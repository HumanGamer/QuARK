(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor - QkSteamFS.pas access steam filesystem
Copyright (C) Alexander Haarer

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
Revision 1.21  2007/08/17 10:33:41  danielpharos
Fix an access violation.

Revision 1.20  2007/08/15 22:34:14  danielpharos
Simplified the DoFileOperation call.

Revision 1.19  2007/08/15 22:18:57  danielpharos
Forgot to uncomment a single line :|

Revision 1.18  2007/08/15 16:28:08  danielpharos
HUGE update to HL2: Took out some code that's now not needed anymore.

Revision 1.17  2007/08/14 16:32:59  danielpharos
HUGE update to HL2: Loading files from Steam should work again, now using the new QuArKSAS utility!

Revision 1.16  2007/03/13 18:59:25  danielpharos
Changed the interface to the Steam dll-files. Should prevent QuArK from crashing on HL2 files.

Revision 1.15  2007/03/11 12:03:10  danielpharos
Big changes to Logging. Simplified the entire thing.

Revision 1.14  2007/02/02 10:07:07  danielpharos
Fixed a problem with the dll loading not loading tier0 correctly

Revision 1.13  2007/02/02 00:51:02  danielpharos
The tier0 and vstdlib dll files for HL2 can now be pointed to using the configuration, so you don't need to copy them to the local QuArK directory anymore!

Revision 1.12  2007/02/01 23:13:53  danielpharos
Fixed a few copyright headers

Revision 1.11  2007/01/31 15:05:20  danielpharos
Unload unused dlls to prevent handle leaks. Also fixed multiple loading of certain dlls

Revision 1.10  2007/01/11 17:45:37  danielpharos
Fixed wrong return checks for LoadLibrary, and commented out the fatal ExitProcess call. QuArK should no longer crash-to-desktop when it's missing a Steam dll file.

Revision 1.9  2005/09/28 10:48:32  peter-b
Revert removal of Log and Header keywords

Revision 1.7  2005/07/31 12:12:28  alexander
add logging, remove some dead code

Revision 1.6  2005/07/05 19:12:48  alexander
logging to file using loglevels

Revision 1.5  2005/07/04 18:53:20  alexander
changed steam acces to be a protocol steamaccess://

Revision 1.4  2005/01/05 15:57:53  alexander
late dll initialization on LoadFile method
dependent dlls are checked before
made dll loading errors or api mismatch errors fatal because there is no means of recovery

Revision 1.3  2005/01/04 17:26:09  alexander
steam environment configuration added

Revision 1.2  2005/01/02 16:44:52  alexander
use setup value for file system module

Revision 1.1  2005/01/02 15:19:27  alexander
access files via steam service - first


}

unit QkSteamFS;

interface

uses Windows, Classes;

function GetGCFFile(const Filename : String) : String;
function RunSteam: Boolean;
function RunSteamExtractor(const Filename : String) : Boolean;
procedure ClearSteamCache;

 {------------------------}

implementation

uses ShellAPI, SysUtils, StrUtils, Quarkx, Setup, Logging, SystemDetails, ExtraFunctionality, QkObjects;

var
  ClearCacheNeeded: Boolean;

procedure Fatal(x:string);
begin
  Log(LOG_CRITICAL,'Error during operation on DDS file: %s',[x]);
  Windows.MessageBox(0, pchar(X), PChar(LoadStr1(401)), MB_TASKMODAL or MB_ICONERROR or MB_OK);
  Raise Exception.Create(x);
end;

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
  if PFilesTo <> nil then
    FreeMem(PFilesTo);
  if PFilesFrom <> nil then
    FreeMem(PFilesFrom);
end;

function GetGCFFile(const Filename : String) : String;
var
  Setup: QObject;
  SteamDirectory: String;
  CacheDirectory: String;
  FullFileName: String;
  SteamGCFFile: String;
  FilesToCopyFrom: TStringList;
  FilesToCopyTo: TStringList;
  FilesToCopyFlags: Word;
begin
  Setup:=SetupSubSet(ssGames, 'Steam');
  SteamDirectory:=IncludeTrailingPathDelimiter(Setup.Specifics.Values['Directory']);
  CacheDirectory:=IncludeTrailingPathDelimiter(Setup.Specifics.Values['CacheDirectory']);
  FullFileName:=SteamDirectory + CacheDirectory + FileName;
  if FileExists(FullFileName)=false then
  begin
    //Try to copy original file...
    ClearCacheNeeded:=true;

    SteamGCFFile:=SteamDirectory+'steamapps\'+Filename;
    if FileExists(SteamGCFFile) = false then
    begin
      Result:='';
      Exit;
    end;
    if Setup.Specifics.Values['CopyGCF'] = '1' then
    begin
      if DirectoryExists(SteamDirectory+CacheDirectory) = false then
        if CreateDir(SteamDirectory+CacheDirectory) = false then
          Fatal('Unable to extract file from Steam. Cannot create cache directory.');

      FilesToCopyFrom:=TStringList.Create;
      FilesToCopyFrom.Add(SteamGCFFile);
      FilesToCopyTo:=TStringList.Create;
      FilesToCopyTo.Add(FullFileName);
      FilesToCopyFlags:=0;
      if DoFileOperation(FO_COPY, FilesToCopyFrom, FilesToCopyTo, FilesToCopyFlags) = false then
      begin
        Log(LOG_WARNING, 'Unable to copy GCF file to cache: CopyFile failed!');
        Result:=SteamGCFFile;
        FilesToCopyFrom.Free;
        FilesToCopyTo.Free;
        Exit;
      end;
      FilesToCopyFrom.Free;
      FilesToCopyTo.Free;
    end
    else
    begin
      Result:=SteamGCFFile;
      Exit;
    end;
  end;
  Result:=FullFileName;
end;

function RunSteam: Boolean;
var
  Setup: QObject;
  SteamDirectory: String;
  SteamStartupInfo: StartUpInfo;
  SteamProcessInformation: Process_Information;
  SteamWindowName: String;
  WaitForSteam: Boolean;
  I: Integer;
begin
  Setup := SetupSubSet(ssGames, 'Steam');
  WaitForSteam := False;
  Result := ProcessExists('steam.exe');
  if (not Result) and (Setup.Specifics.Values['Autostart']='1') then
  begin
    FillChar(SteamStartupInfo, SizeOf(SteamStartupInfo), 0);
    FillChar(SteamProcessInformation, SizeOf(SteamProcessInformation), 0);
    SteamStartupInfo.cb:=SizeOf(SteamStartupInfo);
    SteamDirectory:=IncludeTrailingPathDelimiter(Setup.Specifics.Values['Directory']);
    if Windows.CreateProcess(nil, PChar(SteamDirectory+'steam.exe'), nil, nil, false, 0, nil, nil, SteamStartupInfo, SteamProcessInformation)=true then
    begin
      CloseHandle(SteamProcessInformation.hThread);
      CloseHandle(SteamProcessInformation.hProcess);
      Result := true;
      WaitForSteam := true;
      SteamWindowName := 'STEAM - '+Setup.Specifics.Values['SteamUser'];
    end;
  end;
  I:=0;
  while WaitForSteam do
  begin
    Sleep(200);  //Let's give the system a little bit of time to boot Steam...
    WaitForSteam:=not WindowExists(SteamWindowName);
    if I>50 then
    begin
      //We've been waiting for 10 SECONDS! Let's assume something went terribly wrong...!
      if MessageBox(0, PChar('10 Seconds have passed, and QuArk cannot detect Steam as having started up... Please start it manually now (if it has not yet done so) and press YES. Otherwise, press NO.'), PChar('QuArK'), MB_YESNO) = IDNO then
      begin
        Result:=False;
        WaitForSteam:=False;
      end;
    end
    else
      I:=I+1;
  end;
end;

function RunSteamExtractor(const Filename : String) : Boolean;
var
  Setup: QObject;
  SteamDirectory: String;
  SteamGameDirectory: String;
  SteamCacheDirectory: String;
  SteamUser: String;
  SteamAppID: String;
  GameIDDir: String;
  FullFileName: String;
  QSASFile, QSASPath, QSASParameters: String;
  QSASAdditionalParameters: String;
  QSASStartupInfo: StartUpInfo;
  QSASProcessInformation: Process_Information;
  I, J: Integer;
begin
  //This function uses QuArKSAS to extract files from Steam
  ClearCacheNeeded:=true;
  
  I := Pos('\', Filename);
  J := Pos('/', Filename);
  if ((I > 0) and (I < J)) then
  begin
    GameIDDir := LeftStr(Filename, I-1);
    FullFileName := RightStr(Filename, Length(Filename) - I);
  end
  else
  begin
    if (J > 0) then
    begin
      GameIDDir := LeftStr(Filename, J-1);
      FullFileName := RightStr(Filename, Length(Filename) - J);
    end
    else
      FullFileName := Filename;
  end;

  Setup:=SetupSubSet(ssGames, 'Steam');
  SteamDirectory:=IncludeTrailingPathDelimiter(Setup.Specifics.Values['Directory']);
  SteamUser:=Setup.Specifics.Values['SteamUser'];
  SteamAppID:=SetupGameSet.Specifics.Values['SteamAppID'];
  SteamGameDirectory:=SetupGameSet.Specifics.Values['tmpQuArK'];
  SteamCacheDirectory:=Setup.Specifics.Values['CacheDirectory'];
  QSASAdditionalParameters:=Setup.Specifics.Values['ExtractorParameters'];
  if QSASAdditionalParameters<>'' then
    QSASAdditionalParameters:=' '+QSASAdditionalParameters;

  //Copy QSAS if it's not in the Steam directory yet
  QSASPath := SteamDirectory + 'steamapps\' + SteamUser + '\sourcesdk\bin';
  QSASFile := QSASPath + '\QuArKSAS.exe';

  if DirectoryExists(SteamDirectory) = false then
    Fatal('Unable to extract file from Steam. Cannot find Steam directory.');

  if DirectoryExists(SteamDirectory+SteamCacheDirectory) = false then
    if CreateDir(SteamDirectory+SteamCacheDirectory) = false then
      Fatal('Unable to extract file from Steam. Cannot create cache directory.');

  if DirectoryExists(SteamDirectory+'QuArKApps\'+GameIDDir) = false then
    if CreateDir(SteamDirectory+'QuArKApps\'+GameIDDir) = false then
      Fatal('Unable to extract file from Steam. Cannot create cache directory.');

  if FileExists(QSASFile) = false then
  begin
    if FileExists('dlls/QuArKSAS.exe') = false then
    begin
      Fatal('Unable to extract file from Steam. dlls/QuArKSAS.exe not found!');
    end;

    if CopyFile(PChar('dlls/QuArKSAS.exe'), PChar(QSASFile), true) = false then
    begin
      Fatal('Unable to extract file from Steam. Call to CopyFile failed.');
    end;
  end;

  QSASParameters:='-g '+SteamAppID+' -gamedir "'+SteamDirectory+SteamGameDirectory+'" -o "'+SteamDirectory+SteamCacheDirectory+'\'+GameIDDir+'" -overwrite' + QSASAdditionalParameters;

  FillChar(QSASStartupInfo, SizeOf(QSASStartupInfo), 0);
  FillChar(QSASProcessInformation, SizeOf(QSASProcessInformation), 0);
  QSASStartupInfo.cb:=SizeOf(QSASStartupInfo);
  QSASStartupInfo.dwFlags:=STARTF_USESHOWWINDOW;
  QSASStartupInfo.wShowWindow:=SW_SHOWMINNOACTIVE;
  if Windows.CreateProcess(nil, PChar(QSASPath + '\QuArKSAS.exe ' + QSASParameters + ' ' + FullFilename), nil, nil, false, 0, nil, PChar(QSASPath), QSASStartupInfo, QSASProcessInformation)=false then
    Fatal('Unable to extract file from Steam. Call to CreateProcess failed.');

  //DanielPharos: Waiting for INFINITE is rather dangerous,
  //so let's wait only 10 seconds
  if WaitForSingleObject(QSASProcessInformation.hProcess, 10000)=WAIT_FAILED then
  begin
    CloseHandle(QSASProcessInformation.hThread);
    CloseHandle(QSASProcessInformation.hProcess);
    Fatal('Unable to extract file from Steam. Call to WaitForSingleObject failed.');
  end;
  Result:=True;
end;

procedure ClearSteamCache;
var
  Setup: QObject;
  WarnBeforeClear, AllowRecycle, ClearCache, ClearCacheGCF: Boolean;
  SteamFullCacheDirectory: String;
  FilesToDelete: TStringList;
  FilesToDeleteFlags: Word;
  sr: TSearchRec;
begin
  if ClearCacheNeeded=false then
    Exit;
  ClearCacheNeeded:=false;
  Setup:=SetupSubSet(ssGames, 'Steam');
  ClearCache:=Setup.Specifics.Values['Clearcache']<>'';
  ClearCacheGCF:=Setup.Specifics.Values['ClearcacheGCF']<>'';
  SteamFullCacheDirectory:=IncludeTrailingPathDelimiter(Setup.Specifics.Values['Directory'])+Setup.Specifics.Values['CacheDirectory']+'\';
  {$IFDEF LINUX}
  SteamFullCacheDirectory:=StringReplace(SteamFullCacheDirectory,'\',PathDelim,[rfReplaceAll]);
  {$ELSE}
  SteamFullCacheDirectory:=StringReplace(SteamFullCacheDirectory,'/',PathDelim,[rfReplaceAll]);
  {$ENDIF}
  if ClearCache or ClearCacheGCF then
  begin
    WarnBeforeClear:=Setup.Specifics.Values['WarnBeforeClear']<>'';
    AllowRecycle:=Setup.Specifics.Values['AllowRecycle']<>'';
    if ClearCache then
    begin
      if FindFirst(SteamFullCacheDirectory + '*.*', faDirectory	, sr) = 0 then
      begin
        FilesToDelete := TStringList.Create;
        repeat
          if (sr.name <> '.') and (sr.name <> '..') then
            if Lowercase(RightStr(sr.Name, 4)) <> '.gcf' then
              FilesToDelete.Add(SteamFullCacheDirectory + sr.Name);
        until FindNext(sr) <> 0;
        FindClose(sr);
        if FilesToDelete.Count > 0 then
        begin
          if WarnBeforeClear then
          begin
            if MessageBox(0, PChar(FmtLoadStr1(5712, [SteamFullCacheDirectory])), PChar('QuArK'), MB_ICONWARNING+ MB_YESNO) = IDNO then
               Exit;
            WarnBeforeClear := false;    //So we don't show the warning multiple times!
          end;
          FilesToDeleteFlags := FOF_NOCONFIRMATION;
          if AllowRecycle then
            FilesToDeleteFlags := FilesToDeleteFlags or FOF_ALLOWUNDO;
          if DoFileOperation(FO_DELETE, FilesToDelete, nil, FilesToDeleteFlags) = false then
            Log(LOG_WARNING, 'Warning: Clearing of cache failed!');
        end;
        FilesToDelete.Free;
      end;
    end;
    if ClearCacheGCF then
    begin
      if WarnBeforeClear then
        if MessageBox(0, PChar(FmtLoadStr1(5712, [SteamFullCacheDirectory])), PChar('QuArK'), MB_ICONWARNING+ MB_YESNO) = IDNO then
          Exit;
      FilesToDelete := TStringList.Create;
      FilesToDelete.Add(SteamFullCacheDirectory + '*.gcf');
      FilesToDeleteFlags := FOF_NOCONFIRMATION;
      if AllowRecycle then
        FilesToDeleteFlags := FilesToDeleteFlags or FOF_ALLOWUNDO;
      if DoFileOperation(FO_DELETE, FilesToDelete, nil, FilesToDeleteFlags) = false then
        Log(LOG_WARNING, 'Warning: Clearing of GCF cache failed!');
      FilesToDelete.Free;
    end;
  end;
end;

initialization
  ClearCacheNeeded:=false;
end.

