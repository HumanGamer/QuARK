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

unit QkTga;

interface

uses SysUtils, Classes, QkObjects, QkFileObjects, QkImages;

type
 QTga = class(QImages)
        protected
          procedure Enregistrer(Info: TInfoEnreg1); override;
          procedure Charger(F: TStream; Taille: Integer); override;
        public
          class function TypeInfo: String; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

 {------------------------}

implementation

uses Windows, Quarkx, Game, QkPixelSet;

const
 tgaAlphaBits = $1F;
 tgaTopDown = $20;
{tgaRightLeft = $10;}   { this flag not supported }

type
 TTgaHeader = packed record
               ExtraData: Byte;
               ColorMapType, TypeCode: Byte;
               ColorMapOrg, ColorMapLen: Word;
               ColorMapBpp: Byte;
               XOrigin, YOrigin: Word;
               Width, Height: Word;
               bpp: Byte;
               Flags: Byte;
              end;

 {------------------------}

class function QTga.TypeInfo: String;
begin
 TypeInfo:='.tga';
end;

class procedure QTga.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.NomClasseEnClair:=LoadStr1(5168);
 Info.FileExt:=796;
 Info.WndInfo:=[wiWindow];
end;

procedure QTga.Charger(F: TStream; Taille: Integer);
const
 Spec1 = 'Image1=';
 Spec2 = 'Pal=';
 AlphaSpec = 'Alpha=';
type
 PRGB = ^TRGB;
 TRGB = array[0..2] of Byte;
var
 Header: TTgaHeader;
 Data, Buffer: String;
 ScanLine, Dest, ScanEnd, Source, SourceEnd, AlphaBuf: PChar;
 I, J, ScanW, sScanW, Delta1, K, Count, BytesPerPixel: Integer;
 PaletteLmp: PPaletteLmp;
 TaillePalette: Integer;
 alpha_buffer: String;   {/mac}
begin
 case ReadFormat of
  1: begin  { as stand-alone file }
      if Taille<SizeOf(Header) then
       Raise EError(5519);
      F.ReadBuffer(Header, SizeOf(Header));
      TaillePalette:=0;
      F.Seek(Header.ExtraData, 1);

      { check the file format }
      if not (Header.TypeCode in [2,10])   {true color}
      {or (Header.ColorMapType<>0)          {color map avail}
      or ((Header.bpp<>24) and (Header.bpp<>32)) then   {24- or 32-bpp}
       begin
        if not (Header.TypeCode in [1,9])  {palettized}
        or (Header.ColorMapType<>1)        {color map}
        or (Header.bpp<>8)                 {8-bpp}
        or (Header.ColorMapOrg+Header.ColorMapLen>256)  {no more than 256 colors}
        or (Header.ColorMapBpp<>24) then   {24-bits palette entries}
         Raise EErrorFmt(5679, [LoadName, Header.ColorMapType, Header.TypeCode, Header.bpp]);
        TaillePalette:=3*Header.ColorMapLen;
        if Taille<SizeOf(Header)+Header.ExtraData+TaillePalette then
         Raise EError(5678);

        { load the palette }
        Data:=Spec2;
        SetLength(Data, Length(Spec2)+SizeOf(TPaletteLmp));
        PChar(PaletteLmp):=PChar(Data)+Length(Spec2);
        FillChar(PaletteLmp^, SizeOf(TPaletteLmp), 0);
        if TaillePalette>0 then
         begin
          F.ReadBuffer(PaletteLmp^[Header.ColorMapOrg], TaillePalette);
          for J:=Header.ColorMapOrg to Header.ColorMapOrg+Header.ColorMapLen-1 do
           begin
            K:=PaletteLmp^[J][0];
            PaletteLmp^[J][0]:=PaletteLmp^[J][2];
            PaletteLmp^[J][2]:=K;
           end;
         end;
        SpecificsAdd(Data);
       end;

      { load the image data }
      SetSize(Point(Header.Width, Header.Height));
      I:=Header.Width*(Header.bpp div 8);  { bytes per line in the .tga file }
      ScanW:=(I+3) and not 3;       { the same but rounded up, for storing the data }
      Data:=Spec1;
      J:=ScanW*Header.Height;       { total byte count for storage }
      SetLength(Data, Length(Spec1)+J);
      if Header.Flags and tgaTopDown <> 0 then
       begin
        ScanLine:=PChar(Data)+Length(Data)-ScanW;
        sScanW:=-ScanW;
       end
      else
       begin
        ScanLine:=PChar(Data)+Length(Spec1);
        sScanW:=ScanW;
       end;
      case Header.TypeCode of
       1,2: begin
           if Taille<SizeOf(Header)+Header.ExtraData+TaillePalette+I*Header.Height then
            Raise EError(5678);
           for J:=1 to Header.Height do
            begin
             F.ReadBuffer(ScanLine^, I);
             if I<ScanW then
              FillChar(ScanLine[I], ScanW-I, 0);  { pad with zeroes }
             Inc(ScanLine, sScanW);
            end;
          end;
       9,10: begin
            SetLength(Buffer, Taille-SizeOf(Header)-Header.ExtraData);
            F.ReadBuffer(Pointer(Buffer)^, Length(Buffer));
            J:=Header.Height;
            Dest:=ScanLine;
            ScanEnd:=Dest+I;
            Source:=PChar(Buffer);
            BytesPerPixel:=Header.bpp div 8;
            SourceEnd:=Source+Length(Buffer) - BytesPerPixel;
            repeat
             if Source^ >= #$80 then
              Delta1:=0
             else
              Delta1:=BytesPerPixel;
             Count:=Ord(Source^) and $7F;
             Inc(Source);
             if Source+Delta1*Count > SourceEnd then Raise EError(5678);
             for K:=0 to Count do
              begin
               case BytesPerPixel of
                1: begin
                    Dest^:=Source^;
                    Inc(Dest);
                   end;
                3: begin
                    PRGB(Dest)^:=PRGB(Source)^;
                    Inc(Dest, 3);
                   end;
                4: begin
                    PLongInt(Dest)^:=PLongInt(Source)^;
                    Inc(Dest, 4);
                   end;
               end;
               Inc(Source, Delta1);
               if Dest=ScanEnd then
                begin
                 if I<ScanW then
                  FillChar(ScanEnd, ScanW-I, 0);  { pad with zeroes }
                 Dec(J);
                 if J=0 then Break;
                 Inc(ScanLine, sScanW);
                 Dest:=ScanLine;
                 ScanEnd:=Dest+I;
                end;
              end;
             if Delta1=0 then
              Inc(Source, BytesPerPixel);
            until J=0;
           end;
      end;
      if Header.bpp=32 then   { alpha ? }
       begin
        {alpha channel is assumed to be one byte per pixel if available.
         It was loaded together with the image data into 'Data',
         but 'Data' must now be split into two buffers : one for the image colors
         and one for the alpha channel.}
        alpha_buffer:=AlphaSpec;
        J:=Header.Width*Header.Height;       { pixel count }
        Setlength(alpha_buffer,Length(AlphaSpec)+ J); { new alpha buffer }
        Buffer:=Data;
        Data:=Spec1;
        SetLength(Data, Length(Spec1)+ 4*J); { new, fixed data buffer }

        Source:=PChar(Buffer)+Length(Spec1);
        Dest:=PChar(Data)+Length(Spec1);
        AlphaBuf:=PChar(alpha_buffer)+Length(AlphaSpec);
        for I:=1 to J do
         begin
          PRGB(Dest)^:=PRGB(Source)^;  { rgb }
          AlphaBuf^:=Source[3];      { alpha }
          Inc(Dest, 3);
          Inc(Source, 4);
          Inc(AlphaBuf);
         end;
        Specifics.Add(alpha_buffer);  { "Alpha=xxxxx" }
       end;
      Specifics.Add(Data);  { "Image1=xxxxx" }
     end;
 else inherited;
 end;
end;

(*procedure QTga.Enregistrer(Info: TInfoEnreg1);
var
 Header: TTgaHeader;
 Data: String;
 ScanW, J, I: Integer;
 ScanLine: PChar;
 Tga: QImages;
begin
 with Info do case Format of
  1: begin  { as stand-alone file }
 .    if not IsTrueColor then
  .      Tga:=ConvertToTrueColor
  .     else
   .      Tga:=Self;
 .     Tga.AddRef(+1); try

      FillChar(Header, SizeOf(Header), 0);
      Header.TypeCode:=2;
      with Tga.GetSize do
       begin
        Header.Width:=X;
        Header.Height:=Y;
       end;
      Header.bpp:=24;
      F.WriteBuffer(Header, SizeOf(Header));

       { writes the image data }
      Data:=Tga.GetSpecArg('Image1');
      I:=Header.Width*3;
      ScanW:=(I+3) and not 3;
      if Length(Data)-Length('Image1=') <> ScanW*Header.Height then
       Raise EErrorFmt(5534, ['Image1']);
      ScanLine:=PChar(Data)+Length('Image1=');
      for J:=1 to Header.Height do
       begin
        F.WriteBuffer(ScanLine^, I);
        Inc(ScanLine, ScanW);   { TGA format is bottom-up by default }
       end;

      finally Tga.AddRef(-1); end;
     end;
 else inherited;
 end;
end;*)

procedure QTga.Enregistrer(Info: TInfoEnreg1);
type
 PRGB = ^TRGB;
 TRGB = array[0..2] of Byte;
var
 Header: TTgaHeader;
 LineWidth, J, K: Integer;
 ScanLine, AlphaScanLine: PChar;
 PSD: TPixelSetDescription;
 LineBuffer: PChar;
 SourceRGB: PRGB;
begin
 with Info do case Format of
  1: begin  { as stand-alone file }
      PSD:=Description; try

      FillChar(Header, SizeOf(Header), 0);
      if PSD.Format=psf8bpp then
       begin
        Header.TypeCode:=1;
        Header.bpp:=8;
       end
      else
       begin
        Header.TypeCode:=2;
        if PSD.AlphaBits=psa8bpp then
         begin
          Header.bpp:=32;
          Header.Flags:=8;  { tgaAlphaBits }
         end
        else
         Header.bpp:=24;
       end;
      with PSD.Size do
       begin
        Header.Width:=X;
        Header.Height:=Y;
       end;
      F.WriteBuffer(Header, SizeOf(Header));

       { writes the image data }
      LineWidth:=Header.Width * (Header.bpp div 8);  { bytes per line }
      ScanLine:=PSD.StartPointer;
      if Header.bpp=32 then  { alpha ? }
       begin
        AlphaScanLine:=PSD.AlphaStartPointer;
        GetMem(LineBuffer, LineWidth); try
        for J:=1 to Header.Height do
         begin
          SourceRGB:=PRGB(ScanLine);
          for K:=0 to Header.Width-1 do   { mix color and alpha line-by-line }
           begin
            PRGB(LineBuffer)^:=SourceRGB^; Inc(SourceRGB);
            LineBuffer[3]:=AlphaScanLine[K];
            Inc(LineBuffer, 4);
           end;
          F.WriteBuffer(LineBuffer^, LineWidth);
          Inc(ScanLine, PSD.ScanLine);   { TGA format is bottom-up, and so is PSD }
          Inc(AlphaScanLine, PSD.AlphaScanLine);
         end;
        finally FreeMem(LineBuffer); end;
       end
      else  { no alpha data }
       for J:=1 to Header.Height do
        begin
         F.WriteBuffer(ScanLine^, LineWidth);
         Inc(ScanLine, PSD.ScanLine);   { TGA format is bottom-up, and so is PSD }
        end;

      finally PSD.Done; end;
     end;
 else inherited;
 end;
end;

 {------------------------}

initialization
  RegisterQObject(QTga, 'l');
end.
