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

{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.82  2010/05/05 19:23:23  danielpharos
Fixed small bug in DEBUG output.

Revision 1.81  2010/05/05 19:15:51  danielpharos
Const-ed a string.

Revision 1.80  2010/05/05 19:15:06  danielpharos
Const-ed a string.

Revision 1.79  2010/05/05 18:45:20  danielpharos
Added logging for GetGameFileBase call.

Revision 1.78  2010/02/21 15:42:51  danielpharos
Fixed orangebox compiler not finishing compile.

Revision 1.77  2010/02/06 21:52:54  danielpharos
Corrected ep1 <--> orangebox.

Revision 1.76  2010/02/06 21:05:47  danielpharos
Adjusted for newest Steam release (QuArKSAS 1.02). Also, fixed various Steam-related issues.

Revision 1.75  2010/02/06 15:23:41  danielpharos
Massive update to GCF file loading. This should fix most "cannot find GCF file" type problems.

Revision 1.74  2009/09/23 20:37:16  danielpharos
Fix tags of models not loading outside of pak-files.

Revision 1.73  2009/07/15 10:38:00  danielpharos
Updated website link.

Revision 1.72  2009/03/23 16:02:10  danielpharos
Tweaks and fixes to get FAKK2 build tools working again.

Revision 1.71  2009/02/21 17:06:18  danielpharos
Changed all source files to use CRLF text format, updated copyright and GPL text.

Revision 1.70  2009/01/28 21:10:05  danielpharos
Fix a path IO error 103 crash.

Revision 1.69  2008/11/06 19:29:51  danielpharos
Renamed function to concatenate paths, and start using it.

Revision 1.68  2008/11/06 19:19:57  danielpharos
Moved GameShaderList to correct location, and removed unused variable.

Revision 1.67  2008/10/16 21:26:38  danielpharos
Fix naming of steam path replacer and give auto-setting an invalid filename, so it can never be actually used.

Revision 1.66  2008/10/08 21:42:18  danielpharos
Made map extension changable.

Revision 1.65  2008/10/07 21:16:25  danielpharos
Massive update to get Steam finally working better.

Revision 1.64  2008/10/07 21:04:52  danielpharos
Added GetBaseDir function and other small fixes.

Revision 1.63  2008/09/29 22:50:32  danielpharos
Resolve-code: Fixed games trying to start from wrong directory.

Revision 1.62  2008/09/29 22:41:11  danielpharos
Fixed for file resolving code. Fixes Steam-games.

Revision 1.61  2008/09/29 22:02:00  danielpharos
Update to filename resolving code. Needs more testing, but should work.

Revision 1.60  2008/09/29 21:45:31  danielpharos
Soft-coded 'maps' directory (not in Python yet).

Revision 1.59  2008/09/29 21:08:52  danielpharos
Update filename resolving code. Still untested.

Revision 1.58  2008/09/26 19:37:03  danielpharos
Fix some broken path logic.

Revision 1.57  2008/09/20 19:32:00  danielpharos
Changed a default value and re-factored some code.

Revision 1.56  2008/09/06 15:56:59  danielpharos
Moved exception code into separate file.

Revision 1.55  2008/07/25 18:49:14  danielpharos
Fix a comment

Revision 1.54  2008/05/15 10:09:35  danielpharos
Fix wrong error message

Revision 1.53  2008/02/23 20:22:20  danielpharos
Small changes to Python loading and unloading

Revision 1.52  2008/02/23 19:25:20  danielpharos
Moved a lot of path/file code around: should make it easier to use

Revision 1.51  2007/12/13 12:32:36  danielpharos
Change a procedure name to something much less confusing.

Revision 1.50  2007/12/11 23:52:28  danielpharos
Fixed a memory leak that occurred on exit in some gamemodes.

Revision 1.49  2007/10/23 14:47:56  danielpharos
Fixed the filename being double in the not-found error message.

Revision 1.48  2007/09/13 14:34:53  danielpharos
The name of a pakfile containing a texture can now be specified per texture

Revision 1.47  2007/09/10 10:08:11  danielpharos
Fix a comment-sign

Revision 1.46  2007/08/21 23:43:44  danielpharos
Another fix to the HL2 building process.

Revision 1.45  2007/08/14 16:32:59  danielpharos
HUGE update to HL2: Loading files from Steam should work again, now using the new QuArKSAS utility!

Revision 1.44  2007/05/15 15:01:38  danielpharos
Fixed a dirty looking check for Steam Access.

Revision 1.43  2007/03/15 22:15:35  danielpharos
Made the crash-safe gamebuffer size 8 MB instead of 2 MB.

Revision 1.42  2007/02/07 18:48:34  danielpharos
Fixes for memory leaks

Revision 1.41  2006/05/05 06:04:44  cdunde
To reverse Texture Memory changes. Cases problems with Quake 3 QkQ3.pas
handling of textures in the Texture Browser, hour glass icon jitters and memeor usage
increases causing prog crash, can not use scrole bar in TB.

Revision 1.40  2006/04/07 21:36:31  nerdiii
bugfix: latest version caused access violation if .WAD not found

Revision 1.39  2006/04/06 19:28:06  nerdiii
Texture memory wasn't freed because texture links had additional references to them.

Revision 1.38  2005/09/28 10:48:31  peter-b
Revert removal of Log and Header keywords

Revision 1.36  2005/07/07 07:14:57  alexander
fixed problem not displaying boxes for models

Revision 1.35  2005/07/04 18:53:20  alexander
changed steam acces to be a protocol steamaccess://

Revision 1.34  2005/01/11 01:47:12  alexander
for .steamfs links allow subdirectories after basedir

Revision 1.33  2005/01/02 15:19:27  alexander
access files via steam service - first

Revision 1.32  2004/12/27 10:56:23  alexander
dont load gcf every time again

Revision 1.31  2004/12/22 11:42:16  rowdy
Rowdy - first pass of support for Doom 3

Revision 1.30  2004/11/25 00:35:50  alexander
first gcf access attempt

Revision 1.29  2003/08/12 15:39:45  silverpaladin
Added ExtraFunctionality to the uses so that platform independant routines are available for pre-Delphi 6 versions.

Revision 1.28  2003/07/21 04:52:21  nerdiii
Linux compatibility ( '/' '\' )

Revision 1.27  2002/03/07 19:15:38  decker_dk
Removed QImages, as it was just another name for QImage

Revision 1.26  2001/06/21 17:34:50  decker_dk
If no value in CheckDirectory, then accept any directory.

Revision 1.25  2001/06/05 18:38:28  decker_dk
Prefixed interface global-variables with 'g_', so its clearer that one should not try to find the variable in the class' local/member scope, but in global-scope maybe somewhere in another file.

Revision 1.24  2001/05/09 18:53:29  aiv
fix for retail cs.

Revision 1.23  2001/03/20 21:48:05  decker_dk
Updated copyright-header

Revision 1.22  2001/02/23 19:26:21  decker_dk
Small changes (which hopefully does not break anything)
SuivantDansGroupe => NextInGroup
TrimStringList => StringListConcatWithSeparator

Revision 1.21  2001/02/03 06:09:57  tiglari
reverse order of disk and pak search in GetGameFileBase,
since disk should be consulted first (`missing shader' problem).
What about order of paks?

Revision 1.20  2001/01/30 19:11:10  decker_dk
Changed to GetApplicationPath().

Revision 1.19  2000/11/25 20:51:33  decker_dk
- Misc. small code cleanups
- Replaced the names:
 = ofTvInvisible       -> ofTreeViewInvisible
 = ofTvAlreadyExpanded -> ofTreeViewAlreadyExpanded
 = ofTvExpanded        -> ofTreeViewExpanded
 = ofSurDisque         -> ofNotLoadedToMemory
 = ModeFichier         -> fmOpenReadOnly_ShareDenyWrite
 = ModeFichierEcr      -> fmOpenReadWrite_ShareDenyWrite

Revision 1.18  2000/11/16 19:42:17  decker_dk
- Modified Convex's texture-fileextension alias code, so it won't conflict
with the rest of the existing code.
- Introduced a 'TextureFileExtensions' specific, which will contain the
texture-fileextension aliases, for COnvex's code.
- Implemented solution for extracting texture-links from .PK3 files
('.pakfolder' vs '.zipfolder' problem)
- Replaced the function-names:
  = Q2TexPath    -> GameTexturesPath
  = Q3ShaderPath -> GameShadersPath
- Cleaned up some code here and there.
- Corrected problem with QTextureFile.LoadPaletteInfo not initializing an
PGameBuffer totally. Hmm? May have introduced problem with color-palette
in other windows than the texture-browser-detail.
- Found the place in QkWAD.PAS where the common size of the textures, in the
texture-browser, are controlled/set. Useful for 32x32, 128x128 and so scaling.

Revision 1.17  2000/09/18 01:29:43  alexander
proper indenting

Revision 1.16  2000/09/17 15:00:17  alexander
committed convex' generalization of texture format aliasing

Revision 1.15  2000/07/18 19:37:58  decker_dk
Englishification - Big One This Time...

Revision 1.14  2000/07/16 16:34:50  decker_dk
Englishification

Revision 1.13  2000/07/09 13:20:42  decker_dk
Englishification and a little layout

Revision 1.12  2000/06/17 11:21:59  arigo
minor fix for Decker's hack

Revision 1.11  2000/05/20 14:10:25  decker_dk
Some more englishification

Revision 1.10  2000/05/07 09:33:02  decker_dk
Fixed a problem with TGetPakNames

Revision 1.9  2000/04/29 15:13:30  decker_dk
Allow other than PAK#.PAK files

Revision 1.8  2000/04/14 17:29:00  alexander
fixed: crash, when loading alias files
}

unit Game;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkObjects, QkFileObjects, qmath, QkForm, StdCtrls, TB97, ComCtrls, StrUtils, Logging;

type
  TGameCfgDlg = class(TQkForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ListView1: TListView;
    BtnAdd: TToolbarButton97;
    BtnRemove: TToolbarButton97;
    CancelBtn: TToolbarButton97;
    OkBtn: TToolbarButton97;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnRemoveClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

 {------------------------}

type
 PBitmapInfoColors = ^TBitmapInfoColors;
 TBitmapInfoColors = array[0..255] of TRGBQuad;
 PBitmapInfo256 = ^TBitmapInfo256;
 TBitmapInfo256 = record
                   bmiHeader: TBitmapInfoHeader;
                   bmiColors: TBitmapInfoColors;
                  end;
 PPaletteLmp1 = ^TPaletteLmp1;
 TPaletteLmp1 = packed array[0..2] of Byte;
 PPaletteLmp = ^TPaletteLmp;
 TPaletteLmp = packed array[0..255] of TPaletteLmp1;
 HPalettePtr = ^HPalette;
 PGameBuffer = ^TGameBuffer;
 TGameBuffer = record
                Palette, PaletteReelle: HPalette;
                PaletteLmp: TPaletteLmp;
                RefCount: Integer;
                GameName: String[19];
                TextureExt: String[11]; {DECKER back again, as Aliases are stored in 'TextureFormats' and not 'TextureFormat'}
                (*TextureExt: String[255]; {--CONVEX-- : more space needed!} *)
                UnifiedPalette: Boolean;
               {AddOns: QFileObject;}
                case Integer of
                 0: (BitmapInfo: TBitmapInfo256);
                 1: (BmpInfo: TBitmapInfo);
                end;
 TGeneralGammaBuffer = array[0..255] of Byte;
{TMQIDF = (dfWinFormat, dfTextureFormat, dfBottomUpTexture);}
 TFileType = (ftAny, ftGame, ftTool, ftPath);
 TFileToResolve = record
   Commandline: String;
   FileType: TFileType;
   AFilename: String;
   AFileobject: QObject;
 end;
 TResolvedFilename = record
   Filename: String;
   Workdir: String;
 end;

procedure ClearGameBuffers(CanCancel: Boolean);
procedure ClearGameBuffer1;
procedure SizeDownGameFiles;
procedure ReleaseGameFiles;
procedure ListSourceDirs(Dirs: TStrings);
function NeedGameFile(const FileName, PakFile: String) : QFileObject;
function NeedGameFileBase(const BaseDir, FileName, PakFile: String) : QFileObject;
function CheckForRelativePath(const Path: String) : String;
procedure BuildCorrectFileName(var S: String);
function GettmpQuArK : String;
function GetBaseDir : String;
function BaseOutputPath : String;
function OutputFile(const FileName: String) : String;
function GetGameDir : String;
function QuakeDir : String;
procedure ClearAllFilesRec(const Rep: String);
function CheckQuakeDir : Boolean;
function GameMapPath : String;
function GameModelPath : String;
function GameShaderList : String;
function SteamAppID : String;
function GetSteamtmpQuArK : String;
function GetSteamBaseDir : String;
function SourceSDKDir : String;
function GetSteamCompiler : String;
function ResolveFilename(const FileToResolve : TFileToResolve) : TResolvedFilename;
function QuickResolveFilename(const Filename : String) : String;
procedure CreateAllDirs(const Filename: string; StartIndex: Integer = 1);

function GameBuffer(NeededGame: Char) : PGameBuffer;
procedure ClearBmpInfo24(var BmpInfo: TBitmapInfo256);
procedure PaletteFromLmp(const Lmp: TPaletteLmp; var BmpInfo: TBitmapInfo256;
           Palette, PaletteReelle: HPalettePtr);
procedure ColorsFromLmp(const Lmp: TPaletteLmp; var bmiColors: TBitmapInfoColors);
{function MakeQuakeImageData(NeededGame: Char; DC: HDC; W,H, nW,nH: Integer; Format: TMQIDF) : String;}
function GetQPaletteColor(const BitmapInfo: TBitmapInfo256; I: Integer) : TColorRef;
function ColorIsLight(C: TColorRef) : Boolean;

function DuplicateGameBuffer(Source: PGameBuffer) : PGameBuffer;
procedure DeleteGameBuffer(B: PGameBuffer);

procedure GameCfgDlg;
procedure DisplayAddOnsList(ListView1: TListView);
function InitGeneralGammaBuffer(var Buf: TGeneralGammaBuffer; var FG: TDouble) : Boolean;

 {------------------------}

implementation

{$R *.DFM}

uses QkPak, Setup, QkUnknown, QkTextures, Travail, ToolBox1, QkImages, Qk1,
  Game2, QkQuakeCtx, Config, PakFiles, Quarkx, QkExceptions, PyImages,
  QkApplPaths, QkSteamFS, Python, ExtraFunctionality;

var
 GameFiles: TQList = Nil;
// SourceBases: TStringList;
 GameBuffer1: PGameBuffer;
 FreeGBList: TList = Nil;

{--CONVEX-begin--}
type
  TFileTypeAlias = (ftNone, ftTexture, ftPak);

var
  CurAliasName   : String; // current aliased filename
  CurAliasIndex  : Byte; // current alias-extension index
  CurAliasType   : TFileTypeAlias;
{--CONVEX-end--}

function GetGameFileBase(const BaseDir, FileName, PakFileName: String; LookInCD: Boolean) : QFileObject; forward;

 {------------------------}

procedure ReleaseGameFiles;
begin
 g_Form1.SavePendingFiles(True);
 GameFiles.Free;
 GameFiles:=Nil;
end;

procedure InternalSizeDown;
var
 MemLeft: Integer;
 I, Reste: Integer;
{FreeSize: Integer;
 Remove: Boolean;
 Q: QObject;}
 Setup: QObject;
begin
 if GameFiles=Nil then
  Exit;

 Setup:=SetupSubSet(ssGeneral, 'Memory');
 Reste:=Round(Setup.GetFloatSpec('GameFiles', 15));
(*if Reste<0 then Reste:=0;
 for I:=GameFiles.Count-Reste-1 downto 0 do
  GameFiles.Delete(I);*)
 if GameFiles.Count>Reste then
  begin
   ReleaseGameFiles;
   Exit;
  end;

 MemLeft:=Round(Setup.GetFloatSpec('GameBufferSize', 8)) * (1024*1024);
 for I:=GameFiles.Count-1 downto 0 do
  begin
   Dec(MemLeft, GameFiles[I].GetObjectSize(Nil, False));
   if MemLeft<=0 then
    begin
     ReleaseGameFiles;
     Exit;
    end;
  end;
(*Remove:=False;
 for I:=GameFiles.Count-1 downto 0 do
  begin
   Q:=GameFiles[I];
   if not Remove then
    begin
     Dec(FreeSize, Q.GetObjectSize(Nil, False));
     if FreeSize<=0 then
      Remove:=True;   { game buffer overflow }
    end;
   if Remove then
    begin  { object has to be removed }
     Q.Free;
     GameFiles.Delete(I);
    end
  end;*)
end;

procedure ClearGBList;
var
 I: Integer;
 B: PGameBuffer;
begin
 if FreeGBList<>Nil then
  try
   for I:=FreeGBList.Count-1 downto 0 do
    begin
     B:=PGameBuffer(FreeGBList[I]);
{$IFDEF Debug}
     if B^.RefCount<>0 then
      Raise InternalE('ClearGBList');
{$ENDIF}
     DeleteObject(B^.Palette);
     DeleteObject(B^.PaletteReelle);
    {B^.AddOns.AddRef(-1);}
     Dispose(B);
    end;
  finally
   FreeGBList.Free;
   FreeGBList:=Nil;
  end;
end;

procedure SizeDownGameFiles;
begin
 {SizeDownTextureList(}InternalSizeDown{)};

 ClearGBList;

 SizeDownPython;
end;

function DuplicateGameBuffer(Source: PGameBuffer) : PGameBuffer;
begin
  {$IFDEF Debug}
  if Source^.RefCount<=0 then
    Raise InternalE('DuplicateGameBuffer');
  {$ENDIF}
  Inc(Source^.RefCount);
  Result:=Source;
end;

procedure DeleteGameBuffer(B: PGameBuffer);
begin
  if B<>Nil then
  begin
    Dec(B^.RefCount);
    if B^.RefCount<=0 then
    begin
      {$IFDEF Debug}
      if B^.RefCount<0 then
        Raise InternalE('DeleteGameBuffer');
     {$ENDIF}
      DeleteObject(B^.Palette);
      DeleteObject(B^.PaletteReelle);
     {B^.AddOns.AddRef(-1);}
      Dispose(B);
    end;
  end;
end;

procedure DelayDeleteGameBuffer(B: PGameBuffer);
begin
 if B<>Nil then
  begin
   Dec(B^.RefCount);
   if B^.RefCount<=0 then
    begin
{$IFDEF Debug}
     if B^.RefCount<0 then
      Raise InternalE('DelayDeleteGameBuffer');
{$ENDIF}
     if FreeGBList=Nil then
      FreeGBList:=TList.Create;
     FreeGBList.Add(B);
    end;
  end;
end;

procedure ClearGameBuffers(CanCancel: Boolean);
begin
 g_Form1.SavePendingFiles(CanCancel);
 CloseToolBoxes;
 ProgressIndicatorStart(4415,0);
 try
  DelayDeleteGameBuffer(GameBuffer1);
  GameBuffer1:=Nil;
  GameFiles.Free;
  GameFiles:=Nil;
  CloseAddonsList;
  // SourceBases.Free;
  // SourceBases:=Nil;
  {ClearTextureList;}
 finally
  ProgressIndicatorStop;
 end;
end;

procedure ClearGameBuffer1;
begin
 DelayDeleteGameBuffer(GameBuffer1);
 GameBuffer1:=Nil;
 UpdateAddOnsContent;
end;

function GettmpQuArK : String;
var
 I : Integer;
 L: TQList;
 GameDir : String;
begin
 { tiglari  }
 L:=GetQuakeContext;
 for I:=L.Count-1 downto 0 do
  begin
   GameDir:=L[I].Specifics.Values['GameDir'];
   if GameDir<>'' then
    begin
     Result:=ConvertPath(GameDir);
     Exit;
    end;
  end;
 {/tiglari }
 Result:=SetupGameSet.Specifics.Values['tmpQuArK'];
 if Result='' then
  Result:='tmpQuArK';
 if Result='*auto*' then
   Result:=GetSteamtmpQuArK;
 Result:=ConvertPath(Result);
end;

function GetBaseDir : String;
begin
 Result:=SetupGameSet.Specifics.Values['BaseDir'];
 if Result='*auto*' then
   Result:=GetSteamBaseDir;
 Result:=ConvertPath(Result);
end;

function QuakeDir : String;
begin
  Result:=SetupGameSet.Specifics.Values['Directory'];
  if (Result = '') and (SetupGameSet.Specifics.Values['Steam'] = '1') then
  begin
    Result:=SetupSubSet(ssGames, 'Steam').Specifics.Values['Directory'];
  end;
  Result:=ConvertPath(Result);
end;

function BaseOutputPath : String;
var
  I: Integer;
begin
  Result:=IncludeTrailingPathDelimiter(QuakeDir); //To make sure there already is a trailing slash
  I:=Length(Result)+1;
  Result:=IncludeTrailingPathDelimiter(ConcatPaths([Result, GettmpQuArK]));
  CreateAllDirs(Result, I);
end;

function OutputFile(const FileName: String) : String;
var
 I: Integer;
begin
 Result:=IncludeTrailingPathDelimiter(BaseOutputPath); //To make sure there already is a trailing slash
 if Length(FileName) <> 0 then
   if SetupGameSet.Specifics.Values['Steam']='1' then
     if (GetSteamCompiler = 'source2009') then
     begin
       I:=LastPos(PathDelim, RemoveTrailingSlash(Result));
       if I <> 0 then
         Result:=LeftStr(Result, I-1);
     end;
 I:=Length(Result)+1;
 Result:=ConcatPaths([Result, FileName]);
 if ExtractFileName(Result) <> '' then
   //It's a filename, so we can't add a trailing slash, and we can't send the filename-part to CreateAllDirs
   CreateAllDirs(IncludeTrailingPathDelimiter(ExtractFileDir(Result)), I)
 else
 begin
   Result:=IncludeTrailingPathDelimiter(Result);
   CreateAllDirs(Result, I);
 end;
end;

function GetGameDir : String;
var
  L: TQList;
  I, Count: Integer;
  GameDir, Error: String;
begin
  Result:='';
  Count:=0;
  Error:='';
  L:=GetQuakeContext;
  for I:=0 to L.Count-1 do
  begin
    GameDir:=L[I].Specifics.Values['GameDir'];
    if GameDir<>'' then
    begin
      Inc(Count);
      Error:=Error+FmtLoadStr1(5618, [GameDir]);
      Result:=GameDir;
    end;
  end;
  if Count>1 then
    GlobalWarning(FmtLoadStr1(5625, [SetupGameSet.Name, Error]));
  if Result='' then
    Result:=GettmpQuArK;
  Result:=ConvertPath(Result);
end;

procedure CreateAllDirs(const Filename: string; StartIndex: Integer = 1);
var
 I, ErrorCode: Integer;
 qFilename, S: String;
begin
 //Note: Do NOT forget to end any paths you might send through with a PathDelim!
 qFilename:=QuickResolveFilename(Filename);
 I:=StartIndex;
 if I<1 then I:=1;
 while I<=Length(qFilename) do
  begin
   if qFilename[I]=PathDelim then
    begin
     {$I-}
     S:=Copy(qFilename, 1, I-1);
     MkDir(S);
     {$I+}
     ErrorCode:=IOResult;
     if not (ErrorCode in [0,183]) then
      Raise EErrorFmt(5587, [S, SetupGameSet.Name, ErrorCode]);
    end;
   Inc(I);
  end;
end;

function ResolveFilename(const FileToResolve : TFileToResolve) : TResolvedFilename;

 function ConstainsReplacer(const StringToCheck : String) : Boolean;
 var
   I, J, K: Integer;
 begin
   I:=Pos('%', StringToCheck);
   if I=0 then
   begin
     Result := False;
     Exit;
   end;
   J:=PosEx('%', StringToCheck, I+1);
   if J=0 then
   begin
     Result := False;
     Exit;
   end;
   K:=PosEx(PathDelim, StringToCheck, I+1);
   if (K<>0) and (K < J) then
   begin
     Result := False;
     Exit;
   end;
   Result := True;
 end;

 function getGroupFilePath(obj : QObject) : String;
 var
   Q: QObject;
   Setup: QObject;
   makefolders: String;
 begin
   Result := '';
   Setup := SetupGameset;
   if (Setup.Specifics.Values['UseQrkGroupFolder']<>'') then
   begin
     Q := obj.FParent;
     while (Q <> nil) and (Q.FParent <> nil) do
     begin
       makefolders := outputfile(ConcatPaths([GameMapPath, Q.Name]));
       if Length(Result) <> 0 then
         Result := PathDelim + Result;
       Result := Q.Name + Result;
       Q := Q.FParent;
     end;
   end;
 end;

var
  Setup, SteamSetup: QObject;

  argument_mappath: String;
  argument_mapfile: String;
  argument_file: String;
  argument_filename: String;
  argument_fullfilename: String;
  argument_grouppath: String;
  argument_outputfile: String;

  setupdirectory: String;
  setupbasedir: String;
  setuptmpquark: String;
  MapExt: String;

  S: String;
  I: Integer;
begin
  //Workaround: Only try to resolve if there is anything to resolve. This fixes
  //crashes when the setup is not init-ed properly yet.
  if not ConstainsReplacer(FileToResolve.CommandLine) then
  begin
    Result.Filename:=FileToResolve.CommandLine;
    Result.WorkDir:='';
    Exit;
  end;

  Setup:=SetupGameSet;
  SteamSetup:=SetupSubSet(ssGames, 'Steam');

  setupdirectory := QuakeDir;
  setupbasedir := GetBaseDir;
  setuptmpquark := GettmpQuArK;
  if FileToResolve.FileType<>ftPath then
    argument_outputfile := OutputFile('')
  else
    argument_outputfile := '';

  case FileToResolve.FileType of
  ftGame: S:='StupidGameKludge';
  ftTool: S:='StupidBuildToolKludge';
  else
    S:='';
  end;
  if FileToResolve.FileType <> ftPath then
  begin
    if (S<>'') and (Setup.Specifics.Values[S]<>'') then
    begin
      // stupid program that wants to run in the base dir
      Result.Workdir := ConcatPaths([setupdirectory, setupbasedir]);
      if setupbasedir = setuptmpquark then
        argument_mappath := GameMapPath
      else
        argument_mappath := ConcatPaths(['..', setuptmpquark, GameMapPath]);
    end
    else
    begin
      // clever program that can run anywhere
      if FileToResolve.FileType = ftGame then
        Result.Workdir := RemoveTrailingSlash(QuickResolveFilename(setupdirectory))
      else
        Result.Workdir := RemoveTrailingSlash(QuickResolveFilename(argument_outputfile));
      argument_mappath := GameMapPath;
    end;
    if FileToResolve.FileType = ftTool then
      if SetupGameSet.Specifics.Values['Steam']='1' then
        if (GetSteamCompiler = 'source2009') then
        begin
          I:=LastPos(PathDelim, Result.Workdir);
          if I <> 0 then
            Result.Workdir:=LeftStr(Result.Workdir, I-1);
        end;

    MapExt := Setup.Specifics.Values['MapExt'];
    if MapExt = '' then
      MapExt := '.map';
    argument_mapfile := ConcatPaths([argument_mappath, FileToResolve.AFilename + MapExt]);
    argument_file    := ConcatPaths([argument_mappath, FileToResolve.AFilename]);
    argument_filename := FileToResolve.AFilename;
    argument_fullfilename := FileToResolve.AFilename + MapExt;
    if FileToResolve.AFileobject<>Nil then
      argument_grouppath := getGroupFilePath(FileToResolve.AFileobject)
    else
      argument_grouppath := '';
  end
  else
  begin
    Result.WorkDir := '';
    argument_mappath   := '';
    argument_mapfile   := '';
    argument_file      := '';
    argument_filename  := '';
    argument_grouppath := '';
  end;

  //Be careful when making changes here, because the order of these replacements is not arbitrary!
  Result.Filename:=FileToResolve.Commandline;
  Result.Filename:=StringReplace(Result.Filename, '%output%', argument_outputfile, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%grouppath%', argument_grouppath, [rfReplaceAll]);
  if Setup.Specifics.Values['BuildPgmsDir']<>'' then
    Result.Filename:=StringReplace(Result.Filename, '%buildpgmsdir%', Setup.Specifics.Values['BuildPgmsDir'], [rfReplaceAll]);

  Result.Filename:=StringReplace(Result.Filename, '%mappath%', argument_mappath, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%mapfile%', argument_mapfile, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%file%', argument_file, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%filename%', argument_filename, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%fullfilename%', argument_fullfilename, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%basepath%', setupdirectory, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%gamedir%', setuptmpquark, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%quarkpath%', GetQPath(pQuArK), [rfReplaceAll]);

  //Steam replacers:
  Result.Filename:=StringReplace(Result.Filename, '%sourcesdkdir%', SourceSDKDir, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%steampath%',    SteamSetup.Specifics.Values['Directory'], [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%steamappid%',   SteamAppID, [rfReplaceAll]);
  Result.Filename:=StringReplace(Result.Filename, '%steamuser%',    SteamSetup.Specifics.Values['SteamUser'], [rfReplaceAll]);

  {$IFDEF Debug}
  if ConstainsReplacer(FileToResolve.CommandLine) then
    Log(LOG_WARNING, 'Warning: ResolveFilename: There might be items left to be replaced...!');
  {$ENDIF}
end;

function QuickResolveFilename(const Filename : String) : String;
var
  FileToResolve: TFileToResolve;
  ResolvedFilename: TResolvedFilename;
begin
  FileToResolve.Commandline:=Filename;
  FileToResolve.FileType:=ftPath;
  FileToResolve.AFilename:='';
  FileToResolve.AFileobject:=nil;
  ResolvedFilename:=ResolveFilename(FileToResolve);
  Result:=ResolvedFilename.Filename;
end;

procedure ListSourceDirs(Dirs: TStrings);
var
 L: TQList;
 I: Integer;
 SourceDir: String;
begin
  L:=GetQuakeContext;
  for I:=L.Count-1 downto 0 do
  begin
    SourceDir:=L[I].Specifics.Values['SourceDir'];
    if SourceDir<>'' then
      Dirs.Add(SourceDir);
  end;
  Dirs.Add(GetBaseDir);
end;

{--Convex-begin--}
function IsTextureFile(const FileName: String) : Boolean;
var
  I : Integer;
begin
  Result := False;
  for I := 0 to g_TexExtensions.Count-1 do
  begin
    if (CompareText(ExtractFileExt(FileName), g_TexExtensions.Strings[i])=0) then
    begin { file is a texture if its extension is listed in GameBuffer }
      Result := True;
      Exit;
    end;
  end;
end;

function IsPakFile(const FileName: String) : Boolean;
var
  I : Integer;
begin
  Result := False;
  for I := 0 to g_PakExtensions.Count-1 do
  begin
    if (CompareText(ExtractFileExt(FileName), g_PakExtensions[i])=0) then
    begin { file is a pak if its extension is listed in GameBuffer }
      Result := True;
      Exit;
    end;
  end;
end;

procedure RestartAliasing(const Filename: String);
begin
  CurAliasName := Filename;
  CurAliasIndex := 0;
  if IsTextureFile(Filename) then
    CurAliasType := ftTexture
  else if IsPakFile(Filename) then
    CurAliasType := ftPak
  else
    CurAliasType := ftNone;
end;

function GetNextAlias: String;
begin
  if CurAliasType=ftTexture then
  begin
    if CurAliasIndex >= g_TexExtensions.Count then // no alias found
      Result := ''
    else
    begin
      Result := ChangeFileExt(CurAliasName, g_TexExtensions.Strings[CurAliasIndex]);
      Inc(CurAliasIndex);
    end;
  end
  else if CurAliasType=ftPak then
  begin
    if CurAliasIndex >= g_PakExtensions.Count then // no alias found
      Result := ''
    else
    begin
      Result := ChangeFileExt(CurAliasName, g_PakExtensions.Strings[CurAliasIndex]);
      Inc(CurAliasIndex);
    end;
  end
  else
  begin   // file is not a texture or pak
    if CurAliasIndex=0 then
      Result:=CurAliasName
    else
      Result := '';
    Inc(CurAliasIndex);
  end;
end;
{--Convex-end--}

function DisplayAllAlias(const Filename: String) : String;
var
  AliasName: String;
begin
  RestartAliasing(Filename);
  AliasName := GetNextAlias;
  Result := AliasName;
  while (AliasName <> '') do
  begin
    AliasName := GetNextAlias;
    if AliasName <> '' then
      Result:=Result + LoadStr1(4204) + AliasName;
  end;
  if Result='' then
    Result:=FileName;
end;

function NeedGameFile(const FileName, PakFile: String) : QFileObject;
var
 L: TQList;
 I: Integer;
 SourceDir: String;
begin
  L:=GetQuakeContext;
  for I:=L.Count-1 downto 0 do
  begin
    SourceDir:=L[I].Specifics.Values['SourceDir'];
    if SourceDir<>'' then
    begin
      Result:=GetGameFileBase(SourceDir, FileName, PakFile, False);
      if Result<>Nil then
        Exit;   { found it }
    end;
  end;
  Result:=GetGameFileBase(GetBaseDir, FileName, PakFile, True);
  if Result=Nil then
    Raise EErrorFmt(5560, [SetupGameSet.Name, DisplayAllAlias(FileName)]);
end;

function NeedGameFileBase(const BaseDir, FileName, PakFile: String) : QFileObject;
begin
  Result:=GetGameFileBase(BaseDir, FileName, PakFile, True);
  if Result=Nil then
    Raise EErrorFmt(5561, [SetupGameSet.Name, DisplayAllAlias(FileName), BaseDir]);
end;

//Returns an alternative path (from the QuArK dir) is the given path was a relative path
function CheckForRelativePath(const Path: String) : String;
var
  CurDir, NewPath: String;
begin
  Result:='';
  GetDir(0, CurDir);
  if IncludeTrailingPathDelimiter(CurDir) = GetQPath(pQuArK) then
    //Delphi doesn't like ChDir-ing to the same directory...
    NewPath:=ExpandFileName(Path)
  else
    try
      ChDir(GetQPath(pQuArK));
      NewPath:=ExpandFileName(Path);
    finally
      ChDir(CurDir);
    end;
  if CompareText(NewPath, Path) <> 0 then
    Result:=NewPath;
end;

{--Convex-begin-- : multi-alias texture file search }
function GetGameFileBase(const BaseDir, FileName, PakFileName: String; LookInCD: Boolean) : QFileObject;

 function GetCDPath(const BaseDir, FileName: String): String;
 var
   CD, CDDir: String;
 begin
   Result:='';
   CDDir:=SetupGameSet.Specifics.Values['CDDir'];
   if CDDir='' then
     Exit;  // no CD to look in
   CD:=SetupGameSet.Specifics.Values['CD'];
   if CD='' then
     Exit; // no CD drive configured
   Result:=ConcatPaths([CD, CDDir, BaseDir]);
   if DirectoryExists(Result) = false then
     if MessageDlg(FmtLoadStr1(5559, [SetupGameSet.Name, FileName]), mtInformation, mbOkCancel, 0) <> mrOk then
       Result:='';
 end;

var
 SearchStage: Integer;
 AbsolutePath, AbsolutePathAndFilename: String;
 FilenameAlias: String;
 PakFile: QFileObject;
 PakRealFileName: String;
 PakSearchPath: String;
 GetPakNames: TGetPakNames;
 Setup: QObject;
 SteamRunning: Boolean;
 SteamCacheDir: String;
begin
  Log(LOG_VERBOSE, 'GetGameFileBase: %s, %s, %s, %s', [BaseDir, FileName, PakFileName, BoolToStr(LookInCD)]);
  Result := NIL;
  if (GameFiles=Nil) then
    GameFiles:=TQList.Create;
  SearchStage:=0;
  AbsolutePath:=ConcatPaths([QuakeDir, BaseDir]);
  repeat
    // Buffer search
    RestartAliasing(FileName);
    FilenameAlias := GetNextAlias;
    while (FilenameAlias <> '') do
    begin
      AbsolutePathAndFilename := ExpandFileName(ConcatPaths([AbsolutePath, FilenameAlias]));
      Result := SortedFindFileName(GameFiles, AbsolutePathAndFilename);
      if (Result <> NIL) then
        Exit; { found it }
      FilenameAlias := GetNextAlias;
    end;

    //Disk search
    RestartAliasing(FileName);
    FilenameAlias := GetNextAlias;
    while (FilenameAlias <> '') do
    begin
      AbsolutePathAndFilename := ExpandFileName(ConcatPaths([AbsolutePath, FilenameAlias]));
      if FileExists(AbsolutePathAndFilename) then
      begin
        Result:=ExactFileLink(AbsolutePathAndFilename, Nil, True);
        Result.Flags:=Result.Flags or ofWarnBeforeChange;
        GameFiles.Add(Result);
        GameFiles.Sort(ByFileName);
        Exit; { found it }
      end;
      FilenameAlias := GetNextAlias;
    end;

    //Steam filesystem access
    if SetupGameSet.Specifics.Values['Steam']='1' then
    begin
      SteamRunning := RunSteam;

      if not SteamRunning then
        Log(LOG_WARNING, 'Steam is not running. Unable to extract files from it.')
      else
      begin
        Setup:=SetupSubSet(ssGames, 'Steam');
        SteamCacheDir:=ConcatPaths([Setup.Specifics.Values['Directory'], Setup.Specifics.Values['CacheDirectory']]);
        RestartAliasing(FileName);
        FilenameAlias := GetNextAlias;
        while (FilenameAlias <> '') do
        begin
          if RunSteamExtractor(FilenameAlias) then
            if FileExists(ConcatPaths([SteamCacheDir, FilenameAlias])) then
            begin
              Result:=ExactFileLink(ConcatPaths([SteamCacheDir, FilenameAlias]), Nil, True);
              Result.Flags:=Result.Flags or ofWarnBeforeChange;
              GameFiles.Add(Result);
              GameFiles.Sort(ByFileName);
              Exit; { found it }
            end;

          FilenameAlias := GetNextAlias;
        end;
      end;
    end;

    //Pak file search (this includes GCF's)
    RestartAliasing(FileName);
    FilenameAlias := GetNextAlias;
    if SetupGameSet.Specifics.Values['Steam']='1' then
    begin
      Setup:=SetupSubSet(ssGames, 'Steam');
      if Setup.Specifics.Values['CacheGCF'] = '1' then
      begin
        PakRealFileName:=GetGCFFile(PakFileName);
        PakSearchPath:=ExtractFileDir(PakRealFileName);
        PakRealFileName:=ExtractFileName(PakRealFileName);
      end
      else
      begin
        PakSearchPath:=ConcatPaths([Setup.Specifics.Values['Directory'], Setup.Specifics.Values['ProgramDirectory']]);
        PakRealFileName:=PakFileName;
      end;
    end
    else
    begin
      PakRealFileName:=PakFileName;
      PakSearchPath:=AbsolutePath;
    end;
    GetPakNames:=TGetPakNames.Create;
    try
      GetPakNames.CreatePakList(PakSearchPath, PakRealFileName, True, False);
      while (FilenameAlias <> '') do
      begin
        GetPakNames.ResetIter(True);
        AbsolutePathAndFilename:=ExpandFileName(ConcatPaths([AbsolutePath, FilenameAlias]));
        while GetPakNames.GetNextPakName(True, AbsolutePathAndFilename, True) do
        begin
          if (not IsPakTemp(AbsolutePathAndFilename)) then  // ignores QuArK's own temporary pak's
          begin
            PakFile:=SortedFindFileName(GameFiles, AbsolutePathAndFilename);
            if (PakFile=Nil) then
            begin  // open the pak file if not already opened
              PakFile:=ExactFileLink(AbsolutePathAndFilename, Nil, True);
              PakFile.Flags:=PakFile.Flags or ofWarnBeforeChange;
              GameFiles.Add(PakFile);
              GameFiles.Sort(ByFileName);
            end;
            Result:=PakFile.FindFile(FilenameAlias);
            if (Result<>Nil) then
              Exit; // found it
          end;
        end;
        FilenameAlias := GetNextAlias;
      end;
    finally
      GetPakNames.Free;
    end;

    Inc(SearchStage);
    if (SearchStage = 1) then
    begin
      if LookInCD then
      begin
        AbsolutePath:=GetCDPath(BaseDir, FileName);
        if AbsolutePath='' then
          Inc(SearchStage);  //Skip stage 1, goto stage 2
      end
      else
        Inc(SearchStage);  //Skip stage 1, goto stage 2
    end;
    if (SearchStage = 2) then
    begin
      AbsolutePath:=CheckForRelativePath(BaseDir);
      if AbsolutePath='' then
        Inc(SearchStage);  //Skip stage 2, goto stage 3
    end;
  until SearchStage >= 3;
end;
{--Convex-end--}

{------------------------}

type
 TGammaBuffer = record
                 Factor: TDouble;
                 Map: array[0..255] of SmallInt;
                end;

function GetGammaValue: TDouble;
begin
 Result:=SetupSubSet(ssGeneral, 'Display').GetFloatSpec('Gamma', 11/8);
 if Result<1.0 then
   Result:=1.0
 else
   if Result>20.0 then
     Result:=20.0;
 Result:=1/Result;
end;

procedure InitGammaBuffer(var Buf: TGammaBuffer);
begin
 Buf.Factor:=GetGammaValue;
 FillChar(Buf.Map, SizeOf(Buf.Map), -1);
 Buf.Map[0]:=0;
end;

function Gamma(B: Byte; var Buf: TGammaBuffer) : Integer;
begin
 Result:=Buf.Map[B];
 if Result>=0 then
   Exit;
 Result:=Round(Exp(Ln(B*(1.0/255))*Buf.Factor)*255);
 Buf.Map[B]:=Result;
end;

function InitGeneralGammaBuffer(var Buf: TGeneralGammaBuffer; var FG: TDouble) : Boolean;
var
 FG1: TDouble;
 B: Integer;
begin
 FG1:=GetGammaValue;
 Result:=FG<>FG1;
 if Result then
  begin
   Buf[0]:=0;
   for B:=1 to 255 do
    Buf[B]:=Round(Exp(Ln(B*(1.0/255))*FG1)*255);
   FG:=FG1;
  end;
end;

procedure ColorsFromLmp(const Lmp: TPaletteLmp; var bmiColors: TBitmapInfoColors);
var
 I: Integer;
 FG: TGammaBuffer;
begin
 InitGammaBuffer(FG);
 for I:=0 to 255 do
  with bmiColors[I] do
   begin
    rgbRed:=Gamma(Lmp[I,0], FG);
    rgbGreen:=Gamma(Lmp[I,1], FG);
    rgbBlue:=Gamma(Lmp[I,2], FG);
    rgbReserved:=0;
   end;
end;

procedure ClearBmpInfo24(var BmpInfo: TBitmapInfo256);
begin
 FillChar(BmpInfo, SizeOf(TBitmapInfoHeader), 0);
 with BmpInfo.bmiHeader do
  begin
   biSize:=SizeOf(TBitmapInfoHeader);
   biPlanes:=1;
   biBitCount:=24;
  end;
end;

procedure PaletteFromLmp(const Lmp: TPaletteLmp; var BmpInfo: TBitmapInfo256;
           Palette, PaletteReelle: HPalettePtr);
var
 Log: PLogPalette;
 I: Integer;
 FG: TGammaBuffer;
begin
 FillChar(BmpInfo, SizeOf(TBitmapInfoHeader), 0);
 with BmpInfo.bmiHeader do
  begin
   biSize:=SizeOf(TBitmapInfoHeader);
   biPlanes:=1;
   biBitCount:=8;
  end;

 InitGammaBuffer(FG);

 GetMem(Log, SizeOf(TLogPalette)+255*SizeOf(TPaletteEntry));
 try
   Log^.palVersion:=$300;
   Log^.palNumEntries:=256;
   for I:=0 to 255 do
    with Log^.palPalEntry[I], BmpInfo.bmiColors[I] do
     begin
      peRed:=Gamma(Lmp[I,0], FG);     {lmp[i,0]:=pered;}
      rgbRed:=peRed;
      peGreen:=Gamma(Lmp[I,1], FG);   {lmp[i,1]:=pegreen;}
      rgbGreen:=peGreen;
      peBlue:=Gamma(Lmp[I,2], FG);    {lmp[i,2]:=peblue;}
      rgbBlue:=peBlue;
      peFlags:=0;
      rgbReserved:=0;
     end;
   if Assigned(Palette) then
    Palette^:=CreatePalette(Log^);
   if Assigned(PaletteReelle) then
    begin
     for I:=0 to 255 do
      with Log^.palPalEntry[I] do
       begin
        peRed:=Lmp[I,0];
        peGreen:=Lmp[I,1];
        peBlue:=Lmp[I,2];
       end;
     PaletteReelle^:=CreatePalette(Log^);
    end;
 finally
   FreeMem(Log);
 end;
end;

function GameBuffer(NeededGame: Char) : PGameBuffer;
const
 Start = Length('Data=');
var
 Lmp: TPaletteLmp;
 PaletteFile: QFileObject;
 S: String;
 I, J: Integer;
 L: TQList;
begin
 ChangeGameMode(NeededGame, True);
 if GameBuffer1=Nil then
 begin
   FillChar(Lmp, SizeOf(Lmp), 0);
   {PaletteFile:=Nil;}
   S:=SetupGameSet.Specifics.Values['Palette'];
   if S<>'' then
   begin
     if S[1]=':' then
     begin
       L:=GetQuakeContext;
       for J:=0 to L.Count-1 do
       begin
         S:=L[J].Specifics.Values['Palette'];
         if S<>'' then
         begin
           I:=Length(S);
           if I>SizeOf(Lmp) then
             I:=SizeOf(Lmp);
           Move(PChar(S)^, Lmp, I);
         end;
       end;
     end
     else
     begin
       PaletteFile:=NeedGameFile(S, '');
       PaletteFile.AddRef(+1);
       try
         PaletteFile.Acces;
         if PaletteFile is QImage then
         begin
           QImage(PaletteFile).NotTrueColor;
           QImage(PaletteFile).GetPalette1(Lmp);
         end
         else
         begin
           S:=PaletteFile.GetSpecArg('Data');
           I:=Length(S)-Start;
           if I<0 then
             I:=0
           else
           if I>SizeOf(Lmp) then
             I:=SizeOf(Lmp);
           Move(PChar(S)[Start], Lmp, I);
         end;
       finally
         PaletteFile.AddRef(-1);
       end;
     end;
   end;
   New(GameBuffer1);
   GameBuffer1^.RefCount:=1;
  {GameBuffer1^.AddOns:=Nil;}
   GameBuffer1^.GameName:=SetupGameSet.Name;
   GameBuffer1^.TextureExt:=SetupGameSet.Specifics.Values['TextureFormat'];
   GameBuffer1^.UnifiedPalette:={PaletteFile<>Nil}SetupGameSet.Specifics.Values['UnifiedPalette']<>'';
   GameBuffer1^.PaletteLmp:=Lmp;
   PaletteFromLmp(Lmp, GameBuffer1^.BitmapInfo, @GameBuffer1^.Palette, @GameBuffer1^.PaletteReelle);
 end;
 Result:=GameBuffer1;
end;

(*function MakeQuakeImageData(NeededGame: Char; DC: HDC; W,H, nW,nH: Integer; Format: TMQIDF) : String;
var
 Game: PGameBuffer;
 Dest, Bmp1: HBitmap;
 DestDC: HDC;
 Bits: PChar;
 nScan: Integer;
begin
 Game:=GameBuffer(NeededGame);
 with Game^.BmpInfo.bmiHeader do
  begin
   biWidth:=W;
   biHeight:=H;
  end;
 Dest:=CreateDIBSection(DC, Game^.BmpInfo,
  dib_RGB_Colors, Pointer(Bits), Nil, 0);
 try
  DestDC:=CreateCompatibleDC(DC);              ...BUGGY on some machines...
  Bmp1:=SelectObject(DestDC, Dest);
  BitBlt(DestDC, 0,0,W,H, DC,0,0, srcCopy);
  SelectObject(DestDC, Bmp1);
  DeleteDC(DestDC);

  if Format=dfWinFormat then
   nScan:=(nW+3) and not 3
  else
   nScan:=nW;
  SetLength(Result, nScan*nH);
  if Format<>dfTextureFormat then
   nScan:=-nScan;
  GdiFlush;
  Resample(Game^.BmpInfo.bmiColors, Bits, PChar(Result), W, H, -((W+3) and not 3), nW, nH, nScan);
 finally
  DeleteObject(Dest);
 end;
end;
(*var
 Game: PGameBuffer;
 Dest, Bmp1, Dest24: HBitmap;
 DestDC: HDC;
 Bits, Buffer24: PChar;
 BmpInfo24: TBitmapInfo;
 nScan: Integer;
begin
 Game:=GameBuffer(NeededGame);
 with Game^.BmpInfo.bmiHeader do
  begin
   biWidth:=W;
   biHeight:=H;
  end;
 FillChar(BmpInfo24, SizeOf(BmpInfo24), 0);
 with BmpInfo24.bmiHeader do
  begin
   biSize:=SizeOf(TBitmapInfoHeader);
   biWidth:=nW;
   biHeight:=nH;
   biPlanes:=1;
   biBitCount:=24;
  end;
 Dest24:=0; try
 Dest:=CreateDIBSection(DC, Game^.BmpInfo,
  dib_RGB_Colors, Pointer(Bits), Nil, 0);
 try
  DestDC:=CreateCompatibleDC(DC);
  Bmp1:=SelectObject(DestDC, Dest);
  BitBlt(DestDC, 0,0,W,H, DC,0,0, srcCopy);
  SelectObject(DestDC, Bmp1);
  DeleteDC(DestDC);

  Dest24:=CreateDIBSection(DC, BmpInfo24,
   dib_RGB_Colors, Pointer(Buffer24), Nil, 0);
  nScan:=(nW*3 + 3) and not 3;
  if Format<>dfTextureFormat then
   nScan:=-nScan;
  GdiFlush;
  Resample(Game^.BmpInfo.bmiColors, Bits, Buffer24, W, H, -((W+3) and not 3), nW, nH, nScan);
 finally
  DeleteObject(Dest);
 end;

 with Game^.BmpInfo.bmiHeader do
  begin
   biWidth:=nW;
   biHeight:=nH;
  end;
 if Format=dfWinFormat then
  nScan:=(nW+3) and not 3
 else
  nScan:=nW;
 SetLength(Result, nScan*nH);
 GetDIBits(DC, Dest24, 0, nH, PChar(Result),
  Game^.BmpInfo, dib_RGB_Colors);
 finally DeleteObject(Dest24); end;
end;*)
(*var
 DestDC, TempDC: HDC;
 ImageSize: Integer;
 Dest, Bmp1, Temp, Bmp2: HBitmap;
 Game: PGameBuffer;
 Bits: Pointer;
 Ok, FirstPass: Boolean;
 J: Integer;
 PSrc, PDest: PChar;
begin
 ProgressIndicatorStart(5448, 0); try
 Game:=GameBuffer(NeededGame);
 with Game^.BmpInfo.bmiHeader do
  begin
   biWidth:=nW;
   biHeight:=nH;
  end;
 Dest:=CreateDIBSection(DC, Game^.BmpInfo,
  dib_RGB_Colors, Bits, Nil, 0); try
 DestDC:=CreateCompatibleDC(DC);
 Bmp1:=SelectObject(DestDC, Dest);
 if (W=nW) and (H=nH) then
  Ok:=BitBlt(DestDC, 0,0,W,H, DC,0,0, srcCopy)
 else
  begin
   FirstPass:=True;
   SetStretchBltMode(DestDC, HALFTONE);
   repeat
    Ok:=StretchBlt(DestDC, 0,0, nW, nH, DC, 0,0,W,H, srcCopy);
    if not Ok then
     begin          { for some video drivers }
      TempDC:=CreateCompatibleDC(0);
      Temp:=CreateBitmap(W, H, 1, 24, Nil);
      Bmp2:=SelectObject(TempDC, Temp);
      Ok:=BitBlt(TempDC, 0,0,W,H, DC,0,0, srcCopy)
       and StretchBlt(DestDC, 0,0, nW, nH, TempDC, 0,0,W,H, srcCopy);
      SelectObject(TempDC, Bmp2);
      DeleteObject(Temp);
      DeleteDC(TempDC);
     end;
    if Ok or not FirstPass then Break;
    FirstPass:=False;
    SetStretchBltMode(DestDC, COLORONCOLOR);  { maybe this will work ? }
   until False;
   W:=nW;
   H:=nH;
  end;
 SelectObject(DestDC, Bmp1);
 DeleteDC(DestDC);
 if not Ok then
  Raise EErrorFmt(5537, [GetLastError, Dest, DestDC, Bmp1, W, H, nW, nH]);

 if Format=dfWinFormat then
  ImageSize:=((W+3) and not 3) * H
 else
  ImageSize:=W*H;
 SetLength(Result, ImageSize);
 GdiFlush;

 case Format of
  dfWinFormat: Move(Bits^, Result[1], ImageSize);
  dfTextureFormat:
    begin  { must remove the 4-bytes alignment and bottom-up swap made by Windows }
     PSrc:=PChar(Bits);
     PDest:=PChar(Result)+ImageSize;
     for J:=1 to H do
      begin
       Dec(PDest, W);
       Move(PSrc^, PDest^, W);
       Inc(PSrc, (W+3) and not 3);
      end;
    end;
  dfBottomUpTexture:
    begin  { remove the 4-bytes alignment only }
     PSrc:=PChar(Bits);
     PDest:=PChar(Result);
     for J:=1 to H do
      begin
       Move(PSrc^, PDest^, W);
       Inc(PSrc, (W+3) and not 3);
       Inc(PDest, W);
      end;
    end;
 end;

 finally DeleteObject(Dest); end;
 finally ProgressIndicatorStop; end;
end;*)

function GetQPaletteColor(const BitmapInfo: TBitmapInfo256; I: Integer) : TColorRef;
begin
 with BitmapInfo.bmiColors[I] do
  Result:=rgbRed or (rgbGreen shl 8) or (rgbBlue shl 16);
end;

function ColorIsLight(C: TColorRef) : Boolean;
var
 C1: array[1..3] of Byte absolute C;
begin
 Result:=3*C1[1] + 6*C1[2] + C1[3] > $500;
end;

const
 cDOSFilenameValidChars = ['a'..'z', 'A'..'Z', '0'..'9', '.',
  '$', '%', '''', '-', '_', '@', '{', '}', '~', '`', '!', '#', '(', ')'];

procedure BuildCorrectFileName(var S: String);
var
 I: Integer;
begin
 for I:=Length(S) downto 1 do
 begin
   if not (S[I] in cDOSFilenameValidChars) then
     System.Delete(S, I, 1);
 end;
 if S='' then
   S:=LoadStr1(180);
end;

 {------------------------}

procedure DisplayAddOnsList(ListView1: TListView);
var
 L: TStringList;
 I: Integer;
 Q, AddOns: QObject;
begin
 AddOns:=MakeAddonsList;
 try
   L:=TStringList.Create;
   try
     L.Text:=SetupGameSet.Specifics.Values['AddOns'];
     for I:=0 to L.Count-1 do
      with ListView1.Items.Add do
       begin
        Caption:=L[I];
        Q:=AddOns.SubElements.FindName(L[I]);
        ImageIndex:=LoadGlobalImageList(Q);
        if Q<>Nil then
         begin
          Q.Acces;
          SubItems.Add(Q.Specifics.Values['Description']);
         end;
       end;
   finally
     L.Free;
   end;
 finally
   AddOns.AddRef(-1);
 end;
end;


procedure ClearAllFilesRec(const Rep: String);
var
 S: TSearchRec;
 SousRep: TStringList;
 I: Integer;
 Remove: String;
begin
  SousRep:=TStringList.Create;
  try
    if FindFirst(ConcatPaths([Rep, '*.*']), faAnyFile, S) = 0 then
    begin
      repeat
        if S.Attr and faDirectory = 0 then
          DeleteFile(ConcatPaths([Rep, S.Name]))
        else
          if (S.Name<>'.') and (S.Name<>'..') then
            SousRep.Add(S.Name);
      until FindNext(S)<>0;
    end;
    FindClose(S);
    for I:=0 to SousRep.Count-1 do
      ClearAllFilesRec(ConcatPaths([Rep, SousRep[I]]));
  finally
    SousRep.Free;
  end;
  Remove:=Rep;
  if Remove<>'' then
  begin
    if Remove[Length(Remove)]=PathDelim then
      SetLength(Remove, Length(Remove)-1);
    {$I-}
    RmDir(Remove);
    {$I+}
    IOResult;
  end;
end;

function CheckQuakeDir : Boolean;
var
  CheckFile: String;
  CheckDir, S2: String;
  TryingToFind: String;
  F: Boolean;
begin
  CheckDir:=SetupGameSet.Specifics.Values['CheckDirectory'];
{Decker - If no value in CheckDirectory, then accept any directory}
  if CheckDir='' then
  begin
    Result:=true;
    Exit;
  end;
{/Decker}
  if pos(#$D, CheckDir) <> 0 then
  begin
    Result:=false;
    S2:=CheckDir;
    while (pos(#$D, S2) <> 0) do
    begin
      CheckFile:=ConcatPaths([QuakeDir, Copy(S2, 1, pos(#$D, S2)-1)]);
      F:=FileExists(CheckFile);
      Result:=Result or F;
      if not F then TryingToFind:=TryingToFind+Copy(S2, 1, pos(#$D, S2)-1)+', or ';
      Delete(S2, 1, pos(#$D, S2));
    end;
    Delete(TryingToFind, Length(TryingToFind)-4, 5);
  end
  else if pos(#$A, CheckDir) <> 0 then
  begin
    Result:=true;
    S2:=CheckDir;
    while (pos(#$A, S2) <> 0) do
    begin
      CheckFile:=ConcatPaths([QuakeDir, Copy(S2, 1, pos(#$A, S2)-1)]);
      F:=FileExists(CheckFile);
      Result:=Result and F;
      if not F then TryingToFind:=TryingToFind+Copy(S2, 1, pos(#$A, S2)-1)+', and ';
      Delete(S2, 1, pos(#$A, S2));
    end;
    Delete(TryingToFind, Length(TryingToFind)-5, 6);
  end
  else
  begin
    Result:=FileExists(ConcatPaths([QuakeDir, CheckDir]));
    TryingToFind:=CheckDir;
  end;

//  Result:=FileExists(CheckFile);
  if not Result then
  begin
    case MessageDlg(FmtLoadStr1(5627, [SetupGameSet.Name, TryingToFind]),
                    mtConfirmation, [mbOk, mbCancel, mbIgnore], 0) of
      mrOk: begin
           {ShowConfigDlg('Games:'+SetupGameSet.Name);}
              ShowConfigDlg(':');
              Abort;
           end;
      mrIgnore:
            ;
    else
      Abort;
    end;
  end;
end;

function GameMapPath : String;
var
  TMPQuArK: string;
  I: Integer;
begin
  Result:=SetupGameSet.Specifics.Values['MapPath'];
  if Result='' then
    Result:='maps';
  if (GetSteamCompiler = 'source2009') then
  begin
    TMPQuArK:=ConvertPath(GetSteamtmpQuArK);
    I:=LastPos(PathDelim, TMPQuArK);
    if I <> 0 then
      Result:=ConcatPaths([Copy(TMPQuArK, I+1, MaxInt), Result]);
  end;
end;

function GameModelPath : String;
begin
  Result:=SetupGameSet.Specifics.Values['MdlPath'];
  if Result='' then
    Result:='models';
end;

function GameShaderList : String;
begin
  Result:=SetupGameSet.Specifics.Values['ShaderList'];
  if Result='' then
    Result:=ConcatPaths([GameShadersPath, 'shaderlist.txt']);
end;

function SteamAppID : String;
var
  S: String;
begin
  Result := SetupGameSet.Specifics.Values['SteamAppID'];
  if Result = '*auto*' then
  begin
    S := SetupGameSet.Specifics.Values['SteamGame'];
    if S = 'HL2' then
      Result := '220'
    else if S = 'CSS' then
      Result := '240'
    else if S = 'HL:S' then
      Result := '280'
    else if S = 'HL2:DM' then
      Result := '320'
    else if S = 'HL2:LC' then
      Result := '340'
    else if S = 'HL:DM:S' then
      Result := '360'
    else if S = 'HL2:EP1' then
      Result := '380'
    else if S = 'Portal' then
      Result := '400'
    else if S = 'HL2:EP2' then
      Result := '420'
    else if S = 'TF2' then
      Result := '440'
    else
    begin
      //Shouldn't happen!
      Log(LOG_WARNING, 'SourceSDKDir: Unknown SteamGame value!');
      Result := '';
    end;
  end;
end;

function GetSteamtmpQuArK : String;
var
  S: String;
begin
  Result := SetupGameSet.Specifics.Values['tmpQuArK'];
  if Result = '*auto*' then
  begin
    S := SetupGameSet.Specifics.Values['SteamGame'];
    if S = 'HL2' then
      Result := 'SteamApps\%steamuser%\half-life 2\hl2'
    else if S = 'CSS' then
      Result := 'SteamApps\%steamuser%\counter-strike source\cstrike'
    else if S = 'HL:S' then
      Result := 'SteamApps\%steamuser%\half-life source\hl1'
    else if S = 'HL2:DM' then
      Result := 'SteamApps\%steamuser%\half-life 2 deathmatch\hl2mp'
    else if S = 'HL2:LC' then
      Result := 'SteamApps\%steamuser%\half-life 2 lostcoast\lostcoast'
    else if S = 'HL:DM:S' then
      Result := 'SteamApps\%steamuser%\half-life deathmatch source\hl1mp'
    else if S = 'HL2:EP1' then
      Result := 'SteamApps\%steamuser%\half-life 2 episode one\episodic'
    else if S = 'Portal' then
      Result := 'SteamApps\%steamuser%\portal\portal'
    else if S = 'HL2:EP2' then
      Result := 'SteamApps\%steamuser%\half-life 2 episode two\ep2'
    else if S = 'TF2' then
      Result := 'SteamApps\%steamuser%\team fortress 2\tf'
    else
    begin
      //Shouldn't happen!
      Log(LOG_WARNING, 'GetSteamtmpQuArK: Unknown SteamGame value!');
      Result := '';
    end;
  end;
end;

function GetSteamBaseDir : String;
var
  S: String;
begin
  Result := SetupGameSet.Specifics.Values['BaseDir'];
  if Result = '*auto*' then
  begin
    S := SetupGameSet.Specifics.Values['SteamGame'];
    if S = 'HL2' then
      Result := 'hl2'
    else if S = 'CSS' then
      Result := 'cstrike'
    else if S = 'HL:S' then
      Result := 'hl1'
    else if S = 'HL2:DM' then
      Result := 'hl2mp'
    else if S = 'HL2:LC' then
      Result := 'lostcoast'
    else if S = 'HL:DM:S' then
      Result := 'hl1mp'
    else if S = 'HL2:EP1' then
      Result := 'episodic'
    else if S = 'Portal' then
      Result := 'portal'
    else if S = 'HL2:EP2' then
      Result := 'ep2'
    else if S = 'TF2' then
      Result := 'tf'
    else
    begin
      //Shouldn't happen!
      Log(LOG_WARNING, 'GetSteamBaseDir: Unknown SteamGame value!');
      Result := '';
    end;
  end;
end;

function SourceSDKDir : String;
var
  S: String;
begin
  Result := SetupGameSet.Specifics.Values['SourceSDKDir'];
  if Result = '*auto*' then
  begin
    S := GetSteamCompiler;
    if S = 'old' then
      Result := 'sourcesdk\bin'
    else if S = 'source2006' then
      Result := 'sourcesdk\bin\ep1\bin'
    else if S = 'source2007' then
      Result := 'sourcesdk\bin\source2007\bin'
    else if S = 'source2009' then
      Result := 'sourcesdk\bin\orangebox\bin'
    else
    begin
      //Shouldn't happen!
      Log(LOG_WARNING, 'SourceSDKDir: Unknown SteamGame value!');
      Result := '';
    end;
  end;
end;

function GetSteamCompiler : String;
var
  S: String;
begin
  Result := SetupGameSet.Specifics.Values['Compiler'];
  if Result = '*auto*' then
  begin
    S := SetupGameSet.Specifics.Values['SteamGame'];
    if S = 'HL2' then
      Result := 'source2009'
    else if S = 'CSS' then
      Result := 'source2009'
    else if S = 'HL:S' then
      Result := 'source2006'
    else if S = 'HL2:DM' then
      Result := 'source2006'
    else if S = 'HL2:LC' then
      Result := 'source2006'
    else if S = 'HL:DM:S' then
      Result := 'source2006'
    else if S = 'HL2:EP1' then
      Result := 'source2009'
    else if S = 'Portal' then
      Result := 'source2009'
    else if S = 'HL2:EP2' then
      Result := 'source2009'
    else if S = 'TF2' then
      Result := 'source2009'
    else
    begin
      //Shouldn't happen!
      Log(LOG_WARNING, 'Compiler: Unknown SteamGame value!');
      Result := '';
    end;
  end;
end;

 {------------------------}

procedure GameCfgDlg;
var
  ResultButton: TModalResult;
begin
  with TGameCfgDlg.Create(Application) do
  begin
    try
      ResultButton:=ShowModal;
    finally
      Free;
    end;
  end;

  if ResultButton=mrOk then
    UpdateSetup(scAddOns);
end;

procedure TGameCfgDlg.FormCreate(Sender: TObject);
begin
  MarsCap.ActiveBeginColor:=clMaroon;
  UpdateMarsCap;
  OpenGlobalImageList(ListView1);
  Label1.Caption:=Format(Label1.Caption, [SetupGameSet.Name]);
  DisplayAddOnsList(ListView1);
end;

procedure TGameCfgDlg.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  BtnRemove.Enabled:=(ListView1.Selected<>Nil) and (ListView1.Selected.Index>0);
end;

procedure TGameCfgDlg.BtnAddClick(Sender: TObject);
begin
  with TAddOnsAddDlg.Create(Application) do
  try
    SrcListView:=Self.ListView1;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TGameCfgDlg.BtnRemoveClick(Sender: TObject);
begin
  ListView1.Selected.Delete;
  ListView1.Tag:=1;
end;

procedure TGameCfgDlg.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TGameCfgDlg.OkBtnClick(Sender: TObject);
var
  I: Integer;
  L: TStringList;
  S: String;
begin
  if ListView1.Tag<>0 then
  begin
    L:=TStringList.Create;
    try
      for I:=0 to ListView1.Items.Count-1 do
        L.Add(ListView1.Items[I].Caption);
      S:=StringListConcatWithSeparator(L, $0D);
    finally
      L.Free;
    end;
    SetupGameSet.Specifics.Values['AddOns']:=S;
    ModalResult:=mrOk;
  end
  else
    ModalResult:=mrCancel;
end;

procedure TGameCfgDlg.FormDestroy(Sender: TObject);
begin
  CloseGlobalImageList(ListView1);
end;

initialization

finalization
  ClearGBList;
end.
