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
Revision 1.10  2007/03/11 12:03:10  danielpharos
Big changes to Logging. Simplified the entire thing.

Revision 1.9  2007/02/07 18:48:34  danielpharos
Fixes for memory leaks

Revision 1.8  2007/02/07 14:09:22  danielpharos
Fix a few Range Check errors

Revision 1.7  2005/09/28 10:48:32  peter-b
Revert removal of Log and Header keywords

Revision 1.5  2005/07/05 19:12:48  alexander
logging to file using loglevels

Revision 1.4  2002/12/30 18:07:36  decker_dk
Renamed 'GetRegisteredQObject' to 'RequestClassOfType', and moved the 'QObjectClassList.Free' from Qk1.PAS to QkObjectClassList.PAS.

Revision 1.3  2001/10/10 11:54:57  tiglari
Move QObjectStringlist into interface section so that it can be freed in
 Qk1:TForm1.FormDestroy

Revision 1.2  2001/03/20 21:45:22  decker_dk
Updated copyright-header

Revision 1.1  2001/01/21 15:49:30  decker_dk
Moved RegisterQObject() and those things, to a new unit; QkObjectClassList.
}

unit QkObjectClassList;

interface

uses Classes, QkObjects;

procedure RegisterQObject(Q: QObjectClass; Prior: Char);
function ConstructQObject(const Name: String; nParent: QObject) : QObject;
function RequestClassOfType(const nTypeInfo: String) : QObjectClass;
function NeedClassOfType(const nTypeInfo: String) : QObjectClass;
procedure ListFileExt(L: TStrings);
procedure BuildFileExt(L: TStrings);

 {------------------------}

implementation

uses
 SysUtils,
 {$IFDEF Debug} MemTester, {$ENDIF}
 QkFileObjects, Quarkx,Logging;

var
 QObjectClassList: TStringList = Nil;

 {------------------------}

procedure RegisterQObject(Q: QObjectClass; Prior: Char);
{ (Comment by Decker 2001-01-21)
 Function to register a QkObject-decendant into QuArK's huge class-list.
 'Q' is the class which should be registered.
 'Prior' is a letter, which will be used to prefix 'Q's TypeInfo with, and
 then sorted by 'Prior+Q.TypeInfo()' - Why it needs to be sorted I dont know.
  (Update by Decker 2002-06-20)
 It needs to be sorted, because ConstructQObject() loops backwards through the
 list, in search for a match, and if it does not find any, the lowest priority
 is automatically choosen. Only 'QkUnknown' has (must have) the lowest
 priority, which is #32.
}
begin
  if QObjectClassList=Nil then
  begin
    QObjectClassList:=TStringList.Create;
    QObjectClassList.Sorted:=True;
  end;
  Log(LOG_VERBOSE,'RegisterQObject %s',[Q.TypeInfo]);

  QObjectClassList.AddObject(Prior+Q.TypeInfo, TObject(Q));
end;

function ConstructQObject(const Name: String; nParent: QObject) : QObject;
{ (Comment by Decker 2001-01-21)
 This function, will create an object based on the 'TypeInfo/FilenameExtension'
 of the 'Name'. E.q. if 'Name' contains "MyTexture.WAL", it will create an object
 of the registered class which 'TypeInfo()' function return ".WAL".
  (Update by Decker 2002-06-20)
 The new object will be told that it belongs to 'nParent', however that does not
 make the Parent think it has this new object as its child - someone must perform
 the 'Parent.SubElements.Add(<the new object>)' code after the call to
 ConstructQObject() to ensure that.
}
var
  I: Integer;
  S: String;
begin
  I := QObjectClassList.Count;

  repeat
    if (I=0) then
      break;
    Dec(I);
    S := QObjectClassList[I];
  until (Length(S)-1 <= Length(Name)) and (Length(S)>1)
    and (StrIComp(@Name[Length(Name)-Length(S)+2], PChar(S)+1) = 0);

  Result := QObjectClass(QObjectClassList.Objects[I]).Create(Copy(Name, 1, Length(Name)-Length(S)+1), nParent);
end;

function RequestClassOfType(const nTypeInfo: String) : QObjectClass;
{ (Comment by Decker 2002-06-20
 A function which will search for a class-type, that matches the requested
 'TypeInfo'. Returns the found class-type, or NIL if no match could be found.
}
var
  I: Integer;
  S: String;
begin
  for I:=0 to QObjectClassList.Count-1 do
  begin
    S:=QObjectClassList[I];
    if StrIComp(PChar(nTypeInfo), PChar(S)+1) = 0 then
    begin
      Result:=QObjectClass(QObjectClassList.Objects[I]);
      Exit;
    end;
  end;
  Result:=Nil;
end;

function NeedClassOfType(const nTypeInfo: String) : QObjectClass;
{ (Comment by Decker 2002-06-20)
 A function which will search for a class-type, that matches the requested
 'TypeInfo'. Returns the found class-type, or raises an exception if no match
 could be found.
}
begin
  Result:=RequestClassOfType(nTypeInfo);
  if Result=Nil then
  begin
    Raise EErrorFmt(5644, [nTypeInfo]);
  end;
end;

procedure ListFileExt(L: TStrings);
var
  I: Integer;
  C: QObjectClass;
  Info: TFileObjectClassInfo;
  S: String;
begin
  for I:=QObjectClassList.Count-1 downto 0 do
  begin
    S:=QObjectClassList[I];
    if S[1]='a' then
      Continue;
    C:=QObjectClass(QObjectClassList.Objects[I]);
    if C.InheritsFrom(QFileObject) then
    begin
      QFileObjectClass(C).FileObjectClassInfo(Info);
      if Info.FileExt<>0 then
      begin
        L.Add(Info.DefaultExt);
        L.Add(LoadStr1(Info.FileExt));
      end;
      SetLength(Info.FileObjectDescriptionText,0);
      SetLength(Info.DefaultExt,0);
      SetLength(Info.PythonMacro,0);
      {DanielPharos: Not really good to do it this way
      but it's better than leaking memory!}
    end;
  end;
end;

procedure BuildFileExt(L: TStrings);
{ (Comment by Decker 2002-06-20)
 Builds a string-list, containing all the supported file-types, and inserts
 a "Known types" at the top of the list, with all file-types(extensions) as
 the mask.
}
var
  I: Integer;
  C: QObjectClass;
  Info: TFileObjectClassInfo;
  AllTypes1, AllTypes2, S: String;
begin
  AllTypes1:='';
  AllTypes2:='';
  for I:=QObjectClassList.Count-1 downto 0 do
  begin
    S:=QObjectClassList[I];
    if S[1]='a' then
      Continue;
    C:=QObjectClass(QObjectClassList.Objects[I]);
    if C.InheritsFrom(QFileObject) then
    begin
      QFileObjectClass(C).FileObjectClassInfo(Info);
      if Info.FileExt<>0 then
      begin
        L.Add(LoadStr1(Info.FileExt));
        if Info.DefaultExt <> '' then
        begin
          if AllTypes1 <> '' then
          begin
            AllTypes1 := AllTypes1 + ' ';
            AllTypes2 := AllTypes2 + ';';
          end;
          AllTypes1 := AllTypes1 +        Info.DefaultExt;
          AllTypes2 := AllTypes2 + '*.' + Info.DefaultExt;
        end;
      end;
      SetLength(Info.FileObjectDescriptionText,0);
      SetLength(Info.DefaultExt,0);
      SetLength(Info.PythonMacro,0);
      {DanielPharos: Not really good to do it this way
      but it's better than leaking memory!}
    end;
  end;
  L.Insert(0, FmtLoadStr1(768, [AllTypes1, AllTypes2]));
end;

initialization
finalization
 QObjectClassList.Free;

end.
