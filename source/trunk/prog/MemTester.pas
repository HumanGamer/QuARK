(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor
Copyright (C) QuArK Development Team

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

https://quark.sourceforge.io/ - Contact information in AUTHORS.TXT
**************************************************************************)
unit MemTester;

interface

{$I DelphiVer.inc}

uses Windows;

{$IFDEF Debug} //Only use this in Debug
{.$DEFINE MemTesterDiff}
{.$DEFINE MemResourceViewer}
{.$DEFINE MemHeavyListings} //Do not activate if MemTesterPassthrough is defined!
{.$DEFINE MemTrackAddress}
{$ELSE}
{$DEFINE MemTesterPassthrough}
{$ENDIF}

var
 g_DataDumpProc: procedure;

procedure MemTesting(H: HWnd);
function HeavyMemDump: String;

implementation

uses SysUtils;

const
 DifferenceAttendue = 105;
 TrackMemoryAddress1 = $019e0000;
 TrackMemoryAddress2 = $02020000;
 TrackMemorySize     = 644;

var
 OldMemMgr: TMemoryManager;
 GetMemCount: Integer;
 FreeMemCount: Integer;
 {$IFNDEF MemTesterPassthrough}
 AllocatedMemSize: {$IFDEF DelphiXE2orNewerCompiler}NativeInt{$ELSE}Integer{$ENDIF};
 {$ENDIF}

{$OPTIMIZATION OFF}

{$IFNDEF MemTesterPassthrough}
const
 Signature1 = Integer($89D128BA);
 Signature2 = Integer($3C66336C);
 Signature3 = Integer($FFFFFFFF);
{$ENDIF}

{$IFDEF MemHeavyListings}
type
 PPointer = ^Pointer;
var
 FullLinkedList: Pointer = Nil;
 FullListSize: Integer = 0;
{$ENDIF}

function NewGetMem(Size: {$IFDEF DelphiXE2orNewerCompiler}NativeInt{$ELSE}Integer{$ENDIF}): Pointer;
begin
  Inc(GetMemCount);
  Result := OldMemMgr.GetMem(Size+{$IFDEF MemHeavyListings} 20 {$ELSE} 16 {$ENDIF});
  {$IFNDEF MemTesterPassthrough}
  PInteger(Result)^:=Size;
  PInteger(PChar(Result)+4)^:=Signature1;
  Inc(PChar(Result), 8);
  PInteger(PChar(Result)+Size)^:=Signature2;
  PInteger(PChar(Result)+Size+4)^:=Signature3;
  {$IFDEF MemHeavyListings}
  PPointer(PChar(Result)+Size+8)^:=FullLinkedList;
  FullLinkedList:=Result;
  Inc(FullListSize);
  {$ENDIF}
  Inc(AllocatedMemSize, Size);
  {$IFDEF MemTrackAddress}
  if (Size=TrackMemorySize) and (Integer(Result)>=TrackMemoryAddress1) and (Integer(Result)<TrackMemoryAddress2) then
   Result:=Nil;    { BREAKPOINT }
  {$ENDIF}
  {$ENDIF}
end;

function NewFreeMem(P: Pointer): Integer;
{$IFNDEF MemTesterPassthrough}
var
  OldSize: Integer;
{$ENDIF}
begin
  Inc(FreeMemCount);
  {$IFNDEF MemTesterPassthrough}
  Dec(PChar(P), 8);
  OldSize:=PInteger(P)^;
  if (OldSize<=0) or (OldSize>=$2000000)
  or (PInteger(PChar(P)+4)^<>Signature1)
  or (PInteger(PChar(P)+OldSize+8)^<>Signature2)
  or (PInteger(PChar(P)+OldSize+12)^<>Signature3) then
   Raise Exception.CreateFmt('Very bad internal error [FreeMem %x]', [OldSize]);
  PInteger(PChar(P))^:=$12345678;
  PInteger(PChar(P)+12)^:=$BADF00D;
  Dec(AllocatedMemSize, OldSize);
  {$IFDEF MemHeavyListings}
  PInteger(PChar(P)+4)^:=PInteger(PChar(P)+OldSize+16)^;
  Dec(FullListSize);
  Result := 0;
  {$ELSE}
  Result := OldMemMgr.FreeMem(P);
  {$ENDIF}
  {$ELSE}
  Result := OldMemMgr.FreeMem(P);
  {$ENDIF}
end;

function NewReallocMem(P: Pointer; Size: {$IFDEF DelphiXE2orNewerCompiler}NativeInt{$ELSE}Integer{$ENDIF}): Pointer;
{$IFNDEF MemTesterPassthrough}
var
 OldSize: Integer;
{$IFDEF MemHeavyListings} I: Integer; {$ENDIF}
{$ENDIF}
begin
  {$IFNDEF MemTesterPassthrough}
  Dec(PChar(P), 8);
  OldSize:=PInteger(P)^;
  if (OldSize<=0) or (OldSize>=$2000000)
  or (PInteger(PChar(P)+4)^<>Signature1)
  or (PInteger(PChar(P)+OldSize+8)^<>Signature2)
  or (PInteger(PChar(P)+OldSize+12)^<>Signature3) then
   Raise Exception.CreateFmt('Very bad internal error [ReallocMem %d]', [OldSize]);
  {$IFDEF MemHeavyListings}
  Inc(PChar(P), 8);
  if Size<=OldSize then
   begin
    Result:=P;
    Exit;
   end;
  Result:=NewGetMem(Size);
  I:=0;
  while I<OldSize do
   begin
    PChar(Result)[I]:=PChar(P)[I];
    Inc(I);
   end;
  NewFreeMem(P);
  {$ELSE}
  Inc(AllocatedMemSize, Size-OldSize);
  Result := OldMemMgr.ReallocMem(P, Size+16);
  PInteger(Result)^:=Size;
  PInteger(PChar(Result)+4)^:=Signature1;
  Inc(PChar(Result), 8);
  PInteger(PChar(Result)+Size)^:=Signature2;
  PInteger(PChar(Result)+Size+4)^:=Signature3;
  {$ENDIF}
  {$ELSE}
  Result := OldMemMgr.ReallocMem(P, Size);
  {$ENDIF}
end;

{$IFDEF MemHeavyListings}
function HeavyMemDump: String;
var
 P: Pointer;
 OldSize, Count: Integer;
 Q: PChar;
 Args: array[1..2] of Integer;
begin
 P:=FullLinkedList;
 Count:=FullListSize;
 SetLength(Result, Count*19);
 Q:=Pointer(Result);
 while Assigned(P) do
  begin
   Dec(PChar(P), 8);
   OldSize:=PInteger(P)^;
   if OldSize<>$12345678 then
    begin
     if Count=0 then Raise Exception.Create('HeavyMemDump: Count<0');
     Dec(Count);
     Args[1]:=Integer(P);
     Args[2]:=OldSize;
     wvsprintf(Q, '%08x %8d'#13#10, PChar(@Args));
     Inc(Q, 19);
     P:=PPointer(PChar(P)+OldSize+16)^;
    end
   else
    P:=PPointer(PChar(P)+4)^;
  end;
 if Count>0 then Raise Exception.Create('HeavyMemDump: Count>0');
end;
{$ELSE}
function HeavyMemDump: String;
begin
 Result:='';
end;
{$ENDIF}


{$IFDEF MemResourceViewer}
procedure MemTesting(H: HWnd);
var
 S: String;
 DC: HDC;
 OldMode: Cardinal;
 R: TRect;
begin
 GetWindowRect(H, R);
 S:=Format('<%d blocks, %.2f Kb>', [GetMemCount-FreeMemCount, AllocatedMemSize/1024]);
 DC:=GetWindowDC(H);
 try
  OldMode:=SetTextAlign(DC, TA_TOP or TA_RIGHT);
  TextOut(DC, R.Right-R.Left-60,5, PChar(S), Length(S));
  SetTextAlign(DC, OldMode);
 finally
  ReleaseDC(H, DC);
 end;
end;
(*procedure MemTesting(H: HWnd);
var
 Buffer: array[0..255] of Char;
 I: Integer;
 S: String;
 Diff: Boolean;
 Src: PChar;
begin
 S:=Format(' <%d blocks, %.2f Kb>', [GetMemCount-FreeMemCount, AllocatedMemSize/1024]);
 I:=GetWindowText(H, Buffer, SizeOf(Buffer));
 if (I>0) and (Buffer[I-1]='>') then
  begin
   Dec(I,3);
   while (I>0) and (Buffer[I+1]<>'<') do
    Dec(I);
  end;
 Diff:=False;
 Src:=PChar(S);
 repeat
  if Src^<>Buffer[I] then
   begin
    Buffer[I]:=Src^;
    Diff:=True;
   end;
  if Src^=#0 then Break;
  Inc(Src);
  Inc(I);
 until False;
 if Diff then
  SetWindowText(H, Buffer);
end;*)
{$ELSE}
procedure MemTesting(H: HWnd);
begin
end;
{$ENDIF}


const
  NewMemMgr: TMemoryManager = (
  GetMem: NewGetMem;
  FreeMem: NewFreeMem;
  ReallocMem: NewReallocMem);

procedure Resultat;
var
 Z: Array[0..127] of Char;
{I: Integer;}
begin
 StrPCopy(Z, Format('This is a bug ! Please report : %d # %d.', [GetMemCount-FreeMemCount, DifferenceAttendue]));
 MessageBox(0, Z, 'MemTester', mb_Ok);
{if Assigned(g_DataDumpProc) then
  begin
   StrCat(Z, #13#13'Write a data report (DATADUMP.TXT) ?');
   I:=mb_YesNo;
  end
 else
  I:=mb_Ok;
 if MessageBox(0, Z, 'MemTester', I) = idYes then
  g_DataDumpProc;}
end;

initialization
  GetMemoryManager(OldMemMgr);
  SetMemoryManager(NewMemMgr);
finalization
  if Assigned(g_DataDumpProc) then
   g_DataDumpProc;
{$IFDEF MemTesterDiff}
  if GetMemCount-FreeMemCount <> DifferenceAttendue then
   Resultat;
{$ENDIF}
{$IFNDEF CompiledWithDelphi2}
  SetMemoryManager(OldMemMgr);
{$ENDIF}
end.
