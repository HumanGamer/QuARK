(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor
Copyright (C) 1996-99 Armin Rigo

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

Contact the author Armin Rigo by e-mail: arigo@planetquake.com
or by mail: Armin Rigo, La Cure, 1854 Leysin, Switzerland.
See also http://www.planetquake.com/quark
**************************************************************************)
{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.6  2000/06/23 20:35:54  alexander
fixed potential pak file corruption on write .m32
optimized memory usage and speed for load of .m32

Revision 1.5  2000/06/10 15:20:14  alexander
added: texture flag loading and saving for SoF

Revision 1.4  2000/05/21 20:43:19  alexander
fixed: that R and B colors were xchanged
fixed: distorted loading of some textures (H and W xchanged)

Revision 1.3  2000/05/14 15:06:56  decker_dk
Charger(F,Taille) -> LoadFile(F,FSize)
ToutCharger -> LoadAll
ChargerInterne(F,Taille) -> LoadInternal(F,FSize)
ChargerObjTexte(Q,P,Taille) -> ConstructObjsFromText(Q,P,PSize)

Revision 1.2  2000/05/11 22:08:04  alexander
added copyright header

}
unit QkSoF;

interface

uses SysUtils, Classes, QkObjects, QkFileObjects, QkImages, Dialogs;

type
 QM32 = class(QImages)
        protected
          procedure Enregistrer(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; FSize: Integer); override;
        public
          class function TypeInfo: String; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

implementation

uses Windows, Travail, Quarkx, QkPixelSet;

var InitialStreamPos : longint;

Procedure WriteZeros(F: TStream; tilloffset: longint);
Var
  zero : byte;
begin
  zero:=0;
  while tilloffset > InitialStreamPos - F.position do
    F.WriteBuffer(zero, 1);
end;

Procedure QM32.Enregistrer(Info: TInfoEnreg1);
type
  PRGB = ^TRGB;
  TRGB = array[0..2] of Byte;
const
  spec1='Image1=';
  spec2='Alpha=';
var
  LineWidth, J, K: Integer;
  sig, h, w: longint;
  contents,flags,value:longint;
  Aname: string;
  ScanLine, AlphaScanLine: PChar;
  PSD,OldPSD: TPixelSetDescription;
  PBaseLineBuffer,PLineBuffer: PChar;
  SourceRGB: PRGB;
begin
 with Info do case Format of
  1: begin  { as stand-alone file }
    PSD.Init;
    OldPSD:=Description;
    try
      PSD.Format:=psf24bpp;  { force to 24bpp }
      PSD.AlphaBits:=psa8bpp;  { force to 8bpp alpha }
      PSDConvert(PSD, OldPSD, ccTemporary);
     { use PSD here, it is guaranteed to be 24bpp + 8bpp alpha }

      InitialStreamPos:=F.Position; {save where we are (needed pak file)}
      
      Contents:=StrToIntDef(Specifics.Values['Contents'], 0);
      Flags   :=StrToIntDef(Specifics.Values['Flags'], 0);
      Value   :=StrToIntDef(Specifics.Values['Value'], 0);

      sig:=0004; // 04 00 00 00 header
      F.WriteBuffer(sig,4);
      AName:=Name;
      F.WriteBuffer(AName[1], length(aname));
      WriteZeros(F, $204);
      with PSD.Size do begin
        W:=X;
        H:=Y;
      end;
      F.WriteBuffer(W, 2);
      WriteZeros(F, $244);
      F.WriteBuffer(H, 2);
      WriteZeros(F, $2c4);
      F.WriteBuffer(flags, 4);
      F.WriteBuffer(contents , 4);
      F.WriteBuffer(value, 4);
      WriteZeros(F, $3C8);
      LineWidth:= W * 4;  { 4 bytes per line (32 bit)}
      ScanLine:=PSD.StartPointer;
      AlphaScanLine:=PSD.AlphaStartPointer;
      GetMem(PBaseLineBuffer, LineWidth); try
      for J:=1 to h do {iterate lines}
      begin
        PLineBuffer:=PBaseLineBuffer;
        SourceRGB:=PRGB(ScanLine);
        SourceRGB[2]:=PRGB(ScanLine)^[0];  {rgb -> bgr  }
        SourceRGB[1]:=PRGB(ScanLine)^[1];  {rgb -> bgr  }
        SourceRGB[0]:=PRGB(ScanLine)^[2];  {rgb -> bgr  }
        for K:=0 to W-1 do begin  { mix color and alpha line-by-line }
          PRGB(PLineBuffer)^:=SourceRGB^; Inc(SourceRGB);
          PLineBuffer[3]:=AlphaScanLine[K]; {inject alpha after RGB}
          Inc(PLineBuffer, 4);
        end;
        F.WriteBuffer(PBaseLineBuffer^, LineWidth);
        Inc(ScanLine, PSD.ScanLine);
        Inc(AlphaScanLine, PSD.AlphaScanLine);
      end;
      finally
        FreeMem(PBaseLineBuffer);
      end;
    finally
      OldPSD.Done;
      PSD.Done;
    end;
  end;
 end;
end;
{


header hex : 04 00 00 00
then the pak path where the file is place .. eg pics/menus/
then 00 to offset 204 (hex not byte) then hi lo byte height of image
then 00 to offset 244 (hex) then hi lo byte width of image
i'am not sure whether it first height or width...
then 00 to offset (hex) 3C8
then you take width * height so you can get texsize
then do a cache i think char buffer[texsize]
read in 4 byte blocks
1byte is the red value (0..255)
2byte is the green value
3byte is the blue value

in some files (shapes) the 4 byte is a alpha value
}
function ReadPath(F: TStream): string;
var
  ch: char;
begin
  result:='';
  while true do begin
    F.Readbuffer(ch,1);
    if ch<>#0 then
      result:=result+ch
    else
      exit;
  end;
end;

Procedure ReadRGBA(F: TStream; var rgb, a: string; height, width: integer);
type
  PRGB = ^TRGB;
  TRGB = array[0..2] of Byte;
const
  spec1='Image1=';
  spec2='Alpha=';
var
  RawData, Image_Buffer, Alpha_Buffer: String;
  ScanLine, Dest, Source, AlphaBuf: PChar;
  I, J, ScanW, sScanW: Integer;
begin
  {read into rawdata string}
  I:=Width*(32 div 8);    { bytes per line in the .m32 file }
  ScanW:=(I+3) and not 3; { the same but rounded up, for storing the data }
  RawData:=Spec1;
  J:=ScanW*Height;       { total byte count for storage }
  SetLength(RawData, Length(Spec1)+J);
  ScanLine:=PChar(RawData)+Length(RawData)-ScanW;
  sScanW:=-ScanW;
  for J:=1 to Height do begin
    F.ReadBuffer(ScanLine^, I);
    if I<ScanW then
      FillChar(ScanLine[I], ScanW-I, 0);  { pad with zeroes }
    Inc(ScanLine, sScanW);
  end;

  {prepare alpha buffer
   It is assumed to be one byte per pixel if available.
   It was loaded together with the image data into 'RawData',
   but 'RawData' must now be split into two buffers : one for the image colors
   and one for the alpha channel.}
   alpha_buffer:=Spec2;
   J:=Width*Height;       { pixel count }
   Setlength(alpha_buffer,Length(Spec2)+ J);

   {prepare image buffer}
   Image_Buffer:=Spec1;
   SetLength(Image_Buffer, Length(Spec1)+ 3*J);

   {split ABGR into RGB and Alpha}
   Source:=PChar(RawData)+Length(Spec1);
   Dest:=PChar(Image_Buffer)+Length(Spec1);
   AlphaBuf:=PChar(alpha_buffer)+Length(Spec2);
   for I:=1 to J do
   begin
     PRGB(Dest)^[2]:=PRGB(Source)^[0];  {bgr -> rgb  }
     PRGB(Dest)^[1]:=PRGB(Source)^[1];  {bgr -> rgb  }
     PRGB(Dest)^[0]:=PRGB(Source)^[2];  {bgr -> rgb  }
     AlphaBuf^:=Source[3];      { alpha }
     Inc(Dest, 3);
     Inc(Source, 4);
     Inc(AlphaBuf);
   end;
   a:=Alpha_Buffer;
   rgb:=Image_Buffer;
end;

Procedure QM32.LoadFile(F: TStream; FSize: Integer);
var
  sig, org: Longint;
  tex: string;
  rgb, a: string;
  hi, wi: smallint;
  flags,content,value: longint;
  V: array[1..2] of Single;
begin
 case ReadFormat of
  1: begin  { as stand-alone file }
       org:=F.Position;
       F.readbuffer(sig, 4);
       if sig<>4 then
         raise Exception.Create('Not a valid m32 file!');
       tex:=ReadPath(F);
       SpecificsAdd(format('Texture_Path=%s',[tex]));
       F.Position:=org+$204;
       F.ReadBuffer(wi, 2);
       F.Position:=org+$244;
       F.ReadBuffer(hi, 2);
       F.Position:=org+$2c4;
       F.ReadBuffer(flags, 4);
       F.ReadBuffer(content, 4);
       F.ReadBuffer(value, 4);
       F.Position:=org+$3C8;
       V[1]:=wi;
       V[2]:=hi;
       SetFloatsSpec('Size', V);

       ReadRGBA(f, rgb, a, hi, wi);

       specifics.add(rgb);
       specifics.add(a);

       SpecificsAdd(format('Contents=%d',[content]));
       SpecificsAdd(format('Flags=%d',[flags]));
       SpecificsAdd(format('Value=%d',[value]));
     end;
 else inherited;
 end;
end;

class function QM32.Typeinfo: String;
begin
  Result:='.m32';
end;

class Procedure QM32.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.NomClasseEnClair:=LoadStr1(5177);
 Info.FileExt:=806;
 Info.WndInfo:=[wiWindow];
end;

initialization
  RegisterQObject(QM32, 'l');
end.

