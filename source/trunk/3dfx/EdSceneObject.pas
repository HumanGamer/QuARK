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
Revision 1.24  2007/02/07 20:02:53  danielpharos
Ugly but working fix for an OpenGL lighting memory leak

Revision 1.23  2007/02/06 14:07:39  danielpharos
Another transparency fix. Beziers, sprites and models should now also have transparency.

Revision 1.22  2007/02/06 13:08:47  danielpharos
Fixes for transparency. It should now work (more or less) correctly in all renderers that support it.

Revision 1.21  2007/02/02 12:06:35  danielpharos
Forgot to upload some changes, and changed the MeanColor function so it doesn't overflow anymore, and produces better results faster

Revision 1.20  2007/01/31 15:11:21  danielpharos
HUGH changes: OpenGL lighting, OpenGL transparency, OpenGL culling, OpenGL speedups, and several smaller changes

Revision 1.19  2007/01/06 11:37:23  danielpharos
Fixed the 'Image data missing' error when loading a shader without valid image. Also, QuArK will now automatically use the checkboard-pattern for those faces.

Revision 1.18  2006/12/26 22:49:05  danielpharos
Splitted the Ed3DFX file into two separate renderers: Software and Glide

Revision 1.17  2006/12/03 23:13:33  danielpharos
Fixed the maximum texture dimension for OpenGL

Revision 1.16  2006/11/30 00:42:32  cdunde
To merge all source files that had changes from DanielPharos branch
to HEAD for QuArK 6.5.0 Beta 1.

Revision 1.15.2.14  2006/11/28 16:18:55  danielpharos
Pushed MapView into the renderers and made OpenGL do (bad) Solid Colors

Revision 1.15.2.13  2006/11/23 20:42:44  danielpharos
Pushed FogColor and FrameColor into the renderer

Revision 1.15.2.12  2006/11/23 20:24:03  danielpharos
Added support for texture-size up to 4096x4096 (Software and Glide excluded)

Revision 1.15.2.11  2006/11/23 20:20:35  danielpharos
Changed the texture unloading method. Removed a redundant call.

Revision 1.15.2.10  2006/11/23 20:19:21  danielpharos
Fixed the access violation when loading a model without a skin

Revision 1.15.2.9  2006/11/23 20:18:11  danielpharos
Removed FOG constant
Texture now stay in memory until they're not used anymore

Revision 1.15.2.8  2006/11/01 22:22:28  danielpharos
BackUp 1 November 2006
Mainly reduce OpenGL memory leak

Revision 1.15  2005/10/16 06:45:53  cdunde
To try and reduce 3D view freeze and
gray out at start when loading textures

Revision 1.14  2005/09/28 10:48:31  peter-b
Revert removal of Log and Header keywords

Revision 1.12  2005/09/21 22:52:01  cdunde
To comment out 1.9 changes, caused editor to lockup on any selection or
input of large maps due to constant  texture transparency processing.

Revision 1.11  2005/09/18 09:42:43  cdunde
To reverse 1.10 changes. Causes slow down
of regeneration of all views and locks up editor.

Revision 1.10  2005/04/01 19:32:45  alexander
more progress indicators (textures and polys)

Revision 1.9  2005/03/14 22:43:32  alexander
textures with alpha channel are rendered transparent in open gl

Revision 1.8  2005/01/11 01:52:59  alexander
added a rendermode byte to the modelinfo structure
initialize the texturemode from the render mode
(rendermode is setup from the form data)

Revision 1.7  2003/09/06 02:21:09  tiglari
added comments to BuildScene

Revision 1.6  2003/03/21 00:12:43  nerdiii
tweaked OpenGL mode to render additive and texture modes as in Half-Life

Revision 1.5  2003/01/29 09:59:27  tiglari
Englishification:
  TFace.prvNbs -> prvVertexCount
  TFace.PrvDescS -> prvVertexTable

Revision 1.4  2001/10/16 23:25:43  tiglari
live pointer hunt

Revision 1.3  2001/03/20 21:38:21  decker_dk
Updated copyright-header

Revision 1.2  2001/01/22 00:11:02  aiv
Beginning of support for sprites in 3d view

Revision 1.1  2000/12/30 15:22:19  decker_dk
- Moved TSceneObject and TTextureManager from Ed3DFX.pas into EdSceneObject.Pas
- Created Ed3DEditors.pas which contains close/free calls
- Created EdDirect3D.pas with minimal contents
}

unit EdSceneObject;

interface

uses Windows, Classes,
     Game, PyMath, qmath, Bezier,
     QkObjects, QkPixelSet, QkComponent, QkMapPoly,
     Glide, Sprite;

 {------------------------}

(*
const
 MinW = 64.0;
 MaxW = 65535.0-128.0;    { Note: constants copied from PyMath3D }
 Minoow = 1.0001/MaxW;
 Maxoow = 0.9999/MinW;
 RFACTOR_1 = 32768*1.1;
 MAX_PITCH = pi/2.1;
*)

 {vfFlagsInvalidate = vfAxis;}

type
 TViewEntities = (veNever, veBoxes, veModels);
 TDisplayMode = (dmEditor, dmPanel, dmWindow, dmFullScreen);
 TDisplayType = (dtXY, dtXZ, dtYZ, dt2D, dt3D);

 POpenGLLightingList = ^LongInt;

 PModel3DInfo = ^TModel3DInfo;
 TModel3DInfo = record
                  Base: QComponent;
                  ModelAlpha: Byte;
                  ModelRendermode: Byte;
                  StaticSkin: Boolean;
                  VertexCount: Integer;
                  Vertices: vec3_p;
                end;
 PSpriteInfo = ^TSpriteInfo;
 TSpriteInfo = record
                  Base: QSprite;
                  Alpha: Byte;
                  VertexCount: Integer;
                  Vertices: vec3_p;
                  Width, Height: Integer;
                end;

 PSurface3D = ^TSurface3D;
 TSurface3D = record
               Normale: vec3_t;          { not defined if GL_TRI_STRIP }
               Dist: scalar_t;           { not defined if GL_TRI_STRIP }
               GlideRadius: scalar_t;
               OpenGLLightList: POpenGLLightingList;
               VertexCount: Integer;    { < 0 for a Bezier's GL_TRI_STRIP (OpenGL only) }
               AlphaColor: FxU32;
               TextureMode: Integer;
              end;

 PGuPalette = ^GuTexPalette;
 PTexture3 = ^TTexture3;
 TTexture3 = record
              SourceTexture: QPixelSet;
              TexW, TexH: Integer;
              LoadedTexW, LoadedTexH: Integer;
              info: GrTexInfo;
              MeanColor: FxU32;
              startAddress, endAddress: FxU32;
              OpenGLName: Integer;
              {Scaled: Boolean;}
              Used: Boolean;
              DefaultAlpha: Byte;
              GuPalette: PGuPalette;
             end;

 PSurfaces = ^TSurfaces;
 TSurfaces = record
              Next: PSurfaces;
              Texture: PTexture3;
              TexName: String;
              SurfSize: Integer;
              Surf, tmp: PSurface3D;
              Transparent: Boolean;
              NumberFaces: Integer;
              NumberTransparentFaces: Integer;
             end;

 {------------------------}

type
 PVertex3D = ^TVertex3D;
 TVertex3D = record
              st: array[0..1] of Single;
              xyz: vec3_t;
             end;

type
 TBuildMode = (bmSoftware, bmGlide, bmOpenGL, bmDirect3D);
 TMapViewMode = (vmWireframe, vmSolidcolor, vmTextured);

 TSceneObject = class
 protected
   Coord: TCoordinates;
   FListSurfaces: PSurfaces;
   PolyFaces, ModelInfo, BezierInfo, SpriteInfo: TList;
   CurrentDisplayMode: TDisplayMode;
   CurrentDisplayType: TDisplayType;
   procedure ClearPList;
   function StartBuildScene({var PW: TPaletteWarning;} var VertexSize: Integer) : TBuildMode; virtual; abstract;
   procedure EndBuildScene; virtual;
   procedure stScalePoly(Texture: PTexture3; var ScaleS, ScaleT: TDouble); virtual; abstract;
   procedure stScaleModel(Skin: PTexture3; var ScaleS, ScaleT: TDouble); virtual; abstract;
   procedure stScaleBezier(Texture: PTexture3; var ScaleS, ScaleT: TDouble); virtual; abstract;
   procedure stScaleSprite(Texture: PTexture3; var ScaleS, ScaleT: TDouble); virtual; abstract;
   procedure WriteVertex(PV: PChar; Source: Pointer; const ns,nt: Single; HiRes: Boolean); virtual; abstract;
   procedure PostBuild(nVertexList, nVertexList2: TList); virtual;
   procedure BuildTexture(Texture: PTexture3); virtual; abstract;
 public
   BlendColor: TColorRef;
   ViewEntities: TViewEntities;
   TranspFactor: Single;
   ErrorMsg: String;
   SolidColors: Boolean;
   TemporaryStuff: TQList;   { anything that should not be freed while the scene is alive }
   FarDistance: TDouble;
   FogDensity: Single;
   ViewMode: TMapViewMode;
   constructor Create(nViewMode: TMapViewMode);
   destructor Destroy; override;
   procedure Init(Wnd: HWnd;
                  nCoord: TCoordinates;
                  DisplayMode: TDisplayMode;
                  DisplayType: TDisplayType;
                  const LibName: String;
                  var AllowsGDI: Boolean); virtual; abstract;
   procedure ClearScene; virtual;
   procedure ClearFrame; virtual;
   procedure SetViewRect(SX, SY: Integer); virtual; abstract;
   procedure BuildScene(DC: HDC; AltTexSrc: QObject);
   procedure Render3DView; virtual; abstract;
   procedure SwapBuffers(Synch: Boolean; DC: HDC); virtual;
   procedure Copy3DView(SX,SY: Integer; DC: HDC); virtual; abstract;
   function ChangeQuality(nQuality: Integer) : Boolean; virtual;
   procedure SetColor(nColor: TColorRef);
   procedure AddPolyFace(const a_PolyFace: PSurface);
   procedure AddModel(const a_Model: PModel3DInfo);
   procedure AddSprite(const a_Sprite: PSpriteInfo);
   procedure AddBezier(const a_Bezier: TBezier);
   procedure AddLight(const Position: TVect; Brightness: Single; Color: TColorRef); virtual;
   property ListSurfaces: PSurfaces read FListSurfaces;
 end;

 {------------------------}

const
 MeanColorNotComputed = FxU32($FFFFFFFF);

type
 TTextureManager = class
 private
   FTextures: TStringList;
   Scenes: TList;
  {CurrentPalettePtr: PGuPalette;}
   PaletteCache: TList;
   DefaultGamePalette: Integer;
   GammaValue: TDouble;
  {Colors: TBitmapInfoColors;
   PaletteLmp: PPaletteLmp;}
   {NoGamma{, WallTexLoaded: Boolean;}
  {TexOpacityInfo: TTexOpacityInfo;}
  {procedure ChangePaletteLmp(Lmp: PPaletteLmp{; PalWarning: TPaletteWarning);}
  {procedure ScaleTexture(w1,h1: Integer; var info: GrTexInfo; Q: QPixelSet);}
   procedure Init();
   procedure FreeTexture(Tex: PTexture3);
 protected
   constructor Create;
 public
   DummyGameInfo: PGameBuffer;
   DownloadedPalette: PGuPalette;
   GammaBuffer: TGeneralGammaBuffer;
   destructor Destroy; override;
   class function GetInstance : TTextureManager;
   class procedure AddScene(Scene: TSceneObject);
   class procedure RemoveScene(Scene: TSceneObject);
   class procedure FreeNonVisibleTextures;
   procedure GetTexture(P: PSurfaces; Load: Boolean; AltTexSrc: QObject{; PalWarning: TPaletteWarning});
   procedure FreeTextures(ForceAll: Boolean);
   procedure ClearTexture(Tex: PTexture3); virtual;
   function CanFree: Boolean;
   function UnifiedPalette: Boolean;
   function ComputeGuPalette(Lmp: PPaletteLmp) : PGuPalette;
   property Textures: TStringList read FTextures;
 end;

function ComputeMeanColor(const PSD: TPixelSetDescription) : FxU32;
function GetTex3Description(const Tex3: TTexture3) : TPixelSetDescription;
function SwapColor(Col: TColorRef) : TColorRef;
function GetLodFor(w: Integer) : GrLOD_t;
procedure GetwhForTexture(const info: GrTexInfo; var w,h: Integer);

 {------------------------}

implementation

uses SysUtils,
     Travail, Quarkx, Setup,
     QkMdlObject, QkTextures, QkImages, QkFileObjects,
     EdOpenGL;
     {EdTListP2;}

const
 cDummyTextureWHSize = 16;

 {------------------------}

constructor TSceneObject.Create(nViewMode: TMapViewMode);
begin
 inherited Create;
 PolyFaces:=TList.Create;
 ModelInfo:=TList.Create;
 BezierInfo:=TList.Create;
 SpriteInfo:=TList.Create;
 TemporaryStuff:=TQList.Create;
 ViewMode:=nViewMode;
end;

destructor TSceneObject.Destroy;
begin
 ClearScene;
 TTextureManager.RemoveScene(Self);
 PolyFaces.Free;
 ModelInfo.Free;
 BezierInfo.Free;
 SpriteInfo.Free;
 TemporaryStuff.Free;
 inherited;
end;

procedure TSceneObject.ClearScene;
var
 I: Integer;
 Ptr: Pointer;
begin
 ClearPList;
 I:=0;
 while I < ModelInfo.Count do
  begin
   Ptr:=ModelInfo[I];
   if Ptr=Nil then
    Inc(I,2)
   else
    begin
     PModel3DInfo(Ptr).Base.AddRef(-1);
     FreeMem(Ptr);
     Inc(I);
    end;
  end;
 I:=0;
 while I < SpriteInfo.Count do
  begin
   Ptr:=SpriteInfo[I];
   if Ptr=Nil then
    Inc(I,2)
   else
    begin
     PSpriteInfo(Ptr).Base.AddRef(-1);
     FreeMem(Ptr);
     Inc(I);
    end;
  end;
 PolyFaces.Clear;
 ModelInfo.Clear;
 SpriteInfo.Clear;
 BezierInfo.Clear;
 TemporaryStuff.Clear;
end;

procedure TSceneObject.ClearPList;
var
 P: PSurfaces;
 Surf: PSurface3D;
 SurfEnd: PChar;
begin
 while Assigned(FListSurfaces) do
  begin
   P:=FListSurfaces;
   FListSurfaces:=P^.Next;
   if Assigned(P^.Surf) then
    begin
     if (self is TGLSceneObject) then
     begin
       Surf:=P^.Surf;
       SurfEnd:=PChar(Surf)+P^.SurfSize;
       while (Surf<SurfEnd) do
        begin
         with Surf^ do
          begin
           Inc(Surf);
           if not (OpenGLLightList = nil) then
            begin
             FreeMem(OpenGLLightList);
             OpenGLLightList := nil;
             {DanielPharos: This should be done in the EdOpenGL,
             then the Vertex3D-type above can also be removed,
             and the link to EdOpenGL.}
            end;
           if VertexCount>=0 then
             Inc(PVertex3D(Surf), VertexCount)
           else
             Inc(PChar(Surf), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
          end;
        end;
      end;
     FreeMem(P^.Surf);
   end;
   Dispose(P);
  end;
end;

procedure TSceneObject.ClearFrame;
begin
end;

function TSceneObject.ChangeQuality(nQuality: Integer) : Boolean;
begin
 Result:=False;
end;

procedure TSceneObject.AddPolyFace(const a_PolyFace: PSurface);
begin
  PolyFaces.Add(a_PolyFace);
end;

procedure TSceneObject.AddModel(const a_Model: PModel3DInfo);
begin
  ModelInfo.Add(a_Model);
end;

procedure TSceneObject.AddSprite(const a_Sprite: PSpriteInfo);
begin
  SpriteInfo.Add(a_Sprite);
end;

procedure TSceneObject.AddBezier(const a_Bezier: TBezier);
begin
  BezierInfo.Add(a_Bezier);
end;

procedure TSceneObject.AddLight(const Position: TVect; Brightness: Single; Color: TColorRef);
begin
end;

procedure TSceneObject.SetColor(nColor: TColorRef);
begin
 BlendColor:=nColor;
 nColor:=SwapColor(nColor);
 PolyFaces.Add(Nil);
 PolyFaces.Add(TObject(nColor));
 ModelInfo.Add(Nil);
 ModelInfo.Add(TObject(nColor));
 BezierInfo.Add(Nil);
 BezierInfo.Add(TObject(nColor));
 SpriteInfo.Add(Nil);
 SpriteInfo.Add(TObject(nColor));
end;

procedure TSceneObject.SwapBuffers;
begin
end;

procedure TSceneObject.EndBuildScene;
begin
end;

procedure TSceneObject.PostBuild(nVertexList, nVertexList2: TList);
begin
end;

procedure TSceneObject.BuildScene(DC: HDC; AltTexSrc: QObject);
const
 cProgressBarWidth = 256;
 cProgressBarHeight = 20;
var
 I, J, K, L: Integer;
 NewTextures, NewTexCount: Integer;
 Surf3D: PSurface3D;
 S,spec: String;
 TexNames: TStringList;
 PList: PSurfaces;
 Dest: PChar;
 PV: PChar;
 TexPt: array[1..3] of TVect;
 DeltaV, v2, v3: TVect;
 CorrW, CorrH, aa, bb, {cc,} dd, dot22, dot23, dot33, mdet: TDouble;
 nVertexList, nVertexList2: TList;
 R: TRect;
 Gauche: Integer;
 TextePreparation: String;
 Brush: HBrush;
 CTris: PComponentTris;
 CVertex: vec3_p;
 v3p: array[0..2] of vec3_p;
 nRadius2, Radius2: FxFloat;
 FirstPoint: TVect;
 CurrentColor, ObjectColor: FxU32;
 NewRenderMode: Integer;
 TextureManager: TTextureManager;
 Mode: TBuildMode;
 VertexSize, VertexSize3m: Integer;
 BezierBuf: TBezierMeshBuf3;
 BControlPoints: TBezierMeshBuf5;
 stBuffer, st: vec_st_p;
{PalWarning: TPaletteWarning;}
  PolySurface: PSurface;
  Model3DInfo: PModel3DInfo;
  OneBezier:   TBezier;
  xSpriteInfo: PSpriteInfo;
  { a PSurfaces object is a list wherein each texturename indexes the list
     of surfaces with that texture.  This routine adds a new texturename
     to the list, or increases the SurfSize associated with
     a previously encountered texturename.  I don't understand what SurfSize
     is for since there seems to be no pointer to the vertices }
  procedure AddSurfaceRef(const a_TexName: String; a_SurfSize: Integer; a_Tmp: Pointer);
  var
    Idx: Integer;
    SurfacesElement: PSurfaces;
  begin
    { try finding if the texturename already have been added to the list }
    if TexNames.Find(a_TexName, Idx) then
    begin
      { it had, now get the associated Surfaces-element }
      SurfacesElement:=PSurfaces(TexNames.Objects[Idx]);
      SurfacesElement^.NumberFaces:=SurfacesElement^.NumberFaces+1;
    end
    else
    begin
      { allocate memory for a TSurfaces-structure, and clear it }
      New(SurfacesElement);
      FillChar(SurfacesElement^, SizeOf(TSurfaces), 0);
      { set the pointer-chain of ListSurfaces }
      SurfacesElement^.Next:=FListSurfaces;
      FListSurfaces:=SurfacesElement;  // Set the new starting point of the chain
      { assign the texturename, and some tmp value }
      SurfacesElement^.TexName:=a_TexName;
      SurfacesElement^.NumberFaces:=1;
      SurfacesElement^.NumberTransparentFaces:=0;
      Pointer(SurfacesElement^.tmp):=a_Tmp;
      { add texturename to list, and associate it with the newly allocated Surfaces-element }
      TexNames.AddObject(a_TexName, TObject(SurfacesElement));
    end;
    { increase the surfacesize of the found/new Surfaces-element }
    Inc(SurfacesElement^.SurfSize, a_SurfSize);
  end;

  procedure SmallBezierTriangle(i1, i2, i3: Integer);
  var
    vp0, vp1, vp2: vec3_p;
    stp: vec_st_p;
    v2, v3, DeltaV: TVect;
    dd, Radius2, nRadius2: TDouble;
  begin
    PV:=PChar(Surf3D)+SizeOf(TSurface3D);

    vp0:=BezierBuf.CP;
    Inc(vp0, i1);
    stp:=st;
    Inc(stp, i1);
    WriteVertex(PV, vp0, stp^.s * CorrW, stp^.t * CorrH, False);
    Inc(PV, VertexSize);

    vp1:=BezierBuf.CP;
    Inc(vp1, i2);
    stp:=st;
    Inc(stp, i2);
    WriteVertex(PV, vp1, stp^.s * CorrW, stp^.t * CorrH, False);
    Inc(PV, VertexSize);

    vp2:=BezierBuf.CP;
    Inc(vp2, i3);
    stp:=st;
    Inc(stp, i3);
    WriteVertex(PV, vp2, stp^.s * CorrW, stp^.t * CorrH, False);
    Inc(PV, VertexSize);

    v2.X:=vp1^[0] - vp0^[0];
    v2.Y:=vp1^[1] - vp0^[1];
    v2.Z:=vp1^[2] - vp0^[2];

    v3.X:=vp2^[0] - vp0^[0];
    v3.Y:=vp2^[1] - vp0^[1];
    v3.Z:=vp2^[2] - vp0^[2];

    DeltaV:=Cross(v3, v2);

    dd:=Sqr(DeltaV.X)+Sqr(DeltaV.Y)+Sqr(DeltaV.Z);
    if dd<rien then
      Dec(PList^.SurfSize, VertexSize3m)
    else
    begin
      dd:=1/Sqrt(dd);

      Radius2 :=Sqr(v2.X)+Sqr(v2.Y)+Sqr(v2.Z);
      nRadius2:=Sqr(v3.X)+Sqr(v3.Y)+Sqr(v3.Z);

      with Surf3D^ do
      begin
        Normale[0]:=DeltaV.X*dd;
        Normale[1]:=DeltaV.Y*dd;
        Normale[2]:=DeltaV.Z*dd;

        Dist:=vp0^[0]*Normale[0] + vp0^[1]*Normale[1] + vp0^[2]*Normale[2];

        OpenGLLightList:=nil;
        if nRadius2>Radius2 then
          GlideRadius:=Sqrt(nRadius2)
        else
          GlideRadius:=Sqrt(Radius2);

        VertexCount:=3;
        AlphaColor:=ObjectColor;
      end;

      Inc(PChar(Surf3D), VertexSize3m);
    end;
  end;

begin
 ClearPList;
 Mode:=StartBuildScene({PalWarning,} VertexSize);
 TextureManager:=TTextureManager.GetInstance;
 VertexSize3m:=SizeOf(TSurface3D)+3*VertexSize;
 TexNames:=TStringList.Create;
 try  {begin outer try block - almost whole method}
   TexNames.Sorted:=True;

   if (Mode=bmSoftware) or (Mode=bmGlide) then
   begin
     nVertexList:=TList.Create;
     nVertexList2:=TList.Create;
   end
   else
   begin
     nVertexList:=Nil;
     nVertexList2:=Nil;
   end;

   try  {begin build FListSurfaces, also nVertexList(2), used only in software and Glide mode}
     I:=0;   // process the faces of the polys
     while I<PolyFaces.Count do
     begin
       PolySurface:=PSurface(PolyFaces[I]);
       if PolySurface=Nil then
       begin
         { If it points to a nil-pointer, then the next element is a color
           element, which we have to ignore. Thats why we increment with 1 here }
         Inc(I);
       end
       else
       begin // wtf, we're keeping track of texture name and total size of needed vertexes, but not the vertexes themselves
         AddSurfaceRef(PolySurface^.F.NomTex, SizeOf(TSurface3D) + PolySurface^.prvVertexCount * VertexSize, Nil);
         if nVertexList<>Nil then    // only in software and Glide mode
           for J:=0 to PolySurface^.prvVertexCount-1 do
             nVertexList.Add(PolySurface^.prvVertexTable[J]);
       end;

       Inc(I); { Increment to get the next element }
     end;

     //here the model is drawm
     I:=0;  // process the models, haven't looked into this one yet
     while I<ModelInfo.Count do
     begin
       Model3DInfo:=PModel3DInfo(ModelInfo[I]);
       if Model3DInfo=Nil then
       begin
         { If it points to a nil-pointer, then the next element is a color
           element, which we have to ignore. Thats why we increment with 1 here }
         Inc(I);
       end
       else
       begin
         J:=Model3DInfo^.Base.Triangles(CTris);
         AddSurfaceRef(Model3DInfo^.Base.GetSkinDescr(Model3DInfo^.StaticSkin), J * VertexSize3m, Model3DInfo^.Base.CurrentSkin);
         if nVertexList2<>Nil then
         begin
           CVertex:=Model3DInfo^.Vertices;
           for J:=0 to Model3DInfo^.VertexCount-1 do
           begin
             nVertexList2.Add(CVertex);
             Inc(CVertex);
           end;
         end;
       end;

       Inc(I); { Increment to get the next element }
     end;

     I:=0;  // process the sprites, haven't looked into this one yet/
     while I<SpriteInfo.Count do
     begin
       xSpriteInfo:=PSpriteInfo(SpriteInfo[I]);
       if xSpriteInfo=Nil then
       begin
         { If it points to a nil-pointer, then the next element is a color
           element, which we have to ignore. Thats why we increment with 1 here }
         Inc(I);
       end
       else
       begin
         AddSurfaceRef(xSpriteInfo^.Base.GetSkinDescr, 2 * VertexSize3m, xSpriteInfo^.Base.Skin0);
         if nVertexList2<>Nil then
         begin
           CVertex:=xSpriteInfo^.Vertices;
           for J:=0 to xSpriteInfo^.VertexCount-1 do
           begin
             nVertexList2.Add(CVertex);
             Inc(CVertex);
           end;
         end;
       end;

       Inc(I); { Increment to get the next element }
     end;

     I:=0; // process the beziers, haven't looked into this one yet
     while I<BezierInfo.Count do
     begin
       OneBezier:=TBezier(BezierInfo[I]);
       if OneBezier=Nil then
       begin
         { If it points to a nil-pointer, then the next element is a color
           element, which we have to ignore. Thats why we increment with 1 }
         Inc(I);
       end
       else
       begin
         with OneBezier do
         begin
           BezierBuf:=GetMeshCache;
           if Mode<>bmOpenGL then
           begin
             AddSurfaceRef(NomTex, ((BezierBuf.H-1) * (BezierBuf.W-1) * 2) * VertexSize3m, Nil);
             for J:=1 to BezierBuf.W*BezierBuf.H do
             begin
               nVertexList2.Add(BezierBuf.CP);
               Inc(BezierBuf.CP);
             end;
           end
           else
           begin
             { bmOpenGL }
             AddSurfaceRef(NomTex, (BezierBuf.H-1) * (SizeOf(TSurface3D) + 2 * BezierBuf.W * (VertexSize + SizeOf(vec3_t))), Nil);
           end;
         end;
       end;

       Inc(I); { Increment to get the next element }
     end;

     PostBuild(nVertexList, nVertexList2);  // only does anything in software and Glide mode
   finally
     if (nVertexList <> nil) then
       nVertexList.Free;
     nVertexList:=nil;

     if (nVertexList2 <> nil) then
       nVertexList2.Free;
     nVertexList2:=nil;
   end;  {end build FSurfaceList}

   NewTextures:=0; {rebuild old textures}
   PList:=FListSurfaces;
   while Assigned(PList) do
   begin
     if PList^.Texture=Nil then
     begin
       TextureManager.GetTexture(PList, False, Nil{, PalWarning});
       if PList^.Texture=Nil then
         Inc(NewTextures)
       else
         BuildTexture(PList^.Texture);
     end;
     PList:=PList^.Next;
   end;

   TextureManager.FreeTextures(False);   { free unused textures }

   { build load new textures }
   if NewTextures>0 then
   begin
     Gauche:=0;
     Brush:=0;

     // needed to backup to version 1.09, due to version 1.10 causing constant editor lockups.
     { Setup a progress-bar, depending on what type of device-context
       thats been rendering to }
     if DC=HDC(-1) then
       ProgressIndicatorStart(5454, NewTextures)
     else
     begin
       if DC<>0 then
       begin
         GetClipBox(DC, R);
         Gauche:=(R.Right+R.Left-cProgressBarWidth) div 2;
         R.Left:=Gauche;
         R.Right:=Gauche+cProgressBarWidth;
         R.Top:=(R.Top+R.Bottom-cProgressBarHeight) div 2;
         R.Bottom:=R.Top+cProgressBarHeight;
         SetBkColor(DC, $FFFFFF);
         SetTextColor(DC, $000000);
         TextePreparation:=LoadStr1(5454);
         ExtTextOut(DC, Gauche+38, R.Top+3, eto_Opaque, @R, PChar(TextePreparation), Length(TextePreparation), Nil);
         InflateRect(R, +1, +1);
         FrameRect(DC, R, GetStockObject(Black_brush));
         InflateRect(R, -1, -1);
         GdiFlush;
         R.Right:=R.Left;
         Brush:=CreateSolidBrush($FF0000);
       end;
     end;

     { begin building the textures one by one, while updating the
       progress-bar at the same time }
     try
       NewTexCount:=0;
       PList:=FListSurfaces;
       while Assigned(PList) do
       begin
         if PList^.Texture=Nil then
         begin
           { update progressbar }
           if DC=HDC(-1) then
           begin
             ProgressIndicatorIncrement;
           end
           else
           begin
             if DC<>0 then
             begin
               Inc(NewTexCount);
               R.Right:=Gauche + MulDiv(cProgressBarWidth, NewTexCount, NewTextures);
               FillRect(DC, R, Brush);
               R.Left:=R.Right;
             end;
           end;

           TextureManager.GetTexture(PList, True, AltTexSrc{, PalWarning});
           BuildTexture(PList^.Texture);
         end;

         PList:=PList^.Next;
       end;

     finally
       { clean up the progress-bar }
       if DC=HDC(-1) then
         ProgressIndicatorStop;
       if Brush<>0 then
         DeleteObject(Brush);
       EndBuildScene;
     end;
   end;  {end build and load new textures}

   { do something major with the polys }
   CurrentColor:=$FFFFFF; // what does the CurrentColor do?
   I:=0;
   while I<PolyFaces.Count do
   begin
     PolySurface:=PSurface(PolyFaces[I]);
     if PolySurface=Nil then
     begin
       CurrentColor:=FxU32(PolyFaces[I+1]);
       Inc(I,2);
     end
     else
     begin
       with PolySurface^ do
       begin
         { find the texturename again }
         S:=F.NomTex;
         if not TexNames.Find(S, J) then
          {$IFDEF Debug}Raise InternalE('TexNames.Find'){$ENDIF};

         { get the associated Surfaces-element for this texturename }
         PList:=PSurfaces(TexNames.Objects[J]);

         { setup the Surf3D to point to an area in the dereference of Surfaces-element }
         if PList^.Surf=Nil then
         begin
           GetMem(PList^.Surf, PList^.SurfSize);
           Surf3D:=PList^.Surf;
         end
         else
           Surf3D:=PList^.tmp;

         { initialize this Surf3D area with info from the face and its PSurface}
         with Surf3D^ do
         begin
           with F.Normale do
           begin
             Normale[0]:=X;
             Normale[1]:=Y;
             Normale[2]:=Z;
           end;

           Dist:=F.Dist;
           VertexCount:=prvVertexCount;
           OpenGLLightList:=nil;

           AlphaColor:=CurrentColor or (254 shl 24);
           TextureMode:=0;
           // if the texture has alpha channel its probably transparent
           if Assigned(PList^.Texture^.SourceTexture) then
           begin
             TextureMode:=2;
             case PList^.Texture^.SourceTexture.Description.AlphaBits of
             psaDefault: PList^.Transparent:=False;
             psaNoAlpha: PList^.Transparent:=False;
             psaGlobalAlpha: PList^.Transparent:=False;
             psa8bpp: PList^.Transparent:=True;
             end;
           end;

           AlphaColor:=CurrentColor or (F.GetFaceOpacity(PList^.Texture^.DefaultAlpha).Value shl 24);
           if (AlphaColor and $FF000000) <> $FF000000 then
             PList^.NumberTransparentFaces:=PList^.NumberTransparentFaces+1;

         end;

         if not F.GetThreePointsT(TexPt[1], TexPt[2], TexPt[3]) then
           Raise InternalE('BuildScene - empty face');

       (*TexPt[2].X:=TexPt[2].X-TexPt[1].X;
         TexPt[2].Y:=TexPt[2].Y-TexPt[1].Y;
         TexPt[2].Z:=TexPt[2].Z-TexPt[1].Z;
         TexPt[3].X:=TexPt[3].X-TexPt[1].X;
         TexPt[3].Y:=TexPt[3].Y-TexPt[1].Y;
         TexPt[3].Z:=TexPt[3].Z-TexPt[1].Z;

         {...must inverse the equations...}

         CorrW:=(EchelleTexture*256)/(PTex^.TexW*(Sqr(TexPt[2].X)+Sqr(TexPt[2].Y)+Sqr(TexPt[2].Z)));
         CorrH:=(-EchelleTexture*256)/(PTex^.TexH*(Sqr(TexPt[3].X)+Sqr(TexPt[3].Y)+Sqr(TexPt[3].Z)));
         TexPt[2].X:=TexPt[2].X*CorrW;
         TexPt[2].Y:=TexPt[2].Y*CorrW;
         TexPt[2].Z:=TexPt[2].Z*CorrW;
         TexPt[3].X:=TexPt[3].X*CorrH;
         TexPt[3].Y:=TexPt[3].Y*CorrH;
         TexPt[3].Z:=TexPt[3].Z*CorrH;*)

         stScalePoly(PList^.Texture, CorrW, CorrH);

         TexPt[2].X:=(TexPt[2].X-TexPt[1].X)*CorrW;
         TexPt[2].Y:=(TexPt[2].Y-TexPt[1].Y)*CorrW;
         TexPt[2].Z:=(TexPt[2].Z-TexPt[1].Z)*CorrW;

         TexPt[3].X:=(TexPt[3].X-TexPt[1].X)*CorrH;
         TexPt[3].Y:=(TexPt[3].Y-TexPt[1].Y)*CorrH;
         TexPt[3].Z:=(TexPt[3].Z-TexPt[1].Z)*CorrH;

         { we must inverse the equations for X, Y, Z :
            s*TexPt[2]+t*TexPt[3] = DeltaV

            s = v2.DeltaV
            t = v3.DeltaV

            (v2.DeltaV)*TexPt[2]+(v3.DeltaV)*TexPt[3] = DeltaV

            v2.TexPt[2] = 1    v3.TexPt[2] = 0
            v2.TexPt[3] = 0    v3.TexPt[3] = 1

            v2=a*TexPt[2]+b*TexPt[3]    v3=c*TexPt[2]+d*TexPt[3]

            a*TexPt[2].TexPt[2] + b*TexPt[3].TexPt[2] = 1
            a*TexPt[2].TexPt[3] + b*TexPt[3].TexPt[3] = 0
            c*TexPt[2].TexPt[2] + d*TexPt[3].TexPt[2] = 0
            c*TexPt[2].TexPt[3] + d*TexPt[3].TexPt[3] = 1
         }

         dot22:=Dot(TexPt[2], TexPt[2]);
         dot23:=Dot(TexPt[2], TexPt[3]);
         dot33:=Dot(TexPt[3], TexPt[3]);

         mdet:=dot22*dot33-dot23*dot23;
         if Abs(mdet)<1E-8 then
         begin
           aa:=0;
           bb:=0;
          {cc:=0;}
           dd:=0;
         end
         else
         begin
           mdet:=1/mdet;
           aa:= mdet*dot33;
           bb:=-mdet*dot23;
          {cc:=-mdet*dot23;}
           dd:= mdet*dot22;
         end;

         v2.X:= aa   *TexPt[2].X + bb*TexPt[3].X;
         v2.Y:= aa   *TexPt[2].Y + bb*TexPt[3].Y;
         v2.Z:= aa   *TexPt[2].Z + bb*TexPt[3].Z;

         v3.X:={cc}bb*TexPt[2].X + dd*TexPt[3].X;
         v3.Y:={cc}bb*TexPt[2].Y + dd*TexPt[3].Y;
         v3.Z:={cc}bb*TexPt[2].Z + dd*TexPt[3].Z;

         Radius2:=0;
         PV:=PChar(Surf3D) + SizeOf(TSurface3D);
         for J:=0 to prvVertexCount-1 do
         begin
           with prvVertexTable[J]^.P do
           begin
             if J=0 then
             begin
               FirstPoint.X:=X;
               FirstPoint.Y:=Y;
               FirstPoint.Z:=Z;
             end
             else
             begin
               nRadius2:=Sqr(FirstPoint.X-X)+Sqr(FirstPoint.Y-Y)+Sqr(FirstPoint.Z-Z);
               if nRadius2>Radius2 then
                 Radius2:=nRadius2;
             end;

             DeltaV.X:=X-TexPt[1].X;
             DeltaV.Y:=Y-TexPt[1].Y;
             DeltaV.Z:=Z-TexPt[1].Z;
           end;

           WriteVertex(PV, prvVertexTable[J], Dot(v2, DeltaV), Dot(v3, DeltaV), True);

           Inc(PV, VertexSize);
         end;

         if (Mode=bmSoftware) or (Mode=bmGlide) then
           Surf3D^.GlideRadius:=Sqrt(Radius2);

         PList^.tmp:=PSurface3D(PV);
       end;

       Inc(I);
     end;
   end;

   CurrentColor:=$FFFFFF;  {same deal for models}
   I:=0;
   while I<ModelInfo.Count do
   begin
     Model3DInfo:=PModel3DInfo(ModelInfo[I]);
     if Model3DInfo=Nil then
     begin
       CurrentColor:=FxU32(ModelInfo[I+1]);
       Inc(I,2);
     end
     else
     begin
       with Model3DInfo^ do
       begin
         if not TexNames.Find(Base.GetSkinDescr(StaticSkin), J) then
          {$IFDEF Debug}Raise InternalE('TexNames.Find.2'){$ENDIF};

         PList:=PSurfaces(TexNames.Objects[J]);
         if PList^.Surf=Nil then
         begin
           GetMem(PList^.Surf, PList^.SurfSize);
           Surf3D:=PList^.Surf;
         end
         else
           Surf3D:=PList^.tmp;

         if ModelAlpha<>255 then
           PList^.NumberTransparentFaces:=PList^.NumberTransparentFaces+1;

         stScaleModel(PList^.Texture, CorrW, CorrH);

         for J:=1 to Base.Triangles(CTris) do
         begin
           PV:=PChar(Surf3D)+SizeOf(TSurface3D);
           for L:=0 to 2 do
           begin
             with CTris^[L] do
             begin
               if VertexNo >= VertexCount then
                 Raise EError(5667);

               v3p[L]:=Vertices;
               Inc(v3p[L], VertexNo);

               WriteVertex(PV, v3p[L], st.s * CorrW, st.t * CorrH, False);

               Inc(PV, VertexSize);
             end;
           end;

           Inc(CTris);

           v2.X:=v3p[1]^[0] - v3p[0]^[0];
           v2.Y:=v3p[1]^[1] - v3p[0]^[1];
           v2.Z:=v3p[1]^[2] - v3p[0]^[2];

           v3.X:=v3p[2]^[0] - v3p[0]^[0];
           v3.Y:=v3p[2]^[1] - v3p[0]^[1];
           v3.Z:=v3p[2]^[2] - v3p[0]^[2];

           DeltaV:=Cross(v3, v2);
           dd:=Sqr(DeltaV.X)+Sqr(DeltaV.Y)+Sqr(DeltaV.Z);
           if dd<rien then
             Dec(PList^.SurfSize, VertexSize3m)
           else
           begin
             dd:=1/Sqrt(dd);

             Radius2 :=Sqr(v2.X)+Sqr(v2.Y)+Sqr(v2.Z);
             nRadius2:=Sqr(v3.X)+Sqr(v3.Y)+Sqr(v3.Z);

             with Surf3D^ do
             begin
               Normale[0]:=DeltaV.X*dd;
               Normale[1]:=DeltaV.Y*dd;
               Normale[2]:=DeltaV.Z*dd;

               Dist:=v3p[0]^[0]*Normale[0] + v3p[0]^[1]*Normale[1] + v3p[0]^[2]*Normale[2];
               OpenGLLightList:=nil;

               if (Mode=bmSoftware) or (Mode=bmGlide) then
               begin
                 if nRadius2>Radius2 then
                   GlideRadius:=Sqrt(nRadius2)
                 else
                   GlideRadius:=Sqrt(Radius2);
               end;

               VertexCount:=3;
               Texturemode:= ModelRenderMode;
               AlphaColor:=CurrentColor or (ModelAlpha shl 24);

               // if the texture has alpha channel its probably transparent
               if Assigned(PList^.Texture^.SourceTexture) then
               begin
                 TextureMode:=2;
                 case PList^.Texture^.SourceTexture.Description.AlphaBits of
                 psaDefault: PList^.Transparent:=False;
                 psaNoAlpha: PList^.Transparent:=False;
                 psaGlobalAlpha: PList^.Transparent:=False;
                 psa8bpp: PList^.Transparent:=True;
                 end;
               end;
             end;

             Inc(PChar(Surf3D), VertexSize3m);
           end;
         end;

         PList^.tmp:=Surf3D;
       end;

       Inc(I);
     end;
   end;

   CurrentColor:=$FFFFFF;  { and sprites }
   I:=0;
   while I<SpriteInfo.Count do
   begin
     xSpriteInfo:=PSpriteInfo(SpriteInfo[I]);
     if xSpriteInfo=Nil then
     begin
       CurrentColor:=FxU32(SpriteInfo[I+1]);
       Inc(I,2);
     end
     else
     begin
       with xSpriteInfo^ do
       begin
         if not TexNames.Find(Base.GetSkinDescr, J) then
          {$IFDEF Debug}Raise InternalE('TexNames.Find.4'){$ENDIF};

         PList:=PSurfaces(TexNames.Objects[J]);
         if PList^.Surf=Nil then
         begin
           GetMem(PList^.Surf, PList^.SurfSize);
           Surf3D:=PList^.Surf;
         end
         else
           Surf3D:=PList^.tmp;

         if Alpha<>255 then
           PList^.NumberTransparentFaces:=PList^.NumberTransparentFaces+1;

         stScaleSprite(PList^.Texture, CorrW, CorrH);

         for J:=1 to Base.Triangles(CTris) do
         begin
           PV:=PChar(Surf3D)+SizeOf(TSurface3D);
           for L:=0 to 2 do
           begin
             with CTris^[L] do
             begin
               if VertexNo >= VertexCount then
                 Raise EError(5667);

               v3p[L]:=Vertices;
               Inc(v3p[L], VertexNo);

               WriteVertex(PV, v3p[L], st.s * CorrW, st.t * CorrH, False);

               Inc(PV, VertexSize);
             end;
           end;

           Inc(CTris);

           v2.X:=v3p[1]^[0] - v3p[0]^[0];
           v2.Y:=v3p[1]^[1] - v3p[0]^[1];
           v2.Z:=v3p[1]^[2] - v3p[0]^[2];

           v3.X:=v3p[2]^[0] - v3p[0]^[0];
           v3.Y:=v3p[2]^[1] - v3p[0]^[1];
           v3.Z:=v3p[2]^[2] - v3p[0]^[2];

           DeltaV:=Cross(v3, v2);
           dd:=Sqr(DeltaV.X)+Sqr(DeltaV.Y)+Sqr(DeltaV.Z);
           if dd<rien then
             Dec(PList^.SurfSize, VertexSize3m)
           else
           begin
             dd:=1/Sqrt(dd);

             Radius2 :=Sqr(v2.X)+Sqr(v2.Y)+Sqr(v2.Z);
             nRadius2:=Sqr(v3.X)+Sqr(v3.Y)+Sqr(v3.Z);

             with Surf3D^ do
             begin
               Normale[0]:=DeltaV.X*dd;
               Normale[1]:=DeltaV.Y*dd;
               Normale[2]:=DeltaV.Z*dd;

               Dist:=v3p[0]^[0]*Normale[0] + v3p[0]^[1]*Normale[1] + v3p[0]^[2]*Normale[2];
               OpenGLLightList:=nil;

               if (Mode=bmSoftware) or (Mode=bmGlide) then
               begin
                 if nRadius2>Radius2 then
                   GlideRadius:=Sqrt(nRadius2)
                 else
                   GlideRadius:=Sqrt(Radius2);
               end;

               VertexCount:=3;
               AlphaColor:=CurrentColor or (Alpha shl 24);
               
               // if the texture has alpha channel its probably transparent
               if Assigned(PList^.Texture^.SourceTexture) then
               begin
                 TextureMode:=2;
                 case PList^.Texture^.SourceTexture.Description.AlphaBits of
                 psaDefault: PList^.Transparent:=False;
                 psaNoAlpha: PList^.Transparent:=False;
                 psaGlobalAlpha: PList^.Transparent:=False;
                 psa8bpp: PList^.Transparent:=True;
                 end;
               end;
             end;

             Inc(PChar(Surf3D), VertexSize3m);
           end;
         end;

         PList^.tmp:=Surf3D;
       end;

       Inc(I);
     end;
   end;

   CurrentColor:=$FFFFFF;  { and beziers }
   I:=0;
   while I<BezierInfo.Count do
   begin
     OneBezier:=TBezier(BezierInfo[I]);
     if OneBezier=Nil then
     begin
       CurrentColor:=FxU32(BezierInfo[I+1]);
       Inc(I,2);
     end
     else
     begin
       with OneBezier do
       begin
         S:=NomTex;
         if not TexNames.Find(S, J) then
          {$IFDEF Debug}Raise InternalE('TexNames.Find.3'){$ENDIF};

         PList:=PSurfaces(TexNames.Objects[J]);
         if PList^.Surf=Nil then
         begin
           GetMem(PList^.Surf, PList^.SurfSize);
           Surf3D:=PList^.Surf;
         end
         else
           Surf3D:=PList^.tmp;

         with GetFaceOpacity(PList^.Texture^.DefaultAlpha) do
         begin
           ObjectColor:=CurrentColor or (Value shl 24);
           NewRenderMode:=Mode;
         end;

         if ObjectColor and $FF000000 <> $FF000000 then
           PList^.NumberTransparentFaces:=PList^.NumberTransparentFaces+1;

         stScaleBezier(PList^.Texture, CorrW, CorrH);
         BezierBuf:=GetMeshCache;
         BControlPoints:=ControlPoints;
         GetMem(stBuffer, BezierBuf.W*BezierBuf.H*SizeOf(vec_st_t));
         try
           st:=stBuffer;
           for L:=0 to BezierBuf.H-1 do
           begin
             for K:=0 to BezierBuf.W-1 do
             begin
               st^:=TriangleSTCoordinates(BControlPoints, K, L);
               Inc(st);
             end;
           end;

           st:=stBuffer;
           if (Mode=bmSoftware) or (Mode=bmGlide) then
           begin
             for L:=0 to BezierBuf.H-2 do
             begin
               for K:=0 to BezierBuf.W-2 do
               begin
                 SmallBezierTriangle(0, BezierBuf.W, 1);
                 SmallBezierTriangle(BezierBuf.W, BezierBuf.W+1, 1);
                 Inc(BezierBuf.CP);
                 Inc(st);
               end;

               Inc(BezierBuf.CP);
               Inc(st);
             end;
           end
           else
           begin
             { bmOpenGL }
             for L:=0 to BezierBuf.H-2 do
             begin
               with Surf3D^ do
               begin
                 OpenGLLightList:=nil;
                 VertexCount:=-(2*BezierBuf.W);
                 AlphaColor:=ObjectColor;
                 TextureMode:=NewRenderMode;

                 // if the texture has alpha channel its probably transparent
                 if Assigned(PList^.Texture^.SourceTexture) then
                 begin
                   TextureMode:=2;
                   case PList^.Texture^.SourceTexture.Description.AlphaBits of
                   psaDefault: PList^.Transparent:=False;
                   psaNoAlpha: PList^.Transparent:=False;
                   psaGlobalAlpha: PList^.Transparent:=False;
                   psa8bpp: PList^.Transparent:=True;
                   end;
                 end;
               end;

               PV:=PChar(Surf3D)+SizeOf(TSurface3D);
               bb:=L*(1/BezierMeshCnt);

               for K:=0 to BezierBuf.W-1 do
               begin
                 aa:=K*(1/BezierMeshCnt);
                 WriteVertex(PV, BezierBuf.CP, st^.s*CorrW, st^.t*CorrH, False);

                 Inc(PV, VertexSize);
                 vec3_p(PV)^:=OrthogonalVector(aa, bb);
                 Inc(vec3_p(PV));
                 Inc(BezierBuf.CP, BezierBuf.W);
                 Inc(st, BezierBuf.W);
                 WriteVertex(PV, BezierBuf.CP, st^.s*CorrW, st^.t*CorrH, False);

                 Inc(PV, VertexSize);
                 vec3_p(PV)^:=OrthogonalVector(aa, bb+1/BezierMeshCnt);
                 Inc(vec3_p(PV));
                 Dec(BezierBuf.CP, BezierBuf.W-1);
                 Dec(st, BezierBuf.W-1);
               end;

               PChar(Surf3D):=PChar(PV);
             end;
           end;
         finally
           FreeMem(stBuffer);
         end;

         PList^.tmp:=PSurface3D(Surf3D);
       end;

       Inc(I);
     end;
   end;
   EndBuildScene;
 finally
   TexNames.Free;
 end;
 {/end outer try block}
 PolyFaces.Clear;
 EndBuildScene;
end;

 {------------------------}

var
 TextureManager: TTextureManager = Nil;

class function TTextureManager.GetInstance : TTextureManager;
begin
 if TextureManager=Nil then
  TextureManager:=TTextureManager.Create;
 GetInstance:=TextureManager;
end;

class procedure TTextureManager.AddScene(Scene: TSceneObject);
begin
 with GetInstance do
  begin
   Init();
   if Scenes.IndexOf(Scene)<0 then
    Scenes.Add(Scene);
  end;
end;

class procedure TTextureManager.RemoveScene(Scene: TSceneObject);
begin
 if TextureManager<>Nil then
  begin
   TextureManager.Scenes.Remove(Scene);
   TextureManager.FreeTextures(False);
  end;
end;

constructor TTextureManager.Create;
begin
 Scenes:=TList.Create;
 FTextures:=TStringList.Create;
 FTextures.Sorted:=True;
 GammaValue:=-1;
end;

procedure TTextureManager.FreeTexture(Tex: PTexture3);
begin
 ClearTexture(Tex);
 FreeMem(Tex^.info.data);
 Tex^.SourceTexture.AddRef(-1);
 Dispose(Tex);
end;

destructor TTextureManager.Destroy;
var
 I: Integer;
begin
 {$IFDEF Debug}
 if not CanFree then
  raise InternalE('texturemanager.destroy: still in use');
 {$ENDIF}
 for I:=Textures.Count-1 downto 0 do
  FreeTexture(PTexture3(Textures.Objects[I]));
 FTextures.Free;
 if PaletteCache<>Nil then
  begin
   for I:=PaletteCache.Count-1 downto 0 do
    Dispose(PGuPalette(PaletteCache[I]));
   PaletteCache.Free;
  end;
 DeleteGameBuffer(DummyGameInfo);
 Scenes.Free;
end;

function TTextureManager.ComputeGuPalette(Lmp: PPaletteLmp) : PGuPalette;
var
 nPalette: GuTexPalette;
 I: Integer;
begin
 if (Lmp=@DummyGameInfo^.PaletteLmp)
 and (PaletteCache<>Nil) and (DefaultGamePalette>=0) then
  begin  { fast way out for unified-palette games }
   Result:=PGuPalette(PaletteCache[DefaultGamePalette]);
   Exit;
  end;

 for I:=0 to 255 do
  nPalette[I]:=(GammaBuffer[Lmp^[I,0]] shl 16)
            or (GammaBuffer[Lmp^[I,1]] shl 8)
            or (GammaBuffer[Lmp^[I,2]]);
 if PaletteCache=Nil then
  begin
   PaletteCache:=TList.Create;
   DefaultGamePalette:=-1;
  end
 else
  for I:=PaletteCache.Count-1 downto 0 do
   if CompareMem(PaletteCache[I], @nPalette, SizeOf(nPalette)) then
    begin
     if Lmp=@DummyGameInfo^.PaletteLmp then
      DefaultGamePalette:=I;
     Result:=PGuPalette(PaletteCache[I]);
     Exit;
    end;
 New(Result);
 Result^:=nPalette;
 PaletteCache.Add(Result);
end;

procedure TTextureManager.FreeTextures(ForceAll: Boolean);
var
 I: Integer;
 Tex: PTexture3;
 nPaletteCache: TList;
 P: PSurfaces;
begin
 DownloadedPalette:=Nil;
{CurrentPalettePtr:=Nil;}
{PaletteLmp:=Nil;}
 for I:=0 to Textures.Count-1 do
  begin
   with PTexture3(Textures.Objects[I])^ do
    begin
     Used:=false;
    end;
  end;
 if not ForceAll then
  begin
   for I:=0 to Scenes.Count-1 do
    begin
     P:=TSceneObject(Scenes[I]).ListSurfaces;
     while Assigned(P) do
      begin
       if P^.Texture<>Nil then
        P^.Texture^.Used:=true;
       P:=P^.Next;
      end;
    end;
  end;
 nPaletteCache:=Nil;
 for I:=Textures.Count-1 downto 0 do
  begin
   Tex:=PTexture3(Textures.Objects[I]);
   if (Tex^.Used=false) then
    begin
     FreeTexture(Tex);
     Textures.Delete(I);
    end
   else
    if Tex^.GuPalette<>Nil then
     begin
      if nPaletteCache=Nil then
       nPaletteCache:=TList.Create;
      if nPaletteCache.IndexOf(Tex^.GuPalette)<0 then
       nPaletteCache.Add(Tex^.GuPalette);
     end;
  end;
 if PaletteCache<>Nil then
  begin
   for I:=PaletteCache.Count-1 downto 0 do
    if (nPaletteCache=Nil) or (nPaletteCache.IndexOf(PaletteCache[I])<0) then
     Dispose(PGuPalette(PaletteCache[I]));
   PaletteCache.Free;
  end;
 PaletteCache:=nPaletteCache;
 DefaultGamePalette:=-1;
end;

function TTextureManager.CanFree;
begin
 Result:=Scenes.Count=0;
end;

{$IFDEF xxxNeverxxx}
procedure TTextureManager.ScaleTexture(w1,h1: Integer; var info: GrTexInfo; Q: QPixelSet);
var
 PSD: TPixelSetDescription;
 I, MemSize: Integer;
{S: String;}
{Source,} Dest: PChar;
{Scan: Integer;}
begin
(*if Q<>Nil then
  begin
   with Q.BuildQ1Header do
    begin
     Size.X:=W;
     Size.Y:=H;
    end;
   Scan:=w1;
  end
 else
  begin
   Size:=Image1.GetSize;
   Scan:=-w1;
  end;

 if Q<>Nil then
  begin
   S:=Q.GetTexImage(0);
   Source:=PChar(S);
  end
 else
  begin
   Image1.NotTrueColor;  { FIXME }
   Source:=Image1.GetImagePtr1;
  end;*)
*
 Q.Description(PSD);

 Dest:=PChar(info.data);
* MemSize:=w1*h1;
 for I:=0 to 3 do
  begin
*   {Resample(@Colors, Source, @Colors, Dest, Size.X, Size.Y, Size.X, w1, h1, Scan);}
   Resample(PSD.Colors, PSD.Base.Data, @Colors, Dest,
     PSD.Base.Size.X, PSD.Base.Size.Y, PSD.Base.ScanLine, w1, h1, w1);
   if info.largeLod=info.smallLod then Break;
*   Inc(Dest, MemSize);
   MemSize:=MemSize div 4;
   w1:=w1 div 2;
   h1:=h1 div 2;
*   {Scan:=Scan div 2;}
  end;
end;
{$ENDIF}
(*var
 SrcDC: HDC;
 Src, Bmp1: HBitmap;
 Size: TPoint;
 I, MemSize: Integer;
 S: String;
 Dest: PChar;
 Format: TMQIDF;
begin
 if Q<>Nil then
  begin
   with Q.BuildQ1Header do
    begin
     Size.X:=W;
     Size.Y:=H;
    end;
   Format:=dfBottomUpTexture;
  end
 else
  begin
   Size:=Image1.GetSize;
   Format:=dfTextureFormat;
  end;

  { makes a true color bitmap for the source image to be scaled }
 SrcDC:=CreateCompatibleDC(0);
 Src:=CreateBitmap(Size.X, Size.Y, 1, 24, Nil);
 Bmp1:=SelectObject(SrcDC, Src);
 try
  with GameInfo^.BmpInfo.bmiHeader do
   begin
    biWidth:=Size.X;
    biHeight:=Size.Y;
   end;
  SelectPalette(SrcDC, GameInfo^.Palette, False);
  RealizePalette(SrcDC);
  if Q<>Nil then
   S:=Q.GetTexImage(0)
  else
   S:=Image1.GetImage;
  SetDIBitsToDevice(SrcDC, 0, 0,
   Size.X, Size.Y, 0,0,0,Size.Y, PChar(S),
   GameInfo^.BmpInfo, dib_RGB_Colors);

  Dest:=PChar(info.data);
  MemSize:=w1*h1;
  for I:=0 to 3 do
   begin
    S:='';
    S:=MakeQuakeImageData(mjAny, SrcDC, Size.X, Size.Y, w1 shr I, h1 shr I, Format);
    Move(PChar(S)^, Dest^, MemSize);
    if info.largeLod=info.smallLod then Break;
    Inc(Dest, MemSize);
    MemSize:=MemSize div 4;
   end;

 finally
  SelectObject(SrcDC, Bmp1);
  DeleteObject(Src);
  DeleteDC(SrcDC);
 end;
end;*)

procedure TTextureManager.GetTexture(P: PSurfaces; Load: Boolean; AltTexSrc: QObject{; PalWarning: TPaletteWarning});
var
 {J, MemSize,} w, h, max: Integer;
 {Direct: Boolean;}
 PTex: PTexture3;
 Q: QPixelSet;
{Image1: QImage;
 SkinType: TSkinType;}
 S: String;
{Src, Dest: PChar;}
{Lmp: PPaletteLmp;}
 Size: TPoint;
 TextureMaxDimension: Integer;
begin
 if Textures.Find(P^.TexName, w) then
  PTex:=PTexture3(Textures.Objects[w])
 else
  begin
   if not Load then
    Exit;
   New(PTex);
   FillChar(PTex^, SizeOf(TTexture3), 0);
   PTex^.startAddress:=GR_NULL_MIPMAP_HANDLE;
   Textures.AddObject(P^.TexName, TObject(PTex));
   Q:=Nil;
  {Image1:=Nil;
   SkinType:=stNone;}
   S:=P^.TexName;
   PTex^.DefaultAlpha:=255;
   if S<>'' then
    if S[1]=':' then
     begin  { loading model skin }
      Pointer(Q):=P^.tmp;
      if Q<>Nil then
       try
        Q.Acces;
       except
        Q:=Nil;
       end;
      if Q=Nil then
       GlobalWarning(FmtLoadStr1(5588, [S]));
     end
    else
     begin  { loading texture }
      Q:=GlobalFindTexture(S, AltTexSrc);
      if Q<>Nil then
       try
        Q:=Q.LoadPixelSet;
        if Q is QTextureFile then
         PTex^.DefaultAlpha:=QTextureFile(Q).GetTexOpacity{(TexOpacityInfo)};
       except
        Q:=Nil;
       end;
      if Q=Nil then
       GlobalWarning(FmtLoadStr1(5588, [S]));
     end;
   if Q=Nil then
    begin
     {PSD.Format:=psf8bpp;}
     Size.X:=cDummyTextureWHSize;
     Size.Y:=cDummyTextureWHSize;
    end
   else
    begin
     try
      Size:=Q.GetSize;
      Q.AddRef(+1);
     except
      Size.X:=cDummyTextureWHSize;
      Size.Y:=cDummyTextureWHSize;
      Q:=nil;
     end;
    end;

   { the maximum width/height dimension, to reduce memory-consumption if possible }
   try
     TextureMaxDimension:=1 shl StrToInt(SetupSubSet(ssGeneral, '3D view').Specifics.Values['TextureMaxDimension']);
   except
     TextureMaxDimension:=1 shl 8; { default value is 256 }
   end;
   if (TextureMaxDimension < 8) then
     TextureMaxDimension:=8; { minimum value is 8 }
   if (TextureMaxDimension > 4096) then
     TextureMaxDimension:=4096; { maximum value is 4096 }

   PTex^.SourceTexture:=Q;
   PTex^.TexW:=Size.X;
   PTex^.TexH:=Size.Y;
   w:=8;
   while (w<TextureMaxDimension) and (w<Size.X) do
    w:=w*2;
   h:=8;
   while (h<TextureMaxDimension) and (h<Size.Y) do
    h:=h*2;
   {Direct:=(w=Size.X) and (h=Size.Y);}
   if w=h then
    PTex^.info.aspectRatio:=GR_ASPECT_1x1
   else
    if w>h then
     if w>4*h then
      begin
       if w>8*h then
        begin
         {Direct:=False;}
         h:=w div 8;
        end;
       PTex^.info.aspectRatio:=GR_ASPECT_8x1;
      end
     else
      if w=4*h then
       PTex^.info.aspectRatio:=GR_ASPECT_4x1
      else
       PTex^.info.aspectRatio:=GR_ASPECT_2x1
    else
     if h>4*w then
      begin
       if h>8*w then
        begin
         {Direct:=False;}
         w:=h div 8;
        end;
       PTex^.info.aspectRatio:=GR_ASPECT_1x8;
      end
     else
      if h=4*w then
       PTex^.info.aspectRatio:=GR_ASPECT_1x4
      else
       PTex^.info.aspectRatio:=GR_ASPECT_1x2;
   if w>h then
    max:=w
   else
    max:=h;
   PTex^.LoadedTexW:=w;
   PTex^.LoadedTexH:=h;
 (*MemSize:=w*h;

   if PSD.Format=psf24bpp then
    begin
     MemSize:=MemSize*2;
     PTex^.info.format:=GR_TEXFMT_RGB_565;
     PTex^.GuPalette:=Nil;
    end
   else
    begin
     if Q=Nil then
      begin
       if CurrentPalettePtr=Nil then
        ChangePaletteLmp(@DummyGameInfo^.PaletteLmp, Nil);
      end
     else
      ChangePaletteLmp(PSD.ColorPalette, PalWarning);
     PTex^.info.format:=GR_TEXFMT_P_8;
     PTex^.GuPalette:=CurrentPalettePtr;
    end;
*)
   with PTex^.info do
    begin
     largeLod:=GetLodFor(max);
     if Q is QTextureFile then
      begin
       smallLod:=GetLodFor(max div 8);
       {J:=MemSize*(64+16+4+1) div 64;}
      end
     else
      begin
       smallLod:=largeLod;
       {J:=MemSize;}
      end;
   (*GetMem(data, J);
     if Direct then
      begin
       Dest:=PChar(data);
       if Q=Nil then
        begin
         for J:=0 to MemSize-1 do
          begin       { build a checkerboard texture image
           if (J and (cDummyTextureWHSize div 2)) = ((J div cDummyTextureWHSize) and (cDummyTextureWHSize div 2)) then
            Dest^:=#0
           else
            Dest^:=#255;
           Inc(Dest);
          end;
        end
       else
        begin
         Src:=PSD.StartPointer;
         if Src<>...
         for J:=1 to h do
          begin
           Move(
           Inc(Src, PSD.ScanLine);
           Inc(Dest,
      end

      case SkinType of
       stTexture:
         begin
          Dest:=PChar(data);
          for J:=0 to 3 do
           begin
            Move(PChar(Q.GetTexImage(J))^, Dest^, MemSize);
            Inc(Dest, MemSize);
            MemSize:=MemSize div 4;
           end;
         end;
       stSkin:
         begin
          Image1.NotTrueColor;  { FIXME
          Image1.GetImageData1(data^, MemSize);
         end;
       else
         begin
          Dest:=PChar(data);
          for J:=0 to MemSize-1 do
           begin       { build a checkerboard texture image
            if (J and (cDummyTextureWHSize div 2)) = ((J div cDummyTextureWHSize) and (cDummyTextureWHSize div 2)) then
             Dest^:=#0
            else
             Dest^:=#255;
            Inc(Dest);
           end;
         end;
      end
     else
      begin
       { $IFDEF Debug
       if SkinType=stNone then Raise InternalE('Indirect SkinType stNone');
       { $ENDIF
       if Q<>Nil then
        ScaleTexture(w,h, PTex^.info, Q)
       else
        ScaleTexture(w,h, PTex^.info, Image1);
       PTex^.Scaled:=True;
      end;*)
    end;
   PTex^.MeanColor:=MeanColorNotComputed; {ComputeMeanColor(PChar(data), MemSize);}
  end;
 P^.Texture:=PTex;
end;

procedure TTextureManager.Init({FullScreen: Boolean});
(*var
 I: Integer;*)
begin
 DownloadedPalette:=Nil;
 DeleteGameBuffer(DummyGameInfo);
 DummyGameInfo:=Nil;
 DummyGameInfo:=DuplicateGameBuffer(GameBuffer(mjAny));
 {TexOpacityInfo.Loaded:=False;}
 (*if FullScreen xor NoGamma then
  begin
   for I:=Textures.Count-1 downto 0 do
    with PTexture3(Textures.Objects[I])^ do
     GuPalette:=Nil;
   ...
  end;*)
 if InitGeneralGammaBuffer(GammaBuffer, GammaValue) then
  FreeTextures(True);  { gamma value changed, free all textures (to be reloaded) }
{NoGamma:=FullScreen;}
{if DummyGameInfo^.UnifiedPalette then
  ChangePaletteLmp(@DummyGameInfo^.PaletteLmp, Nil);}
end;

function TTextureManager.UnifiedPalette: Boolean;
begin
 Result:=DummyGameInfo^.UnifiedPalette;
end;

class procedure TTextureManager.FreeNonVisibleTextures;
begin
 if TextureManager<>Nil then
  begin
   TextureManager.FreeTextures(False);
   if TextureManager.CanFree then
    begin
     TextureManager.Free;
     TextureManager:=Nil;
    end;
  end;
end;

procedure TTextureManager.ClearTexture(Tex: PTexture3);
begin
end;

 {------------------------}

function GetTex3Description(const Tex3: TTexture3) : TPixelSetDescription;
var
 J: Integer;
 Dest: PChar;
begin
 if Tex3.SourceTexture<>Nil then
  Result:=Tex3.SourceTexture.Description
 else
  begin
   Result.Init;
   Result.Format:=psf8bpp;
   Result.Palette:=pspFixed;
   Result.Size.X:=cDummyTextureWHSize;
   Result.Size.Y:=cDummyTextureWHSize;
   Result.ScanLine:=cDummyTextureWHSize;
   Result.ColorPalette:=@(TTextureManager.GetInstance.DummyGameInfo^.PaletteLmp);
   Result.AllocData;
   Dest:=PChar(Result.Data);
   { build a checkerboard texture image }
   for J:=0 to cDummyTextureWHSize * cDummyTextureWHSize - 1 do
    begin
     if (J and (cDummyTextureWHSize div 2)) = ((J div cDummyTextureWHSize) and (cDummyTextureWHSize div 2)) then
      Dest^:=#0
     else
      Dest^:=#255;
     Inc(Dest);
    end;
  end;
end;

function ComputeMeanColor(const PSD: TPixelSetDescription) : FxU32;
var
 re, gr, bl: LongInt;
 re2, gr2, bl2: LongInt;
 pl: array[0..255] of record pr, pg, pb: LongInt; end;
 I, J: Integer;
 P: PChar;
begin
 re:=0;
 gr:=0;
 bl:=0;
 case PSD.Format of
  psf8bpp: begin
            P:=PChar(PSD.ColorPalette);
            for I:=0 to 255 do
             with pl[I] do
              begin
               pr:=LongInt(Ord(P^));
               Inc(P);
               pg:=LongInt(Ord(P^));
               Inc(P);
               pb:=LongInt(Ord(P^));
               Inc(P);
              end;
            P:=PSD.StartPointer;
            for J:=1 to PSD.Size.Y do
             begin
              re2:=0;
              gr2:=0;
              bl2:=0;
              for I:=0 to PSD.Size.X-1 do
               with pl[Ord(P[I])] do
                begin
                 Inc(re2, pr);
                 Inc(gr2, pg);
                 Inc(bl2, pb);
                end;
              Inc(re,re2 div PSD.Size.X);
              Inc(gr,gr2 div PSD.Size.X);
              Inc(bl,bl2 div PSD.Size.X);
              Inc(P, PSD.ScanLine);
             end;
           end;
  psf24bpp: begin
             P:=PSD.StartPointer;
             for J:=1 to PSD.Size.Y do
              begin
               re2:=0;
               gr2:=0;
               bl2:=0;
               I:=PSD.Size.X*3;
               while I>0 do
                begin
                 Dec(I);
                 Inc(bl2, LongInt(Ord(P[I])));
                 Dec(I);
                 Inc(gr2, LongInt(Ord(P[I])));
                 Dec(I);
                 Inc(re2, LongInt(Ord(P[I])));
                end;
               Inc(re,re2 div PSD.Size.X);
               Inc(gr,gr2 div PSD.Size.X);
               Inc(bl,bl2 div PSD.Size.X);
               Inc(P, PSD.ScanLine);
              end;
            end;
 else
  begin
   Result:=0;
   Exit;
  end;
 end;
 Result:=(bl div PSD.Size.Y)
     or ((gr div PSD.Size.Y) shl 8)
     or ((re div PSD.Size.Y) shl 16);
end;

function SwapColor(Col: TColorRef) : TColorRef;
begin
 Result:=((Col and $FF0000) shr 16)
       or (Col and $00FF00)
      or ((Col and $0000FF) shl 16);
end;

function GetLodFor(w: Integer) : GrLOD_t;
begin
 case w of
  4096: Result:=GR_LOD_256;  {Daniel: The software and 3DFX don't support higher LODs}
  2048: Result:=GR_LOD_256;
  1024: Result:=GR_LOD_256;
  512:  Result:=GR_LOD_256;
  256:  Result:=GR_LOD_256;
  128:  Result:=GR_LOD_128;
  64:   Result:=GR_LOD_64;
  32:   Result:=GR_LOD_32;
  16:   Result:=GR_LOD_16;
  8:    Result:=GR_LOD_8;
  4:    Result:=GR_LOD_4;
  2:    Result:=GR_LOD_2;
  1:    Result:=GR_LOD_1;
 else
  Raise InternalE('Bad LOD');
 end;
end;

procedure GetwhForTexture(const info: GrTexInfo; var w,h: Integer);
begin
 case info.largeLod of
  GR_LOD_256: w:=256;
  GR_LOD_128: w:=128;
  GR_LOD_64:  w:=64;
  GR_LOD_32:  w:=32;
  GR_LOD_16:  w:=16;
  GR_LOD_8:   w:=8;
  GR_LOD_4:   w:=4;
  GR_LOD_2:   w:=2;
  GR_LOD_1:   w:=1;
 else
  Raise InternalE('Bad reverse LOD');
 end;

 h:=w;

 case info.aspectratio of
  GR_ASPECT_8x1: h:=h div 8;
  GR_ASPECT_4x1: h:=h div 4;
  GR_ASPECT_2x1: h:=h div 2;
  GR_ASPECT_1x2: w:=w div 2;
  GR_ASPECT_1x4: w:=w div 4;
  GR_ASPECT_1x8: w:=w div 8;
 end;
end;

initialization

finalization
 TextureManager.Free;
end.
