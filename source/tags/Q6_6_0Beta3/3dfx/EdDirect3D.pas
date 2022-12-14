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

{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.38  2009/07/15 10:38:06  danielpharos
Updated website link.

Revision 1.37  2009/02/21 17:06:18  danielpharos
Changed all source files to use CRLF text format, updated copyright and GPL text.

Revision 1.36  2009/02/14 16:30:19  danielpharos
Compacted some code a bit by using SetupGameSet.

Revision 1.35  2008/12/04 12:14:00  danielpharos
Fixed a redraw-clipping problem, removed a redundant file and cleaned-up the constructor of the EdSceneObjects.

Revision 1.34  2008/12/01 22:34:03  danielpharos
Cleaned up the clipping routines.

Revision 1.33  2008/11/20 23:45:50  danielpharos
Big update to renderers: mostly cleanup, and stabilized Direct3D a bit more.

Revision 1.32  2008/11/14 00:39:54  danielpharos
Fixed a few variable types and fixed the coloring of faces not working properly in OpenGL and giving the wrong color in Glide.

Revision 1.31  2008/10/18 15:09:59  danielpharos
Small clean-up.

Revision 1.30  2008/10/02 18:55:54  danielpharos
Don't render when not in wp_paint handling.

Revision 1.29  2008/10/02 12:34:13  danielpharos
Small correction to ViewWnd and ViewDC handling.

Revision 1.28  2008/10/02 12:23:27  danielpharos
Major improvements to HWnd and HDC handling. This should fix all kinds of OpenGL problems.

Revision 1.27  2008/09/06 15:57:29  danielpharos
Moved exception code into separate file.

Revision 1.26  2007/09/23 21:44:30  danielpharos
Switch DirectX to dynamic explicit loading: it should work on WinNT4 again! Also fixed the access violations that popped up when loading of DirectX went wrong.

Revision 1.25  2007/09/23 21:04:31  danielpharos
Add Desktop Window Manager calls to disable Desktop Composition on Vista. This should fix/workaround corrupted OpenGL and DirectX viewports.

Revision 1.24  2007/09/04 14:38:12  danielpharos
Fix the white-line erasing after a tooltip disappears in OpenGL. Also fix an issue with quality settings in software mode.

Revision 1.23  2007/08/05 19:53:30  danielpharos
Fix an infinite loop due to rubbish transparency code.

Revision 1.22  2007/06/06 22:31:19  danielpharos
Fix a (recent introduced) problem with OpenGL not drawing anymore.

Revision 1.21  2007/06/04 19:20:24  danielpharos
Window pull-out now works with DirectX too. Fixed an access violation on shutdown after using DirectX.

Revision 1.20  2007/05/09 17:51:55  danielpharos
Another big improvement. Stability and speed should be much better now.

Revision 1.19  2007/05/09 16:14:43  danielpharos
Big update to the DirectX renderer. Fade color should now display. Stability is still an issue however.

Revision 1.18  2007/04/03 13:08:54  danielpharos
Added a back buffer format selection option.

Revision 1.17  2007/03/29 21:02:08  danielpharos
Made a Stencil Buffer Bits selection option

Revision 1.16  2007/03/29 20:18:32  danielpharos
DirectX interfaces should be unloading correctly now.
Also added a bit of fog code.

Revision 1.15  2007/03/29 17:27:25  danielpharos
Updated the Direct3D renderer. It should now initialize correctly.

Revision 1.14  2007/03/26 21:13:14  danielpharos
Big change to OpenGL. Fixed a huge memory leak. Better handling of shared display lists.

Revision 1.13  2007/03/22 20:53:18  danielpharos
Improved tracking of the target DC. Should fix a few grey screens.

Revision 1.12  2007/03/17 14:32:38  danielpharos
Moved some dictionary entries around, moved some error messages into the dictionary and added several new error messages to improve feedback to the user.

Revision 1.11  2007/02/06 13:08:47  danielpharos
Fixes for transparency. It should now work (more or less) correctly in all renderers that support it.

Revision 1.10  2007/02/02 21:09:55  danielpharos
Rearranged the layout of the Direct3D file

Revision 1.9  2007/01/31 15:11:21  danielpharos
HUGH changes: OpenGL lighting, OpenGL transparency, OpenGL culling, OpenGL speedups, and several smaller changes

Revision 1.8  2006/11/30 00:42:32  cdunde
To merge all source files that had changes from DanielPharos branch
to HEAD for QuArK 6.5.0 Beta 1.

Revision 1.7.2.12  2006/11/23 20:36:55  danielpharos
Pushed FogColor and FrameColor into the renderer

Revision 1.7.2.11  2006/11/23 20:33:09  danielpharos
Cleaned up the Init procedure to match OpenGL better

Revision 1.7.2.10  2006/11/23 20:30:34  danielpharos
Added counter to make sure the renderers only unload when they're not used anymore

Revision 1.7.2.9  2006/11/23 20:29:25  danielpharos
Removed now obsolete FreeDirect3DEditor procedure

Revision 1.7.2.8  2006/11/01 22:22:28  danielpharos
BackUp 1 November 2006
Mainly reduce OpenGL memory leak

Revision 1.7  2005/09/28 10:48:31  peter-b
Revert removal of Log and Header keywords

Revision 1.5  2003/08/31 02:53:47  silverpaladin
Removing hints and warnings that appear when Direct3d Compiler directive is used.

Revision 1.4  2001/03/20 21:38:21  decker_dk
Updated copyright-header

Revision 1.3  2001/02/01 20:45:45  decker_dk
Only include Direct3D support-code, if QUARK_DIRECT3D is defined.

Revision 1.2  2001/01/22 00:11:02  aiv
Beginning of support for sprites in 3d view

Revision 1.1  2000/12/30 15:22:19  decker_dk
- Moved TSceneObject and TTextureManager from Ed3DFX.pas into EdSceneObject.Pas
- Created Ed3DEditors.pas which contains close/free calls
- Created EdDirect3D.pas with minimal contents
}

unit EdDirect3D;

interface

uses Windows, Classes,
     qmath, PyMath, PyMath3D,
     DX9, Direct3D9,
     EdSceneObject;

type
  TDirect3DSceneObject = class(TSceneObject)
  private
    Fog: Boolean;
    Transparency: Boolean;
    Lighting: Boolean;
    Culling: Boolean;
    Dithering: Boolean;
    Direct3DLoaded: Boolean;
    DWMLoaded: Boolean;
    MapLimit: TVect;
    MapLimitSmallest: Double;
    pPresParm: D3DPRESENT_PARAMETERS;
    DXFogColor: D3DColor;
    LightingQuality: Integer;
    SwapChain: IDirect3DSwapChain9;
    DepthStencilSurface: IDirect3DSurface9;
    procedure RenderPList(PList: PSurfaces; TransparentFaces: Boolean; SourceCoord: TCoordinates);
  protected
    ScreenResized: Boolean;
    m_CurrentAlpha, m_CurrentColor: TColorRef;
    ScreenX, ScreenY: Integer;
    function StartBuildScene(var VertexSize: Integer) : TBuildMode; override;
    procedure EndBuildScene; override;
    procedure stScalePoly(Texture: PTexture3; var ScaleS, ScaleT: TDouble); override;
    procedure stScaleModel(Skin: PTexture3; var ScaleS, ScaleT: TDouble); override;
    procedure stScaleSprite(Skin: PTexture3; var ScaleS, ScaleT: TDouble); override;
    procedure stScaleBezier(Texture: PTexture3; var ScaleS, ScaleT: TDouble); override;
    procedure WriteVertex(PV: PChar; Source: Pointer; const ns,nt: Single; HiRes: Boolean); override;
    procedure ReleaseResources;
    procedure BuildTexture(Texture: PTexture3); override;
    procedure ChangedViewWnd; override;
    function CheckDeviceState : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Init(nCoord: TCoordinates;
                   nDisplayMode: TDisplayMode;
                   nDisplayType: TDisplayType;
                   nRenderMode: TRenderMode;
                   const LibName: String;
                   var AllowsGDI: Boolean); override;
    procedure ClearScene; override;
 (*
    procedure ClearFrame; override;
 *)
    procedure SetViewSize(SX, SY: Integer); override;
    procedure Render3DView; override;
    procedure Copy3DView; override;
 (*
    procedure SwapBuffers(Synch: Boolean); override;
    procedure AddLight(const Position: TVect; Brightness: Single; Color: TColorRef); override;
 *)
    function ChangeQuality(nQuality: Integer) : Boolean; override;
  end;

type  { this is the data shared by all existing TDirect3DSceneObjects }
  TDirect3DState = class
  public
    procedure ReleaseAllResources;
    procedure ClearTexture(Tex: PTexture3);
  end;

var
  qrkDXState: TDirect3DState;

 {------------------------}

implementation

uses Logging, Quarkx, QkExceptions, Setup, SysUtils, DWM, SystemDetails,
     QkObjects, QkMapPoly, DXTypes, D3DX9, Direct3D, DXErr9;

type
 PVertex3D = ^TVertex3D;
 TVertex3D = PD3DLVertex;

 {------------------------}

procedure UnpackColor(Color: TColorRef; var v: array of float);
begin
  v[0]:=((Color       ) and $FF) * (1/255.0);
  v[1]:=((Color shr  8) and $FF) * (1/255.0);
  v[2]:=((Color shr 16) and $FF) * (1/255.0);
  v[3]:=((Color shr 24) and $FF) * (1/255.0);
end;

procedure TDirect3DSceneObject.SetViewSize(SX, SY: Integer);
begin
  if SX<1 then SX:=1;
  if SY<1 then SY:=1;
  if (SX<>ScreenX) or (SY<>ScreenY) then
  begin
    ScreenResized := True;

    ScreenX:=SX;
    ScreenY:=SY;
  end;
end;

procedure TDirect3DSceneObject.ChangedViewWnd;
begin
  ScreenResized := True;
  //DanielPharos: Do we need to do this?

  pPresParm.hDeviceWindow:=ViewWnd;
end;

function TDirect3DSceneObject.ChangeQuality(nQuality: Integer) : Boolean;
begin
 if not ((nQuality=0) or (nQuality=1) or (nQuality=2)) then
 begin
  Result:=False;
  Exit;
 end;
 Result:=LightingQuality<>nQuality;
 LightingQuality:=nQuality;
end;

procedure TDirect3DSceneObject.stScalePoly(Texture: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  with Texture^ do
  begin
    ScaleS:=TexW*( 1/EchelleTexture);
    ScaleT:=TexH*(-1/EchelleTexture);
  end;
end;

procedure TDirect3DSceneObject.stScaleModel(Skin: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  with Skin^ do
  begin
    ScaleS:=1/TexW;
    ScaleT:=1/TexH;
  end;
end;

procedure TDirect3DSceneObject.stScaleSprite(Skin: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  with Skin^ do
  begin
    ScaleS:=1/TexW;
    ScaleT:=1/TexH;
  end;
end;

procedure TDirect3DSceneObject.stScaleBezier(Texture: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  ScaleS:=1;
  ScaleT:=1;
end;

procedure TDirect3DSceneObject.WriteVertex(PV: PChar; Source: Pointer; const ns,nt: Single; HiRes: Boolean);
begin
{  if HiRes then
  begin
    PVertex3D(PV)^.x := PVect(Source)^.X;
    PVertex3D(PV)^.y := PVect(Source)^.Y;
    PVertex3D(PV)^.z := PVect(Source)^.Z;
  end
  else
  begin
    PVertex3D(PV)^.x := vec3_p(Source)^[0];
    PVertex3D(PV)^.y := vec3_p(Source)^[1];
    PVertex3D(PV)^.z := vec3_p(Source)^[2];
  end;

  PVertex3D(PV)^.tu := ns;
  PVertex3D(PV)^.tv := nt;}


  {PVertex3D(PV)^.color := D3DXColorToDWord(D3DXColor(random, random, random, 0));}

end;

constructor TDirect3DSceneObject.Create;
begin
  inherited;
  SwapChain:=nil;
  DepthStencilSurface:=nil;
end;

procedure TDirect3DSceneObject.ReleaseResources;
begin
  //FIXME: Set the RenderBackBuffer to something else, just in case...
  SwapChain:=nil;
  DepthStencilSurface:=nil;
end;

destructor TDirect3DSceneObject.Destroy;
begin
  ReleaseResources;
  inherited;
  if Direct3DLoaded then
    UnloadDirect3D;
  if DWMLoaded then
  begin
    DwmEnableComposition(DWM_EC_ENABLECOMPOSITION);
    UnloadDWM;
  end;
end;

procedure TDirect3DSceneObject.Init(nCoord: TCoordinates;
                                    nDisplayMode: TDisplayMode;
                                    nDisplayType: TDisplayType;
                                    nRenderMode: TRenderMode;
                                    const LibName: String;
                                    var AllowsGDI: Boolean);
var
  nFogColor: array[0..3] of float;
  FogColor{, FrameColor}: TColorRef;
  Setup: QObject;
  l_Res: HResult;
  WindowRect: TRect;
begin
  ClearScene;

  DisplayMode:=nDisplayMode;
  DisplayType:=nDisplayType;
  RenderMode:=nRenderMode;

  if CheckWindowsVista then
  begin
    if not DWMLoaded then
    begin
      DWMLoaded:=LoadDWM;
      if not DWMLoaded then
        Log(LOG_WARNING, LoadStr1(6013));
    end;
    if DWMLoaded then
      DwmEnableComposition(DWM_EC_DISABLECOMPOSITION);
  end;

  //Is the Direct3D object already loaded?
  if Direct3DLoaded = False then
  begin
    if LibName='' then
      Raise EError(6001);
    //Try to load the Direct3D object
    if not LoadDirect3D() then
      Raise EErrorFmt(6402, [GetLastError]);
    Direct3DLoaded := true;
  end;
  if (DisplayMode=dmFullScreen) then
   Raise InternalE(LoadStr1(6420));

  Coord:=nCoord;
  TTextureManager.AddScene(Self);

  try
   MapLimit:=SetupGameSet.VectSpec['MapLimit'];
  except
   MapLimit:=SetupSubSet(ssMap, 'Display').VectSpec['MapLimit'];
  end;
  if (MapLimit.X=OriginVectorZero.X) and (MapLimit.Y=OriginVectorZero.Y) and (MapLimit.Z=OriginVectorZero.Z) then
   begin
    MapLimit.X:=4096;
    MapLimit.Y:=4096;
    MapLimit.Z:=4096;
   end;
  if (MapLimit.X < MapLimit.Y) then
   begin
    if (MapLimit.X < MapLimit.Z) then
     MapLimitSmallest:=MapLimit.X
    else
     MapLimitSmallest:=MapLimit.Z;
   end
  else
   begin
    if (MapLimit.Y < MapLimit.Z) then
     MapLimitSmallest:=MapLimit.Y
    else
     MapLimitSmallest:=MapLimit.Z;
   end;

  Setup:=SetupSubSet(ssGeneral, '3D View');
  if (DisplayMode=dmWindow) or (DisplayMode=dmFullScreen) then
  begin
    FarDistance:=Setup.GetFloatSpec('FarDistance', 1500);
    if (FarDistance>MapLimitSmallest) then
      FarDistance:=MapLimitSmallest;
  end
  else
  begin
    FarDistance:=MapLimitSmallest;
  end;
  FogDensity:=Setup.GetFloatSpec('FogDensity', 1);
  FogColor:=Setup.IntSpec['FogColor'];
  {FrameColor:=Setup.IntSpec['FrameColor'];}
  Setup:=SetupSubSet(ssGeneral, 'DirectX');
  if (DisplayMode=dmWindow) or (DisplayMode=dmFullScreen) then
  begin
    Fog:=Setup.Specifics.Values['Fog']<>'';
    Transparency:=Setup.Specifics.Values['Transparency']<>'';
    Lighting:=Setup.Specifics.Values['Lights']<>'';
    Culling:=Setup.Specifics.Values['Culling']<>'';
  end
  else
  begin
    Fog:=False;
    Transparency:=False;
    Lighting:=False;
    Culling:=False;
  end;
  Dithering:=Setup.Specifics.Values['Dither']<>'';

  if (ScreenX = 0) or (ScreenY = 0) then
  begin
    if GetWindowRect(ViewWnd, WindowRect)=false then
      Raise EErrorFmt(6400, ['GetWindowRect']);
    ScreenX:=WindowRect.Right-WindowRect.Left;
    ScreenY:=WindowRect.Bottom-WindowRect.Top;
  end;

  CopyMemory(@pPresParm, @PresParm, SizeOf(D3DPRESENT_PARAMETERS));
  pPresParm.BackBufferWidth:=ScreenX;
  pPresParm.BackBufferHeight:=ScreenY;
  if (DisplayMode=dmFullScreen) then
  begin
    ppresparm.SwapEffect:=D3DSWAPEFFECT_DISCARD;
  end
  else
  begin
    ppresparm.SwapEffect:=D3DSWAPEFFECT_COPY;
  end;
  pPresParm.hDeviceWindow:=ViewWnd;

  //Using CreateAdditionalSwapChain to create new chains will automatically share
  //textures and other resources between views.
  l_Res:=D3DDevice.CreateAdditionalSwapChain(pPresParm, SwapChain);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['CreateAdditionalSwapChain', DXGetErrorString9(l_Res)]);

  l_Res:=D3DDevice.CreateDepthStencilSurface(ScreenX, ScreenY, pPresParm.AutoDepthStencilFormat, pPresParm.MultiSampleType, pPresParm.MultiSampleQuality, false, DepthStencilSurface, nil);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['CreateDepthStencilSurface', DXGetErrorString9(l_Res)]);

  UnpackColor(FogColor, nFogColor);

  //These calls are for the SwapChain!!!

  DXFogColor:=D3DXColorToDWord(D3DXColor(nFogColor[0],nFogColor[1],nFogColor[2],nFogColor[3]));
  D3DDevice.SetRenderState(D3DRS_ZENABLE, 1);  //D3DZB_TRUE := 1
  if Fog then
  begin
    D3DDevice.SetRenderState(D3DRS_FOGENABLE, 1);  //True := 1
    D3DDevice.SetRenderState(D3DRS_FOGTABLEMODE, 2);  //D3DFOG_EXP2 := 2
   {D3DDevice.SetRenderState(D3DRS_FOGSTART, FarDistance * kDistFarToShort);
    D3DDevice.SetRenderState(D3DRS_FOGEND, FarDistance);}
//DanielPharos: Got to find a conversion...
//    D3DDevice.SetRenderState(D3DRS_FOGDENSITY, FogDensity/FarDistance);
//DanielPharos: Got to make sure the color is send in the same format
//    D3DDevice.SetRenderState(D3DRS_FOGCOLOR, FogColor);
  end
  else
    D3DDevice.SetRenderState(D3DRS_FOGENABLE, 0);  //False := 0

  if Lighting then
  begin
    D3DDevice.SetRenderState(D3DRS_LIGHTING, 1);  //True := 1
    D3DDevice.SetRenderState(D3DRS_AMBIENT, D3DXColorToDWord(D3DXColor(255, 255, 255, 0))); //FIXME!
  end
  else
    D3DDevice.SetRenderState(D3DRS_LIGHTING, 0);  //False := 0

  if Transparency then
    D3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, 1) //FIXME!
  else
    D3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, 0); //FIXME!

  if Culling then
    D3DDevice.SetRenderState(D3DRS_CULLMODE, 1) //FIXME!
  else
    D3DDevice.SetRenderState(D3DRS_CULLMODE, 0); //FIXME!

  if Dithering then
    D3DDevice.SetRenderState(D3DRS_DITHERENABLE, 1) //FIXME!
  else
    D3DDevice.SetRenderState(D3DRS_DITHERENABLE, 0) //FIXME!

{  // Create material
  FillChar(l_Material, SizeOf(l_Material), 0);
  l_Material.dcvDiffuse  := TD3DColorValue(D3DXColor(0.00, 0.00, 0.00, 0.00));
  l_Material.dcvAmbient  := TD3DColorValue(D3DXColor(1.00, 1.00, 1.00, 0.00));
  l_Material.dcvSpecular := TD3DColorValue(D3DXColor(0.00, 0.00, 0.00, 0.00));
  l_Material.dvPower     := 100.0;
  D3DDevice.SetMaterial(l_Material);   }

end;

function TDirect3DSceneObject.CheckDeviceState : Boolean;
var
  l_Res: HResult;
  NeedReset: Boolean;
begin
  Result:=false;
  NeedReset:=false;
  l_Res:=D3DDevice.TestCooperativeLevel;
  case l_Res of
  D3D_OK: ;
  D3DERR_DEVICELOST: Exit;  //Device lost and can't be restored at this time.
  D3DERR_DEVICENOTRESET: NeedReset:=True;  //Device can be recovered
  D3DERR_DRIVERINTERNALERROR: raise EError(6410);  //Big problem!
  end;

  if not NeedReset and not ScreenResized then
  begin
    Result:=True;
    Exit;
  end;

  //FIXME: The first parameter isn't necessarily 0!
  l_Res:=D3DDevice.SetRenderTarget(0, OrigBackBuffer);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['SetRenderTarget', DXGetErrorString9(l_Res)]);

  l_Res:=D3DDevice.SetDepthStencilSurface(nil);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['SetDepthStencilSurface', DXGetErrorString9(l_Res)]);

  if NeedReset then
  begin
    qrkDXState.ReleaseAllResources;

    OrigBackBuffer:=nil;

    l_Res:=D3DDevice.Reset(pPresParm);
    if (l_Res <> D3D_OK) then
      raise EErrorFmt(6403, ['Reset', DXGetErrorString9(l_Res)]);

    //FIXME: Are the first two parameters always 0?
    l_Res:=D3DDevice.GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, OrigBackBuffer);
    if (l_Res <> D3D_OK) then
    begin
      Log(LOG_WARNING, LoadStr1(6403), ['GetBackBuffer', DXGetErrorString9(l_Res)]);
      Exit;
    end;

    //FIXME: We now need to reload all the textures and stuff!
  end
  else
  begin
    if not (DepthStencilSurface=nil) then
      DepthStencilSurface:=nil;

    if not (SwapChain=nil) then
      SwapChain:=nil;
  end;

  l_Res:=D3DDevice.CreateAdditionalSwapChain(pPresParm, SwapChain);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['CreateAdditionalSwapChain', DXGetErrorString9(l_Res)]);

  l_Res:=D3DDevice.CreateDepthStencilSurface(pPresParm.BackBufferWidth, pPresParm.BackBufferHeight, pPresParm.AutoDepthStencilFormat, pPresParm.MultiSampleType, pPresParm.MultiSampleQuality, false, DepthStencilSurface, nil);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['CreateDepthStencilSurface', DXGetErrorString9(l_Res)]);

  l_Res:=D3DDevice.SetDepthStencilSurface(DepthStencilSurface);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['SetDepthStencilSurface', DXGetErrorString9(l_Res)]);

  Result:=True;
end;

procedure TDirect3DSceneObject.ClearScene;
begin
end;

function TDirect3DSceneObject.StartBuildScene(var VertexSize: Integer) : TBuildMode;
begin
  VertexSize:=SizeOf(TVertex3D);
  Result:=bmDirect3D;
end;

procedure TDirect3DSceneObject.EndBuildScene;
begin
end;

procedure TDirect3DSceneObject.Render3DView;
var
  l_Res: HResult;
  pBackBuffer: IDirect3DSurface9;
{  l_VCenter: D3DVector;
  l_Projection: TD3DXMatrix;
  l_CameraEye: TD3DXMatrix;
  l_matRotation: TD3DXMatrix;
  l_quaRotation: TD3DXQuaternion;}
  PList: PSurfaces;
begin
  if not Direct3DLoaded then
    Exit;

  //If the viewport has been resized, then tell Direct3D what happened
  if (ScreenResized = True) then
  begin
    pPresParm.BackBufferWidth:=ScreenX;
    pPresParm.BackBufferHeight:=ScreenY;
    pPresParm.hDeviceWindow:=ViewWnd;
  end;

  if not CheckDeviceState then
    Exit;
  ScreenResized := False;

  l_Res:=SwapChain.GetBackBuffer(0, D3DBACKBUFFER_TYPE_MONO, pBackBuffer);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['GetBackBuffer', DXGetErrorString9(l_Res)]);

  l_Res:=D3DDevice.SetRenderTarget(0, pBackBuffer);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['SetRenderTarget', DXGetErrorString9(l_Res)]);

  pBackBuffer:=nil;

  l_Res:=D3DDevice.SetDepthStencilSurface(DepthStencilSurface);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['SetDepthStencilSurface', DXGetErrorString9(l_Res)]);

  l_Res:=D3DDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, DXFogColor, 1.0, 0);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['Clear', DXGetErrorString9(l_Res)]);

    { set camera }
  {with TCameraCoordinates(Coord) do
  begin
    D3DXMatrixTranslation(l_CameraEye, Camera.X, Camera.Y, Camera.Z);

    D3DXQuaternionRotationYawPitchRoll(l_quaRotation, HorzAngle * (180/pi), PitchAngle * (180/pi), 0);
    l_VCenter := D3DXVector3(Camera.X, Camera.Y, Camera.Z);
    D3DXMatrixAffineTransformation(l_matRotation,
                                   1,
                                   @l_VCenter,
                                   @l_quaRotation,
                                   nil);

    D3DXMatrixMultiply(l_CameraEye, l_CameraEye, l_matRotation);

    m_pD3DDevice.SetTransform(D3DTRANSFORMSTATE_VIEW, TD3DMatrix(l_CameraEye));
  end;}
  //    D3DXMatrixPerspectiveFov(l_Projection, D3DXToRadian(60.0), ScreenY/ScreenX, 1.0, 1000.0);
//    m_pD3DDevice.SetTransform(D3DTRANSFORMSTATE_PROJECTION, TD3DMatrix(l_Projection));

  l_Res := D3DDevice.BeginScene;
  if (l_Res <> 0) then
    raise EErrorFmt(6403, ['BeginScene', DXGetErrorString9(l_Res)]);

  try
//    m_CurrentAlpha  :=0;
//    m_CurrentColor:=0;

    PList:=ListSurfaces;
    while Assigned(PList) do
    begin
      if Transparency then
      begin
        if (PList^.Transparent=False) then
          RenderPList(PList, False, Coord);
      end
      else
      begin
        RenderPList(PList, False, Coord);
        if PList^.NumberTransparentFaces>0 then
          RenderPList(PList, True, Coord);
      end;
      PList:=PList^.Next;
    end;

  finally
    l_Res:=D3DDevice.EndScene;
    if (l_Res <> 0) then
      raise EErrorFmt(6403, ['EndScene', DXGetErrorString9(l_Res)]);
  end;

{  l_Res := m_pD3DX.UpdateFrame(0);
  if (l_Res <> 0) then
    raise EErrorFmt(6403, ['UpdateFrame', D3DXGetErrorMsg(l_Res)]);}

end;

procedure TDirect3DSceneObject.Copy3DView;
var
  l_Res: HResult;
begin
  if not Direct3DLoaded then
    Exit;

  if (DisplayMode=dmFullScreen) then
    l_Res:=SwapChain.Present(nil, nil, 0, nil, 0)
  else
    l_Res:=SwapChain.Present(@DrawRect, @DrawRect, 0, nil, 0);
  if (l_Res <> D3D_OK) then
    raise EErrorFmt(6403, ['Present', DXGetErrorString9(l_Res)]);
end;

procedure TDirect3DSceneObject.RenderPList(PList: PSurfaces; TransparentFaces: Boolean; SourceCoord: TCoordinates);
var
  Surf: PSurface3D;
  SurfEnd: PChar;
begin
  Surf:=PList^.Surf;
  SurfEnd:=PChar(Surf)+PList^.SurfSize;

  while Surf<SurfEnd do
  begin
    with Surf^ do
    begin
      Inc(Surf);
      if ((AlphaColor and $FF000000 = $FF000000) xor TransparentFaces)
      and (SourceCoord.PositiveHalf(Normale[0], Normale[1], Normale[2], Dist)) then
      begin
        if AlphaColor<>m_CurrentAlpha then
        begin
          m_CurrentAlpha := AlphaColor;
          m_CurrentColor := m_CurrentAlpha;
        end;
(*
        if l_NeedTex then
        begin
          LoadCurrentTexture(PList^.Texture);
          l_NeedTex:=False;
        end;
*)
        begin
(*
          for I:=1 to Abs(VertexCount) do
          begin
            l_TriangleStrip[i].color := m_CurrentColor;
          end;
*)
          {m_pD3DDevice.DrawPrimitive(D3DPT_TRIANGLESTRIP, D3DFVF_LVERTEX, PD3DLVERTEX(Surf)^, Abs(VertexCount), D3DDP_WAIT);}
        end;
      end;

      if VertexCount>=0 then
        Inc(PVertex3D(Surf), VertexCount)
      else
        Inc(PChar(Surf), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
    end;
  end;
end;

procedure TDirect3DSceneObject.BuildTexture(Texture: PTexture3);
begin
  //D3DDevice.CreateTexture(@);

end;

 {------------------------}

procedure TDirect3DState.ReleaseAllResources;
var
 TextureManager: TTextureManager;
 I: Integer;
 Scene: TObject;
begin
 TextureManager:=TTextureManager.GetInstance;
 for I:=0 to TextureManager.Scenes.Count-1 do
  begin
   Scene:=TextureManager.Scenes[I];
   if Scene is TDirect3DSceneObject then
     TDirect3DSceneObject(Scene).ReleaseResources;
  end;

  //FIXME: Also, need to release all OTHER resources (like textures etc.)
end;

procedure TDirect3DState.ClearTexture(Tex: PTexture3);
begin
  //DanielPharos: How can you be sure Direct3D has been loaded?

end;

 {------------------------}

initialization
  //FIXME: Is this really needed...?
  qrkDXState:=TDirect3DState.Create;
finalization
  qrkDXState.Free;
end.
