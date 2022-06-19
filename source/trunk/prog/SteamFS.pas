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
unit SteamFS;

interface

uses Windows, Classes;

function RunSteam: Boolean;
function RunSteamExtractor(const Filename : String) : Boolean;
function GetSteamCacheDir : String;

 {------------------------}

implementation

uses ShellAPI, SysUtils, StrUtils, Quarkx, Game, Setup, Logging, SystemDetails,
     QkObjects, ExtraFunctionality, QkApplPaths, QkExceptions, QkFileObjects;

const
  QSASDelay: DWORD = 30000; //How long (in ms) to wait for QSAS to run

var
  CheckQuArKSAS: Boolean = true;

//FIXME: Not used anymore... More somewhere else? CONST certain parameters?
function DoFileOperation(Operation: Word; FilesFrom: TStringList; FilesTo: TStringList; FileOpFlags: Word): Boolean;

  procedure ParseFiles(Files: TStringList; Target: Pointer);
  var
    Dest: PChar;
    I: Integer;
  begin
    Dest:=Target;
    for I:=0 to Files.Count-1 do
    begin
      StrPCopy(Dest, Files[I]);
      Inc(Dest, Length(Files[I])+1);
    end;
  end;

var
  PFilesFrom, PFilesTo: Pointer;
  FileOp: TSHFileOpStruct;
  FilesFromCharLength: Integer;
  FilesToCharLength: Integer;
  I: Integer;
begin
  try
    if (FilesFrom<>nil) and (FilesFrom.Count > 0) then
    begin
      FilesFromCharLength := 1;
      for I:=0 to FilesFrom.Count-1 do
        FilesFromCharLength := FilesFromCharLength + Length(FilesFrom[I]) + 1;
      GetMem(PFilesFrom, FilesFromCharLength+1);
      ZeroMemory(PFilesFrom, FilesFromCharLength+1);
      ParseFiles(FilesFrom, PFilesFrom);
    end
    else
      PFilesFrom := nil;
    if (FilesTo<>nil) and (FilesTo.Count > 0) then
    begin
      FilesToCharLength := 1;
      for I:=0 to FilesTo.Count-1 do
        FilesToCharLength := FilesToCharLength + Length(FilesTo[I]) + 1;
      GetMem(PFilesTo, FilesToCharLength+1);
      ZeroMemory(PFilesTo, FilesToCharLength+1);
      ParseFiles(FilesTo, PFilesTo);
    end
    else
       PFilesTo := nil;
    FillChar(FileOp, SizeOf(FileOp), 0);
    FileOp.wFunc := Operation;
    FileOp.pFrom := PFilesFrom;
    FileOp.pTo := PFilesTo;
    FileOp.fFlags := FileOpFlags;
    if SHFileOperation(FileOp) <> 0 then
    begin
      if FileOp.fAnyOperationsAborted = false then
        Log(LOG_WARNING, 'Warning: User aborted file operation!');
      Result:=false;
    end
    else
    begin
      Log(LOG_WARNING, 'Warning: File operation failed!');
      Result:=false;
    end;
  finally
    if PFilesTo <> nil then
      FreeMem(PFilesTo);
    if PFilesFrom <> nil then
      FreeMem(PFilesFrom);
  end;
end;

function GetSteamCacheDir : String;
begin
  Result := ConcatPaths([ExtractFilePath(MakeTempFileName('QuArKSAS')), 'QuArKSAS']);
end;

function RunSteam: Boolean;
var
  Setup: QObject;
  SteamEXEFullPath: String;
  SteamStartupInfo: StartUpInfo;
  SteamProcessInformation: Process_Information;
begin
  Setup := SetupSubSet(ssGames, 'Steam');
  SteamEXEFullPath := ConcatPaths([QuickResolveFilename(Setup.Specifics.Values['Directory']), Setup.Specifics.Values['SteamEXEName']]);
  Result := ProcessExists(SteamEXEFullPath);
  if (not Result) and (Setup.Specifics.Values['Autostart']='1') then
  begin
    FillChar(SteamStartupInfo, SizeOf(SteamStartupInfo), 0);
    FillChar(SteamProcessInformation, SizeOf(SteamProcessInformation), 0);
    SteamStartupInfo.cb:=SizeOf(SteamStartupInfo);
    if Windows.CreateProcess(nil, PChar(SteamEXEFullPath), nil, nil, false, 0, nil, nil, SteamStartupInfo, SteamProcessInformation)=false then
    begin
      LogWindowsError(GetLastError(), 'CreateProcess(Steam)');
      Exit;
    end;
    CloseHandle(SteamProcessInformation.hThread);
    WaitForInputIdle(SteamProcessInformation.hProcess, INFINITE);
    CloseHandle(SteamProcessInformation.hProcess);
    Result := true;
  end;
end;

//This function uses QuArKSAS to extract files from Steam
function RunSteamExtractor(const Filename : String) : Boolean;
var
  Setup: QObject;
  SteamCompiler: String;
  GameIDDir: String;
  FullFilename: String;
  TmpDirectory: String;
  QuArKSASEXE: String;
  QSASFile, QSASPath, QSASParameters: String;
  QSASAdditionalParameters: String;
  QSASStartupInfo: StartUpInfo;
  QSASProcessInformation: Process_Information;
  I: Integer;
begin
  Result:=False;

  Setup:=SetupSubSet(ssGames, 'Steam');

  if not (Setup.Specifics.Values['UseQuArKSAS'] <> '') then
  begin
    //Don't use QuArKSAS
    Exit;
  end;

  QSASAdditionalParameters:=Setup.Specifics.Values['ExtractorParameters'];

  SteamCompiler:=GetSteamCompiler;
  if (SteamCompiler = 'old') or (SteamCompiler = 'source2006') then
  begin
    if (SteamCompiler = 'old') then
      QuArKSASEXE := Setup.Specifics.Values['QuArKSASEXENameOld']
    else
      QuArKSASEXE := Setup.Specifics.Values['QuArKSASEXENameSource2006'];
    FullFilename := ConvertPath(FileName);
    I := Pos(PathDelim, FullFilename);
    if (I > 0) then
    begin
      GameIDDir := LeftStr(FullFilename, I-1);
      FullFileName := RightStr(FullFilename, Length(FullFilename) - I);
    end
    else
    begin
      GameIDDir := '';
      FullFileName := Filename;
    end;
  end
  else if (SteamCompiler = 'source2007') then
  begin
    QuArKSASEXE := Setup.Specifics.Values['QuArKSASEXENameSource2007'];
    GameIDDir := '';
    FullFileName := FileName;
  end
  else if (SteamCompiler = 'source2009') then
  begin
    QuArKSASEXE := Setup.Specifics.Values['QuArKSASEXENameSource2009'];
    GameIDDir := '';
    FullFileName := FileName;
  end
  else //Includes orangebox and maybe Source2013
  begin
    QuArKSASEXE := Setup.Specifics.Values['QuArKSASEXENameOrangebox'];
    GameIDDir := '';
    FullFileName := FileName;
  end;

  if QuArKSASEXE='' then
  begin
    Log(LOG_WARNING, 'No QuArKSAS executable name found; defaulting to QuArKSAS.exe.');
    QuArKSASEXE:='QuArKSAS.exe';
  end;

  //Copy QSAS if it's not in the Steam directory yet
  QSASPath := QuickResolveFilename(SourceSDKDir);
  QSASFile := ConcatPaths([QSASPath, QuArKSASEXE]);
  if CheckQuArKSAS then
  begin

    //FIXME: First check if the Steam path exists at all!

    if FileExists(ConcatPaths([GetQPath(pQuArKDll), QuArKSASEXE])) = false then
      LogAndRaiseError('Unable to extract file from Steam. dlls/'+QuArKSASEXE+' not found.'); //FIXME: Move to dict!
    if FileExists(QSASFile) = false then
    begin
      if CopyFile(PChar(ConcatPaths([GetQPath(pQuArKDll), QuArKSASEXE])), PChar(QSASFile), true) = false then
        LogAndRaiseError('Unable to extract file from Steam. Call to CopyFile failed.');
    end;

    //Make sure its the same version
    if CompareFiles(ConcatPaths([GetQPath(pQuArKDll), QuArKSASEXE]), QSASFile) then
    begin
      //Files do not match. The one in dlls is probably the most current one,
      //so let's update the Steam one.
      if CopyFile(PChar(ConcatPaths([GetQPath(pQuArKDll), QuArKSASEXE])), PChar(QSASFile), false) = false then
        LogAndRaiseError('Unable to extract file from Steam. Call to CopyFile failed.');
    end;

    CheckQuArKSAS:=false;
  end;

  TmpDirectory:=GetSteamCacheDir;
  if DirectoryExists(TmpDirectory) = false then
    if CreateDir(TmpDirectory) = false then
      LogAndRaiseError('Unable to extract file from Steam. Cannot create cache directory.');

  //No trailing slashes in paths allowed for QuArKSAS!
  QSASParameters:='-g '+SteamAppID+' -gamedir "'+RemoveTrailingSlash(GetSteamBaseDir)+'" -o "'+TmpDirectory+'" -overwrite';
  if Length(QSASAdditionalParameters)<>0 then
    QSASParameters:=QSASParameters+' '+QSASAdditionalParameters;

  Log(LOG_VERBOSE, 'Now calling: '+QSASFile + ' ' + QSASParameters + ' ' + FullFilename);

  FillChar(QSASStartupInfo, SizeOf(QSASStartupInfo), 0);
  FillChar(QSASProcessInformation, SizeOf(QSASProcessInformation), 0);
  QSASStartupInfo.cb:=SizeOf(QSASStartupInfo);
  QSASStartupInfo.dwFlags:=STARTF_USESHOWWINDOW;
  QSASStartupInfo.wShowWindow:=SW_SHOWMINNOACTIVE;
  if Windows.CreateProcess(nil, PChar(QSASFile + ' ' + QSASParameters + ' ' + FullFilename), nil, nil, false, 0, nil, PChar(QSASPath), QSASStartupInfo, QSASProcessInformation)=false then
    LogAndRaiseError('Unable to extract file from Steam. Call to CreateProcess failed.');
  try
    CloseHandle(QSASProcessInformation.hThread);

    //DanielPharos: Waiting for INFINITE is rather dangerous, so let's wait only a certain amount of seconds
    if WaitForSingleObject(QSASProcessInformation.hProcess, QSASDelay)=WAIT_FAILED then
      LogAndRaiseError('Unable to extract file from Steam. Call to WaitForSingleObject failed.');
  finally
    CloseHandle(QSASProcessInformation.hProcess);
  end;
  Result:=True;
end;

end.

