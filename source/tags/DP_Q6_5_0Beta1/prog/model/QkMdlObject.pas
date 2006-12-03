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
Revision 1.4  2001/03/20 21:37:18  decker_dk
Updated copyright-header

Revision 1.3  2001/02/28 19:03:25  aiv
Fixed ref count prob.

Revision 1.2  2000/10/11 19:01:08  aiv
Small updates
}

unit QkMdlObject;

interface

uses Windows, SysUtils, Classes, QkObjects, Qk3D, QkForm, Graphics,
     qmath, PyMath, Python;

type
  dstvert_p = ^dstvert_t;
  dstvert_t = packed record
    s,t: SmallInt;
  end;

(***********  QuArK objects  ***********)

type
  PComponentVertex = ^TComponentVertex;
  TComponentVertex = packed record
    VertexNo: Word;
    case Integer of
      0: (S, T: SmallInt);
      1: (st: dstvert_t);
      2: (longst: LongInt);
    end;
  PComponentTris = ^TComponentTris;
  TComponentTris = packed array[0..2] of TComponentVertex;

type
  QMdlObject = class(Q3DObject)
  public
    class function TypeInfo: String; override;
    procedure ObjectState(var E: TEtatObjet); override;
    function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
    procedure AddTo3DScene; override;
    procedure BuildRefList(L: TQList); virtual;
    procedure ChercheExtremites(var Min, Max: TVect); override;
    procedure Dessiner; override;
    procedure AnalyseClic(Liste: PyObject); override;
//    procedure FixupReference; override;
  end;

implementation

uses qkskindrawobject;

class function QMdlObject.TypeInfo;
begin
  TypeInfo:=':m';
end;

procedure QMdlObject.ObjectState(var E: TEtatObjet);
begin
  inherited;
  E.IndexImage:=iiModelGroup;
end;

function QMdlObject.IsExplorerItem(Q: QObject) : TIsExplorerItem;
begin
  Result:=ieResult[not (Q is QSkinDrawObject)];
end;

{procedure QMdlObject.FixupReference;
begin
  PythonObj.ob_refcnt:=0;
end;                        }

procedure QMdlObject.AddTo3DScene;
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is QMdlObject then
      QMdlObject(Q).AddTo3DScene;
  end;
end;

procedure QMdlObject.BuildRefList(L: TQList);
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is QMdlObject then
      QMdlObject(Q).BuildRefList(L);
  end;
end;

procedure QMdlObject.ChercheExtremites(var Min, Max: TVect);
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is QMdlObject then
      QMdlObject(Q).ChercheExtremites(Min, Max);
  end;
end;

procedure QMdlObject.Dessiner;
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is QMdlObject then
      QMdlObject(Q).Dessiner;
  end;
end;

procedure QMdlObject.AnalyseClic;
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is QMdlObject then
      QMdlObject(Q).AnalyseClic(Liste);
  end;
end;

end.
