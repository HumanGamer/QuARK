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
Revision 1.19  2001/06/05 18:44:01  decker_dk
Prefixed interface global-variables with 'g_', so its clearer that one should not try to find the variable in the class' local/member scope, but in global-scope maybe somewhere in another file.

Revision 1.18  2001/04/19 19:27:45  aiv
better error messages

Revision 1.17  2001/03/20 21:34:13  decker_dk
Updated copyright-header

Revision 1.16  2001/02/23 19:27:37  decker_dk
Small changes (which hopefully does not break anything)
SuivantDansGroupe => NextInGroup
TrimStringList => StringListConcatWithSeparator

Revision 1.15  2001/02/12 03:25:10  tiglari
PyLogging -> Logging in implementation uses

Revision 1.14  2001/02/11 22:38:24  aiv
Removed PyLogging.pas - use Quarkx.log(...) to log stuff.

Revision 1.13  2001/01/30 19:12:14  decker_dk
Changed to GetApplicationPath().

Revision 1.12  2001/01/21 15:51:46  decker_dk
Moved RegisterQObject() and those things, to a new unit; QkObjectClassList.

Revision 1.11  2000/12/07 19:47:30  decker_dk
Some layout changes. I like columns, specially when there is lots of data.

Revision 1.10  2000/11/11 17:55:56  decker_dk
Rearranged try-finally statements, so the code will be more readable

Revision 1.9  2000/10/16 22:27:40  aiv
pylogging added (not fully working yet)

Revision 1.8  2000/07/18 19:38:01  decker_dk
Englishification - Big One This Time...

Revision 1.7  2000/07/16 16:33:39  decker_dk
Englishification

Revision 1.6  2000/07/09 13:19:28  decker_dk
Englishification and a little layout

Revision 1.5  2000/05/14 20:26:48  alexander
ToutCharger -> LoadAll
}


unit Quarkx;

interface

uses Windows, Messages, ShellApi, SysUtils, Python, Forms,
     Menus;

const
 PythonSetupString = 'import sys'#10'sys.path[:0]=["%s"]'#10'import quarkpy';
 PythonRunPackage  = 'quarkpy.RunQuArK()';
 FatalErrorText    = 'Cannot initialize the Python interpreter. QuArK cannot start. Be sure Python and QuArK are correctly installed; reinstall them if required.';
 FatalErrorCaption = 'QuArK Python';
 PythonNotFound    = 'Python does not seem to be installed on this system. QuArK cannot start. Please download the MiniPython pack from QuArK''s home page at http://www.planetquake.com/quark.';

var
 Py_None        : PyObject = Nil;
 Py_xStrings    : PyObject = Nil;
 QuarkxDict     : PyObject = Nil;
{SysModule      : PyObject = Nil;
 SysDict        : PyObject = Nil;}
 MacrosDict     : PyObject = Nil;
 QuarkxError    : PyObject = Nil;
 QuarkxAborted  : PyObject = Nil;
 EmptyTuple     : PyObject = Nil;
{MenuItemCls    : PyObject = Nil;}
 ToolboxMenu    : PyObject = Nil;
 HelpMenu       : PyObject = Nil;

 ExceptionMethod : procedure (const S: String) of object = Nil;

 {-------------------}

procedure PythonLoadMain;
function LoadStr1(I: Integer) : String;
function FmtLoadStr1(I: Integer; Args: array of const) : String;
function PyNoResult : PyObject;
function GetEmptyTuple : PyObject;
procedure SimpleDestructor(o: PyObject); cdecl;
function EError(Res: Integer) : Exception;
function EErrorFmt(Res: Integer; Fmt: array of const) : Exception;
procedure EBackToPython;
procedure EBackToUser;
function GetExceptionMessage(E: Exception) : String;
function CallNotifyEvent(self, fnt: PyObject; Hourglass: Boolean) : Boolean;
function GetPythonValue(value, args: PyObject; Hourglass: Boolean) : PyObject;
function CallMacro(self: PyObject; const fntname: String) : PyObject;
function CallMacroEx(args: PyObject; const fntname: String) : PyObject;
function CallMacroEx2(args: PyObject; const fntname: String; Hourglass: Boolean) : PyObject;
function GetQuarkxAttr(attr: PChar) : PyObject;
procedure PythonCodeEnd;
function PoolObj(const nName: String) : PyObject;
procedure SetPoolObj(const nName: String; nObj: PyObject);
function ClearPool(Full: Boolean) : Boolean;
procedure ClearTimers;
function MiddleColor(c1, c2: TColorRef; const f: Single) : TColorRef;
{procedure GetStdMenus(var HelpMenu: PyObject);}
procedure ClickForm(nForm: TForm);
procedure HTMLDoc(const URL: String);

 {-------------------}

implementation

uses Classes, Dialogs, Graphics, CommCtrl, ExtCtrls, Controls,
     QkForm, PyToolbars, PyImages, PyPanels, TB97, QkObjects,
     PyObjects, QkFileObjects, {PyFiles,} PyExplorer, Travail, Setup,
     Qk1, PyFormCfg, QkQuakeCtx, PyFloating, PyMapView, qmath,
     PyMath, PyCanvas, PyUndo, qmatrices, QkMapObjects, QkTextures,
     Undo, QkGroup, Qk3D, PyTravail, ToolBox1, Config, PyProcess,
     Console, Game, {$IFDEF VER90} ShellObj, {$ELSE} ShlObj, {$ENDIF}
     Output1, About, Reg2, SearchHoles, QkMapPoly, HelpPopup1,
     PyForms, QkPixelSet, Bezier, Logging, QkObjectClassList,
     QkApplPaths;

 {-------------------}

function PyNoResult : PyObject; assembler;
asm
 mov eax, [Py_None]
 inc dword ptr [eax]
end;

function GetEmptyTuple : PyObject;
begin
 Py_INCREF(EmptyTuple);
 GetEmptyTuple:=EmptyTuple;
end;

procedure SimpleDestructor(o: PyObject); cdecl;
begin
 try
  FreeMem(o);
 except
  EBackToPython;
 end;
end;

 {-------------------}

var
 Pool: TStringList = Nil;

function PoolObj(const nName: String) : PyObject;
var
 J: Integer;
begin
 if (Pool<>Nil) and Pool.Find(nName,J) then
  Result:=PyObject(Pool.Objects[J])
 else
  Result:=Nil;
end;

procedure SetPoolObj(const nName: String; nObj: PyObject);
var
 oObj: PyObject;
 J: Integer;
begin
 if Pool=Nil then
  begin
   Pool:=TStringList.Create;
   Pool.Sorted:=True;
   Pool.Duplicates:=dupAccept;
  end;
 if (nName<>'') and Pool.Find(nName, J) then
  begin
   oObj:=PyObject(Pool.Objects[J]);
   if nObj = Py_None then
    Pool.Delete(J)
   else
    begin
     Pool.Objects[J]:=TObject(nObj);
     Py_INCREF(nObj);
    end;
   Py_DECREF(oObj);
  end
 else
  if nObj<>Py_None then
   begin
    Pool.AddObject(nName, TObject(nObj));
    Py_INCREF(nObj);
   end;
end;

function ClearPool(Full: Boolean) : Boolean;
const
 OneStepCount = 4;
var
 I, Count: Integer;
 oObj: PyObject;
 DT: Boolean;
begin
 if Pool<>Nil then
  begin
   DT:=False;
   try
    if Full then
     Count:=MaxInt
    else
     Count:=OneStepCount;
    I:=0;
    while I<Pool.Count do
     begin
      oObj:=PyObject(Pool.Objects[I]);
      if oObj^.ob_refcnt = 1 then
       begin
        if not DT then
         begin
          ProgressIndicatorStart(0,0);
          DT:=True;
         end;
        Pool.Delete(I);
        Py_DECREF(oObj);
        Dec(Count);
        if Count=0 then
         begin
          Result:=False;
          Exit;
         end;
       end
      else
       Inc(I);
     end;
   finally
    if DT then
     ProgressIndicatorStop;
   end;
  end;
 Result:=True;
end;

 {-------------------}

type
 TPyTimer = class(TTimer)
            public
             Call, Info: PyObject;
             InCall: Boolean;
             procedure TimerTimer(Sender: TObject);
             destructor Destroy; override;
             procedure Clear;
            end;

var
 TimerList: TList = Nil;

procedure TPyTimer.Clear;
begin
 Enabled:=False;
 Py_XDECREF(Call);
 Call:=Nil;
 Py_XDECREF(Info);
 Info:=Nil;
end;

destructor TPyTimer.Destroy;
begin
 Py_XDECREF(Info);
 Py_XDECREF(Call);
 inherited;
end;

procedure TPyTimer.TimerTimer;
var
 arglist, callresult: PyObject;
 nInterval: Integer;
begin
 Enabled:=False;
 nInterval:=0;
 arglist:=Py_BuildValueX('(O)', [Info]);
 if arglist=Nil then Exit;
 try
  InCall:=True;
  callresult:=PyEval_CallObject(Call, arglist);
  if callresult<>Nil then
   begin
    if callresult <> Py_None then
     nInterval:=PyInt_AsLong(callresult);
    Py_DECREF(callresult);
   end;
 finally
  InCall:=False;
  Py_DECREF(arglist);
  if nInterval>0 then
   begin
    Interval:=nInterval;
    Enabled:=True;
   end
  else
   Clear;
 end;
 PythonCodeEnd;
end;

procedure ClearTimers;
var
 I: Integer;
begin
 if TimerList=Nil then Exit;
 for I:=TimerList.Count-1 downto 0 do
  with TPyTimer(TimerList[I]) do
   if not Enabled and not InCall then
    begin
     Free;
     TimerList.Delete(I);
    end;
 if TimerList.Count=0 then
  begin
   TimerList.Free;
   TimerList:=Nil;
  end;
end;

procedure MakePyTimer(nCall, nInfo: PyObject; nInterval: Integer);
var
 I, N: Integer;
 T: TPyTimer;
begin
 N:=-1;
 if TimerList=Nil then
  TimerList:=TList.Create
 else
  for I:=TimerList.Count-1 downto 0 do
   with TPyTimer(TimerList[I]) do
    if (Call=nCall) and (Info=nInfo) then
     begin
      N:=I;
      Clear;
      Break;
     end
    else
     if not Enabled then
      N:=I;
 if nInterval<=0 then Exit;
 if N<0 then
  begin
   T:=TPyTimer.Create(Application);
   TimerList.Add(T);
  end
 else
  T:=TPyTimer(TimerList[N]);
 T.Call:=nCall; Py_INCREF(nCall);
 T.Info:=nInfo; Py_INCREF(nInfo);
 T.Interval:=nInterval;
 T.Enabled:=True;
 T.OnTimer:=T.TimerTimer;
end;

 {-------------------}

(*function FillInMenu(nOwner: TQkForm; Menu: TMenuItem; args: PyObject) : Boolean;
var
 I, Count: Integer;
 Text: PChar;
 obj, callback, obj1: PyObject;
 Item: TPythonMenuItem;
begin
 Result:=False;
 Count:=PyObject_Length(args);
 if Count<0 then Exit;
 for I:=0 to Count-1 do
  begin
   obj:=PySequence_GetItem(args, I);
   if obj=Nil then Exit;
   try
    obj1:=PyObject_GetAttrString(obj, 'text');
    if obj1=Nil then Exit;
    Text:=PyString_AsString(obj1);
    Py_DECREF(obj1);
    if Text=Nil then Exit;

    callback:=PyObject_GetAttrString(obj, 'onclick');
    if callback=Nil then Exit;
    if callback=Py_None then
     begin
      Py_DECREF(callback);
      callback:=Nil;
     end;

    obj1:=PyObject_GetAttrString(obj, 'items');
    if obj1=Nil then Exit;

    try
     Item:=TPythonMenuItem.Create(nOwner);
     Item.Caption:=StrPas(Text);
     Item.FCallback:=callback;
     if not FillInMenu(nOwner, Item, obj1) then
      begin
       Item.Free;
       Exit;
      end;
    finally
     Py_DECREF(obj1);
    end;
    Menu.Add(Item);
   finally
    Py_DECREF(obj);
   end;
  end;
 Result:=True;
end;

function wSetMenu(self, args: PyObject) : PyObject; cdecl;
var
 OldMainMenu, NewMainMenu: TMainMenu;
 Form: TQkForm;
 obj: PyObject;
begin
 Result:=Nil;
 if not PyArg_ParseTupleX(args, 'O', [@obj]) then Exit;
 Form:=PyWindow(self)^.Form;
 NewMainMenu:=TMainMenu.Create(Form);
 try
  if not FillInMenu(Form, NewMainMenu.Items, obj) then Exit;
  OldMainMenu:=Form.Menu;
  Form.Menu:=NewMainMenu;
  if NewMainMenu=OldMainMenu then
   NewMainMenu:=Nil
  else
   NewMainMenu:=OldMainMenu;
 finally
  NewMainMenu.Free;
 end;
 Result:=PyNoResult;
end;

var
 WindowMethodTable: array[0..0] of TyMethodDef =
  ((ml_name: 'setmenu';    ml_meth: wSetMenu;    ml_flags: METH_VARARGS));

function GetWindowAttr(self: PyObject; attr: PChar) : PyObject; cdecl;
var
 I: Integer;
begin
 for I:=Low(WindowMethodTable) to High(WindowMethodTable) do
  if StrComp(attr, WindowMethodTable[I].ml_name) = 0 then
   begin
    Result:=PyCFunction_New(WindowMethodTable[I], self);
    Exit;
   end;
 Result:=PyNoResult;
end;

function PyNewWindow(nForm: TQkForm) : PyObject;
begin
 Result:=PyObject_NEW(@TyWindow_Type);
 PyWindow(Result)^.Form := nForm;
end;*)

 {-------------------}

function xSetup1(self, args: PyObject) : PyObject; cdecl;
var
 obj: PyObject;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O', [@obj]) then
   Exit;
  Py_INCREF(obj);       { never delete this }
  if Py_None=Nil then
   Py_None:=obj
  else
   if Py_xStrings=Nil then
    Py_xStrings:=obj
   else
    if MacrosDict=Nil then
     MacrosDict:=obj;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xForms(self, args: PyObject) : PyObject; cdecl;
var
 I, Mode: Integer;
 F: TForm;
begin
 try
  Mode:=0;
  Result:=Nil;
  if not PyArg_ParseTupleX(args, '|i', [@Mode]) then
   Exit;
  Result:=PyList_New(0);
  for I:=0 to Screen.FormCount-1 do
   begin
    F:=Screen.Forms[I];
    if (F is TPyForm) and (TPyForm(F).FileObject<>Nil) then
     PyList_Append(Result, TPyForm(F).WindowObject)
    else
     if (Mode>=1) and (F is TPyFloatingWnd) then
      PyList_Append(Result, TPyFloatingWnd(F).WindowObject)
     else
      if (Mode>=2) then
       PyList_Append(Result, Py_None);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xNewForm(self, args: PyObject) : PyObject; cdecl;
var
 Temp: TPyForm;
 s: PChar;
begin
 try
  Result:=Nil;
  s:=Nil;
  if not PyArg_ParseTupleX(args, '|s', [@s]) then
   Exit;
  Temp:=TPyForm.Create(Application);
 {Temp.Show;}
  if s=Nil then
   g_Form1.Enabled:=False   { special trick for the installer of QuArK }
  else
   Temp.Caption:=s;
     //DefWindowProc(g_Form1.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  Result:=Temp.WindowObject;
  Py_INCREF(Result);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

(*function xMainForm(self, args: PyObject) : PyObject; cdecl;
begin
 Result:=PyNewWindow(QkForm);
end;*)

function xLoadImages(self, args: PyObject) : PyObject; cdecl;
var
 S: String;
 FileName: PChar;
 cx: Integer;
 MaskX, MaskY: Integer;
 Bitmap: TBitmap;
 Ok: Boolean;
 WidthObj: PyObject;
 cratio: TDouble;
begin
 try
  Result:=Nil;
  WidthObj:=Nil;
  MaskX:=-1;
  if not PyArg_ParseTupleX(args, 's|O(ii)', [@FileName, @WidthObj, @MaskX, @MaskY]) then
   Exit;
  cratio:=1;
  if WidthObj=Nil then
   cx:=16
  else
   if WidthObj^.ob_type = PyFloat_Type then
    begin
     cx:=0;
     cratio:=PyFloat_AsDouble(WidthObj);
    end
   else
    begin
     cx:=PyInt_AsLong(WidthObj);
     if cx<=0 then
      Raise EError(4459);
    end;
  Bitmap:=TBitmap.Create;
  try
   S:=GetApplicationPath()+StrPas(FileName);
   Ok:=FileExists(S);
   if Ok then
    try
     Bitmap.LoadFromFile(S);
    except
     Ok:=False;
    end;
   if not Ok then
    begin
     S:=StrPas(FileName);
     Ok:=FileExists(S);
     if Ok then
      try
       Bitmap.LoadFromFile(S);
      except
       Ok:=False;
      end;
     if not Ok then
      begin
       PyErr_SetString(QuarkxError, PChar(FmtLoadStr1(4418, [S])));
       Exit;
      end;
    end;
   Result:=NewImageList(Bitmap, cx, MaskX, MaskY, cratio);
  finally
   Bitmap.Free;
  end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xExit(self, args: PyObject) : PyObject; cdecl;
begin
 try
  g_Form1.Close;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xScreenRect(self, args: PyObject) : PyObject; cdecl;
begin
 try
  with GetDesktopArea do
   Result:=Py_BuildValueX('iiii', [Left, Top, Right, Bottom]);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xNewObj(self, args: PyObject) : PyObject; cdecl;
var
 nName: PChar;
begin
 try
  Result:=Nil;
  nName:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@nName]) then
   Exit;
  with ConstructQObject(nName, Nil) do
   begin
    Result:=@PythonObj;
    Py_INCREF(Result);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xNewFileObj(self, args: PyObject) : PyObject; cdecl;
var
 FileName: PChar;
 nParent: PPythonObj;
begin
 try
  Result:=Nil;
  FileName:=Nil;
  nParent:=Nil;
  if not PyArg_ParseTupleX(args, 's|O!', [@FileName, @TyObject_Type, @nParent]) then
   Exit;
  with BuildFileRoot(FileName, QkObjFromPyObj(nParent)) do
   begin
    Result:=@PythonObj;
    Py_INCREF(Result);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xOpenFileObj(self, args: PyObject) : PyObject; cdecl;
var
 FileName: PChar;
 nParent: PPythonObj;
begin
 try
  Result:=Nil;
  FileName:=Nil;
  nParent:=Nil;
  if not PyArg_ParseTupleX(args, 's|O!', [@FileName, @TyObject_Type, @nParent]) then
   Exit;
  with LienFichierQObject(FileName, QkObjFromPyObj(nParent), False) do
   begin
    Result:=@PythonObj;
    Py_INCREF(Result);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xSetIcons(self, args: PyObject) : PyObject; cdecl;
var
 im, im2: PyObject;
 J: Integer;
begin
 try
  Result:=Nil;
  im2:=Nil;
  if not PyArg_ParseTupleX(args, 'iO|O', [@J, @im, @im2]) then
   Exit;
  if ((im^.ob_type <> @TyImage1_Type) and not PyCallable_Check(im))
  or ((im2<>Nil) and (im2^.ob_type <> @TyImage1_Type) and not PyCallable_Check(im2)) then
   Raise EError(4431);
  if (J<0) or (J>=InternalImagesCount) then
   Raise EError(4430);
  Py_XDECREF(InternalImages[J,0]);
  InternalImages[J,0]:=im;
  Py_INCREF(im);
  Py_XDECREF(InternalImages[J,1]);
  InternalImages[J,1]:=im2;
  Py_XINCREF(im2);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xFileDialogBox(self, args: PyObject) : PyObject; cdecl;
const
 fdb_SaveDialog = 1;
var
 nTitle, nFileName, nDefExt, P1: PChar;
 nFilters, obj: PyObject;
 Flags, I, Count: Integer;
 OpenDialog: TOpenDialog;
 SaveDialog: TSaveDialog;
 FiltersStr: String;
 Ok: Boolean;

  procedure ProcessResult(L: TStrings);
  var
   I: Integer;
  begin
   if not Ok then
    Result:=PyList_New(0)
   else
    begin
     Result:=PyList_New(L.Count);
     for I:=0 to L.Count-1 do
      PyList_SetItem(Result, I, PyString_FromString(PChar(L[I])));
    end;
  end;

begin
 try
  Result:=Nil;
  Flags:=0;
  nFileName:='';
  if not PyArg_ParseTupleX(args, 'ssO|is', [@nTitle, @nDefExt, @nFilters, @Flags, @nFileName]) then
   Exit;
  Count:=PyObject_Length(nFilters);
  if Count<0 then Exit;
  FiltersStr:='';
  for I:=0 to Count-1 do
   begin
    obj:=PyList_GetItem(nFilters, I);
    if obj=Nil then Exit;
    P1:=PyString_AsString(obj);
    if P1=Nil then Exit;
    if I>0 then FiltersStr:=FiltersStr+'|';
    FiltersStr:=FiltersStr+P1;
   end;
  if Flags and fdb_SaveDialog <> 0 then
   begin
    Dec(Flags, fdb_SaveDialog);
    SaveDialog:=TSaveDialog.Create(Application);
    try
     SaveDialog.Title:=nTitle;
     SaveDialog.Options:=TOpenOptions(Flags)
      + [ofCreatePrompt, ofPathMustExist, ofHideReadOnly];
     SaveDialog.DefaultExt:=nDefExt;
     SaveDialog.FileName:=nFileName;
     SaveDialog.Filter:=FiltersStr;
     Ok:=SaveDialog.Execute;
     ProcessResult(SaveDialog.Files);
    finally
     SaveDialog.Free;
    end;
   end
  else
   begin
    OpenDialog:=TOpenDialog.Create(Application);
    try
     OpenDialog.Title:=nTitle;
     OpenDialog.Options:=TOpenOptions(Flags)
      + [ofFileMustExist, ofHideReadOnly];
     OpenDialog.DefaultExt:=nDefExt;
     OpenDialog.FileName:=nFileName;
     OpenDialog.Filter:=FiltersStr;
     Ok:=OpenDialog.Execute;
     ProcessResult(OpenDialog.Files);
    finally
     OpenDialog.Free;
    end;
   end
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xSetupSubSet(self, args: PyObject) : PyObject; cdecl;
var
 SetIndex: Integer;
 SubSet: PChar;
begin
 try
  Result:=Nil;
  SetIndex:=-1;
  SubSet:=Nil;
  if not PyArg_ParseTupleX(args, '|is', [@SetIndex, @SubSet]) then
   Exit;
  if SubSet<>Nil then
   Result:=GetPyObj(SetupSubSet(TSetupSet(SetIndex), SubSet))
  else
   if SetIndex>=0 then
    Result:=GetPyObj(g_SetupSet[TSetupSet(SetIndex)])
   else
    Result:=GetPyObj(SetupGameSet);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xLines2List(self, args: PyObject) : PyObject; cdecl;
var
 obj: PyObject;
 Lines: PChar;
 L: TStringList;
 I: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O', [@obj]) then
   Exit;
  if obj=Py_None then
   Result:=PyList_New(0)
  else
   begin
    Lines:=PyString_AsString(obj);
    if Lines=Nil then Exit;
    L:=TStringList.Create;
    try
     L.Text:=Lines;
     Result:=PyList_New(L.Count);
     for I:=0 to L.Count-1 do
      PyList_SetItem(Result, I, PyString_FromString(PChar(L[I])));
    finally
     L.Free;
    end;
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xList2Lines(self, args: PyObject) : PyObject; cdecl;
var
 Lines: PyObject;
 L: TStringList;
 I, Count: Integer;
 obj: PyObject;
 Text: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O', [@Lines]) then
   Exit;
  if Lines=Py_None then
   Result:=PyString_FromString('')
  else
   begin
    Count:=PyObject_Length(Lines);
    if Count<0 then Exit;
    L:=TStringList.Create;
    try
     for I:=0 to Count-1 do
      begin
       obj:=PyList_GetItem(Lines, I);
       if obj=Nil then Exit;
       Text:=PyString_AsString(obj);
       if Text=Nil then Exit;
       L.Add(Text);
      end;
     Result:=PyString_FromString(PChar(StringListConcatWithSeparator(L, $0A)));
    finally
     L.Free;
    end;
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xTruncStr(self, args: PyObject) : PyObject; cdecl;
var
 P: PChar;
 Size: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's#', [@P, @Size]) then
   Exit;
  Result:=PyString_FromString(P);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xListFileExt(self, args: PyObject) : PyObject; cdecl;
var
 obj: PyObject;
 I: Integer;
 L: TStringList;
begin
 try
  L:=TStringList.Create;
  try
   ListFileExt(L);
   Result:=PyList_New(L.Count div 2);
   if Result=Nil then Exit;
   for I:=0 to L.Count div 2 - 1 do
    begin
     obj:=Py_BuildValueX('(ss)', [PChar(L[I*2]), PChar(L[I*2+1])]);
     if obj=Nil then
      begin
       Py_DECREF(Result);
       Exit;
      end;
     PyList_SetItem(Result, I, obj);
    end;
  finally
   L.Free;
  end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xGetQCtxList(self, args: PyObject) : PyObject; cdecl;
var
 PType, PName: PChar;
 nName: String;
 L: TQList;
begin
 try
  Result:=Nil;
  PType:=Nil;
  PName:=Nil;
  if not PyArg_ParseTupleX(args, '|ss', [@PType, @PName]) then
   Exit;
  if PType=Nil then
   Result:=QListToPyList(GetQuakeContext)
  else
   begin
    if PName=Nil then
     nName:=''
    else
     nName:=PName;
    L:=BuildQuakeCtxObjects(NeedClassOfType(PType), nName);
    try
     Result:=QListToPyList(L);
    finally
     L.Free;
    end;
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xUpdate(self, args: PyObject) : PyObject; cdecl;
var
 obj: PyObject;
begin
 try
  Result:=Nil;
  obj:=Nil;
  if not PyArg_ParseTupleX(args, '|O!', [@TyWindow_Type, @obj]) then
   Exit;
  if obj=Nil then
   PythonUpdateAll
  else
   PyWindow(obj)^.Form.RefreshMenus;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xWait(self, args: PyObject) : PyObject; cdecl;
var
 Ticks, Start: Integer;
begin
 try
  Result:=Nil;
  Ticks:=0;
  Start:=-1;
  if not PyArg_ParseTupleX(args, '|ii', [@Ticks, @Start]) then
   Exit;
  if Start<>0 then
   begin
    if Start<>-1 then
     Dec(Ticks, Integer(GetTickCount)-Start);
    if Ticks>0 then
     Sleep(Ticks);
   end;
  Result:=PyInt_FromLong(GetTickCount);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xVect(self, args: PyObject) : PyObject; cdecl;
var
 nX, nY, nZ, nS, nT: Double;
begin
 try
  Result:=Nil;
  if PyObject_Length(args)=1 then
   begin
    args:=PyTuple_GetItem(args, 0);
    if args^.ob_type = PyString_Type then
     begin
      Result:=MakePyVect(ReadVector(PyString_AsString(args)));
      Exit;
     end;
   end;
  if PyObject_Length(args)=5 then
   begin
    if not PyArg_ParseTupleX(args, 'ddddd', [@nX, @nY, @nZ, @nS, @nT]) then
     Exit;
    Result:=MakePyVect5(nX, nY, nZ, nS, nT);
   end
  else
   begin
    if not PyArg_ParseTupleX(args, 'ddd', [@nX, @nY, @nZ]) then
     Exit;
    Result:=MakePyVect3(nX, nY, nZ);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xMatrix(self, args: PyObject) : PyObject; cdecl;
var
 obj: array[1..3] of PyObject;
 M: TMatrixTransformation;
 I: Integer;
begin
 try
  Result:=Nil;
  if PyObject_Length(args)=1 then
   begin
    args:=PyTuple_GetItem(args, 0);
    if args^.ob_type = PyString_Type then
     begin
      Result:=MakePyMatrix(stomx(PyString_AsString(args)));
      Exit;
     end;
   end;
  if not PyArg_ParseTupleX(args, 'OOO', [@obj[1], @obj[2], @obj[3]]) then
   Exit;
  if (obj[1]^.ob_type = @TyVect_Type)
  and (obj[2]^.ob_type = @TyVect_Type)
  and (obj[3]^.ob_type = @TyVect_Type) then
   begin
    for I:=1 to 3 do
     with PyVect(obj[I])^.V do
      begin
       M[1,I]:=X;
       M[2,I]:=Y;
       M[3,I]:=Z;
      end;
   end
  else
   for I:=1 to 3 do
    if not PyArg_ParseTupleX(obj[I], 'ddd', [@M[I,1], @M[I,2], @M[I,3]]) then
     Exit;
  Result:=MakePyMatrix(M);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xPoolObj(self, args: PyObject) : PyObject; cdecl;
var
 nName: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@nName]) then
   Exit;
  Result:=PoolObj(nName);
  if Result=Nil then
   Result:=Py_None;
  Py_INCREF(Result);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xSetPoolObj(self, args: PyObject) : PyObject; cdecl;
var
 nName: PChar;
 nObj: PyObject;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'sO', [@nName, @nObj]) then
   Exit;
  SetPoolObj(nName, nObj);
  Result:=nObj;
  Py_INCREF(Result);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xUndoState(self, args: PyObject) : PyObject; cdecl;
var
 nObj, undo, redo: PyObject;
 Q: QObject;
 R: PUndoRoot;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!', [@TyObject_Type, @nObj]) then
   Exit;
  Q:=QkObjFromPyObj(nObj);
  if Q=Nil then
   R:=Nil
  else
   R:=GetUndoRoot(Q);
  undo:=Py_None;
  redo:=Py_None;
  try
   if R<>Nil then
    begin
     if R^.Undone < R^.UndoList.Count then
      undo:=PyString_FromString(PChar(TUndoObject(R^.UndoList[R^.UndoList.Count-1-R^.Undone]).Text));
     if R^.Undone > 0 then
      redo:=PyString_FromString(PChar(TUndoObject(R^.UndoList[R^.UndoList.Count-R^.Undone]).Text));
    end;
   Result:=Py_BuildValueX('OO', [undo, redo]);
  finally
   if redo<>Py_None then Py_DECREF(redo);
   if undo<>Py_None then Py_DECREF(undo);
  end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xAction(self, args: PyObject) : PyObject; cdecl;
begin
 try
  Result:=GetUndoModule;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xPasteObj(self, args: PyObject) : PyObject; cdecl;
var
 Now: PyObject;
 Gr: QExplorerGroup;
begin
 try
  Result:=Nil;
  Now:=Py_None;
  if not PyArg_ParseTupleX(args, '|O', [@Now]) then
   Exit;
  if PyObject_IsTrue(Now) then
   begin
    Gr:=ClipboardGroup;
    Gr.AddRef(+1);
    try
     g_ClipboardChain(Gr);
     Result:=QListToPyList(Gr.SubElements);
    finally
     Gr.AddRef(-1);
    end;
   end
  else
   Result:=PyInt_FromLong(Ord(g_ClipboardChain(Nil)));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xCopyObj(self, args: PyObject) : PyObject; cdecl;
var
 nList: PyObject;
 Gr: QExplorerGroup;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!', [PyList_Type, @nList]) then
   Exit;
  Gr:=ClipboardGroup;
  Gr.AddRef(+1);
  try
   PyListToQList(nList, Gr.SubElements, QObject);
   Gr.CopierObjets(False);
  finally
   Gr.AddRef(-1);
  end;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xSetTimer(self, args: PyObject) : PyObject; cdecl;
var
 nCall, nInfo: PyObject;
 nDelay: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'OOi', [@nCall, @nInfo, @nDelay]) then
   Exit;
  MakePyTimer(nCall, nInfo, nDelay);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xMsgBox(self, args: PyObject) : PyObject; cdecl;
var
 msg: PChar;
 typ, btn: Integer;
 Buttons: TMsgDlgButtons absolute btn;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'sii', [@msg, @typ, @btn]) then
   Exit;
  Result:=PyInt_FromLong(MessageDlg(msg, TMsgDlgType(typ), Buttons, 0));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function MiddleColor(c1, c2: TColorRef; const f: Single) : TColorRef;
var
 c1c: array[0..3] of Byte absolute c1;
 c2c: array[0..3] of Byte absolute c2;
 c3c: array[0..3] of Byte absolute Result;
 I: Integer;
 R: TDouble;
begin
 for I:=0 to 2 do
  begin
   R:=c1c[I]*f + c2c[I]*(1.0-f);
   if R<=0 then
    c3c[I]:=0
   else if R>=255 then
    c3c[I]:=255
   else
    c3c[I]:=Round(R);
  end;
 c3c[3]:=0;
end;

function xMiddleColor(self, args: PyObject) : PyObject; cdecl;
var
 c1, c2: Integer;
 factor: Single;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'iif', [@c1, @c2, @factor]) then
   Exit;
  Result:=PyInt_FromLong(MiddleColor(c1,c2,factor));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xRnd(self, args: PyObject) : PyObject; cdecl;
var
 r: Single;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'f', [@r]) then
   Exit;
  Result:=PyInt_FromLong(Round(r-rien));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xftos(self, args: PyObject) : PyObject; cdecl;
var
 r: Double;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'd', [@r]) then
   Exit;
  Result:=PyString_FromString(PChar(ftos(r)));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xTexturesOf(self, args: PyObject) : PyObject; cdecl;
var
 L: TStringList;
 I: Integer;
 obj, lst: PyObject;
 Q: QObject;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!', [PyList_Type, @lst]) then
   Exit;
  L:=TStringList.Create;
  try
   L.Sorted:=True;
   for I:=0 to PyObject_Length(lst)-1 do
    begin
     obj:=PyList_GetItem(lst, I);
     Q:=QkObjFromPyObj(obj);
     if not (Q is TTreeMap) then
      Raise EErrorFmt(4450, ['TreeMap']);
     with TTreeMap(Q) do
      begin
       LoadAll;
       FindTextures(L);
      end;
    end;
   Result:=PyList_New(L.Count);
   for I:=0 to L.Count-1 do
    PyList_SetItem(Result, I, PyString_FromString(PChar(L[I])));
  finally
   L.Free;
  end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xBoundingBoxOf(self, args: PyObject) : PyObject; cdecl;
var
 I: Integer;
 obj1, obj2, lst: PyObject;
 Q: QObject;
 Min, Max: TVect;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!', [PyList_Type, @lst]) then
   Exit;
  Min.X:=MaxInt;
  Min.Y:=MaxInt;
  Min.Z:=MaxInt;
  Max.X:=-MaxInt;
  Max.Y:=-MaxInt;
  Max.Z:=-MaxInt;
  for I:=0 to PyObject_Length(lst)-1 do
   begin
    obj1:=PyList_GetItem(lst, I);
    if obj1^.ob_type = @TyVect_Type then
     with PyVect(obj1)^.V do
      begin
       if Min.X > X then Min.X:=X;
       if Min.Y > Y then Min.Y:=Y;
       if Min.Z > Z then Min.Z:=Z;
       if Max.X < X then Max.X:=X;
       if Max.Y < Y then Max.Y:=Y;
       if Max.Z < Z then Max.Z:=Z;
      end
    else
     begin
      Q:=QkObjFromPyObj(obj1);
      if Q is Q3DObject then
       with Q3DObject(Q) do
        begin
         LoadAll;
         ChercheExtremites(Min, Max);
        end;
     end;
   end;
  if (Min.X=MaxInt) or (Max.Z=-MaxInt) then
   Result:=PyNoResult
  else
   begin
    obj1:=MakePyVect(Min);
    obj2:=MakePyVect(Max);
    Result:=Py_BuildValueX('OO', [obj1, obj2]);
    Py_DECREF(obj2);
    Py_DECREF(obj1);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xExtendCoplanar(self, args: PyObject) : PyObject; cdecl;
var
 lst1, lst2: PyObject;
 dir: Integer;
begin
 try
  Result:=Nil;
  dir:=0;
  if not PyArg_ParseTupleX(args, 'O!O!|i', [PyList_Type, @lst1, PyList_Type, @lst2, @dir]) then
   Exit;
  RechercheAdjacents(lst1, lst2, dir>=0, dir<=0);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xLoadTexture(self, args: PyObject) : PyObject; cdecl;
var
 texname: PChar;
 Q: QPixelSet;
 AltTexSrc: PyObject;
begin
 try
  Result:=Nil;
  AltTexSrc:=Nil;
  if not PyArg_ParseTupleX(args, 's|O', [@texname, @AltTexSrc]) then
   Exit;
  Q:=GlobalFindTexture(texname, QkObjFromPyObj(AltTexSrc));
 {if Q<>Nil then
   Q:=Q.Loadtexture;}
  Result:=GetPyObj(Q);
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xMapTextures(self, args: PyObject) : PyObject; cdecl;
var
 texnames, obj: PyObject;
 AltTexSrc: PyObject;
 I, Count, op: Integer;
 L: TStringList;
 P: PChar;
 QL: TQList;
begin
 try
  Result:=Nil;
  AltTexSrc:=Nil;
  if not PyArg_ParseTupleX(args, 'O!i|O', [PyList_Type, @texnames, @op, @AltTexSrc]) then
   Exit;
  Count:=PyObject_Length(texnames);
  if Count<0 then Exit;
  L:=TStringList.Create;
  try
   for I:=0 to Count-1 do
    begin
     obj:=PyList_GetItem(texnames, I);
     if obj=Nil then Exit;
     P:=PyString_AsString(obj);
     if P=Nil then Exit;
     L.Add(P);
    end;
   QL:=WriteAllTextures(L, op, QkObjFromPyObj(AltTexSrc));
   try
    Result:=QListToPyList(QL);
   finally
    QL.Free;
   end;
  finally
   L.Free;
  end;
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xKeyDown(self, args: PyObject) : PyObject; cdecl;
var
 State: SmallInt;
 P: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@P]) then
   Exit;
  State:=GetAsyncKeyState(Ord(P^));
  if State<0 then
   State:=1
  else
   if Odd(State) then
    State:=-1
   else
    State:=0;
  Result:=PyInt_FromLong(State);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xBeep(self, args: PyObject) : PyObject; cdecl;
var
 Mb: Integer;
begin
 try
  Result:=Nil;
  Mb:=0;
  if not PyArg_ParseTupleX(args, '|i', [@Mb]) then
   Exit;
  MessageBeep(Mb);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

(*function xSubtractPoly(self, args: PyObject) : PyObject; cdecl;
var
 pol, neg: PyObject;
 I, J: Integer;
 Originaux, Anciens, Nouveaux, L: TQList;
 Negatif, Test: QObject;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!O!', [PyList_Type, @pol, PyList_Type, @neg]) then
   Exit;
  Originaux:=TQList.Create;
  Anciens:=TQList.Create;
  Nouveaux:=TQList.Create;
  try
   PyListToQList(pol, Originaux, TPolyedre);
   Anciens.Capacity:=Originaux.Count;
   for I:=0 to Originaux.Count-1 do
    Anciens.Add(Originaux[I]);
   for I:=0 to PyObject_Length(neg)-1 do
    begin
     Negatif:=QkObjFromPyObj(PyList_GetItem(neg, I));
     if not (Negatif is TPolyedre) then
      Raise EErrorFmt(4450, ['Polyhedron']);
     SoustractionPolyedre(Anciens, Nouveaux, TPolyedre(Negatif), False);
     L:=Anciens;
     Anciens:=Nouveaux;
     Nouveaux:=L;
     Nouveaux.Clear;
    end;
   for I:=0 to Originaux.Count-1 do
    begin
     Test:=Originaux[I];
     J:=Resultat.IndexOf(Test);
     if J<0 then    { supprimer les poly�dres effac�s }
      ListeActions.Add(TQObjectUndo.Create('', Test, Nil))
     else
      Resultat[J]:=Nil;   { ignorer les poly�dres qui sont rest�s }
    end;
   for I:=0 to Resultat.Count-1 do
    begin
     Test:=TTreeMap(Resultat[I]);
     if Test<>Nil then    { ajouter les nouveaux poly�dres }
      ListeActions.Add(TQObjectUndo.Create('', Nil, Test));
    end;
  finally
   Nouveaux.Free;
   Anciens.Free;
   Originaux.Free;
  end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;*)

function xProgressBar(self, args: PyObject) : PyObject; cdecl;
var
 nCount, nText: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'ii', [@nText, @nCount]) then
   Exit;
  Result:=GetProgressBarModule(nText, nCount);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xOpenToolBox(self, args: PyObject) : PyObject; cdecl;
var
 tb: PChar;
 sel: PyObject;
 ToolBox: TToolBoxForm;
begin
 try
  Result:=Nil;
  sel:=Nil;
  if not PyArg_ParseTupleX(args, 's|O', [@tb, @sel]) then
   Exit;
  if tb^<>#0 then
   ToolBox:=OpenToolBox(tb)
  else
   ToolBox:=OpenTextureBrowser;
  if sel<>Nil then
   ToolBox.SelectTbObject(QkObjFromPyObj(sel));
  ActivateNow(ToolBox);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xOpenConfigDlg(self, args: PyObject) : PyObject; cdecl;
var
 path: PChar;
 obj, oblist: PyObject;
 QList: TQList;
begin
 try
  Result:=Nil;
  path:='';
  obj:=Nil;
  oblist:=Py_None;
  if not PyArg_ParseTupleX(args, '|sO!O', [@path, @TyObject_Type, @obj, @oblist]) then
   Exit;
  if obj=Nil then
   begin
    ShowConfigDlg(path);
    Result:=PyNoResult;
   end
  else
   begin
    QList:=Nil;
    try
     if oblist<>Py_None then
      begin
       QList:=TQList.Create;
       PyListToQList(oblist, QList, QObject);
      end;
     Result:=PyInt_FromLong(Ord(ShowAltConfigDlg(QkObjFromPyObj(obj), path, QList)));
    finally
     QList.Free;
    end;
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xClipLine(self, args: PyObject) : PyObject; cdecl;
var
 v1, v2: PyVect;
 PP1, PP2: TPointProj;
 Ok: Boolean;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!O!', [@TyVect_Type, @v1, @TyVect_Type, @v2]) then
   Exit;
  if (v1^.Source3D=Nil) or (v1^.Source3D<>v2^.Source3D) then
   Raise EError(4447);
  PP1:=PyVect_AsPP(v1);
  PP2:=PyVect_AsPP(v2);
  Ok:=v1^.Source3D.ClipLine95(PP1, PP2);
  if Ok then
   begin
    v1^.Source3D.CheckVisible(PP1);
    v1^.Source3D.CheckVisible(PP2);
   end;
  Result:=PyTuple_New(2);
  if Ok then
   begin
    PyTuple_SetItem(Result, 0, v1^.Source3D.MakePyVectPtf(PP1));
    PyTuple_SetItem(Result, 1, v1^.Source3D.MakePyVectPtf(PP2));
   end
  else
   begin
    PyTuple_SetItem(Result, 0, PyNoResult);
    PyTuple_SetItem(Result, 1, PyNoResult);
   end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xRunProgram(self, args: PyObject) : PyObject; cdecl;
var
 cmdline, curdir, P, Q: PChar;
 SI: TStartupInfo;
 PI: TProcessInformation;
 nstdout, nstderr: PyObject;
 Flags: Integer;
 Z, Z2: array[0..MAX_PATH] of Char;
 ShInfo: TShFileInfo;
 BinaryType: Integer;
begin
 try
  Result:=Nil;
  nstdout:=Nil;
  nstderr:=Nil;
  if not PyArg_ParseTupleX(args, 'ss|OO', [@cmdline, @curdir, @nstdout, @nstderr]) then
   Exit;
  if nstderr=Nil then
   nstderr:=nstdout;
  FillChar(SI, SizeOf(SI), 0);
  FillChar(PI, SizeOf(PI), 0);
  try
   if nstdout<>Nil then
    begin
     SI.cb:=SizeOf(SI);
     SI.dwFlags:=STARTF_USESTDHANDLES;
     SI.hStdInput:=EmptyInputPipe;
     SI.hStdOutput:=ProcessPipe(nstdout);
     SI.hStdError:=ProcessPipe(nstderr);
     Flags:=DETACHED_PROCESS;
    end
   else
    Flags:=0;
   GetCurrentDirectory(SizeOf(Z), Z);
   try
    SetCurrentDirectory(curdir);
    if SI.dwFlags and STARTF_USESTDHANDLES <> 0 then
     begin
      if cmdline^='"' then
       begin
        P:=cmdline+1;
        Q:=StrScan(P, '"');
       end
      else
       begin
        P:=cmdline;
        Q:=StrScan(P, ' ');
        if Q=Nil then Q:=StrEnd(P);
       end;
      if Q<>Nil then
       begin
        Move(P^, Z2, Q-P);
        Z2[Q-P]:=#0;
        if StrScan(Z2, '.')=Nil then
         StrCat(Z2, '.exe');
        BinaryType:=SHGetFileInfo(Z2, 0, ShInfo, SizeOf(ShInfo), SHGFI_EXETYPE);
        if BinaryType=$5A4D then   { MS-DOS applications }
         begin
          SI.dwFlags:=SI.dwFlags and not STARTF_USESTDHANDLES;
          Flags:=0;
         end;
       end;
     end;
    if not CreateProcess(Nil, cmdline, Nil, Nil, True, Flags, Nil, curdir, SI, PI) then
     Raise EError(4453);
   finally
    SetCurrentDirectory(Z);
   end;
  finally
   if SI.hStdError<>0 then CloseHandle(SI.hStdError);
   if SI.hStdOutput<>0 then CloseHandle(SI.hStdOutput);{coflhack:=SI.hStdOutput;}
  end;
  Result:=GetProcessModule(PI, nstdout, nstderr, cmdline);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xWriteConsole(self, args: PyObject) : PyObject; cdecl;
var
 text: PChar;
 textlength: Integer;
 obj: PyObject;
 S: String;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'Os#', [@obj, @text, @textlength]) then
   Exit;
  SetString(S, text, textlength);
  WriteConsole(obj, S);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xConsole(self, args: PyObject) : PyObject; cdecl;
var
 o: PyObject;
begin
 try
  Result:=Nil;
  o:=Nil;
  if not PyArg_ParseTupleX(args, '|O', [@o]) then
   Exit;
  ShowConsole((o=Nil) or PyObject_IsTrue(o));
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xOutputFile(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  s:=Nil;
  if not PyArg_ParseTupleX(args, '|s', [@s]) then
   Exit;
  CheckQuakeDir;
  if s=Nil then
   Result:=PyString_FromString(PChar(GettmpQuArK))
  else
   Result:=PyString_FromString(PChar(OutputFile(s)));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xOutputPakFile(self, args: PyObject) : PyObject; cdecl;
var
 test: PyObject;
 S: String;
begin
 try
  Result:=Nil;
  test:=Py_None;
  if not PyArg_ParseTupleX(args, 'O', [@test]) then
   Exit;
  S:=FindNextAvailablePakFilename(PyObject_IsTrue(test));
  if S='' then
   Result:=PyNoResult
  else
   Result:=PyString_FromString(PChar(S));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xGetFileAttr(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  Result:=PyInt_FromLong(GetFileAttributes(s));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xSetFileAttr(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
 i: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'si', [@s, @i]) then
   Exit;
  if i=-1 then
   begin
    if not Windows.DeleteFile(s) then
     Raise EError(4455);
   end
  else
   if not SetFileAttributes(s,i) then
    Raise EError(4455);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xReloadSetup(self, args: PyObject) : PyObject; cdecl;
var
 i: Integer;
 s: PyObject;
 P: PChar;
begin
 try
  Result:=Nil;
  i:=scMaximal;
  if not PyArg_ParseTupleX(args, '|i', [@i]) then
   Exit;
  if i=scInit then
   begin
    s:=PyDict_GetItemString(QuarkxDict, 'exepath');
    if s<>Nil then
     begin
      P:=PyString_AsString(s);
      if (P<>Nil) and (P^<>#0) then
       begin
        SetApplicationPath(P);
       end;
     end;
    InitSetup;   { reload setup }
   end
  else
   SetupChanged(i);
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xGlobalAccept(self, args: PyObject) : PyObject; cdecl;
var
 ok: PyObject;
begin
 try
  Result:=Nil;
  ok:=Nil;
  if not PyArg_ParseTupleX(args, '|O', [@ok]) then
   Exit;
  if (ok=Nil) or PyObject_IsTrue(ok) then
   GlobalDoAccept
  else
   GlobalDoCancel;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

procedure HTMLDoc(const URL: String);
var
 S1, S2: String;
 Reg: TRegistry2;
 I: Integer;
 SI: TStartupInfo;
 PI: TProcessInformation;

  procedure OpenError(const Err: String);
  begin
   raise EErrorFmt(5649, [URL, Err]);
  end;

begin
 Reg:=TRegistry2.Create;
 try
  Reg.RootKey:=HKEY_CLASSES_ROOT;
  if (not Reg.ReadOpenKey('.html') and not Reg.ReadOpenKey('.htm'))
  or not Reg.ReadString('', S1) then
   OpenError(LoadStr1(5650));
  S1:='\'+S1+'\shell\open\command';
  if not Reg.ReadOpenKey(S1) or not Reg.ReadString('', S2) or (S2='') then
   OpenError(FmtLoadStr1(5651, [S1]));
 finally
  Reg.Free;
 end;

 if S2[1]='"' then
  begin
   System.Delete(S2, 1, 1);
   I:=Pos('"', S2);
  end
 else
  I:=Pos(' ', S2);
 if I>0 then
  SetLength(S2, I-1);
 S2:=S2+' "'+URL+'"';

 FillChar(SI, SizeOf(SI), 0);
 FillChar(PI, SizeOf(PI), 0);
 if CreateProcess(Nil, PChar(S2), Nil, Nil, False, 0, Nil, Nil, SI, PI) then
  begin
   DeleteObject(PI.hThread);
   DeleteObject(PI.hProcess);
  end
 else
  OpenError(FmtLoadStr1(5652, [S2]));
end;

function xHTMLDoc(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  HTMLDoc(s);
  Result:=PyNoResult;
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xHelpPopup(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  HelpPopup(s);
  Result:=PyNoResult;
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xHelpMenuItem(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
 Item: TMenuItem;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  if g_Form1.HelpMenu.Tag=0 then
   begin
    Item:=TMenuItem.Create(g_Form1);
    Item.Caption:='-';
    g_Form1.HelpMenu.Items.Insert(0, Item);
   end;
  Item:=TMenuItem.Create(g_Form1);
  Item.Caption:=s;
  Item.OnClick:=g_Form1.HelpMenuItemClick;
  g_Form1.HelpMenu.Items.Insert(g_Form1.HelpMenu.Tag, Item);
  g_Form1.HelpMenu.Tag:=g_Form1.HelpMenu.Tag+1;
  Result:=PyNoResult;
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xEntityMenuItem(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
 Item: TMenuItem;
begin
  try
    Result:=Nil;
    if not PyArg_ParseTupleX(args, 's', [@s]) then
      Exit;
    Item:=TMenuItem.Create(g_Form1);
    Item.Caption:=s;
    Item.OnClick:=g_Form1.ConvertFrom1Item1Click;
    g_Form1.ConvertFrom1.Add(Item);
    g_Form1.empty1.visible:=false;
    Result:=PyNoResult;
  except
    EBackToUser;
    Result:=Nil;
  end;
end;

function xGetShortHint(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  Result:=PyString_FromString(PChar(GetShortHint(s)));
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xGetLongHint(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  Result:=PyString_FromString(PChar(GetLongHint(s)));
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xSetHint(self, args: PyObject) : PyObject; cdecl;
var
 s: PChar;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  Application.Hint:=s;
  Result:=PyNoResult;
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xListMapViews(self, args: PyObject) : PyObject; cdecl;
var
 I, J: Integer;
begin
 try
  Result:=PyList_New(0);
  for I:=0 to Screen.FormCount-1 do
   with Screen.Forms[I] do
    for J:=0 to ComponentCount-1 do
     if Components[J] is TPyMapView then
      PyList_Append(Result, TPyMapView(Components[J]).MapViewObject);
 except
  EBackToUser;
  Result:=Nil;
 end;
end;

function xMenuName(self, args: PyObject) : PyObject; cdecl;
var
 s, dest: PChar;
 S1: String;
 N: Integer;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 's', [@s]) then
   Exit;
  N:=StrLen(s);
  SetLength(S1, N*2);
  dest:=PChar(S1);
  while s^<>#0 do
   begin
    if s^='&' then
     begin
      dest^:='&';
      Inc(dest);
     end;
    dest^:=s^;
    Inc(dest);
    Inc(s);
   end;
  Result:=PyString_FromStringAndSize(PChar(S1), dest-PChar(S1));
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xSearchForHoles(self, args: PyObject) : PyObject; cdecl;
var
 pol, sta: PyObject;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!O!', [PyList_Type, @pol, PyList_Type, @sta]) then
   Exit;
  Result:=SearchForHoles(pol, sta);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xNewFaceEx(self, args: PyObject) : PyObject; cdecl;
var
 vtx, obj: PyObject;
 Face: TFace;
 S: PSurface;
 I, Count: Integer;
 nSommet: PSommet;
 V: array[0..2] of TVect;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O!', [PyList_Type, @vtx]) then
   Exit;
  Count:=PyObject_Length(vtx);
  if Count<0 then Exit;
  FillChar(V, SizeOf(V), 0);
  GetMem(S, TailleBaseSurface + Count*(SizeOf(PSommet)+SizeOf(TSommet)));
  try
   nSommet:=PSommet(@S^.prvDescS[Count]);
   for I:=0 to Count-1 do
    begin
     S^.prvDescS[I]:=nSommet;
     obj:=PyList_GetItem(vtx, I);
     if obj=Nil then Exit;
     if obj^.ob_type <> @TyVect_Type then
      Raise EError(4441);
     nSommet^.P:=PyVect(obj)^.V;
     if I<3 then V[I]:=nSommet^.P else V[2]:=nSommet^.P;
     Inc(nSommet);
    end;
   Face:=TFace.Create('tmp', Nil);
   Face.SetThreePoints(V[0], V[2], V[1]);
   S^.Source:=Face;
   S^.F:=Face;
   S^.NextF:=Nil;
   S^.prvNbS:=Count;
   Face.LinkSurface(S);
  except
   FreeMem(S);
   Raise;
  end;
  Result:=GetPyObj(Face);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xFindToolBoxes(self, args: PyObject) : PyObject; cdecl;
var
 L: TQList;
 SetupQrk, Q, T: QObject;
 I: Integer;
 S: String;
 P: PChar;
 obj: PyObject;
begin
 try
  Result:=Nil;
  P:='';
  if not PyArg_ParseTupleX(args, '|s', [@P]) then
   Exit;

  L:=TQList.Create;
  try
   SetupQrk:=MakeAddOnsList; try
    { looks for toolbox data in all add-ons }
   BrowseToolBoxes(SetupQrk, P, L);
  finally
   SetupQrk.AddRef(-1);
  end;

  Result:=PyList_New(0);
  for I:=0 to L.Count-1 do
   begin
    Q:=L[I];
    S:=Q.Specifics.Values['Root'];
    if S='' then Continue;   { no data }
    T:=Q.SubElements.FindName(S);
    if T=Nil then Continue;   { no data }
    S:=Q.Specifics.Values['ToolBox'];
    obj:=Py_BuildValueX('sO', [PChar(S), @T.PythonObj]);
    if obj=Nil then Exit;
    PyList_Append(Result, obj);
    Py_DECREF(obj);
   end;
  finally L.Free; end;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function xNeedGameFile(self, args: PyObject) : PyObject; cdecl;
var
 f, b: PChar;
 Q: QFileObject;
begin
 try
  Result:=Nil;
  b:=Nil;
  if not PyArg_ParseTupleX(args, 's|s', [@f, @b]) then
   Exit;
  if b=Nil then
   Q:=NeedGameFile(f)
  else
   Q:=NeedGameFileBase(b, f);
  Result:=GetPyObj(Q);
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

{AiV}
Function xLog(self, args: PyObject) : PyObject; cdecl;
var
  P: PChar;
begin
  Result:=Nil;
  try
    P:=PyString_AsString(Args);
    if P=Nil then
      Exit;
    aLog(LOG_PYTHONSOURCE, P^);
    Result:=PyNoResult;
  except
    EBackToPython;
    Result:=Nil;
  end;
end;{/AiV}

const
 MethodTable: array[0..66] of TyMethodDef =
  ((ml_name: 'Setup1';          ml_meth: xSetup1;         ml_flags: METH_VARARGS),
   (ml_name: 'newobj';          ml_meth: xNewObj;         ml_flags: METH_VARARGS),
   (ml_name: 'newfileobj';      ml_meth: xNewFileObj;     ml_flags: METH_VARARGS),
   (ml_name: 'openfileobj';     ml_meth: xOpenFileObj;    ml_flags: METH_VARARGS),
   (ml_name: 'setupsubset';     ml_meth: xSetupSubSet;    ml_flags: METH_VARARGS),
   (ml_name: 'lines2list';      ml_meth: xLines2List;     ml_flags: METH_VARARGS),
   (ml_name: 'list2lines';      ml_meth: xList2Lines;     ml_flags: METH_VARARGS),
   (ml_name: 'truncstr';        ml_meth: xTruncStr;       ml_flags: METH_VARARGS),
   (ml_name: 'getshorthint';    ml_meth: xGetShortHint;   ml_flags: METH_VARARGS),
   (ml_name: 'getlonghint';     ml_meth: xGetLongHint;    ml_flags: METH_VARARGS),
   (ml_name: 'action';          ml_meth: xAction;         ml_flags: METH_VARARGS),
   (ml_name: 'undostate';       ml_meth: xUndoState;      ml_flags: METH_VARARGS),
   (ml_name: 'pasteobj';        ml_meth: xPasteObj;       ml_flags: METH_VARARGS),
   (ml_name: 'copyobj';         ml_meth: xCopyObj;        ml_flags: METH_VARARGS),
   (ml_name: 'settimer';        ml_meth: xSetTimer;       ml_flags: METH_VARARGS),
   (ml_name: 'forms';           ml_meth: xForms;          ml_flags: METH_VARARGS),
   (ml_name: 'rnd';             ml_meth: xRnd;            ml_flags: METH_VARARGS),
   (ml_name: 'ftos';            ml_meth: xftos;           ml_flags: METH_VARARGS),
   (ml_name: 'menuname';        ml_meth: xMenuName;       ml_flags: METH_VARARGS),
   (ml_name: 'middlecolor';     ml_meth: xMiddleColor;    ml_flags: METH_VARARGS),
   (ml_name: 'boundingboxof';   ml_meth: xBoundingBoxOf;  ml_flags: METH_VARARGS),
   (ml_name: 'texturesof';      ml_meth: xTexturesOf;     ml_flags: METH_VARARGS),
   (ml_name: 'extendcoplanar';  ml_meth: xExtendCoplanar; ml_flags: METH_VARARGS),
   (ml_name: 'loadtexture';     ml_meth: xLoadTexture;    ml_flags: METH_VARARGS),
   (ml_name: 'maptextures';     ml_meth: xMapTextures;    ml_flags: METH_VARARGS),
   (ml_name: 'outputfile';      ml_meth: xOutputFile;     ml_flags: METH_VARARGS),
   (ml_name: 'outputpakfile';   ml_meth: xOutputPakFile;  ml_flags: METH_VARARGS),
   (ml_name: 'opentoolbox';     ml_meth: xOpenToolBox;    ml_flags: METH_VARARGS),
   (ml_name: 'openconfigdlg';   ml_meth: xOpenConfigDlg;  ml_flags: METH_VARARGS),
   (ml_name: 'progressbar';     ml_meth: xProgressBar;    ml_flags: METH_VARARGS),
   (ml_name: 'clipline';        ml_meth: xClipLine;       ml_flags: METH_VARARGS),
  {(ml_name: 'offscreenbitmap'; ml_meth: xOffscreenBitmap;ml_flags: METH_VARARGS),}
   (ml_name: 'keydown';         ml_meth: xKeyDown;        ml_flags: METH_VARARGS),
   (ml_name: 'poolobj';         ml_meth: xPoolObj;        ml_flags: METH_VARARGS),
   (ml_name: 'setpoolobj';      ml_meth: xSetPoolObj;     ml_flags: METH_VARARGS),
   (ml_name: 'vect';            ml_meth: xVect;           ml_flags: METH_VARARGS),
   (ml_name: 'matrix';          ml_meth: xMatrix;         ml_flags: METH_VARARGS),
   (ml_name: 'newform';         ml_meth: xNewForm;        ml_flags: METH_VARARGS),
   (ml_name: 'update';          ml_meth: xUpdate;         ml_flags: METH_VARARGS),
   (ml_name: 'getqctxlist';     ml_meth: xGetQCtxList;    ml_flags: METH_VARARGS),
   (ml_name: 'listfileext';     ml_meth: xListFileExt;    ml_flags: METH_VARARGS),
   (ml_name: 'filedialogbox';   ml_meth: xFileDialogBox;  ml_flags: METH_VARARGS),
   (ml_name: 'loadimages';      ml_meth: xLoadImages;     ml_flags: METH_VARARGS),
   (ml_name: 'reloadsetup';     ml_meth: xReloadSetup;    ml_flags: METH_VARARGS),
   (ml_name: 'screenrect';      ml_meth: xScreenRect;     ml_flags: METH_VARARGS),
   (ml_name: 'seticons';        ml_meth: xSetIcons;       ml_flags: METH_VARARGS),
   (ml_name: 'msgbox';          ml_meth: xMsgBox;         ml_flags: METH_VARARGS),
   (ml_name: 'beep';            ml_meth: xBeep;           ml_flags: METH_VARARGS),
   (ml_name: 'console';         ml_meth: xConsole;        ml_flags: METH_VARARGS),
   (ml_name: 'writeconsole';    ml_meth: xWriteConsole;   ml_flags: METH_VARARGS),
   (ml_name: 'globalaccept';    ml_meth: xGlobalAccept;   ml_flags: METH_VARARGS),
   (ml_name: 'runprogram';      ml_meth: xRunProgram;     ml_flags: METH_VARARGS),
   (ml_name: 'getfileattr';     ml_meth: xGetFileAttr;    ml_flags: METH_VARARGS),
   (ml_name: 'setfileattr';     ml_meth: xSetFileAttr;    ml_flags: METH_VARARGS),
   (ml_name: 'listmapviews';    ml_meth: xListMapViews;   ml_flags: METH_VARARGS),
   (ml_name: 'newfaceex';       ml_meth: xNewFaceEx;      ml_flags: METH_VARARGS),
   (ml_name: 'searchforholes';  ml_meth: xSearchForHoles; ml_flags: METH_VARARGS),
   (ml_name: 'findtoolboxes';   ml_meth: xFindToolBoxes;  ml_flags: METH_VARARGS),
   (ml_name: 'sethint';         ml_meth: xSetHint;        ml_flags: METH_VARARGS),
   (ml_name: 'helppopup';       ml_meth: xHelpPopup;      ml_flags: METH_VARARGS),
   (ml_name: 'helpmenuitem';    ml_meth: xHelpMenuItem;   ml_flags: METH_VARARGS),
   (ml_name: 'entitymenuitem';    ml_meth: xEntityMenuItem;   ml_flags: METH_VARARGS),
   (ml_name: 'htmldoc';         ml_meth: xHTMLDoc;        ml_flags: METH_VARARGS),
   (ml_name: 'needgamefile';    ml_meth: xNeedGameFile;   ml_flags: METH_VARARGS),
   (ml_name: 'wait';            ml_meth: xWait;           ml_flags: METH_VARARGS),
   (ml_name: 'exit';            ml_meth: xExit;           ml_flags: METH_VARARGS),
   (ml_name: 'log';             ml_meth: xLog;            ml_flags: METH_VARARGS),{AiV}
   (ml_Name: Nil;               ml_meth: Nil));

 {-------------------}

procedure RegType(var PyType: TyTypeObject; VarName: PChar);
begin
 PyType.ob_type:=PyType_Type;
 PyDict_SetItemString(QuarkxDict, VarName, @PyType);
end;

function InitializeQuarkx : Boolean;
var
 m: PyObject;
begin
 Result:=False;

 m:=Py_InitModule4('quarkx', MethodTable, Nil, Nil, PYTHON_API_VERSION);
 if m=Nil then
  Exit;
 QuarkxDict:=PyModule_GetDict(m);
 if QuarkxDict=Nil then
  Exit;
 EmptyTuple:=PyTuple_New(0);

 RegType(TyWindow_Type,    'window_type');
 RegType(TyToolbar_Type,   'toolbar_type');
 RegType(TyImageList_Type, 'imagelist_type');
 RegType(TyImage1_Type,    'image1_type');
 RegType(TyPanel_Type,     'panel_type');
{RegType(TyFile_Type,      'file_type');}
 RegType(TyObject_Type,    'object_type');
{RegType(TyFileObject_Type,'fileobject_type');}
 RegType(TyExplorer_Type,  'explorer_type');
 RegType(TyFormCfg_Type,   'dataform_type');
 RegType(TyFloating_Type,  'floating_type');
 RegType(TyMapView_Type,   'mapview_type');
 RegType(TyImageCtrl_Type, 'imagectrl_type');
 RegType(TyBtnPanel_Type,  'btnpanel_type');
 RegType(TyVect_Type,      'vector_type');
 RegType(TyMatrix_Type,    'matrix_type');
 RegType(TyCanvas_Type,    'canvas_type');
 RegType(TyProcess_Type,   'process_type');

(*Temp:=TPyForm.Create(Application);
 Temp.Show;
 PyDict_SetItemString(QuarkxDict, 'mainform', @Temp.WndObject);*)

 QuarkxError:=PyErr_NewException('quarkx.error', Nil, Nil);
 if QuarkxError=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'error', QuarkxError);

 QuarkxAborted:=PyErr_NewException('quarkx.aborted', Nil, Nil);
 if QuarkxAborted=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'aborted', QuarkxAborted);

 m:=PyString_FromString(QuArKVersion);
 if m=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'version', m);
 Py_DECREF(m);

 m:=PyString_FromString(PChar(GetApplicationPath()));
 if m=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'exepath', m);
 Py_DECREF(m);

 m:=PyList_New(0);
 if m=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'editshortcuts', m);
 Py_DECREF(m);

 m:=PyList_New(0);
 if m=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'buildmodes', m);
 Py_DECREF(m);

 ToolboxMenu:=PyList_New(0);
 if ToolboxMenu=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'toolboxmenu', ToolboxMenu);

 HelpMenu:=PyList_New(0);
 if HelpMenu=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'helpmenu', HelpMenu);

{m:=Py_BuildValueX('OOOO', [Py_None, Py_None, Py_None, Py_None]);
 if m=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'redlinesicons', m);
 Py_DECREF(m);}

 m:=PyInt_FromLong(BezierMeshCnt);
 if m=Nil then
  Exit;
 PyDict_SetItemString(QuarkxDict, 'beziermeshcnt', m);
 Py_DECREF(m);

 Result:=True;
end;

function LoadStr1(I: Integer) : String;
var
 key: TyIntObject;
 obj: PyObject;
 P: PChar;
begin
 Result:='';
 key.ob_refcnt:=1;
 key.ob_type:=PyInt_Type;
 key.ob_ival:=I;
 obj:=PyObject_GetItem(Py_xStrings, @key);
 if obj=Nil then
  Exit;
 P:=PyString_AsString(obj);
 if P<>Nil then
  Result:=StrPas(P);
 Py_DECREF(obj);
end;

function FmtLoadStr1(I: Integer; Args: array of const) : String;
begin
 Result:=Format(LoadStr1(I), Args);
end;

procedure ClickForm(nForm: TForm);
begin
 if nForm is TPyForm then
  PyDict_SetItemString(QuarkxDict, 'clickform', TPyForm(nForm).WindowObject)
 else
  PyDict_SetItemString(QuarkxDict, 'clickform', Py_None);
end;

function CallNotifyEvent(self, fnt: PyObject; Hourglass: Boolean) : Boolean;
var
 arglist, callresult: PyObject;
begin
 Result:=False;
 if (fnt<>Nil) and (fnt<>Py_None) then
  begin
   arglist:=Py_BuildValueX('(O)', [self]);
   if arglist=Nil then Exit;
   if Hourglass then
    ProgressIndicatorStart(0,0);
   try
    callresult:=PyEval_CallObject(fnt, arglist);
    Result:=callresult<>Nil;
    Py_XDECREF(callresult);
   finally
    if Hourglass then
     ProgressIndicatorStop;
    Py_DECREF(arglist);
   end;
   PythonCodeEnd;
  end;
end;

function GetPythonValue(value, args: PyObject; Hourglass: Boolean) : PyObject;
begin
 Result:=Nil;
 if args=Nil then
  begin
   PythonCodeEnd;
   Exit;
  end;
 try
  if value=Nil then
   PythonCodeEnd
  else
   if PyCallable_Check(value) then
    begin
     if Hourglass then
      ProgressIndicatorStart(0,0);
     try
      Result:=PyEval_CallObject(value, args);
     finally
      if Hourglass then
       ProgressIndicatorStop;
     end;
     PythonCodeEnd;
    end
   else
    begin
     Result:=value;
     Py_INCREF(Result);
    end;
 finally
  Py_DECREF(args);
 end;
end;

function CallMacro(self: PyObject; const fntname: String) : PyObject;
begin
 Result:=CallMacroEx2(Py_BuildValueX('(O)', [self]), fntname, True);
end;

function CallMacroEx(args: PyObject; const fntname: String) : PyObject;
begin
 Result:=CallMacroEx2(args, fntname, True);
end;

function CallMacroEx2(args: PyObject; const fntname: String; Hourglass: Boolean) : PyObject;
var
 fnt: PyObject;
begin
 Result:=Nil;
 if args=Nil then Exit;
 try
  if fntname='' then Exit;
  fnt:=PyDict_GetItemString(MacrosDict, PChar('MACRO_'+fntname));
  if fnt=Nil then Exit;
  if Hourglass then
   ProgressIndicatorStart(0,0);
  Result:=PyEval_CallObject(fnt, args);
 finally
  if Hourglass then
   ProgressIndicatorStop;
  Py_DECREF(args);
 end;
end;

function GetQuarkxAttr(attr: PChar) : PyObject;
begin
 Result:=PyDict_GetItemString(QuarkxDict, attr);
end;

 {-------------------}

function EError(Res: Integer) : Exception;
begin
 PythonCodeEnd;
 EError:=Exception.Create(LoadStr1(Res));
end;

function EErrorFmt(Res: Integer; Fmt: array of const) : Exception;
begin
 PythonCodeEnd;
 EErrorFmt:=Exception.Create(FmtLoadStr1(Res, Fmt));
end;

procedure EBackToPython;
var
 S: String;
begin
 PythonCodeEnd;
 if not (ExceptObject is Exception) then
  PyErr_SetString(QuarkxError, PChar(LoadStr1(4433)))
 else
  if ExceptObject is EAbort then
   PyErr_SetString(QuarkxAborted, PChar(LoadStr1(4452)))
  else
   begin
    S:=Format('%s [%p]', [GetExceptionMessage(Exception(ExceptObject)), @TForm1.AppException]);
    PyErr_SetString(QuarkxError, PChar(S));
   end;
end;

procedure EBackToUser;
var
 S: String;
begin
 PythonCodeEnd;
 if not (ExceptObject is Exception) then
  PyErr_SetString(QuarkxError, PChar(LoadStr1(4433)))
 else
  if ExceptObject is EAbort then
   PyErr_SetString(QuarkxAborted, PChar(LoadStr1(4452)))
  else
   begin
    S:=GetExceptionMessage(Exception(ExceptObject));
    g_Form1.AppException(Nil, Exception(ExceptObject));
    PyErr_SetString(QuarkxAborted, PChar(S));
   end;
end;

function GetExceptionMessage(E: Exception) : String;
var
 I: Integer;
begin
 Result:=E.Message;
 I:=Pos('//', Result);
 if I>0 then
  begin
   SetLength(Result, I);
   Result[I]:='.';
  end
 else
  Result:=Result+'.';
end;

 {-------------------}

function OpenSplashScreen : TForm;
var
 Image1: TImage;
begin
 Result:=TForm.CreateNew(Application);
 Result.Position:=poScreenCenter;
 Result.BorderStyle:=bsNone;
 Result.Color:=clWhite;
 {Result.FormStyle:=fsStayOnTop;}
 Image1:=TImage.Create(Result);
 Image1.Parent:=Result;
 Image1.Picture.Bitmap.LoadFromResourceName(HInstance, 'QUARKLOGO');
 Image1.AutoSize:=True;
 Result.ClientWidth:=Image1.Width;
 Result.ClientHeight:=Image1.Height;
 Result.Show;
 Result.Update;
end;

var ProbableCauseOfFatalError: array[-9..3] of PChar = (
   {-9}    ' (Unable to initialise python module "Quarkx")',
   {-8}    ' (Unable to find "quarkpy" directory or incorrect file versions)',
   {-7}    ' (Unable to find or execute "quarkpy.__init__.py", function "RunQuArK()")',
   {-6}    '',
   {-5}    '',
   {-4}    '',
   {-3}    '',
   {-2}    '',
   {-1}    '',
   { 0}    ' (No Error)',
   { 1}    ' (Error setting up python types)',
   { 2}    ' (Error loading dll)',
   { 3}    ' (Unable to find Python)');


procedure FatalError(Err: Integer);
var
  P: PChar;
  X: Array[0..65535] of char;
begin
 while Screen.FormCount>0 do
  Screen.Forms[0].Free;
 if Err=3 then
  P:=PythonNotFound
 else
  begin
   WriteConsole(@g_Ty_InternalConsole, 'Error code '+IntToStr(Err)+#10);
   if Err<0 then
    PythonCodeEnd;
   P:=FatalErrorText;
  end;
 StrCat(X, P);
 StrCat(X, ProbableCauseOfFatalError[err]);
 ShowConsole(True);
 Windows.MessageBox(0, X, FatalErrorCaption, MB_TASKMODAL);
 Log(strPas(x)+ ' Error Code '+IntToStr(Err));
 ExitProcess(Err);
end;

procedure PythonLoadMain;
var
 S: String;
 I: Integer;
 Splash: TForm;
 Reminder: THandle;
begin
 Splash:=OpenSplashScreen;
 try
  Reminder:=ReminderThread(Splash);
  try
  {InitConsole;}
   I:=InitializePython;
   if I>0 then FatalError(I);

   SetApplicationPath(ExtractFilePath(Application.Exename));

   if not InitializeQuarkx then FatalError(-9);

   S:=GetApplicationPath();
   if (Length(S)>0) and (S[Length(S)]='\') then
    SetLength(S, Length(S)-1);
   for I:=Length(S) downto 1 do
    if S[I]='\' then
     System.Insert('\', S, I);
   S:=Format(PythonSetupString, [S]);
   { tiglari:
     S will now be the python commands:
      import sys
      sys.path[:0]=["<the path to the quark exe>"]
      import quarkpy
   }
   if PyRun_SimpleString(PChar(S))<>0 then FatalError(-8);
   InitSetup;
   { tiglari:
     runs quarkpy.RunQuArK(), defined in quarkpy.__init__.py;
     mostly sets up icons and stuff like that.}
   if PyRun_SimpleString(PythonRunPackage)<>0 then FatalError(-7);
   PythonCodeEnd;
   PythonUpdateAll;
   WaitForSingleObject(Reminder, 10000);
  finally
   CloseHandle(Reminder);
  end;
 finally
  Splash.Release;
 end;
end;

procedure PythonCodeEnd;
var
 ptype, pvalue, ptraceback: PyObject;
 str: PyObject;
begin
 if PyErr_Occurred<>Nil then
  if PyErr_ExceptionMatches(QuarkxAborted) then
   PyErr_Clear   { silent exception }
  else
   if Assigned(ExceptionMethod) and PyErr_ExceptionMatches(QuarkxError) then
    begin
     str:=Nil;
     PyErr_Fetch(ptype, pvalue, ptraceback);
     try
      str:=PyObject_Str(pvalue);
      if str=Nil then Exit;
      ExceptionMethod(PyString_AsString(str));
     finally
      Py_XDECREF(str);
      Py_XDECREF(ptraceback);
      Py_XDECREF(pvalue);
      Py_XDECREF(ptype);
     end;
    end
   else
    begin
     PyErr_Print;
     ShowConsole(True);
    end;
end;
(*{const
 nTitle = ' - Python Error...';}
var
 Z: array[0..255] of Char;
{P: PChar;}
 H: HWnd;
begin
 if PyErr_Occurred<>Nil then
  if PyErr_ExceptionMatches(QuarkxAborted) then
   PyErr_Clear   { silent exception }
  else
   begin
    PyErr_Print;
    GetConsoleTitle(Z, SizeOf(Z));
   {P:=StrEnd(Z);
    StrCopy(P, nTitle);
    SetConsoleTitle(Z);}
    H:=FindWindow('tty', Z);
   {P^:=#0;
    SetConsoleTitle(Z);}
    SetForegroundWindow(H);
   end;
 {PyErr_Restore(Nil, Nil, Nil);}
end;*)

 {-------------------}
(*
function mToolbox1Click(self, args: PyObject) : PyObject; cdecl;
forward;

const
 MenuDef: array[1..2] of TyMethodDef =
  ((ml_name: 'toolbox1click'; ml_meth: mToolbox1Click; ml_flags: METH_VARARGS),
   (ml_name: 'help1click';    ml_meth: mHelp1Click;    ml_flags: METH_VARARGS));

function mToolbox1Click(self, args: PyObject) : PyObject; cdecl;
var
 menu: PyObject;
 Total: Integer;
 Obj: TComponent;
 Item: TMenuItem;
 Active: TForm;
 LookFor: String;
 SetupQrk: QFileObject;
 LItems, args, li: PyObject;
 Roots: TQList;
 I, J: Integer;
 L: TStringList;
 ToolBox: QToolBox;
 S: String;
 Item: TMenuItem;
begin
 try
  Result:=Nil;
  if not PyArg_ParseTupleX(args, 'O', [@menu]) then
   Exit;
  LItems:=PyList_New(0); try
  Active:=Screen.Forms[0];

  SetupQrk:=MakeAddOnsList; try

  Roots:=TQList.Create; try
  BrowseToolBoxes(SetupQrk, '', Roots);
  L:=TStringList.Create; try
  L.Sorted:=True;
  Result:=TbList1.MenuIndex;
  for I:=0 to Roots.Count-1 do
   begin
    ToolBox:=Roots[I] as QToolBox;
    S:=ToolBox.Specifics.Values['ToolBox'];
    if (S<>'') and not L.Find(S,J) then
     begin
      li:=PyCFunction_New(MenuDef[3], Py_None);
      args:=Py_BuildValueX('(sO)', [PChar(S)]);
      if args=Nil then Exit;
      try
       li:=PyEval_CallObject(MenuItemCls, args);
       if li=Nil then Exit;
       PyList_Append(LItems, li);
       Py_DECREF(li);
      finally
       Py_DECREF(args);
      end;

      if L.Count<Result then
       Item:=WindowMenu.Items[L.Count]
      else
       begin
        Item:=TMenuItem.Create(Self);
        Item.RadioItem:=True;
        Item.OnClick:=ToolBoxClick;
        WindowMenu.Items.Insert(Result, Item);
        Inc(Result);
       end;
      Item.Caption:=S;
      L.Add(S);
     end;
   end;
  while Result>L.Count do
   begin
    Dec(Result);
    WindowMenu.Items[Result].Free;
   end;
  finally L.Free; end;
  finally Roots.Free; end;


  finally SetupQrk.AddRef(-1); end;

  if Active is TToolBoxForm then
   LookFor:=Active.Caption
  else
   LookFor:='';
  for I:=0 to Total-1 do
   with WindowMenu.Items[I] do
    Checked:=CompareText(Caption, LookFor) = 0;
  MainWindow1.Checked:=Active=Self;
  for I:=0 to Application.ComponentCount-1 do
   begin
    Obj:=Application.Components[I];
    if (Obj is TQForm1) and TQForm1(Obj).Visible then
     begin
      Item:=TMenuItem.Create(Self);
      Item.Caption:=TQForm1(Obj).Caption;
      Item.Tag:=LongInt(Obj);
      Item.OnClick:=MainWindow1Click;
      Item.RadioItem:=True;
      Item.Checked:=Active=Obj;
      WindowMenu.Items.Insert(WinList1.MenuIndex, Item);
     end;
   end;
  finally Py_DECREF(LItems); end;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

procedure GetStdMenus(var HelpMenu: PyObject);
var
 obj, Toolboxes: PyObject;
begin
 Toolboxes:=GetQuarkxAttr('toolboxmenu');
 if Toolboxes<>Nil then
  begin
   obj:=PyCFunction_New(MenuDef[1], Py_None);
   if obj<>Nil then
    begin
     PyObject_SetAttrString(Toolboxes, 'onclick', obj);
     Py_DECREF(obj);
    end;
   Py_DECREF(Toolboxes);
  end;
 HelpMenu:=GetQuarkxAttr('helpmenu');
 if HelpMenu<>Nil then
  begin
   obj:=PyCFunction_New(MenuDef[2], Py_None);
   if obj<>Nil then
    begin
     PyObject_SetAttrString(HelpMenu, 'onclick', obj);
     Py_DECREF(obj);
    end;
  end;
end;*)

 {-------------------}

end.
