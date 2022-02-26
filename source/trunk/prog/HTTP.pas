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

uses Windows, Classes;

//We can't use WinInet here, because that creates a load-time dependency on wininet.dll,
//which might not exist on Windows 95 RTM. So we're copy-pasting part from it,
//and dynamically loading wininet.dll instead.
type
  HINTERNET = Pointer;

type
  THTTPConnection = class
  private
    Online, Connected, Requesting: Boolean;
    InetHandle, InetConnection, InetResource: HINTERNET;
  public
    function GoOnline: Boolean;
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

//Everything in this section is based on WinInet

const
  winetdll = 'wininet.dll';

  INTERNET_OPEN_TYPE_PRECONFIG = 0;
  {$EXTERNALSYM INTERNET_OPEN_TYPE_PRECONFIG}
  INTERNET_DEFAULT_HTTP_PORT = 80;
  {$EXTERNALSYM INTERNET_DEFAULT_HTTP_PORT}
  INTERNET_DEFAULT_HTTPS_PORT = 443;
  {$EXTERNALSYM INTERNET_DEFAULT_HTTPS_PORT}
  INTERNET_SERVICE_HTTP = 3;
  {$EXTERNALSYM INTERNET_SERVICE_HTTP}
  INTERNET_FLAG_RELOAD = $80000000;
  {$EXTERNALSYM INTERNET_FLAG_RELOAD}
  INTERNET_FLAG_NO_CACHE_WRITE = $04000000;
  {$EXTERNALSYM INTERNET_FLAG_NO_CACHE_WRITE}
  HTTP_QUERY_CONTENT_LENGTH = 5;
  {$EXTERNALSYM HTTP_QUERY_CONTENT_LENGTH}
  HTTP_QUERY_STATUS_CODE = 19;
  {$EXTERNALSYM HTTP_QUERY_STATUS_CODE}

type
  INTERNET_PORT = Word; 
  {$EXTERNALSYM INTERNET_PORT}

var
  HWinInet: HMODULE;

  InternetOpen: function (lpszAgent: PChar; dwAccessType: DWORD; lpszProxy, lpszProxyBypass: PChar; dwFlags: DWORD): HINTERNET; stdcall;
  {$EXTERNALSYM InternetOpen}
  InternetCloseHandle: function (hInet: HINTERNET): BOOL; stdcall;
  {$EXTERNALSYM InternetCloseHandle}
  InternetConnect: function (hInet: HINTERNET; lpszServerName: PChar; nServerPort: INTERNET_PORT; lpszUsername: PChar; lpszPassword: PChar; dwService: DWORD; dwFlags: DWORD; dwContext: DWORD): HINTERNET; stdcall;
  {$EXTERNALSYM InternetConnect}
  HttpOpenRequest: function(hConnect: HINTERNET; lpszVerb: PChar; lpszObjectName: PChar; lpszVersion: PChar; lpszReferrer: PChar; lplpszAcceptTypes: PLPSTR; dwFlags: DWORD; dwContext: DWORD): HINTERNET; stdcall;
  {$EXTERNALSYM HttpOpenRequest}
  HttpSendRequest: function(hRequest: HINTERNET; lpszHeaders: PChar; dwHeadersLength: DWORD; lpOptional: Pointer;  dwOptionalLength: DWORD): BOOL; stdcall;
  {$EXTERNALSYM HttpSendRequest}
  HttpQueryInfo: function(hRequest: HINTERNET; dwInfoLevel: DWORD; lpvBuffer: Pointer; var lpdwBufferLength: DWORD; var lpdwReserved: DWORD): BOOL; stdcall;
  {$EXTERNALSYM HttpQueryInfo}
  InternetSetFilePointer: function(hFile: HINTERNET; lDistanceToMove: Longint; pReserved: Pointer; dwMoveMethod, dwContext: DWORD): DWORD; stdcall;
  {$EXTERNALSYM InternetSetFilePointer}
  InternetReadFile: function(hFile: HINTERNET; lpBuffer: Pointer; dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
  {$EXTERNALSYM InternetReadFile}

function LoadWinInet: Boolean;
begin
  //Note: Delphi7 always calls the ANSI version
  HWinInet := LoadLibrary(winetdll);
  If HWinInet = 0 Then
  begin
    Result := False;
    Exit;
  end;
  @InternetOpen := GetProcAddress(HWinInet, 'InternetOpenA');
  If @InternetOpen = nil Then
  begin
    Result := False;
    Exit;
  end;
  @InternetCloseHandle := GetProcAddress(HWinInet, 'InternetCloseHandle');
  If @InternetCloseHandle = nil Then
  begin
    Result := False;
    Exit;
  end;
  @InternetConnect := GetProcAddress(HWinInet, 'InternetConnectA');
  If @InternetConnect = nil Then
  begin
    Result := False;
    Exit;
  end;
  @HttpOpenRequest := GetProcAddress(HWinInet, 'HttpOpenRequestA');
  If @HttpOpenRequest = nil Then
  begin
    Result := False;
    Exit;
  end;
  @HttpSendRequest := GetProcAddress(HWinInet, 'HttpSendRequestA');
  If @HttpSendRequest = nil Then
  begin
    Result := False;
    Exit;
  end;
  @HttpQueryInfo := GetProcAddress(HWinInet, 'HttpQueryInfoA');
  If @HttpQueryInfo = nil Then
  begin
    Result := False;
    Exit;
  end;
  @InternetSetFilePointer := GetProcAddress(HWinInet, 'InternetSetFilePointer');
  If @InternetSetFilePointer = nil Then
  begin
    Result := False;
    Exit;
  end;
  @InternetReadFile := GetProcAddress(HWinInet, 'InternetReadFile');
  If @InternetReadFile = nil Then
  begin
    Result := False;
    Exit;
  end;
  Result:=True;
end;

procedure UnloadWinInet;
begin
  @InternetReadFile := nil;
  @InternetSetFilePointer := nil;
  @HttpQueryInfo := nil;
  @HttpSendRequest := nil;
  @HttpOpenRequest := nil;
  @InternetConnect := nil;
  @InternetOpen := nil;
  @InternetCloseHandle := nil;
  FreeLibrary(HWinInet);
  HWinInet:=0;
end;

 {------------------------}

destructor THTTPConnection.Destroy;
begin
  if Online then
    GoOffline;

  inherited;
end;

function THTTPConnection.GoOnline: Boolean;
begin
  if Online then
    GoOffline;

  if HWinInet=0 then
    if not LoadWinInet then
    begin
      Result:=False;
      Exit;
    end;

  InetHandle:=InternetOpen(PChar('QuArK'), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if InetHandle=nil then
  begin
    LogWindowsError(GetLastError(), 'THTTPConnection.GoOnline: InternetOpen failed!');
    raise exception.create('Unable to open internet connection.');
  end;
  Online:=True;
  Result:=True;
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
  if not Online then
    raise exception.create('Not online.');
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
  if not Connected then
    raise exception.create('Not connected.');
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
  if not Requesting then
    raise exception.create('Not requesting.');

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
  if not Requesting then
    raise exception.create('Not requesting.');

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

initialization
finalization
  UnloadWinInet();
end.
