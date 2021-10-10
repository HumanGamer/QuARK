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
unit Reg2;

interface

uses Windows, Classes, SysUtils, Registry;

type
 TRegistry2 = class(TRegistry)
              public
              {OnWrite: TNotifyEvent;
               DontWrite: Boolean;
               Tag: Integer;}
               function ReadOpenKey(const KeyName: String) : Boolean;
               function ReadDWORD(const Name: string) : DWORD;
               function TryReadDWORD(const Name: string; var Value: DWORD) : Boolean;
               function TryReadString(const Name: string; var Value: String) : Boolean;
               procedure WriteDWORD(const Name: string; Value: DWORD);
               function TryWriteDWORD(const Name: string; Value: DWORD) : Boolean;
               function TryWriteString(const Name, Value: string) : Boolean;
              end;

implementation


// ---

function TRegistry2.TryReadString(const Name: string; var Value: String) : Boolean;
var
  BufSize: Integer;
  DataType: Cardinal;
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

end.
