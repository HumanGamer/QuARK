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
unit QkModelBone;

interface

uses SysUtils, QkMdlObject, QkObjects, qmath, qmatrices, Python, QkBoneGroup;

{
Internal Format:

Bones are Connected End to Start of sub objects i.e.:

In Treeview                          #  In Real Life   ( O specifies bone connection)
                                     #
Skeleton                             #                |
|                                    #                |
+ Neck                               #           O----O----O
   |                                 #          /     |     \
   +RightArm                         #                |
   |   |                             #                |
   |   + RightHand                   #                |
   |                                 #                |
   +LeftArm                          #                O
   |   |                             #               / \
   |   + LeftHand                    #              /   \
   |                                 #             /     \
   +Spine                            #          --O       O--
       |                             #
       + RightLeg                    #
       |   |                         #
       |   + RightFoot               #
       |                             #
       + LeftLeg                     #
           |                         #
           + LeftLeg                 #

}
type
  QModelBone = class(QMdlObject)
  public
    function IsAllowedParent(Parent: QObject) : Boolean; override;
    class function TypeInfo: String; override;
    procedure ObjectState(var E: TEtatObjet); override;
//    procedure Dessiner; override;
    Procedure SetPosition(p: vec3_t);
    Function GetPosition: vec3_p;
    procedure SetRotMatrix(P: TMatrixTransformation);
    procedure GetRotMatrix(var P: PMatrixTransformation);
    function PyGetAttr(attr: PChar) : PyObject; override;
    function PySetAttr(attr: PChar; value: PyObject) : Boolean; override;
    function TreeViewColorBoxes : TColorBoxList; override;
  end;

 {------------------------}

implementation

uses qk3d, pymath, quarkx, QkExceptions, QkObjectClassList, QkMiscGroup, ExtraFunctionality;

 {------------------------}

function QModelBone.IsAllowedParent(Parent: QObject) : Boolean;
begin
  if (Parent=nil) or (Parent is QBoneGroup) or (Parent is QModelBone) then
    Result:=true
  else
    Result:=false;
end;

class function QModelBone.TypeInfo;
begin
  TypeInfo:=':bone';
end;

procedure QModelBone.ObjectState(var E: TEtatObjet);
begin
  inherited;
  E.IndexImage:=iiModelBone;
end;

const
  PosSpec = 'sys_position';
  PosSpecLen = length(PosSpec+'=');
  RotSpec = 'sys_rotmatrix';
  RotSpecLen = length(RotSpec+'=');
  VertSpec = 'vtxlist';
  VertSpecLen = length(VertSpec+'=');
  VertPosSpec = 'vtx_pos';
  VertPosSpecLen = length(VertPosSpec+'=');

procedure QModelBone.SetPosition(P: vec3_t);
var
  CVert: vec3_p;
  s: string;
begin
  S:=PosSpec;
  SetLength(S, PosSpecLen+SizeOf(vec3_t));
  PChar(CVert):=PChar(S)+PosSpecLen;
  CVert^[0]:=P[0];
  CVert^[1]:=P[1];
  CVert^[2]:=P[2];
  if Specifics.IndexofName(PosSpec)<>-1 then
    //FIXME: BAD CODING TACTIC!
    Specifics.Delete(Specifics.IndexofName(PosSpec));
  Specifics.Add(s);
end;

function QModelBone.GetPosition: vec3_p;
var
  s: string;
begin
  Result:=nil;
  S:=GetSpecArg(PosSpec);
  if S='' then
    Exit;
  if Length(S) < PosSpecLen + SizeOf(vec3_t) then
    Exit;
  PChar(Result):=PChar(S) + PosSpecLen;
end;

procedure QModelBone.SetRotMatrix(P: TMatrixTransformation);
var
  CVert: vec3_p;
  s: string;
begin
  S:=RotSpec;
  SetLength(S, RotSpecLen+SizeOf(TMatrixTransformation));
  PChar(CVert):=PChar(S)+RotSpecLen;
  Move(P, CVert^, Sizeof(TMatrixTransformation));
  if Specifics.IndexofName(RotSpec)<>-1 then
    //FIXME: BAD CODING TACTIC!
    Specifics.Delete(Specifics.IndexofName(RotSpec));
  Specifics.Add(s);
end;

procedure QModelBone.GetRotMatrix(var P: PMatrixTransformation);
var
  s: string;
begin
  P:=nil;
  S:=GetSpecArg(RotSpec);
  if S='' then
    Exit;
  if Length(S) < RotSpecLen + SizeOf(TMatrixTransformation) then
    Exit;
  PChar(P):=PChar(S) + RotSpecLen;
end;

(*procedure QModelBone.Dessiner;
var
  start_point, end_point: vec3_p;
  ok: boolean;
  pt_start, pt_end: TPointProj;
  NewPen, DeletePen, OldPen: HPen;
  CDC: TCDC;
begin
  ok:=GetStartEnd(start_point, end_point);
  if not ok then
    exit;
  pt_start:=CCoord.Proj(MakeVect(start_point^));
  pt_end:=CCoord.Proj(MakeVect(end_point^));

  DeletePen:=CreatePen(ps_Solid, 0, clWhite);
  NewPen:=DeletePen;
  OldPen:=g_DrawInfo.BlackBrush;
  g_DrawInfo.BlackBrush:=NewPen;
  SetupComponentDC(CDC);
  SelectObject(g_DrawInfo.DC, g_DrawInfo.BlackBrush);

  CCoord.Line95(pt_start, pt_end);

  CloseComponentDC(CDC);
  if OldPen<>0 then begin
    SelectObject(g_DrawInfo.DC, OldPen);
    g_DrawInfo.BlackBrush:=OldPen;
    if DeletePen<>0 then
      DeleteObject(DeletePen);
  end;

  inherited;
end;*)

function QModelBone.TreeViewColorBoxes : TColorBoxList;
const
 SpecColor2 = '_color';
begin
  Result:=TColorBoxList.Create;
  Result.Add(SpecColor2, 'LI');
end;

function QModelBone.PyGetAttr(attr: PChar) : PyObject;
var
  P: vec3_p;
  M: PMatrixTransformation;
  S, S2: String;
  P2: PChar;
  o, o2: PyObject;
  N, I: Integer;
  N2, I2: Integer;
  I3: Integer;
begin
  Result:=inherited PyGetAttr(attr);
  if Result<>Nil then Exit;
  case attr[0] of
    'p': if StrComp(attr, 'position')=0 then
    begin
      P:=GetPosition;
      if P=nil then
      begin
        Result:=MakePyVect(OriginVectorZero);
        Exit;
      end;
      Result:=MakePyVectv(P^);
      Exit;
    end;
    'r': if StrComp(attr, 'rotmatrix')=0 then
    begin
      GetRotMatrix(M);
      if M=nil then
      begin
        Result:=MakePyMatrix(MatriceIdentite);
        Exit;
      end;
      Result:=MakePyMatrix(M^);
      Exit;
    end;
    'v': if StrComp(attr, 'vtxlist')=0 then
    begin
      S:=GetSpecArg(VertSpec);
      Result:=PyDict_New;
      if Length(S)<=VertSpecLen then
        Exit;
      P2:=PChar(S)+VertSpecLen;
      N:=PInteger(P2)^;
      Inc(P2, SizeOf(Integer));
      for I:=0 to N-1 do
      begin
        S2:=StrPas(P2);
        Inc(P2, Length(S2)+1);
        N2:=PInteger(P2)^;
        Inc(P2, SizeOf(Integer));
        o:=PyList_New(N2);
        for I2:=0 to N2-1 do
        begin
          I3:=PInteger(P2)^;
          Inc(P2, SizeOf(Integer));
          o2:=PyInt_FromLong(I3);
          PyList_SetItem(o, I2, o2);
        end;
        PyDict_SetItemString(Result, PChar(S2), o);
        Py_XDECREF(o);
      end;
      Exit;
    end
    else if StrComp(attr, 'vtx_pos')=0 then
    begin
      S:=GetSpecArg(VertPosSpec);
      Result:=PyDict_New;
      if Length(S)<=VertPosSpecLen then
        Exit;
      P2:=PChar(S)+VertPosSpecLen;
      N:=PInteger(P2)^;
      Inc(P2, SizeOf(Integer));
      for I:=0 to N-1 do
      begin
        S2:=StrPas(P2);
        Inc(P2, Length(S2)+1);
        N2:=PInteger(P2)^;
        Inc(P2, SizeOf(Integer));
        o:=PyList_New(N2);
        for I2:=0 to N2-1 do
        begin
          I3:=PInteger(P2)^;
          Inc(P2, SizeOf(Integer));
          o2:=PyInt_FromLong(I3);
          PyList_SetItem(o, I2, o2);
        end;
        PyDict_SetItemString(Result, PChar(S2), o);
        Py_XDECREF(o);
      end;
      Exit;
    end;
  end;
end;

function QModelBone.PySetAttr(attr: PChar; value: PyObject) : Boolean;
var
  P: PyVect;
  M: PyMatrix;
  S, S0: String;
  DictLen: {$IFDEF PYTHON25}Py_ssize_t{$ELSE}Integer{$ENDIF};
  DestP: vec3_p;
  DestM: PMatrixTransformation;
  DestV: PChar;
  DictKey, DictValue: PyObject;
  N, I: Integer;
  o2: PyObject;
  N2, I2: Integer;
  S2: String;
  I3: Integer;
begin
  Result:=inherited PySetAttr(attr, value);
  if not Result then begin
    case attr[0] of
      'p': if StrComp(attr, 'position')=0 then begin
        S0:=PosSpec;
        S:=S0+'=';
        SetLength(S, PosSpecLen+SizeOf(vec3_t));
        PChar(DestP):=PChar(S)+PosSpecLen;
        P:=PyVect(value);
        if P=Nil then
          Exit;
        if P^.ob_type <> @TyVect_Type then
          Raise EError(4441);
        with P^.V do begin
          DestP^[0]:=X;
          DestP^[1]:=Y;
          DestP^[2]:=Z;
        end;
        if Specifics.IndexofName(PosSpec)<>-1 then
          //FIXME: BAD CODING TACTIC!
          Specifics.Delete(Specifics.IndexofName(PosSpec));
        Specifics.Add(S);
        Result:=True;
        Exit;
      end;
      'r': if StrComp(attr, 'rotmatrix')=0 then begin
        S0:=RotSpec;
        S:=S0+'=';
        SetLength(S, RotSpecLen+SizeOf(TMatrixTransformation));
        PChar(DestM):=PChar(S)+RotSpecLen;
        M:=PyMatrix(value);
        if M=Nil then
          Exit;
        if M^.ob_type <> @TyMatrix_Type then
          Raise EError(4462);
        with M^ do begin
          DestM^[1][1]:=M[1][1];
          DestM^[1][2]:=M[1][2];
          DestM^[1][3]:=M[1][3];
          DestM^[2][1]:=M[2][1];
          DestM^[2][2]:=M[2][2];
          DestM^[2][3]:=M[2][3];
          DestM^[3][1]:=M[3][1];
          DestM^[3][2]:=M[3][2];
          DestM^[3][3]:=M[3][3];
        end;
        if Specifics.IndexofName(RotSpec)<>-1 then
          //FIXME: BAD CODING TACTIC!
          Specifics.Delete(Specifics.IndexofName(RotSpec));
        Specifics.Add(S);
        Result:=True;
        Exit;
      end;
      'v': if StrComp(attr, 'vtxlist')=0 then begin
        S0:=VertSpec;
        S:=S0+'=';
        SetLength(S, VertSpecLen);
        I:=VertSpecLen;
        PChar(DestV):=PChar(S)+I;
        N:=PyObject_Length(value);
        SetLength(S, I+SizeOf(Integer));
        PChar(DestV):=PChar(S)+I;
        Move(N, DestV^, SizeOf(Integer));
        I:=I+SizeOf(Integer);
        DictLen:=0;
        while (PyDict_Next(value, @DictLen, @DictKey, @DictValue)<>0) do
        begin
          S2:=PyString_AsString(DictKey);
          SetLength(S, I+Length(S2)+1);
          PChar(DestV):=PChar(S)+I;
          StrCopy(DestV, PChar(S2));
          I:=I+Length(S2)+1;
          N2:=PyObject_Length(DictValue);
          SetLength(S, I+SizeOf(Integer));
          PChar(DestV):=PChar(S)+I;
          Move(N2, DestV^, SizeOf(Integer));
          I:=I+SizeOf(Integer);
          for I2:=0 to N2-1 do
          begin
            o2:=PyList_GetItem(DictValue, I2);
            I3:=PyInt_AsLong(o2);
            SetLength(S, I+SizeOf(Integer));
            PChar(DestV):=PChar(S)+I;
            Move(I3, DestV^, SizeOf(Integer));
            I:=I+SizeOf(Integer);
          end;
        end;
        //FIXME: Check for ref counters bugs!
        if Specifics.IndexofName(VertSpec)<>-1 then
          //FIXME: BAD CODING TACTIC!
          Specifics.Delete(Specifics.IndexofName(VertSpec));
        Specifics.Add(S);
        Result:=True;
        Exit;
      end
      else if StrComp(attr, 'vtx_pos')=0 then begin
        S0:=VertPosSpec;
        S:=S0+'=';
        SetLength(S, VertPosSpecLen);
        I:=VertPosSpecLen;
        PChar(DestV):=PChar(S)+I;
        N:=PyObject_Length(value);
        SetLength(S, I+SizeOf(Integer));
        PChar(DestV):=PChar(S)+I;
        Move(N, DestV^, SizeOf(Integer));
        I:=I+SizeOf(Integer);
        DictLen:=0;
        while (PyDict_Next(value, @DictLen, @DictKey, @DictValue)<>0) do
        begin
          S2:=PyString_AsString(DictKey);
          SetLength(S, I+Length(S2)+1);
          PChar(DestV):=PChar(S)+I;
          StrCopy(DestV, PChar(S2));
          I:=I+Length(S2)+1;
          N2:=PyObject_Length(DictValue);
          SetLength(S, I+SizeOf(Integer));
          PChar(DestV):=PChar(S)+I;
          Move(N2, DestV^, SizeOf(Integer));
          I:=I+SizeOf(Integer);
          for I2:=0 to N2-1 do
          begin
            o2:=PyList_GetItem(DictValue, I2);
            I3:=PyInt_AsLong(o2);
            SetLength(S, I+SizeOf(Integer));
            PChar(DestV):=PChar(S)+I;
            Move(I3, DestV^, SizeOf(Integer));
            I:=I+SizeOf(Integer);
          end;
        end;
        //FIXME: Check for ref counters bugs!
        if Specifics.IndexofName(VertPosSpec)<>-1 then
          //FIXME: BAD CODING TACTIC!
          Specifics.Delete(Specifics.IndexofName(VertPosSpec));
        Specifics.Add(S);
        Result:=True;
        Exit;
      end;
    end;
  end;
end;

initialization
  RegisterQObject(QModelBone,  'a');
end.

