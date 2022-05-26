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

uses SysUtils, qhelper, Quarkx, Setup, QkTextures, QkExceptions, Logging;

const
 DKMaxMipmaps = 9;

type
 TDKMiptex = packed record
              Version: Byte;
              Nom: TCompactTexName;
              padding1, padding2, padding3: Byte;
              W,H: LongInt;
              Indexes: array[0..DKMaxMipmaps-1] of LongInt;
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
const
  Spec1 = 'Image#=';
  PosNb = 6;
  Spec2 = 'Pal=';
var
  Header: TDKMiptex;
  S: String;
  I: Integer;
  Taille1: TStreamPos;
  V: array[1..2] of Single;
  W, H: Integer;
begin
  if Taille-Base<SizeOf(Header) then
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
  for I:=0 to DKMaxMipmaps-1 do
  begin
    if Header.Indexes[I]=0 then
      Break;
    S:=Spec1;
    S[PosNb]:=ImgCodes[I];
    Taille1:=W*H;
    if I=DKMaxMipmaps-1 then
    begin
      if Base+Header.Indexes[I]+Taille1 > Taille then
      begin
        Log(LOG_WARNING, LoadStr1(5859), [Texture.GetFullName()]);
        Break;
      end;
    end
    else
    begin
      if Base+Header.Indexes[I]+Taille1 > Base+Header.Indexes[I+1] then
      begin
        Log(LOG_WARNING, LoadStr1(5859), [Texture.GetFullName()]);
        Break;
      end;
    end;
    SetLength(S, Length(Spec1)+Taille1);
    F.Position:=Base+Header.Indexes[I];
    F.ReadBuffer(S[Length(Spec1)+1], Taille1);
    Texture.Specifics.Add(S);
    if not ScaleDown(W,H) then
      Break;
  end;

  //Read palette
  S:=Spec2;
  SetLength(S, Length(Spec2)+768);
  Move(Header.Palette, S[Length(Spec2)+1], 768);
  Texture.Specifics.Add(S);

  if Header.Animation[0]<>0 then
    Texture.Specifics.Add('Anim='+CharToPas(Header.Animation));

  Texture.Specifics.Add('Contents='+IntToStr(Header.Contents));
  Texture.Specifics.Add('Flags='+IntToStr(Header.Flags));
  Texture.Specifics.Add('Value='+IntToStr(Header.Value));
  F.Position:=Base+Taille;
end;

//FIXME: Add save support!

 {------------------------}

initialization

end.
