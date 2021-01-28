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
unit Python;

{$IFDEF DEBUG}
{$DEFINE PyRefDEBUG}
{$DEFINE DebugPythonLeak}
{$ENDIF}

{.$DEFINE PyProfiling}

 {-------------------}

interface

uses ExtraFunctionality {$IFDEF PyProfiling}, Classes {$ENDIF};

{$INCLUDE PyVersions.inc}

type
 CFILE = Pointer;

 {$IFDEF PYTHON25}
 Py_ssize_t = ssize_t;
 Py_ssize_tPtr = ^Py_ssize_t;
 {$ENDIF}

 PyObjectPtr = ^PyObject;
 PyTypeObject = ^TyTypeObject;

 PyObject = ^TyObject;
 TyObject = object
             ob_refcnt: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF};
             ob_type: PyTypeObject;
            end;

 PyVarObject = ^TyVarObject;
 TyVarObject = object(TyObject)
                ob_size: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF};
               end;
 PyIntObject = ^TyIntObject;
 TyIntObject = object(TyObject)
                ob_ival: LongInt;
               end;
(* PyTupleObject = ^TyTupleObject;
 TyTupleObject = object(TyVarObject)
                  ob_item: array[0..0] of PyObject;
                 end;
 PyStringObject = ^TyStringObject;
 TyStringObject = object(TyVarObject)
                   ob_shash: LongInt;
                   ob_sstate: Integer;
                   ob_sval: array[0..0] of Char;
                  end; *)

 TyCFunction = function(self, args: PyObject) : PyObject; cdecl;
 TyCFunctionKey = function(self, args, keys: PyObject) : PyObject; cdecl;
 PTymethodDef = ^TyMethodDef;
 TyMethodDef = packed record
                ml_name: (*const*) PChar;
                case Integer of
                 0: (ml_meth: TyCFunction;
                     ml_flags: Integer;
                     ml_doc: (*const*) PChar);
                 1: (ml_keymeth: TyCFunctionKey);
               end;

 PPyMemberDef = ^PyMemberDef;
 PyMemberDef = packed record
   name : PChar;
   _type : integer;
   offset : {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF};
   flags : integer;
   doc : PChar;
 end;

 getter = function(ob : PyObject; ptr : Pointer) : PyObject; cdecl;
 setter = function(ob1, ob2 : PyObject; ptr : Pointer) : integer; cdecl;

 PPyGetSetDef = ^PyGetSetDef;
 PyGetSetDef = packed record
   name : PChar;
   get : getter;
   _set : setter;
   doc : PChar;
   closure : Pointer;
 end;

 FnUnaryFunc         = function(o1: PyObject) : PyObject; cdecl;
 FnBinaryFunc        = function(o1,o2: PyObject) : PyObject; cdecl;
 FnTernaryFunc       = function(o1,o2,o3: PyObject) : PyObject; cdecl;
 FnInquiry           = function(o: PyObject) : Integer; cdecl;
 {$IFDEF PYTHON25}FnLenfunc           = function(o: PyObject) : Py_ssize_t; cdecl;{$ENDIF}
 FnCoercion      = function(var o1, o2: PyObject) : Integer; cdecl;
 FnIntArgFunc        = function(o: PyObject; i1: Integer) : PyObject; cdecl;
 FnIntIntArgFunc     = function(o: PyObject; i1, i2: Integer) : PyObject; cdecl;
 {$IFDEF PYTHON25}FnSSizeArgFunc      = function(o: PyObject; i1: Py_ssize_t) : PyObject; cdecl;{$ENDIF}
 {$IFDEF PYTHON25}FnSSizeSSizeArgFunc = function(o: PyObject; i1: Py_ssize_t; i2: Py_ssize_t) : PyObject; cdecl;{$ENDIF}
 FnIntObjArgProc     = function(o: PyObject; i: Integer; o2: PyObject) : Integer; cdecl;
 FnIntIntObjArgProc  = function(o: PyObject; i1, i2: Integer; o2: PyObject) : Integer; cdecl;
 {$IFDEF PYTHON25}FnSSizeObjArgProc   = function(o: PyObject; i: Py_ssize_t; o2: PyObject) : Integer; cdecl;{$ENDIF}
 {$IFDEF PYTHON25}FnSSizeSSizeObjArgProc = function(o: PyObject; i1, i2: Py_ssize_t; o2: PyObject) : Integer; cdecl;{$ENDIF}
 FnObjObjArgProc     = function(o1,o2,o3: PyObject) : Integer; cdecl;

 //buffer interface
 FnReadBufferProc    = function(o: PyObject; i: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; p: Pointer): {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; cdecl;
 FnWriteBufferProc   = function(o: PyObject; i: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; p: Pointer): {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; cdecl;
 FnSegCountProc      = function(o: PyObject; i: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}): {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; cdecl;
 FnCharBufferProc    = function(o: PyObject; i: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; p: PChar): {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}; cdecl;
 {$IFDEF PYTHON26}
 FnGetBufferProc     = function(o: PyObject; p: Pointer; i: Integer): Integer; cdecl;
 FnReleaseBufferProc = procedure(o: PyObject; p: Pointer); cdecl;
 {$ENDIF}

 FnObjObjProc      = function(ob1, obj2: PyObject): integer; cdecl;
 FnVisitProc       = function(ob1: PyObject; ptr: Pointer): integer; cdecl;
 FnTraverseProc    = function(ob1: PyObject; proc: FnVisitProc; ptr: Pointer): integer; cdecl;

 FnFreeFunc      = procedure(ptr: Pointer); cdecl;
 FnDestructor    = procedure(o: PyObject); cdecl;
 FnPrintFunc     = function(o: PyObject; f: CFILE; i: Integer) : Integer; cdecl;
 FnGetAttrFunc   = function(o: PyObject; attr: PChar) : PyObject; cdecl;
 FnGetAttrOFunc  = function(o: PyObject; attr: PyObject) : PyObject; cdecl;
 FnSetAttrFunc   = function(o: PyObject; attr: PChar; v: PyObject) : Integer; cdecl;
 FnSetAttrOFunc  = function(o: PyObject; attr: PyObject; v: PyObject) : Integer; cdecl;
 FnCmpFunc       = function(o1, o2: PyObject) : Integer; cdecl;
 FnReprfunc      = function(o: PyObject) : PyObject; cdecl;
 FnHashfunc      = function(o: PyObject) : LongInt; cdecl;
 FnRichCmpFunc   = function(ob1, ob2 : PyObject; i : Integer) : PyObject; cdecl;
 FnGetIterFunc   = function(ob1 : PyObject) : PyObject; cdecl;
 FnIterNextFunc  = function(ob1 : PyObject) : PyObject; cdecl;
 FnDescrGetFunc  = function(ob1, ob2, ob3 : PyObject) : PyObject; cdecl;
 FnDescrSetFunc  = function(ob1, ob2, ob3 : PyObject) : Integer; cdecl;
 FnInitProc      = function(ob1, ob2, ob3 : PyObject) : Integer; cdecl;
 FnNewFunc       = function(t: PyTypeObject; ob1, ob2 : PyObject) : PyObject; cdecl;
 FnAllocFunc     = function(t: PyTypeObject; i : {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF}) : PyObject; cdecl;

 PyNumberMethods = ^TyNumberMethods;
 TyNumberMethods = packed record
                    nb_add, nb_subtract, nb_multiply,
                    nb_divide, nb_remainder, nb_divmod: FnBinaryFunc;
                    nb_power: FnTernaryFunc;
                    nb_negative, nb_positive, nb_absolute: FnUnaryFunc;
                    nb_nonzero: FnInquiry;
                    nb_invert: FnUnaryFunc;
                    nb_lshift, nb_rshift,
                    nb_and, nb_xor, nb_or: FnBinaryFunc;
                    nb_coerce: FnCoercion;
                    nb_int, nb_long, nb_float, nb_oct, nb_hex: FnUnaryFunc;
{$IFDEF PYTHON20}
                    nb_inplace_add, nb_inplace_subtract, nb_inplace_multiply,
                    nb_inplace_divide, nb_inplace_remainder: FnBinaryFunc;
                    nb_inplace_power: FnTernaryFunc;
                    nb_inplace_lshift, nb_inplace_rshift,
                    nb_inplace_and, nb_inplace_xor, nb_inplace_or: FnBinaryFunc;
{$ENDIF}
{$IFDEF PYTHON22}
                    // The following require the Py_TPFLAGS_HAVE_CLASS flag
                    nb_floor_divide, nb_true_divide, nb_inplace_floor_divide, nb_inplace_true_divide: FnBinaryFunc;
{$ENDIF}
{$IFDEF PYTHON25}
                    nb_index: FnUnaryFunc;
{$ENDIF}
                   end;

 PySequenceMethods = ^TySequenceMethods;
 TySequenceMethods = packed record
                      sq_length: {$IFDEF PYTHON25}FnLenfunc{$ELSE}FnInquiry{$ENDIF};
                      sq_concat: FnBinaryfunc;
                      sq_repeat: {$IFDEF PYTHON25}FnSSizeArgfunc{$ELSE}FnIntArgFunc{$ENDIF};
                      sq_item: {$IFDEF PYTHON25}FnSSizeArgfunc{$ELSE}FnIntArgFunc{$ENDIF};
                      sq_slice: {$IFDEF PYTHON25}FnSSizeSSizeArgfunc{$ELSE}FnIntIntArgFunc{$ENDIF};
                      sq_ass_item: {$IFDEF PYTHON25}FnSSizeObjArgproc{$ELSE}FnIntObjArgProc{$ENDIF};
                      sq_ass_slice: {$IFDEF PYTHON25}FnSSizeSSizeObjArgproc{$ELSE}FnIntIntObjArgProc{$ENDIF};
                      sq_contains: FnObjObjProc;
{$IFDEF PYTHON20}
                      sq_inplace_concat: FnBinaryFunc;
                      sq_inplace_repeat: {$IFDEF PYTHON25}FnSSizeArgFunc{$ELSE}FnIntArgFunc{$ENDIF};
{$ENDIF}
                     end;

 PyMappingMethods = ^TyMappingMethods;
 TyMappingMethods = packed record
                     mp_length: {$IFDEF PYTHON25}FnLenFunc{$ELSE}FnInquiry{$ENDIF};
                     mp_subscript: FnBinaryFunc;
                     mp_ass_subscript: FnObjObjArgProc;
                    end;

 PyBufferProcs = ^TyBufferProcs;
 TyBufferProcs = packed record
                  bf_getreadbuffer: FnReadBufferProc;
                  bf_getwritebuffer: FnWriteBufferProc;
                  bf_getsegcount: FnSegCountProc;
                  bf_getcharbuffer: FnCharBufferProc;
                  {$IFDEF PYTHON26}
                  bf_getbuffer: FnGetBufferProc;
                  bf_releasebuffer: FnReleaseBufferProc;
                  {$ENDIF}
                 end;

 TyTypeObject = object(TyVarObject)
                 tp_name: (*const*) PChar;
                 tp_basicsize, tp_itemsize: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF};

                 tp_dealloc: FnDestructor;
                 tp_print: FnPrintFunc;
                 tp_getattr: FnGetAttrFunc;
                 tp_setattr: FnSetAttrFunc;
                 tp_compare: FnCmpFunc;
                 tp_repr: FnReprFunc;

                 tp_as_number: PyNumberMethods;
                 tp_as_sequence: PySequenceMethods;
                 tp_as_mapping: PyMappingMethods;

                 tp_hash: FnHashfunc;
                 tp_call: FnTernaryfunc;
                 tp_str: FnReprfunc;
                 tp_getattro: FnGetattrofunc;
                 tp_setattro: FnSetattrofunc;

                 tp_as_buffer: PyBufferProcs;

                 tp_flags: LongInt;

                 tp_doc: PChar;

{$IFDEF PYTHON20}
                 tp_traverse:    FnTraverseProc;   // call function for all accessible objects
                 tp_clear:       FnInquiry;   // delete references to contained objects
{$ENDIF}
{$IFDEF PYTHON21}
                 tp_richcompare: FnRichCmpFunc;   // rich comparisons
                 tp_weaklistoffset: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}LongInt{$ENDIF};   // weak reference enabler
{$ENDIF}
{$IFDEF PYTHON22}
                 tp_iter: FnGetIterFunc;
                 tp_iternext: FnIterNextFunc;

                 tp_methods          : PTyMethodDef;
                 tp_members          : PPyMemberDef;
                 tp_getset           : PPyGetSetDef;
                 tp_base             : PyTypeObject;
                 tp_dict             : PyObject;
                 tp_descr_get        : FnDescrGetFunc;
                 tp_descr_set        : FnDescrSetFunc;
                 tp_dictoffset       : {$IFDEF PYTHON25}Py_ssize_t{$ELSE}LongInt{$ENDIF};
                 tp_init             : FnInitProc;
                 tp_alloc            : FnAllocFunc;
                 tp_new              : FnNewFunc;
                 tp_free             : FnFreeFunc; // Low-level free-memory routine
                 tp_is_gc            : FnInquiry; // For PyObject_IS_GC
                 tp_bases            : PyObject;
                 tp_mro              : PyObject; // method resolution order
                 tp_cache            : PyObject;
                 tp_subclasses       : PyObject;
                 tp_weaklist         : PyObject;
                 tp_del              : FnDestructor;
{$ENDIF}
{$IFDEF PYTHON26}
                 tp_version_tag      : Cardinal; //Type attribute cache version tag
{$ENDIF}
      end;

const
 // PYTHON_API_VERSION =
 //   1001 for Python ?
 //   1002 for Python ?
 //   1002 for Python ?
 //   1003 for Python ?
 //   1004 for Python ?
 //   1005 for Python ?
 //   1006 for Python 1.4?
 //   1007 for Python 1.5.1?
 //   1008 for Python 1.5.2b1 (NO LONGER SUPPORTED!) or 1.6?
 //   1009 for Python 2.0?
 //   1010 for Python 2.1a2 (and probably 2.1 as well)
 //   1011 for Python 2.2
 //   1012 for Python 2.3 and 2.4
 //   1013 for Python 2.5 and 2.6 and 2.7
 // Version info from here: http://svn.python.org/view/python/trunk/Include/modsupport.h
{$IFDEF PYTHON27}
 PYTHON_API_VERSION = 1013;
{$ELSE}

{$IFDEF PYTHON26}
 PYTHON_API_VERSION = 1013;
{$ELSE}

{$IFDEF PYTHON25}
 PYTHON_API_VERSION = 1013;
{$ELSE}

{$IFDEF PYTHON24}
 PYTHON_API_VERSION = 1012;
{$ELSE}

{$IFDEF PYTHON23}
 PYTHON_API_VERSION = 1012;
{$ELSE}

{$IFDEF PYTHON22}
 PYTHON_API_VERSION = 1011;
{$ELSE}

{$IFDEF PYTHON21}
 PYTHON_API_VERSION = 1010;
{$ELSE}

{$IFDEF PYTHON20}
 PYTHON_API_VERSION = 1009;
{$ELSE}

//Minimal support version is 2.0!
 PYTHON_API_VERSION = 1009;

{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

// METH_OLDARGS  = $0000; //Do not use!
 METH_VARARGS  = $0001;
 METH_KEYWORDS = $0002;
 METH_NOARGS   = $0004;
 METH_O        = $0008;
{$IFDEF PYTHON23}
 METH_CLASS    = $0010;
 METH_STATIC   = $0020;
{$ENDIF}
{$IFDEF PYTHON24}
 METH_COEXIST  = $0040;
{$ENDIF}

 {-------------------}

var

Py_Initialize: procedure; cdecl;
Py_Finalize: procedure; cdecl;
Py_SetProgramName: procedure (name : PChar); cdecl;
Py_GetVersion: function : (*const*) PChar; cdecl;
//Py_GetBuildNumber: function : (*const*) PChar; cdecl; //New in Python 2.5
//Py_GetPlatform: function : (*const*) PChar; cdecl;
//Py_GetCopyright: function : (*const*) PChar; cdecl;
//Py_GetCompiler: function : (*const*) PChar; cdecl;
//Py_GetBuildInfo: function : (*const*) PChar; cdecl;

PyRun_SimpleString: function (const P: PChar) : Integer; cdecl;
//PyRun_String: function (const str: PChar; start: Integer; Globals, Locals: PyObject) : PyObject; cdecl;
//Py_CompileString: function (const str, filename: PChar; start: Integer) : PyObject; cdecl;

//Py_InitModule: function (name: PChar; const MethodDef) : PyObject; cdecl;
//Py_InitModule3: function (name: PChar; const MethodDef; doc: PChar) : PyObject; cdecl;
Py_InitModule4: function (name: PChar; const MethodDef; doc: PChar; self: PyObject; Version: Integer) : PyObject; cdecl;
PyModule_GetDict: function (module: PyObject) : PyObject; cdecl;
PyModule_New: function (const name: PChar) : PyObject; cdecl;
//PyImport_ImportModule: function (const name: PChar) : PyObject; cdecl;

//PyEval_GetGlobals: function : PyObject; cdecl;
//PyEval_GetLocals: function : PyObject; cdecl;
//function PyEval_GetBuiltins : PyObject; cdecl;
PyEval_CallObject: function (o, args: PyObject) : PyObject; cdecl;
{$IFDEF PYTHON27}
//Python 2.7.x broke backwards compatibility without warning
PyEval_CallObjectWithKeywords: function (o, args, kw: PyObject) : PyObject; cdecl;
{$ENDIF}
PyCallable_Check: function (o: PyObject) : LongBool; cdecl;

PyErr_Print: procedure; cdecl;
PyErr_Clear: procedure; cdecl;
PyErr_Occurred: function : PyObject; cdecl;
PyErr_Fetch: procedure (var o1, o2, o3: PyObject); cdecl;
PyErr_Restore: procedure (o1, o2, o3: PyObject); cdecl;
PyErr_NewException: function (name: PChar; base, dict: PyObject) : PyObject; cdecl;
PyErr_SetString: procedure (o: PyObject; const c: PChar); cdecl;
//function PyErr_BadArgument : Integer; cdecl;
PyErr_ExceptionMatches: function (exc: PyObject) : LongBool; cdecl;

//function PyObject_Hash(o: PyObject) : LongInt; cdecl;
PyObject_Length: function (o: PyObject) : {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; cdecl;
//PyObject_GetItem: function (o, key: PyObject) : PyObject; cdecl;
PyObject_HasAttrString: function (o: PyObject; const attr_name: PChar) : LongBool; cdecl;
PyObject_GetAttrString: function (o: PyObject; const attr_name: PChar) : PyObject; cdecl;
PyObject_IsTrue: function (o: PyObject) : LongBool; cdecl;
PyObject_Str: function (o: PyObject) : PyObject; cdecl;
PyObject_Repr: function (o: PyObject) : PyObject; cdecl;
PySequence_GetItem: function (o: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject; cdecl;
PySequence_In: function (o, value: PyObject) : Integer; cdecl;
PySequence_Index: function (o, value: PyObject) : {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; cdecl;
PySequence_DelItem: function (o: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : Integer; cdecl;
PyMapping_HasKey: function (o, key: PyObject) : LongBool; cdecl;
PyMapping_HasKeyString: function (o: PyObject; key: PChar) : LongBool; cdecl;
PyNumber_Float: function (o: PyObject) : PyObject; cdecl;

Py_BuildValue: function (const fmt: PChar{...}) : PyObject; cdecl;
PyArg_ParseTuple: function (src: PyObject; const fmt: PChar{...}) : LongBool; cdecl;
//PyArg_ParseTupleAndKeywords: function (arg, kwdict: PyObject; const fmt: PChar; var kwlist: PChar{...}) : LongBool; cdecl;
PyTuple_New: function (size: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject; cdecl;
PyTuple_GetItem: function (tuple: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject; cdecl;
PyTuple_SetItem: function (tuple: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; item: PyObject) : Integer; cdecl;

PyList_New: function (size: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject; cdecl;
PyList_GetItem: function (list: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject; cdecl;
PyList_SetItem: function (list: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; item: PyObject) : Integer; cdecl;
PyList_Insert: function (list: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; item: PyObject) : Integer; cdecl;
PyList_Append: function (list: PyObject; item: PyObject) : Integer; cdecl;

PyDict_New: function : PyObject; cdecl;
PyDict_SetItemString: function (dict: PyObject; const key: PChar; item: PyObject) : Integer; cdecl;
PyDict_GetItemString: function (dict: PyObject; const key: PChar) : PyObject; cdecl;
PyDict_GetItem: function (dict, key: PyObject) : PyObject; cdecl;
PyDict_Keys: function (dict: PyObject) : PyObject; cdecl;
PyDict_Values: function (dict: PyObject) : PyObject; cdecl;
//function PyDict_Items(dict: PyObject) : PyObject; cdecl;
//function PyDict_DelItemString(dict: PyObject; key: PChar) : Integer; cdecl;
PyDict_Next: function (dict: PyObject; pos : {$IFDEF PYTHON25} Py_ssize_tPtr {$ELSE} PInteger {$ENDIF}; key : PyObjectPtr; value : PyObjectPtr) : Integer; cdecl;

PyString_FromString: function (const str: PChar) : PyObject; cdecl;
PyString_AsString: function (o: PyObject) : PChar; cdecl;
PyString_FromStringAndSize: function (const str: PChar; size: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject; cdecl;
PyString_Size: function (o: PyObject) : {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; cdecl;

PyInt_FromLong: function (Value: LongInt) : PyObject; cdecl;
PyInt_AsLong: function (o: PyObject) : LongInt; cdecl;

//NOT TESTED:
//Long integers in Python are unlimited in size
//(only limited by the amount of available memory)
//PyLong_FromLong: function (Value : LongInt) : PyObject; cdecl;
//PyLong_FromUnsignedLong: function (Value : Longword) : PyObject; cdecl;
//PyLong_FromSsize_t: function (Value : Py_ssize_t) : PyObject; cdecl; //New in Python 2.6
//PyLong_FromSize_t: function (Value : size_t) : PyObject; cdecl; //New in Python 2.6
//PyLong_FromDouble: function (Value : Double) : PyObject; cdecl;
//PyLong_AsLong: function (o : PyObject) : LongInt; cdecl;
//PyLong_AsLongAndOverflow: function (o : PyObject, overflow : PInteger) : LongInt; cdecl; //New in Python 2.7
//PyLong_AsSsize_t: function(o : PyObject) : Py_ssize_t; cdecl; //New in Python 2.6
//PyLong_AsUnsignedLong: function(o : PyObject) : Longword; cdecl;
//PyLong_AsUnsignedLongMask: function (o : PyObject) : Longword; cdecl; //New in Python 2.3

PyFloat_FromDouble: function (Value: Double) : PyObject; cdecl;
PyFloat_AsDouble: function (o: PyObject) : Double; cdecl;

PyObject_Init: function (o: PyObject; t: PyTypeObject) : PyObject; cdecl;

// function _PyObject_NewVar(t: PyTypeObject; i: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}; o: PyObject) : PyObject; cdecl;

PyCFunction_New: function (const Def: TyMethodDef; self: PyObject) : PyObject; cdecl;

//New in Python 2.3: (NOT TESTED)
//PyBool_Check: function (o: PyObject) : Integer; cdecl;
//Py_False: function : PyObject; cdecl;
//Py_True: function : PyObject; cdecl;
//PyBool_FromLong: function (Value: LongInt) : PyObject; cdecl;

PyGC_Collect: procedure; cdecl;

{$IFDEF PyProfiling}
type
  PyCodeObject = ^TyCodeObject;
  TyCodeObject = object(TyObject)
    co_argcount, co_nlocals, co_stacksize, co_flags: Integer;
    co_code, co_consts, co_names, co_varnames: PyObject;
    {$IFDEF PYTHON21}
    co_freevars, co_cellvars: PyObject;
    {$ENDIF}
    co_filename, co_name: PyObject;
    co_firstlineno: Integer;
    co_lnotab: PyObject;
    {$IFDEF PYTHON25}
    co_zombieframe: Pointer;
    {$ENDIF}
    {$IFDEF PYTHON27}
    co_weakreflist: PyObject;
    {$ENDIF}
  end;

const
  CO_MAXBLOCKS = 20;

type
  PyTryBlock = packed record
    b_type, b_handler, b_level: Integer;
  end;

  PyFrameObject = ^TyFrameObject;
  TyFrameObject = object(TyVarObject)
    f_back: PyFrameObject;
    f_code: PyCodeObject;
    f_builtins: PyObject;
    f_globals: PyObject;
    f_locals: PyObject;
    f_valuestack: ^PyObject;

    f_stacktop: ^PyObject;
    f_trace: PyObject;

    f_exc_type, f_exc_value, f_exc_traceback: PyObject;

    f_tstate: Pointer; //Actually PyThreadState, but Delphi can't handle forward record declarations, so we have to break the cyclical dependancy.
    f_lasti, f_lineno, f_iblock: Integer;

    f_blockstack: packed array[0..CO_MAXBLOCKS-1] of PyTryBlock;
    f_localsplus: array of PyObject; //dynamically sized
  end;

{$IFDEF PYTHON22}
type
  Py_tracefunc = function(obj: PyObject; frame: PyFrameObject; what: Integer; arg: PyObject) : Integer;
{$ENDIF}

type
  PyInterpreterState = ^TyInterpreterState;
  TyInterpreterState = packed record
    next, tstate_head: PyInterpreterState;
    modules, sysdict, builtins: PyObject;
    {$IFDEF PYTHON26}
    modules_reloading: PyObject;
    {$ENDIF}
    {$IFDEF PYTHON22}
    codec_search_path, codec_search_cache, codec_error_registry: PyObject;
    {$ELSE}
    checkinterval: Integer;
    {$ENDIF}
    //dlopenflags: Integer; //HAVE_DLOPEN
    {$IFDEF PYTHON24}
    //tscdump: Integer; //WITH_TSC
    {$ENDIF}
  end;

  PyThreadState = ^TyThreadState;
  TyThreadState = packed record
    next: PyThreadState;
    interp: PyInterpreterState;

    frame: PyFrameObject;
    recursion_depth: Integer;

    {$IFNDEF PYTHON23}
    ticker: Integer;
    {$ENDIF}
    tracing: Integer;
    {$IFDEF PYTHON22}
    use_tracing: Integer;
    {$ENDIF}

    {$IFDEF PYTHON22}
    c_profilefunc: Py_tracefunc;
    c_tracefunc: Py_tracefunc;
    c_profileobj: PyObject;
    c_traceobj: PyObject;
    {$ELSE}
    sys_profilefunc, sys_tracefunc: PyObject;
    {$ENDIF}

    curexc_type, curexc_value, curexc_traceback: PyObject;
    exc_type, exc_value, exc_traceback: PyObject;

    dict: PyObject;

    {$IFDEF PYTHON23}
    tick_counter, gilstate_counter: Integer;

    async_exc: PyObject;
    thread_id: LongInt;

    (* These were added in Python 2.7.4:
    trash_delete_nesting: Integer;
    trash_delete_later: PyObject;
    *)
    {$ENDIF}
  end;

var
  PyThreadState_Get: function : PyThreadState; cdecl;
  {$IFDEF PYTHON23}
  PyCode_Addr2Line: function(co: PyCodeObject; addrq: Integer) : Integer; cdecl;
  {$ENDIF}
{$ENDIF}

 {-------------------}

function PyObject_NEW(t: PyTypeObject) : PyObject;
{function PyObject_NEWVAR(t: PyTypeObject; i: Integer) : PyObject;}
procedure PyObject_DEL(o: PyObject);
function Py_BuildValueX(const fmt: PChar; Args: array of const) : PyObject;
function Py_BuildValueDD(v1, v2: Double) : PyObject;
function Py_BuildValueDDD(v1, v2, v3: Double) : PyObject;
function Py_BuildValueD4(v1, v2, v3, v4: Double) : PyObject;
function Py_BuildValueD5(v1, v2, v3, v4, v5: Double) : PyObject;
function Py_BuildValueODD(v1: PyObject; v2, v3: Double) : PyObject;
function PyArg_ParseTupleX(src: PyObject; const fmt: PChar; AllArgs: array of const) : LongBool;
//function PyArg_ParseTupleAndKeywordsX(arg, kwdict: PyObject; const fmt: PChar; var kwlist: PChar; AllArgs: array of const) : LongBool;  pascal;
procedure Py_INCREF(o: PyObject);
procedure Py_DECREF(o: PyObject);
procedure Py_REF_Delta(o: PyObject; Delta: Integer);
procedure Py_XINCREF(o: PyObject);
procedure Py_XDECREF(o: PyObject);
//function PySeq_Length(o: PyObject) : {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF};
//function PySeq_Item(o: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject;

var
 PyInt_Type:    PyTypeObject;
 PyType_Type:   PyTypeObject;
 PyList_Type:   PyTypeObject;
 PyString_Type: PyTypeObject;
 PyFloat_Type:  PyTypeObject;
 PyTuple_Type:  PyTypeObject;

function IsPythonLoaded : Boolean;
function InitializePython : Integer;
procedure UnInitializePython;
procedure SizeDownPython;

{$IFDEF PyProfiling}
function PythonGetStackTrace() : TStringList;
{$ENDIF}

 {-------------------}

implementation

uses
 {$IFDEF Debug} QkObjects, {$ENDIF}
 {$IFDEF DebugPythonLeak} {$IFNDEF PyProfiling}Classes,{$ENDIF} QkConsts, PyObjects, Quarkx, {$ENDIF}
  Windows, Forms, SysUtils, StrUtils, QkExceptions,
  QkApplPaths, SystemDetails, Logging;

{$IFDEF DebugPythonLeak}
var g_PythonObjects: TList;
{$ENDIF}

 {-------------------}

const
  PythonProcList: array[0..{$IFDEF PyProfiling}60{$ELSE}58{$ENDIF}] of record
                                    Variable: Pointer;
                                    Name: PChar;
                                    MinimalVersion: Integer; //Exact meaning in GoodPythonVersion
                                  end =
  ( (Variable: @@Py_Initialize;              Name: 'Py_Initialize';              MinimalVersion: 0 ),
    (Variable: @@Py_Finalize;                Name: 'Py_Finalize';                MinimalVersion: 0 ),
    (Variable: @@Py_GetVersion;              Name: 'Py_GetVersion';              MinimalVersion: 0 ),
    (Variable: @@Py_SetProgramName;          Name: 'Py_SetProgramName';          MinimalVersion: 0 ),
    (Variable: @@PyRun_SimpleString;         Name: 'PyRun_SimpleString';         MinimalVersion: 0 ),
//  (Variable: @@Py_CompileString;           Name: 'Py_CompileString';           MinimalVersion: 0 ),
//  (Variable: @@Py_InitModule;              Name: 'Py_InitModule';              MinimalVersion: 0 ), //Missing in DLL
//  (Variable: @@Py_InitModule3;             Name: 'Py_InitModule3';             MinimalVersion: 0 ), //Missing in DLL
    (Variable: @@Py_InitModule4;             Name: 'Py_InitModule4';             MinimalVersion: 0 ),
    (Variable: @@PyModule_GetDict;           Name: 'PyModule_GetDict';           MinimalVersion: 0 ),
    (Variable: @@PyModule_New;               Name: 'PyModule_New';               MinimalVersion: 0 ),
//  (Variable: @@PyImport_ImportModule;      Name: 'PyImport_ImportModule';      MinimalVersion: 0 ),
//  (Variable: @@PyEval_GetGlobals;          Name: 'PyEval_GetGlobals';          MinimalVersion: 0 ),
//  (Variable: @@PyEval_GetLocals;           Name: 'PyEval_GetLocals';           MinimalVersion: 0 ),
{$IFDEF PYTHON27}
    (Variable: @@PyEval_CallObjectWithKeywords; Name: 'PyEval_CallObjectWithKeywords'; MinimalVersion: 0 ),
{$ELSE}
    (Variable: @@PyEval_CallObject;          Name: 'PyEval_CallObject';          MinimalVersion: 0 ),
{$ENDIF}
    (Variable: @@PyCallable_Check;           Name: 'PyCallable_Check';           MinimalVersion: 0 ),
    (Variable: @@PyErr_Print;                Name: 'PyErr_Print';                MinimalVersion: 0 ),
    (Variable: @@PyErr_Clear;                Name: 'PyErr_Clear';                MinimalVersion: 0 ),
    (Variable: @@PyErr_Occurred;             Name: 'PyErr_Occurred';             MinimalVersion: 0 ),
    (Variable: @@PyErr_Fetch;                Name: 'PyErr_Fetch';                MinimalVersion: 0 ),
    (Variable: @@PyErr_Restore;              Name: 'PyErr_Restore';              MinimalVersion: 0 ),
    (Variable: @@PyErr_NewException;         Name: 'PyErr_NewException';         MinimalVersion: 0 ),
    (Variable: @@PyErr_SetString;            Name: 'PyErr_SetString';            MinimalVersion: 0 ),
    (Variable: @@PyErr_ExceptionMatches;     Name: 'PyErr_ExceptionMatches';     MinimalVersion: 0 ),
    (Variable: @@PyObject_Length;            Name: 'PyObject_Length';            MinimalVersion: 0 ),
//    (Variable: @@PyObject_GetItem;           Name: 'PyObject_GetItem';           MinimalVersion: 0 ),
    (Variable: @@PyObject_HasAttrString;     Name: 'PyObject_HasAttrString';     MinimalVersion: 0 ),
    (Variable: @@PyObject_GetAttrString;     Name: 'PyObject_GetAttrString';     MinimalVersion: 0 ),
    (Variable: @@PyObject_IsTrue;            Name: 'PyObject_IsTrue';            MinimalVersion: 0 ),
    (Variable: @@PyObject_Str;               Name: 'PyObject_Str';               MinimalVersion: 0 ),
    (Variable: @@PyObject_Repr;              Name: 'PyObject_Repr';              MinimalVersion: 0 ),
    (Variable: @@PySequence_GetItem;         Name: 'PySequence_GetItem';         MinimalVersion: 0 ),
    (Variable: @@PySequence_In;              Name: 'PySequence_In';              MinimalVersion: 0 ), //Is a legacy alias for the new PySequence_Contains
    (Variable: @@PySequence_Index;           Name: 'PySequence_Index';           MinimalVersion: 0 ),
    (Variable: @@PySequence_DelItem;         Name: 'PySequence_DelItem';         MinimalVersion: 0 ),
    (Variable: @@PyMapping_HasKey;           Name: 'PyMapping_HasKey';           MinimalVersion: 0 ),
    (Variable: @@PyMapping_HasKeyString;     Name: 'PyMapping_HasKeyString';     MinimalVersion: 0 ),
    (Variable: @@PyNumber_Float;             Name: 'PyNumber_Float';             MinimalVersion: 0 ),
    (Variable: @@Py_BuildValue;              Name: 'Py_BuildValue';              MinimalVersion: 0 ),
    (Variable: @@PyArg_ParseTuple;           Name: 'PyArg_ParseTuple';           MinimalVersion: 0 ),
    (Variable: @@PyTuple_New;                Name: 'PyTuple_New';                MinimalVersion: 0 ),
    (Variable: @@PyTuple_GetItem;            Name: 'PyTuple_GetItem';            MinimalVersion: 0 ),
    (Variable: @@PyTuple_SetItem;            Name: 'PyTuple_SetItem';            MinimalVersion: 0 ),
    (Variable: @@PyList_New;                 Name: 'PyList_New';                 MinimalVersion: 0 ),
    (Variable: @@PyList_GetItem;             Name: 'PyList_GetItem';             MinimalVersion: 0 ),
    (Variable: @@PyList_SetItem;             Name: 'PyList_SetItem';             MinimalVersion: 0 ),
    (Variable: @@PyList_Insert;              Name: 'PyList_Insert';              MinimalVersion: 0 ),
    (Variable: @@PyList_Append;              Name: 'PyList_Append';              MinimalVersion: 0 ),
    (Variable: @@PyDict_New;                 Name: 'PyDict_New';                 MinimalVersion: 0 ),
    (Variable: @@PyDict_SetItemString;       Name: 'PyDict_SetItemString';       MinimalVersion: 0 ),
    (Variable: @@PyDict_GetItemString;       Name: 'PyDict_GetItemString';       MinimalVersion: 0 ),
    (Variable: @@PyDict_GetItem;             Name: 'PyDict_GetItem';             MinimalVersion: 0 ),
    (Variable: @@PyDict_Keys;                Name: 'PyDict_Keys';                MinimalVersion: 0 ),
    (Variable: @@PyDict_Values;              Name: 'PyDict_Values';              MinimalVersion: 0 ),
    (Variable: @@PyDict_Next;                Name: 'PyDict_Next';                MinimalVersion: 0 ),
    (Variable: @@PyString_FromString;        Name: 'PyString_FromString';        MinimalVersion: 0 ),
    (Variable: @@PyString_AsString;          Name: 'PyString_AsString';          MinimalVersion: 0 ),
    (Variable: @@PyString_FromStringAndSize; Name: 'PyString_FromStringAndSize'; MinimalVersion: 0 ),
    (Variable: @@PyString_Size;              Name: 'PyString_Size';              MinimalVersion: 0 ),
    (Variable: @@PyInt_FromLong;             Name: 'PyInt_FromLong';             MinimalVersion: 0 ),
    (Variable: @@PyInt_AsLong;               Name: 'PyInt_AsLong';               MinimalVersion: 0 ),
    (Variable: @@PyFloat_FromDouble;         Name: 'PyFloat_FromDouble';         MinimalVersion: 0 ),
    (Variable: @@PyFloat_AsDouble;           Name: 'PyFloat_AsDouble';           MinimalVersion: 0 ),
    (Variable: @@PyObject_Init;              Name: 'PyObject_Init';              MinimalVersion: 0 ),
    (Variable: @@PyCFunction_New;            Name: 'PyCFunction_New';            MinimalVersion: 0 ),
    (Variable: @@PyGC_Collect;               Name: 'PyGC_Collect';               MinimalVersion: 235 ){$IFDEF PyProfiling},
    (Variable: @@PyThreadState_Get;          Name: 'PyThreadState_Get';          MinimalVersion: 0 ),
    (Variable: @@PyCode_Addr2Line;           Name: 'PyCode_Addr2Line';           MinimalVersion: 230 ){$ENDIF}
  );

var
  PythonLoaded: boolean;

  PythonLib: HMODULE;
  PythonDll: String;

 {-------------------}

{$IFDEF PYTHON27}
function PyEval_CallObjectX(o, args: PyObject) : PyObject; cdecl;
begin
  result := PyEval_CallObjectWithKeywords(o, args, nil);
end;
{$ENDIF}

 {-------------------}

function GoodPythonVersion(NumberToCheck: Integer; const PythonVersionNumber: TVersionNumber) : boolean;
begin
  //This function checks if the Python version 'encoded' in NumberToCheck
  //is equal or higher to the given PythonVersionNumber
  Result:=false;
  case NumberToCheck of
  0:
  begin
    //All Python versions will do
    Result:=true;
  end;
  230:
  begin
    if Length(PythonVersionNumber) >= 1 then
    begin
      if PythonVersionNumber[0] > 2 then
      begin
        Result:=true;
      end
      else if PythonVersionNumber[0] = 2 then
      begin
        if Length(PythonVersionNumber) >= 2 then
        begin
          if PythonVersionNumber[1] > 3 then
          begin
            Result:=true;
          end
          else if PythonVersionNumber[1] = 3 then
          begin
            if Length(PythonVersionNumber) >= 3 then
            begin
              if PythonVersionNumber[2] >= 0 then
              begin
                Result:=true;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  235:
  begin
    if Length(PythonVersionNumber) >= 1 then
    begin
      if PythonVersionNumber[0] > 2 then
      begin
        Result:=true;
      end
      else if PythonVersionNumber[0] = 2 then
      begin
        if Length(PythonVersionNumber) >= 2 then
        begin
          if PythonVersionNumber[1] > 3 then
          begin
            Result:=true;
          end
          else if PythonVersionNumber[1] = 3 then
          begin
            if Length(PythonVersionNumber) >= 3 then
            begin
              if PythonVersionNumber[2] >= 5 then
              begin
                Result:=true;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  else
  begin
    raise InternalE('Call to GoodPythonVersion with an unknown NumberToCheck!');
  end;
  end;
end;

function IsPythonLoaded : Boolean;
begin
  Result:=PythonLoaded;
end;

function InitializePython : Integer;
var
  obj1: PyObject;
  I: Integer;
  P: Pointer;
  s: string;
  Index: Integer;
  VersionNumber: TVersionNumber;
  VersionNumberString: String;
  FoundGoodVersion: Boolean;
  FoundOwnVersion: Boolean;
begin
  //See ProbableCauseOfFatalError in QuarkX for return value meaning
  Result:=6;

  if SetEnvironmentVariable('PYTHONHOME', PChar(ExtractFileDir(Application.Exename))) = false then
    Exit;
  if SetEnvironmentVariable('PYTHONPATH', PChar(ConcatPaths([ExtractFileDir(Application.Exename), 'Lib']))) = false then
    Exit;
//FIXME: Not used for now
//  if SetEnvironmentVariable('PYTHONOPTIMIZE', '1') = false then
//    Exit;
{$IFDEF Debug}
  if SetEnvironmentVariable('PYTHONDEBUG', '1') = false then
    Exit;
  if SetEnvironmentVariable('PYTHONDUMPREFS', '1') = false then
    Exit;
{$ENDIF}
  Result:=5;

  if PythonLib=0 then
  begin
    PythonDll:='python.dll';

    Log(LOG_VERBOSE, 'Now loading Python DLL...');
    PythonLib:=LoadLibrary(PChar(ConcatPaths([GetQPath(pQuArKDll), PythonDll])));
    if PythonLib=0 then
    begin
      //If the PythonDLL was not found in the dlls-dir,
      //let's try to load from anywhere else...
      {$IFDEF PYTHON27}
       PythonDll:='python27.dll';
      {$ELSE}
       {$IFDEF PYTHON26}
        PythonDll:='python26.dll';
       {$ELSE}
        {$IFDEF PYTHON25}
         PythonDll:='python25.dll';
        {$ELSE}
         {$IFDEF PYTHON24}
          PythonDll:='python24.dll';
         {$ELSE}
          {$IFDEF PYTHON23}
           PythonDll:='PYTHON23.DLL';
          {$ELSE}
           {$IFDEF PYTHON22}
            PythonDll:='PYTHON22.DLL';
           {$ELSE}
            {$IFDEF PYTHON21}
             PythonDll:='PYTHON21.DLL';
            {$ELSE}
             {$IFDEF PYTHON20}
              PythonDll:='PYTHON20.DLL';
             {$ELSE}
              PythonDll:='';
             {$ENDIF}
            {$ENDIF}
           {$ENDIF}
          {$ENDIF}
         {$ENDIF}
        {$ENDIF}
       {$ENDIF}
      {$ENDIF}

      if PythonDll<>'' then
        PythonLib:=LoadLibrary(PChar(PythonDll));

      if PythonLib=0 then
      begin
        Exit;  {This is handled manually}
        {Raise InternalE('Unable to load dlls/PythonLib.dll');}
      end;
    end;
  end;
  Result:=4;

  //First load the all-version functions
  for I:=Low(PythonProcList) to High(PythonProcList) do
  begin
    if (PythonProcList[I].MinimalVersion = 0) then
    begin
      P:=GetProcAddress(PythonLib, PythonProcList[I].Name);
      if P=Nil then
      begin
        Log(LOG_PYTHON, LOG_CRITICAL, 'Unable to load %s!', [PythonProcList[I].Name]);
        Exit;
      end;
    end
    else
      P:=nil;
    PPointer(PythonProcList[I].Variable)^:=P;
  end;
  {$IFDEF PYTHON27}
  PyEval_CallObject := PyEval_CallObjectX;
  {$ENDIF}
  Py_SetProgramName(PChar(Application.Exename));
  Py_Initialize;
  s:=Py_GetVersion;
  Log(LOG_PYTHON,'PYTHON:');
  Log(LOG_PYTHON,'Version: '+s);
  Log(LOG_PYTHON,'DLL: '+RetrieveModuleFilename(PythonLib));
  Result:=3;

  //Process Py_GetVersion to find version number
  FoundGoodVersion:=False;
  FoundOwnVersion:=False;

  //DanielPharos: We're going to assume the Python version information always
  //is formated as integers delimited by periods '.', with the number starting
  //after a space ' '.
  Index:=Pos(' ', s);
  if Index <> 0 then
  begin
    VersionNumberString:=LeftStr(s, Index-1);
    VersionNumber:=SplitVersionNumber(VersionNumberString);

    if Length(VersionNumber) >= 1 then
    begin
      if VersionNumber[0] > 2 then
      begin
        //Python 3 or larger: Proceed at own risk!
        FoundGoodVersion:=True;
        LogAndWarn('Unsupported, future version ('+VersionNumberString+') of Python found! QuArK might behave unpredictably!');
      end
      else if (VersionNumber[0] = 2) then
      begin
        if Length(VersionNumber) >= 2 then
        begin
          if (VersionNumber[1] >= 4) then
          begin
            //Python 2.4 or higher: Supported!
            FoundGoodVersion:=True;
            if (VersionNumber[1] = 4) then
            begin
              if Length(VersionNumber) >= 3 then
              begin
                if (VersionNumber[2] = 4) then
                begin
                  FoundOwnVersion:=True;
                end;
              end;
            end;
            if not FoundOwnVersion then
            begin
              LogAndWarn('A different version ('+VersionNumberString+') of Python than supported found! QuArK might behave unpredictably!');
            end;
          end;
        end;
      end;
    end;
  end
  else
    VersionNumberString:=s;

  if not FoundGoodVersion then
  begin
    LogAndWarn('Unsupported version ('+VersionNumberString+') of Python found!');
    Exit;
  end;
  Result:=2;

  //Now that we know the Python version, load the version-specific functions
  for I:=Low(PythonProcList) to High(PythonProcList) do
  begin
    if (PythonProcList[I].MinimalVersion = 0) then
      continue;
    if GoodPythonVersion(PythonProcList[I].MinimalVersion, VersionNumber) then
    begin
      P:=GetProcAddress(PythonLib, PythonProcList[I].Name);
      if P=Nil then
      begin
        Log(LOG_PYTHON, LOG_CRITICAL, 'Unable to load %s!', [PythonProcList[I].Name]);
        Exit;
      end;
      PPointer(PythonProcList[I].Variable)^:=P;
    end;
  end;
  Result:=1;

 { tiglari:
   Now we set the value of some global variables
   to the basic Python types }
  obj1:=PyList_New(0);
  if obj1=Nil then
    Exit;
  PyList_Type:=obj1^.ob_type;
  Py_DECREF(obj1);

  obj1:=PyTuple_New(0);
  if obj1=Nil then
    Exit;
  PyTuple_Type:=obj1^.ob_type;
  Py_DECREF(obj1);

  obj1:=PyInt_FromLong(0);
  if obj1=Nil then
    Exit;
  PyInt_Type:=obj1^.ob_type;
  Py_DECREF(obj1);

  obj1:=PyString_FromString('');
  if obj1=Nil then
    Exit;
  PyString_Type:=obj1^.ob_type;
  Py_DECREF(obj1);

  obj1:=PyFloat_FromDouble(0.0);
  if obj1=Nil then
    Exit;
  PyFloat_Type:=obj1^.ob_type;
  Py_DECREF(obj1);

  PyType_Type:=PyList_Type^.ob_type;

  PythonLoaded:=true;
  Result:=0;
end;

procedure UnInitializePython;
var
  I: Integer;
begin
  if PythonLib<>0 then
  begin
    if FreeLibrary(PythonLib)=false then
    begin
      //FIXME: If FreeLibrary failed, can we still trust the loaded Python?
      //       Shouldn't we be killing PythonLoaded?
      LogWindowsError(GetLastError(), 'FreeLibrary(PythonLib)');
      LogAndRaiseError('Unable to unload the Python library');
    end;
    PythonLib:=0;

    PythonLoaded:=false;

    for I:=Low(PythonProcList) to High(PythonProcList) do
      PPointer(PythonProcList[I].Variable)^:=nil;
  end;
end;

procedure SizeDownPython;
begin
  //GC doesn't work when PyErr is set
  //See: https://github.com/python/cpython/commit/2fe940c727802ad54cff9486c658bc38743f7bfc
  if PyErr_Occurred<>Nil then
    Exit;
  if Assigned(PyGC_Collect) then
    PyGC_Collect;
end;

function PyObject_NEW(t: PyTypeObject) : PyObject;
var
 o: PyObject;
begin
  GetMem(o, t^.tp_basicsize);
  Result:=PyObject_Init(o,t);
  {$IFDEF DebugPythonLeak}
  g_PythonObjects.Add(o);
  {$ENDIF}
end;

{function PyObject_NEWVAR(t: PyTypeObject; i: Integer) : PyObject;
var
 o: PyObject;
begin
 GetMem(o, t^.tp_basicsize + i*t^.tp_itemsize);
 Result:=_PyObject_NewVar(t,i,o);
end;}

procedure PyObject_DEL(o: PyObject);
begin
  {$IFDEF DebugPythonLeak}
  g_PythonObjects.Remove(o);
  {$ENDIF}
  FreeMem(o);
end;

//Note: This function can only handle Args-elements that are 4 bytes in size (DWORD's), so it will NOT work with Double's!
function Py_BuildValueX(const fmt: PChar; Args: array of const) : PyObject;
asm                     { Comments added by Decker, but I'm not sure they are correct!! }
 push edi               { save the value of edi for later retrieval }
 add ecx, ecx           { multiply ecx with 2 (ecx = the number of elements in the Args array, minus 1) }
 add ecx, ecx           { multiply ecx with 2 again - so in reality its "ecx = ecx * 4" }
 lea edi, [ecx+8]       { load edi register with the result of "ecx + 8"; this is the number of bytes we're going to push onto the stack }
 add ecx, ecx           { multiply ecx with 2 - now it would have been "ecx = ecx * 8"; "array of const" stores its elements per 8 bytes }
 add ecx, edx           { this will now point to the last argument we need to send through }
 @L1:
  push dword ptr [ecx]  { push an argument onto the stack }
  sub ecx, 8            { subtract 8 from our argument pointer }
  cmp ecx, edx          { compare with the first argument; i.e. did we just push the last argument onto the stack? }
 jnb @L1                { jump to L1 if "not below"; i.e. we're not done with the Args-array yet }
 push fmt               { push the fmt-string onto the stack as well, making it the first argument for Py_BuildValue }
 call Py_BuildValue     { call Py_BuildValue }
 add esp, edi           { remove the arguments we pushed onto the stack }
 pop edi                { restore the saved value of edi }
end;

function PyArg_ParseTupleX(src: PyObject; const fmt: PChar; AllArgs: array of const) : LongBool;
asm
 push edi               { save the value of edi for later retrieval }
 push esi               { save the value of esi for later retrieval }
 mov esi, edx
 mov edx, ecx
 mov ecx, [esp+16]
 add ecx, ecx
 add ecx, ecx
 lea edi, [ecx+12]
 add ecx, ecx
 add ecx, edx
 @L1:
  push dword ptr [ecx]
  sub ecx, 8
  cmp ecx, edx
 jnb @L1
 push esi
 push eax
 call PyArg_ParseTuple
 add esp, edi
 pop esi                { restore the saved value of esi }
 pop edi                { restore the saved value of edi }
end;

function Py_BuildValueDD(v1, v2: Double) : PyObject;
type
 F = function(const fmt: PChar; v1, v2: Double) : PyObject; cdecl;
begin
 Result:=F(Py_BuildValue)('dd', v1, v2);
end;

function Py_BuildValueDDD(v1, v2, v3: Double) : PyObject;
type
 F = function(const fmt: PChar; v1, v2, v3: Double) : PyObject; cdecl;
begin
 Result:=F(Py_BuildValue)('ddd', v1, v2, v3);
end;

function Py_BuildValueD4(v1, v2, v3, v4: Double) : PyObject;
type
 F = function(const fmt: PChar; v1, v2, v3, v4: Double) : PyObject; cdecl;
begin
 Result:=F(Py_BuildValue)('dddd', v1, v2, v3, v4);
end;

function Py_BuildValueD5(v1, v2, v3, v4, v5: Double) : PyObject;
type
 F = function(const fmt: PChar; v1, v2, v3, v4, v5: Double) : PyObject; cdecl;
begin
 Result:=F(Py_BuildValue)('ddddd', v1, v2, v3, v4, v5);
end;

function Py_BuildValueODD(v1: PyObject; v2, v3: Double) : PyObject;
type
 F = function(const fmt: PChar; v1: PyObject; v2, v3: Double) : PyObject; cdecl;
begin
 Result:=F(Py_BuildValue)('Odd', v1, v2, v3);
end;

{function PyArg_ParseTupleAndKeywordsX(arg, kwdict: PyObject; const fmt: PChar; var kwlist: PChar; AllArgs: array of const) : LongBool;
pascal; assembler; asm
 mov ecx, [AllArgs-4]
 mov edx, [AllArgs]
 add ecx, ecx
 add ecx, ecx
 add ecx, ecx
 add ecx, edx
 @L1:
  mov eax, [ecx]
  push eax
  sub ecx, 8
  cmp ecx, edx
 jnb @L1
 push [kwlist]
 push [fmt]
 push [kwdict]
 push [arg]
 call PyArg_ParseTupleAndKeywords
end;}

{$IFDEF PyRefDEBUG}
procedure RefError;
begin
 Raise InternalE('Python Reference count error');
end;
{$ENDIF}

procedure Py_INCREF(o: PyObject);
begin
  {$IFDEF PyRefDEBUG}
  if o^.ob_refcnt<0 then
    RefError();
  {$ENDIF}
  Inc(o^.ob_refcnt);
end;

(*
procedure Py_INCREF(o: PyObject); assembler;
asm
{$IFDEF PyRefDEBUG}
 cmp dword ptr [eax], 0
 jl RefError
{$ENDIF}
 inc dword ptr [eax]
end;
*)

(*
procedure Py_XINCREF(o: PyObject); assembler;
asm
 or eax, eax
 jz @Null
{$IFDEF PyRefDEBUG}
 cmp dword ptr [eax], 0
 jl RefError
{$ENDIF}
 inc dword ptr [eax]
@Null:
end;
*)

procedure Py_XINCREF(o: PyObject);
begin
  if o <> nil then Py_INCREF(o);
end;

(*{$IFDEF Debug}
procedure Py_Dealloc1(o: PyObject); forward;
{$ENDIF}*)

procedure Py_Dealloc(o: PyObject);
begin
  o^.ob_type^.tp_dealloc(o);
end;
(*{$IFDEF Debug}
var
 Size: Integer;
begin
 Size:=PyTypeObject(o^.ob_type)^.tp_basicsize;
 if PyTypeObject(o^.ob_type)^.tp_itemsize>0 then
  Inc(Size, PyTypeObject(o^.ob_type)^.tp_itemsize*PyVarObject(o)^.ob_size);
 Py_Dealloc1(o);
{if Size<>16 then}
  FillChar(o^, Size, $FF);
end;
procedure Py_Dealloc1(o: PyObject);
{$ENDIF}
assembler;
asm
 push eax
 mov edx, [eax+TyObject.ob_type]
 call dword [edx+TyTypeObject.tp_dealloc]
 add esp, 4
end;
*)

procedure Py_DECREF(o: PyObject);
begin
  with o^ do begin
    {$IFDEF PyRefDEBUG}
    if ob_refcnt <= 0 then
      RefError();
    {$ENDIF}
    Dec(ob_refcnt);
    if ob_refcnt = 0 then
      Py_Dealloc(o);
  end;
end;

(*
procedure Py_DECREF(o: PyObject); assembler;
asm
{$IFDEF PyRefDEBUG}
 cmp dword ptr [eax], 0
 jle RefError
{$ENDIF}
 dec dword ptr [eax]
 jz Py_Dealloc
end;
*)

(*
procedure Py_XDECREF(o: PyObject); assembler;
asm
 or eax, eax
 jz @Null
{$IFDEF PyRefDEBUG}
 cmp dword ptr [eax], 0
 jle RefError
{$ENDIF}
 dec dword ptr [eax]
 jz Py_Dealloc
@Null:
end;
*)

procedure Py_XDECREF(o: PyObject);
begin
  if o <> nil then Py_DECREF(o);
end;

procedure Py_REF_Delta(o: PyObject; Delta: Integer);
begin
  if Delta=0 then
   {$IFDEF DEBUG}
   Raise InternalE('Delta = 0!');
   {$ELSE}
   Exit;
   {$ENDIF}
  {$IFDEF PyRefDEBUG}
  if o^.ob_refcnt<0 then
    RefError();
  if (Delta<0) and (o^.ob_refcnt=0) then
    RefError();
  {$ENDIF}
  Inc(o^.ob_refcnt, Delta);
  {$IFDEF PyRefDEBUG}
  if o^.ob_refcnt < 0 then
    RefError();
  {$ENDIF}
  if o^.ob_refcnt <= 0 then
    Py_Dealloc(o);
end;

(*function PySeq_Length(o: PyObject) : {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF};
begin
 with PyTypeObject(o^.ob_type)^ do
  if (tp_as_sequence=Nil) or not Assigned(tp_as_sequence^.sq_length) then
   Result:=0
  else
   Result:=tp_as_sequence^.sq_length(o);
end;

function PySeq_Item(o: PyObject; index: {$IFDEF PYTHON25} Py_ssize_t {$ELSE} Integer {$ENDIF}) : PyObject;
begin
 with PyTypeObject(o^.ob_type)^ do
  if (tp_as_sequence=Nil) or not Assigned(tp_as_sequence^.sq_item) then
   Result:=Nil
  else
   Result:=tp_as_sequence^.sq_item(o, index);
end;*)

{$IFDEF PyProfiling}
//Based on: https://stackoverflow.com/questions/1796510/accessing-a-python-traceback-from-the-c-api
function PythonGetStackTrace() : TStringList;
var
 tstate: PyThreadState;
 frame: PyFrameObject;
 LineNumber: Integer;
 Filename, Funcname: PChar;
begin
 Result := TStringList.Create;
 tstate := PyThreadState_GET();
 if tstate = nil then
   Exit;
 frame := tstate^.frame;
 if frame = nil then
   Exit;

  while (frame<>nil) do
  begin
    {$IFDEF PYTHON23}
    LineNumber := PyCode_Addr2Line(frame^.f_code, frame^.f_lasti);
    {$ELSE}
    LineNumber := frame^.lineno;
    {$ENDIF}
    Filename := PyString_AsString(frame^.f_code^.co_filename);
    Funcname := PyString_AsString(frame^.f_code^.co_name);
    Result.Add(Format('%s: %s, line %d', [Funcname, Filename, LineNumber]));
    frame := frame^.f_back;
  end;
end;
{$ENDIF}

{$IFDEF DebugPythonLeak}
procedure PythonObjectDump;
const
  PythonObjectDumpFile = 'PythonObjectDump.txt';
var
  Text: TStringList;
  I: Integer;
  SomePythonObject: PyObject;
  Q: QObject;
begin
  Text:=TStringList.Create;
  try
    Text.Add(QuArKVersion + ' ' + QuArKMinorVersion);

    Text.Add('-----');

    Text.Add(Format('%5.5s  %s  %s', ['RefCnt', 'Class', 'Object']));
    for I:=0 to g_PythonObjects.Count-1 do
    begin
      SomePythonObject := g_PythonObjects[I];
      Q:=QkObjFromPyObj(SomePythonObject);
      if Q=nil then
        Text.Add(Format('%5d  %s  nil', [SomePythonObject.ob_refcnt, SomePythonObject.ob_type.tp_name]))
      else
        Text.Add(Format('%5d  %s  %s', [SomePythonObject.ob_refcnt, SomePythonObject.ob_type.tp_name, Q.Name+Q.TypeInfo]));
    end;

    Text.SaveToFile(ExtractFilePath(ParamStr(0))+PythonObjectDumpFile);
  finally
    Text.Free;
  end;
end;

procedure TestPythonObjectDump;
begin
  if g_PythonObjects.Count>0 then
    if Windows.MessageBox(0, 'Some Python objects were not correctly freed. This is a bug. Do you want to write a data report (PythonObjectDump.txt) ?', 'DEBUGGING - BETA VERSION', MB_YESNO) = IDYES then
      PythonObjectDump;
end;
{$ENDIF}

initialization
  PythonLib:=0;
{$IFDEF DebugPythonLeak}
  g_PythonObjects:=TList.Create;

finalization
  TestPythonObjectDump;
  g_PythonObjects.Free;
{$ENDIF}
end.
