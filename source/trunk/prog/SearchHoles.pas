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
unit SearchHoles;

interface

uses SysUtils, Classes, QkObjects, Python;

 {-------------------}

function SearchForHoles(pol, sta: PyObject) : PyObject;

 {-------------------}

implementation

uses Quarkx, qmath, PyObjects, PyMath, Qk3D, QkMapPoly, Travail;

 {-------------------}

type
 TPolyedreEx = class(TPolyedre)
                Precedent: TStreamPos;
               end;

 {-------------------}

function SearchForHoles(pol, sta: PyObject) : PyObject;
const
 DebutCompteur = 50;
 MaxBufferSize = 100;
type
 PInfo = ^TInfo;
 TInfo = record
          Distance: TDouble;
          Poly: TPolyedre;
          Face: PSurface;
         end;
 PTableauInfo = ^TTableauInfo;
 TTableauInfo = array[0..MaxBufferSize-1] of TInfo;
 PInfoSource = ^TInfoSource;
 TInfoSource = record
                P: TVect;
                Poly: TPolyedreEx;
               end;
var
 Centre: TInfoSource;
 Liste: TMemoryStream;
 Sources: TMemoryStream;
 Sources0: TStreamPos;
 Compteur: Integer;
 TamponInterne: PTableauInfo;

  procedure Init;
  var
   Info: TInfo;
   Centre: TInfoSource;
   I: Integer;
   Q: QObject;
   obj: PyObject;
  begin
   for I:=0 to PyObject_Length(pol)-1 do
    begin
     Q:=QkObjFromPyObj(PyList_GetItem(pol, I));
     if Q is TPolyedre then
      begin
       Info.Poly:=TPolyedre(Q);
       Info.Poly.AddRef(+1);
       Liste.Write(Info, SizeOf(Info));
      end;
    end;
   for I:=0 to PyObject_Length(sta)-1 do
    begin
     obj:=PyList_GetItem(sta, I);
     if obj^.ob_type = @TyVect_Type then
      Centre.P:=PyVect(obj)^.V
     else
      begin
       Q:=QkObjFromPyObj(obj);
       if not (Q is Q3DObject) or not Q3DObject(Q).GetOrigin(Centre.P) then
        Continue;
      end;
     Centre.Poly:=Nil;
     Sources.Write(Centre, SizeOf(Centre));
    end;
  end;

  procedure Gonfler;
  var
   New: TPolyedreEx;
   TamponInterne: PTableauInfo;
   I, J, K, N: Integer;
   F, F1: PSurface;
   nFace: TFace;
   Derriere: Boolean;
   Dist1: TDouble;
   Info: TInfo;
   nCentre: TInfoSource;

    PROCEDURE TrierTampon(Gauche,Droite : INTEGER);
    VAR
     I,J : INTEGER;
     Pivot: TDouble;
     UneCase: TInfo;
    BEGIN
     I:=Gauche; J:=Droite;
     Pivot:=TamponInterne^[(Gauche+Droite) DIV 2].Distance;
     REPEAT
      WHILE TamponInterne^[I].Distance < Pivot DO INC(I);
      WHILE TamponInterne^[J].Distance > Pivot DO DEC(J);
      IF I<=J THEN
       BEGIN
        UneCase:=TamponInterne^[I];
        TamponInterne^[I]:=TamponInterne^[J];
        TamponInterne^[J]:=UneCase;
        INC(I);
        DEC(J);
       END;
     UNTIL I>J;
     IF J>Gauche THEN TrierTampon(Gauche,J);
     IF I<Droite THEN TrierTampon(I,Droite);
    END;

    procedure DiviserX(const Sommets: TFVertexTable; NbS, J0: Integer);
    var
     J, K, L, S: Integer;
     FK: PSurface;
     Centre: TInfoSource;
     P1, P2: TVect;
     Norm2: array[0..MaxFVertices-1] of record Y,Z,Dist: TDouble end;
     Min, Max, D1, D2: TDouble;
    begin
     P1:=Sommets[0]^.P;
     for S:=NbS-1 downto 0 do
      begin
       P2:=P1;
       P1:=Sommets[S]^.P;
       with Norm2[S] do
        begin
         Y:=(P1.Z-P2.Z) * F^.F.Normale.X;
         Z:=(P2.Y-P1.Y) * F^.F.Normale.X;
         Dist:=Y*P1.Y + Z*P1.Z - rien2;
        end;
      end;
     for J:=J0 to N-1 do
      with TamponInterne^[J].Poly do
       for K:=0 to Faces.Count-1 do
        begin
         FK:=PSurface(Faces[K]);
         if (Abs(FK^.F.Normale.X+F^.F.Normale.X)<rien)
         and (Abs(FK^.F.Normale.Y+F^.F.Normale.Y)<rien)
         and (Abs(FK^.F.Normale.Z+F^.F.Normale.Z)<rien)
         and (Abs(FK^.F.Dist+F^.F.Dist)<rien) then
          begin
           P1:=FK^.prvVertexTable[0]^.P;
           for L:=FK^.prvVertexCount-1 downto 0 do
            begin
             P2:=P1;
             P1:=FK^.prvVertexTable[L]^.P;
             Min:=0;
             Max:=1;
             for S:=0 to NbS-1 do
              with Norm2[S] do
               begin
                D1:=Y*P1.Y + Z*P1.Z - Dist;
                D2:=Y*P2.Y + Z*P2.Z - Dist;
                if (D1>rien) and (D2<-rien) then
                 begin
                  D1:=D1/(D1-D2);
                  if D1>Min then
                   Min:=D1;
                 end
                else
                 if (D1<-rien) and (D2>rien) then
                  begin
                   D1:=D1/(D1-D2);
                   if D1<Max then
                    Max:=D1;
                  end
                 else
                  if (D1>rien) and (D2>rien) then
                   begin
                    Min:=Max;
                    Break;
                   end;
               end;
             if Min < Max-rien2 then
              begin
               D1:=0.5*(Min+Max);
               P2.Y:=P2.Y-P1.Y;
               P2.Z:=P2.Z-P1.Z;
               D2:=rien2*F^.F.Normale.X;
               Centre.P.Y:=P1.Y + D1*P2.Y + D2*P2.Z;
               Centre.P.Z:=P1.Z + D1*P2.Z - D2*P2.Y;
               Centre.P.X := (-Centre.P.Y*F^.F.Normale.Y
                - Centre.P.Z*F^.F.Normale.Z + F^.F.Dist + rien2) / F^.F.Normale.X;
               Centre.Poly:=New;
               Sources.Write(Centre, SizeOf(Centre));
              end;
            end;
          end;
        end;
    end;

    procedure DiviserY(const Sommets: TFVertexTable; NbS, J0: Integer);
    var
     J, K, L, S: Integer;
     FK: PSurface;
     Centre: TInfoSource;
     P1, P2: TVect;
     Norm2: array[0..MaxFVertices-1] of record X,Z,Dist: TDouble end;
     Min, Max, D1, D2: TDouble;
    begin
     P1:=Sommets[0]^.P;
     for S:=NbS-1 downto 0 do
      begin
       P2:=P1;
       P1:=Sommets[S]^.P;
       with Norm2[S] do
        begin
         X:=(P2.Z-P1.Z) * F^.F.Normale.Y;
         Z:=(P1.X-P2.X) * F^.F.Normale.Y;
         Dist:=Z*P1.Z + X*P1.X - rien2;
        end;
      end;
     for J:=J0 to N-1 do
      with TamponInterne^[J].Poly do
       for K:=0 to Faces.Count-1 do
        begin
         FK:=PSurface(Faces[K]);
         if (Abs(FK^.F.Normale.X+F^.F.Normale.X)<rien)
         and (Abs(FK^.F.Normale.Y+F^.F.Normale.Y)<rien)
         and (Abs(FK^.F.Normale.Z+F^.F.Normale.Z)<rien)
         and (Abs(FK^.F.Dist+F^.F.Dist)<rien) then
          begin
           P1:=FK^.prvVertexTable[0]^.P;
           for L:=FK^.prvVertexCount-1 downto 0 do
            begin
             P2:=P1;
             P1:=FK^.prvVertexTable[L]^.P;
             Min:=0;
             Max:=1;
             for S:=0 to NbS-1 do
              with Norm2[S] do
               begin
                D1:=X*P1.X + Z*P1.Z - Dist;
                D2:=X*P2.X + Z*P2.Z - Dist;
                if (D1>rien) and (D2<-rien) then
                 begin
                  D1:=D1/(D1-D2);
                  if D1>Min then
                   Min:=D1;
                 end
                else
                 if (D1<-rien) and (D2>rien) then
                  begin
                   D1:=D1/(D1-D2);
                   if D1<Max then
                    Max:=D1;
                  end
                 else
                  if (D1>rien) and (D2>rien) then
                   begin
                    Min:=Max;
                    Break;
                   end;
               end;
             if Min < Max-rien2 then
              begin
               D1:=0.5*(Min+Max);
               P2.X:=P2.X-P1.X;
               P2.Z:=P2.Z-P1.Z;
               D2:=rien2*F^.F.Normale.Y;
               Centre.P.X:=P1.X + D1*P2.X - D2*P2.Z;
               Centre.P.Z:=P1.Z + D1*P2.Z + D2*P2.X;
               Centre.P.Y := (-Centre.P.X*F^.F.Normale.X
                - Centre.P.Z*F^.F.Normale.Z + F^.F.Dist + rien2) / F^.F.Normale.Y;
               Centre.Poly:=New;
               Sources.Write(Centre, SizeOf(Centre));
              end;
            end;
          end;
        end;
    end;

    procedure DiviserZ(const Sommets: TFVertexTable; NbS, J0: Integer);
    var
     J, K, L, S: Integer;
     FK: PSurface;
     Centre: TInfoSource;
     P1, P2: TVect;
     Norm2: array[0..MaxFVertices-1] of record X,Y,Dist: TDouble end;
     Min, Max, D1, D2: TDouble;
    begin
     P1:=Sommets[0]^.P;
     for S:=NbS-1 downto 0 do
      begin
       P2:=P1;
       P1:=Sommets[S]^.P;
       with Norm2[S] do
        begin
         X:=(P1.Y-P2.Y) * F^.F.Normale.Z;
         Y:=(P2.X-P1.X) * F^.F.Normale.Z;
         Dist:=X*P1.X + Y*P1.Y - rien2;
        end;
      end;
     for J:=J0 to N-1 do
      with TamponInterne^[J].Poly do
       for K:=0 to Faces.Count-1 do
        begin
         FK:=PSurface(Faces[K]);
         if (Abs(FK^.F.Normale.X+F^.F.Normale.X)<rien)
         and (Abs(FK^.F.Normale.Y+F^.F.Normale.Y)<rien)
         and (Abs(FK^.F.Normale.Z+F^.F.Normale.Z)<rien)
         and (Abs(FK^.F.Dist+F^.F.Dist)<rien) then
          begin
           P1:=FK^.prvVertexTable[0]^.P;
           for L:=FK^.prvVertexCount-1 downto 0 do
            begin
             P2:=P1;
             P1:=FK^.prvVertexTable[L]^.P;
             Min:=0;
             Max:=1;
             for S:=0 to NbS-1 do
              with Norm2[S] do
               begin
                D1:=X*P1.X + Y*P1.Y - Dist;
                D2:=X*P2.X + Y*P2.Y - Dist;
                if (D1>rien) and (D2<-rien) then
                 begin
                  D1:=D1/(D1-D2);
                  if D1>Min then
                   Min:=D1;
                 end
                else
                 if (D1<-rien) and (D2>rien) then
                  begin
                   D1:=D1/(D1-D2);
                   if D1<Max then
                    Max:=D1;
                  end
                 else
                  if (D1>rien) and (D2>rien) then
                   begin
                    Min:=Max;
                    Break;
                   end;
               end;
             if Min < Max-rien2 then
              begin
               D1:=0.5*(Min+Max);
               P2.X:=P2.X-P1.X;
               P2.Y:=P2.Y-P1.Y;
               D2:=rien2*F^.F.Normale.Z;
               Centre.P.X:=P1.X + D1*P2.X + D2*P2.Y;
               Centre.P.Y:=P1.Y + D1*P2.Y - D2*P2.X;
               Centre.P.Z := (-Centre.P.X*F^.F.Normale.X
                - Centre.P.Y*F^.F.Normale.Y + F^.F.Dist + rien2) / F^.F.Normale.Z;
               Centre.Poly:=New;
               Sources.Write(Centre, SizeOf(Centre));
              end;
            end;
          end;
        end;
    end;

  begin
  {if Sources0=11424 then
    Liste.Size;}
   N:=Liste.Size div SizeOf(TInfo);
   Pointer(TamponInterne):=Liste.Memory;
   for J:=N-1 downto 0 do
    with TamponInterne^[J] do
     begin
      Face:=Nil;
      Distance:=rien;
      with Poly.Faces do
       for I:=0 to Count-1 do
        begin
         F:=PSurface(Items[I]);
         Dist1:=Dot(Centre.P, F^.F.Normale) - F^.F.Dist;
         if Dist1>Distance then
          begin
           Distance:=Dist1;
           Face:=F;
          end;
        end;
      if Face=Nil then
       Exit;   { 'Centre' est � l'int�rieur d'un poly�dre }
     end;
   if N>1 then
    TrierTampon(0, N-1);
   New:=TPolyedreEx.Create('', Nil);
   New.AddRef(+1);
   try
    for I:=0 to N-1 do
     begin
      F1:=TamponInterne^[I].Face;
      Derriere:=False;
      for K:=0 to I-1 do
       begin
        F:=TamponInterne^[K].Face;
        if F<>Nil then
         begin
          Derriere:=True;
          for J:=0 to F1^.prvVertexCount-1 do
           Derriere:=Derriere and (Dot(F1^.prvVertexTable[J]^.P, F^.F.Normale) < F^.F.Dist{+rien});
          if Derriere then
           Break;
         end;
       end;
      if Derriere then
       TamponInterne^[I].Face:=Nil
      else
       begin
        nFace:=TFace(F1.F.Clone(New, False));
        nFace.AddRef(+1); try
        if nFace.Retourner(False) then
         New.AddFace(nFace, False)
        else
         {$IFDEF Debug}Abort{$ENDIF};
        finally nFace.AddRef(-1); end;
       end;
     end;
    New.ConstructVertices;
    Sources.Seek(0,soFromEnd);
    for K:=0 to New.Faces.Count-1 do
     begin
      F:=PSurface(New.Faces[K]);
      nCentre.P:=CentreSurface(F);
      nCentre.P.X:=nCentre.P.X + F^.F.Normale.X * rien2;
      nCentre.P.Y:=nCentre.P.Y + F^.F.Normale.Y * rien2;
      nCentre.P.Z:=nCentre.P.Z + F^.F.Normale.Z * rien2;
      nCentre.Poly:=New;
      Sources.Write(nCentre, SizeOf(nCentre));
      with F^.F.Normale do
       if Abs(X)>Abs(Y) then
        if Abs(X)>Abs(Z) then
         DiviserX(F^.prvVertexTable, F^.prvVertexCount, 0)
        else
         DiviserZ(F^.prvVertexTable, F^.prvVertexCount, 0)
       else
        if Abs(Y)>Abs(Z) then
         DiviserY(F^.prvVertexTable, F^.prvVertexCount, 0)
        else
         DiviserZ(F^.prvVertexTable, F^.prvVertexCount, 0);
     end;
    New.Precedent:=Sources0;
    Info.Poly:=New;
    Liste.Write(Info, SizeOf(Info));
   except
    New.AddRef(-1);
    Raise;
   end;
  end;

  procedure Paf;
  var
   list, v: PyObject;
  begin
   list:=PyList_New(0);
   repeat
    v:=MakePyVect(Centre.P);
    PyList_Append(list, v);
    Py_DECREF(v);
    if Centre.Poly=Nil then Break;
    Sources.Seek(Centre.Poly.Precedent, soFromBeginning);
    Sources.ReadBuffer(Centre, SizeOf(Centre));
   until False;
   SearchForHoles:=list;
  end;

begin
 Sources:=TMemoryStream.Create;
 Liste:=TMemoryStream.Create;
 try
  Init;
  ProgressIndicatorStart(172, 9999);
  try
   Sources.Seek(0,soFromBeginning);
   Sources0:=0;
   Compteur:=1;
   while Sources.Read(Centre, SizeOf(Centre)) = SizeOf(Centre) do
    begin
     try
      Gonfler;
     except
      on EPolyedreInvalide do
       begin
        Paf;
        Exit;
       end;
     end;
     Inc(Sources0, SizeOf(Centre));
     Sources.Seek(Sources0, soFromBeginning);
     if Compteur>0 then
      Dec(Compteur)
     else
      if Sources.Size>=4096 then
       begin
        ProgressIndicatorChangeMax(Sources0 div 4096, Sources.Size div 4096);
        ProgressIndicatorIncrement;
        Compteur:=DebutCompteur;
       end;
    end;
  finally
   ProgressIndicatorStop;
   Pointer(TamponInterne):=Liste.Memory;
   for Compteur:=Liste.Size div SizeOf(TInfo)-1 downto 0 do
    with TamponInterne^[Compteur].Poly do
     AddRef(-1);
  end;
 finally
  Sources.Free;
  Liste.Free;
 end;
 Result:=PyNoResult;
end;

 {-------------------}

(*initialization
  RegisterQObject(TPolyedreEx, 'a');*)
end.
