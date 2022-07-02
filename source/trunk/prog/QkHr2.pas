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
unit QkHr2;

interface

uses SysUtils, Classes, Graphics, Dialogs, Controls,
     QkObjects, QkFileObjects, QkTextures, QkMd2, QkQ2;

type
 QM8  = class(QTexture2)
        protected
          procedure SaveFile(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; FSize: TStreamPos); override;
        public
          class function CustomParams : Integer; override;
          class function TypeInfo: String; override;
          function BaseGame : Char; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;
 QHr2Model = class(QMd2File)
             protected
               procedure LoadFile(F: TStream; FSize: TStreamPos); override;
               procedure SaveFile(Info: TInfoEnreg1); override;
             public
               class function TypeInfo: String; override;
               class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
             end;

 {------------------------}

implementation

uses qhelper, Game, Setup, Quarkx, QkExceptions, QkMdlObject, QkObjectClassList;

const
 MIP_VERSION = 2;
 MIPLEVELS   = 16;

type
 TM8Header = packed record
              Version: LongInt;
              Name: TCompactTexName;
              Width, Height, Offsets: array[0..MIPLEVELS-1] of LongInt;
              AnimName: TCompactTexName;
              Palette: TPaletteLmp;
              Flags, Contents, Value: LongInt;
             end;

 {------------------------}

class function QM8.TypeInfo: String;
begin
 TypeInfo:='.m8';
end;

class procedure QM8.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5163);
 Info.FileExt:=792;
end;

class function QM8.CustomParams : Integer;
begin
 Result:={MIPLEVELS} cp16MipIndexes or cpPalette or cpPower2;
end;

function QM8.BaseGame : Char;
begin
 Result:=mjHeretic2;
end;

procedure QM8.LoadFile(F: TStream; FSize: TStreamPos);
const
 Spec1 = 'Image1=';
 Spec2 = 'Pal=';
var
 Header: TM8Header;
 Q2MipTex: TQ2MipTex;
 Base: TStreamPos;
 I, W, H: Integer;
 Data: String;
begin
 case ReadFormat of
  rf_Default: begin  { as stand-alone file }
      if FSize<=SizeOf(Header) then
       Raise EError(5519);
      Base:=F.Position;
      F.ReadBuffer(Header, SizeOf(Header));
      if Header.Version <> MIP_VERSION then
       Raise EErrorFmt(5655, [LoadName, Header.Version, MIP_VERSION]);

       { check the sizes }
      W:=Header.Width[0];
      H:=Header.Height[0];
      for I:=1 to MIPLEVELS-1 do
       begin
        ScaleDown(W,H);
        if Header.Offsets[I]=0 then Break;
        if (W<>Header.Width[I]) or (H<>Header.Height[I]) then
         Raise EErrorFmt(5661, [LoadName, Header.Width[I], Header.Height[I], W, H]);
       end;

       { reads the palette }
      Data:=Spec2;
      SetLength(Data, Length(Spec2)+SizeOf(TPaletteLmp));
      PPaletteLmp(@Data[Length(Spec2)+1])^:=Header.Palette;
      Specifics.Add(Data);  { "Pal=xxxxx" }

       { reads the image data }
      Q2MipTex.W:=Header.Width[0];
      Q2MipTex.H:=Header.Height[0];
      Q2MipTex.Nom:=Header.Name;
      Q2MipTex.Animation:=Header.AnimName;
      Q2MipTex.Contents:=Header.Contents;
      Q2MipTex.Flags:=Header.Flags;
      Q2MipTex.Value:=Header.Value;
      LoadTextureData(F, Base, FSize, Q2MipTex, @Header.Offsets, Nil, Nil);
     end;
 else inherited;
 end;
end;

procedure QM8.SaveFile(Info: TInfoEnreg1);
var
 Header: TM8Header;
 Q2: TQ2MipTex;
 I, W, H, LastImg: Integer;
 Delta: Integer;
 Lmp: PPaletteLmp;
 S: String;
begin
 with Info do case Format of
  rf_Default: begin  { as stand-alone file }
      Q2:=BuildWalFileHeader;
      FillChar(Header, SizeOf(Header), 0);
      Header.Version:=MIP_VERSION;
      Header.Name:=Q2.Nom;
      Delta:=SizeOf(Header);
      W:=Q2.W;
      H:=Q2.H;
      LastImg:=ImagesCount-1;
      for I:=0 to LastImg do
       begin
        Header.Width[I]:=W;
        Header.Height[I]:=H;
        Header.Offsets[I]:=Delta;
        Inc(Delta, W*H);
        ScaleDown(W, H);
       end;
      Header.AnimName:=Q2.Animation;
      LoadPaletteLmp(Lmp);
      Move(Lmp^, Header.Palette, SizeOf(TPaletteLmp));
      Header.Flags:=Q2.Flags;
      Header.Contents:=Q2.Contents;
      Header.Value:=Q2.Value;
      F.WriteBuffer(Header, SizeOf(Header));
      for I:=0 to LastImg do
       begin
        S:=GetTexImage(I);
        F.WriteBuffer(S[1], Length(S));
       end;
     end;
 else inherited;
 end;
end;

 {------------------------}

type
 THr2Entry = record
              SectionName: array[0..31] of Byte;
              Version, Size: LongWord;
             end;
 THr2Header = record
               skinwidth: LongInt;
               skinheight: LongInt;
               framesize: LongInt;        // byte size of each frame
               num_skins: LongInt;
               num_xyz: LongInt;
               num_st: LongInt;           // greater than num_xyz for seams
               num_tris: LongInt;
               num_glcmds: LongInt;       // dwords in strip/fan command list
               num_frames: LongInt;
               mesh_nodes: LongInt;       { unknown, for Heretic II only }
              end;

class function QHr2Model.TypeInfo: String;
begin
 Result:='.fm';
end;

class procedure QHr2Model.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5167);
 Info.FileExt:=795;
end;

procedure QHr2Model.LoadFile(F: TStream; FSize: TStreamPos);
var
 mdl: dmdl_t;
 Origine, Delta: TStreamPos;
 Hr2Entry: THr2Entry;
 Hr2Header: THr2Header;
 S: String;
 I, J: Integer;
 CTris: PComponentTris;
begin
 case ReadFormat of
  rf_Default: begin  { as stand-alone file }
      Origine:=F.Position;
      FillChar(mdl, SizeOf(mdl), 0);
      Delta:=0;
      ObjectGameCode:=mjHeretic2;
      while Delta <= FSize-SizeOf(Hr2Entry) do
       begin
        F.Position:=Origine+Delta;
        F.ReadBuffer(Hr2Entry, SizeOf(Hr2Entry));
        Inc(Delta, SizeOf(Hr2Entry));
        if (Delta+Integer(Hr2Entry.Size) > FSize) then
         Raise EErrorFmt(5509, [291]);

        S:=CharToPas(Hr2Entry.SectionName);
        if (S='header') and (Hr2Entry.Size>=SizeOf(Hr2Header)) then
         begin
          F.ReadBuffer(Hr2Header, SizeOf(Hr2Header));
          mdl.ident      := 1;
          mdl.skinwidth  := Hr2Header.skinwidth;
          mdl.skinheight := Hr2Header.skinheight;
          mdl.framesize  := Hr2Header.framesize;
          mdl.num_skins  := Hr2Header.num_skins;
          mdl.num_xyz    := Hr2Header.num_xyz;
          mdl.num_st     := Hr2Header.num_st;
          mdl.num_tris   := Hr2Header.num_tris;
          mdl.num_glcmds := Hr2Header.num_glcmds;
          mdl.num_frames := Hr2Header.num_frames;
         end
        else if S='skin'     then mdl.ofs_skins := Delta
        else if S='st coord' then mdl.ofs_st    := Delta
        else if S='tris'     then mdl.ofs_tris  := Delta
        else if S='frames'   then mdl.ofs_frames:= Delta;
        Inc(Delta, Hr2Entry.Size);
       end;

      S:='';
           if mdl.ident      = 0 then S:='header'
      else if mdl.ofs_skins  = 0 then S:='skin'
      else if mdl.ofs_st     = 0 then S:='st coord'
      else if mdl.ofs_tris   = 0 then S:='tris'
      else if mdl.ofs_frames = 0 then S:='frames';
      if S<>'' then
       Raise EErrorFmt(5672, [LoadName, S]);

      with ReadMd2File(F, Origine, mdl) do
       for I:=1 to Triangles(CTris) do
        begin
         for J:=0 to 2 do
          with CTris^[J] do
           T:=T;  { .m8 skins are top-down, but .pcx skins were bottom-up }
         Inc(CTris);
        end;
     end;
 else inherited;
 end;
end;

procedure QHr2Model.SaveFile(Info: TInfoEnreg1);
begin
 with Info do case Format of
  rf_Siblings: begin  { write the skin files }
     {if Flags and ofNotLoadedToMemory <> 0 then Exit;
      Root:=Saving_Root;
      Info.TempObject:=Root;
      for I:=0 to Root.SubElements.Count-1 do
       if Root.SubElements[I] is QImage then
        begin
         SkinObj:=QImage(Root.SubElements[I]);
         Info.WriteSibling(SkinObj.Name+SkinObj.TypeInfo, SkinObj);
        end;}
     end;

  rf_Default: begin  { write the .fm file }
      raise EQObjectSavingNotSupported.Create('Saving Heretic II models is currently not supported.');
     end;
 else inherited;
 end;
end;

 {------------------------}

initialization
  RegisterQObject(QM8, 'k');
  RegisterQObject(QHr2Model, 'u');
end.
