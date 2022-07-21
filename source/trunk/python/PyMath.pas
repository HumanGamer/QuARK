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
unit PyMath;

interface

{$INCLUDE PyVersions.inc}

uses Windows, SysUtils, Coordinates, qmath, qquaternions, qmatrices, Python, Quarkx;

type
  PyVect = ^TyVect;
  TyVect = object(TyObject)
            V: TVect;
            Source3D: TCoordinates;
            ST: Boolean;
            OffScreen: Byte;
           end;
  PyVectST = ^TyVectST;
  TyVectST = object(TyVect)
              TexS, TexT: TDouble;
             end;
  PyQuaternion = ^TyQuaternion;
  TyQuaternion = object(TyObject)
                  Q: TQuaternion;
                 end;
  PyMatrix = ^TyMatrix;
  TyMatrix = object(TyObject)
              M: TMatrixTransformation;
             end;

 {------------------------}

function MakePyVect3(const nX, nY, nZ: Double) : PyVect;
function MakePyVect5(const nX, nY, nZ, nS, nT: Double) : PyVectST;
function MakePyVect(const nV: TVect) : PyVect;
function MakePyVectv(const v3: vec3_t) : PyVect;
{function MakePyVectvArray(Source: vec3_p; Count: Integer) : PyVect;}
function MakePyVectPtf(const P: TPointProj; Coord: TCoordinates) : PyVect;
function PyVect_AsPP(V: PyVect) : TPointProj;

function GetVectAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
function SetVectAttr(self: PyObject; attr: PChar; value: PyObject) : Integer; cdecl;
function CompareVect(v1, v2: PyObject) : Integer; cdecl;
function PrintVect(self: PyObject) : PyObject; cdecl;
function VectToStr(self: PyObject) : PyObject; cdecl;

function VectorAdd(v1, v2: PyObject) : PyObject; cdecl;
function VectorSubtract(v1, v2: PyObject) : PyObject; cdecl;
function VectorMultiply(v1, v2: PyObject) : PyObject; cdecl;
function VectorDivide(v1, v2: PyObject) : PyObject; cdecl;
function VectorNegative(v1: PyObject) : PyObject; cdecl;
function VectorPositive(v1: PyObject) : PyObject; cdecl;
function VectorAbsolute(v1: PyObject) : PyObject; cdecl;
function VectorNonZero(v1: PyObject) : Integer; cdecl;
function VectorXor(v1, v2: PyObject) : PyObject; cdecl;
function VectorCoerce(var v1, v2: PyObject) : Integer; cdecl;

const
 VectNumbers: TyNumberMethods =
  (nb_add:         VectorAdd;
   nb_subtract:    VectorSubtract;
   nb_multiply:    VectorMultiply;
   nb_divide:      VectorDivide;
   nb_negative:    VectorNegative;
   nb_positive:    VectorPositive;
   nb_absolute:    VectorAbsolute;
   nb_nonzero:     VectorNonZero;
   nb_xor:         VectorXor;
   nb_coerce:      VectorCoerce);

var
 TyVect_Type: TyTypeObject =
  (ob_refcnt:      1;
   tp_name:        'vector';
   tp_basicsize:   SizeOf(TyVect);
   tp_dealloc:     SimpleDestructor;
   tp_getattr:     GetVectAttr;
   tp_setattr:     SetVectAttr;
   tp_compare:     CompareVect;
   tp_repr:        PrintVect;
   tp_as_number:   @VectNumbers;
   tp_str:         VectToStr;
   tp_doc:         'A vector in 3D space.');

 {------------------------}

function MakePyQuaternion(const nQ: TQuaternion) : PyQuaternion; overload;
function MakePyQuaternion(nX, nY, nZ, nW: TDouble) : PyQuaternion; overload;

function GetQuaternionAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
function PrintQuaternion(self: PyObject) : PyObject; cdecl;
function QuaternionToStr(self: PyObject) : PyObject; cdecl;

function QuaternionAdd(v1, v2: PyObject) : PyObject; cdecl;
function QuaternionSubtract(v1, v2: PyObject) : PyObject; cdecl;
function QuaternionMultiply(v1, v2: PyObject) : PyObject; cdecl;
function QuaternionDivide(v1, v2: PyObject) : PyObject; cdecl;
function QuaternionNegative(v1: PyObject) : PyObject; cdecl;
function QuaternionPositive(v1: PyObject) : PyObject; cdecl;
function QuaternionAbsolute(v1: PyObject) : PyObject; cdecl;
function QuaternionNonZero(v1: PyObject) : Integer; cdecl;
function QuaternionInvert(v1: PyObject) : PyObject; cdecl;
function QuaternionCoerce(var v1, v2: PyObject) : Integer; cdecl;

const
 QuaternionNumbers: TyNumberMethods =
  (nb_add:         QuaternionAdd;
   nb_subtract:    QuaternionSubtract;
   nb_multiply:    QuaternionMultiply;
   nb_divide:      QuaternionDivide;
   nb_negative:    QuaternionNegative;
   nb_positive:    QuaternionPositive;
   nb_absolute:    QuaternionAbsolute;
   nb_nonzero:     QuaternionNonZero;
   nb_invert:      QuaternionInvert;
   nb_coerce:      QuaternionCoerce);

var
 TyQuaternion_Type: TyTypeObject =
  (ob_refcnt:      1;
   tp_name:        'quaternion';
   tp_basicsize:   SizeOf(TyQuaternion);
   tp_dealloc:     SimpleDestructor;
   tp_getattr:     GetQuaternionAttr;
   tp_repr:        PrintQuaternion;
   tp_as_number:   @QuaternionNumbers;
   tp_str:         QuaternionToStr;
   tp_doc:         'A quaternion.');

 {------------------------}

function GetMatrixAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
function PrintMatrix(self: PyObject) : PyObject; cdecl;
function MatrixToStr(self: PyObject) : PyObject; cdecl;
function MakePyMatrix(const nMatrix: TMatrixTransformation; transposed : boolean = false) : PyMatrix;

function MatrixLength(m: PyObject) : {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; cdecl;
function MatrixSubscript(m, ij: PyObject) : PyObject; cdecl;
function MatrixAssSubscript(m, ij, value: PyObject) : Integer; cdecl;

function MatrixAdd(v1, v2: PyObject) : PyObject; cdecl;
function MatrixSubtract(v1, v2: PyObject) : PyObject; cdecl;
function MatrixMultiply(v1, v2: PyObject) : PyObject; cdecl;
function MatrixDivide(v1, v2: PyObject) : PyObject; cdecl;
function MatrixNegative(v1: PyObject) : PyObject; cdecl;
function MatrixPositive(v1: PyObject) : PyObject; cdecl;
function MatrixAbsolute(v1: PyObject) : PyObject; cdecl;
function MatrixNonZero(v1: PyObject) : Integer; cdecl;
function MatrixInvert(v1: PyObject) : PyObject; cdecl;
function MatrixCoerce(var v1, v2: PyObject) : Integer; cdecl;

const
 TyMatrix_Mapping: TyMappingMethods =
  (mp_length:        MatrixLength;
   mp_subscript:     MatrixSubscript;
   mp_ass_subscript: MatrixAssSubscript);
 MatrixNumbers: TyNumberMethods =
  (nb_add:         MatrixAdd;
   nb_subtract:    MatrixSubtract;
   nb_multiply:    MatrixMultiply;
   nb_divide:      MatrixDivide;
   nb_negative:    MatrixNegative;
   nb_positive:    MatrixPositive;
   nb_absolute:    MatrixAbsolute;
   nb_nonzero:     MatrixNonZero;
   nb_invert:      MatrixInvert;
   nb_coerce:      MatrixCoerce);

var
 TyMatrix_Type: TyTypeObject =
  (ob_refcnt:      1;
   tp_name:        'matrix';
   tp_basicsize:   SizeOf(TyMatrix);
   tp_dealloc:     SimpleDestructor;
   tp_getattr:     GetMatrixAttr;
   tp_repr:        PrintMatrix;
   tp_as_number:   @MatrixNumbers;
   tp_as_mapping:  @TyMatrix_Mapping;
   tp_str:         MatrixToStr;
   tp_doc:         'A 3x3 matrix.');

 {------------------------}

implementation

uses qdraw, QkExceptions, QkMapObjects, QkMapPoly, Qk3D;

const
 COERCEDFROMFLOAT : TDouble = -1E308; //Sentinel value if object was created through coercing of a float value.

 {------------------------}

{const
 MethodTable: array[0..7] of TyMethodDef =
  ((ml_name: 'subitem';       ml_meth: qSubItem;       ml_flags: METH_VARARGS),
   (ml_name: 'findname';      ml_meth: qFindName;      ml_flags: METH_VARARGS),
   (ml_name: 'findshortname'; ml_meth: qFindShortName; ml_flags: METH_VARARGS),
   (ml_name: 'getint';        ml_meth: qGetInt;        ml_flags: METH_VARARGS),
   (ml_name: 'setint';        ml_meth: qSetInt;        ml_flags: METH_VARARGS),
   (ml_name: 'appenditem';    ml_meth: qAppendItem;    ml_flags: METH_VARARGS),
   (ml_name: 'insertitem';    ml_meth: qInsertItem;    ml_flags: METH_VARARGS),
   (ml_name: 'removeitem';    ml_meth: qRemoveItem;    ml_flags: METH_VARARGS));}

function GetVectAttr(self: PyObject; attr: PChar) : PyObject;
{var
 I, N: Integer;}
var
 V1: TVect;
 o: PyObject;
begin
 Result:=Nil;
 try
 {for I:=Low(MethodTable) to High(MethodTable) do
   if StrComp(attr, MethodTable[I].ml_name) = 0 then
    begin
     Result:=PyCFunction_New(MethodTable[I], self);
     Exit;
    end;}
  case attr[0] of
   '_': if StrComp(attr, '__getstate__')=0 then
         begin
          Result:=PyDict_New();
          o:=PyTuple_New(3);
          try
           PyTuple_SetItem(o, 0, PyFloat_FromDouble(PyVect(self)^.V.x));
           PyTuple_SetItem(o, 1, PyFloat_FromDouble(PyVect(self)^.V.y));
           PyTuple_SetItem(o, 2, PyFloat_FromDouble(PyVect(self)^.V.z));
           PyDict_SetItemString(Result, 'v', o);
          finally
           Py_DECREF(o);
          end;
          Exit;
         end;
   'c': if StrComp(attr, 'copy')=0 then
         begin
          Result:=MakePyVect(PyVect(self)^.V);
          Exit;
         end;
   'n': if StrComp(attr, 'normalized')=0 then
         begin
          V1:=PyVect(self)^.V;
          Normalise(V1);
          Result:=MakePyVect(V1);
          Exit;
         end;
   'o': if StrComp(attr, 'offscreen')=0 then
         begin
          with PyVect(self)^ do
           Result:=PyInt_FromLong(OffScreen);
          Exit;
         end;
   's': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyVectST(self)^.TexS);
          Exit;
         end
         else if (attr[1]='t') and (attr[2]=#0) then
         begin
           with PyVectST(self)^ do
            Result:=Py_BuildValueDD(TexS, TexT);
           Exit;
         end;
   't':  if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyVectST(self)^.TexT);
          Exit;
         end
         else if StrComp(attr, 'tuple')=0 then
         begin
          with PyVect(self)^.V do
           Result:=Py_BuildValueDDD(X, Y, Z);
          Exit;
         end
        else if (attr[1]='e') and (attr[2]='x') and PyVect(self)^.ST then
         if attr[3]=#0 then
          begin
           with PyVectST(self)^ do
            Result:=Py_BuildValueDD(TexS, TexT);
           Exit;
          end
         else
          if (attr[3]='_') and (attr[5]=#0) then
           case attr[4] of
            's': begin
                  Result:=PyFloat_FromDouble(PyVectST(self)^.TexS);
                  Exit;
                 end;
            't': begin
                  Result:=PyFloat_FromDouble(PyVectST(self)^.TexT);
                  Exit;
                 end;
           end;
   'v': if StrComp(attr, 'visible')=0 then
         begin
          with PyVect(self)^ do
           if Source3D=Nil then
            Result:=PyInt_FromLong(-1)
           else
            Result:=PyInt_FromLong(Ord((OffScreen and Source3D.HiddenRegions)=0));
          Exit;
         end;
   'x': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyVect(self)^.V.X);
          Exit;
         end
         else if StrComp(attr,'xyz')=0 then
          begin
           with PyVect(self)^.V do
            Result:=Py_BuildValueDDD(X, Y, Z);
           Exit;
         end
         else if StrComp(attr,'xyzst')=0 then
          begin
           with PyVect(self)^.V do
            with PyVectST(self)^ do
             Result:=Py_BuildValueD5(X, Y, Z, TexS, TexT);
           Exit;
          end;
   'y': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyVect(self)^.V.Y);
          Exit;
         end;
   'z': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyVect(self)^.V.Z);
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

function SetVectAttr(self: PyObject; attr: PChar; value: PyObject) : Integer;
var
 o: PyObject;
begin
 try
  Result:=-1;
  case attr[0] of
   '_': if StrComp(attr, '__setstate__') = 0 then
         begin
          o:=PyDict_GetItemString(value, 'v');
          if o=Nil then Exit;
          PyVect(self)^.V.x:=PyFloat_AsDouble(PyTuple_GetItem(o, 0));
          PyVect(self)^.V.y:=PyFloat_AsDouble(PyTuple_GetItem(o, 1));
          PyVect(self)^.V.z:=PyFloat_AsDouble(PyTuple_GetItem(o, 2));
          Result:=0;
          Exit;
         end;
 (*'n': if StrComp(attr, 'name') = 0 then
         begin
          P:=PyString_AsString(value);
          if P=Nil then Exit;
          with QkObjFromPyObj(self) do
           Name:=P;
          Result:=0;
          Exit;
         end;*)
  end;
  PyErr_SetString(QuarkxError, PChar(LoadStr1(4429)));
  Result:=-1;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function CompareVect(v1, v2: PyObject) : Integer;
var
 oow1, oow2: Single;
 Src3D: TCoordinates;
begin
 Result:=0;
 try
  Src3D:=Nil;
  if v1^.ob_type = @TyVect_Type then
   begin
    oow1:=PyVect(v1)^.V.Z;
    Src3D:=PyVect(v1)^.Source3D;
   end
  else
   oow1:=PyFloat_AsDouble(v1);
  if v2^.ob_type = @TyVect_Type then
   begin
    oow2:=PyVect(v2)^.V.Z;
    Src3D:=PyVect(v2)^.Source3D;
   end
  else
   oow2:=PyFloat_AsDouble(v2);
  if Src3D=Nil then
   begin
    {Raise EError(4447);}
    Exit;
   end;
  if oow1<>oow2 then
   if Src3D.NearerThan(oow1, oow2) then
    Result:=-1
   else
    Result:=1;
 except
  EBackToPython;
 end;
end;

function PrintVect(self: PyObject) : PyObject;
var
 S: String;
begin
 Result:=Nil;
 try
  S:='<vect '+vtos(PyVect(self)^.V)+'>';
  if PyVect(self)^.ST then
   S:=Copy(S, 1, Length(S)-1) + ' ' + ftos(PyVectST(self)^.TexS)
                              + ' ' + ftos(PyVectST(self)^.TexT) + '>';
  Result:=PyString_FromString(PChar(S));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectToStr(self: PyObject) : PyObject;
var
 S: String;
begin
 Result:=Nil;
 try
  S:=vtos(PyVect(self)^.V);
  Result:=PyString_FromString(PChar(S));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MakePyVect3(const nX, nY, nZ: Double) : PyVect;
begin
 Result:=PyVect(PyObject_New(@TyVect_Type));
 with PyVect(Result)^ do
  begin
   V.X:=nX;
   V.Y:=nY;
   V.Z:=nZ;
   Source3D:=Nil;
   ST:=False;
  end;
end;

function MakePyVect5(const nX, nY, nZ, nS, nT: Double) : PyVectST;
begin
  GetMem(Result, SizeOf(TyVectST));
  Result:=PyVectST(PyObject_Init(Result, @TyVect_Type));
  with PyVectST(Result)^ do
  begin
    V.X:=nX;
    V.Y:=nY;
    V.Z:=nZ;
    Source3D:=Nil;
    ST:=True;
    TexS:=nS;
    TexT:=nT;
  end;
end;

function MakePyVectv(const v3: vec3_t) : PyVect;
begin
 Result:=PyVect(PyObject_New(@TyVect_Type));
 with PyVect(Result)^ do
  begin
   V.X:=v3[0];
   V.Y:=v3[1];
   V.Z:=v3[2];
   Source3D:=Nil;
   ST:=False;
  end;
end;

(*function MakePyVectvArray(Source: vec3_p; Count: Integer) : PyVect;
var
 P: PyObject;
 I: Integer;
begin
 Result:=Nil;
 GetMem(P, SizeOf(TyVect)*Count);
 Inc(Source, Count);
 Inc(P, Count);
 for I:=1 to Count do
  begin
   Dec(Source);
   Dec(P);
   Result:=PyVect(_PyObject_New(@TyVect_Type, P));
   with Result^ do
    begin
     V.X:=Source^[0];
     V.Y:=Source^[1];
     V.Z:=Source^[2];
     Source3D:=Nil;
     ST:=False;
    end;
  end;
end;*)

function MakePyVect(const nV: TVect) : PyVect;
begin
 Result:=PyVect(PyObject_New(@TyVect_Type));
 with PyVect(Result)^ do
  begin
   V:=nV;
   Source3D:=Nil;
   ST:=False;
  end;
end;

function MakePyVectPtf(const P: TPointProj; Coord: TCoordinates) : PyVect;
begin
 Result:=PyVect(PyObject_New(@TyVect_Type));
 with PyVect(Result)^ do
  begin
   V.X:=P.x;
   V.Y:=P.y;
   V.Z:=P.oow;
   Source3D:=Coord;
   OffScreen:=P.OffScreen;
   ST:=False;
  end;
end;

function PyVect_AsPP(V: PyVect) : TPointProj;
begin
 with V^ do
  begin
   Result.x:=V.X;
   Result.y:=V.Y;
   Result.oow:=V.Z;
   Result.OffScreen:=OffScreen;
  end;
end;

 {------------------------}

function PyVectST_S(v1: PyObject) : TDouble;
begin
 if PyVect(v1)^.ST then
  Result:=PyVectST(v1)^.TexS
 else
  Result:=0;
end;

function PyVectST_T(v1: PyObject) : TDouble;
begin
 if PyVect(v1)^.ST then
  Result:=PyVectST(v1)^.TexT
 else
  Result:=0;
end;

function VectorAdd(v1, v2: PyObject) : PyObject;
var
 W1, W2: TVect;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyVect_Type)
  or (v2^.ob_type <> @TyVect_Type) then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  W2:=PyVect(v2)^.V;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y = COERCEDFROMFLOAT) then
   Raise EError(4443);
  if PyVect(v1)^.ST or PyVect(v2)^.ST then
   begin
    Result:=MakePyVect5(W1.X+W2.X, W1.Y+W2.Y, W1.Z+W2.Z,
                        PyVectST_S(v1)+PyVectST_S(v2),
                        PyVectST_T(v1)+PyVectST_T(v2));
   end
  else
   Result:=MakePyVect3(W1.X+W2.X, W1.Y+W2.Y, W1.Z+W2.Z);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorSubtract(v1, v2: PyObject) : PyObject;
var
 W1, W2: TVect;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyVect_Type)
  or (v2^.ob_type <> @TyVect_Type) then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  W2:=PyVect(v2)^.V;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y = COERCEDFROMFLOAT) then
   Raise EError(4443);
  if PyVect(v1)^.ST or PyVect(v2)^.ST then
   Result:=MakePyVect5(W1.X-W2.X, W1.Y-W2.Y, W1.Z-W2.Z,
                       PyVectST_S(v1)-PyVectST_S(v2),
                       PyVectST_T(v1)-PyVectST_T(v2))
  else
   Result:=MakePyVect3(W1.X-W2.X, W1.Y-W2.Y, W1.Z-W2.Z);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorMultiply(v1, v2: PyObject) : PyObject;
var
 W1, W2, W: TVect;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyVect_Type)
  or (v2^.ob_type <> @TyVect_Type) then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  W2:=PyVect(v2)^.V;
  if (W1.Y <> COERCEDFROMFLOAT)
  and (W2.Y <> COERCEDFROMFLOAT) then
   Result:=PyFloat_FromDouble(Dot(W1,W2))
  else
   begin
    if (W1.Y = COERCEDFROMFLOAT)
    or (W2.Y <> COERCEDFROMFLOAT) then
     begin
      W:=W1;
      W1:=W2;
      W2:=W;
      if (W1.Y = COERCEDFROMFLOAT)
      or (W2.Y <> COERCEDFROMFLOAT) then
       Raise EError(4443);
      v1:=v2;
     end;
    if PyVect(v2)^.ST then
     Result:=MakePyVect5(W1.X*W2.X, W1.Y*W2.X, W1.Z*W2.X,
                         PyVectST(v1)^.TexS*W2.X,
                         PyVectST(v1)^.TexT*W2.X)
    else
     Result:=MakePyVect3(W1.X*W2.X, W1.Y*W2.X, W1.Z*W2.X);
   end;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorDivide(v1, v2: PyObject) : PyObject;
var
 W1, W2: TVect;
 f: TDouble;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyVect_Type)
  or (v2^.ob_type <> @TyVect_Type) then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  W2:=PyVect(v2)^.V;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y <> COERCEDFROMFLOAT) then
   Raise EError(4443);
  f:=1/W2.X;
  if PyVect(v1)^.ST then
   Result:=MakePyVect5(W1.X*f, W1.Y*f, W1.Z*f,
                       PyVectST(v1)^.TexS*f,
                       PyVectST(v1)^.TexT*f)
  else
   Result:=MakePyVect3(W1.X*f, W1.Y*f, W1.Z*f);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorNegative(v1: PyObject) : PyObject;
var
 W1: TVect;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyVect_Type then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  if PyVect(v1)^.ST then
   Result:=MakePyVect5(-W1.X, -W1.Y, -W1.Z,
                       -PyVectST(v1)^.TexS,
                       -PyVectST(v1)^.TexT)
  else
   Result:=MakePyVect3(-W1.X, -W1.Y, -W1.Z);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorPositive(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyVect_Type then
   Raise EError(4443);
  Result:=MakePyVect(PyVect(v1)^.V);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorAbsolute(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyVect_Type then
   Raise EError(4443);
  Result:=PyFloat_FromDouble(VecLength(PyVect(v1)^.V));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorNonZero(v1: PyObject) : Integer;
var
 W1: TVect;
begin
 try
  if v1^.ob_type <> @TyVect_Type then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  if (Abs(W1.X)<rien) and (Abs(W1.Y)<rien) and (Abs(W1.Z)<rien) then
   Result:=0
  else
   Result:=1;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function VectorXor(v1, v2: PyObject) : PyObject;
var
 W1, W2: TVect;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyVect_Type)
  or (v2^.ob_type <> @TyVect_Type) then
   Raise EError(4443);
  W1:=PyVect(v1)^.V;
  W2:=PyVect(v2)^.V;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y = COERCEDFROMFLOAT) then
   Raise EError(4443);
  Result:=MakePyVect(Cross(W1,W2));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function VectorCoerce(var v1, v2: PyObject) : Integer;
var
 f: TDouble;
 v3: PyObject;
begin
 try
  Result:=-1;
  if v2^.ob_type <> @TyVect_Type then
   begin
    v3:=PyNumber_Float(v2);
    if v3=Nil then Exit;
    f:=PyFloat_AsDouble(v3);
    Py_DECREF(v3);
    v2:=MakePyVect3(f, COERCEDFROMFLOAT, COERCEDFROMFLOAT);
   end
  else
   Py_INCREF(v2);
  Py_INCREF(v1);
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

 {------------------------}

function GetQuaternionAttr(self: PyObject; attr: PChar) : PyObject;
var
 Q1: TQuaternion;
begin
 Result:=Nil;
 try
  case attr[0] of
   'c': if StrComp(attr, 'copy')=0 then
         begin
          Result:=MakePyQuaternion(PyQuaternion(self)^.Q);
          Exit;
         end;
   'n': if StrComp(attr, 'normalized')=0 then
         begin
          Q1:=PyQuaternion(self)^.Q;
          QuaternionNormalise(Q1);
          Result:=MakePyQuaternion(Q1);
          Exit;
         end;
   'w': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyQuaternion(self)^.Q.W);
          Exit;
         end;
   'x': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyQuaternion(self)^.Q.X);
          Exit;
         end
         else if StrComp(attr,'xyz')=0 then
          begin
           with PyQuaternion(self)^.Q do
            Result:=Py_BuildValueDDD(X, Y, Z);
           Exit;
         end
         else if StrComp(attr,'xyzw')=0 then
          begin
           with PyQuaternion(self)^.Q do
            Result:=Py_BuildValueD4(X, Y, Z, W);
           Exit;
          end;
   'y': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyQuaternion(self)^.Q.Y);
          Exit;
         end;
   'z': if attr[1]=#0 then
         begin
          Result:=PyFloat_FromDouble(PyQuaternion(self)^.Q.Z);
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

function PrintQuaternion(self: PyObject) : PyObject;
var
 S: String;
begin
 Result:=Nil;
 try
  S:='<quaternion '+qtos(PyQuaternion(self)^.Q)+'>';
  Result:=PyString_FromString(PChar(S));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionToStr(self: PyObject) : PyObject;
var
 S: String;
begin
 Result:=Nil;
 try
  S:=qtos(PyQuaternion(self)^.Q);
  Result:=PyString_FromString(PChar(S));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MakePyQuaternion(const nQ: TQuaternion) : PyQuaternion;
begin
 Result:=PyQuaternion(PyObject_New(@TyQuaternion_Type));
 with PyQuaternion(Result)^ do
  begin
   Q:=nQ;
  end;
end;

function MakePyQuaternion(nX, nY, nZ, nW: TDouble) : PyQuaternion;
begin
 Result:=PyQuaternion(PyObject_New(@TyQuaternion_Type));
 with PyQuaternion(Result)^.Q do
  begin
   X:=nX;
   Y:=nY;
   Z:=nZ;
   W:=nW;
  end;
end;

 {------------------------}

function QuaternionAdd(v1, v2: PyObject) : PyObject;
var
 W1, W2: TQuaternion;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyQuaternion_Type)
  or (v2^.ob_type <> @TyQuaternion_Type) then
   Raise EError(4463);
  W1:=PyQuaternion(v1)^.Q;
  W2:=PyQuaternion(v2)^.Q;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y = COERCEDFROMFLOAT) then
   Raise EError(4463);
  Result:=MakePyQuaternion(W1.X+W2.X, W1.Y+W2.Y, W1.Z+W2.Z, W1.W+W2.W);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionSubtract(v1, v2: PyObject) : PyObject;
var
 W1, W2: TQuaternion;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyQuaternion_Type)
  or (v2^.ob_type <> @TyQuaternion_Type) then
   Raise EError(4463);
  W1:=PyQuaternion(v1)^.Q;
  W2:=PyQuaternion(v2)^.Q;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y = COERCEDFROMFLOAT) then
   Raise EError(4463);
  Result:=MakePyQuaternion(W1.X-W2.X, W1.Y-W2.Y, W1.Z-W2.Z, W1.W-W2.W);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionMultiply(v1, v2: PyObject) : PyObject;
var
 W1, W2, W: TQuaternion;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyQuaternion_Type)
  or (v2^.ob_type <> @TyQuaternion_Type) then
   Raise EError(4463);
  W1:=PyQuaternion(v1)^.Q;
  W2:=PyQuaternion(v2)^.Q;
  if (W1.Y <> COERCEDFROMFLOAT)
  and (W2.Y <> COERCEDFROMFLOAT) then
   Result:=MakePyQuaternion(MultiplyQuaternions(PyQuaternion(v1)^.Q, PyQuaternion(v2)^.Q))
  else
   begin
    if (W1.Y = COERCEDFROMFLOAT)
    or (W2.Y <> COERCEDFROMFLOAT) then
     begin
      W:=W1;
      W1:=W2;
      W2:=W;
      if (W1.Y = COERCEDFROMFLOAT)
      or (W2.Y <> COERCEDFROMFLOAT) then
       Raise EError(4463);
      v1:=v2;
     end;
    Result:=MakePyQuaternion(W1.X*W2.X, W1.Y*W2.X, W1.Z*W2.X, W1.W*W2.X);
   end;
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionDivide(v1, v2: PyObject) : PyObject;
var
 W1, W2: TQuaternion;
 f: TDouble;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyQuaternion_Type)
  or (v2^.ob_type <> @TyQuaternion_Type) then
   Raise EError(4463);
  W1:=PyQuaternion(v1)^.Q;
  W2:=PyQuaternion(v2)^.Q;
  if (W1.Y = COERCEDFROMFLOAT)
  or (W2.Y <> COERCEDFROMFLOAT) then
   Raise EError(4463);
  f:=1/W2.X;
  Result:=MakePyQuaternion(W1.X*f, W1.Y*f, W1.Z*f, W1.W*f);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionNegative(v1: PyObject) : PyObject;
var
 W1: TQuaternion;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyQuaternion_Type then
   Raise EError(4463);
  W1:=PyQuaternion(v1)^.Q;
  Result:=MakePyQuaternion(-W1.X, -W1.Y, -W1.Z, -W1.W);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionPositive(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyQuaternion_Type then
   Raise EError(4443);
  Result:=MakePyQuaternion(PyQuaternion(v1)^.Q);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionAbsolute(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyQuaternion_Type then
   Raise EError(4463);
  Result:=PyFloat_FromDouble(QuaternionNorm(PyQuaternion(v1)^.Q));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionNonZero(v1: PyObject) : Integer;
var
 W1: TQuaternion;
begin
 try
  if v1^.ob_type <> @TyQuaternion_Type then
   Raise EError(4463);
  W1:=PyQuaternion(v1)^.Q;
  if (Abs(W1.X)<rien) and (Abs(W1.Y)<rien) and (Abs(W1.Z)<rien) and (Abs(W1.W)<rien) then
   Result:=0
  else
   Result:=1;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function QuaternionInvert(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyQuaternion_Type then
   Raise EError(4463);
  Result:=MakePyQuaternion(QuaternionInverse(PyQuaternion(v1)^.Q));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function QuaternionCoerce(var v1, v2: PyObject) : Integer;
var
 f: TDouble;
 v3: PyObject;
begin
 try
  Result:=-1;
  if v2^.ob_type <> @TyQuaternion_Type then
   begin
    v3:=PyNumber_Float(v2);
    if v3=Nil then Exit;
    f:=PyFloat_AsDouble(v3);
    Py_DECREF(v3);
    v2:=MakePyQuaternion(f, COERCEDFROMFLOAT, COERCEDFROMFLOAT, COERCEDFROMFLOAT);
   end
  else
   Py_INCREF(v2);
  Py_INCREF(v1);
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

 {------------------------}

function GetMatrixAttr(self: PyObject; attr: PChar) : PyObject;
var
 I: Integer;
 obj: array[1..3] of PyObject;
begin
 Result:=Nil;
 try
 {for I:=Low(MethodTable) to High(MethodTable) do
   if StrComp(attr, MethodTable[I].ml_name) = 0 then
    begin
     Result:=PyCFunction_New(MethodTable[I], self);
     Exit;
    end;}
  case attr[0] of
   'c': if StrComp(attr, 'copy')=0 then
         begin
          Result:=MakePyMatrix(PyMatrix(self)^.M);
          Exit;
         end
        else if StrComp(attr, 'cols')=0 then
         begin
          with PyMatrix(self)^ do
           for I:=1 to 3 do
            obj[I]:=MakePyVect3(M[1,I], M[2,I], M[3,I]);
          try
           Result:=Py_BuildValueX('OOO', [obj[1], obj[2], obj[3]]);
          finally
           for I:=3 downto 1 do
            Py_DECREF(obj[I]);
          end;
          Exit;
         end;
   't':  if StrComp(attr, 'transposed')=0 then
         begin
           Result:=MakePyMatrix(PyMatrix(self)^.M,true);
           Exit;
         end
         else if StrComp(attr, 'tuple')=0 then
         begin
          with PyMatrix(self)^ do
           for I:=1 to 3 do
            obj[I]:=Py_BuildValueDDD(M[I,1], M[I,2], M[I,3]);
          try
           Result:=Py_BuildValueX('OOO', [obj[1], obj[2], obj[3]]);
          finally
           for I:=3 downto 1 do
            Py_DECREF(obj[I]);
          end;
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

function PrintMatrix(self: PyObject) : PyObject;
var
 S: String;
begin
 Result:=Nil;
 try
  S:='<matrix '+mxtos(PyMatrix(self)^.M)+'>';
  Result:=PyString_FromString(PChar(S));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixToStr(self: PyObject) : PyObject;
var
 S: String;
begin
 Result:=Nil;
 try
  S:=mxtos(PyMatrix(self)^.M);
  Result:=PyString_FromString(PChar(S));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MakePyMatrix(const nMatrix: TMatrixTransformation; transposed : boolean=false) : PyMatrix;
begin
  Result:=PyMatrix(PyObject_New(@TyMatrix_Type));
  if transposed then
    Result^.M:=MatriceTranspose(nMatrix)
  else
    Result^.M:=nMatrix;
end;

function MatrixLength(m: PyObject) : {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF};
begin
 try
  Raise EError(4444);
 except
  EBackToPython;
  Result:=0;
 end;
end;

function MatrixSubscript(m, ij: PyObject) : PyObject;
var
 I, J: Integer;
begin
 Result:=Nil;
 try
  if not PyArg_ParseTupleX(ij, 'ii:matrix[i,j]', [@I, @J]) then
   Exit;
  if (I<0) or (J<0) or (I>=3) or (J>=3) then
   Raise EError(4444);
  Result:=PyFloat_FromDouble(PyMatrix(m)^.M[I+1,J+1]);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixAssSubscript(m, ij, value: PyObject) : Integer;
var
 I, J: Integer;
begin
 try
  Result:=-1;
  if not PyArg_ParseTupleX(ij, 'ii:matrix[i,j]', [@I, @J]) then
   Exit;
  if (I<0) or (J<0) or (I>=3) or (J>=3) then
   Raise EError(4444);
  PyMatrix(m)^.M[I+1,J+1]:=PyFloat_AsDouble(value);
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

 {------------------------}

function MatrixAdd(v1, v2: PyObject) : PyObject;
var
 M: TMatrixTransformation;
 I, J: Integer;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyMatrix_Type)
  or (v2^.ob_type <> @TyMatrix_Type)
  or (PyMatrix(v1)^.M[2,2] = COERCEDFROMFLOAT)
  or (PyMatrix(v2)^.M[2,2] = COERCEDFROMFLOAT) then
   Raise EError(4444);
  for I:=1 to 3 do
   for J:=1 to 3 do
    M[I,J]:=PyMatrix(v1)^.M[I,J] + PyMatrix(v2)^.M[I,J];
  Result:=MakePyMatrix(M);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixSubtract(v1, v2: PyObject) : PyObject;
var
 M: TMatrixTransformation;
 I, J: Integer;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyMatrix_Type)
  or (v2^.ob_type <> @TyMatrix_Type)
  or (PyMatrix(v1)^.M[2,2] = COERCEDFROMFLOAT)
  or (PyMatrix(v2)^.M[2,2] = COERCEDFROMFLOAT) then
   Raise EError(4444);
  for I:=1 to 3 do
   for J:=1 to 3 do
    M[I,J]:=PyMatrix(v1)^.M[I,J] - PyMatrix(v2)^.M[I,J];
  Result:=MakePyMatrix(M);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixMultiply(v1, v2: PyObject) : PyObject;
var
 M: TMatrixTransformation;
 v3: PyObject;
 I, J: Integer;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyMatrix_Type)
  or (v2^.ob_type <> @TyMatrix_Type) then
   Raise EError(4444);
  if (PyMatrix(v1)^.M[2,2] <> COERCEDFROMFLOAT)
  and (PyMatrix(v2)^.M[2,2] <> COERCEDFROMFLOAT) then
   M:=MultiplieMatrices(PyMatrix(v1)^.M, PyMatrix(v2)^.M)
  else
   begin
    if PyMatrix(v1)^.M[2,1] = COERCEDFROMFLOAT then
     begin
      v3:=v1;
      v1:=v2;
      v2:=v3;
     end;
    if PyMatrix(v1)^.M[2,2] = COERCEDFROMFLOAT then
     Raise EError(4444);
    if PyMatrix(v2)^.M[2,1] = COERCEDFROMFLOAT then
     for I:=1 to 3 do
      for J:=1 to 3 do
       M[I,J]:=PyMatrix(v1)^.M[I,J] * PyMatrix(v2)^.M[1,1]
    else
     begin
      for I:=1 to 3 do
       begin
        M[I,1]:=0;
        for J:=1 to 3 do
         M[I,1]:=M[I,1] + PyMatrix(v1)^.M[I,J] * PyMatrix(v2)^.M[J,1];
       end;
      Result:=MakePyVect3(M[1,1], M[2,1], M[3,1]);
      Exit;
     end;
   end;
  Result:=MakePyMatrix(M);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixDivide(v1, v2: PyObject) : PyObject;
var
 M: TMatrixTransformation;
 F: TDouble;
 I, J: Integer;
begin
 Result:=Nil;
 try
  if (v1^.ob_type <> @TyMatrix_Type)
  or (v2^.ob_type <> @TyMatrix_Type) then
   Raise EError(4444);
  if (PyMatrix(v1)^.M[2,2] <> COERCEDFROMFLOAT)
  and (PyMatrix(v2)^.M[2,2] <> COERCEDFROMFLOAT) then
   M:=MultiplieMatrices(PyMatrix(v1)^.M, MatriceInverse(PyMatrix(v2)^.M))
  else
   begin
    if (PyMatrix(v1)^.M[2,2] = COERCEDFROMFLOAT)
    or (PyMatrix(v2)^.M[2,1] <> COERCEDFROMFLOAT) then
     begin
      if (PyMatrix(v1)^.M[2,1] <> COERCEDFROMFLOAT)
      or (PyMatrix(v2)^.M[2,2] = COERCEDFROMFLOAT) then
       Raise EError(4444);
      F:=PyMatrix(v1)^.M[1,1];
      M:=MatriceInverse(PyMatrix(v2)^.M);
     end
    else
     begin
      M:=PyMatrix(v1)^.M;
      F:=1.0/PyMatrix(v2)^.M[1,1];
     end;
    for I:=1 to 3 do
     for J:=1 to 3 do
      M[I,J]:=M[I,J] * F;
   end;
  Result:=MakePyMatrix(M);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixNegative(v1: PyObject) : PyObject;
var
 M: TMatrixTransformation;
 I, J: Integer;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyMatrix_Type then
   Raise EError(4444);
  for I:=1 to 3 do
   for J:=1 to 3 do
    M[I,J]:=-PyMatrix(v1)^.M[I,J];
  Result:=MakePyMatrix(M);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixPositive(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyMatrix_Type then
   Raise EError(4444);
  Result:=MakePyMatrix(PyMatrix(v1)^.M);
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixAbsolute(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyMatrix_Type then
   Raise EError(4444);
  Result:=PyFloat_FromDouble(Determinant(PyMatrix(v1)^.M));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixNonZero(v1: PyObject) : Integer;
var
 I, J: Integer;
begin
 try
  if v1^.ob_type <> @TyMatrix_Type then
   Raise EError(4444);
  Result:=1;
  for I:=1 to 3 do
   for J:=1 to 3 do
    if Abs(PyMatrix(v1)^.M[I,J]) >= rien then
     Exit;
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

function MatrixInvert(v1: PyObject) : PyObject;
begin
 Result:=Nil;
 try
  if v1^.ob_type <> @TyMatrix_Type then
   Raise EError(4444);
  Result:=MakePyMatrix(MatriceInverse(PyMatrix(v1)^.M));
 except
  Py_XDECREF(Result);
  EBackToPython;
  Result:=Nil;
 end;
end;

function MatrixCoerce(var v1, v2: PyObject) : Integer;
var
 v3: PyObject;
 M: TMatrixTransformation;
begin
 try
  Result:=-1;
  if v2^.ob_type <> @TyMatrix_Type then
   begin
    if v2^.ob_type = @TyVect_Type then
     with PyVect(v2)^.V do
      begin
       M[1,1]:=X;
       M[2,1]:=Y;
       M[3,1]:=Z;
      end
    else
     begin
      v3:=PyNumber_Float(v2);
      if v3=Nil then Exit;
      M[1,1]:=PyFloat_AsDouble(v3);
      Py_DECREF(v3);
      M[2,1]:=COERCEDFROMFLOAT;
     end;
    M[2,2]:=COERCEDFROMFLOAT;
    v2:=MakePyMatrix(M);
   end
  else
   Py_INCREF(v2);
  Py_INCREF(v1);
  Result:=0;
 except
  EBackToPython;
  Result:=-1;
 end;
end;

end.
