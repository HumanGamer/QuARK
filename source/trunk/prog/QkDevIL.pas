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
unit QkDevIL;

interface

uses Windows, SysUtils, ExtraFunctionality;

const
  IL_FALSE =0;
  IL_TRUE  =1;

// Palette types
  IL_PAL_NONE   =$0400;
  IL_PAL_RGB24  =$0401;
  IL_PAL_RGB32  =$0402;
  IL_PAL_RGBA32 =$0403;
  IL_PAL_BGR24  =$0404;
  IL_PAL_BGR32  =$0405;
  IL_PAL_BGRA32 =$0406;

// Image types
  IL_TYPE_UNKNOWN =$0000;
  IL_BMP          =$0420;
  IL_CUT          =$0421;
  IL_DOOM         =$0422;
  IL_DOOM_FLAT    =$0423;
  IL_ICO          =$0424;
  IL_JPG          =$0425;
  IL_JFIF         =$0425;
  IL_LBM          =$0426;
  IL_PCD          =$0427;
  IL_PCX          =$0428;
  IL_PIC          =$0429;
  IL_PNG          =$042A;
  IL_PNM          =$042B;
  IL_SGI          =$042C;
  IL_TGA          =$042D;
  IL_TIF          =$042E;
  IL_CHEAD        =$042F;
  IL_RAW          =$0430;
  IL_MDL          =$0431;
  IL_WAL          =$0432;
  IL_LIF          =$0434;
  IL_MNG          =$0435;
  IL_JNG          =$0435;
  IL_GIF          =$0436;
  IL_DDS          =$0437;
  IL_DCX          =$0438;
  IL_PSD          =$0439;
  IL_EXIF         =$043A;
  IL_PSP          =$043B;
  IL_PIX          =$043C;
  IL_PXR          =$043D;
  IL_XPM          =$043E;
  IL_HDR          =$043F;
  IL_ICNS         =$0440;
  IL_JP2          =$0441;
  IL_EXR          =$0442;
  IL_WDP          =$0443;
  IL_VTF          =$0444;
  IL_WBMP         =$0445;
  IL_SUN          =$0446;
  IL_IFF          =$0447;
  IL_TPL          =$0448;
  IL_FITS         =$0449;
  IL_DICOM        =$044A;
  IL_IWI          =$044B;
  IL_BLP          =$044C;
  IL_FTX          =$044D;
  IL_ROT          =$044E;
  IL_TEXTURE      =$044F;
  IL_DPX          =$0450;
  IL_UTX          =$0451;
  IL_MP3          =$0452;

  IL_JASC_PAL     =$0475;

// Mode types
  IL_ORIGIN_SET            =$0600;
  IL_ORIGIN_LOWER_LEFT     =$0601;
  IL_ORIGIN_UPPER_LEFT     =$0602;
  IL_ORIGIN_MODE           =$0603;
  IL_FORMAT_SET            =$0610;
  IL_FORMAT_MODE           =$0611;
  IL_TYPE_SET              =$0612;
  IL_TYPE_MODE             =$0613;
  IL_FILE_OVERWRITE        =$0620;
  IL_FILE_MODE             =$0621;
  IL_CONV_PAL              =$0630;
  IL_USE_KEY_COLOUR        =$0635;
  IL_USE_KEY_COLOR         =$0635;
  IL_VERSION_NUM           =$0DE2;
  IL_IMAGE_WIDTH           =$0DE4;
  IL_IMAGE_HEIGHT          =$0DE5;
  IL_IMAGE_DEPTH           =$0DE6;
  IL_IMAGE_SIZE_OF_DATA    =$0DE7;
  IL_IMAGE_BPP             =$0DE8;
  IL_IMAGE_BYTES_PER_PIXEL =$0DE8;
  IL_IMAGE_BITS_PER_PIXEL  =$0DE9;
  IL_IMAGE_FORMAT          =$0DEA;
  IL_IMAGE_TYPE            =$0DEB;
  IL_PALETTE_TYPE          =$0DEC;
  IL_PALETTE_SIZE          =$0DED;
  IL_PALETTE_BPP           =$0DEE;
  IL_PALETTE_NUM_COLS      =$0DEF;
  IL_PALETTE_BASE_TYPE     =$0DF0;
  IL_NUM_FACES             =$0DE1;
  IL_NUM_IMAGES            =$0DF1;
  IL_NUM_MIPMAPS           =$0DF2;
  IL_NUM_LAYERS            =$0DF3;
  IL_ACTIVE_IMAGE          =$0DF4;
  IL_ACTIVE_MIPMAP         =$0DF5;
  IL_ACTIVE_LAYER          =$0DF6;
  IL_ACTIVE_FACE           =$0E00;
  IL_CUR_IMAGE             =$0DF7;
  IL_IMAGE_DURATION        =$0DF8;
  IL_IMAGE_PLANESIZE       =$0DF9;
  IL_IMAGE_BPC             =$0DFA;
  IL_IMAGE_OFFX            =$0DFB;
  IL_IMAGE_OFFY            =$0DFC;
  IL_IMAGE_CUBEFLAGS       =$0DFD;
  IL_IMAGE_ORIGIN          =$0DFE;
  IL_IMAGE_CHANNELS        =$0DFF;

// Hints
  IL_FASTEST          =$0660;
  IL_LESS_MEM         =$0661;
  IL_DONT_CARE        =$0662;
  IL_MEM_SPEED_HINT   =$0665;
  IL_USE_COMPRESSION  =$0666;
  IL_NO_COMPRESSION   =$0667;
  IL_COMPRESSION_HINT =$0668;

// Mode types (file specific):
  IL_TGA_CREATE_STAMP        =$0710;
  IL_JPG_QUALITY             =$0711;
  IL_PNG_INTERLACE           =$0712;
  IL_TGA_RLE                 =$0713;
  IL_BMP_RLE                 =$0714;
  IL_SGI_RLE                 =$0715;
  IL_TGA_ID_STRING           =$0717;
  IL_TGA_AUTHNAME_STRING     =$0718;
  IL_TGA_AUTHCOMMENT_STRING  =$0719;
  IL_PNG_AUTHNAME_STRING     =$071A;
  IL_PNG_TITLE_STRING        =$071B;
  IL_PNG_DESCRIPTION_STRING  =$071C;
  IL_TIF_DESCRIPTION_STRING  =$071D;
  IL_TIF_HOSTCOMPUTER_STRING =$071E;
  IL_TIF_DOCUMENTNAME_STRING =$071F;
  IL_TIF_AUTHNAME_STRING     =$0720;
  IL_JPG_SAVE_FORMAT         =$0721;
  IL_CHEAD_HEADER_STRING     =$0722;
  IL_PCD_PICNUM              =$0723;
  IL_PNG_ALPHA_INDEX         =$0724;
  IL_JPG_PROGRESSIVE         =$0725;
  IL_VTF_COMP                =$0726;

// DXTC definitions
  IL_DXTC_FORMAT      =$0705;
  IL_DXT1             =$0706;
  IL_DXT2             =$0707;
  IL_DXT3             =$0708;
  IL_DXT4             =$0709;
  IL_DXT5             =$070A;
  IL_DXT_NO_COMP      =$070B;
  IL_KEEP_DXTC_DATA   =$070C;
  IL_DXTC_DATA_FORMAT =$070D;
  IL_3DC              =$070E;
  IL_RXGB             =$070F;
  IL_ATI1N            =$0710;
  IL_DXT1A            =$0711;

// Error types
  IL_NO_ERROR             =$0000;
  IL_INVALID_ENUM         =$0501;
  IL_OUT_OF_MEMORY        =$0502;
  IL_FORMAT_NOT_SUPPORTED =$0503;
  IL_INTERNAL_ERROR       =$0504;
  IL_INVALID_VALUE        =$0505;
  IL_ILLEGAL_OPERATION    =$0506;
  IL_ILLEGAL_FILE_VALUE   =$0507;
  IL_INVALID_FILE_HEADER  =$0508;
  IL_INVALID_PARAM        =$0509;
  IL_COULD_NOT_OPEN_FILE  =$050A;
  IL_INVALID_EXTENSION    =$050B;
  IL_FILE_ALREADY_EXISTS  =$050C;
  IL_OUT_FORMAT_SAME      =$050D;
  IL_STACK_OVERFLOW       =$050E;
  IL_STACK_UNDERFLOW      =$050F;
  IL_INVALID_CONVERSION   =$0510;
  IL_BAD_DIMENSIONS       =$0511;
  IL_FILE_READ_ERROR      =$0512;
  IL_FILE_WRITE_ERROR     =$0512;

  IL_LIB_GIF_ERROR  =$05E1;
  IL_LIB_JPEG_ERROR =$05E2;
  IL_LIB_PNG_ERROR  =$05E3;
  IL_LIB_TIFF_ERROR =$05E4;
  IL_LIB_MNG_ERROR  =$05E5;
  IL_LIB_JP2_ERROR  =$05E6;
  IL_LIB_EXR_ERROR  =$05E7;
  IL_UNKNOWN_ERROR  =$05FF;

// Format types:
  IL_COLOUR_INDEX     =$1900;
  IL_COLOR_INDEX      =$1900;
  IL_ALPHA            =$1906;
  IL_RGB              =$1907;
  IL_RGBA             =$1908;
  IL_BGR              =$80E0;
  IL_BGRA             =$80E1;
  IL_LUMINANCE        =$1909;
  IL_LUMINANCE_ALPHA  =$190A;

// Format type types:
  IL_BYTE           =$1400;
  IL_UNSIGNED_BYTE  =$1401;
  IL_SHORT          =$1402;
  IL_UNSIGNED_SHORT =$1403;
  IL_INT            =$1404;
  IL_UNSIGNED_INT   =$1405;
  IL_FLOAT          =$1406;
  IL_DOUBLE         =$140A;
  IL_HALF           =$140B;

type
  ILenum     = Cardinal;
  ILboolean  = Byte;
  ILbitfield = Cardinal;
  ILbyte     = Char;
  ILshort    = SmallInt;
  ILint      = Integer;
  ILsizei    = size_t;
  ILubyte    = Byte;
  ILushort   = Word;
  ILuint     = Cardinal;
  ILfloat    = Single;
  ILclampf   = Single;
  ILdouble   = Double;
  ILclampd   = Double;

(*  if UNICODE:
  ILchar     = WideChar;
  ILstring   = PWideChar;
  ILconst_string = {const} PWideChar;*)
  ILchar     = Char;
  ILstring   = PChar;
	ILconst_string = {const} PChar;

  PILboolean  = ^ILboolean;
  PILint      = ^ILint;
  PILubyte    = ^ILubyte;
  PILuint     = ^ILuint;

  DevILType = ILenum;
  DevILMode = ILenum;
  DevILError = ILenum;
  DevILHint = ILenum;
  DevILFormat = ILenum;
  DevILFormatType = ILenum;
  DevILFormatPalette = ILenum;

var
  ilInit: procedure; stdcall;
  ilShutDown: procedure; stdcall;
  ilGetError: function : DevILError; stdcall;
  ilGetBoolean: function (Mode : DevILMode) : ILboolean; stdcall;
  //ilGetBooleanv: procedure (Mode : DevILMode; Param : PILboolean); stdcall;
  ilGetInteger: function (Mode : DevILMode) : ILint; stdcall;
  //ilGetIntegerv: procedure (Mode : DevILMode; Param : PILint); stdcall;
  ilSetInteger: procedure (Mode : DevILMode; Param : ILint); stdcall;
  ilHint: procedure (Target : DevILHint; Mode : DevILMode); stdcall;

  //ilGenImage: function : ILuint; stdcall;
  ilGenImages: procedure (Num : ILsizei; Images : PILuint); stdcall;
  ilBindImage: procedure (Image : ILuint); stdcall;
  //ilDeleteImage: procedure (const Num : ILuint); stdcall;
  ilDeleteImages: procedure (Num : ILsizei; const Images : PILuint); stdcall;

  { DanielPharos: The first parameter should be named Type, but since this is
  a statement in Delphi, we can't use that name }
  //ilLoad: function (xType : DevILType; FileName : ILconst_string) : ILboolean; stdcall;
  ilSave: function (xType : DevILType; FileName : ILstring) : ILboolean; stdcall;
  ilLoadL: function (xType : DevILType; Lump : PByte; Size : ILuint) : ILboolean; stdcall;
  ilSaveL: function (xType : DevILType; Lump : PByte; Size : ILuint) : ILuint; stdcall;
  ilConvertImage: function (DestFormat : DevILFormat; DestType : DevILFormatType) : ILboolean; stdcall;
  ilConvertPal: function (DestFormat : DevILFormatPalette) : ILboolean; stdcall;
  ilGetData: function : PILubyte; stdcall;
  //ilSetData: function (Data : PByte) : ILboolean; stdcall;
  ilGetPalette: function : PILubyte; stdcall;
  //ilCopyPixels: function (XOff : ILuint; YOff : ILuint; ZOff : ILuint; Width : ILuint; Height : ILuint; Depth : ILuint; Format : DevILFormat; xType : DevILFormatType; Data : PByte): ILuint; stdcall;
  //ilSetPixels: procedure (XOff : ILint; YOff : ILint; ZOff : ILint; Width : ILuint; Height : ILuint; Depth : ILuint; Format : DevILFormat; xType : DevILFormatType; Data : PByte); stdcall; //DanielPharos: I suspect these should be unsigned integers too!
  ilTexImage: function (Width : ILuint; Height : ILuint; Depth : ILuint; numChannels : ILubyte; Format : DevILFormat; xType : DevILType; Data : PByte) : ILboolean; stdcall;
  ilDisable: function (Mode : DevILMode) : ILboolean; stdcall;
  ilEnable: function (Mode : DevILMode) : ILboolean; stdcall;
  //ilFormatFunc: function (Mode : DevILMode) : ILboolean; stdcall;
  ilOriginFunc: function (Mode : DevILMode) : ILboolean; stdcall;
  ilClearImage: function : ILboolean; stdcall;
  ilRegisterPal: procedure (Pal : PByte; Size : ILuint; xType : DevILFormatPalette); stdcall;

function LoadDevIL : Boolean;
procedure UnloadDevIL(ForceUnload: boolean = false);
function ilHasAlpha: Boolean;
function ilHasPalette: Boolean;
procedure CheckDevILError(DevILError: DevILError);

{-------------------}

implementation

uses Setup, Quarkx, QkExceptions, Logging, ApplPaths;

var
  TimesLoaded: Cardinal;
  HDevIL : HMODULE;

function InitDllPointer(DLLHandle: HMODULE; const APIFuncname: String) : Pointer;
begin
  Result := GetProcAddress(DLLHandle, PChar(APIFuncname));
  if Result = Nil then
  begin
    LogWindowsError(GetLastError(), 'GetProcAddress(DLLHandle, "'+APIFuncname+'")');
    LogAndRaiseError(FmtLoadStr1(5743, [APIFuncname, 'DevIL']));
  end;
end;

function LoadDevIL : Boolean;
var
  DevILLibraryFilename: String;
begin
  if (TimesLoaded=0) then
  begin
    if (HDevIL = 0) then
    begin
      DevILLibraryFilename := ConcatPaths([GetQPath(pQuArKDll), 'DevIL.dll']);
      Log(LOG_INFO, LoadStr1(5740), ['DevIL', DevILLibraryFilename]);

      HDevIL := LoadLibrary(PChar(DevILLibraryFilename));
      if HDevIL = 0 then
      begin
        LogWindowsError(GetLastError(), 'LoadLibrary("'+DevILLibraryFilename+'")');
        LogAndRaiseError(FmtLoadStr1(5741, ['DevIL']));
      end;

      ilInit            := InitDllPointer(HDevIL, 'ilInit');
      ilShutDown        := InitDllPointer(HDevIL, 'ilShutDown');
      ilGetError        := InitDllPointer(HDevIL, 'ilGetError');
      ilGetBoolean      := InitDllPointer(HDevIL, 'ilGetBoolean');
      //ilGetBooleanv     := InitDllPointer(HDevIL, 'ilGetBooleanv');
      ilGetInteger      := InitDllPointer(HDevIL, 'ilGetInteger');
      //ilGetIntegerv     := InitDllPointer(HDevIL, 'ilGetIntegerv');
      ilSetInteger      := InitDllPointer(HDevIL, 'ilSetInteger');
      ilHint            := InitDllPointer(HDevIL, 'ilHint');
      //ilGenImage        := InitDllPointer(HDevIL, 'ilGenImage');
      ilGenImages       := InitDllPointer(HDevIL, 'ilGenImages');
      ilBindImage       := InitDllPointer(HDevIL, 'ilBindImage');
      //ilDeleteImage     := InitDllPointer(HDevIL, 'ilDeleteImage');
      ilDeleteImages    := InitDllPointer(HDevIL, 'ilDeleteImages');
      //ilLoad            := InitDllPointer(HDevIL, 'ilLoad');
      ilSave            := InitDllPointer(HDevIL, 'ilSave');
      ilLoadL           := InitDllPointer(HDevIL, 'ilLoadL');
      ilSaveL           := InitDllPointer(HDevIL, 'ilSaveL');
      ilConvertImage    := InitDllPointer(HDevIL, 'ilConvertImage');
      ilConvertPal      := InitDllPointer(HDevIL, 'ilConvertPal');
      ilGetData         := InitDllPointer(HDevIL, 'ilGetData');
      //ilSetData         := InitDllPointer(HDevIL, 'ilSetData');
      ilGetPalette      := InitDllPointer(HDevIL, 'ilGetPalette');
      //ilCopyPixels      := InitDllPointer(HDevIL, 'ilCopyPixels');
      //ilSetPixels       := InitDllPointer(HDevIL, 'ilSetPixels');
      ilTexImage        := InitDllPointer(HDevIL, 'ilTexImage');
      ilDisable         := InitDllPointer(HDevIL, 'ilDisable');
      ilEnable          := InitDllPointer(HDevIL, 'ilEnable');
      //ilFormatFunc      := InitDllPointer(HDevIL, 'ilFormatFunc');
      ilOriginFunc      := InitDllPointer(HDevIL, 'ilOriginFunc');
      ilClearImage      := InitDllPointer(HDevIL, 'ilClearImage');
      ilRegisterPal     := InitDllPointer(HDevIL, 'ilRegisterPal');

      if ilGetInteger(IL_VERSION_NUM) < 178 then
        LogAndRaiseError(FmtLoadStr1(5742, ['DevIL']));

      ilInit;
      CheckDevILError(ilGetError);

      Log(LOG_VERBOSE, 'DevIL library loaded!');
    end;

    TimesLoaded := 1;
    Result:=true;
  end
  else
  begin
    TimesLoaded := TimesLoaded + 1;
    Result := True;
  end;
end;

procedure UnloadDevIL(ForceUnload: boolean);
begin
  if (TimesLoaded = 1) or ForceUnload then
  begin
    if HDevIL <> 0 then
    begin
      Log(LOG_VERBOSE, 'Unloading DevIL...');

      ilShutdown;

      if FreeLibrary(HDevIL) = false then
      begin
        LogWindowsError(GetLastError(), 'FreeLibrary(HDevIL)');
        LogAndRaiseError(FmtLoadStr1(5748, ['DevIL']));
      end;
      HDevIL := 0;

      ilInit                := nil;
      ilShutDown            := nil;
      ilGetError            := nil;
      ilGetBoolean          := nil;
      //ilGetBooleanv         := nil;
      ilGetInteger          := nil;
      //ilGetIntegerv         := nil;
      ilSetInteger          := nil;
      ilHint                := nil;
      //ilGenImage            := nil;
      ilGenImages           := nil;
      ilBindImage           := nil;
      //ilDeleteImage         := nil;
      ilDeleteImages        := nil;
      //ilLoad                := nil;
      ilSave                := nil;
      ilLoadL               := nil;
      ilSaveL               := nil;
      ilConvertImage        := nil;
      ilConvertPal          := nil;
      ilGetData             := nil;
      //ilSetData             := nil;
      ilGetPalette          := nil;
      //ilCopyPixels          := nil;
      //ilSetPixels           := nil;
      ilTexImage            := nil;
      ilDisable             := nil;
      ilEnable              := nil;
      //ilFormatFunc          := nil;
      ilOriginFunc          := nil;
      ilClearImage          := nil;
      ilRegisterPal         := nil;

      Log(LOG_VERBOSE, 'DevIL unloaded!');
    end;

    TimesLoaded := 0;
  end
  else
    if TimesLoaded <> 0 then
      TimesLoaded := TimesLoaded - 1;
end;

{-------------------}

function ilHasAlpha: Boolean;
var
  ImageFormat: DevILFormat;
  PaletteType: DevILFormatPalette;
begin
  ImageFormat:=ilGetInteger(IL_IMAGE_FORMAT);
  CheckDevILError(ilGetError);
  case ImageFormat of
  IL_RGBA, IL_BGRA, IL_LUMINANCE_ALPHA:
    Result:=True;
  IL_COLOUR_INDEX:
  begin
    PaletteType:=ilGetInteger(IL_PALETTE_TYPE);
    CheckDevILError(ilGetError);
    if (PaletteType = IL_PAL_RGBA32) or (PaletteType = IL_PAL_BGRA32) then
      Result:=True
    else
      Result:=False;
  end;
  else
    Result:=False;
  end;
end;

function ilHasPalette: Boolean;
var
  ImageFormat: DevILFormat;
begin
  ImageFormat:=ilGetInteger(IL_IMAGE_FORMAT);
  CheckDevILError(ilGetError);
  if ImageFormat=IL_COLOUR_INDEX then
    Result:=True
  else
    Result:=False;
end;

procedure CheckDevILError(DevILError: DevILError);
var
  S, S1: String;
begin
  while DevILError<>IL_NO_ERROR do
  begin
    case DevILError of
    IL_INVALID_ENUM: S1 := 'IL_INVALID_ENUM';
    IL_OUT_OF_MEMORY: S1 := 'IL_OUT_OF_MEMORY';
    IL_FORMAT_NOT_SUPPORTED: S1 := 'IL_FORMAT_NOT_SUPPORTED';
    IL_INTERNAL_ERROR: S1 := 'IL_INTERNAL_ERROR';
    IL_INVALID_VALUE: S1 := 'IL_INVALID_VALUE';
    IL_ILLEGAL_OPERATION: S1 := 'IL_ILLEGAL_OPERATION';
    IL_ILLEGAL_FILE_VALUE: S1 := 'IL_ILLEGAL_FILE_VALUE';
    IL_INVALID_FILE_HEADER: S1 := 'IL_INVALID_FILE_HEADER';
    IL_INVALID_PARAM: S1 := 'IL_INVALID_PARAM';
    IL_COULD_NOT_OPEN_FILE: S1 := 'IL_COULD_NOT_OPEN_FILE';
    IL_INVALID_EXTENSION: S1 := 'IL_INVALID_EXTENSION';
    IL_FILE_ALREADY_EXISTS: S1 := 'IL_FILE_ALREADY_EXISTS';
    IL_OUT_FORMAT_SAME: S1 := 'IL_OUT_FORMAT_SAME';
    IL_STACK_OVERFLOW: S1 := 'IL_STACK_OVERFLOW';
    IL_STACK_UNDERFLOW: S1 := 'IL_STACK_UNDERFLOW';
    IL_INVALID_CONVERSION: S1 := 'IL_INVALID_CONVERSION';
    IL_BAD_DIMENSIONS: S1 := 'IL_BAD_DIMENSIONS';
    IL_FILE_READ_ERROR: S1 := 'IL_FILE_READ_ERROR or IL_FILE_WRITE_ERROR';
//    IL_FILE_READ_ERROR: S1 := 'IL_FILE_READ_ERROR';
//    IL_FILE_WRITE_ERROR: S1 := 'IL_FILE_WRITE_ERROR';
    IL_LIB_GIF_ERROR: S1 := 'IL_LIB_GIF_ERROR';
    IL_LIB_JPEG_ERROR: S1 := 'IL_LIB_JPEG_ERROR';
    IL_LIB_PNG_ERROR: S1 := 'IL_LIB_PNG_ERROR';
    IL_LIB_TIFF_ERROR: S1 := 'IL_LIB_TIFF_ERROR';
    IL_LIB_MNG_ERROR: S1 := 'IL_LIB_MNG_ERROR';
    IL_LIB_JP2_ERROR: S1 := 'IL_LIB_JP2_ERROR';
    IL_LIB_EXR_ERROR: S1 := 'IL_LIB_EXR_ERROR';
    IL_UNKNOWN_ERROR: S1 := 'IL_UNKNOWN_ERROR';
    else
      S1 := 'Unknown error code';
    end;
    if S <> '' then
      S := S + ',';
    S := S + S1;
    DevILError:=ilGetError;
  end;
  if S <> '' then
    Raise EErrorFmt(5731, ['DevIL library', S]);
end;

{-------------------}

initialization
begin
  HDevIL:=0;
end;

finalization
  UnloadDevIL(true);
end.
