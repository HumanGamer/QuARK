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
Revision 1.7  2008/07/07 19:51:50  danielpharos
Small update: AutoUpdateInstaller now going through individual files of packages

Revision 1.6  2008/06/25 14:44:50  danielpharos
Added missing log entries.

Revision 1.5  2008/06/25 14:30:12  danielpharos
Change to ASCII file property

Revision 1.4  2008/06/25 14:23:41  danielpharos
Major improvements in online update system.

Revision 1.3  2008/02/21 21:21:27  danielpharos
Small auto-update update: just some minor things.

Revision 1.2  2008/02/07 14:09:44  danielpharos
Add missing result.

Revision 1.1  2008/02/03 13:12:45  danielpharos
Update for the AutoUpdater. Beginning of the install-window.

}

unit AutoUpdateInstaller;

interface

uses Windows, Forms, Classes, StdCtrls, Controls, ComCtrls, AutoUpdater, HTTP;

type
  TAutoUpdateInstaller = class(TForm)
    StopBtn: TButton;
    pgbInstall: TProgressBar;
    Label1: TLabel;
    procedure StopBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  end;

function DoInstall: Boolean;

 {------------------------}

implementation

uses SysUtils, QkObjects, QuarkX;

procedure InstallPackages; stdcall; forward;

var
  InstallWindow: TAutoUpdateInstaller;
  ThreadHandle: Cardinal;
  StopUpdate, ExitWindow: Boolean;

{$R *.DFM}

 {------------------------}

function GetExceptionMessage: String;
begin
  Result:=LoadStr1(402);
  if Result='' then
    Result:='Unknown error';
  if (ExceptObject is Exception) then
    Result:=Exception(ExceptObject).Message;
end;

function DoInstall: Boolean;
var
  ThreadId: Cardinal; //Dummy variable
begin
  Result:=False;
  InstallWindow:=TAutoUpdateInstaller.Create(nil);
  try
    ThreadHandle:=CreateThread(nil, 0, @InstallPackages, nil, 0, ThreadId);
    if ThreadHandle = 0 then
    begin
      MessageBox(InstallWindow.Handle, PChar('Unable to create installer thread. Update unsuccessful.'), PChar('QuArK'), MB_OK);
      Exit;
    end;
    SetThreadPriority(ThreadHandle, THREAD_PRIORITY_ABOVE_NORMAL);
    //@ FUCK UP! Need better Thread-management!
    InstallWindow.ShowModal;
  finally
    InstallWindow.Free;
  end;
  Result:=True;
end;

procedure InstallPackages; stdcall;
var
  I, J: Integer;
  UpdateConnection: THTTPConnection;
  FileData: TMemoryStream;
  TotalFileNumber: Cardinal;
begin
  try
    try
      TotalFileNumber:=0;
      for I:=0 to UpdatePackagesNR-1 do
        with UpdatePackages[I] do
          if Install then
            TotalFileNumber:=TotalFileNumber+FileNR;

      if TotalFileNumber>0 then
      begin
        InstallWindow.pgbInstall.Max:=Integer(TotalFileNumber*2);

        UpdateConnection:=THTTPConnection.Create;
        try
          UpdateConnection.GoOnline;
          UpdateConnection.ConnectTo(QuArKUpdateSite);

          //Download new files
          for I:=0 to UpdatePackagesNR-1 do
          begin
            with UpdatePackages[I] do
              if Install then
              begin
                for J:=0 to FileNR-1 do
                begin
                  FileData := TMemoryStream.Create;
                  try
                    //@Open file for QUPfiledata...
                    UpdateConnection.GetFile(Files[J].FileName, FileData);
                    FileData.Seek(0, soFromBeginning);
                    //@Save QUPfiledata to file...
                    //@
                  finally
                    FileData.Free;
                  end;
                  InstallWindow.pgbInstall.StepIt;
                  if StopUpdate then
                    Exit;
                  Application.ProcessMessages;
                end;
              end;
          end;
        finally
          UpdateConnection.Free;
        end;

        //Install new files
        for I:=0 to UpdatePackagesNR-1 do
        begin
          with UpdatePackages[I] do
            if Install then
            begin
              //@
              UpdatePackages[I].InstallSuccessful:=True;
              InstallWindow.pgbInstall.StepIt;
              if StopUpdate then
                Exit;
              Application.ProcessMessages;
            end;
        end;
      end
      else
      begin
      //@
        //InstallWindow.pgbInstall.Max:=1;
        //InstallWindow.pgbInstall.Step:=1;
      end;
    finally
      InstallWindow.StopBtn.Caption:='OK';
      ThreadHandle:=0;
    end;
  except
    InstallWindow.Label1.Caption:=GetExceptionMessage; //@
    Exit;
  end;
  InstallWindow.Label1.Caption:='QuArK needs to be restarted for the updates to be applied.'; //@
  Application.ProcessMessages;
end;

 {------------------------}

procedure TAutoUpdateInstaller.StopBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TAutoUpdateInstaller.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ThreadHandle<>0 then
  begin
    if MessageBox(Handle, PChar('Installation of the updates is still busy. Stopping the update will most likely result in a corrupt install. Are you sure you want to stop the installation?'), PChar('QuArK'), MB_ICONEXCLAMATION + MB_YESNO + MB_DEFBUTTON2) = IDNO then
    begin
      CanClose:=False;
      Exit;
    end;
    StopUpdate:=True;
    while ThreadHandle<>0 do
    begin
      Sleep(50);
      Application.ProcessMessages;
    end;
  end;
end;

procedure TAutoUpdateInstaller.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ExitWindow:=True;
end;

end.

