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
unit qmath;

interface

uses Windows, SysUtils, Graphics;

type
 TInteger = Integer;
 TDouble = Double;
 PVect = ^TVect;
 TVect = record
          X, Y, Z: TDouble;
         end;
 scalar_t = Single;
 vec2_p = ^vec2_t;
 vec2_t = packed array[0..1] of scalar_t;

 vec3_p = ^vec3_t;
 vec3_t = packed array[0..2] of scalar_t;

 vec5_p = ^vec5_t;
 vec5_t = packed array[0..4] of scalar_t;
 vec_st_p = ^vec_st_t;
 vec_st_t = record
             s,t: TDouble;
            end; 
 TVect4 = record
           X, Y, Z, D: TDouble;
          end;
 TVect5 = record
           X, Y, Z, S, T: TDouble;
          end;
 TVect7 = record
           X1, X2, X3, X4, X5, X6, X7: TDouble;
          end;
 TVect10 = record
           X1, X2, X3, X4, X5, X6, X7, X8, X9, X10: TDouble;
          end;

function VecLength(const V1: TVect): TDouble;
function Cross(const V1, V2: TVect) : TVect;
function Dot(const V1, V2: TVect) : TDouble;
procedure Normalise(var V: TVect); overload;
procedure Normalise(var V: TVect; var S: Double); overload;
function AngleXY(const X, Y: TDouble) : TDouble;
procedure ReadDoubleArray(const S1: String; var Vals: array of TDouble);
function ReadVector(const S: String) : TVect;
function ReadNumValueEx(const S: String) : TDouble;
function itos(const I: TInteger) : String;
function ftos(const F: TDouble) : String;
function ftos0(const F: TDouble) : String;
function ftos1(const F: TDouble) : String;
function ftosp(const F: TDouble; const P: integer) : String;
{function dtos(const D: TDouble) : String;}
function dtosp(const D: TDouble; const P: integer) : String;
function vtos(const V: TVect) : String;
function vtos1(const V: TVect) : String;
function CalculeMAngle(const Angles: TVect) : TVect;
function coltov(C: TColor) : TVect;
function coltos255(C: TColor) : String;
function vtocol(const V: TVect) : TColor;
function vtocol255(const R,G,B: TDouble) : TColor;
procedure NormaliseCol1(var V: TVect);
{function sReadIntegers(const S1: String; Int: PLongInt; MaxCount: Integer) : Integer;
function sWriteIntegers(Int: PLongInt; Count: Integer) : String;}
function MakeVect(const X, Y, Z : Double) : TVect; overload;
function MakeVect(const V: vec3_t) : TVect; overload;
function MakeVect5(const V: vec5_t) : TVect5;
function VecEqual(const V1, V2 : TVect) : Boolean;
function VecDiff(const V, W : TVect) : TVect;
function VecSum(const V, W : TVect) : TVect;
function VecScale(const R: Double; const V: TVect) : TVect;
function Vec3Add(const V, W: vec3_t) : vec3_t;
function Vec3Diff(const V, W : vec3_t) : vec3_t;
function ProjectPointToPlane(const Point, Along, PlanePoint, PlaneNorm : TVect) : TVect;
function SolveForThreePoints(const V1, V2, V3: TVect5; var P1, P2, P3:TVect) : Boolean;

procedure TranslateVecs(const vec: vec3_t; var vec_out: vec3_p; count: Integer);
procedure ScaleVecs(var vec_out: vec3_p; count: Integer; scale: double);

const
 {Origine}OriginVectorZero: TVect = (X:0; Y:0; Z:0);
 rien = 1E-5;
 rien2 = 3E-3;
 Deg2Rad = Pi/180;
 Rad2Deg = 180/Pi;

type
 TModeProj = (VueXY, VueXZ, Vue3D);
 TProjEventEx = function (const P: TVect; var Pt: TPoint) : Boolean of object;
 TProfondeurEventEx = function (const P: TVect) : TDouble of object;

var
 g_pProjZ: TDouble;
 g_ModeProj: TModeProj;

function Proj(const P: TVect) : TPoint;
function ProjEx(const P: TVect; var Dest: TPoint) : Boolean;
function Espace(X,Y,Z: Integer) : TVect;
function Profondeur(const V: TVect) : TDouble;
procedure InitProjVar;

function TailleMaximaleEcranX: Integer;
function TailleMaximaleEcranY: Integer;

implementation

uses QkExceptions;

var
 pDeltaX, pDeltaY, pDeltaZ: Integer;
 pProjX, pProjY: TDouble;
 CalculeProj3D: TProjEventEx;
 CalculeProfondeur3D: TProfondeurEventEx;
var
 Facteur: TDouble;

function VecLength(const V1: TVect) : TDouble;
begin
  Result:=Sqrt(Dot(V1, V1));
end;

function Cross(const V1, V2: TVect) : TVect;
begin
 Cross.X := v1.Y*v2.Z - v1.Z*v2.Y;
 Cross.Y := v1.Z*v2.X - v1.X*v2.Z;
 Cross.Z := v1.X*v2.Y - v1.Y*v2.X;
end;

function Dot(const V1, V2: TVect) : TDouble;
begin
 Dot:=V1.X*V2.X + V1.Y*V2.Y + V1.Z*V2.Z;
end;

procedure Normalise(var V: TVect);
var
 F,S: TDouble;
begin
 S:=Sqrt(Sqr(V.X)+Sqr(V.Y)+Sqr(V.Z));
 if (S = 0) then
   exit;
 F:=1/S;
 V.X:=V.X*F;
 V.Y:=V.Y*F;
 V.Z:=V.Z*F;
end;

procedure Normalise(var V: TVect; var S: Double);
var
 F : TDouble;
begin
 S:=Sqrt(Sqr(V.X)+Sqr(V.Y)+Sqr(V.Z));
 if (S = 0) then
   exit;
 F:=1/S;
 V.X:=V.X*F;
 V.Y:=V.Y*F;
 V.Z:=V.Z*F;
end;

function Proj;
begin
 case g_ModeProj of
  VueXY: begin
          Proj.X:=Round(P.X*pProjX+P.Y*pProjY)+pDeltaX;
          Proj.Y:=pDeltaY-Round(P.Y*pProjX-P.X*pProjY);
         end;
  VueXZ: begin
          Proj.X:=Round(P.X*pProjX+P.Y*pProjY)+pDeltaX;
          Proj.Y:=pDeltaZ-Round(P.Z*g_pProjZ);
         end;
  else   if not CalculeProj3D(P, Result) then
          Raise EErrorFmt(167, [vtos(P)]);
 end;
end;

function ProjEx(const P: TVect; var Dest: TPoint) : Boolean;
begin
 if g_ModeProj=Vue3D then
  Result:=CalculeProj3D(P, Dest)
 else
  begin
   Dest:=Proj(P);
   ProjEx:=True;
  end;
end;

function Espace;
begin
 Dec(X, pDeltaX);
 Y:=pDeltaY-Y;
 Espace.X:=(X*pProjX - Y*pProjY) * Facteur;
 Espace.Y:=(Y*pProjX + X*pProjY) * Facteur;
 Espace.Z:=(pDeltaZ-Z) / g_pProjZ;
end;

procedure InitProjVar;
begin
 Facteur:=1/(Sqr(pProjX)+Sqr(pProjY));
end;

function Profondeur(const V: TVect) : TDouble;
begin
 case g_ModeProj of
  VueXY: Profondeur:=-V.Z;
  VueXZ: Profondeur:=V.Y*pProjX-V.X*pProjY;
  else Profondeur:=CalculeProfondeur3D(V);
 end;
end;

function AngleXY;
begin
 if Abs(X)<rien then
  if Y>0 then
   Result:=pi/2
  else
   Result:=-pi/2
 else
  if X>0 then
   Result:=ArcTan(Y/X)
  else
   Result:=ArcTan(Y/X)+pi;
end;

function itos(const I: TInteger) : String;
begin
 Result:=IntToStr(I);
end;

function ftos(const F: TDouble) : String;
const
 maxDigits = 2;
var
 i: Integer;
 FP: TDouble;
begin
 if Abs(F) < High(Integer) - 2 then //Safety margin
 begin
   i:=0; FP:=F;
   //how many digits are necessary? (stop at maxDigits)
   while (i<>maxDigits) and (Abs(FP-Round(FP))>rien) do begin FP:=FP*10; inc(i); end;
   if i=0 then
   begin
     Result:=IntToStr(Round(F));
     Exit;
   end;
 end
 else
  i:=maxDigits;
 Result:=FloatToStrF(F, ffFixed, 7, i);
end;

function ftos0(const F: TDouble) : String;
var
 R: Integer;
begin
 if Abs(F) < High(R) - 2 then //Safety margin
 begin
   R:=Round(F);
   if Abs(F-R) <= rien then
   begin
     Result:=IntToStr(R)+'.0';
     Exit;
   end;
 end;
 {DecimalSeparator:='.';}
 Result:=FloatToStrF(F, ffFixed, 7, 5);
end;

function ftos1(const F: TDouble) : String;
var
 R: Integer;
begin
 if Abs(F) < High(R) - 2 then //Safety margin
 begin
   R:=Round(F);
   if Abs(F-R) <= rien then
   begin
     Result:=IntToStr(R);
     Exit;
   end;
 end;
 {DecimalSeparator:='.';}
 Result:=FloatToStrF(F, ffFixed, 7, 5);
end;

function ftosp(const F: TDouble; const P: integer) : String;
var
 R: Integer;
begin
 if Abs(F) < High(R) - 2 then //Safety margin
 begin
   R:=Round(F);
   if Abs(F-R) <= rien then
   begin
     Result:=IntToStr(R);
     Exit;
   end;
 end;
 {DecimalSeparator:='.';}
 Result:=FloatToStrF(F, ffFixed, 7, P);
end;

{function dtos(const D: TDouble) : String;
const
 maxDigits = 2;
var
 i: Integer;
 DP: TDouble;
begin
 if Abs(D) < High(Integer) - 2 then //Safety margin
 begin
   i:=0; DP:=D;
   //how many digits are necessary? (stop at maxDigits)
   while (i<>maxDigits) and (Abs(DP-Round(DP))>rien) do begin DP:=DP*10; inc(i); end;
   if i=0 then
   begin
     Result:=IntToStr(Round(D));
     Exit;
   end;
 end
 else
  i:=maxDigits;
 Result:=FloatToStrF(D, ffFixed, 15, i);
end;}

function dtosp(const D: TDouble; const P: integer) : String;
var
 R: Integer;
begin
 if Abs(D) < High(R) - 2 then //Safety margin
 begin
   R:=Round(D);
   if Abs(D-R) <= rien then
   begin
     Result:=IntToStr(R);
     Exit;
   end;
 end;
 {DecimalSeparator:='.';}
 Result:=FloatToStrF(D, ffFixed, 15, P);
end;

procedure ReadDoubleArray(const S1: String; var Vals: array of TDouble);
var
 P, I: Integer;
 S: String;
begin
 S:=S1;
{DecimalSeparator:='.';}
 for I:=Low(Vals) to High(Vals)-1 do
  begin
   S:=Trim(S);
   P:=Pos(' ', S);
   if P=0 then
    Raise EErrorFmt(192, [High(Vals)-Low(Vals)+1, S1]);
   Vals[I]:=StrToFloat(Copy(S, 1, P-1));
   System.Delete(S, 1, P);
  end;
 if Pos(' ', S)<>0 then
   Raise EErrorFmt(192, [High(Vals)-Low(Vals)+1, S1]);
 Vals[High(Vals)]:=StrToFloat(Trim(S));
end;

function ReadVector(const S: String) : TVect;
var
 Lu: array[1..3] of TDouble;
begin
 ReadDoubleArray(S, Lu);
 Result.X:=Lu[1];
 Result.Y:=Lu[2];
 Result.Z:=Lu[3];
end;

function ReadNumValueEx(const S: String) : TDouble;
var
 S1, S2: String;
 P: Integer;
begin
 Result:=1;
 S1:=S;
 repeat
  P:=Pos('*', S1);
  if P=0 then
   S2:=S1
  else
   begin
    S2:=Copy(S1, 1, P-1);
    System.Delete(S1, 1, P);
   end;
  Result:=Result*StrToFloat(Trim(S2));
 until P=0;
end;

function sReadIntegers(const S1: String; Int: PLongInt; MaxCount: Integer) : Integer;
var
 P: Integer;
 S: String;
begin
 S:=Trim(S1);
 Result:=0;
 while (S<>'') and (Result<MaxCount) do
  begin
   P:=Pos(' ', S);
   if P=0 then P:=Length(S)+1;
   Int^:=StrToInt(Copy(S, 1, P-1));
   Inc(Int);
   Inc(Result);
   System.Delete(S, 1, P);
   S:=Trim(S);
  end;
end;

function sWriteIntegers(Int: PLongInt; Count: Integer) : String;
var
 I: Integer;
begin
 Result:='';
 for I:=1 to Count do
  begin
   if I>1 then
    Result:=Result+' ';
   Result:=Result+IntToStr(Int^);
   Inc(Int);
  end;
end;

function CalculeMAngle(const Angles: TVect) : TVect;
var
 A, B: TDouble;
begin
 A:=Angles.Y*Deg2Rad;
 B:=Angles.X*Deg2Rad;
 Result.X:=Cos(A)*Cos(B);
 Result.Y:=Sin(A)*Cos(B);
 Result.Z:=Sin(B);
end;

function TailleMaximaleEcranX: Integer;
begin
 Result:=GetSystemMetrics(sm_CxMaximized)-2*GetSystemMetrics(sm_CxSizeFrame);
end;

function TailleMaximaleEcranY: Integer;
begin
 Result:=GetSystemMetrics(sm_CyMaximized)-2*GetSystemMetrics(sm_CySizeFrame);
end;

(*function LirePositionFenetre(const R: TRect) : String;
var
 XMax, YMax: TDouble;
begin
{DecimalSeparator:='.';}
 XMax:=1/TailleMaximaleEcranX;
 YMax:=1/TailleMaximaleEcranY;
 Result:=FloatToStrF(R.Left  *XMax, ffFixed, 5,3)
   +' '+ FloatToStrF(R.Top   *YMax, ffFixed, 5,3)
   +' '+ FloatToStrF(R.Right *XMax, ffFixed, 5,3)
   +' '+ FloatToStrF(R.Bottom*YMax, ffFixed, 5,3);
end;

function AppliquerPositionFenetre(const S: String) : TRect;
var
 V: array[0..3] of TDouble;
 XMax, YMax: Integer;
begin
 ReadDoubleArray(S, V);
 XMax:=TailleMaximaleEcranX;
 Result.Left:=Round(V[0]*XMax);
 Result.Right:=Round(V[2]*XMax);
 YMax:=TailleMaximaleEcranY;
 Result.Top:=Round(V[1]*YMax);
 Result.Bottom:=Round(V[3]*YMax);
end;*)

 {------------------------------------}

function vtos(const V: TVect) : String;
begin
 Result:=ftos(V.X) + ' ' + ftos(V.Y) + ' ' + ftos(V.Z);
end;

function vtos1(const V: TVect) : String;
begin
 Result:=ftos1(V.X) + ' ' + ftos1(V.Y) + ' ' + ftos1(V.Z);
end;

function coltov(C: TColor) : TVect;
var
 ComposantesSource: array[1..3] of Byte absolute C;
begin
 if ComposantesSource[1]=$FF then Result.X:=1 else Result.X:=ComposantesSource[1]*(1/$100);
 if ComposantesSource[2]=$FF then Result.Y:=1 else Result.Y:=ComposantesSource[2]*(1/$100);
 if ComposantesSource[3]=$FF then Result.Z:=1 else Result.Z:=ComposantesSource[3]*(1/$100);
end;

function coltos255(C: TColor) : String;
var
 ComposantesSource: array[1..3] of Byte absolute C;
begin
 Result:=IntToStr(ComposantesSource[1])
    +' '+IntToStr(ComposantesSource[2])
    +' '+IntToStr(ComposantesSource[3]);
end;

function vtocol(const V: TVect) : TColor;
begin
 Result:=vtocol255(V.X*$100, V.Y*$100, V.Z*$100);
end;

function vtocol255(const R,G,B: TDouble) : TColor;
var
 ComposantesCible: array[1..3] of Byte absolute Result;
 Entier: Integer;
begin
 Result:=0;
 Entier:=Round(R);
 if Entier<0 then Entier:=0 else if Entier>=$100 then Entier:=$FF;
 ComposantesCible[1]:=Entier;
 Entier:=Round(G);
 if Entier<0 then Entier:=0 else if Entier>=$100 then Entier:=$FF;
 ComposantesCible[2]:=Entier;
 Entier:=Round(B);
 if Entier<0 then Entier:=0 else if Entier>=$100 then Entier:=$FF;
 ComposantesCible[3]:=Entier;
end;

procedure NormaliseCol1(var V: TVect);
var
 Max: TDouble;
begin
 if V.X>V.Y then Max:=V.X else Max:=V.Y;
 if V.Z>Max then Max:=V.Z;
 if Max>rien then
  begin
   V.X:=V.X/Max;
   V.Y:=V.Y/Max;
   V.Z:=V.Z/Max;
  end;
end;

function MakeVect(const X, Y, Z : Double) : TVect; overload;
begin
  Result.X:=X;
  Result.Y:=Y;
  Result.Z:=Z;
end;

function MakeVect(const V: vec3_t) : TVect; overload;
begin
  Result.X:=V[0];
  Result.Y:=V[1];
  Result.Z:=V[2];
end;

function MakeVect5(const V: vec5_t) : TVect5;
begin
  Result.X:=V[0];
  Result.Y:=V[1];
  Result.Z:=V[2];
  Result.S:=V[3];
  Result.T:=V[4];
end;

function VecEqual(const V1, V2 : TVect) : Boolean;
begin
  if (V1.X=V2.X) and (V1.Y=V2.Y) and (V1.Z=V2.Z) then
    Result:=true
  else
    Result:=false;
end;

function VecDiff(const V, W : TVect) : TVect;
begin
 Result.X:=V.X-W.X;
 Result.Y:=V.Y-W.Y;
 Result.Z:=V.Z-W.Z;
end;

function VecSum(const V, W : TVect) : TVect;
begin
 Result.X:=V.X+W.X;
 Result.Y:=V.Y+W.Y;
 Result.Z:=V.Z+W.Z;
end;

function VecScale(const R: Double; const V: TVect) : TVect;
begin
 Result.X:=R*V.X;
 Result.Y:=R*V.Y;
 Result.Z:=R*V.Z;
end;

function Vec3Add(const V, W: vec3_t) : vec3_t;
begin
   Result[0]:=V[0]+W[0];
   Result[1]:=V[1]+W[1];
   Result[2]:=V[2]+W[2];
end;

function Vec3Diff(const V, W : vec3_t) : vec3_t;
begin
 Result[0]:=V[0]-W[0];
 Result[1]:=V[1]-W[1];
 Result[2]:=V[2]-W[2];
end;

function ProjectPointToPlane(const Point, Along, PlanePoint, PlaneNorm : TVect) : TVect;
 var Dot1, Dot2 : Double;
begin
  Dot1:=Dot(VecDiff(PlanePoint,Point), PlaneNorm);
  Dot2:=Dot(Along, PlaneNorm);
  Result:=VecSum(Point,VecScale(Dot1/Dot2,Along));
end;

function SolveForThreePoints(const V1, V2, V3: TVect5; var P1, P2, P3:TVect) : Boolean;
var
  Denom : TDouble;
  D1, D2 : TVect;
begin
  //Original Python code from quarkpy.maputils.py
  Denom:= v1.s*v2.t-v1.s*v3.t-v1.t*v2.s+v1.t*v3.s-v3.s*v2.t+v3.t*v2.s;
  if Denom=0 then
  begin
    Result:=False;
    Exit;
  end;
  Denom:=1/Denom;
  P1.X:= -v2.t*v1.x*v3.s+v2.x*v1.t*v3.s-v3.t*v1.s*v2.x+v3.t*v1.x*v2.s+v2.t*v1.s*v3.x-v3.x*v1.t*v2.s;
  P1.Y:= -v2.t*v1.y*v3.s+v2.y*v1.t*v3.s-v3.t*v1.s*v2.y+v3.t*v1.y*v2.s+v2.t*v1.s*v3.y-v3.y*v1.t*v2.s;
  P1.Z:= -(v2.t*v1.z*v3.s-v2.z*v1.t*v3.s+v3.t*v1.s*v2.z-v3.t*v1.z*v2.s-v2.t*v1.s*v3.z+v3.z*v1.t*v2.s);
  P1:=VecScale(Denom,P1);
  D1.X:= -(v2.t*v3.x-v2.t*v1.x+v3.t*v1.x-v3.x*v1.t+v2.x*v1.t-v2.x*v3.t);
  D1.Y:= -(v2.t*v3.y-v2.t*v1.y+v3.t*v1.y-v3.y*v1.t+v2.y*v1.t-v2.y*v3.t);
  D1.Z:= -(v2.t*v3.z-v2.t*v1.z+v3.t*v1.z-v3.z*v1.t+v2.z*v1.t-v2.z*v3.t);
  D1 := VecScale(Denom,D1);
  P2:=VecSum(P1,D1);
  D2.X := -v1.s*v3.x+v1.s*v2.x-v3.s*v2.x+v3.x*v2.s-v1.x*v2.s+v1.x*v3.s;
  D2.Y := -v1.s*v3.y+v1.s*v2.y-v3.s*v2.y+v3.y*v2.s-v1.y*v2.s+v1.y*v3.s;
  D2.Z := -v1.s*v3.z+v1.s*v2.z-v3.s*v2.z+v3.z*v2.s-v1.z*v2.s+v1.z*v3.s;
  D2 := VecScale(Denom,D2);
  P3:=VecSum(P1,D2);
  Result:=True;
end;

 {------------------------}

procedure TranslateVecs(const vec: vec3_t; var vec_out: vec3_p; count: Integer);
var
  p: vec3_p;
  j,k: Integer;
begin
  p:=vec_out;
  for j:=1 to count do
  begin
    for k:=0 to 2 do
      p^[k]:=p^[k] + vec[k]{ + pos[k]};
    inc(p);
  end;
end;

procedure ScaleVecs(var vec_out: vec3_p; count: Integer; scale: double);
var
  p: vec3_p;
  j,k: Integer;
begin
  p:=vec_out;
  for j:=1 to count do
  begin
    for k:=0 to 2 do
      p^[k]:=p^[k] * scale;
    inc(p);
  end;
end;

end.

