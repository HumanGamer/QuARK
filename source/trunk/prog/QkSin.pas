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
unit QkSin;

interface

uses Windows, SysUtils, Classes, Graphics, Dialogs, Controls,
     QkObjects, QkFileObjects, QkTextures, QkPak, qmath
     ,QkQ2;

type
 QTextureSin = class(QTexture2)
        protected
          procedure SaveFile(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; FSize: TStreamPos); override;
        public
          class function TypeInfo: String; override;
          class function CustomParams : Integer; override;
          function BaseGame : Char; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;
 QSinPak = class(QPak)
           public
             class function TypeInfo: String; override;
             class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
           end;

 {------------------------}

implementation

uses Game, Setup, Quarkx, QkExceptions, QkObjectClassList;

type
 {tiglari: this stuff is binary data just read into this structure in
    one gulp in QTextureSin.LoadFile}
 TSinHeader = packed record
               Name: array[0..63] of Char;
               Width, Height: LongInt;
               Palette: array[0..255] of record R,G,B,A: Byte; end;
               PalCrc: Word;
               Reserved1: Word;
               Offsets: array[0..3] of LongInt;
               AnimName: array[0..63] of Char;
               Flags, Contents: LongInt;
               Value, direct: Word;
               animtime, nonlit: Single;
               directangle, trans_angle: Word;
               directstyle, translucence, friction, restitution, trans_mag: Single;
               color: array[0..2] of Single;
              end;

 {------------------------}

class function QTextureSin.TypeInfo: String;
begin
 TypeInfo:='.swl';
end;

class procedure QTextureSin.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5165);
 Info.FileExt:=793;
end;

class function QTextureSin.CustomParams : Integer;
begin
 Result:=cp4MipIndexes or cpPalette or cpAnyHeight;
end;

function QTextureSin.BaseGame : Char;
begin
 Result:=mjSin;
end;

procedure QTextureSin.LoadFile(F: TStream; FSize: TStreamPos);
const
 Spec1 = 'Image1=';
 Spec2 = 'Pal=';
 Spec3 = 'Alpha=';
var
 Header: TSinHeader;
 Q2MipTex: TQ2MipTex;
 Base: TStreamPos;
 I: Integer;
 Lmp: PPaletteLmp;
 Data: String;
 HasAlpha: Boolean;
 P: PChar;
begin
 case ReadFormat of
  rf_Default: begin  { as stand-alone file }
      if FSize<=SizeOf(Header) then
       Raise EError(5519);
      Base:=F.Position;
      F.ReadBuffer(Header, SizeOf(Header));

       { reads the palette }
      Data:=Spec2;
      SetLength(Data, Length(Spec2)+SizeOf(TPaletteLmp));
      Lmp:=PPaletteLmp(@Data[Length(Spec2)+1]);
      HasAlpha:=False;
      for I:=Low(Lmp^) to High(Lmp^) do
       with Header.Palette[I] do
        begin
         Lmp^[I,0]:=R;
         Lmp^[I,1]:=G;
         Lmp^[I,2]:=B;
         if A<>0 then
          HasAlpha:=True;
        end;
      Specifics.Add(Data);  { "Pal=xxxxx" }

      if HasAlpha then
       begin
        Data:=Spec3;
        SetLength(Data, Length(Spec3)+256);
        P:=@Data[Length(Spec3)+1];
        for I:=0 to 255 do
         P[I]:=Chr(Header.Palette[I].A);
        Specifics.Add(Data);  { "Alpha=xxxx" }
       end;

       { reads misc flags }
      IntSpec['PalCrc']:=Header.PalCrc;
      Specifics.Add('direct='+IntToStr(Header.direct));
      SetFloatSpec('animtime', Header.animtime);
      SetFloatSpec('nonlit', Header.nonlit);
      Specifics.Add('directangle='+IntToStr(Header.directangle));
      Specifics.Add('trans_angle='+IntToStr(Header.trans_angle));
    { tiglari: this shouldn't be set since it shouldn't be in .swl's
	   at all, nor in tex. def. files, it's a label for grouping light
	   sources that go on & off together, treated as a string in the
	   editor & converted to a logical integer by qbsp, wtf knows why
	   it gets coded as a float in the .swls......
	  SetFloatSpec('directstyle', Header.directstyle); }
      SetFloatSpec('translucence', Header.translucence);
      SetFloatSpec('friction', Header.friction);
      SetFloatSpec('restitution', Header.restitution);
      SetFloatSpec('trans_mag', Header.trans_mag);

    { tiglari: we revise this so as to represent color as a string coding
	  the three floats (2 dec places)
	  SetFloatsSpec('color', Header.color); }

      Specifics.Add('color='+FloatToStrF(Header.color[0],ffFixed,7,2)+' '+
                             FloatToStrF(Header.color[1],ffFixed,7,2)+ ' '+
                             FloatToStrF(Header.color[2],ffFixed,7,2));

       { reads the image data }
      Q2MipTex.W:=Header.Width;
      Q2MipTex.H:=Header.Height;
      Q2MipTex.Contents:=Header.Contents;
      Q2MipTex.Flags:=Header.Flags;
      Q2MipTex.Value:=Header.Value;
      LoadTextureData(F, Base, FSize, Q2MipTex, @Header.Offsets, Header.Name, Header.AnimName);
     end;
 else inherited;
 end;
end;

{ tiglari:  Not sure what this is actually for, tho it seems to write
   info in the object-specific format to the header format. }
procedure QTextureSin.SaveFile;
var
 Header: TSinHeader;
 I, Taille: Integer;
 Delta: Integer;
 Lmp: PPaletteLmp;
 S: String;
 V: array[1..2] of Single;
 Cl: array[0..2] of TDouble;
 begin
 with Info do case Format of
  rf_Default: begin  { as stand-alone file }
      FillChar(Header, SizeOf(Header), 0);
      StrPLCopy(Header.Name, GetTexName, SizeOf(Header.Name));
      if not GetFloatsSpec('Size', V) then
       Raise EErrorFmt(5504, ['Size']);
      Header.Width:=Round(V[1]);
      Header.Height:=Round(V[2]);
      LoadPaletteLmp(Lmp);
      for I:=0 to 255 do
       with Header.Palette[I] do
        begin
         R:=Lmp^[I,0];
         G:=Lmp^[I,1];
         B:=Lmp^[I,2];
        end;
      S:=Specifics.Values['Alpha'];
      for I:=1 to Length(S) do
       Header.Palette[I-1].A:=Ord(S[I]);

      Header.PalCrc:=IntSpec['PalCrc'];

      Delta:=SizeOf(Header);
      Taille:=Header.Width*Header.Height;
      for I:=0 to 3 do
       begin
        Header.Offsets[I]:=Delta;
        Inc(Delta, Taille);
        Taille:=Taille div 4;
       end;

      StrPLCopy(Header.AnimName, Specifics.Values['Anim'], SizeOf(Header.AnimName));
      Header.Contents:=StrToIntDef(Specifics.Values['Contents'], 0);
      Header.Flags   :=StrToIntDef(Specifics.Values['Flags'], 0);
      Header.Value   :=StrToIntDef(Specifics.Values['Value'], 0);
      Header.direct  :=StrToIntDef(Specifics.Values['direct'], 0);
      Header.animtime    :=GetFloatSpec('animtime', 0.2);
      Header.nonlit      :=GetFloatSpec('nonlit', 0.0);
      Header.directangle :=StrToIntDef(Specifics.Values['directangle'], 0);
      Header.trans_angle :=StrToIntDef(Specifics.Values['trans_angle'], 0);
   {  tiglari: removing this one, see above
      Header.directstyle :=GetFloatSpec('directstyle', 0.0);  }
      Header.translucence :=GetFloatSpec('translucence', 0.0);
      Header.friction :=GetFloatSpec('friction', 1.0);
      Header.restitution :=GetFloatSpec('restitution', 0.0);
      Header.trans_mag :=GetFloatSpec('trans_mag', 0.0);
    { tiglari: revising rep to string
      GetFloatsSpec('color', Header.color); }
      ReadDoubleArray(Specifics.Values['color'], Cl);
    { tiglari: this looks real dumb, is there a cast construction or something
       that could be used instead? }
      for I:=0 to 2 do
       Header.color[i]:=Cl[i];

      F.WriteBuffer(Header, SizeOf(Header));
      for I:=0 to 3 do
       begin
        S:=GetTexImage(I);
        F.WriteBuffer(S[1], Length(S));
       end;
     end;
 else inherited;
 end;
end;

 {------------------------}

class function QSinPak.TypeInfo;
begin
 Result:='.sin';
end;

class procedure QSinPak.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5166);
 Info.FileExt:=794;
end;

 {------------------------}

initialization
  RegisterQObject(QTextureSin, 'k');
  RegisterQObject(QSinPak, 't');
end.
