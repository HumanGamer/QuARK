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

unit PyMath3D;

interface

uses Windows, qmath, PyMath;

const
 MinW = 64.0;
 MaxW = 65535.0-128.0;   { Note: constants copied from Ed3DFX }
 Minoow = 1.0001/MaxW;
 Maxoow = 0.9999/MinW;
 RFACTOR_1 = 32768*1.1;
 MAX_PITCH = pi/2.1;

type
  T3DCoordinates = class(TCoordinates)
  protected
    Eye, Look, Right, Down: TVect;
    ooWFactor, SpaceFactor: TDouble;
    procedure InitProjVar;
  public
    FarDistance: TDouble;
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
    function NearerThan(const oow1, oow2: Single) : Boolean; override;
    function ScalingFactor(Pt: PVect) : TDouble; override;
    property FCheckRadius: TDouble read ooWFactor;
  end;

  TCameraCoordinates = class(T3DCoordinates)
  protected
    FHorzAngle, FPitchAngle, RFactorDistance: TDouble;
  public
    VAngleDegrees: Single;
    RFactorBase: TDouble;
    property Camera: TVect read Eye write Eye;
    property HorzAngle: TDouble read FHorzAngle write FHorzAngle;
    property PitchAngle: TDouble read FPitchAngle write FPitchAngle;
    procedure ResetCamera;
    procedure Resize(nWidth, nHeight: Integer); override;
  end;

 {------------------------}

function Get3DCoord : TCameraCoordinates;
procedure CameraVectors(const nHorzAngle, nPitchAngle, nLength: TDouble; var Look, Right, Down: TVect);

 {------------------------}

implementation

 {------------------------}

function Get3DCoord : TCameraCoordinates;
begin
 Result:=TCameraCoordinates.Create;
 Result.InitProjVar;
end;

 {------------------------}

procedure T3DCoordinates.InitProjVar;
begin
 inherited;
 HiddenRegions:=os_Left or os_Right or os_Top or os_Bottom or os_Back;
 MinDistance:=Minoow;
 MaxDistance:=Maxoow;
end;

(*procedure T3DCoordinates.Resize(nWidth, nHeight: Integer);
begin
{ViewRectLeft:=0;
 ViewRectTop:=0;
 ViewRectRight:=nWidth;
 ViewRectBottom:=nHeight;}
 ScrCenter.X:=nWidth div 2;
 ScrCenter.Y:=nHeight div 2;
end;*)

function T3DCoordinates.Espace(const P: TPointProj) : TVect;
var
 Dist, X, Y: TDouble;
begin
 Dist:=ooWFactor/P.oow;
 X:=(P.x-ScrCenter.X)*SpaceFactor;
 Y:=(P.y-ScrCenter.Y)*SpaceFactor;
 Result.X := Dist * (X*Right.X + Y*Down.X + Look.X) + Eye.X;
 Result.Y := Dist * (X*Right.Y + Y*Down.Y + Look.Y) + Eye.Y;
 Result.Z := Dist * (X*Right.Z + Y*Down.Z + Look.Z) + Eye.Z;
end;

function T3DCoordinates.Proj(const V: TVect) : TPointProj;
var
 Delta: TVect;
 Dist: TDouble;
begin
 Delta.X:=V.X - Eye.X;
 Delta.Y:=V.Y - Eye.Y;
 Delta.Z:=V.Z - Eye.Z;
 Dist:=Dot(Delta, Look);
 if (Dist>-rien) and (Dist<rien) then
  if Dist>0 then
   Dist:=rien
  else
   Dist:=-rien;
 Result.oow:=ooWFactor/Dist;
 Result.x:=Dot(Delta, Right) * Result.oow + ScrCenter.X;
 Result.y:=Dot(Delta, Down) * Result.oow + ScrCenter.Y;
end;

function T3DCoordinates.VectorX;
begin
 VectorX:=Right;
end;

function T3DCoordinates.VectorY;
begin
 VectorY:=Down;
end;

function T3DCoordinates.VectorEye;
begin
 Result.X:=Eye.X-Pt.X;
 Result.Y:=Eye.Y-Pt.Y;
 Result.Z:=Eye.Z-Pt.Z;
end;

function T3DCoordinates.PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean;
begin
 Result:=NormaleX*Eye.X + NormaleY*Eye.Y + NormaleZ*Eye.Z > Dist;
end;

function T3DCoordinates.NearerThan(const oow1, oow2: Single) : Boolean;
begin
 { the result to compute is "1/oow1 < 1/oow2" }
 if oow1>=0 then
  Result:=(0<=oow2) and (oow2<oow1)
 else
  Result:=(oow2>=0) or (oow1<oow2);
end;

function T3DCoordinates.ScalingFactor(Pt: PVect) : TDouble;
var
 Delta: TVect;
 Dist: TDouble;
begin
 if Pt=Nil then
  Result:=inherited ScalingFactor(Nil)
 else
  begin
   Delta.X:=Pt^.X - Eye.X;
   Delta.Y:=Pt^.Y - Eye.Y;
   Delta.Z:=Pt^.Z - Eye.Z;
   Dist:=Dot(Delta, Look);
   if (Dist>-rien) and (Dist<rien) then
    if Dist>0 then
     Dist:=rien
    else
     Dist:=-rien;
   Result:=Sqrt(Sqr(Right.X)+Sqr(Right.Y)+Sqr(Right.Z))*ooWFactor/Dist;
  end;
end;

 {------------------------}

procedure CameraVectors(const nHorzAngle, nPitchAngle, nLength: TDouble; var Look, Right, Down: TVect);
var
 SA,CA,SP,CP: TDouble;
begin
 SA:=Sin(nHorzAngle);  CA:=Cos(nHorzAngle);
 SP:=Sin(nPitchAngle); CP:=Cos(nPitchAngle);
 Look.X:=CA*CP;
 Look.Y:=SA*CP;
 Look.Z:=SP;
 Right.X:=SA*nLength;
 Right.Y:=-CA*nLength;
 Right.Z:=0;
 Down.X:=SP*CA*nLength;
 Down.Y:=SP*SA*nLength;
 Down.Z:=-CP*nLength;
end;

procedure TCameraCoordinates.ResetCamera;
var
 nRFactor: TDouble;
begin
 nRFactor:=RFactorDistance/FarDistance;
 CameraVectors(HorzAngle, PitchAngle, nRFactor, Look, Right, Down);
 ooWFactor:=FarDistance*(1/MaxW);
 SpaceFactor:=1/(Sqr(nRFactor)*ooWFactor);
end;

procedure TCameraCoordinates.Resize(nWidth, nHeight: Integer);
begin
 inherited;
 RFactorDistance:=nHeight*RFactorBase*RFACTOR_1;
 ResetCamera;
end;

 {------------------------}

end.
