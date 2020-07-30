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
unit HTTP;

interface

uses Windows, WinInet, Classes;

type
  THTTPConnection = class
  private
    Online, Connected, Requesting: Boolean;
    InetHandle, InetConnection, InetResource: HINTERNET;
  public
    procedure GoOnline;
    procedure GoOffline;
    procedure ConnectTo(const HostName: string);
    procedure CloseConnect;
    procedure FileRequest(const FileName: string);
    function FileQueryInfo(Flag: DWORD; Default: Integer = 0): Integer;
    procedure CloseRequest;
    procedure ReadFile(FileData: TMemoryStream; DataStart, DataLength: cardinal);
    //Easy-to-use function:
    procedure GetFile(const FileName: string; FileData: TMemoryStream);
    destructor Destroy; override;
  end;

 {------------------------}

implementation

uses StrUtils, SysUtils, Logging, QkExceptions, ExtraFunctionality;

const
  StatusBufferLength : DWORD = 256;
  FileBufferLength : DWORD = 65536;

 {------------------------}

destructor THTTPConnection.Destroy;
begin
  if Online then
    GoOffline;

  inherited;
end;

procedure THTTPConnection.GoOnline;
begin
  if Online then
    GoOffline;

  InetHandle:=InternetOpen(PChar('QuArK'), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if InetHandle=nil then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.GoOnline: InternetOpen failed!');
    raise exception.create('Unable to open internet connection.');
  end;
  Online:=True;
end;

procedure THTTPConnection.GoOffline;
begin
  if not Online then
    Exit;

  if Connected then
    CloseConnect;
  if InternetCloseHandle(InetHandle)=false then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.GoOffline: InternetCloseHandle failed!');
    //Exit;
  end;
  Online:=False;
  InetHandle:=nil;
end;

procedure THTTPConnection.ConnectTo(const HostName: string);
begin
  if Connected then
    CloseConnect;

  InetConnection:=InternetConnect(InetHandle, PChar(HostName), INTERNET_DEFAULT_HTTP_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
  if InetConnection=nil then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.ConnectTo: InternetConnect failed!');
    raise exception.create('Unable to open internet connection.');
  end;
  Connected:=True;
end;

procedure THTTPConnection.CloseConnect;
begin
  if not Connected then
    Exit;

  if InternetCloseHandle(InetConnection)=false then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.CloseConnect: InternetCloseHandle failed!');
    //Exit;
  end;
  Connected:=False;
  InetConnection:=nil;
end;

procedure THTTPConnection.FileRequest(const FileName: string);
begin
  if Requesting then
    CloseRequest;

  //We might need to set this as accepted type: 'binary/octet-stream'
  InetResource:=HttpOpenRequest(InetConnection, PChar('GET'), PChar(FileName), nil, nil, nil, INTERNET_FLAG_RELOAD + INTERNET_FLAG_NO_CACHE_WRITE, 0);
  if InetResource=nil then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.FileRequest: HttpOpenRequest failed!');
    raise exception.create('Can not access file to download.');
  end;
  if HttpSendRequest(InetResource, nil, 0, nil, 0)=false then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.FileRequest: HttpSendRequest failed!');
    raise exception.create('Can not access file to download.');
  end;
  Requesting:=True;
end;

procedure THTTPConnection.CloseRequest;
begin
  if not Requesting then
    Exit;

  if InternetCloseHandle(InetResource)=false then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.CloseRequest: InternetCloseHandle failed!');
    //Exit;
  end;
  Requesting:=False;
  InetResource:=nil;
end;

function THTTPConnection.FileQueryInfo(Flag: DWORD; Default: Integer = 0): Integer;
var
  StatusBuffer: PChar;
  BufferLength: DWORD;
  HeaderIndex: DWORD;
begin
  GetMem(StatusBuffer, StatusBufferLength);
  try
    HeaderIndex:=0;
    BufferLength:=StatusBufferLength;

    if HttpQueryInfo(InetResource, Flag, StatusBuffer, BufferLength, HeaderIndex)=false then
    begin
      LogWindowsError(GetLastError(), 'THTTPConnection.FileQueryInfo: HttpQueryInfo failed!');
      Result:=Default;
      Exit;
    end;

    Result:=StrToIntDef(LeftStr(StatusBuffer, BufferLength), Default);
  finally
    FreeMem(StatusBuffer);
  end;
end;

procedure THTTPConnection.ReadFile(FileData: TMemoryStream; DataStart, DataLength: cardinal);
var
  Buffer: PChar;
  BufferLength: DWORD;
begin
  if DataStart<>0 then
  begin
    if (InternetSetFilePointer(InetResource, DataStart, nil, FILE_BEGIN, 0) = INVALID_SET_FILE_POINTER) and (GetLastError() <> NO_ERROR) then
    begin
      LogWindowsError(GetLastError(), 'THTTPConnection.ReadFile: InternetSetFilePointer failed!');
      raise exception.create('Cannot download file. Data transfer failed.');
    end;
  end;

  FileData.Seek(0, soFromBeginning);
  FileData.SetSize(DataLength);

  GetMem(Buffer, FileBufferLength);
  try
    repeat
      if InternetReadFile(InetResource, Buffer, FileBufferLength, BufferLength)=false then
      begin
        LogWindowsError(GetLastError(), 'THTTPConnection.ReadFile: InternetReadFile failed!');
        raise exception.create('Cannot download file. Data transfer failed.');
      end;
      if BufferLength>0 then
        FileData.WriteBuffer(Buffer^, BufferLength);
    until BufferLength=0;
  finally
    FreeMem(Buffer);
  end;
  if FileData.Position <> FileData.Size then
  begin
    Log(LOG_WARNING, 'THTTPConnection.ReadFile: FileData does NOT fill buffer completely!');
    GetMem(Buffer, FileData.Size - FileData.Position);
    try
      FillChar(Buffer, FileData.Size - FileData.Position, 0);
      FileData.WriteBuffer(Buffer, FileData.Size - FileData.Position);
    finally
      FreeMem(Buffer);
    end;
  end;
end;

procedure THTTPConnection.GetFile(const FileName: string; FileData: TMemoryStream);
var
  StatusValue: Integer;
  ResourceSize: Cardinal;
begin
  if not Connected then
    raise exception.create('Cannot download file: not connected.');

  FileRequest(FileName);
  try
    StatusValue:=FileQueryInfo(HTTP_QUERY_STATUS_CODE, 200);
    if StatusValue<>200 then
    begin
      //FIXME: Properly handle StatusValue!
      raise exception.create('Cannot download file: file info query failed.');
    end;

    //Retrieve the index-filesize...
    ResourceSize:=FileQueryInfo(HTTP_QUERY_CONTENT_LENGTH, 0);
    if ResourceSize=0 then
    begin
      //DanielPharos: This is not considered to be an error.
      //raise exception.create('Cannot download file: Filesize is zero.');
      Exit;
    end;

    ReadFile(FileData, 0, ResourceSize);
  finally
    CloseRequest;
  end;
end;

end.
