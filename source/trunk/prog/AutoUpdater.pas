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
Revision 1.8  2008/06/26 20:35:06  danielpharos
Added sanity check for package build number, and completed package file parser.

Revision 1.7  2008/06/25 14:23:41  danielpharos
Major improvements in online update system.

Revision 1.6  2008/02/21 21:21:27  danielpharos
Small auto-update update: just some minor things.

Revision 1.5  2008/02/07 14:10:05  danielpharos
Display progressbar when searching for updates

Revision 1.4  2008/02/03 13:12:45  danielpharos
Update for the AutoUpdater. Beginning of the install-window.

Revision 1.3  2008/01/01 20:37:44  danielpharos
Partially build in and enabled the online update system. Still needs a lot of work, but it's downloading an index file and parsing it.

Revision 1.2  2007/11/21 18:19:50  danielpharos
Fix a problem downloading files in the AutoUpdater, and disabled it and hidden it per default (since it's not yet functional).

Revision 1.1  2007/09/12 15:35:40  danielpharos
Moved update settings to seperate config section and added beginnings of online update check.

}

unit AutoUpdater;

interface

uses Windows, ShellApi, Classes, Forms, StdCtrls, Controls, Graphics, CheckLst,
  HTTP;

type
  TUpdateFileType = (uptIndex, uptPackage, uptNotification);
  TUpdatePriority = (upCritical, upImportant, upOptional, upBeta);

  TUpdateNotification = record
    FileName: String; //@
    BuildNumber: Cardinal; //@
    //@
  end;

  TUpdatePackage = record
    InternalName: String;
    FileName: String;
    BuildNumber: Cardinal;
  end;

  TPackageFile = record
    FileName: String;
    FileSize: Cardinal;
    MD5: String;
  end;

  TUpdateFile = class
    ShouldBeFileType: TUpdateFileType;
    FileHeader: String;
    FileFormatVersion: String;
    FileType: TUpdateFileType;
  end;

  TUpdateIndexFile = class(TUpdateFile)
    NotificationNR: Cardinal;
    Notifications: array of TUpdateNotification;
    PackageNR: Cardinal;
    Packages: array of TUpdatePackage;
  end;

//@  TUpdateNotificationFile = class(TUpdateFile)
//@    NotificationIndex: Integer;
//@    ...
//@  end;

  TUpdatePackageFile = class(TUpdateFile)
    PackageIndex: Integer;
    FileName: String;
    Name: String;
    Description: String;
    BuildNumber: Cardinal;
//@    Priority: TUpdatePriority;
    FileNR: Cardinal;
    Files: array of TPackageFile;
    Install: Boolean;
    InstallSuccessful: Boolean;
  end;

  TAutoUpdater = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    CheckListBox1: TCheckListBox;
    Label2: TLabel;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  UpdateIndexFile: TUpdateIndexFile;
//@  UpdateNotificationsNR: Cardinal;
//@  UpdateNotifications: array of TUpdateNotificationFile;
  UpdatePackagesNR: Cardinal;
  UpdatePackages: array of TUpdatePackageFile;

procedure DoUpdate(AllowOnline: Boolean);

//Don't call these functions from outside this module!
function GetLine(FileData: TMemoryStream; var OutputLine: String) : Boolean;

procedure ParseString(FileData: TMemoryStream; var OutputVar: String);
procedure ParseCardinal(FileData: TMemoryStream; var OutputVar: Cardinal);

procedure ParseCommonHeader(CurrentFile: TUpdateFile; FileData: TMemoryStream);
procedure ParseIndexFile(CurrentFile: TUpdateIndexFile; FileData: TMemoryStream);
procedure ParsePackageFile(CurrentFile: TUpdatePackageFile; FileData: TMemoryStream);
//@procedure ParseNotificationFile(CurrentFile: TUpdateNotificationFile; FileData: TMemoryStream);

 {------------------------}

implementation

uses StrUtils, SysUtils, DateUtils, QkObjects, Setup, Logging, Travail,
  AutoUpdateInstaller;

{$R *.DFM}

 {------------------------}

function GetLine(FileData: TMemoryStream; var OutputLine: String) : Boolean;
var
  Dest, OldDest: PChar;
begin
  Dest := PChar(FileData.Memory) + FileData.Position;
  OldDest := Dest;
  if (FileData.Position >= FileData.Size) then
  begin
    SetLength(OutputLine, 0);
    Result := false;
    Exit;
  end;
  while ((Dest^ <> #13) and (Dest^ <> #10)) do
  begin
    FileData.Seek(1, soFromCurrent);
    Inc(Dest);
    if (FileData.Position = FileData.Size) then
    begin
      SetString(OutputLine, OldDest, Dest - OldDest);
      Result := true;
      Exit;
    end;
  end;
  SetString(OutputLine, OldDest, Dest - OldDest);
  if ((Dest^ = #13) and (FileData.Position < FileData.Size)) then
  begin
    Inc(Dest);
    if (Dest^ = #10) then
      FileData.Seek(1, soFromCurrent);
  end;
  if (FileData.Position <FileData.Size) then
    FileData.Seek(1, soFromCurrent);
  Result := true;
end;

procedure ParseString(FileData: TMemoryStream; var OutputVar: String);
begin
  if GetLine(FileData, OutputVar) = false then
    raise Exception.Create('Invalid String.');
end;

procedure ParseCardinal(FileData: TMemoryStream; var OutputVar: Cardinal);
var
  ParseLine: String;
  Dummy: Int64;
begin
  if GetLine(FileData, ParseLine) = false then
    raise Exception.Create('Invalid Cardinal number.');

  //There is no Delphi StrToCardinal function, so we're going through Int64 instead
  if TryStrToInt64(ParseLine, Dummy) = false then
    raise Exception.Create('Invalid Cardinal number.');

  if (Dummy < 0) or (Dummy > 4294967295) then
    raise Exception.Create('Invalid Cardinal number.');

  OutputVar := Cardinal(Dummy);
end;

procedure ParseCommonHeader(CurrentFile: TUpdateFile; FileData: TMemoryStream);
var
  ParseLine: String;
begin
  ParseString(FileData, CurrentFile.FileHeader);
  if CurrentFile.FileHeader <> 'QuArK Update File' then
    raise Exception.Create('Invalid header.');

  ParseString(FileData, CurrentFile.FileFormatVersion);
  if CurrentFile.FileFormatVersion <> 'Version 0.0' then
    raise Exception.Create('Unknown file format version.');

  ParseString(FileData, ParseLine);
  if ParseLine = 'Index File' then
    CurrentFile.FileType := uptIndex
  else if ParseLine = 'Package File' then
    CurrentFile.FileType := uptPackage
  else if ParseLine = 'Notification File' then
    CurrentFile.FileType := uptNotification
  else if ParseLine = 'Patcher File' then
    raise Exception.Create('Wrong file type.')
  else
    raise Exception.Create('Unknown file type.');

  if CurrentFile.FileType <> CurrentFile.ShouldBeFileType then
    raise Exception.Create('Wrong file type.');
end;

procedure ParseIndexFile(CurrentFile: TUpdateIndexFile; FileData: TMemoryStream);
var
  I: Integer;
begin
  CurrentFile.ShouldBeFileType := uptIndex;
  ParseCommonHeader(CurrentFile, FileData);

  ParseCardinal(FileData, CurrentFile.NotificationNR);

  if CurrentFile.NotificationNR > 0 then
  begin
    SetLength(CurrentFile.Notifications, CurrentFile.NotificationNR);
    for I:=0 to CurrentFile.NotificationNR - 1 do
    begin
      ParseString(FileData, CurrentFile.Notifications[I].FileName);
      ParseCardinal(FileData, CurrentFile.Notifications[I].BuildNumber);
    end;
  end;

  ParseCardinal(FileData, CurrentFile.PackageNR);

  if CurrentFile.PackageNR > 0 then
  begin
    SetLength(CurrentFile.Packages, CurrentFile.PackageNR);
    for I:=0 to CurrentFile.PackageNR - 1 do
    begin
      ParseString(FileData, CurrentFile.Packages[I].InternalName);
      ParseString(FileData, CurrentFile.Packages[I].FileName);
      ParseCardinal(FileData, CurrentFile.Packages[I].BuildNumber);
    end;
  end;
end;

procedure ParsePackageFile(CurrentFile: TUpdatePackageFile; FileData: TMemoryStream);
var
  I: Integer;
begin
  CurrentFile.ShouldBeFileType := uptPackage;
  ParseCommonHeader(CurrentFile, FileData);

  ParseString(FileData, CurrentFile.Name);
  ParseString(FileData, CurrentFile.Description);
  ParseCardinal(FileData, CurrentFile.BuildNumber);
  if CurrentFile.BuildNumber <> UpdateIndexFile.Packages[CurrentFile.PackageIndex].BuildNumber then
    raise Exception.Create('Build-numbers do not match.');

  ParseCardinal(FileData, CurrentFile.FileNR);
  if CurrentFile.FileNR > 0 then
  begin
    SetLength(CurrentFile.Files, CurrentFile.FileNR);
    for I:=0 to CurrentFile.FileNR - 1 do
    begin
      ParseString(FileData, CurrentFile.Files[I].FileName);
      ParseCardinal(FileData, CurrentFile.Files[I].FileSize);
      ParseString(FileData, CurrentFile.Files[I].MD5);
    end;
  end;
end;

function AutoUpdateOnline: Boolean;
var
  UpdateConnection: THTTPConnection;
  Setup: QObject;
  UpdateWindow: TAutoUpdater;
  FileData: TMemoryStream;
  I: Integer;
  Dummy: String;
  BuildNumber: Cardinal;
  AddThisPackage: Boolean;
  ProgressIndicatorMax: Integer;
begin
  Result := false;
  UpdateIndexFile := TUpdateIndexFile.Create;
  try
    try
      UpdateConnection:=THTTPConnection.Create;
      try
        ProgressIndicatorMax:=4;
        ProgressIndicatorStart(5462, ProgressIndicatorMax);
        try
          UpdateConnection.GoOnline;
          ProgressIndicatorIncrement;

          UpdateConnection.ConnectTo(QuArKUpdateSite);
          ProgressIndicatorIncrement;

          FileData := TMemoryStream.Create;
          try
            UpdateConnection.GetFile(QuArKUpdateFile, FileData);
            ProgressIndicatorIncrement;

            FileData.Seek(0, soFromBeginning);

            ParseIndexFile(UpdateIndexFile, FileData);
            ProgressIndicatorIncrement;
          finally
            FileData.Free;
          end;

          Setup := SetupSubSet(ssGeneral, 'Update');
          for I:=0 to UpdateIndexFile.PackageNR-1 do
          begin
            AddThisPackage := False;
            Dummy := Setup.Specifics.Values['Package_'+UpdateIndexFile.Packages[I].InternalName];
            if Dummy <> '' then
              try
                BuildNumber := StrToInt(Dummy);
                if BuildNumber < UpdateIndexFile.Packages[I].BuildNumber then
                  AddThisPackage := True;
              except
                AddThisPackage := True;
              end
            else
              AddThisPackage := True;

            if AddThisPackage then
            begin
              UpdatePackagesNR := UpdatePackagesNR + 1;
              SetLength(UpdatePackages, UpdatePackagesNR);
              UpdatePackages[UpdatePackagesNR - 1] := TUpdatePackageFile.Create;
              UpdatePackages[UpdatePackagesNR - 1].PackageIndex := I;
              UpdatePackages[UpdatePackagesNR - 1].FileName := UpdateIndexFile.Packages[I].FileName;

              ProgressIndicatorMax:=ProgressIndicatorMax+2;
              ProgressIndicatorChangeMax(-1, ProgressIndicatorMax);
              FileData := TMemoryStream.Create;
              try
                UpdateConnection.GetFile(UpdatePackages[UpdatePackagesNR - 1].FileName, FileData);
                ProgressIndicatorIncrement;

                FileData.Seek(0, soFromBeginning);

                ParsePackageFile(UpdatePackages[UpdatePackagesNR - 1], FileData);
                ProgressIndicatorIncrement;
              finally
                FileData.Free;
              end;
            end;
          end;
        finally
          ProgressIndicatorStop;
        end;
        UpdateConnection.GoOffline;
      finally
        UpdateConnection.Free;
      end;


      if Setup.Specifics.Values['AutomaticInstall'] = '' then
      begin
        UpdateWindow := TAutoUpdater.Create(nil);
        try
          for I:=0 to UpdatePackagesNR-1 do
            with UpdateWindow.CheckListBox1 do
            begin
              AddItem(UpdatePackages[I].Name, nil);
(*              case UpdatePackages[I].Priority of
              upCritical:  Checked[I] := true;
              upImportant: Checked[I] := true;
              upOptional:  Checked[I] := false;
              upBeta:      Checked[I] := false;
              else
              begin
                //Shouldn't happen!
                //@
                Checked[I] := true;
              end;
              end; *)
            end;
          UpdateWindow.ShowModal;
          //@
        finally
          UpdateWindow.Free;
        end;
      end
      else
        if DoInstall = false then
          Exit; //@

      //@

      Result := true;
    except
      on E: Exception do
      begin
        //Recycle Dummy...
        Dummy := 'The online update check has failed with the following error: '+E.Message+#13#10#13#10+'QuArK will not automatically fall back to offline update checking. If this error persists, please contact the QuArK development team via the forums.';
        Log(LOG_WARNING, Dummy);
        Application.MessageBox(PChar(Dummy), PChar('QuArK'), MB_OK);
      end;
    end;
  finally
    UpdateIndexFile.Free;
//    for I:=0 to UpdateNotificationsNR-1 do
//      UpdateNotifications[I].Free;
//    SetLength(UpdateNotifications, 0);
//    UpdateNotificationsNR := 0;
    for I:=0 to UpdatePackagesNR-1 do
      UpdatePackages[I].Free;
    SetLength(UpdatePackages, 0);
    UpdatePackagesNR := 0;
  end;
end;

procedure DoUpdate(AllowOnline: Boolean);
var
  DoOfflineUpdate: Boolean;
begin
  if AllowOnline then
  begin
    if SetupSubSet(ssGeneral, 'Update').Specifics.Values['UpdateCheckOnline'] <> '' then
    begin
      //Online update
      DoOfflineUpdate := False;
      if AutoUpdateOnline = false then
      begin
        //Something went wrong, let's fall back to the offline 'update'
        Log(LOG_WARNING, 'Unable to check for updates online! Using offline update routine.');
        DoOfflineUpdate := True;
      end;
    end
    else
      DoOfflineUpdate := True;
  end
  else
    DoOfflineUpdate := True;

  if DoOfflineUpdate then
  begin
    //Offline 'update'
    if DaySpan(Now, QuArKCompileDate) >= QuArKDaysOld then
    begin
      Log(LOG_WARNING, 'Offline update: Old version of QuArK detected!');
      if MessageBox(0, 'This version of QuArK is rather old. Do you want to open the QuArK website to check for updates?', 'QuArK', MB_YESNO) = IDYES then
      begin
        if ShellExecute(0, 'open', QuArKWebsite, nil, nil, SW_SHOWDEFAULT) <= 32 then
          MessageBox(0, 'Unable to open website: Call to ShellExecute failed!' + #13#10#13#10 + 'Please manually go to: ' + QuArKWebsite, 'QuArK', MB_OK);
      end;
    end;
  end;
end;

 {------------------------}

procedure TAutoUpdater.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TAutoUpdater.OKBtnClick(Sender: TObject);
var
  I: Integer;
  PackageSelected: Boolean;
begin
  PackageSelected := False;
  for I:=0 to CheckListBox1.Count-1 do
  begin
    UpdatePackages[I].Install := CheckListBox1.Checked[I];
    if CheckListBox1.Checked[I] then
      PackageSelected := true;
  end;
  if not PackageSelected then
  begin
    MessageBox(0, PChar('No packages selected. Please first select packages to install, or click "Cancel".'), PChar('QuArK'), MB_OK);
    Exit;
  end;
  Close;
  if DoInstall = false then
    Exit; //@
end;

procedure TAutoUpdater.CheckListBox1Click(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  I:=(Sender as TCheckListBox).ItemIndex;
  if I=-1 then
  begin
    Label1.Caption:='Description';
    Label1.Font.Color:=clGrayText;
  end
  else
  begin
(*    case UpdatePackages[I].Priority of
    upCritical: S:='Priority: Critical';
    upImportant: S:='Priority: Important';
    upOptional: S:='Priority: Optional';
    upBeta: S:='Priority: Beta';
    else
      S:=''; //Shouldn't happen!
    end;   *)
    Label1.Caption:=S + #13 + #10 + UpdatePackages[I].Description;
    Label1.Font.Color:=clWindowText;
  end;
end;

procedure TAutoUpdater.FormCreate(Sender: TObject);
begin
  CheckListBox1Click(CheckListBox1);
end;

end.
