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
unit QkMiscGroup;

interface

uses
  QkObjects, QkFileObjects, QkForm, QkImages, Python, Game, QkMdlObject;

type
  QMiscGroup = Class(QMdlObject)
  public
    class function TypeInfo: String; override;
    function IsAllowedParent(Parent: QObject) : Boolean; override;
    //procedure AddTo3DScene(Scene: TObject); override;
    procedure AnalyseClic(Liste: PyObject); override;
  end;

implementation

uses QkObjectClassList, QkModelRoot, QkMapPoly, QkMapObjects, QkBBoxGroup;

function QMiscGroup.IsAllowedParent(Parent: QObject) : Boolean;
begin
  if (Parent=nil) or (Parent is QModelRoot) then
    Result:=true
  else
    Result:=false;
end;

(*procedure QMiscGroup.AddTo3DScene(Scene: TObject);
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is TPolyhedron then
      QMdlObject(Q).AddTo3DScene(Scene);
  end;
end;*)

procedure QMiscGroup.AnalyseClic;
var
  I: Integer;
  Q: QObject;
begin
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if (Q is TPolyhedron) then
      TPolyhedron(Q).AnalyseClic(Liste)
    else if (Q is TTreeMapGroup) then
      TTreeMapGroup(Q).AnalyseClic(Liste)
    else if (Q is QBBoxGroup) then
      QBBoxGroup(Q).AnalyseClic(Liste);
  end;
end;

class function QMiscGroup.TypeInfo;
begin
  TypeInfo:=':mg';
end;

initialization
  RegisterQObject(QMiscGroup, 'a');
end.

