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
unit qkskindrawobject;

interface

uses SysUtils, QkObjects, Qk3D, Graphics,
     QkImages, qmath, QkTextures, PyMath, Python, QkMdlObject;

type
  QSkinDrawObject = class(QMdlObject)
  public
    class function TypeInfo: String; override;
    function IsAllowedParent(Parent: QObject) : Boolean; override;
    procedure Dessiner; override;
    procedure CouleurDessin(var C: TColor);
  end;

implementation

uses QkModelRoot, QkComponent, QkObjectClassList, QkExceptions;

function QSkinDrawObject.IsAllowedParent(Parent: QObject) : Boolean;
begin
  if (Parent=nil) or (Parent is QComponent) then
    Result:=true
  else
    Result:=false;
end;

procedure QSkinDrawObject.CouleurDessin;
const
 SpecColor2 = '_color';
var
  S: String;
begin
  S:=Specifics.Values[SpecColor2];
  if S<>'' then begin
    C:=clNone;
    try
      C:=vtocol(ReadVector(S));
    except
      {rien}
    end;
  end;
end;

class function QSkinDrawObject.Typeinfo:string;
begin
  result:=':sdo';
end;

type
  TTri = array[0..2] of TVect;
  PTri = ^TTri;

function GetSkinTriangles(Comp: QComponent; var Tris: PTri): Integer;
var
  i, j: Integer;
  skin_dims: array[1..2] of single;
  numtris: Integer;
  triangles: PComponentTris;
  aTris: PTri;
begin
  comp.GetFloatsSpec('skinsize', skin_dims);
  numtris:=comp.Triangles(triangles);
  GetMem(Tris, sizeof(TTri)*NumTris);
  aTris:=Tris;
  result:=numtris;
  for i:=0 to numtris-1 do
  begin
    for j:=0 to 2 do
    begin
      aTris^[j].X:=Triangles^[j].S;
      aTris^[j].Y:=Triangles^[j].T;
      aTris^[j].Z:=0;
    end;
    inc(aTris);
    inc(Triangles);
  end;
end;

{type
  TTableauInt = Integer;
  PTableauInt = ^TTableauInt;}

procedure QSkinDrawObject.Dessiner;
var
  Tris, aTris: PTri;
  I, J: Integer;
  numtris: integer;
  c: qcomponent;
  pa, pa_o: PPointProj;
begin
  //FIXME: Is this code dead? It's never called from QkComponent!
  //In fact, it seems to ONLY be used to retrieve the texture size from Python!
  //I think this entire class can be REMOVED!
  if not(CCoord is T2DCoordinates) then exit;
  if not (md2dOnly in g_DrawInfo.ModeDessin) then exit;
  c:=QComponent(Self.FParent);
  if (c = nil) or not(c is QComponent) then
    Raise InternalE('QSkinDrawObject.Dessiner: C is not a QComponent');
  //FIXME: CouleurDessin(C1);
  numtris:=GetSkinTriangles(c, Tris);
  //  draw 'c.currentskin' on canvas
    { don't know how }
  //  draw net connecting vertices
  try
    aTris:=Tris;
    getmem(pa_o, sizeof(TPointProj)*3);
    try
      for i:=0 to numtris-1 do
      begin
        pa:=pa_o;
        for j:=0 to 2 do
        begin
          pA^:=CCoord.Proj(aTris^[j]);
          inc(pa);
        end;
        CCoord.Polygon95f(pa_o^,3, false);
        inc(aTris);
      end;
    finally
      freemem(pa_o);
    end;
  finally
    FreeMem(Tris);
  end;
end;

initialization
  RegisterQObject(QSkinDrawObject, 'a');
end.
