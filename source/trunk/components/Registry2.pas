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
unit Registry2;

interface

uses Windows, Classes, SysUtils, Registry;

type
  QWORD = Int64;

type
 TRegistry2 = class(TRegistry)
              public
              {OnWrite: TNotifyEvent;
               DontWrite: Boolean;
               Tag: Integer;}
               function ReadOpenKey(const KeyName: String) : Boolean;
               function GetRawDataType(const ValueName: string): DWORD;
               function ReadDWORD(const Name: string) : DWORD;
               function ReadQWORD(const Name: string) : QWORD;
               function TryReadDWORD(const Name: string; var Value: DWORD) : Boolean;
               function TryReadQWORD(const Name: string; var Value: QWORD) : Boolean;
               function TryReadBinaryData(const Name: string; var Buffer; var BufSize: Integer) : Boolean;
               function TryReadString(const Name: string; var Value: String) : Boolean;
               procedure WriteDWORD(const Name: string; Value: DWORD);
               procedure WriteQWORD(const Name: string; Value: QWORD);
               function TryWriteDWORD(const Name: string; Value: DWORD) : Boolean;
               function TryWriteQWORD(const Name: string; Value: QWORD) : Boolean;
               function TryWriteBinaryData(const Name: string; var Buffer; BufSize: Integer) : Boolean;
               function TryWriteString(const Name, Value: string) : Boolean;
              end;

implementation

uses RTLConsts;

const
  REG_QWORD = 11;

//Note that we can't override the DataTypeToRegData function,
//so it will not properly process REG_QWORD.

//Copied from Registry.pas:
procedure ReadError(const Name: string);
begin
  raise ERegistryException.CreateResFmt(@SInvalidRegType, [Name]);
end;

// ---

{function TRegistry2.OpenKey(const KeyName: String; Create: Boolean) : Boolean;
begin
 if Create and (DontWrite or Assigned(OnWrite)) then
  begin
   Result:=OpenKey(KeyName, False);
   if not Result then
    begin
     if DontWrite then Exit;
     if Assigned(OnWrite) then OnWrite(Self);
     if DontWrite then Exit;
     Result:=OpenKey(KeyName, True);
    end;
  end
 else
  OpenKey:=inherited OpenKey(KeyName, Create);
end;}

function TRegistry2.ReadOpenKey(const KeyName: String) : Boolean;
var
  TempKey: HKey;
  S: string;
  Relative: Boolean;
begin
 Result:=False;
 if KeyName='' then Exit;
 S:=KeyName;
 Relative:=S[1]<>'\';
 if not Relative then Delete(S, 1, 1);
 TempKey:=0;
 Result:=RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0, KEY_READ, TempKey) = ERROR_SUCCESS;
 if Result then
  begin
   if (CurrentKey<>0) and Relative then S:=CurrentPath+'\'+S;
   ChangeKey(TempKey, S);
  end;
end;

function TRegistry2.GetRawDataType(const ValueName: string): DWORD;
begin
  if RegQueryValueEx(CurrentKey, PChar(ValueName), nil, @Result, nil, nil) <> ERROR_SUCCESS then
    ReadError(ValueName);
end;

// ---

function TRegistry2.TryReadBinaryData(const Name: string; var Buffer; var BufSize: Integer) : Boolean;
var
  DataType: DWORD;
  NewBufSize: Integer;
begin
  Result:=False;
  NewBufSize := GetDataSize(Name);
  if NewBufSize > BufSize then
   begin
    Result:=False;
    Exit;
   end;
  DataType := REG_NONE;
  if (RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(Buffer),
   @NewBufSize) = ERROR_SUCCESS)
  and (DataType = REG_BINARY) then
   begin
    BufSize:=NewBufSize;
    Result:=True;
   end;
end;

function TRegistry2.TryWriteBinaryData(const Name: string; var Buffer; BufSize: Integer) : Boolean;
var
  bdata: pchar;
begin
 {if DontWrite then
 begin
   Result:=True;
   Exit;
 end;}
 bdata:=stralloc(BufSize + 1); //Note: One larger for null-terminator
 try
  FillChar(bdata^, BufSize + 1, 0);
  if (not TryReadBinaryData(Name, bdata, BufSize)) or (not CompareMem(@Buffer, bdata, BufSize)) then
  begin
  {if Assigned(OnWrite) then
    OnWrite(Self);
   if not DontWrite then}
    Result:=RegSetValueEx(CurrentKey, PChar(Name), 0, REG_BINARY,
     PChar(Buffer), BufSize+1)=ERROR_SUCCESS;
  end
  else
   Result:=True;
 finally
  strdispose(bdata);
 end;
end;

// ---

function TRegistry2.TryReadString(const Name: string; var Value: String) : Boolean;
var
  BufSize: Integer;
  DataType: DWORD;
  Courant: String;
begin
  Result:=False;
  BufSize := GetDataSize(Name);
  if BufSize > 0 then
   begin
    SetString(Courant, nil, BufSize);
    DataType := REG_NONE;
    if (RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(Courant),
     @BufSize) = ERROR_SUCCESS)
    and ((DataType = REG_SZ) or (DataType = REG_EXPAND_SZ)) then
     begin
      SetLength(Courant, StrLen(PChar(Courant)));
      Value:=Courant;
      Result:=True;
     end;
   end;
end;

function TRegistry2.TryWriteString(const Name, Value: string) : Boolean;
var
 Courant: String;
begin
 if {not DontWrite and}
 (not TryReadString(Name, Courant) or (Value<>Courant)) then
  begin
  {if Assigned(OnWrite) then
    OnWrite(Self);
   if not DontWrite then}
    Result:=RegSetValueEx(CurrentKey, PChar(Name), 0, REG_SZ,
     PChar(Value), Length(Value)+1)=ERROR_SUCCESS;
  end
 else
  Result:=True;
end;

// ---

function TRegistry2.ReadDWORD(const Name: string) : DWORD;
begin
  Result:=ReadInteger(Name);
end;

function TRegistry2.TryReadDWORD(const Name: string; var Value: DWORD) : Boolean;
var
  Buffer: DWORD;
  DataType, BufSize: DWORD;
begin
 BufSize := SizeOf(Buffer);
 DataType := REG_NONE;
 if (RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(@Buffer),
  @BufSize) <> ERROR_SUCCESS) or (DataType <> REG_DWORD) then
   Result:=False
  else
   begin
    Value:=Buffer;
    Result:=True;
   end;
end;

procedure TRegistry2.WriteDWORD(const Name: string; Value: DWORD);
begin
  PutData(Name, @Value, SizeOf(DWORD), rdInteger);
end;

function TRegistry2.TryWriteDWORD(const Name: string; Value: DWORD) : Boolean;
var
 Buffer: DWORD;
begin
 if {not DontWrite and}
 (not TryReadDWORD(Name, Buffer) or (Buffer<>Value)) then
  begin
  {if Assigned(OnWrite) then
    OnWrite(Self);
   if not DontWrite then}
    Result:=RegSetValueEx(CurrentKey, PChar(Name), 0, REG_DWORD,
     @Value, SizeOf(Value))=ERROR_SUCCESS;
  end
 else
  Result:=True;
end;

// ---

function TRegistry2.ReadQWORD(const Name: string): QWORD;
var
  DataType: DWORD;
  BufSize: Integer;
begin
  BufSize := SizeOf(Result);
  DataType := REG_NONE;
  if RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(@Result),
    @BufSize) <> ERROR_SUCCESS then
    raise ERegistryException.CreateResFmt(@SRegGetDataFailed, [Name]);
  if DataType <> REG_QWORD then ReadError(Name);
end;

function TRegistry2.TryReadQWORD(const Name: string; var Value: QWORD) : Boolean;
var
  Buffer: QWORD;
  DataType, BufSize: DWORD;
begin
 BufSize := SizeOf(Buffer);
 DataType := REG_NONE;
 if (RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(@Buffer),
  @BufSize) <> ERROR_SUCCESS) or (DataType <> REG_QWORD) then
   Result:=False
  else
   begin
    Value:=Buffer;
    Result:=True;
   end;
end;

procedure TRegistry2.WriteQWORD(const Name: string; Value: QWORD);
var
  BufSize: DWORD;
begin
  BufSize := SizeOf(Value);
  if RegSetValueEx(CurrentKey, PChar(Name), 0, REG_QWORD, @Value,
    BufSize) <> ERROR_SUCCESS then
    raise ERegistryException.CreateResFmt(@SRegSetDataFailed, [Name]);
end;

function TRegistry2.TryWriteQWORD(const Name: string; Value: QWORD) : Boolean;
var
 Buffer: QWORD;
begin
 if {not DontWrite and}
 (not TryReadQWORD(Name, Buffer) or (Buffer<>Value)) then
  begin
  {if Assigned(OnWrite) then
    OnWrite(Self);
   if not DontWrite then}
    Result:=RegSetValueEx(CurrentKey, PChar(Name), 0, REG_QWORD,
     @Value, SizeOf(Value))=ERROR_SUCCESS;
  end
 else
  Result:=True;
end;

end.
