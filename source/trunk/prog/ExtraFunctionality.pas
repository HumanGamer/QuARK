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


unit ExtraFunctionality;

interface

{$I DelphiVer.inc}

uses SysUtils;
function ConvertPath(const s: string):string;


{$ifndef Delphi6Over} // Pre-dates Delphi 6

// IncludeTrailingPathDelimiter returns the path with a PathDelimiter
//  ('/' or '\') at the end.  This function is MBCS enabled.
function IncludeTrailingPathDelimiter(const S: string): string;

const
  PathDelim  = {$IFDEF MSWINDOWS} '\'; {$ELSE} '/'; {$ENDIF}
  DriveDelim = {$IFDEF MSWINDOWS} ':'; {$ELSE} '';  {$ENDIF}
  PathSep    = {$IFDEF MSWINDOWS} ';'; {$ELSE} ':'; {$ENDIF}

{$endif}

implementation

function ConvertPath(const s: string):string;
begin
  {$IFDEF LINUX}
  result:=StringReplace(s,'\',PathDelim,[rfReplaceAll]);
  {$ELSE}
  result:=StringReplace(s,'/',PathDelim,[rfReplaceAll]);
  {$ENDIF}
end;

{$ifndef Delphi6Over} // Pre-dates Delphi 6
function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + PathDelim;
end;
{$endif}

end.
