(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor
Copyright (C) Armin Rigo

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
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

http://www.planetquake.com/quark - Contact information in AUTHORS.TXT
**************************************************************************)

{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.2  2007/08/21 23:43:44  danielpharos
Another fix to the HL2 building process.

Revision 1.1  2007/08/14 16:32:59  danielpharos
HUGE update to HL2: Loading files from Steam should work again, now using the new QuArKSAS utility!


}

unit PakFiles;

interface

uses  Windows, Classes;

type
  TGetPakNames = class
  private
   StrList : TStringList;
   StrListIter : Integer;
  public
   constructor Create;
   destructor Destroy; override;
   procedure ResetIter(Backwards: Boolean);
   procedure CreatePakList(const Path, CustomFilter: String; Backwards: Boolean; SearchForTemp: boolean);
   function GetNextPakName(MustExist: Boolean; var FileName: String; Backwards: Boolean) : Boolean;
  end;

 {------------------------}

function IsPakTemp(const theFilename: String) : Boolean;
function FindNextAvailablePakFilename(Force: Boolean) : String;

 {------------------------}

implementation

uses StrUtils, SysUtils, Setup, Game, QkPak, Quarkx;

function IsPakTemp(const theFilename: String) : Boolean;
var
 F: TFileStream;
 IntroEx: TIntroPakEx;
begin
 if FileExists(theFilename) = false then
 begin
  Result:=False;
  Exit;
 end;

 //Only Quake1/2 PAK files support this at the moment
 //PK3 also, but we can't detect/strip them...
 if (UpperCase(RightStr(theFilename,4))<>'.PAK') then
 begin
  Result:=False;
  Exit;
 end;

 try
  F:=TFileStream.Create(theFilename, fmOpenRead or fmShareDenyNone);
  try
   F.ReadBuffer(IntroEx, SizeOf(IntroEx));
   Result:=((IntroEx.Intro.Signature=SignaturePACK)
         or (IntroEx.Intro.Signature=SignatureSPAK))
        and (IntroEx.Code1=SignatureQuArKPAK1)
        and (IntroEx.Code2=SignatureQuArKPAK2);
  finally
   F.Free;
  end;
 except
  Result:=False;
 end;
end;

constructor TGetPakNames.Create;
begin
  StrList := TStringList.Create;
  StrList.Sorted := True;
end;

destructor TGetPakNames.Destroy;
begin
  StrList.Free;
  inherited;
end;

procedure TGetPakNames.ResetIter(Backwards: Boolean);
begin
 if Backwards then
   StrListIter:=StrList.Count
 else
   StrListIter:=-1; //-- will be increased in GetNextPakName --
end;

procedure TGetPakNames.CreatePakList(const Path, CustomFilter: String; Backwards: Boolean; SearchForTemp: Boolean);
var
 PakFileExt: String;
 PakFileFilter: String;
 PakFileMaxNumber: Integer;
 I, J: Integer;
 S: String;
 sr: TSearchRec;
begin
 StrList.Clear;
 PakFileExt:=SetupGameSet.Specifics.Values['PakExt'];
 if SearchForTemp then
   //We're going to search for QuArK's temp pak files,
   //so we have to force-search ALL pak files.
   PakFileFilter:='*'+PakFileExt
 else
   if CustomFilter<>'' then
     PakFileFilter:=CustomFilter
   else
     PakFileFilter:=SetupGameSet.Specifics.Values['PakFormat'];
 if PakFileFilter='' then
 begin
   if PakFileExt<>'' then
     PakFileFilter:='PAK#'+PakFileExt
   else
     PakFileFilter:='PAK#.PAK';
 end;
 I:=Pos('#', PakFileFilter);
 if I>0 then
 begin
   PakFileMaxNumber:=SetupGameSet.IntSpec['PakMaxNumber'];
   if PakFileMaxNumber<=0 then
     PakFileMaxNumber:=9;
   //Setup a list of strings; example: "PAK0.PAK", "PAK1.PAK", ...
   for J:=0 to PakFileMaxNumber do
   begin
     S := LeftStr(PakFileFilter, I-1) + IntToStr(J) + RightStr(PakFileFilter, Length(PakFileFilter) - I);
     StrList.Add(PathAndFile(Path, S));
   end;
 end
 else
 begin
   //Get the list of strings, by looking in the path for files matching the filefilter
   if FindFirst(PathAndFile(Path, PakFileFilter), faAnyFile, sr) = 0 then
   begin
     S := PathAndFile(Path, sr.Name);
     if (not SearchForTemp) or (SearchForTemp and IsPakTemp(S)) then
       StrList.Add(S);
     while FindNext(sr) = 0 do
     begin
       S := PathAndFile(Path, sr.Name);
       if (not SearchForTemp) or (SearchForTemp and IsPakTemp(S)) then
         StrList.Add(S);
     end;
     FindClose(sr);
   end;
 end;

 //Do correct sorting: Quake games load the official PAK-files FIRST,
 //then any others in alphabetical order. (StrList.Sorted := True;)

 ResetIter(Backwards);
end;

function TGetPakNames.GetNextPakName(MustExist: Boolean; var FileName: String; Backwards: Boolean) : Boolean;
begin
  Result:=False;
  repeat
    if Backwards then
      Dec(StrListIter)
    else
      Inc(StrListIter);
    if (StrListIter<0) or (StrListIter>=StrList.Count) then
      Exit;
    FileName:=StrList.Strings[StrListIter];
  until not MustExist or FileExists(FileName);
  Result:=True;
end;

function FindNextAvailablePakFilename(Force: Boolean) : String;
var
 GameModDir, AvailablePakFile: String;
 GetPakNames: TGetPakNames;
 PakFileExt: String;
 PakFileMaxNumber: Integer;
 I: Integer;
 FoundFreeOne: Boolean;
begin
 GameModDir:=GetGameDir;
 if (SetupGameSet.Specifics.Values['AlwaysPak']='')
 and (GameModDir=GettmpQuArK) and not Force then
 begin
   FindNextAvailablePakFilename:='';  // no pak file to write
   Exit;
 end;
 GameModDir:=PathAndFile(QuakeDir, GameModDir);
 GetPakNames := TGetPakNames.Create;
 try
   //-- Find last existing package with QuArK-tag --
   GetPakNames.CreatePakList(ExpandFileName(GameModDir), '', True, True);
   if GetPakNames.GetNextPakName(True, AvailablePakFile, True) = false then
   begin
     PakFileExt:=SetupGameSet.Specifics.Values['PakExt'];
     PakFileMaxNumber:=SetupGameSet.IntSpec['PakMaxNumber'];
     if PakFileMaxNumber<=0 then
       PakFileMaxNumber:=9;
     FoundFreeOne:=False;
     for I:=0 to PakFileMaxNumber do
     begin
       AvailablePakFile:=PathAndFile(GameModDir,'tmpQuArK' + IntToStr(I) + PakFileExt);
       if FileExists(AvailablePakFile) = false then
       begin
         FoundFreeOne:=True;
         break;
       end;
     end;
     if not FoundFreeOne then
     begin
       Raise EErrorFmt(5630, [AvailablePakFile]);
       AvailablePakFile:='';
     end;
   end;
   FindNextAvailablePakFilename:=AvailablePakFile;
 finally
   GetPakNames.Free;
 end;
end;

end.
