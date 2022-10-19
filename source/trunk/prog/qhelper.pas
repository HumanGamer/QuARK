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
unit qhelper;

interface

function CharToPas(const C: array of Byte) : String;
procedure PasToChar(var C: array of Byte; const S: String);
function IntToPackedStr(Value: Integer) : String;
function PackedStrToInt(const S: String) : Integer;

function RequiredBytesToContainValue(T: Integer) : Integer;

implementation

uses Math;

function CharToPas(const C: array of Byte) : String;
var
  N{$IFDEF UNICODE}, I{$ENDIF}: Integer;
begin
  N:=0;
  while (N<=High(C)) and (C[N]<>0) do
    Inc(N);
  SetLength(Result, N);
  {$IFDEF UNICODE}
  for I:=0 to N-1 do
  begin
    Result[I+1]:=Chr(C[I]);
  end;
  {$ELSE}
  Move(C, PChar(Result)^, N);
  {$ENDIF}
end;

procedure PasToChar(var C: array of Byte; const S: String);
{$IFDEF UNICODE}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF UNICODE}
  for I:=0 to Min(High(C), Length(S))-1 do
  begin
    C[I]:=Ord(S[I+1]);
  end;
  {$ELSE}
  if Length(S) <= High(C) then
  begin
    Move(PChar(S)^, C, Length(S));
    FillChar(C[Length(S)], High(C)+1-Length(S), 0);
  end
  else
    Move(PChar(S)^, C, High(C)+1);
  {$ENDIF}
end;

function PackedStrToInt(const S: String) : Integer;
var
  ByteSize: Integer;
begin
  ByteSize:=Length(S);
  if ByteSize>SizeOf(Result) then
    ByteSize:=SizeOf(Result);
  Result:=0;
  if Length(S)>0 then
    Move(S[1], Result, ByteSize);
end;

function IntToPackedStr(Value: Integer) : String;
var
  ByteSize: Integer;
begin
  ByteSize:=RequiredBytesToContainValue(Value);
  SetLength(Result, ByteSize);
  Move(Value, Result[1], ByteSize);
end;

function RequiredBytesToContainValue(T: Integer) : Integer;
begin
  if T<0 then
    Result:=SizeOf(T) { $FFFFFFFF - $80000000 }
  else
  if T<$100 then
    Result:=1  { $00 - $FF }
  else
  if T<$10000 then
    Result:=2  { $0000 - $FFFF }
  else
  if T<$1000000 then
    Result:=3  { $000000 - $FFFFFF }
  else
    Result:=4; { $00000000 - $7FFFFFFF }
end;

end.

