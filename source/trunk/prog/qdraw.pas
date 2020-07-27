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
unit qdraw;

interface

uses Windows, Messages, SysUtils, Graphics;

{
 PointVisible16: function (const P: TPoint) : Boolean;
 Polygon16: function (DC: HDC; var Pts; NbPts: Integer) : Bool; stdcall;
 PolyPolyline16: function (DC: HDC; var Pts, Cnt; NbPolylines: Integer) : Bool; stdcall;
 Rectangle16: function (DC: HDC; X1,Y1,X2,Y2: Integer) : Bool; stdcall;
 Line16: procedure (DC: HDC; const P1,P2: TPoint);}

{procedure CheckWindows16bits(HiZoom: Boolean);}

{function PolyPolyline95(DC: HDC; var Pts, Cnt; NbPolylines: Integer) : Bool; stdcall;
function Rectangle95(DC: HDC; X1,Y1,X2,Y2: Integer) : Bool; stdcall;
procedure Line95(DC: HDC; const P1,P2: TPoint);
function Polygon95(DC: HDC; var Pts; NbPts: Integer) : Bool; stdcall;
function PointVisible95(const P: TPoint) : Boolean;}

implementation

function PointVisibleOk(const P: TPoint) : Boolean;
begin
 Result:=True;
end;

procedure LineOk(DC: HDC; const P1,P2: TPoint);
begin
 Windows.MoveToEx(DC, P1.X,P1.Y, Nil);
 Windows.LineTo(DC, P2.X,P2.Y);
end;

const
 Max95 = 8192;

function PointVisible95(const P: TPoint) : Boolean;
begin
 Result:=(P.X>=-Max95) and (P.Y>=-Max95) and (P.X<Max95) and (P.Y<Max95);
end;

function Ligne95(var P1, P2: TPoint) : Boolean;
begin
 Ligne95:=True;
 if P1.Y<-Max95 then
  begin
   if P2.Y<-Max95 then
    begin
     P2.Y:=-Max95;
     Ligne95:=False;
    end
   else
    P1.X:=P2.X + MulDiv(P2.Y+Max95, P1.X-P2.X, P2.Y-P1.Y);
   P1.Y:=-Max95;
  end;
 if P1.Y>Max95 then
  begin
   if P2.Y>Max95 then
    begin
     P2.Y:=Max95;
     Ligne95:=False;
    end
   else
    P1.X:=P2.X + MulDiv(Max95-P2.Y, P1.X-P2.X, P1.Y-P2.Y);
   P1.Y:=Max95;
  end;
 if P2.Y<-Max95 then
  begin
   P2.X:=P1.X + MulDiv(P1.Y+Max95, P2.X-P1.X, P1.Y-P2.Y);
   P2.Y:=-Max95;
  end;
 if P2.Y>Max95 then
  begin
   P2.X:=P1.X + MulDiv(Max95-P1.Y, P2.X-P1.X, P2.Y-P1.Y);
   P2.Y:=Max95;
  end;

 if P1.X<-Max95 then
  begin
   if P2.X<-Max95 then
    begin
     P2.X:=-Max95;
     Ligne95:=False;
    end
   else
    P1.Y:=P2.Y + MulDiv(P2.X+Max95, P1.Y-P2.Y, P2.X-P1.X);
   P1.X:=-Max95;
  end;
 if P1.X>Max95 then
  begin
   if P2.X>Max95 then
    begin
     P2.X:=Max95;
     Ligne95:=False;
    end
   else
    P1.Y:=P2.Y + MulDiv(Max95-P2.X, P1.Y-P2.Y, P1.X-P2.X);
   P1.X:=Max95;
  end;
 if P2.X<-Max95 then
  begin
   P2.Y:=P1.Y + MulDiv(P1.X+Max95, P2.Y-P1.Y, P1.X-P2.X);
   P2.X:=-Max95;
  end;
 if P2.X>Max95 then
  begin
   P2.Y:=P1.Y + MulDiv(Max95-P1.X, P2.Y-P1.Y, P2.X-P1.X);
   P2.X:=Max95;
  end;
end;

function Polygon95(DC: HDC; var Pts; NbPts: Integer) : Bool; stdcall;
var
 I, J: Integer;
 Pt, Tampon, Dest: ^TPoint;
 CorrPolygon: Boolean;
 Origine0, Origine, Cible, PointCourant: TPoint;
begin
 CorrPolygon:=False;
 Pt:=@Pts;
 for J:=1 to NbPts do
  begin
   with Pt^ do
    if (X<-Max95) or (Y<-Max95) or (X>Max95) or (Y>Max95) then
     begin
      CorrPolygon:=True;
      Break;
     end;
   Inc(Pt);
  end;
 if CorrPolygon then
  begin
   GetMem(Tampon, NbPts * (2*SizeOf(TPoint))); try
   Pt:=@Pts;
   Dest:=Pt;
   Inc(Dest, NbPts-1);
   Origine0:=Dest^;
   Dest:=Tampon;
   I:=0;
   PointCourant.X:=MaxInt;
   for J:=1 to NbPts do
    begin
     Origine:=Origine0;
     Cible:=Pt^;
     Origine0:=Cible;
     Ligne95(Origine, Cible);
     if (Origine.X<>PointCourant.X) or (Origine.Y<>PointCourant.Y) then
      begin
       Dest^:=Origine;
       Inc(Dest);
       Inc(I);
      end;
     if (Origine.X<>Cible.X) or (Origine.Y<>Cible.Y) then
      begin
       Dest^:=Cible;
       Inc(Dest);
       Inc(I);
      end;
     PointCourant:=Cible;
     Inc(Pt);
    end;
   Dec(Dest);
   with Dest^ do
    if (X=Tampon^.X) and (Y=Tampon^.Y) then
     Dec(I);
   if I>=3 then
    Windows.Polygon(DC, Tampon^, I);
   finally FreeMem(Tampon); end;
  end
 else
  Windows.Polygon(DC, Pts, NbPts);
 Result:=True;
end;

function PolyPolyline95(DC: HDC; var Pts, Cnt; NbPolylines: Integer) : Bool; stdcall;
var
 I, J: Integer;
 P: ^Integer;
 Pt: ^TPoint;
 Origine0, Origine, Dest: TPoint;
 CorrPolyline: Boolean;
begin
 CorrPolyline:=False;
 P:=@Cnt;
 Pt:=@Pts;
 for I:=1 to NbPolylines do
  begin
   for J:=P^ downto 1 do
    begin
     with Pt^ do
      if (X<-Max95) or (Y<-Max95) or (X>Max95) or (Y>Max95) then
       begin
        CorrPolyline:=True;
        Inc(Pt, J);
        Inc(P^, $80000000);
        Break;
       end;
     Inc(Pt);
    end;
   Inc(P);
  end;
 if CorrPolyline then
  begin
   P:=@Cnt;
   Pt:=@Pts;
   for I:=1 to NbPolylines do
    begin
     if P^<0 then
      begin
       Dec(P^, $80000000);
       Origine0:=Pt^;
       Inc(Pt);
       for J:=2 to P^ do
        begin
         Origine:=Origine0;
         Dest:=Pt^;
         Origine0:=Dest;
         if Ligne95(Origine, Dest) then
          begin
           Windows.MoveToEx(DC, Origine.X, Origine.Y, Nil);
           Windows.LineTo(DC, Dest.X, Dest.Y);
          end;
         Inc(Pt);
        end;
      end
     else
      begin
       Windows.Polyline(DC, Pt^, P^);
       Inc(Pt, P^);
      end;
     Inc(P);
    end;
  end
 else
  Windows.PolyPolyline(DC, Pts, Cnt, NbPolylines);
 Result:=True;
end;

function Rectangle95(DC: HDC; X1,Y1,X2,Y2: Integer) : Bool; stdcall;
begin
 if (X2<=-Max95) or (Y2<=-Max95) or (X1>=Max95) or (Y1>=Max95) then
  begin
   Result:=True;
   Exit;
  end;
 if X1<-Max95 then X1:=-Max95;
 if Y1<-Max95 then Y1:=-Max95;
 if X2>Max95 then X2:=Max95;
 if Y2>Max95 then Y2:=Max95;
 Result:=Windows.Rectangle(DC, X1,Y1,X2,Y2);
end;

procedure Line95(DC: HDC; const P1,P2: TPoint);
var
 P1x, P2x: TPoint;
begin
 P1x:=P1;
 P2x:=P2;
 if Ligne95(P1x, P2x) then
  begin
   Windows.MoveToEx(DC, P1x.X,P1x.Y, Nil);
   Windows.LineTo(DC, P2x.X,P2x.Y);
  end;
end;

(*procedure CheckWindows16bits(HiZoom: Boolean);
var
 OSVersion: TOSVersionInfo;
begin
 OSVersion.dwOSVersionInfoSize:=SizeOf(OSVersion);
 if not HiZoom
 or (GetVersionEx(OSVersion) and (OSVersion.dwPlatformId=VER_PLATFORM_WIN32_NT)) then
  begin   { Windows NT : Ok }
   PointVisible16:=PointVisibleOk;
   Polygon16:=Windows.Polygon;
   PolyPolyline16:=Windows.PolyPolyline;
   Rectangle16:=Windows.Rectangle;
   Line16:=LineOk;
  end
 else
  begin
   PointVisible16:=PointVisible95;
   Polygon16:=Polygon95;
   PolyPolyline16:=PolyPolyline95;
   Rectangle16:=Rectangle95;
   Line16:=Line95;
  end;
end;*)
end.

