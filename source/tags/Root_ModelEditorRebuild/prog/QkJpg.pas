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

{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.18  2007/06/13 11:56:24  danielpharos
Added FreeImage as an alternative for DevIL. PNG and JPEG file handling now also uses these two libraries. Set-up a new section in the Configuration for all of this.

Revision 1.17  2005/09/28 10:48:32  peter-b
Revert removal of Log and Header keywords

Revision 1.15  2002/03/07 19:16:02  decker_dk
Removed QImages, as it was just another name for QImage

Revision 1.14  2001/03/20 21:45:50  decker_dk
Updated copyright-header

Revision 1.13  2001/01/21 15:49:03  decker_dk
Moved RegisterQObject() and those things, to a new unit; QkObjectClassList.

Revision 1.12  2001/01/15 19:20:19  decker_dk
Replaced the name: NomClasseEnClair -> FileObjectDescriptionText

Revision 1.11  2000/08/23 20:59:24  aiv
Added exception messages for debugging purposes

Revision 1.10  2000/07/18 19:37:59  decker_dk
Englishification - Big One This Time...

Revision 1.9  2000/07/16 16:34:50  decker_dk
Englishification

Revision 1.8  2000/07/09 13:20:43  decker_dk
Englishification and a little layout

Revision 1.7  2000/05/20 14:10:25  decker_dk
Some more englishification

Revision 1.6  2000/05/14 15:06:56  decker_dk
Charger(F,Taille) -> LoadFile(F,FSize)
ToutCharger -> LoadAll
ChargerInterne(F,Taille) -> LoadInternal(F,FSize)
ChargerObjTexte(Q,P,Taille) -> ConstructObjsFromText(Q,P,PSize)

Revision 1.5  2000/04/20 10:43:33  arigo
JPeg writing fixes
}

unit QkJpg;

interface

uses Classes, QkImages, QkPixelSet, QkObjects, QkFileObjects, QkDevIL, QkFreeImage;

type
 QJPeg = class(QImage)
        protected
          procedure SaveFile(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; FSize: Integer); override;
        public
          function BaseGame : Char;
          class function CustomParams : Integer;
          class function TypeInfo: String; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

{-------------------}

implementation

uses SysUtils, Setup, Quarkx, QkObjectClassList, QkTextures, Game, Logging, Windows;

var
  DevILLoaded: Boolean;
  FreeImageLoaded: Boolean;

procedure Fatal(x:string);
begin
  Log(LOG_CRITICAL,'Error during operation on JPG file: %s',[x]);
  Windows.MessageBox(0, pchar(X), PChar(LoadStr1(401)), MB_TASKMODAL or MB_ICONERROR or MB_OK);
  Raise Exception.Create(x);
end;

class function QJPeg.TypeInfo: String;
begin
 TypeInfo:='.jpg';
end;

class procedure QJPeg.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5172);
 Info.FileExt:=801;
 Info.WndInfo:=[wiWindow];
end;

class function QJpeg.CustomParams : Integer;
begin
 Result:=cpAnyHeight;
end;

function QJpeg.BaseGame : Char;
begin
 Result:=mjQ3A;
end;

procedure QJpeg.LoadFile(F: TStream; FSize: Integer);
const
  Spec1 = 'Image1=';
//  Spec2 = 'Pal=';
  Spec3 = 'Alpha=';
type
  PRGB = ^TRGB;
  TRGB = array[0..2] of Byte;
var
  RawBuffer: String;
  Source, Source2: PByte;
  AlphaData, ImgData: String;
  DestAlpha, DestImg: PChar;
  I, J: Integer;
  LibraryToUse: string;
  Setup: QObject;

  //DevIL:
  DevILImage: Cardinal;

  //FreeImage:
  FIBuffer: FIMEMORY;
  FIImage, FIConvertedImage: FIBITMAP;
  Pitch: Cardinal;
  FIFlags: Integer;

  ImageFormat: DevILFormat;
  Width, Height: Cardinal;
  NumberOfPixels: Integer;
  V: array[1..2] of Single;
begin
  Log(LOG_VERBOSE,'Loading JPG file: %s',[self.name]);;
  case ReadFormat of
  1: begin  { as stand-alone file }
    Setup:=SetupSubSet(ssFiles, 'JPG');
    LibraryToUse:=Setup.Specifics.Values['LoadLibrary'];
    if LibraryToUse='DevIL' then
    begin
      if (not DevILLoaded) then
      begin
        if not LoadDevIL then
          Raise EErrorFmt(5730, ['DevIL library', GetLastError]);
        DevILLoaded:=true;
      end;

      SetLength(RawBuffer, F.Size);
      F.Seek(0, 0);
      F.ReadBuffer(Pointer(RawBuffer)^, Length(RawBuffer));

      ilGenImages(1, @DevILImage);
      CheckDevILError(ilGetError);
      ilBindImage(DevILImage);
      CheckDevILError(ilGetError);

      if ilLoadL(IL_JPG, Pointer(RawBuffer), Length(RawBuffer))=false then
      begin
        ilDeleteImages(1, @DevILImage);
        Fatal('Unable to load JPG file. Call to ilLoadL failed. Please make sure the file is a valid JPG file, and not damaged or corrupt.');
      end;

      Width:=ilGetInteger(IL_IMAGE_WIDTH);
      CheckDevILError(ilGetError);
      Height:=ilGetInteger(IL_IMAGE_HEIGHT);
      CheckDevILError(ilGetError);
      //DanielPharos: 46340 squared is just below the integer max value.
      if (Width>46340) or (Height>46340) then
      begin
        ilDeleteImages(1, @DevILImage);
        Fatal('Unable to load JPG file. Picture is too large.');
      end;
      NumberOfPixels:=Width * Height;
      V[1]:=Width;
      V[2]:=Height;
      SetFloatsSpec('Size', V);

      ImageFormat:=ilGetInteger(IL_IMAGE_FORMAT);
      CheckDevILError(ilGetError);
      if (ImageFormat=IL_RGBA) or (ImageFormat=IL_BGRA) or (ImageFormat=IL_LUMINANCE_ALPHA) then
      begin
        //Allocate quarks image buffers
        ImgData:=Spec1;
        AlphaData:=Spec3;
        SetLength(ImgData , Length(Spec1) + NumberOfPixels * 3); {RGB buffer}
        Setlength(AlphaData,Length(Spec3) + NumberOfPixels);     {alpha buffer}

        GetMem(Source,NumberOfPixels*4);
        ilCopyPixels(0, 0, 0, Width, Height, 1, IL_RGBA, IL_UNSIGNED_BYTE, Source);
        CheckDevILError(ilGetError);

        DestImg:=PChar(ImgData) + Length(Spec1);
        DestAlpha:=PChar(AlphaData) + Length(Spec3);
        Source2:=Source;
        Inc(Source2, NumberOfPixels*4);
        Inc(Source2, Width*4);
        for J:=Height-1 downto 0 do
        begin
          Dec(Source2, 2*Width*4);
          for I:=0 to Width-1 do
          begin
            PRGB(DestImg)^[2]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[1]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[0]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestAlpha)^[0]:=Source2^;
            Inc(Source2, 1);
            Inc(DestImg, 3);
            Inc(DestAlpha, 1);
          end;
        end;

        Specifics.Add(AlphaData);
        Specifics.Add(ImgData);
      end
      else
      begin
        //Allocate quarks image buffers
        ImgData:=Spec1;
        SetLength(ImgData , Length(Spec1) + NumberOfPixels * 3); {RGB buffer}

        GetMem(Source,NumberOfPixels*3);
        ilCopyPixels(0, 0, 0, Width, Height, 1, IL_RGB, IL_UNSIGNED_BYTE, Source);
        CheckDevILError(ilGetError);

        DestImg:=PChar(ImgData) + Length(Spec1);
        Source2:=Source;
        Inc(Source2, NumberOfPixels*3);
        Inc(Source2, Width*3);
        for J:=Height-1 downto 0 do
        begin
          Dec(Source2, 2*Width*3);
          for I:=0 to Width-1 do
          begin
            PRGB(DestImg)^[2]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[1]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[0]:=Source2^;
            Inc(Source2, 1);
            Inc(DestImg, 3);
          end;
        end;

        Specifics.Add(ImgData);
      end;

      FreeMem(Source);

      ilDeleteImages(1, @DevILImage);
      CheckDevILError(ilGetError);

    end
    else if LibraryToUse='FreeImage' then
    begin
      if (not FreeImageLoaded) then
      begin
        if not LoadFreeImage then
          Raise EErrorFmt(5730, ['FreeImage library', GetLastError]);
        FreeImageLoaded:=true;
      end;

      SetLength(RawBuffer, F.Size);
      F.Seek(0, 0);
      F.ReadBuffer(Pointer(RawBuffer)^, Length(RawBuffer));

      try
        case StrToInt(Setup.Specifics.Values['LoadQualityFreeImage']) of
        0: FIFlags:=JPEG_DEFAULT;
        1: FIFlags:=JPEG_FAST;
        2: FIFlags:=JPEG_ACCURATE;
        else
          FIFlags:=JPEG_ACCURATE;
        end;
      except
        FIFlags:=JPEG_ACCURATE;
      end;

      FIBuffer := FreeImage_OpenMemory(Pointer(RawBuffer), Length(RawBuffer));
      FIImage := FreeImage_LoadFromMemory(FIF_JPEG, FIBuffer, FIFlags);

      Width:=FreeImage_GetWidth(FIImage);
      Height:=FreeImage_GetHeight(FIImage);
      //DanielPharos: 46340 squared is just below the integer max value.
      if (Width>46340) or (Height>46340) then
      begin
        FreeImage_Unload(FIImage);
        FreeImage_CloseMemory(FIBuffer);
        Fatal('Unable to load JPG file. Picture is too large.');
      end;
      NumberOfPixels:=Width * Height;
      V[1]:=Width;
      V[2]:=Height;
      SetFloatsSpec('Size', V);

      if FreeImage_IsTransparent(FIImage) then
      begin
        //Allocate quarks image buffers
        ImgData:=Spec1;
        AlphaData:=Spec3;
        SetLength(ImgData , Length(Spec1) + NumberOfPixels * 3); {RGB buffer}
        Setlength(AlphaData,Length(Spec3) + NumberOfPixels);     {alpha buffer}

        FIConvertedImage:=FreeImage_ConvertTo32Bits(FIImage);
        Pitch:=FreeImage_GetPitch(FIConvertedImage);
        GetMem(Source,Height * Pitch);
        FreeImage_ConvertToRawBits(Source, FIConvertedImage, Pitch, 32, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, true);

        DestImg:=PChar(ImgData) + Length(Spec1);
        DestAlpha:=PChar(AlphaData) + Length(Spec3);
        Source2:=Source;
        for J:=Height-1 downto 0 do
        begin
          for I:=0 to Width-1 do
          begin
            PRGB(DestImg)^[0]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[1]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[2]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestAlpha)^[0]:=Source2^;
            Inc(Source2, 1);
            Inc(DestImg, 3);
            Inc(DestAlpha, 1);
          end;
        end;

        Specifics.Add(AlphaData);
        Specifics.Add(ImgData);
      end
      else
      begin
        //Allocate quarks image buffers
        ImgData:=Spec1;
        SetLength(ImgData , Length(Spec1) + NumberOfPixels * 3); {RGB buffer}

        FIConvertedImage:=FreeImage_ConvertTo24Bits(FIImage);
        Pitch:=FreeImage_GetPitch(FIConvertedImage);
        GetMem(Source,Height * Pitch);
        FreeImage_ConvertToRawBits(Source, FIConvertedImage, Pitch, 24, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, true);

        DestImg:=PChar(ImgData) + Length(Spec1);
        Source2:=Source;
        for J:=Height-1 downto 0 do
        begin
          for I:=0 to Width-1 do
          begin
            PRGB(DestImg)^[0]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[1]:=Source2^;
            Inc(Source2, 1);
            PRGB(DestImg)^[2]:=Source2^;
            Inc(Source2, 1);
            Inc(DestImg, 3);
          end;
        end;

        Specifics.Add(ImgData);
      end;

      FreeMem(Source);
      FreeImage_Unload(FIConvertedImage);
      FreeImage_Unload(FIImage);
      FreeImage_CloseMemory(FIBuffer);
    end
    else
    begin
      Fatal('Unable to load JPG file. No valid loading library selected.');
    end;
  end;
  else
    inherited;
  end;
end;

procedure QJpeg.SaveFile(Info: TInfoEnreg1);
var
  PSD: TPixelSetDescription;
  RawBuffer: String;
  RawData, RawData2: PByte;
  SourceImg, SourceAlpha, pSourceImg, pSourceAlpha: PChar;
  LibraryToUse: string;
  Setup: QObject;

  //DevIL:
  DevILImage: Cardinal;
  ImageBpp: Byte;
  ImageFormat: DevILFormat;

  //FreeImage:
  FIBuffer: FIMEMORY;
  FIImage: FIBITMAP;
  Pitch: Cardinal;
  FIbpp: Cardinal;
  FIFlags: Integer;

  Width, Height: Integer;
  I, J: Integer;
  OutputSize: Cardinal;
begin
 Log(LOG_VERBOSE,'Saving JPG file: %s',[self.name]);
 with Info do
  case Format of
  1:  begin  { as stand-alone file }
    Setup:=SetupSubSet(ssFiles, 'JPG');
    LibraryToUse:=Setup.Specifics.Values['SaveLibrary'];
    if LibraryToUse='DevIL' then
    begin
      if (not DevILLoaded) then
      begin
        if not LoadDevIL then
          Raise EErrorFmt(5730, ['DevIL library', GetLastError]);
        DevILLoaded:=true;
      end;

      PSD:=Description;
      Width:=PSD.size.x;
      Height:=PSD.size.y;
      if PSD.AlphaBits=psa8bpp then
      begin
        ImageBpp:=4;
        ImageFormat:=IL_BGRA;
        GetMem(RawData, Width*Height*4);
        RawData2:=RawData;

        SourceImg:=PChar(PSD.Data);
        SourceAlpha:=PChar(PSD.AlphaData);
        pSourceImg:=SourceImg;
        pSourceAlpha:=SourceAlpha;
        for J:=0 to Height-1 do
        begin
          for I:=0 to Width-1 do
          begin
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceAlpha^;
            Inc(pSourceAlpha);
            Inc(RawData2);
          end;
        end;
      end
      else
      begin
        ImageBpp:=3;
        ImageFormat:=IL_BGR;
        GetMem(RawData, Width*Height*3);
        RawData2:=RawData;

        SourceImg:=PChar(PSD.Data);
        pSourceImg:=SourceImg;
        for J:=0 to Height-1 do
        begin
          for I:=0 to Width-1 do
          begin
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
          end;
        end;
      end;

      ilGenImages(1, @DevILImage);
      CheckDevILError(ilGetError);
      ilBindImage(DevILImage);
      CheckDevILError(ilGetError);

      if ilTexImage(Width, Height, 1, ImageBpp, ImageFormat, IL_UNSIGNED_BYTE, RawData)=false then
      begin
        ilDeleteImages(1, @DevILImage);
        Fatal('Unable to save JPG file. Call to ilTexImage failed.');
      end;

      FreeMem(RawData);

      //DanielPharos: How do we retrieve the correct value of the lump?
      OutputSize:=Width*Height*10;
      SetLength(RawBuffer,OutputSize);

      OutputSize:=ilSaveL(IL_JPG, Pointer(RawBuffer), OutputSize);
      CheckDevILError(ilGetError);
      if OutputSize=0 then
      begin
        ilDeleteImages(1, @DevILImage);
        Fatal('Unable to save JPG file. Call to ilSaveL failed.');
      end;

      F.WriteBuffer(Pointer(RawBuffer)^,OutputSize);

      ilDeleteImages(1, @DevILImage);
      CheckDevILError(ilGetError);
    end
    else if LibraryToUse='FreeImage' then
    begin
      if (not FreeImageLoaded) then
      begin
        if not LoadFreeImage then
          Raise EErrorFmt(5730, ['FreeImage library', GetLastError]);
        FreeImageLoaded:=true;
      end;

      PSD:=Description;
      Width:=PSD.size.x;
      Height:=PSD.size.y;
      if PSD.AlphaBits=psa8bpp then
      begin
        FIBpp:=32;
        GetMem(RawData, Width*Height*4);
        RawData2:=RawData;

        SourceImg:=PChar(PSD.Data);
        SourceAlpha:=PChar(PSD.AlphaData);
        pSourceImg:=SourceImg;
        pSourceAlpha:=SourceAlpha;
        for J:=0 to Height-1 do
        begin
          for I:=0 to Width-1 do
          begin
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceAlpha^;
            Inc(pSourceAlpha);
            Inc(RawData2);
          end;
        end;
      end
      else
      begin
        FIBpp:=24;
        GetMem(RawData, Width*Height*3);
        RawData2:=RawData;

        SourceImg:=PChar(PSD.Data);
        pSourceImg:=SourceImg;
        for J:=0 to Height-1 do
        begin
          for I:=0 to Width-1 do
          begin
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
            PChar(RawData2)^:=pSourceImg^;
            Inc(pSourceImg);
            Inc(RawData2);
          end;
        end;
      end;

      Pitch:=Cardinal(Width)*(FIBpp div 8);
      FIImage:=FreeImage_ConvertFromRawBits(RawData, width, height, pitch, FIBpp, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, true);

      FreeMem(RawData);

      try
        case StrToInt(Setup.Specifics.Values['SaveQualityFreeImage']) of
        0: FIFlags:=JPEG_DEFAULT;
        1: FIFlags:=JPEG_QUALITYBAD;
        2: FIFlags:=JPEG_QUALITYAVERAGE;
        3: FIFlags:=JPEG_QUALITYNORMAL;
        4: FIFlags:=JPEG_QUALITYGOOD;
        5: FIFlags:=JPEG_QUALITYSUPERB;
        else
          FIFlags:=JPEG_QUALITYGOOD;
        end;
      except
        FIFlags:=JPEG_QUALITYGOOD;
      end;

      try
        if Setup.Specifics.Values['SaveProgressiveFreeImage']<>'' then
          FIFlags:=FIFlags or JPEG_PROGRESSIVE;
      except
        ;
      end;

      FIBuffer := FreeImage_OpenMemory(nil, 0);
      if FreeImage_SaveToMemory(FIF_JPEG, FIImage, FIBuffer, FIFlags)=false then
      begin
        FreeImage_CloseMemory(FIBuffer);
        Fatal('Unable to save JPG file. Call to FreeImage_SaveToMemory failed.');
      end;

      OutputSize:=FreeImage_TellMemory(FIBuffer);
      SetLength(RawBuffer,OutputSize);
      if FreeImage_SeekMemory(FIBuffer, 0, SEEK_SET)=false then
      begin
        FreeImage_CloseMemory(FIBuffer);
        Fatal('Unable to save JPG file. Call to FreeImage_SeekMemory failed.');
      end;
      OutputSize:=FreeImage_ReadMemory(Pointer(RawBuffer), 1, OutputSize, FIBuffer);
      if OutputSize=0 then
      begin
        FreeImage_CloseMemory(FIBuffer);
        Fatal('Unable to save JPG file. Call to FreeImage_ReadMemory failed.');
      end;

      F.WriteBuffer(Pointer(RawBuffer)^,OutputSize);

      FreeImage_Unload(FIImage);
      FreeImage_CloseMemory(FIBuffer);
    end
    else
      Fatal('Unable to save JPG file. No valid saving library selected.');
  end
  else
    inherited;
  end;
end;

{-------------------}

initialization
  RegisterQObject(QJPeg, 'l');

finalization
  if DevILLoaded then
    UnloadDevIl(false);
  if FreeImageLoaded then
    UnloadFreeImage(false);
end.
