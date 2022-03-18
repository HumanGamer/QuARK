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

http://quark.sourceforge.net/ - Contact information in AUTHORS.TXT
**************************************************************************)
unit QkDaikatana;

interface

uses Classes, QkObjects, QkQ2;

procedure LoadTextureDataDK(F: TStream; Base, Taille: TStreamPos; var Texture: QTexture2);

 {------------------------}

implementation

uses SysUtils, Quarkx, Setup, QkExceptions;

type
 TDKMiptex = packed record
              Version: Byte;
              Nom: TCompactTexName;
              padding1, padding2, padding3: Byte;
              W,H: LongInt;
              Indexes: array[0..8] of LongInt;
              Animation: TCompactTexName;
              Flags: LongInt;
              Contents: LongInt;
              Palette: array[0..767] of Byte;
              Value: LongInt;
             end;

 {------------------------}

//Copied (and slightly modified) from QkTextures
procedure CheckTexName(const Texture: QTexture2; const nName: String);
var
  TexName: String;
begin
  if SetupSubSet(ssFiles, 'Textures').Specifics.Values['TextureNameCheck']<>'' then
  begin
    TexName := Texture.GetTexName;
    if ((nName = '') or (TexName = '')) and (SetupSubSet(ssFiles, 'Textures').Specifics.Values['TextureEmptyNameValid']<>'') then
      Exit;
    if CompareText(nName, TexName)<>0 then
      GlobalWarning(FmtLoadStr1(5569, [nName, TexName]));
  end;
end;

//Based on QkQ2's LoadTextureData
procedure LoadTextureDataDK(F: TStream; Base, Taille: TStreamPos; var Texture: QTexture2);
var
  Header: TDKMiptex;
  S: String;
  I: Integer;
  V: array[1..2] of Single;
  W, H: Integer;
begin
  if Taille<SizeOf(Header) then
    Raise EError(5519);
  F.ReadBuffer(Header, SizeOf(Header));
  if Header.Version <> 3 then
    Raise EErrorFmt(5858, [Header.Version]);
  S:=CharToPas(Header.Nom);
  for I:=Length(S) downto 1 do
  begin
    if S[I]='/' then
    begin
      Texture.Specifics.Add('Path='+Copy(S,1,I-1));
      Break;
    end;
  end;
  CheckTexName(Texture, S);
  W:=Header.W;
  H:=Header.H;
  V[1]:=W;
  V[2]:=H;
  Texture.SetFloatsSpec('Size', V);
  //FIXME: Load the actual image data
end;

 {------------------------}

initialization

end.
