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
unit QkDDS;

interface

uses Windows, Classes, QkImages, QkPixelSet, QkObjects, QkFileObjects,
     QkDevIL, QkFreeImage;

type
  QDDS = class(QImage)
        protected
          class function FileTypeDevIL : DevILType; override;
          class function FileTypeFreeImage : FREE_IMAGE_FORMAT; override;
          procedure SaveFileDevILSettings; override;
          function LoadFileFreeImageSettings : Integer; override;
          function SaveFileFreeImageSettings : Integer; override;
          class function FormatName : String; override;
          procedure SaveFile(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; FSize: TStreamPos); override;
        public
          class function TypeInfo: String; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

 {--------------------}

implementation

uses SysUtils, Setup, Quarkx, QkExceptions, QkObjectClassList, Game, Logging, ApplPaths;

class function QDDS.FormatName : String;
begin
 Result:='DDS';
end;

class function QDDS.TypeInfo: String;
begin
 TypeInfo:='.dds';
end;

class procedure QDDS.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5192);
  Info.FileExt:=819;
  Info.WndInfo:=[wiWindow];
end;

class function QDDS.FileTypeDevIL : DevILType;
begin
  Result:=IL_DDS;
end;

class function QDDS.FileTypeFreeImage : FREE_IMAGE_FORMAT;
begin
  Result:=FIF_DDS;
end;

procedure QDDS.SaveFileDevILSettings;
var
  Setup: QObject;
  Flag: ILint;
begin
  inherited;

  Setup:=SetupSubSet(ssFiles, 'DDS');
  try
    case StrToInt(Setup.Specifics.Values['SaveFormatDevIL']) of
    0: Flag:=IL_DXT1;
    1: Flag:=IL_DXT1A;
    2: Flag:=IL_DXT2;
    3: Flag:=IL_DXT3;
    4: Flag:=IL_DXT4;
    5: Flag:=IL_DXT5;
    6: Flag:=IL_ATI1N;
    7: Flag:=IL_3DC;
    8: Flag:=IL_RXGB;
    else
      Flag:=IL_DXT1;
    end;
  except
    Flag:=IL_DXT1;
  end;

  ilSetInteger(IL_DXTC_FORMAT, Flag);
  CheckDevILError(ilGetError);
end;

function QDDS.LoadFileFreeImageSettings : Integer;
begin
  Result:=DDS_DEFAULT;
end;

function QDDS.SaveFileFreeImageSettings : Integer;
begin
  Result:=DDS_DEFAULT;
end;

procedure QDDS.LoadFile(F: TStream; FSize: TStreamPos);
var
  LibraryToUse: string;
begin
  Log(LOG_VERBOSE, 'Loading DDS file: %s', [self.name]);
  case ReadFormat of
  rf_Default: begin  { as stand-alone file }
    LibraryToUse:=SetupSubSet(ssFiles, 'DDS').Specifics.Values['LoadLibrary'];
    if LibraryToUse='DevIL' then
      LoadFileDevIL(F, FSize)
    else if LibraryToUse='FreeImage' then
      LoadFileFreeImage(F, FSize)
    else
      LogAndRaiseError(FmtLoadStr1(5813, [FormatName]));
  end;
  else
    inherited;
  end;
end;

var
  DevILLoaded: Boolean;

procedure QDDS.SaveFile(Info: TInfoEnreg1);
const
  Spec1 = 'Image1=';
  Spec2 = 'Pal=';
  Spec3 = 'Alpha=';
type
  PRGB = ^TRGB;
  TRGB = array[0..2] of Byte;
  PRGBA = ^TRGBA;
  TRGBA = array[0..3] of Byte;
var
  LibraryToUse: string;

  PSD: TPixelSetDescription;
//  TexSize : longword;
  //RawBuffer: String;
  S: String;
  Dest: PByte;
  SourceImg, SourceAlpha, SourcePal, pSourceImg, pSourceAlpha, pSourcePal: PByte;
  RawPal: PByte;

  DevILImage: Cardinal;
  ImageBpp: Byte;
  ImageFormat: DevILFormat;
  Width, Height: Integer;
  PaddingSource, PaddingDest: Integer;
  I, J: Integer;
  TexFormat: Integer;
  TexFormatParameter: String;
  Quality: Integer;
  QualityParameter: String;
  DumpBuffer: TFileStream;
  NVDXTFileNamePNG, NVDXTFileNameDDS: String;
  NVDXTStartupInfo: StartUpInfo;
  NVDXTProcessInformation: Process_Information;
  NVDXTReturnCode: DWORD;
  TMPPath: array[0..MAX_PATH+1] of Char;
begin
 Log(LOG_VERBOSE, 'Saving DDS file: %s', [self.name]);
 with Info do
  case Format of
  rf_Default:
  begin  { as stand-alone file }
    LibraryToUse:=SetupSubSet(ssFiles, 'DDS').Specifics.Values['SaveLibrary'];
    if LibraryToUse='DevIL' then
      SaveFileDevIL(Info)
    //FreeImage has no DDS file saving support (yet?)
    //else if LibraryToUse='FreeImage' then
    //  SaveFileDevIL(Info)
    else if LibraryToUse='NVDXT' then
    begin
      if FileExists(ConcatPaths([GetQPath(pQuArKDll), 'nvdxt.exe']))=false then
        LogAndRaiseError(FmtLoadStr1(5739, [FormatName, 'NVDXT']));

      //DanielPharos: This is a workaround: we use DevIL to save a PNG, and then NVDXT to convert it to a DDS
      if (not DevILLoaded) then
      begin
        if not LoadDevIL then
          Raise EErrorFmt(5730, ['DevIL library', GetLastError]);
        DevILLoaded:=true;
      end;

      PSD:=Description;
      try
        Width:=PSD.size.x;
        Height:=PSD.size.y;

        if PSD.Format = psf8bpp then
        begin
          ImageBpp:=1;
          ImageFormat:=IL_COLOUR_INDEX;
          PaddingDest:=0;
        end
        else
        begin
          if PSD.AlphaBits=psa8bpp then
          begin
            ImageBpp:=4;
            ImageFormat:=IL_RGBA;
            PaddingDest:=0;
          end
          else
          begin
            ImageBpp:=3;
            ImageFormat:=IL_RGB;
            PaddingDest:=0;
          end;
        end;

        ilGenImages(1, @DevILImage);
        CheckDevILError(ilGetError);
        ilBindImage(DevILImage);
        CheckDevILError(ilGetError);

        if ilTexImage(Width, Height, 1, ImageBpp, ImageFormat, IL_UNSIGNED_BYTE, nil)=IL_FALSE then
        begin
          ilDeleteImages(1, @DevILImage);
          LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'ilTexImage']));
        end;
        CheckDevILError(ilGetError);

        if ilClearImage=IL_FALSE then
        begin
          ilDeleteImages(1, @DevILImage);
          LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'ilClearImage']));
        end;
        CheckDevILError(ilGetError);

        if PSD.Format = psf8bpp then
        begin
          ilConvertPal(IL_PAL_RGB24);
          CheckDevILError(ilGetError);
        end;

        if PSD.Format = psf8bpp then
        begin
          //This is the padding for the 'Image1'-RGB array
          PaddingSource:=((((Width * 8) + 31) div 32) * 4) - (Width * 1);
        end
        else
        begin
          //This is the padding for the 'Image1'-RGB array
          PaddingSource:=((((Width * 24) + 31) div 32) * 4) - (Width * 3);
        end;

        TexFormat:=2;
        if PSD.AlphaBits=psa8bpp then
          S:=SetupSubSet(ssFiles, 'DDS').Specifics.Values['SaveFormatANVDXT']
        else
          S:=SetupSubSet(ssFiles, 'DDS').Specifics.Values['SaveFormatNVDXT'];
        if S<>'' then
        begin
          TexFormat:=StrToIntDef(S, 2);
          if (TexFormat < 0) or (TexFormat > 12) then
            TexFormat := 2;
        end;

        if PSD.Format = psf8bpp then
        begin
          GetMem(RawPal, 256*3);
          try
            ilRegisterPal(RawPal, 256*3, IL_PAL_RGB24);
            CheckDevILError(ilGetError);
          finally
            FreeMem(RawPal);
          end;

          Dest:=PByte(ilGetPalette);
          CheckDevILError(ilGetError);
          SourcePal:=PByte(PSD.ColorPalette);
          pSourcePal:=SourcePal;
          for I:=0 to 255 do
          begin
            PRGB(Dest)^[0]:=PRGB(pSourcePal)^[0];
            PRGB(Dest)^[1]:=PRGB(pSourcePal)^[1];
            PRGB(Dest)^[2]:=PRGB(pSourcePal)^[2];
            Inc(pSourcePal, 3);
            Inc(Dest, 3);
          end;

          //FIXME: Change this code! Use QkPng (or whatever) instead!!! Look at AutoSave temps file code!
          Dest:=PByte(ilGetData);
          CheckDevILError(ilGetError);
          SourceImg:=PByte(PSD.Data);
          pSourceImg:=SourceImg;
          for J:=0 to Height-1 do
          begin
            for I:=0 to Width-1 do
            begin
              Dest^:=PByte(pSourceImg)^;
              Inc(pSourceImg, 1);
              Inc(Dest, 1);
            end;
            Inc(pSourceImg, PaddingSource);
            for I:=0 to PaddingDest-1 do
            begin
              Dest^:=0;
              Inc(Dest, 1);
            end;
          end;
        end
        else
        begin
          if PSD.AlphaBits=psa8bpp then
          begin
            Dest:=PByte(ilGetData);
            CheckDevILError(ilGetError);
            SourceImg:=PByte(PSD.Data);
            SourceAlpha:=PByte(PSD.AlphaData);
            pSourceImg:=SourceImg;
            pSourceAlpha:=SourceAlpha;
            for J:=0 to Height-1 do
            begin
              for I:=0 to Width-1 do
              begin
                PRGBA(Dest)^[2]:=PRGB(pSourceImg)^[0];
                PRGBA(Dest)^[1]:=PRGB(pSourceImg)^[1];
                PRGBA(Dest)^[0]:=PRGB(pSourceImg)^[2];
                PRGBA(Dest)^[3]:=PByte(pSourceAlpha)^;
                Inc(pSourceImg, 3);
                Inc(pSourceAlpha, 1);
                Inc(Dest, 4);
              end;
              Inc(pSourceImg, PaddingSource);
              for I:=0 to PaddingDest-1 do
              begin
                Dest^:=0;
                Inc(Dest, 1);
              end;
            end;
          end
          else
          begin
            Dest:=PByte(ilGetData);
            CheckDevILError(ilGetError);
            SourceImg:=PByte(PSD.Data);
            pSourceImg:=SourceImg;
            for J:=0 to Height-1 do
            begin
              for I:=0 to Width-1 do
              begin
                PRGB(Dest)^[2]:=PRGB(pSourceImg)^[0];
                PRGB(Dest)^[1]:=PRGB(pSourceImg)^[1];
                PRGB(Dest)^[0]:=PRGB(pSourceImg)^[2];
                //FIXME: What about alpha?
                Inc(pSourceImg, 3);
                Inc(Dest, 3);
              end;
              Inc(pSourceImg, PaddingSource);
              for I:=0 to PaddingDest-1 do
              begin
                Dest^:=0;
                Inc(Dest, 1);
              end;
            end;
          end;
        end;
      finally
        PSD.Done;
      end;

      S:=SetupSubSet(ssFiles, 'DDS').Specifics.Values['SaveQualityNVDXT'];
      if S<>'' then
      begin
        Quality:=StrToIntDef(S, 2);
        if (Quality < 0) or (Quality > 3) then
          Quality := 2;
      end
      else
        Quality:=2;

      //NVDXT uses the file extension to identify the format, so we can't use MakeTempFileName here.
      GetTempPath(High(TMPPath)-1, TMPPath);
      NVDXTFileNamePNG:=ConcatPaths([TMPPath, 'QuArK_NVDXT0.PNG']);
      while FileExists(NVDXTFileNamePNG) do
        NVDXTFileNamePNG:=ConcatPaths([TMPPath, 'QuArK_NVDXT'+IntToStr(Random(999999))+'.png']);
      if ilSave(IL_PNG, ToILstring(NVDXTFileNamePNG))=IL_FALSE then
      begin
        ilDeleteImages(1, @DevILImage);
        LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'ilSave']));
      end;

      ilDeleteImages(1, @DevILImage);
      CheckDevILError(ilGetError);

      try
        //DanielPharos: Now convert the PNG to DDS with NVIDIA's DDS tool...

        case TexFormat of
        0: TexFormatParameter:='dxt1c';
        1: TexFormatParameter:='dxt1a';
        2: TexFormatParameter:='dxt3';
        3: TexFormatParameter:='dxt5';
        4: TexFormatParameter:='u1555';
        5: TexFormatParameter:='u4444';
        6: TexFormatParameter:='u565';
        7: TexFormatParameter:='u8888';
        8: TexFormatParameter:='u888';
        9: TexFormatParameter:='u555';
        10: if ImageBpp = 1 then TexFormatParameter:='l8' else TexFormatParameter:='dxt3';
        11: if ImageBpp = 1 then TexFormatParameter:='a8' else TexFormatParameter:='dxt3';
        12: if ImageBpp = 2 then TexFormatParameter:='a8l8' else TexFormatParameter:='dxt3';
        end;

        case Quality of
        0: QualityParameter:='quick';
        1: QualityParameter:='quality_normal';
        2: QualityParameter:='quality_production';
        3: QualityParameter:='quality_highest';
        end;

        NVDXTFileNameDDS:=ConcatPaths([TMPPath, 'QuArK_NVDXT0.dds']);
        while FileExists(NVDXTFileNameDDS) do
          NVDXTFileNameDDS:=ConcatPaths([TMPPath, 'QuArK_NVDXT'+IntToStr(Random(999999))+'.dds']);

        FillChar(NVDXTStartupInfo, SizeOf(NVDXTStartupInfo), 0);
        FillChar(NVDXTProcessInformation, SizeOf(NVDXTProcessInformation), 0);
        NVDXTStartupInfo.cb:=SizeOf(NVDXTStartupInfo);
        NVDXTStartupInfo.dwFlags:=STARTF_USESHOWWINDOW;
        NVDXTStartupInfo.wShowWindow:=SW_HIDE+SW_MINIMIZE;
        try
          if CreateProcess(PChar(ConcatPaths([GetQPath(pQuArKDll), 'nvdxt.exe'])), PChar('nvdxt.exe -rescale nearest -file "'+NVDXTFileNamePNG+'" -output "'+NVDXTFileNameDDS+'" -'+TexFormatParameter+' -'+QualityParameter), nil, nil, false, 0, nil, PChar(GetQPath(pQuArKDll)), NVDXTStartupInfo, NVDXTProcessInformation)=false then
          begin
            LogWindowsError(GetLastError(), 'CreateProcess(nvdxt.exe)');
            LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'CreateProcess']));
          end;
          CloseHandle(NVDXTProcessInformation.hThread);

          //DanielPharos: This is kinda dangerous, but NVDXT should exit rather quickly!
          if WaitForSingleObject(NVDXTProcessInformation.hProcess, INFINITE)=WAIT_FAILED then
          begin
            LogWindowsError(GetLastError(), 'WaitForSingleObject(NVDXT)');
            LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'WaitForSingleObject']));
          end;
          if not GetExitCodeProcess(NVDXTProcessInformation.hProcess, NVDXTReturnCode) then
          begin
            LogWindowsError(GetLastError(), 'GetExitCodeProcess(NVDXT)');
            LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'GetExitCodeProcess']));
          end;
        finally
          CloseHandle(NVDXTProcessInformation.hProcess);
        end;
      finally
        if DeleteFile(NVDXTFileNamePNG)=false then
          LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'DeleteFile(png)']));
      end;

      if NVDXTReturnCode <> 0 then
        LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'NVDXT']));

      //DanielPharos: Now let's read in that DDS file and be done!
      DumpBuffer:=TFileStream.Create(NVDXTFileNameDDS,fmOpenRead);
      try
        F.CopyFrom(DumpBuffer,DumpBuffer.Size);
      finally
        DumpBuffer.Free;
      end;
      if DeleteFile(NVDXTFileNameDDS)=false then
        LogAndRaiseError(FmtLoadStr1(5721, [FormatName, 'DeleteFile(dds)']));

    end
    else
      LogAndRaiseError(FmtLoadStr1(5814, [FormatName]));
  end
  else
    inherited;
  end;
end;

 {--------------------}

initialization
  RegisterQObject(QDDS, 'k');

finalization
  if DevILLoaded then
    UnloadDevIL(False);
end.
