(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor
Copyright (C) 1996-99 Armin Rigo

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

Contact the author Armin Rigo by e-mail: arigo@planetquake.com
or by mail: Armin Rigo, La Cure, 1854 Leysin, Switzerland.
See also http://www.planetquake.com/quark
**************************************************************************)

{

$Header$
 ----------- REVISION HISTORY ------------
$Log$

}


unit Reg2;

interface

uses Windows, Classes, SysUtils, Registry;

type
 TRegistry2 = class(TRegistry)
              public
              {OnWrite: TNotifyEvent;
               DontWrite: Boolean;
               Tag: Integer;}
               function ReadInteger(const Name: string; var Value: Integer) : Boolean;
               function ReadString(const Name: string; var Value: String) : Boolean;
               function WriteString(const Name, Value: string) : Boolean;
               function WriteInteger(const Name: string; Value: Integer) : Boolean;
               function ReadOpenKey(const KeyName: String) : Boolean;
              end;

implementation

function TRegistry2.ReadString;
var
  Len: Integer;
  DataType: Integer;
  Courant: String;
begin
  Result:=False;
  Len := GetDataSize(Name);
  if Len > 0 then
   begin
    SetString(Courant, nil, Len);
    DataType := REG_NONE;
    if (RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(Courant),
     @Len) = ERROR_SUCCESS)
    and ((DataType = REG_SZ) or (DataType = REG_EXPAND_SZ)) then
     begin
      SetLength(Courant, StrLen(PChar(Courant)));
      Value:=Courant;
      Result:=True;
     end;
   end;
end;

function TRegistry2.WriteString;
var
 Courant: String;
begin
 if {not DontWrite and}
 (not ReadString(Name, Courant) or (Value<>Courant)) then
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

function TRegistry2.ReadInteger;
var
  Courant, Len: Integer;
  DataType: Integer;
begin
 Len:=SizeOf(Courant);
 DataType := REG_NONE;
 if (RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(@Courant),
  @Len) <> ERROR_SUCCESS) or (DataType <> REG_DWORD) then
   Result:=False
  else
   begin
    Value:=Courant;
    Result:=True;
   end;
end;

function TRegistry2.WriteInteger;
var
 Courant: Integer;
begin
 if {not DontWrite and}
 (not ReadInteger(Name, Courant) or (Courant<>Value)) then
  begin
  {if Assigned(OnWrite) then
    OnWrite(Self);
   if not DontWrite then}
    Result:=RegSetValueEx(CurrentKey, PChar(Name), 0, REG_DWORD,
     @Value, SizeOf(Integer))=ERROR_SUCCESS;
  end
 else
  Result:=True;
end;

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
