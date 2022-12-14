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



unit DX9;

interface

uses Windows, Direct3D, Direct3D9;

var
 g_D3D : IDirect3D9;
 g_D3DDevice : IDirect3DDevice9;

function LoadDirect3D : Boolean;
procedure UnloadDirect3D;

implementation

var
  TimesLoaded : Integer;

 { ----------------- }

function LoadDirect3D : Boolean;
begin
  if TimesLoaded = 0 then
  begin
    Result := False;
    try

     g_D3D := Direct3DCreate9(D3D_SDK_VERSION);
     {if (!g_D3D) then
       begin

       end;}

      TimesLoaded := 1;
      Result := True;
    finally
      if (not Result) then
      begin
        TimesLoaded := 1;
        UnloadDirect3D;
      end;
    end;
  end
  else
  begin
    TimesLoaded := TimesLoaded + 1;
    Result := True;
  end;
end;

procedure UnloadDirect3D;
begin
  if TimesLoaded = 1 then
    begin
    if not (g_D3D=Nil) then
      begin
      {g_D3D->Release();}  {Daniel: Shouldn't we release it with the release-procedure?}
      g_D3D:=Nil;
      end;
    TimesLoaded := 0;
    end
  else
    TimesLoaded := TimesLoaded + 1;
end;

initialization

  TimesLoaded := 0;
end.
