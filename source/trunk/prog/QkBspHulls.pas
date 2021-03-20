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
unit QkBspHulls;

interface

uses Windows, SysUtils, Classes, QkObjects, QkMapObjects, QkBsp,
     qmath, QkFileObjects;

const
  MAX_MAP_HULLS = 4; //8 FOR HEXEN2!!!
  MAXLIGHTMAPS = 4;

type
 TBytePair = record
              first, second: Byte;
             end;
 TSmallIntPair = record
                  first, second: SmallInt;
                 end;
 TIntegerPair = record
                 first, second : Integer;
                end;
 TBoundBox = record
              Min, Max: vec3_t;
             end;

 PHull = ^THull; //@@@RENAME: TQ1Hull AND THE OTHERS TOO
 THull = record
          Bound: TBoundBox;
          Origin: vec3_t;
          Node_id: array[0..MAX_MAP_HULLS-1] of Integer; //4@@@
          NumLeafs, Face_id, Face_num: Integer;
         end;
 PHullH2 = ^THullH2;
 THullH2 = record
            Bound: TBoundBox;
            Origin: vec3_t;
            Node_id: array[0..8-1] of Integer; //@@@MAX_MAP_HULLS
            NumLeafs, Face_id, Face_num: Integer;
           end;
 PHullQ2 = ^THullQ2;
 THullQ2 = record
            Bound: TBoundBox;
            Origin: vec3_t;
            HeadNode, Face_id, Face_num: Integer;
           end;
 PHullQ3 = ^THullQ3;
 THullQ3 = record
            Bound: TBoundBox;
            Face_id, Face_num: Integer;
            Brush_id, Brush_num: Integer;
           end;

 PbSurface = ^TbSurface; //@@@Rename: Q1!
 TbSurface = record
              Plane_id, Side: SmallInt;
              LEdge_id: Integer;
              LEdge_num, TexInfo_id: SmallInt;
              LightStyles: array[0..MAXLIGHTMAPS-1] of Byte;
              LightMap: Integer;
             end;

 PbSOFSurface = ^TbSOFSurface;
 TbSOFSurface = record
              Plane_id: Word;
              Side: SmallInt;
              LEdge_id: Integer;
              LEdge_num, TexInfo_id: SmallInt;
              Region_id: SmallInt;
              RegionFace_id: Integer;
              RegionFace_num: SmallInt;
              LightStyles: array[0..MAXLIGHTMAPS-1] of Byte;
              Lightofs: Integer;
              Lm_Size, Lm_Start : TBytePair;
              Texturemins: TSmallIntPair;
              Extents: TSmallIntPair;
             end;

 PbQ3Surface = ^TbQ3Surface;
 TbQ3Surface = record
                TexInfo_id: Integer;
                Effect_id: Integer;
                Face_Type: Integer; { 0=bad, 1=planer (polygon), 2=patch, 3=mesh (triangle soup), 4=billboard (flare) }
                Vertex_id, Vertex_num, Meshvert_id, Meshvert_num : Integer;
                Lightmap_id : Integer;
                Lm_Start, Lm_Size : TIntegerPair;
                Lm_Origin, Lm_S, Lm_T : vec3_t;
                Normal: vec3_t;
                PatchDim: TIntegerPair;
               end;

 TLEdge = LongInt;
 PLEdge = ^TLEdge;
 PEdge = ^TEdge;
 TEdge = record
          Vertex0, Vertex1: Word;
         end;
 PTexInfoVecs = ^TTexInfoVecs;
 TTexInfoVecs = array[0..1, 0..3] of scalar_t;
 PTexInfo = ^TTexInfo;
 TTexInfo = record
             vecs: TTexInfoVecs;     // [s/t][xyz offset]
             miptex: Integer;
             flags: Integer;
            end;
 PTexInfoQ2 = ^TTexInfoQ2; //@Also used by SOF!
 TTexInfoQ2 = record
               vecs: TTexInfoVecs;             // [s/t][xyz offset]
               flags: LongWord;                // miptex flags + overrides
               value: LongWord;                // light emission, etc
               texture: array[0..31] of Byte;  // texture name (textures/*.wal)
               nexttexinfo: LongWord;          // for animations, -1 = end of chain
              end;

const
 MAX_QPATH = 64; //Q3@@@
type
 PTexInfoQ3 = ^ TTexInfoQ3;
 TTexInfoQ3 = record
                texture: array[0..MAX_QPATH-1] of Byte;
                flags: Integer;
                content: Integer;
              end;

type
 TBSPHull = class(TTreeMapGroup)
            private
              FBsp: QBSP;
              HullNum, UsedVertex: Integer;
              NbFaces, FirstFace: Integer;
              SurfaceList: PChar;
            public
              constructor Create(nBsp: QBSP; Index: Integer; nParent: QObject);
              destructor Destroy; override;
              class function TypeInfo: String; override;
              procedure ObjectState(var E: TEtatObjet); override;
              function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
              procedure Dessiner; override;
             {function SingleLevel: Boolean; override;}
             {procedure AjouterRef(Liste: TList; Niveau: Integer) : Integer; override;}
            end;

 {------------------------}

function CheckQ1Hulls(Hulls: PHull; Size, FaceCount: Integer) : Boolean;
function CheckH2Hulls(Hulls: PHullH2; Size, FaceCount: Integer) : Boolean;

 {------------------------}

implementation

uses QkExceptions, QkMapPoly, Setup, qmatrices, QkWad, Quarkx, PyMath, Qk3D,
     QkObjectClassList, Dialogs, Travail, Logging;

 {------------------------}

function CheckQ1Hulls(Hulls: PHull; Size, FaceCount: Integer) : Boolean;
var
 P, Q: PHull;
 I, J, HullCount: Integer;
begin
 Result:=False;
 HullCount:=Size div SizeOf(THull);
 if HullCount*SizeOf(THull)<>Size then Exit;
 P:=Hulls;
 for I:=1 to HullCount do
  begin
   with P^ do
    begin
     if (Face_id<0) or (Face_num<=0) or (Face_id>=FaceCount) or (Face_id+Face_num>FaceCount) then
      Exit;    { invalid Face_id and Face_num }
     Q:=Hulls;
     for J:=2 to I do
      begin
       if (Face_id+Face_num > Q^.Face_id) and (Face_id < Q^.Face_id+Q^.Face_num) then
        Exit;   { overlapping Face_id and Face_num }
       Inc(Q);
      end;
    end;
   Inc(P);
  end;
 Result:=True;
end;

function CheckH2Hulls(Hulls: PHullH2; Size, FaceCount: Integer) : Boolean;
var
 P, Q: PHullH2;
 I, J, HullCount: Integer;
begin
 Result:=False;
 HullCount:=Size div SizeOf(THullH2);
 if HullCount*SizeOf(THullH2)<>Size then Exit;
 P:=Hulls;
 for I:=1 to HullCount do
  begin
   with P^ do
    begin
     if (Face_id<0) or (Face_num<=0) or (Face_id>=FaceCount) or (Face_id+Face_num>FaceCount) then
      Exit;    { invalid Face_id and Face_num }
     Q:=Hulls;
     for J:=2 to I do
      begin
       if (Face_id+Face_num > Q^.Face_id) and (Face_id < Q^.Face_id+Q^.Face_num) then
        Exit;   { overlapping Face_id and Face_num }
       Inc(Q);
      end;
    end;
   Inc(P);
  end;
 Result:=True;
end;

 {------------------------}

constructor TBSPHull.Create(nBsp: QBSP; Index: Integer; nParent: QObject);
var
 HullType: Char;
 Delta, Size1: Integer;
 S: String;
 I, J, NoVert, NoVert2{, TexInfo_id}, SurfaceSize, FaceType: Integer;
 Faces, Faces2: PbSurface;
 Q3Faces, Q3Faces2: PbQ3Surface;
 LEdges, Edges, Vertices, TexInfo, Planes, P: PChar;
 cLEdges, cEdges, cVertices, cTexInfo, cPlanes: Integer;
 LEdge: PLEdge;
 NoEdge: LongInt;
 Face: TFace;
 Surface1: PSurface;
 Dest: ^PVertex;
 BspVecs: PTexInfoVecs;
 InvFaces: Integer;
 LastError: String;
 P1, P2, P3, NN: TVect;
 P5_1, P5_2, P5_3: TVect5;
 PlaneDist: TDouble;
 texcoord: vec2_t;
 Q3Vertex: TQ3Vertex;
 Q3VertexP: PQ3Vertex;
 TextureList: QTextureList;
 miptex, q12surf: boolean;
 Norm2 : TVect;

 function AdjustTexScale(const V: TVect5) : TVect5;
 begin
   Result:=V;
  { Result.S:=Result.S; }
   Result.T:=-Result.T;
 end;

begin
 inherited Create(FmtLoadStr1(5406, [Index]), nParent);
 Log(LOG_INFO, LoadStr1(5466), [Index]);

 // Initialize variables
 PChar(LEdge) := #0;
 PlaneDist := 0;
 cEdges := 0;
 HullNum:=Index;
 FBsp:=nBsp;
 FBsp.AddRef(+1);
 FBsp.VerticesAddRef(+1);
 try
  InvFaces:=0;
  cTexInfo:=0;
  HullType:=FBsp.FileHandler.GetHullType(FBsp.NeedObjectGameCode);
  q12surf:=FBsp.FileHandler.GetSurfaceType(HullType)=bspSurfQ12;
  miptex:=SetupSubSet(ssGames, GetGameName(FBsp.NeedObjectGameCode)).Specifics.Values['UsesMipTex']<>'';
  case HullType of
   HullQ1:  Size1:=SizeOf(THull);
   HullHx:  Size1:=SizeOf(THullH2);
   HullQ2:  Size1:=SizeOf(THullQ2);
   HullQ3:  Size1:=SizeOf(THullQ3);
  else Exit;
  end;
  I:=FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpModels(), P);
  Delta:=Size1*Succ(Index);
  if I<Delta then
   Raise EErrorFmt(5635, [1]);
  Inc(P, Delta-Size1);
  case HullType of
   HullQ1: with PHull(P)^ do
             begin
              NbFaces:=Face_num;
              FirstFace:=Face_id;
              cTexInfo:=SizeOf(TTexInfo);
             end;
   HullHx: with PHullH2(P)^ do
             begin
              NbFaces:=Face_num;
              FirstFace:=Face_id;
              cTexInfo:=SizeOf(TTexInfo);
             end;
   HullQ2: with PHullQ2(P)^ do
              begin
               NbFaces:=Face_num;
               FirstFace:=Face_id;
               cTexInfo:=SizeOf(TTexInfoQ2);
              end;
   HullQ3: with PHullQ3(P)^ do
              begin
               NbFaces:=Face_num;
               FirstFace:=Face_id;
               cTexInfo:=SizeOf(TTexInfoQ3);
              end;
   end;
  if not miptex then
   TextureList:=Nil
  else
   begin
    TextureList:=FBsp.BspEntry[FBsp.FileHandler.GetLumpTextures()] as QTextureList;
    TextureList.Acces;
   end;
  if q12surf then
  begin
    if Fbsp.NeedObjectGameCode=mjSOF then
      SurfaceSize:=SizeOf(TbSOFSurface)
    else
      SurfaceSize:=SizeOf(TbSurface);
    {J:=  FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpFaces(), PChar(Faces));}
    if FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpFaces(), PChar(Faces)) < (FirstFace+NbFaces)*SurfaceSize then
       Raise EErrorFmt(5635, [2]);
    Inc(PChar(Faces), Pred(FirstFace) * SurfaceSize);
    cLEdges  :=FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpSurfEdges(), LEdges) div SizeOf(TLEdge);
    cEdges   :=FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpEdges(), Edges) div SizeOf(TEdge);
    Log(LOG_INFO, LoadStr1(5468), [cLEdges]);
    Log(LOG_INFO, LoadStr1(5469), [cEdges]);
  end else
  begin
    SurfaceSize:=Sizeof(TbQ3Surface);
    if FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpFaces(), PChar(Q3Faces)) < (FirstFace+NbFaces)*SurfaceSize then
      Raise EErrorFmt(5635, [2]);
    Inc(PChar(Q3Faces), Pred(FirstFace) * SurfaceSize);
  end;
  cTexInfo :=FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpTexInfo(), TexInfo) div cTexInfo;
  { cPlanes  :=FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpPlanes(), Planes) div SizeOf(TQ1Plane);
  { FBsp.FVertices, VertexCount are previously computed
    by FBsp.GetStructure }

  cPlanes := FBsp.PlaneCount;
  Planes := FBsp.Planes;

  Vertices:=PChar(FBsp.FVertices);
  cVertices:=FBsp.VertexCount;

  Log(LOG_INFO, LoadStr1(5470), [cTexInfo]);
  Log(LOG_INFO, LoadStr1(5471), [cPlanes]);
  Log(LOG_INFO, LoadStr1(5472), [cVertices]);

  Size1:=0;
  { for each face in the brush, reserve space for a Surface }
  if q12surf then
  begin
    Faces2:=Faces;
    for I:=1 to NbFaces do
    begin
      Inc(PChar(Faces2), SurfaceSize);
      if Faces2^.ledge_id + Faces2^.ledge_num > cLEdges then
        Raise EErrorFmt(5635, [3]);
      Inc(Size1, TailleBaseSurface+Faces2^.ledge_num*SizeOf(PVertex));
    end;
  end
  else
  begin
    Q3Faces2:=Q3Faces;
    for I:=1 to NbFaces do
    begin
      Inc(PChar(Q3Faces2), SurfaceSize);
      if Q3Faces2^.Face_Type=1 then
      begin
        {FIXME : check for face additions as above}
        Inc(Size1, TailleBaseSurface+Q3Faces2^.Vertex_num*SizeOf(PVertex));
      end
      else
        Inc(FBsp.NonFaces);
        {FIXME: we'll be wanting to do something smarter with patches etc}
    end;
  end;
  GetMem(SurfaceList, Size1);
  PChar(Surface1):=SurfaceList;

  SubElements.Capacity:=NbFaces;

  ProgressIndicatorStart(5463, NbFaces); try
  for I:=1 to NbFaces do
   begin
    ProgressIndicatorIncrement;
    if q12surf then
    begin
      Inc(PChar(Faces), SurfaceSize);
      PChar(LEdge):=LEdges + Faces^.ledge_id * SizeOf(TLEdge);
    end
    else
    begin
      Inc(PChar(Q3Faces), SurfaceSize);
      if Q3Faces^.Face_Type<>1 then
        Continue;
    end;
    Surface1^.Source:=Self;
    Surface1^.NextF:=Nil;
    if q12surf then
    begin
      Surface1^.prvVertexCount:=Faces^.ledge_num;
      if Faces^.Plane_id >= cPlanes then
      begin
        Inc(InvFaces);
        LastError:='Err Plane_id';
        Continue;
      end;
      with PQ1Plane(Planes + Faces^.Plane_id * SizeOf(TQ1Plane))^ do
      begin
        NN.X:=normal[0];
        NN.Y:=normal[1];
        NN.Z:=normal[2];
        PlaneDist:=dist;
      end;
    end
    else
    begin
      with Q3Faces^ do
      begin
        Surface1^.prvVertexCount:=Vertex_num;
        NN.X:=Normal[0];
        NN.Y:=Normal[1];
        NN.Z:=Normal[2];
        { fill in PlaneDist later }
      end
    end;
    {TexInfo_id:=Faces^.TexInfo_id;}

    PChar(Dest):=PChar(Surface1)+TailleBaseSurface;
    if q12surf then
    for J:=1 to Faces^.ledge_num do
    begin
      NoEdge:=LEdge^;
      Inc(PChar(LEdge), SizeOf(TLEdge));
      if NoEdge < 0 then
       begin
        if -NoEdge>=cEdges then
         Raise EErrorFmt(5635, [4]);
        with PEdge(Edges - NoEdge * SizeOf(TEdge))^ do
         begin
          NoVert:=Vertex0;
          NoVert2:=Vertex1;
         end;
       end
      else
       begin
        if NoEdge>=cEdges then
         Raise EErrorFmt(5635, [5]);
        with PEdge(Edges + NoEdge * SizeOf(TEdge))^ do
         begin
          NoVert:=Vertex1;
          NoVert2:=Vertex0;
         end;
       end;
      if NoVert2>=UsedVertex then
       UsedVertex:=NoVert2+1;
      if NoVert>=UsedVertex then
       UsedVertex:=NoVert+1;
      Dest^:=PVertex(Vertices + NoVert * SizeOf(TVect));
      Inc(Dest);
    end
    else
    with Q3Faces^ do
    begin
     { the vertexes are stored in the vertex lump in consecutive
       order as they are used by each face.  Since we need a QuArK
       Vertex (Sommet) table like that constructed in FBsp.GetStructure,
       we use it for the vertexes, but use direct access to the bsp
       structure for the texture position information }
      for J:=0 to Vertex_num-1 do
      begin
        //FIXME: Handle meshverts!
        Dest^:=PVertex(Vertices+(Vertex_id+J)*SizeOf(TVect));
        Q3VertexP:=PQ3Vertex(FBsp.Q3Vertices+(Vertex_id+J)*SizeOf(TQ3Vertex));
        //dist:=Q3VertexP^.Normal;
        if J=1 then
        begin
          P1:=MakeVect(vec3_p(Q3VertexP)^);
          PlaneDist:=Dot(NN,P1);
        end;
        Inc(Dest);
      end;
    end;
    if UsedVertex>cVertices then
     Raise EErrorFmt(5635, [6]);

     { load texture infos }
    if q12surf then
    begin
      if Faces^.TexInfo_id >= cTexInfo then
      begin
        Inc(InvFaces);
       {if TexInfo_id = MaxInt then
         LastError:='Err Point Off Plane'
        else}
         LastError:='Err TexInfo_id';
        Continue;
      end;
(*
      if not q12surf then
        with PTexInfoQ3(TexInfo+Q3Faces^.TexInfo_id*SizeOf(TTexInfoQ3))^ do
        begin
          S:=CharToPas(texture);
          { get flags & contents }
        end
      else
*)
      if HullType=BspTypeQ2 then
        with PTexInfoQ2(TexInfo + Faces^.TexInfo_id * SizeOf(TTexInfoQ2))^ do
        begin
          S:=CharToPas(texture);
          BspVecs:=@vecs;
        end
      else
        with PTexInfo(TexInfo + Faces^.TexInfo_id * SizeOf(TTexInfo))^ do
        begin
          BspVecs:=@vecs;
          if miptex>=TextureList.SubElements.Count then
          begin
            Inc(InvFaces);
            LastError:=FmtLoadStr1(5639,[miptex]);
            Continue;
          end;
          S:=TextureList.SubElements[miptex].Name;
        end;

          (** Equations to solve :     with (s,s0)=vecs[0] and (t,t0)=vecs[1]

                s*P1 + s0 = 0       s*P2 + s0 = 128     s*P3 + s0 = 0
                t*P1 + t0 = 0       t*P2 + t0 = 0       t*P3 + t0 = -128

              with P1, P2, P3 in the plane PlaneInfo = (n,d).
              We must solve (s*p,t*p) = (s1,t1).

                s.x*p.x + s.y*p.y + s.z*p.z = s1
                t.x*p.x + t.y*p.y + t.z*p.z = t1
                n.x*p.x + n.y*p.y + n.z*p.z = d
          **)
      g_DrawInfo.Matrice[1,1]:=bspvecs^[0,0];
      g_DrawInfo.Matrice[1,2]:=bspvecs^[0,1];
      g_DrawInfo.Matrice[1,3]:=bspvecs^[0,2];
      g_DrawInfo.Matrice[2,1]:=bspvecs^[1,0];
      g_DrawInfo.Matrice[2,2]:=bspvecs^[1,1];
      g_DrawInfo.Matrice[2,3]:=bspvecs^[1,2];
      g_DrawInfo.Matrice[3,1]:=NN.X;
      g_DrawInfo.Matrice[3,2]:=NN.Y;
      g_DrawInfo.Matrice[3,3]:=NN.Z;
      g_DrawInfo.Matrice:=MatriceInverse(g_DrawInfo.Matrice);
      P1.X:=-bspvecs^[0,3];
      P1.Y:=-bspvecs^[1,3];
      P1.Z:=PlaneDist;
      TransformationLineaire(P1);
      P2.X:=EchelleTexture-bspvecs^[0,3];
      P2.Y:=-bspvecs^[1,3];
      P2.Z:=PlaneDist;
      TransformationLineaire(P2);
      P3.X:=-bspvecs^[0,3];
      P3.Y:=-EchelleTexture-bspvecs^[1,3];
      P3.Z:=PlaneDist;
      TransformationLineaire(P3);
    end
    else
    begin {Q3 texture info}
      if Q3Faces^.Vertex_num< 3 then
        Raise EErrorFmt(5635, [7]);
      J:=1;
      while true do
      begin
        Q3VertexP:=PQ3Vertex(FBsp.Q3Vertices+(Q3Faces^.Vertex_id+J-1)*SizeOf(TQ3Vertex));
        if J=1 then
          { This trick works because the position and tex coords are the
            first 5 fields.  If we want to drag lightmaps into it we'll
            need to go to 7, or do something different }
          P5_1:=AdjustTexScale(MakeVect5(vec5_p(Q3VertexP)^))
        else if J=2 then
          P5_2:=AdjustTexScale(MakeVect5(vec5_p(Q3VertexP)^))
        else if J=3 then
          P5_3:=AdjustTexScale(MakeVect5(vec5_p(Q3VertexP)^))
        else
        begin
          // If this failed, the three vertices lay on a single line. Cycle through to find some that don't.
          P5_1:=P5_2;
          P5_2:=P5_3;
          P5_3:=AdjustTexScale(MakeVect5(vec5_p(Q3VertexP)^));
        end;
        if J>2 then
          // Try to convert them to etp 3points P1-P3
          if SolveForThreePoints(P5_1, P5_2, P5_3, P1, P2, P3) then
            break;
        J:=J+1;
        if J>Q3Faces^.Vertex_num then
          Raise EErrorFmt(5635, [8]);
      end;
      with PTexInfoQ3(TexInfo+Q3Faces^.TexInfo_id*SizeOf(TTexInfoQ3))^ do
      begin
        S:=CharToPas(texture);
        { strip off leading texture/ }
        S:=Copy(S,10,Length(S)-9);
        { get flags & contents }
      end;
    end;

    Face:=TFace.Create(IntToStr(I), Self);
    SubElements.Add(Face);
    if q12surf then
    begin
      if Faces^.side<>0 then
         with Face do
         begin
           Normale.X:=-NN.X;
           Normale.Y:=-NN.Y;
           Normale.Z:=-NN.Z;
           Dist:=-PlaneDist;
         end
      else
        with Face do
        begin
          Normale:=NN;
          Dist:=PlaneDist;
        end;
    end else
    begin
        with Face do
        begin
          Normale:=NN;
        {  Dist:=PlaneDist;  }
        end;
    end;
    { Some changes needed here if NuTex2 branch stuff used  }
    Norm2:=Cross(VecDiff(P2,P1), VecDiff(P3,P1));
    if VecLength(Norm2)> rien then
    begin
      Normalise(Norm2);
      if VecLength(VecDiff(Norm2, Face.Normale)) < rien then
        Face.SetThreePoints(P1, P2, P3)
      else
        Face.SetThreePoints(P1, P3, P2);
    end;
    if not Face.SetThreePointsEx(P1, P2, P3, Face.Normale) then
    begin
      SubElements.Remove(Face);
      Inc(InvFaces);
      LastError:='Err degenerate';
      Continue;
    end;
    Face.NomTex:=S;
    if not q12surf then
      Face.SetThreePointsUserTex(P1,P2,P3,nil);
    Face.Specifics.Add(CannotEditFaceYet+'=1');
    Surface1^.F:=Face;
    Face.LinkSurface(Surface1);
    PChar(Surface1):=PChar(Dest);
   end;
  finally
   ProgressIndicatorStop;
  end;

  if InvFaces>0 then
   GlobalWarning(FmtLoadStr1(5638, [Index, InvFaces, LastError]));
 except
   //DanielPharos: None of this is needed; we're already running through the destructor!
   //FBsp.VerticesAddRef(-1);
   //FBsp.AddRef(-1);
   //FBsp:=Nil;
   //FreeMem(SurfaceList);
   raise;
 end;
end;

{function TBSPHull.SingleLevel: Boolean;
begin
 SingleLevel:=True;
end;}

procedure TBSPHull.Dessiner;   { optimized (the inherited version would also do the job) }
type
 PProjVertices = ^TProjVertices;
 TProjVertices = array[0..0] of TPointProj;
var
 I, J: Integer;
 Faces: PbSurface;
 LEdges, Edges, Vertices, Limit: PChar;
 LEdge: PLEdge;
 NoEdge: LongInt;
 ProjVertices: PProjVertices;
{OutOfView: TBits;}
 OutOfViewChk: Boolean;
 Dest: PPointProj;
 Src: ^TVect;
 Sommets: array[0..1] of PVect;
 ProjSommets: array[0..1] of TPointProj;
{Pts: array[0..1] of TPoint;}
 OldPen, NewPen: HPen;
 PV0, PV1: PPointProj;
begin
 if (FBsp=Nil) or (SurfaceList=Nil) then Exit;
 { optimized versions don't work for SOF, even with correct
   surfacesize }
 if FBsp.NeedObjectGameCode=mjSOF then
 begin
   inherited;
   Exit
 end;

 if FBsp.FileHandler.GetSurfaceType(FBsp.NeedObjectGameCode)=bspSurfQ12 then
 begin
   FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpFaces(), PChar(Faces));
   Inc(PChar(Faces), FirstFace * SizeOf(TbSurface));
   FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpSurfEdges(), LEdges);
   FBsp.GetBspEntryData(FBsp.FileHandler.GetLumpEdges(), Edges);
   Vertices:=PChar(FBsp.FVertices);
 end
 else
 begin
   { Whatever Happens to draw Q3A bsp's ... }
   inherited;
   Exit;
 end;
 if g_DrawInfo.SelectedBrush<>0 then
  begin
   NewPen:=g_DrawInfo.SelectedBrush;
  {OldROP:=SetROP2(g_DrawInfo.DC, R2_CopyPen);}
  end
 else
  if HullNum=0 then
   NewPen:=CreatePen(ps_Solid, 0, MapColors(lcBSP))
  else
   NewPen:=GetStockObject(g_DrawInfo.BasePen);
 OldPen:=SelectObject(g_DrawInfo.DC, NewPen);
 SetROP2(g_DrawInfo.DC, R2_CopyPen);
 ProjVertices:=Nil;
{OutOfView:=Nil;}
 try
  if HullNum=0 then     { point projection optimization }
   begin
    J:=UsedVertex*SizeOf(TPointProj);
    GetMem(ProjVertices, J);
    PChar(Src):=Vertices;
    PChar(Dest):=PChar(ProjVertices);
    Limit:=PChar(Dest)+J;
    while PChar(Dest)<Limit do
     begin
      Dest^:=CCoord.Proj(Src^);
      CCoord.CheckVisible(Dest^);
      Inc(Dest);
      Inc(Src);
     end;
    OutOfViewChk:=(g_DrawInfo.ModeAff>0) and (g_DrawInfo.SelectedBrush=0);
  (*if (g_DrawInfo.ModeAff>0) and (g_DrawInfo.SelectedBrush=0) then
     begin
      OutOfView:=TBits.Create;
      OutOfView.Size:=UsedVertex;
      PChar(Dest):=PChar(ProjVertices);
      for I:=0 to UsedVertex-1 do
       begin
        if Dest^.OffScreen <> 0 then
         OutOfView.Bits[I]:=True;
        Inc(Dest);
       end;
     end;*)
    for I:=1 to NbFaces do   { fast version }
     begin
      PChar(LEdge):=LEdges + Faces^.ledge_id * SizeOf(TLEdge);
      for J:=1 to Faces^.ledge_num do
       begin
        NoEdge:=LEdge^;
        Inc(PChar(LEdge), SizeOf(TLEdge));
        if NoEdge > 0 then  { only draws half the edges - the other ones are drawn in the other direction another time anyway }
         with PEdge(Edges + NoEdge * SizeOf(TEdge))^ do
          begin
           PV0:=@ProjVertices^[Vertex0];
           PV1:=@ProjVertices^[Vertex1];
           if OutOfViewChk then
            begin
             if not ((PV0^.OffScreen<>0) and (PV1^.OffScreen<>0)) then
              begin
               if g_DrawInfo.ModeAff=1 then
                begin
                 SelectObject(g_DrawInfo.DC, NewPen);
                 SetROP2(g_DrawInfo.DC, R2_CopyPen);
                end;
              end
             else
              begin
               if g_DrawInfo.ModeAff=2 then
                Continue;
               SetROP2(g_DrawInfo.DC, g_DrawInfo.MaskR2);
               SelectObject(g_DrawInfo.DC, g_DrawInfo.GreyBrush);
              end;
            end;
           CCoord.Line95f(PV0^, PV1^);
          end;
       end;
       Inc(PChar(Faces), SizeOf(TbSurface));
     end
   end
  else
   for I:=1 to NbFaces do   { slow version }
    begin
     PChar(LEdge):=LEdges + Faces^.ledge_id * SizeOf(TLEdge);
     for J:=1 to Faces^.ledge_num do
      begin
       NoEdge:=LEdge^;
       Inc(PChar(LEdge), SizeOf(TLEdge));
       if NoEdge > 0 then  { only draws half the edges - the other ones are drawn in the other direction another time anyway }
        with PEdge(Edges + NoEdge * SizeOf(TEdge))^ do
         begin
          PChar(Sommets[0]):=Vertices + Vertex0 * SizeOf(TVect);
          PChar(Sommets[1]):=Vertices + Vertex1 * SizeOf(TVect);
          ProjSommets[0]:=CCoord.Proj(Sommets[0]^);
          ProjSommets[1]:=CCoord.Proj(Sommets[1]^);
          CCoord.CheckVisible(ProjSommets[0]);
          CCoord.CheckVisible(ProjSommets[1]);
          if (g_DrawInfo.ModeAff>0) and (g_DrawInfo.SelectedBrush=0) then
           begin
          (*ModeProj:=TModeProj(1-Ord(ModeProj));
            Pts[0]:=Proj(Sommets[0]^);
            Pts[1]:=Proj(Sommets[1]^);
            ModeProj:=TModeProj(1-Ord(ModeProj));
            if PtInRect(g_DrawInfo.VisibleRect, Pts[0])
            or PtInRect(g_DrawInfo.VisibleRect, Pts[1]) then*)
            if (ProjSommets[0].OffScreen=0)
            or (ProjSommets[1].OffScreen=0) then
             begin
              if g_DrawInfo.ModeAff=1 then
               begin
                SelectObject(g_DrawInfo.DC, NewPen);
                SetROP2(g_DrawInfo.DC, R2_CopyPen);
               end;
             end
            else
             begin
              if g_DrawInfo.ModeAff=2 then
               Continue;
              SetROP2(g_DrawInfo.DC, g_DrawInfo.MaskR2);
              SelectObject(g_DrawInfo.DC, g_DrawInfo.GreyBrush);
             end;
           end;
          CCoord.Line95f(ProjSommets[0], ProjSommets[1]);
         end;
      end;
      Inc(PChar(Faces), SizeOf(TbSurface));
    end;
 finally
 {OutOfView.Free;}
  FreeMem(ProjVertices);
  SelectObject(g_DrawInfo.DC, OldPen);
  if g_DrawInfo.SelectedBrush<>0 then
  {SetROP2(g_DrawInfo.DC, OldROP)}
  else
   DeleteObject(NewPen);
 end;
end;

destructor TBSPHull.Destroy;
begin
 inherited;
 if FBsp<>Nil then
  begin
   FBsp.VerticesAddRef(-1);
   FBsp.AddRef(-1);
  end;
 FreeMem(SurfaceList);
end;

class function TBSPHull.TypeInfo: String;
begin
 TypeInfo:=':bsphull';
end;

procedure TBSPHull.ObjectState;
begin
 inherited;
 E.IndexImage:=iiComponent;
end;

function TBSPHull.IsExplorerItem(Q: QObject) : TIsExplorerItem;
begin
 if Q is TFace then
  Result:=ieResult[True] + [ieInvisible]
 else
  Result:=[];
end;

(*function TBSPHull.AjouterRef(Liste: TList; Niveau: Integer) : Integer;
var
 ZMax1: LongInt;
 I: Integer;
 Vertices: PTableauPointsProj;
 S: PSurface;
begin
 if (FBsp<>Nil) and (SurfaceList<>Nil) then
  begin
   if HullNum=0 then
    begin
     GetMem(Vertices, Sommets.Count*SizeOf(TPointsProj)); try
     ZMax1:=-MaxInt;
     for I:=0 to Sommets.Count-1 do
      with Vertices^[I] do
       begin
        Src:=PVertex(Sommets[I]);
        Pt3D:=SceneCourante.Proj(Src^.P);
        if Pt3D.Z > ZMax1 then
         ZMax1:=Pt3D.Z;
      end;
     for I:=0 to Faces.Count-1 do
      begin
       S:=PSurface(Faces[I]);
       S^.F.AjouterSurfaceRef(Liste, S, Vertices, Sommets.Count, ZMax1, Odd(S^.F.SelMult));
        {g_DrawInfo.ColorTraits[esNormal]);}
      end;
     finally FreeMem(Vertices); end;
    end
   else
    inherited AjouterRef(Liste, -1);
   Result:=1;
  end
 else
  Result:=0;
end;*)

 {------------------------}

initialization
  RegisterQObject(TBSPHull, 'a');
end.
