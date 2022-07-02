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
unit Platform;

interface

type
  TSoundType = (SOUND_DEFAULT, SOUND_INFO, SOUND_QUESTION, SOUND_WARNING, SOUND_ERROR);

function PlaySound(const SoundType: TSoundType): Boolean;

implementation

uses {$IFDEF LINUX}SysUtils{$ELSE}Windows{$ENDIF}, QkExceptions;

function PlaySound(const SoundType: TSoundType): Boolean;
{$IFNDEF LINUX}
var
  uType: UINT;
{$ENDIF}
begin
  {$IFDEF LINUX}
  Beep;
  Result:=True;
  {$ELSE}
  case SoundType of
  SOUND_DEFAULT: uType:=MB_OK;
  SOUND_INFO: uType:=MB_ICONINFORMATION;
  SOUND_QUESTION: uType:=MB_ICONQUESTION;
  SOUND_WARNING: uType:=MB_ICONWARNING;
  SOUND_ERROR: uType:=MB_ICONERROR;
  else raise InternalE('Unknown SoundType');
  end;
  Result:=Windows.MessageBeep(uType);
  {$ENDIF}
end;

end.
