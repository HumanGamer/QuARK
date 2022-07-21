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
unit Coordinates;

interface

uses Windows, Types, qmath, qmatrices;

const
 os_Left    = $01;   { x too small }
 os_Right   = $02;   { x too large }
 os_Top     = $04;   { y too small }
 os_Bottom  = $08;   { y too large }
 os_Back    = $10;   { behind the eye }
 os_Far     = $20;   { too far away }

 //For 3D coordinates
 MinW = 1; //Glide
 MaxW = 65535; //Glide
 Minoow = 1.0001/MaxW;
 Maxoow = 0.9999/MinW;
 RFACTOR_1 = 32768*1.1;

type
  PPointProj = ^TPointProj;
  TPointProj = record
                x, y, oow: Single; //FIXME: TDouble?
                OffScreen: Byte;
                OnEdge: Byte;
               end;
  TCoordinates = class
  protected
    procedure InitProjVar;
  public
    pDeltaX, pDeltaY: Integer;   { offset of the origin }
    FastDisplay: Boolean;   { can use the standard drawing routines }
    FlatDisplay: Boolean;   { is a 2D view }
    HiddenRegions: Byte;   { os_xxx }
    MinDistance, MaxDistance: TDouble;
    ScrCenter: TPoint;
     { 3D point -> window (x,y,w), w is the distance from the viewer with the same scale as x and y }
    function Proj(const V: TVect) : TPointProj; virtual; abstract;
     { compute "OffScreen" and return True is the point is visible at all }
    function CheckVisible(var P: TPointProj) : Boolean;
     { window (x,y,w) -> 3D point }
    function Espace(const P: TPointProj) : TVect; virtual; abstract;
     { 3D vector in the direction "Espace(1,0,1)-Espace(0,0,1)" }
    function VectorX : TVect; virtual; abstract;
     { 3D vector in the direction "Espace(0,1,1)-Espace(0,0,1)" }
    function VectorY : TVect; virtual; abstract;
     { 3D vector in the direction "Espace(1,1,0)-Espace(0,0,1)" }
    function VectorZ : TVect; virtual; abstract;
     { 3D vector from Pt in the direction of the eye }
    function VectorEye(const Pt: TVect) : TVect; virtual; abstract;
     { is the "eye" in the given half space ? }
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; virtual; abstract;
     { compare two TPointProj.oow depths }
    function NearerThan(const oow1, oow2: Single) : Boolean; virtual; abstract;
   (*{ normal vector end }
    function VecteurNormalDe(const Centre, Normale: TVect) : TVect;*)
     { scaling factor, if any }
    function ScalingFactor(const Pt: PVect) : TDouble; virtual;
     { set as current CCoord }
    procedure SetAsCCoord(nDC: HDC);
     { checks for orthogonality }
    function Orthogonal : Boolean; virtual;   { FIXME: do it }
     { drawing routines }
    procedure Line95(P1, P2: TPointProj);
    procedure Line95f(P1, P2: TPointProj);
    function ClipLine95(var P1, P2: TPointProj) : Boolean;
    procedure Polygon95(var Pts; NbPts: Integer; CCW: Boolean);
    procedure Polygon95f(var Pts; NbPts: Integer; CCW: Boolean);
    procedure Polyline95(var Pts; NbPts: Integer);
    procedure Polyline95f(const Pts; NbPts: Integer);
    procedure Rectangle3D(const V1, V2, V3: TVect; Fill: Boolean);
     { screen dimension changing }
    procedure Resize(nWidth, nHeight: Integer); virtual;
  end;

(*T2DCoordinates = class(TCoordinates)
  protected
    pProjZ, Facteur: TDouble;
    procedure InitProjVar;
  public
    function ScalingFactor(const Pt: PVect) : TDouble; override;
    function NearerThan(const oow1, oow2: Single) : Boolean; override;
  end;

  TStdCoordinates = class(T2DCoordinates)
  protected
    pProjX, pProjY: TDouble;
    Vue: (v_XY, v_YmX, v_mXmY, v_mYX, v_Autre);
    procedure InitProjVar;
  public
    function Orthogonal : Boolean; override;
  end;

  TXYCoordinates = class(TStdCoordinates)
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
  end;

  TXY2Coordinates = class(TXYCoordinates)
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
  end;

  TXZCoordinates = class(TStdCoordinates)
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
  end;

  TAACoordinates = class(T2DCoordinates)
  protected
    SinAngle, CosAngle: TDouble;    { normalized, length 1 }
    SinAngleV, CosAngleV: TDouble;  { not normalized, length pProjZ }
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
    {function Orthogonal : Boolean; override;}
  end;*)

  T2DCoordinates = class(TCoordinates)
  protected
    pProjZ: TDouble;
    mx, mxinv: TMatrixTransformation;
    procedure InitProjVar;
  public
    function ScalingFactor(const Pt: PVect) : TDouble; override;
    function NearerThan(const oow1, oow2: Single) : Boolean; override;
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorZ : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
  end;

  TXYCoordinates = class(T2DCoordinates)
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
  end;

  TXZCoordinates = class(T2DCoordinates)
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
  end;

  T3DCoordinates = class(TCoordinates)
  protected
    Eye, Look, Right, Down: TVect;
    ooWFactor, SpaceFactor: TDouble;
    procedure InitProjVar;
  public
    function Espace(const P: TPointProj) : TVect; override;
    function Proj(const V: TVect) : TPointProj; override;
    function VectorX : TVect; override;
    function VectorY : TVect; override;
    function VectorZ : TVect; override;
    function VectorEye(const Pt: TVect) : TVect; override;
    function PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean; override;
    function NearerThan(const oow1, oow2: Single) : Boolean; override;
    function ScalingFactor(const Pt: PVect) : TDouble; override;
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

var
  CCoord : TCoordinates;

{function GetCoordinates(const Up: TVect; const Scale: TDouble) : T2DCoordinates;
function GetTopDownAngle(const Angle, Scale: TDouble; BottomUp: Boolean) : TXYCoordinates;
function GetAngleCoord(const Angle, VAngle, Scale: TDouble) : T2DCoordinates;}

function GetMatrixCoordinates(const mx: TMatrixTransformation) : T2DCoordinates;

function Get3DCoord : TCameraCoordinates;
procedure CameraVectors(const nHorzAngle, nPitchAngle, nLength: TDouble; var Look, Right, Down: TVect);

 {------------------------}

implementation

{ $DEFINE DebugCoord}

uses qdraw, Qk3D, QkMapPoly, Setup, SystemDetails;

const
  MaxoowLocal = 1.0;

 {------------------------}

function Ligne95(var P1, P2: TPointProj; Test3D: Boolean) : Boolean;
var
 F: TDouble;
 P1x, P2x: TPoint;
begin
 if Test3D then
  begin
   if P1.OffScreen and os_Back <> 0 then
    begin
     if P2.OffScreen and os_Back <> 0 then
      begin
       Ligne95:=False;
       Exit;
      end;
     F:=(P2.oow-MaxoowLocal)/(P2.oow-P1.oow);
     P1.X:=P2.X + F*(P1.X-P2.X);
     P1.Y:=P2.Y + F*(P1.Y-P2.Y);
    end;
   if P2.OffScreen and os_Back <> 0 then
    begin
     F:=(P1.oow-MaxoowLocal)/(P1.oow-P2.oow);
     P2.X:=P1.X + F*(P2.X-P1.X);
     P2.Y:=P1.Y + F*(P2.Y-P1.Y);
    end;
  end;

 P1x.X:=Round(P1.X);
 P1x.Y:=Round(P1.Y);
 P2x.X:=Round(P2.X);
 P2x.Y:=Round(P2.Y);
 Result:=qdraw.Ligne95(P1x, P2x);
end;

function TCoordinates.ClipLine95(var P1, P2: TPointProj) : Boolean;
begin
 Result:=Ligne95(P1, P2, not FlatDisplay);
end;

procedure TCoordinates.Line95(P1, P2: TPointProj);
begin
 CheckVisible(P1);
 CheckVisible(P2);
 if Ligne95(P1, P2, not FlatDisplay) then
  begin
   Windows.MoveToEx(g_DrawInfo.DC, Round(P1.x), Round(P1.y), Nil);
   Windows.LineTo(g_DrawInfo.DC, Round(P2.x), Round(P2.y));
  end;
end;

procedure TCoordinates.Line95f(P1, P2: TPointProj);
begin
 if Ligne95(P1, P2, not FlatDisplay) then
  begin
   Windows.MoveToEx(g_DrawInfo.DC, Round(P1.x), Round(P1.y), Nil);
   Windows.LineTo(g_DrawInfo.DC, Round(P2.x), Round(P2.y));
  end;
end;

procedure TCoordinates.Polygon95(var Pts; NbPts: Integer; CCW: Boolean);
var
 PV: PPointProj;
 N: Integer;
begin
 PV:=@Pts;
 for N:=1 to NbPts do
  begin
   CheckVisible(PV^);
   Inc(PV);
  end;
 Polygon95f(Pts, NbPts, CCW);
end;

procedure TCoordinates.Polygon95f(var Pts; NbPts: Integer; CCW: Boolean);
type
 FxFloat = Single;
 TV1 = TPointProj;
 TBBox = (bbX, bbY, bbW);
const
 MAX_VERTICES = 4*MaxFVertices;
 oe_Left   = 1;
 oe_Top    = 2;
 oe_Right  = 3;
 oe_Bottom = 4;
var
 FindVertexState: Integer;
 PV, BaseV, BaseMaxV, SourceV, LoadedTarget: PPointProj;
 PV1, PrevV1, NewV1, TargetV1: TV1;
 ScrMask, ScrTotal, ScrDiff, SourceEdge, LastEdge: Byte;
 PrevChanged: Boolean;
 VList: array[0..MAX_VERTICES-1] of TPoint;
 N: Integer;
 aa, bb: Single;
 ViewRectLeft, ViewRectTop, ViewRectRight, ViewRectBottom: Integer;

  procedure LoadV(var PrevV1: TV1; PV: PPointProj);
  begin
   PrevV1:=PV^;
   with PrevV1 do
    begin
     OffScreen:=OffScreen and ScrMask;
     OnEdge:=0;
    end;
  end;

  procedure ScaleInterval(var PrevV1: TV1; const PV1: TV1; F: FxFloat; BBox: TBBox; nValue: FxFloat);
  var
   nScr: Byte;
  begin
   nScr:=0;
   if BBox=bbX then
    PrevV1.x:=nValue
   else
    begin
     PrevV1.x:=PrevV1.x + (PV1.x-PrevV1.x)*F;
     if PrevV1.x<ViewRectLeft  then Inc(nScr, os_Left) else
     if PrevV1.x>ViewRectRight then Inc(nScr, os_Right);
    end;
   if BBox=bbY then
    PrevV1.y:=nValue
   else
    begin
     PrevV1.y:=PrevV1.y + (PV1.y-PrevV1.y)*F;
     if PrevV1.y<ViewRectTop    then Inc(nScr, os_Top) else
     if PrevV1.y>ViewRectBottom then Inc(nScr, os_Bottom);
    end;
   if BBox=bbW then
    PrevV1.oow:=nValue
   else
    PrevV1.oow:=PrevV1.oow + (PV1.oow-PrevV1.oow)*F;
  {PrevV1.sow:=PrevV1.sow + (PV1.sow-PrevV1.sow)*F;
   PrevV1.tow:=PrevV1.tow + (PV1.tow-PrevV1.tow)*F;}
   PrevV1.OffScreen:=nScr;
  end;

  procedure ComingFrom(F: FxFloat; BBox: TBBox; nValue: FxFloat);
  begin
   ScaleInterval(PrevV1, PV1, F, BBox, nValue);
   ScrDiff:=PrevV1.OffScreen xor PV1.OffScreen;
   PrevChanged:=True;
  end;

  procedure GoingInto(F: FxFloat; BBox: TBBox; nValue: FxFloat);
  begin
   ScaleInterval(PV1, PrevV1, F, BBox, nValue);
   ScrDiff:=PV1.OffScreen xor PrevV1.OffScreen;
  end;

  procedure Output(const V1: TV1);
  begin
   with VList[N] do
    begin
     X:=Round(V1.x);
     Y:=Round(V1.y);
    end;
   Inc(N);
  end;

  procedure AddCorners(Target: Byte);
  begin
   while Target<>LastEdge do
    begin
     with VList[N] do
      if CCW then
       begin
        case LastEdge of
         oe_Left:   begin
                     x:=ViewRectLeft;
                     y:=ViewRectTop;
                    end;
         oe_Top:    begin
                     x:=ViewRectRight;
                     y:=ViewRectTop;
                    end;
         oe_Right:  begin
                     x:=ViewRectRight;
                     y:=ViewRectBottom;
                    end;
         oe_Bottom: begin
                     x:=ViewRectLeft;
                     y:=ViewRectBottom;
                    end;
        end;
        LastEdge:=(LastEdge and 3)+1;
       end
      else
       begin
        case LastEdge of
         oe_Top:    begin
                     x:=ViewRectLeft;
                     y:=ViewRectTop;
                    end;
         oe_Right:  begin
                     x:=ViewRectRight;
                     y:=ViewRectTop;
                    end;
         oe_Bottom: begin
                     x:=ViewRectRight;
                     y:=ViewRectBottom;
                    end;
         oe_Left:   begin
                     x:=ViewRectLeft;
                     y:=ViewRectBottom;
                    end;
        end;
        Dec(LastEdge);
        if LastEdge=0 then LastEdge:=4;
       end;
     Inc(N);
    end;
  end;

  function FindVertex : Boolean;
  var
   Scr, Scr2: Byte;
   ClosingLoop: Integer;
  begin
   ClosingLoop:=3;
   Result:=True;
   repeat
    case FindVertexState of
     0: begin  { initialization }
         with SourceV^ do
          begin
          {if oow<0 then
            begin
             if MinRadius*oow < PProjInfo(FProjInfo)^.ooWFactor then
              begin
               Result:=False;
               Exit;
              end;
            end
           else
            if MaxRadius*oow < PProjInfo(FProjInfo)^.ooWFactor then
             begin
              Result:=False;
              Exit;
             end;}
           Scr:=OffScreen and ScrMask;
          end;
         if Scr and (os_Back {or os_Far}) = 0 then
          begin
           LoadV(PV1, SourceV);
           FindVertexState:=1;
           Exit;
          end;
         FindVertexState:=2;
         ClosingLoop:=5;
        end;
     1: begin  { previous vertex (PrevV1) was on-screen }
         if PV=BaseV then
          begin
           Result:=False;
           Exit;
          end;
         Dec(PV);
         with PV^ do
          Scr:=OffScreen and ScrMask;
         LoadV(PV1, PV);
         if Scr and (os_Back {or os_Far}) = 0 then
          Exit;  { next vertex is also on-screen }
         TargetV1:=PV1;
         LoadedTarget:=PV;
       (*if Scr and os_Back <> 0 then*)
          begin   { entering the back area }
           ScaleInterval(PV1, PrevV1,
            (MaxoowLocal-PV1.oow) / (PrevV1.oow-PV1.oow), bbW, MaxoowLocal);
          end
       (*else
          begin   { entering the far area }
           ScaleInterval(PV1, PrevV1,
            (Minoow-PV1.oow) / (PrevV1.oow-PV1.oow), bbW, Minoow);
          end*);
         SourceV:=PV;
         FindVertexState:=2;
         Exit;
        end;
     2: begin  { previous vertex (SourceV) off-screen, searching }
         if PV=BaseV then
          begin
           if ClosingLoop<>3 then
            begin
             Result:=False;
             Exit;
            end;
           ClosingLoop:=4;
           PV:=BaseMaxV;
          end;
         Dec(PV);
         Scr:=SourceV^.OffScreen and ScrMask;
         with PV^ do
          begin
           Scr2:=OffScreen and ScrMask;
           if (Scr and (os_Back {or os_Far})) = (Scr2 and (os_Back {or os_Far})) then
            SourceV:=PV   { keep searching }
           else
            begin
             if LoadedTarget=SourceV then
              PV1:=TargetV1
             else
              LoadV(PV1, SourceV);
             LoadV(TargetV1, PV);
             LoadedTarget:=PV;
           (*if Scr and os_Back <> 0 then*)
              begin   { entering the visible area from os_Back }
               ScaleInterval(PV1, TargetV1,
                (MaxoowLocal-PV1.oow) / (TargetV1.oow-PV1.oow), bbW, MaxoowLocal);
              end
           (*else
              begin   { entering the visible area from os_Far }
               ScaleInterval(PV1, TargetV1,
                (Minoow-PV1.oow) / (TargetV1.oow-PV1.oow), bbW, Minoow);
              end*);
             FindVertexState:=ClosingLoop;
             Exit;
            end;
          end;
        end;
     3: begin  { previous vertex (PrevV1) was on w-edge }
         with PV^ do
          Scr:=OffScreen and ScrMask;
         PV1:=TargetV1;
         if Scr and (os_Back {or os_Far}) = 0 then
          begin   { target vertex is on-screen }
           FindVertexState:=1;
           Exit;
          end;
       (*if Scr and os_Back <> 0 then*)
          begin   { entering the back area }
           ScaleInterval(PV1, PrevV1,
            (MaxoowLocal-PV1.oow) / (PrevV1.oow-PV1.oow), bbW, MaxoowLocal);
          end
       (*else
          begin   { entering the far area }
           ScaleInterval(PV1, PrevV1,
            (Minoow-PV1.oow) / (PrevV1.oow-PV1.oow), bbW, Minoow);
          end*);
         SourceV:=PV;
         FindVertexState:=2;
         Exit;
        end;
     4: begin   { ClosingLoop }
         Result:=False;
         Exit;
        end;
     5: FindVertexState:=3;  { end of initialization }
    end;
   until False;
  end;

begin
 ViewRectLeft  :=0;
 ViewRectTop   :=0;
 ViewRectRight :=(ScrCenter.X * 2) + 1; //compensate for rounding
 ViewRectBottom:=(ScrCenter.Y * 2) + 1; //compensate for rounding
 ScrMask:=HiddenRegions;
 PV:=@Pts;
 BaseV:=PV;
 Inc(PV, NbPts);
 BaseMaxV:=PV;
 SourceV:=BaseV;
 LoadedTarget:=Nil;
 FindVertexState:=0;
 if FindVertex then
  begin
   PrevV1:=PV1;
   N:=0;
   SourceEdge:=0;
   LastEdge:=0;
   ScrTotal:=PrevV1.OffScreen;
   while FindVertex do
    begin
     ScrTotal:=ScrTotal or PV1.OffScreen;
     if PrevV1.OffScreen and PV1.OffScreen <> 0 then
      PrevV1:=PV1  { completely off-screen }
     else
      if PrevV1.OffScreen or PV1.OffScreen = 0 then
       begin  { completely on-screen }
        Output(PV1);
        PrevV1:=PV1;
        LastEdge:=0;
       end
      else
       begin  { partially on-screen }
        NewV1:=PV1;
        PrevChanged:=False;
        ScrDiff:=PrevV1.OffScreen xor PV1.OffScreen;
        if ScrDiff and os_Left <> 0 then
         if PV1.OffScreen and os_Left = 0 then
          begin
           ComingFrom((ViewRectLeft-PrevV1.x) / (PV1.x-PrevV1.x), bbX, ViewRectLeft);
           PrevV1.OnEdge:=oe_Left;
          end
         else
          begin
           GoingInto((ViewRectLeft-PV1.x) / (PrevV1.x-PV1.x), bbX, ViewRectLeft);
           PV1.OnEdge:=oe_Left;
          end;
        if ScrDiff and os_Right <> 0 then
         if PV1.OffScreen and os_Right = 0 then
          begin
           ComingFrom((ViewRectRight-PrevV1.x) / (PV1.x-PrevV1.x), bbX, ViewRectRight);
           PrevV1.OnEdge:=oe_Right;
          end
         else
          begin
           GoingInto((ViewRectRight-PV1.x) / (PrevV1.x-PV1.x), bbX, ViewRectRight);
           PV1.OnEdge:=oe_Right;
          end;

        if ScrDiff and os_Top <> 0 then
         if PV1.OffScreen and os_Top = 0 then
          begin
           ComingFrom((ViewRectTop-PrevV1.y) / (PV1.y-PrevV1.y), bbY, ViewRectTop);
           PrevV1.OnEdge:=oe_Top;
          end
         else
          begin
           GoingInto((ViewRectTop-PV1.y) / (PrevV1.y-PV1.y), bbY, ViewRectTop);
           PV1.OnEdge:=oe_Top;
          end;
        if ScrDiff and os_Bottom <> 0 then
         if PV1.OffScreen and os_Bottom = 0 then
          begin
           ComingFrom((ViewRectBottom-PrevV1.y) / (PV1.y-PrevV1.y), bbY, ViewRectBottom);
           PrevV1.OnEdge:=oe_Bottom;
          end
         else
          begin
           GoingInto((ViewRectBottom-PV1.y) / (PrevV1.y-PV1.y), bbY, ViewRectBottom);
           PV1.OnEdge:=oe_Bottom;
          end;

        if PrevV1.OffScreen or PV1.OffScreen = 0 then
         begin  { the resulting line is on-screen }
          if PrevChanged then
           begin
            if (LastEdge<>0) and (PrevV1.OnEdge<>0) then
             AddCorners(PrevV1.OnEdge);
            if N=0 then SourceEdge:=PrevV1.OnEdge;
            Output(PrevV1);
           end;
          Output(PV1);
          LastEdge:=PV1.OnEdge;
         end;

        PrevV1:=NewV1;
       end;
    end;
   if (LastEdge<>0) and (SourceEdge<>0) then
    AddCorners(SourceEdge);

   if (N=0) and (ScrTotal and (os_Top or os_Bottom or os_Left or os_Right)
                            = (os_Top or os_Bottom or os_Left or os_Right)) then
    begin  { maybe we are in the case of a big, full-screen polygon }
     aa:=(ViewRectLeft+ViewRectRight)*0.5;
     bb:=(ViewRectTop+ViewRectBottom)*0.5;
     PV:=BaseMaxV;
     SourceV:=BaseV;
     LoadedTarget:=Nil;
     FindVertexState:=0;
     FindVertex;
     repeat
      PrevV1:=PV1;
      if not FindVertex then
       begin  { we are in this case }
        LastEdge:=oe_Left;
        AddCorners(oe_Right);
        AddCorners(oe_Left);
        Break;
       end;
     until (PV1.y-PrevV1.y)*(aa-PrevV1.x)>(PV1.x-PrevV1.x)*(bb-PrevV1.y);
    end;
   if N>=3 then
    Windows.Polygon(g_DrawInfo.DC, VList, N);
  end;
end;

 {------------------------}

(*function GetCoordinates(const Up: TVect; const Scale: TDouble) : T2DCoordinates;
var
 R: TDouble;
begin
 if Abs(Up.Z)>1-rien then
  begin
   if Up.Z>0 then
    Result:=TXYCoordinates.Create
   else
    Result:=TXY2Coordinates.Create;
   with TStdCoordinates(Result) do
    begin
     pProjX:=Scale;
     pProjY:=0;
     pProjZ:=Scale;
     InitProjVar;
    end;
  end
 else
  if Abs(Up.Z)<rien then
   begin
    Result:=TXZCoordinates.Create;
    with TStdCoordinates(Result) do
     begin
      pProjX:=-Scale*Up.Y;
      pProjY:=Scale*Up.X;
      pProjZ:=Scale;
      InitProjVar;
     end;
   end
  else
   begin
    Result:=TAACoordinates.Create;
    with TAACoordinates(Result) do
     begin
      R:=Sqrt(Sqr(Up.X)+Sqr(Up.Y));
      SinAngle:=-Up.X/R;
      CosAngle:=-Up.Y/R;
      SinAngleV:=-Scale*Up.Z;
      CosAngleV:=Scale*R;
      pProjZ:=Scale;
      InitProjVar;
     end;
   end;
end;

function GetTopDownAngle(const Angle, Scale: TDouble; BottomUp: Boolean) : TXYCoordinates;
begin
 if BottomUp then
  Result:=TXY2Coordinates.Create
 else
  Result:=TXYCoordinates.Create;
 with Result do
  begin
   pProjX:=Scale*Cos(Angle);
   pProjY:=-Scale*Sin(Angle);
   pProjZ:=Scale;
   InitProjVar;
  end;
end;

function GetAngleCoord(const Angle, VAngle, Scale: TDouble) : T2DCoordinates;
var
 R: TDouble;
 Up: TVect;
begin
 Up.Z:=Sin(VAngle);
 if Abs(Up.Z)>1-rien then
  Result:=GetTopDownAngle(Angle, Scale, Up.Z<0)
 else
  begin
   R:=-Cos(VAngle);
   Up.X:=Sin(Angle)*R;
   Up.Y:=Cos(Angle)*R;
   Result:=GetCoordinates(Up, Scale);
  end;
end;*)

function GetMatrixCoordinates(const mx: TMatrixTransformation) : T2DCoordinates;
begin
 if (Abs(mx[1,2])<rien) and (Abs(mx[1,3])<rien)
 and (Abs(mx[2,1])<rien) and (Abs(mx[3,1])<rien) then
  if (Abs(mx[2,3])<rien) and (Abs(mx[3,2])<rien) then
   Result:=TXYCoordinates.Create
  else
   if (Abs(mx[2,2])<rien) and (Abs(mx[3,3])<rien) then
    Result:=TXZCoordinates.Create
   else
    Result:=T2DCoordinates.Create
 else
  Result:=T2DCoordinates.Create;
 Result.mx:=mx;
 Result.mxinv:=MatriceInverse(mx);
 Result.pProjZ:=Exp(Ln(Determinant(mx))*(1/3));
 Result.InitProjVar;
end;

 {------------------------}

procedure TCoordinates.SetAsCCoord(nDC: HDC);
begin
 g_DrawInfo.DC:=nDC;
 CCoord:=Self;
 g_DrawInfo.ModeAff:=0;
 g_DrawInfo.BlackBrush:=GetStockObject(g_DrawInfo.BasePen);
 g_DrawInfo.SelectedBrush:=0;
 SetROP2(g_DrawInfo.DC, R2_CopyPen);
end;

function TCoordinates.ScalingFactor(const Pt: PVect) : TDouble;
begin
 ScalingFactor:=1.0;
end;

(*function TCoordinates.VecteurNormalDe(const Centre, Normale: TVect) : TVect;
var
 Dist1: TDouble;
begin
 Dist1:=LongueurVectNormal/ScalingFactor;
 Result.X:=Centre.X + Normale.X*Dist1;
 Result.Y:=Centre.Y + Normale.Y*Dist1;
 Result.Z:=Centre.Z + Normale.Z*Dist1;
end;*)

function TCoordinates.Orthogonal : Boolean;
begin
 Orthogonal:=False;
end;

procedure TCoordinates.Resize(nWidth, nHeight: Integer);
begin
 ScrCenter.X:=nWidth div 2;
 ScrCenter.Y:=nHeight div 2;
end;

function TCoordinates.CheckVisible(var P: TPointProj) : Boolean;
var
 Scr: Byte;
begin
 Scr:=0;
 if P.X < 0 then Inc(Scr, os_Left);
 if P.X >= (ScrCenter.X * 2) + 1 then Inc(Scr, os_Right); //Compensate for rounding
 if P.Y < 0 then Inc(Scr, os_Top);
 if P.Y >= (ScrCenter.Y * 2) + 1 then Inc(Scr, os_Bottom); //Compensate for rounding
 if (P.oow < MinDistance) or (P.oow >= MaxDistance) then
  if NearerThan(P.oow, MinDistance) then
   Inc(Scr, os_Back)
  else
   Inc(Scr, os_Far);
 P.OffScreen:=Scr;
 Result:=Scr and HiddenRegions = 0;
end;

procedure TCoordinates.Rectangle3D(const V1, V2, V3: TVect; Fill: Boolean);
const
 MiniFacteur = 1-0.13;
var
 V: array[0..3] of TVect;
 W, Normale: TVect;
 Pts: array[0..3] of TPointProj;
{Facteur: TDouble;
 Trait: TPoint;}
 R: Integer;
begin
 V[2].X:=V2.X-V1.X;
 V[2].Y:=V2.Y-V1.Y;
 V[2].Z:=V2.Z-V1.Z;
 W.X:=V3.X-V1.X;
 W.Y:=V3.Y-V1.Y;
 W.Z:=V3.Z-V1.Z;
 Normale:=Cross(V[2],W);
 if not PositiveHalf(Normale.X, Normale.Y, Normale.Z, Dot(Normale, V1)) then
  begin
   V[0]:=V1;
   V[1]:=V2;
   V[2].X:=V2.X+W.X;
   V[2].Y:=V2.Y+W.Y;
   V[2].Z:=V2.Z+W.Z;
   V[3]:=V3;
   for R:=0 to 3 do
    Pts[R]:=Proj(V[R]);
   if Fill then
    Polygon95(Pts, 4, False)
   else
    begin
     for R:=0 to 3 do
      begin
       with V[(R-1) and 3] do
        begin
         W.X:=X + (V[R].X-X)*MiniFacteur;
         W.Y:=Y + (V[R].Y-Y)*MiniFacteur;
         W.Z:=Z + (V[R].Z-Z)*MiniFacteur;
        end;
       Line95(Proj(W), Pts[R]);
       with V[(R+1) and 3] do
        begin
         W.X:=X + (V[R].X-X)*MiniFacteur;
         W.Y:=Y + (V[R].Y-Y)*MiniFacteur;
         W.Z:=Z + (V[R].Z-Z)*MiniFacteur;
        end;
       Line95(Pts[R], Proj(W));
      end;
   (*for R:=0 to 3 do
      if not PointVisible95(Pts[R]) then Exit;
     MoveToEx(g_DrawInfo.DC, Pts[0].X, Pts[0].Y, Nil);
     for R:=0 to 3 do
      with Pts[Succ(R) and 3] do
       begin
        Facteur:=Sqr(X-Pts[R].X)+Sqr(Y-Pts[R].Y);
        if Facteur<rien2 then Exit;
        Facteur:=3.5/Sqrt(Facteur);
        Trait.X:=Round(Facteur*(X-Pts[R].X));
        Trait.Y:=Round(Facteur*(Y-Pts[R].Y));
        LineTo(g_DrawInfo.DC, Pts[R].X + Trait.X, Pts[R].Y + Trait.Y);
        MoveToEx(g_DrawInfo.DC, X - Trait.X, Y - Trait.Y, Nil);
        LineTo(g_DrawInfo.DC, X,Y);
       end;*)
    end;
  end;
end;

procedure TCoordinates.Polyline95(var Pts; NbPts: Integer);
var
 Pt: ^TPointProj;
 I: Integer;
begin
 Pt:=@Pts;
 for I:=1 to NbPts do
  begin
   CheckVisible(Pt^);
   Inc(Pt);
  end;
 Polyline95f(Pts, NbPts);
end;

procedure TCoordinates.Polyline95f(const Pts; NbPts: Integer);
var
 I: Integer;
 Pt: PPointProj;
 Dest, PtBuffer: PPoint;
 P1, P2, P3: TPointProj;
 OffScr: Boolean;
begin
 OffScr:=False;
 Pt:=@Pts;
 if NbPts = 3 then
  begin
   for I:=3 to NbPts do
    begin
     OffScr:=OffScr or (Pt^.OffScreen <> 0);
     Inc(Pt);
    end;
   Pt:=@Pts;
   if (not OffScr) or (OffScr) then
    begin
     for I:=3 to NbPts do
      begin
       P1:=Pt^;
       Inc(Pt);
       P2:=Pt^;
       Inc(Pt);
       P3:=Pt^;
       if Ligne95(P1, P2, not FlatDisplay) then
        begin
         Windows.MoveToEx(g_DrawInfo.DC, Round(P1.x), Round(P1.y), Nil);
         Windows.LineTo(g_DrawInfo.DC, Round(P2.x), Round(P2.y));
         Windows.MoveToEx(g_DrawInfo.DC, Round(P2.x), Round(P2.y), Nil);
         Windows.LineTo(g_DrawInfo.DC, Round(P3.x), Round(P3.y));
         Windows.MoveToEx(g_DrawInfo.DC, Round(P3.x), Round(P3.y), Nil);
         Windows.LineTo(g_DrawInfo.DC, Round(P1.x), Round(P1.y));
        end;
      end;
    end
   else
    begin
     GetMem(PtBuffer, NbPts*SizeOf(TPoint)); try
     Dest:=PtBuffer;
     for I:=1 to NbPts do
      begin
       with Pt^ do
        begin
         Dest^.X:=Round(x);
         Dest^.Y:=Round(y);
        end;
       Inc(Pt);
       Inc(Dest);
      end;
     Windows.Polyline(g_DrawInfo.DC, PtBuffer^, NbPts);
     finally FreeMem(PtBuffer); end;
    end;
   end
 else
  begin
   for I:=1 to NbPts do
    begin
    // CheckVisible(Pt^);
     OffScr:=OffScr or (Pt^.OffScreen <> 0);
     Inc(Pt);
    end;
   Pt:=@Pts;
   if OffScr then
    begin
     for I:=2 to NbPts do
      begin
       P1:=Pt^;
       Inc(Pt);
       P2:=Pt^;
       if Ligne95(P1, P2, not FlatDisplay) then
        begin
         Windows.MoveToEx(g_DrawInfo.DC, Round(P1.x), Round(P1.y), Nil);
         Windows.LineTo(g_DrawInfo.DC, Round(P2.x), Round(P2.y));
        end;
      end;
    end
   else
    begin
     GetMem(PtBuffer, NbPts*SizeOf(TPoint)); try
     Dest:=PtBuffer;
     for I:=1 to NbPts do
      begin
       with Pt^ do
        begin
         Dest^.X:=Round(x);
         Dest^.Y:=Round(y);
        end;
       Inc(Pt);
       Inc(Dest);
      end;
     Windows.Polyline(g_DrawInfo.DC, PtBuffer^, NbPts);
     finally FreeMem(PtBuffer); end;
    end;
  end;
end;

procedure TCoordinates.InitProjVar;
begin
end;

 {------------------------}

function T2DCoordinates.ScalingFactor(const Pt: PVect) : TDouble;
begin
 ScalingFactor:=pProjZ;
end;

function T2DCoordinates.NearerThan(const oow1, oow2: Single) : Boolean;
begin
 Result:=oow1<oow2;
end;

procedure T2DCoordinates.InitProjVar;
begin
 inherited;
{Facteur:=1/Sqr(pProjZ);}
 FastDisplay:=CheckWindowsNT or (pProjZ<=2); //FIXME: Why pProjZ here?
 FlatDisplay:=True;
 HiddenRegions:=os_Left or os_Right or os_Top or os_Bottom;
end;

function T2DCoordinates.Proj(const V: TVect) : TPointProj;
begin
 Result.X  :=mx[1,1]*V.X + mx[1,2]*V.Y + mx[1,3]*V.Z + pDeltaX;
 Result.Y  :=mx[2,1]*V.X + mx[2,2]*V.Y + mx[2,3]*V.Z + pDeltaY;
 Result.oow:=mx[3,1]*V.X + mx[3,2]*V.Y + mx[3,3]*V.Z;
end;

function T2DCoordinates.VectorX;
begin
 Result.X:=mxinv[1,1];
 Result.Y:=mxinv[2,1];
 Result.Z:=mxinv[3,1];
end;

function T2DCoordinates.VectorY;
begin
 Result.X:=mxinv[1,2];
 Result.Y:=mxinv[2,2];
 Result.Z:=mxinv[3,2];
end;

function T2DCoordinates.VectorZ;
begin
 Result.X:=mxinv[1,3];
 Result.Y:=mxinv[2,3];
 Result.Z:=mxinv[3,3];
end;

function T2DCoordinates.VectorEye(const Pt: TVect) : TVect;
begin
 Result.X:=-mxinv[1,3]+Pt.X;
 Result.Y:=-mxinv[2,3]+Pt.Y;
 Result.Z:=-mxinv[3,3]+Pt.Z;
end;

function T2DCoordinates.PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean;
begin
 Result:=(mx[3,1]*NormaleX + mx[3,2]*NormaleY + mx[3,3]*NormaleZ)<0;
end;

function T2DCoordinates.Espace(const P: TPointProj) : TVect;
var
 X, Y: TDouble;
begin
 X:=P.X-pDeltaX;
 Y:=P.Y-pDeltaY;
 Result.X:=mxinv[1,1]*X + mxinv[1,2]*Y + mxinv[1,3]*P.oow;
 Result.Y:=mxinv[2,1]*X + mxinv[2,2]*Y + mxinv[2,3]*P.oow;
 Result.Z:=mxinv[3,1]*X + mxinv[3,2]*Y + mxinv[3,3]*P.oow;
end;

 {------------------------}

(* XY Coordinates matrix :
    *  0  0
    0  *  0
    0  0  *      *)

function TXYCoordinates.Espace(const P: TPointProj) : TVect;
begin
 Result.X:=mxinv[1,1]*(P.X-pDeltaX);
 Result.Y:=mxinv[2,2]*(P.Y-pDeltaY);
 Result.Z:=mxinv[3,3]*P.oow;
{$IFDEF DebugCoord}
 with inherited Espace(P) do
  if (Abs(X-Result.X)>rien)
  or (Abs(Y-Result.Y)>rien)
  or (Abs(Z-Result.Z)>rien) then
   Raise InternalE('XYEspace');
{$ENDIF}
end;

function TXYCoordinates.Proj(const V: TVect) : TPointProj;
begin
 Result.X  := mx[1,1] * V.X + pDeltaX;
 Result.Y  := mx[2,2] * V.Y + pDeltaY;
 Result.oow:= mx[3,3] * V.Z;
{$IFDEF DebugCoord}
 with inherited Proj(V) do
  if (Abs(X-Result.X)>rien)
  or (Abs(Y-Result.Y)>rien)
  or (Abs(oow-Result.oow)>rien) then
   Raise InternalE('XYProj');
{$ENDIF}
end;

 {------------------------}

(* XZ Coordinates matrix :
    *  0  0
    0  0  *
    0  *  0      *)

function TXZCoordinates.Espace(const P: TPointProj) : TVect;
begin
 Result.X:=mxinv[1,1]*(P.X-pDeltaX);
 Result.Y:=mxinv[2,3]*P.oow;
 Result.Z:=mxinv[3,2]*(P.Y-pDeltaY);
{$IFDEF DebugCoord}
 with inherited Espace(P) do
  if (Abs(X-Result.X)>rien)
  or (Abs(Y-Result.Y)>rien)
  or (Abs(Z-Result.Z)>rien) then
   Raise InternalE('XZEspace');
{$ENDIF}
end;

function TXZCoordinates.Proj(const V: TVect) : TPointProj;
begin
 Result.X  := mx[1,1] * V.X + pDeltaX;
 Result.Y  := mx[2,3] * V.Z + pDeltaY;
 Result.oow:= mx[3,2] * V.Y;
{$IFDEF DebugCoord}
 with inherited Proj(V) do
  if (Abs(X-Result.X)>rien)
  or (Abs(Y-Result.Y)>rien)
  or (Abs(oow-Result.oow)>rien) then
   Raise InternalE('XZProj');
{$ENDIF}
end;

 {------------------------}

(*procedure TStdCoordinates.InitProjVar;
begin
 inherited;
 if Abs(pProjY) < rien then
  if pProjX > 0 then
   Vue:=v_XY
  else
   Vue:=v_mXmY
 else
  if Abs(pProjX) < rien then
   if pProjY < 0 then
    Vue:=v_YmX
   else
    Vue:=v_mYX
  else
   Vue:=v_Autre;
end;

function TStdCoordinates.Orthogonal : Boolean;
begin
 Orthogonal:=Vue<>v_Autre;
end;

 {------------------------}

function TXYCoordinates.Proj(const V: TVect) : TPointProj;
begin
 case Vue of
  v_XY:    begin
            Result.X:=(V.X*pProjZ)+pDeltaX;
            Result.Y:=pDeltaY-(V.Y*pProjZ);
           end;
  v_YmX:   begin
            Result.X:=pDeltaX-(V.Y*pProjZ);
            Result.Y:=pDeltaY-(V.X*pProjZ);
           end;
  v_mXmY:  begin
            Result.X:=pDeltaX-(V.X*pProjZ);
            Result.Y:=pDeltaY+(V.Y*pProjZ);
           end;
  v_mYX:   begin
            Result.X:=(V.Y*pProjZ)+pDeltaX;
            Result.Y:=pDeltaY+(V.X*pProjZ);
           end;
  else     begin
            Result.X:=(V.X*pProjX+V.Y*pProjY)+pDeltaX;
            Result.Y:=pDeltaY-(V.Y*pProjX-V.X*pProjY);
           end;
 end;
 Result.oow:=-V.Z*pProjZ;
end;

function TXYCoordinates.VectorX;
begin
 Result.X:=pProjX;
 Result.Y:=pProjY;
 Result.Z:=0;
end;

function TXYCoordinates.VectorY;
begin
 Result.X:=pProjY;
 Result.Y:=-pProjX;
 Result.Z:=0;
end;

function TXYCoordinates.VectorEye;
begin
 Result.X:=0;
 Result.Y:=0;
 Result.Z:={-}pProjZ;
end;

function TXYCoordinates.PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean;
begin
 Result:=NormaleZ>0;
end;

function TXYCoordinates.Espace(const P: TPointProj) : TVect;
var
 X, Y: TDouble;
begin
 X:=P.X-pDeltaX;
 Y:=pDeltaY-P.Y;
 Espace.X:=(X*pProjX - Y*pProjY) * Facteur;
 Espace.Y:=(Y*pProjX + X*pProjY) * Facteur;
 Espace.Z:=-P.oow/pProjZ;
end;

 {------------------------}

function TXY2Coordinates.Espace(const P: TPointProj) : TVect;
var
 P1: TPointProj;
begin
 P1.X:=P.X;
 P1.Y:=-P.Y;
 P1.oow:=-P.oow;
 Result:=inherited Espace(P1);
end;

function TXY2Coordinates.Proj(const V: TVect) : TPointProj;
begin
 Result:=inherited Proj(V);
 Result.Y:=-Result.Y;
 Result.oow:=-Result.oow;
end;

function TXY2Coordinates.VectorX;
begin
 Result.X:=pProjX;
 Result.Y:=pProjY;
 Result.Z:=0;
end;

function TXY2Coordinates.VectorY;
begin
 Result.X:=-pProjY;
 Result.Y:=pProjX;
 Result.Z:=0;
end;

function TXY2Coordinates.VectorEye;
begin
 Result.X:=0;
 Result.Y:=0;
 Result.Z:= - pProjZ;
end;

function TXY2Coordinates.PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean;
begin
 Result:=NormaleZ<0;
end;

 {------------------------}

function TXZCoordinates.Proj;
begin
 case Vue of
  v_XY:    begin
            Result.X:=(V.X*pProjZ)+pDeltaX;
            Result.oow:=V.Y*pProjZ;
           end;
  v_YmX:   begin
            Result.X:=pDeltaX-(V.Y*pProjZ);
            Result.oow:=V.X*pProjZ;
           end;
  v_mXmY:  begin
            Result.X:=pDeltaX-(V.X*pProjZ);
            Result.oow:=-V.Y*pProjZ;
           end;
  v_mYX:   begin
            Result.X:=(V.Y*pProjZ)+pDeltaX;
            Result.oow:=-V.X*pProjZ;
           end;
  else     begin
            Result.X:=(V.X*pProjX+V.Y*pProjY)+pDeltaX;
            Result.oow:=V.Y*pProjX-V.X*pProjY;
           end;
 end;
 Result.Y:=pDeltaY-(V.Z*pProjZ);
end;

function TXZCoordinates.Espace(const P: TPointProj) : TVect;
var
 X: TDouble;
begin
 X:=P.X-pDeltaX;
 Espace.X:=(  X  *pProjX - P.oow*pProjY) * Facteur;
 Espace.Y:=(P.oow*pProjX +   X  *pProjY) * Facteur;
 Espace.Z:=(pDeltaY-P.Y) / pProjZ;
end;

function TXZCoordinates.VectorX;
begin
 Result.X:=pProjX;
 Result.Y:=pProjY;
 Result.Z:=0;
end;

function TXZCoordinates.VectorY;
begin
 Result.X:=0;
 Result.Y:=0;
 Result.Z:=-1;
end;

function TXZCoordinates.VectorEye;
begin
 Result.X:=pProjY;
 Result.Y:=-pProjX;
 Result.Z:=0;
end;

function TXZCoordinates.PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean;
begin
 Result:=NormaleX*pProjY - NormaleY*pProjX > 0;
end;

 {------------------------}

function TAACoordinates.Espace(const P: TPointProj) : TVect;
var
 V1, X, Y: TDouble;
begin
 X:=(P.X - pDeltaX) * pProjZ;
 Y:=pDeltaY - P.Y;
 V1:=P.oow*CosAngleV - Y*SinAngleV; {= (V.X*SinAngle + V.Y*CosAngle)*pProjZ*pProjZ }
 Result.X:=(V1*SinAngle +  X  *CosAngle) * Facteur;
 Result.Y:=(V1*CosAngle -  X  *SinAngle) * Facteur;
 Result.Z:=(Y *CosAngleV+P.oow*SinAngleV)* Facteur;
end;

function TAACoordinates.Proj(const V: TVect) : TPointProj;
var
 V1: TDouble;
begin
 V1:=V.X*SinAngle+V.Y*CosAngle;
 Result.X:=(pProjZ*(V.X*CosAngle - V.Y*SinAngle)) + pDeltaX;
 Result.Y:=pDeltaY - (V.Z*CosAngleV-V1*SinAngleV);
 Result.oow:=V.Z*SinAngleV+V1*CosAngleV;
end;

function TAACoordinates.VectorX;
begin
 Result.X:=CosAngle;
 Result.Y:=-SinAngle;
 Result.Z:=0;
end;

function TAACoordinates.VectorY;
begin
 Result.X:=-SinAngleV*SinAngle;
 Result.Y:=-SinAngleV*CosAngle;
 Result.Z:=CosAngleV;
end;

function TAACoordinates.VectorEye;
begin
 Result.X:=SinAngle*CosAngleV;
 Result.Y:=CosAngle*CosAngleV;
 Result.Z:=SinAngleV;
end;

function TAACoordinates.PositiveHalf(const NormaleX, NormaleY, NormaleZ, Dist: TDouble) : Boolean;
begin
 Result:=NormaleX*SinAngle*CosAngleV*pProjY + NormaleY*CosAngle*CosAngleV + NormaleZ*SinAngleV > 0;
end;

(*function TAACoordinates.Orthogonal : Boolean;
begin
 Orthogonal:=(Abs(SinAngleV*CosAngleV)<rien) and (Abs(SinAngle*CosAngle)<rien);
end;*)































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

function T3DCoordinates.VectorZ;
begin
 Result:=Look;
end;

function T3DCoordinates.VectorEye(const Pt: TVect) : TVect;
begin
 Result.X:=-Eye.X+Pt.X;
 Result.Y:=-Eye.Y+Pt.Y;
 Result.Z:=-Eye.Z+Pt.Z;
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

function T3DCoordinates.ScalingFactor(const Pt: PVect) : TDouble;
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
 FarDistance: TDouble;
 nRFactor: TDouble;
begin
 FarDistance:=SetupSubSet(ssGeneral, '3D view').GetFloatSpec('FarDistance', 1500);
 nRFactor:=RFactorDistance/FarDistance;
 CameraVectors(HorzAngle, PitchAngle, nRFactor, Look, Right, Down);
 ooWFactor:=FarDistance*(1/MaxW);
 if nRFactor = 0 then
  SpaceFactor:=0
 else
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
