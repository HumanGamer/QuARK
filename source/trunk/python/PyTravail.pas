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

unit PyTravail;

interface

uses Classes, QkObjects, Travail, Python;

 {-------------------}

function GetProgressBarModule(nText, nCount: Integer) : PyObject;

 {-------------------}

implementation

uses Quarkx;

 {-------------------}

function tProgress(self, args: PyObject) : PyObject; cdecl;
begin
 try
  if PyList_GetItem(self,0)=Py_None then
   Raise EError(4451);
  ProgressIndicatorIncrement;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function tClose(self, args: PyObject) : PyObject; cdecl;
begin
 try
  if PyList_GetItem(self,0)<>Py_None then
   begin
    ProgressIndicatorStop;
    PyList_SetItem(self,0, PyNoResult);
   end;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function tChangeCount(self, args: PyObject) : PyObject; cdecl;
var
 nCount: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'i', [@nCount]) then
   Exit;
  if PyList_GetItem(self,0)=Py_None then
   Raise EError(4451);
  ProgressIndicatorChangeMax(-1, nCount);
  PyList_SetItem(self,0, PyInt_FromLong(nCount));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function tCount(self, args: PyObject) : PyObject; cdecl;
begin
 try
  Result:=PyList_GetItem(self,0);
  Py_INCREF(Result);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

 {-------------------}

const
 MethodTable: array[0..3] of TyMethodDef =
  ((ml_name: 'progress';    ml_meth: tProgress;    ml_flags: METH_VARARGS),
   (ml_name: 'changecount'; ml_meth: tChangeCount; ml_flags: METH_VARARGS),
   (ml_name: 'close';       ml_meth: tClose;       ml_flags: METH_VARARGS),
   (ml_name: 'count';       ml_meth: tCount;       ml_flags: METH_VARARGS));

function GetProgressBarModule;
var
 dict, obj, ok: PyObject;
 I: Integer;
begin
 Result:=PyModule_New('quarkx.progressbar');
 dict:=PyModule_GetDict(Result);
 ok:=PyList_New(1);
 PyList_SetItem(ok, 0, PyInt_FromLong(nCount));
 for I:=Low(MethodTable) to High(MethodTable) do
  begin
   obj:=PyCFunction_New(MethodTable[I], ok);
   PyDict_SetItemString(dict, MethodTable[I].ml_name, obj);
   Py_DECREF(obj);
  end;
 ProgressIndicatorStart(nText, nCount);
end;

 {-------------------}

end.
