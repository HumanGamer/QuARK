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
unit PyObjects;

interface

uses SysUtils, Classes, Python, QkObjects, Dialogs;

{$IFDEF DEBUG}
{$DEFINE PyObjDEBUG}
{$ENDIF}

 {-------------------}

function QkObjFromPyObj(o: PyObject) : QObject;
function GetPyObj(Q: QObject) : PyObject;
function QListToPyList(L: TQList) : PyObject;
procedure PyListToQList(list: PyObject; L: TQList; Cls: QObjectClass);
function GetPySpecArg(var Spec: String; value: PyObject) : String;

procedure PythonObjDestructor(o: PyObject); cdecl;
function GetObjAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
function SetObjAttr(self: PyObject; attr: PChar; value: PyObject) : Integer; cdecl;
function ObjRepr(self: PyObject) : PyObject; cdecl;
{function GetFileObjAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
function SetFileObjAttr(self: PyObject; attr: PChar; value: PyObject) : Integer; cdecl;}
function GetObjSpec(self, o: PyObject) : PyObject; cdecl;
function SetObjSpec(self, o, value: PyObject) : Integer; cdecl;

var
 TyObjectMapping: TyMappingMethods =
  (mp_subscript:     GetObjSpec;
   mp_ass_subscript: SetObjSpec);

 TyObject_Type: TyTypeObject =
  (ob_refcnt:      1;
   tp_name:        'QuArK Internal';
   tp_basicsize:   SizeOf(TPythonObj);
   tp_dealloc:     PythonObjDestructor;
   tp_getattr:     GetObjAttr;
   tp_setattr:     SetObjAttr;
   tp_repr:        ObjRepr;
   tp_as_mapping:  @TyObjectMapping;
   tp_doc:         'An internal object for QuArK.');

 {-------------------}

function qSubItem(self, args: PyObject) : PyObject; cdecl;
function qFindName(self, args: PyObject) : PyObject; cdecl;
function qFindShortName(self, args: PyObject) : PyObject; cdecl;
function qGetInt(self, args: PyObject) : PyObject; cdecl;
function qSetInt(self, args: PyObject) : PyObject; cdecl;
function qToggleSel(self, args: PyObject) : PyObject; cdecl;
function qAppendItem(self, args: PyObject) : PyObject; cdecl;
function qInsertItem(self, args: PyObject) : PyObject; cdecl;
function qRemoveItem(self, args: PyObject) : PyObject; cdecl;
function qAcceptItem(self, args: PyObject) : PyObject; cdecl;
function qCopy(self, args: PyObject) : PyObject; cdecl;
function qNextInGroup(self, args: PyObject) : PyObject; cdecl;
function qFindAllSubItems(self, args: PyObject) : PyObject; cdecl;
function qCopyAllData(self, args: PyObject) : PyObject; cdecl;
function qLoadText(self, args: PyObject) : PyObject; cdecl;
function qGetIcon(self, args: PyObject) : PyObject; cdecl;
function qRefreshTV(self, args: PyObject) : PyObject; cdecl;
function qSpecAdd(self, args: PyObject) : PyObject; cdecl;
function qIsAllowedParent(self, args: PyObject) : PyObject; cdecl;

const
 PyObjMethodTable: array[0..18] of TyMethodDef =
  ((ml_name: 'subitem';         ml_meth: qSubItem;         ml_flags: METH_VARARGS),
   (ml_name: 'findname';        ml_meth: qFindName;        ml_flags: METH_VARARGS),
   (ml_name: 'findshortname';   ml_meth: qFindShortName;   ml_flags: METH_VARARGS),
   (ml_name: 'getint';          ml_meth: qGetInt;          ml_flags: METH_VARARGS),
   (ml_name: 'setint';          ml_meth: qSetInt;          ml_flags: METH_VARARGS),
   (ml_name: 'togglesel';       ml_meth: qToggleSel;       ml_flags: METH_VARARGS),
   (ml_name: 'appenditem';      ml_meth: qAppendItem;      ml_flags: METH_VARARGS),
   (ml_name: 'insertitem';      ml_meth: qInsertItem;      ml_flags: METH_VARARGS),
   (ml_name: 'removeitem';      ml_meth: qRemoveItem;      ml_flags: METH_VARARGS),
   (ml_name: 'acceptitem';      ml_meth: qAcceptItem;      ml_flags: METH_VARARGS),
   (ml_name: 'copy';            ml_meth: qCopy;            ml_flags: METH_VARARGS),
   (ml_name: 'nextingroup';     ml_meth: qNextInGroup;     ml_flags: METH_VARARGS),
   (ml_name: 'findallsubitems'; ml_meth: qFindAllSubItems; ml_flags: METH_VARARGS),
   (ml_name: 'copyalldata';     ml_meth: qCopyAllData;     ml_flags: METH_VARARGS),
   (ml_name: 'loadtext';        ml_meth: qLoadText;        ml_flags: METH_VARARGS),
   (ml_name: 'geticon';         ml_meth: qGetIcon;         ml_flags: METH_VARARGS),
   (ml_name: 'refreshtv';       ml_meth: qRefreshTV;       ml_flags: METH_VARARGS),
   (ml_name: 'specificadd';     ml_meth: qSpecAdd;         ml_flags: METH_VARARGS),
   (ml_name: 'isallowedparent'; ml_meth: qIsAllowedParent; ml_flags: METH_VARARGS));

 {-------------------}

implementation

uses Quarkx, QkExceptions, QkFileObjects, QkObjectClassList, QkExplorer, qhelper, WorkaroundStringCompare;

 {-------------------}

function QkObjFromPyObj1(o: PyObject) : QObject; register;
asm
 sub eax, offset QObject.PythonObj
end;

function QkObjFromPyObj(o: PyObject) : QObject;
begin
 if (o=Nil) or (o^.ob_type<>@TyObject_Type) then
  Result:=Nil
 else
  Result:=QkObjFromPyObj1(o);
end;

function GetPyObj(Q: QObject) : PyObject;
begin
 if Q=Nil then
  Result:=Py_None
 else
  Result:=@Q.PythonObj;
 Py_INCREF(Result);
end;

function QListToPyList(L: TQList) : PyObject;
var
 I: Integer;
begin
 Result:=PyList_New(L.Count);
 for I:=0 to L.Count-1 do
  PyList_SetItem(Result, I, GetPyObj(L[I]));
end;

procedure PyListToQList(list: PyObject; L: TQList; Cls: QObjectClass);
var
 I, Count: Integer;
 Q: QObject;
begin
 Count:=PyObject_Length(list);
 L.Capacity:=L.Count+Count;
 for I:=0 to Count-1 do
  begin
   Q:=QkObjFromPyObj(PyList_GetItem(list, I));
   if not (Q is Cls) then
    Raise EErrorFmt(4450, [Copy(Cls.ClassName, 2, MaxInt)]);
   L.Add(Q);
  end;
end;

procedure PythonObjDestructor(o: PyObject); cdecl;
begin
 try
  QkObjFromPyObj(o).Free;
 except
  EBackToPython;
 end;
end;

function GetObjAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
begin
 Result:=Nil;
 try
  Result:=QkObjFromPyObj(self).PyGetAttr(attr);
  if Result=Nil then
   PyErr_SetString(QuarkxError, PChar(LoadStr1(4429)));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function SetObjAttr(self: PyObject; attr: PChar; value: PyObject) : Integer; cdecl;
begin
 Result:=-1;
 try
  if not QkObjFromPyObj(self).PySetAttr(attr, value) then
   begin
    PyErr_SetString(QuarkxError, PChar(LoadStr1(4429)));
    Exit;
   end;
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function ObjRepr(self: PyObject) : PyObject; cdecl;
var
 Q: QObject;
 s {$IFDEF PyObjDEBUG}, s1 {$ENDIF}: string;
begin
 Result:=Nil;
 try
  Q:=QkObjFromPyObj(self);
{$IFDEF PyObjDEBUG}
  if Q=nil then
   s1:=''
  else
   s1:=QObjectClass(Q.ClassType).ClassName;
  s:=Format('<%s object at 0x%p, name: "%s", class: "%s">', [self.ob_type.tp_name, self, Q.Name+Q.TypeInfo, s1]);
{$ELSE}
  s:=Format('<%s object, name: "%s">', [self.ob_type.tp_name, Q.Name+Q.TypeInfo]);
{$ENDIF}
  Result:=PyString_FromString(PChar(s));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qSubItem(self, args: PyObject) : PyObject; cdecl;
var
 Index: Integer;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'i', [@Index]) then
   Exit;
  with QkObjFromPyObj(self) do
   begin
    Acces;
    if (Index<0) or (Index>=SubElements.Count) then
     begin
      PyErr_SetString(QuarkxError, PChar(LoadStr1(4420)));
      Exit;
     end;
    Result:=GetPyObj(SubElements[Index]);
   end;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qAppendItem(self, args: PyObject) : PyObject; cdecl;
var
 Obj1: PyObject;
 nParent, nChild: QObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'O!', [@TyObject_Type, @Obj1]) then
   Exit;
  nChild:=QkObjFromPyObj(Obj1);
  nParent:=QkObjFromPyObj(self);
  nParent.Acces;
  nChild.PySetParent(nParent);
  nParent.SubElements.Add(nChild);
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qInsertItem(self, args: PyObject) : PyObject; cdecl;
var
 Obj1: PyObject;
 nParent, nChild: QObject;
 Index: Integer;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'iO!', [@Index, @TyObject_Type, @Obj1]) then
   Exit;
  nChild:=QkObjFromPyObj(Obj1);
  if nChild.FParent<>Nil then
   begin
    PyErr_SetString(QuarkxError, PChar(LoadStr1(4422)));
    Exit;
   end;
  nParent:=QkObjFromPyObj(self);
  nParent.Acces;
  if (Index<0) or (Index>nParent.SubElements.Count) then
   begin
    PyErr_SetString(QuarkxError, PChar(LoadStr1(4423)));
    Exit;
   end;
  nChild.PySetParent(nParent);
  nParent.SubElements.Insert(Index, nChild);
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qRemoveItem(self, args: PyObject) : PyObject; cdecl;
var
 Obj1: PyObject;
 nParent, nChild: QObject;
 Index: Integer;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'O', [@Obj1]) then
   Exit;
  nParent:=QkObjFromPyObj(self);
  nParent.Acces;
  if Obj1.ob_type <> @TyObject_Type then
   begin
    Index:=PyInt_AsLong(Obj1);
    if (Index<0) or (Index>=nParent.SubElements.Count) then
     begin
      PyErr_SetString(QuarkxError, PChar(LoadStr1(4424)));
      Exit;
     end;
    nChild:=nParent.SubElements[Index];
   end
  else
   begin
    nChild:=QkObjFromPyObj(Obj1);
    Index:=nParent.SubElements.IndexOf(nChild);
    if Index<0 then
     begin
      PyErr_SetString(QuarkxError, PChar(LoadStr1(4425)));
      Exit;
     end;
   end;
  nChild.PySetParent(Nil);
  nParent.SubElements.Delete(Index);
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qFindName(self, args: PyObject) : PyObject; cdecl;
var
 nName: PChar;
 nParent: QObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 's', [@nName]) then
   Exit;
  nParent:=QkObjFromPyObj(self);
  nParent.Acces;
  Result:=GetPyObj(nParent.SubElements.FindName(nName));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qFindShortName(self, args: PyObject) : PyObject; cdecl;
var
 nName: PChar;
 nParent: QObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 's', [@nName]) then
   Exit;
  nParent:=QkObjFromPyObj(self);
  nParent.Acces;
  Result:=GetPyObj(nParent.SubElements.FindShortName(nName));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qGetInt(self, args: PyObject) : PyObject; cdecl;
var
 Spec: PChar;
 Q: QObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 's', [@Spec]) then
   Exit;
  Q:=QkObjFromPyObj(self);
  Q.Acces;
  Result:=PyInt_FromLong(Q.IntSpec[Spec]);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qSetInt(self, args: PyObject) : PyObject; cdecl;
var
 Spec: PChar;
 Q: QObject;
 value: Integer;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'si', [@Spec, @value]) then
   Exit;
  Q:=QkObjFromPyObj(self);
  Q.Acces;
  Q.IntSpec[Spec]:=value;
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qToggleSel(self, args: PyObject) : PyObject; cdecl;
var
 Q: QObject;
begin
 Result:=Nil;
 try
  Q:=QkObjFromPyObj(self);
  Q.ToggleSelMult;
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qCopy(self, args: PyObject) : PyObject; cdecl;
var
 Q, Q1: QObject;
 obj: PyObject;
{nparent: PyObject;}
begin
 Result:=Nil;
 try
  obj:=Py_None;
  if not PyArg_ParseTupleX(args, '|O', [@obj]) then
   Exit;
  Q:=QkObjFromPyObj(self);
 {nparent:=GetPyObj(Q.FParent);
  if not PyArg_ParseTupleX(args, '|O!', [@TyObject_Type, @nparent]) then
   Exit;}
  Q1:=Q.Clone({QkObjFromPyObj(nparent)}Nil, PyObject_IsTrue(obj));
  Result:=GetPyObj(Q1);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qAcceptItem(self, args: PyObject) : PyObject; cdecl;
var
 Obj1: PyObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'O!', [@TyObject_Type, @Obj1]) then
   Exit;
  Result:=PyInt_FromLong(Ord(
   ieCanDrop in QkObjFromPyObj(self).IsExplorerItem(QkObjFromPyObj(Obj1))));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qNextInGroup(self, args: PyObject) : PyObject; cdecl;
begin
 Result:=Nil;
 try
  Result:=GetPyObj(QkObjFromPyObj(self).NextInGroup);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qFindAllSubItems(self, args: PyObject) : PyObject; cdecl;
var
 name, wc, bc: PChar;
 nName: String;
 L: TQList;
 WantClass, Browse: QObjectClass;
 Q: QObject;
begin
 Result:=Nil;
 try
  bc:=Nil;
  if not PyArg_ParseTupleX(args, 'ss|s', [@name, @wc, @bc]) then
   Exit;
  nName:=name;
  WantClass:=NeedClassOfType(wc);
  if bc=Nil then
   Browse:=Nil
  else
   Browse:=NeedClassOfType(bc);
  L:=TQList.Create; try
  Q:=QkObjFromPyObj(self);
  if (Q is WantClass) and ((nName='') or SameText(Q.Name, nName)) then
   L.Add(Q);
  Q.FindAllSubObjects(nName, WantClass, Browse, L);
  Result:=QListToPyList(L);
  finally L.Free; end;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qCopyAllData(self, args: PyObject) : PyObject; cdecl;
var
 src: PyObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'O!', [@TyObject_Type, @src]) then
   Exit;
  QkObjFromPyObj(self).CopyAllData(QkObjFromPyObj(src), False);
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qLoadText(self, args: PyObject) : PyObject; cdecl;
var
 src: PChar;
 count: Integer;
 Q: QObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 's#', [@src, @count]) then
   Exit;
  Q:=QkObjFromPyObj(self);
  Q.Acces;
  ConstructObjsFromText(Q, src, count);
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qGetIcon(self, args: PyObject) : PyObject; cdecl;
var
 Q: QObject;
 o: PyObject;
 Sel1: Boolean;
 Info: TDisplayDetails;
begin
 Result:=Nil;
 try
  o:=Nil;
  if not PyArg_ParseTupleX(args, '|O', [@o]) then
   Exit;
  Q:=QkObjFromPyObj(self);
  if o=Nil then
   Sel1:=Odd(Q.SelMult)
  else
   Sel1:=PyObject_IsTrue(o);
  Q.DisplayDetails(Sel1, Info);
  if Info.Icon=Nil then
   Result:=PyNoResult
  else
   Result:=Info.Icon; //No Py_INCREF here; Q.DisplayDetails did that already
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

(*const
 PyObjMethodTable: array[0..8] of TyMethodDef =
  ((ml_name: 'subitem';       ml_meth: qSubItem;       ml_flags: METH_VARARGS),
   (ml_name: 'findname';      ml_meth: qFindName;      ml_flags: METH_VARARGS),
   (ml_name: 'findshortname'; ml_meth: qFindShortName; ml_flags: METH_VARARGS),
   (ml_name: 'getint';        ml_meth: qGetInt;        ml_flags: METH_VARARGS),
   (ml_name: 'setint';        ml_meth: qSetInt;        ml_flags: METH_VARARGS),
   (ml_name: 'togglesel';     ml_meth: qToggleSel;     ml_flags: METH_VARARGS),
   (ml_name: 'appenditem';    ml_meth: qAppendItem;    ml_flags: METH_VARARGS),
   (ml_name: 'insertitem';    ml_meth: qInsertItem;    ml_flags: METH_VARARGS),
   (ml_name: 'removeitem';    ml_meth: qRemoveItem;    ml_flags: METH_VARARGS));



var
 I, N: Integer;
 o: PyObject;
begin
 Result:=Nil;
 try
  for I:=Low(MethodTable) to High(MethodTable) do
   if StrComp(attr, MethodTable[I].ml_name) = 0 then
    begin
     Result:=PyCFunction_New(MethodTable[I], self);
     Exit;
    end;
  case attr[0] of
   'd': if StrComp(attr, 'dictitems') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Acces;
           N:=SubElements.Count;
           Result:=PyDict_New;
           for I:=N-1 downto 0 do
            begin
             o:=@SubElements[I].PythonObj;
             PyDict_SetItemString(Result, PChar(SubElements[I].GetFullName), o);
            end;
           Exit;
          end;
   'i': if StrComp(attr, 'itemcount') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Acces;
           Result:=PyInt_FromLong(SubElements.Count);
           Exit;
          end;
   'n': if StrComp(attr, 'name') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Result:=PyString_FromString(PChar(GetFullName));
           Exit;
          end;
   'p': if StrComp(attr, 'parent') = 0 then
         with QkObjFromPyObj(self) do
          begin
           if FParent=Nil then
            Result:=PyNoResult
           else
            Result:=GetPyObj(FParent);
           Exit;
          end;
   's': if StrComp(attr, 'selected') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Result:=PyInt_FromLong(Ord(Odd(SelMult)));
           Exit;
          end
        else if StrComp(attr, 'shortname') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Result:=PyString_FromString(PChar(Name));
           Exit;
          end
        else if StrComp(attr, 'subitems') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Acces;
           N:=SubElements.Count;
           Result:=PyList_New(N);
           for I:=0 to N-1 do
            begin
             o:=GetPyObj(SubElements[I]);
             PyList_SetItem(Result, I, o);
            end;
           Exit;
          end;
   't': if StrComp(attr, 'type') = 0 then
         with QkObjFromPyObj(self) do
          begin
           Result:=PyString_FromString(PChar(TypeInfo));
           Exit;
          end;
  end;
  PyErr_SetString(QuarkxError, PChar(LoadStr1(4429)));
  Result:=Nil;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function SetObjAttr(self: PyObject; attr: PChar; value: PyObject) : Integer; cdecl;
var
 P: PChar;
begin
 Result:=-1;
 try
  case attr[0] of
   'n': if StrComp(attr, 'name') = 0 then
         begin
          P:=PyString_AsString(value);
          if P=Nil then Exit;
          with QkObjFromPyObj(self) do
           Name:=P;
          Result:=0;
          Exit;
         end;
   's': if StrComp(attr, 'selected') = 0 then
         begin
          with QkObjFromPyObj(self) do
           if PyObject_IsTrue(value) then
            SetSelMult
           else
            if Odd(SelMult) then
             SelMult:=smNonSel;
          Result:=0;
          Exit;
         end
  end;
  PyErr_SetString(QuarkxError, PChar(LoadStr1(4429)));
  Result:=-1;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function GetFileObjAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
begin
 Result:=Nil;
 try
  case attr[0] of
   'f': if StrComp(attr, 'filename') = 0 then
         with QkObjFromPyObj(self) as QFileObject do
          begin
           Result:=PyString_FromString(PChar(Filename));
           Exit;
          end;
  end;
  Result:=GetObjAttr(self, attr);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function SetFileObjAttr(self: PyObject; attr: PChar; value: PyObject) : Integer; cdecl;
var
 P: PChar;
begin
 Result:=-1;
 try
  case attr[0] of
   'f': if StrComp(attr, 'filename') = 0 then
         begin
          P:=PyString_AsString(value);
          if P=Nil then Exit;
          with QkObjFromPyObj(self) as QFileObject do
           Filename:=P;
          Result:=0;
          Exit;
         end;
  end;
  Result:=SetObjAttr(self, attr, value);
 except
  EBackToPython;
  Result:=-1;
 end;
end;*)

//FIXME: Currently, we're accepting both lists and tuples when reading in specifics...
//(Don't forget the 'dictspec'-code in QkObjects!)

function GetObjSpec(self, o: PyObject) : PyObject; cdecl;
var
 P: PChar;
 I, J, N: Integer;
 S, Spec: String;
 PF: ^Single;
(* PI: ^Integer;*)
begin
 Result:=Nil;
 try
  P:=PyString_AsString(o);
  if P=Nil then Exit;
  Spec:=P;
  with QkObjFromPyObj(self) do
   begin
    Acces;
    I:=Strict_IndexOfName(Specifics, Spec); //I:=Specifics.IndexOfName(Spec);
    if I<0 then
     begin
      I:=Strict_IndexOfName(Specifics, FloatSpecNameOf(Spec)); //I:=Specifics.IndexOfName(FloatSpecNameOf(Spec));
      if I<0 then
       begin
(*        I:=Strict_IndexOfName(Specifics, IntSpecNameOf(Spec)); //I:=Specifics.IndexOfName(IntSpecNameOf(Spec));
        if I<0 then
         begin*)
          Result:=PyNoResult;
          Exit;
         end;
(*        S:=Specifics[I];
        I:=Length(Spec)+1;
        N:=(Length(S)-I) div 4;    { SizeOf(Integer) }
        PChar(PI):=PChar(S)+I;
        Result:=PyTuple_New(N);
        for J:=0 to N-1 do
         begin
          PyTuple_SetItem(Result, J, PyInt_FromLong(PI^));
          Inc(PI);
         end;
        Exit;
       end;*)
      S:=Specifics[I];
      I:=Length(Spec)+1;
      N:=(Length(S)-I) div 4;    { SizeOf(Single) }
      PChar(PF):=PChar(S)+I;
      Result:=PyTuple_New(N);
      for J:=0 to N-1 do
       begin
        PyTuple_SetItem(Result, J, PyFloat_FromDouble(PF^));
        Inc(PF);
       end;
      Exit;
     end;
    S:=Specifics[I];
    I:=Length(Spec)+1;
    Result:=PyString_FromStringAndSize(PChar(S)+I, Length(S)-I);
   end;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function GetPySpecArg(var Spec: String; value: PyObject) : String;
var
 nValue: PChar;
 I, N: Integer;
 obj: PyObject;
 PF: ^Single;
(* PI: ^Integer;*)
 IsTupleNotList: Boolean;
begin
 if value^.ob_type = PyString_Type then
  begin
   nValue:=PyString_AsString(value);
   if nValue=Nil then Abort;
   SetString(Result, nValue, PyString_Size(value));
   Exit;
  end;
 if value^.ob_type = PyInt_Type then
  begin
   Result:=IntToPackedStr(PyInt_AsLong(value));
   Exit;
  end;
 if (value.ob_type=PyTuple_Type) or (value.ob_type=PyList_Type) then
  begin
   if (value.ob_type=PyTuple_Type) then
    IsTupleNotList:=True
   else
    IsTupleNotList:=False;
   N:=PyObject_Length(value);
   if N<0 then Abort;
   SetLength(Result, N*4);   { SizeOf(Single) and SizeOf(Integer) }
(*   if IsTupleNotList then //FIXME: This fails if the list has zero entries!
    obj:=PyTuple_GetItem(value, 0)
   else
    obj:=PyList_GetItem(value, 0);
   if obj=Nil then Abort;
   if obj^.ob_type = PyInt_Type then
    begin
     PChar(PI):=PChar(Result);
     for I:=0 to N-1 do
      begin
       if IsTupleNotList then
        obj:=PyTuple_GetItem(value, I)
       else
        obj:=PyList_GetItem(value, I);
       if obj=Nil then Abort;
       if obj^.ob_type <> PyInt_Type then Abort;
       PI^:=PyInt_AsLong(obj);
       Inc(PI);
      end;
     Spec:=IntSpecNameOf(Spec);
    end
   else if obj^.ob_type = PyFloat_Type then
    begin*)
     PChar(PF):=PChar(Result);
     for I:=0 to N-1 do
      begin
       if IsTupleNotList then
        obj:=PyTuple_GetItem(value, I)
       else
        obj:=PyList_GetItem(value, I);
       if obj=Nil then Abort;
(*       if obj^.ob_type <> PyFloat_Type then Abort;*)
       PF^:=PyFloat_AsDouble(obj);
       Inc(PF);
      end;
     Spec:=FloatSpecNameOf(Spec);
(*    end
   else
    Abort;*)
  end
 else
  begin
   Abort;
 end;
end;

function SetObjSpec(self, o, value: PyObject) : Integer; cdecl;
var
 P: PChar;
 nSpec, S: String;
begin
 try
  Result:=-1;
  P:=PyString_AsString(o);
  if P=Nil then Exit;
  nSpec:=P;
  if value<>Py_None then
   S:=GetPySpecArg(nSpec, value);
  with QkObjFromPyObj(self) do
   begin
    Acces;
    if value<>Py_None then
     if value^.ob_type = PyFloat_Type then
      begin
       Specifics.Values[P]:='';
       Specifics.Values[FloatSpecNameOf(P)]:='';
       Specifics.Values[FloatSpecNameOf(nSpec)]:=S;
      end
     else
      begin
       Specifics.Values[P]:='';
       Specifics.Values[FloatSpecNameOf(P)]:='';
       Specifics.Values[nSpec]:=S;
      end
    else
     begin
      Specifics.Values[P]:='';
      Specifics.Values[FloatSpecNameOf(P)]:='';
     end;
   end;
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function qRefreshTV(self, args: PyObject) : PyObject; cdecl;
var
 Q: QObject;
 E: TQkExplorer;
begin
 Result:=Nil;
 try
  Q:=QkObjFromPyObj(self);
  if Q=nil then
    exit;
  E:=ExplorerFromObject(Q);
  if E<>nil then
    E.Refresh;
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qSpecAdd(self, args: PyObject) : PyObject; cdecl;
var
 Q: QObject;
 nSpec: PChar;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 's', [@nSpec]) then
    Exit;
  Q:=QkObjFromPyObj(self);
  if Q=nil then
    exit;
  Q.Specifics.Add(nSpec);
  Result:=PyNoResult;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function qIsAllowedParent(self, args: PyObject) : PyObject; cdecl;
var
 Q, Q1: QObject;
 obj: PyObject;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(args, 'O', [@obj]) then
    Exit;
  Q:=QkObjFromPyObj(self);
  if Q=nil then
    exit;
  Q1:=QkObjFromPyObj(obj);
  if Q1=nil then
    exit;
  Result:=PyInt_FromLong(Ord(Q.IsAllowedParent(Q1)));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

 {-------------------}

end.
