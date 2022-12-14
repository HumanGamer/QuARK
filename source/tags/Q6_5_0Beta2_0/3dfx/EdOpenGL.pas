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
Revision 1.56  2007/03/29 15:26:03  danielpharos
Removed a little bit of redundant code.

Revision 1.55  2007/03/26 21:01:46  danielpharos
Big change to OpenGL. Fixed a huge memory leak. Better handling of shared display lists.

Revision 1.54  2007/03/24 19:21:07  danielpharos
Removed some double and possibly wrong code.

Revision 1.53  2007/03/22 22:08:08  danielpharos
Moved a debug routine into a debug section.

Revision 1.52  2007/03/22 21:51:27  danielpharos
Fix for abnormal lighting effects in OpenGL introduced in last 'fix'.

Revision 1.51  2007/03/22 20:53:46  danielpharos
Improved tracking of the target DC. Should fix a few grey screens.
Also fixed the solid-color not showing up with lighting enabled.

Revision 1.50  2007/03/17 14:32:38  danielpharos
Moved some dictionary entries around, moved some error messages into the dictionary and added several new error messages to improve feedback to the user.

Revision 1.49  2007/03/11 12:03:11  danielpharos
Big changes to Logging. Simplified the entire thing.

Revision 1.48  2007/03/11 10:59:52  danielpharos
Fixed a warning during compiling.

Revision 1.47  2007/03/01 17:36:54  danielpharos
Stopped many redundant calls from being made when moving the camera. Should take care of some weird problems, and be faster too.

Revision 1.46  2007/02/27 21:20:08  danielpharos
Fixed a huge slowdown in the rendering process.

Revision 1.45  2007/02/27 17:02:52  danielpharos
Fix a few bugs in OpenGL lighting, and sort the transparent faces. Transparency is not working properly yet, but it's a decent start.

Revision 1.44  2007/02/06 14:07:39  danielpharos
Another transparency fix. Beziers, sprites and models should now also have transparency.

Revision 1.43  2007/02/06 13:08:47  danielpharos
Fixes for transparency. It should now work (more or less) correctly in all renderers that support it.

Revision 1.42  2007/02/02 21:01:28  danielpharos
Made the OpenGL lights respond to the light-setting, and made the ambient lighting match software lighting better

Revision 1.41  2007/01/31 17:06:53  danielpharos
Fixed the colors in OpenGL solid view mode

Revision 1.40  2007/01/31 15:11:21  danielpharos
HUGH changes: OpenGL lighting, OpenGL transparency, OpenGL culling, OpenGL speedups, and several smaller changes

Revision 1.39  2007/01/11 18:08:06  danielpharos
Fix for the panels sometimes not displaying anything

Revision 1.38  2007/01/05 19:47:11  danielpharos
Build in proper Maplimit handling
Fixed a debug comment

Revision 1.37  2006/12/26 22:48:16  danielpharos
A little fix to reduce the amount of grid-draw-problems with OpenGL

Revision 1.36  2006/12/03 23:13:33  danielpharos
Fixed the maximum texture dimension for OpenGL

Revision 1.35  2006/12/03 20:36:09  danielpharos
Put the perspective in the correct place for OpenGL. Should fix any fog issues.

Revision 1.34  2006/11/30 00:42:33  cdunde
To merge all source files that had changes from DanielPharos branch
to HEAD for QuArK 6.5.0 Beta 1.

Revision 1.33.2.15  2006/11/28 16:18:55  danielpharos
Pushed MapView into the renderers and made OpenGL do (bad) Solid Colors

Revision 1.33.2.14  2006/11/23 20:54:42  danielpharos
Cleaned up the OpenGL error messages
Added new OpenGL error messages texts to the dictionary

Revision 1.33.2.13  2006/11/23 20:52:59  danielpharos
Fixed the camera. Movement should now be the same as in software mode

Revision 1.33.2.12  2006/11/23 20:50:59  danielpharos
Now checks for the current PixelFormat, and changes that if needed
Code cleanup, moved some OpenGL calls around

Revision 1.33.2.11  2006/11/23 20:49:00  danielpharos
Pushed FogColor and FrameColor into the renderer

Revision 1.33.2.10  2006/11/23 20:47:26  danielpharos
Added counter to make sure the renderers only unload when they're not used anymore
(This affected the texture unloading procedure)

Revision 1.33.2.9  2006/11/23 20:45:23  danielpharos
Removed now obsolete FreeOpenGLEditor procedure

Revision 1.33.2.8  2006/11/01 22:22:28  danielpharos
BackUp 1 November 2006
Mainly reduce OpenGL memory leak

Revision 1.33  2006/04/06 19:44:56  nerdiii
Cleaned some compiler hints

Revision 1.32  2005/10/15 23:44:21  cdunde
Made one setting in QuArK's Config OpenGL section for all
games that use transparency that can be viewed in QuArK.
Also removed light entity dependency for  transparency to work.

Revision 1.31  2005/09/28 10:48:31  peter-b
Revert removal of Log and Header keywords

Revision 1.29  2005/09/23 00:06:04  cdunde
To fix light entity dependence for transparency to work feature

Revision 1.28  2005/09/22 05:08:34  cdunde
To comment out and reverse changes in version 1.24 2004/12/14
that broke OpenGL for odd sized textures

Revision 1.27  2005/04/01 19:30:16  alexander
remove unneeded copy operation for proxy views

Revision 1.26  2005/03/14 22:43:33  alexander
textures with alpha channel are rendered transparent in open gl

Revision 1.25  2005/01/11 01:58:56  alexander
some indentation to assist when debugging, no semantic change

Revision 1.24  2004/12/14 00:32:07  alexander
removed unnecessary resampling and gamma conversion for open gl true color textures

Revision 1.23  2003/03/21 00:12:43  nerdiii
tweaked OpenGL mode to render additive and texture modes as in Half-Life

Revision 1.22  2003/03/14 10:09:30  decker_dk
Some indent-changes and a bit cleanup.

Revision 1.21  2003/03/13 20:20:32  decker_dk
Modified so much to support transparency.

Revision 1.20  2002/05/25 18:29:21  decker_dk
Missed a semicolon.

Revision 1.19  2002/05/13 10:18:45  tiglari
Add Bilinear filtering option for textures in OGL view

Revision 1.18  2001/03/20 21:38:21  decker_dk
Updated copyright-header

Revision 1.17  2001/01/22 00:11:02  aiv
Beginning of support for sprites in 3d view

Revision 1.16  2000/12/30 15:22:19  decker_dk
- Moved TSceneObject and TTextureManager from Ed3DFX.pas into EdSceneObject.Pas
- Created Ed3DEditors.pas which contains close/free calls
- Created EdDirect3D.pas with minimal contents

Revision 1.15  2000/12/11 21:36:05  decker_dk
- Added comments to some assembly sections in Ed3DFX.PAS and EdOpenGL.PAS.
- Made TSceneObject's: PolyFaces, ModelInfo and BezierInfo protected, and
added 3 functions to add stuff to them; AddPolyFace(), AddModel() and
AddBezier(). This modification have impact on Bezier.PAS, QkMapObjects.PAS,
QkComponent.PAS and QkMapPoly.PAS.
- Misc. other changes.

Revision 1.14  2000/12/07 19:47:59  decker_dk
- Changed the code in Glide.PAS and GL1.PAS, to more understandable
and readable code (as seen in Python.PAS), which isn't as subtle to
function-pointer changes, as the old code was. This modification also
had impact on Ed3DFX.PAS and EdOpenGL.PAS, which now does not have any
prefixed 'qrkGlide_API' or 'qrkOpenGL_API' pointer-variables for DLL calls.

Revision 1.13  2000/11/11 17:56:52  decker_dk
Exchanged pointer-variable names: 'gr' with 'qrkGlide_API' and 'gl' with 'qrkOpenGL_API'

Revision 1.12  2000/09/10 14:04:24  alexander
added cvs headers
}

unit EdOpenGL;

interface

uses Windows, Classes,
     qmath, PyMath, PyMath3D,
     GL1,
     EdSceneObject;

{x $ IFDEF Debug}
 {---$OPTIMIZATION OFF}
 {x $ DEFINE DebugGLErr}
{x $ ENDIF}

const
 kScaleCos = 0.5;

var
 TexturesToDelete: array of Integer;
 DisplayListsToDelete: array of Integer;
 RCs: array of HGLRC;

type
 PLightList = ^TLightList;
 TLightList = record
               SubLightList, Next: PLightList;
               Position, Min, Max: vec3_t;
               Brightness, Brightness2: scalar_t;
               Color: TColorRef;
              end;
 TLightParams = record
                 ZeroLight, BrightnessSaturation, LightFactor: scalar_t;
                end;

 TGLSceneObject = class(TSceneObject)
 private
   DestWnd: HWnd;
   ViewDC: HDC;
   RC: HGLRC;
   CurrentAlpha: LongInt;
   Currentf: GLfloat4;
   RenderingTextureBuffer: TMemoryStream;
   DoubleBuffered, FReady: Boolean;
   Fog: Boolean;
   Transparency: Boolean;
   Lighting: Boolean;
   Culling: Boolean;
   MakeSections: Boolean;
   VCorrection2: Single;
   Lights: PLightList;
   NumberOfLights: LongInt;
   DisplayLists: Boolean;
   LightParams: TLightParams;
   FullBright: TLightParams;
   OpenGLLoaded: Boolean;
   MapLimit: TVect;
   MapLimitSmallest: Double;
   DepthBufferBits: Byte;
   MaxLights: GLint;
   LightingQuality: Integer;
   OpenGLDisplayLists: array[0..2] of Integer;
   procedure RenderPList(PList: PSurfaces; TransparentFaces: Boolean; SourceCoord: TCoordinates);
 protected
   Bilinear: boolean;
   ScreenX, ScreenY: Integer;
   procedure stScalePoly(Texture: PTexture3; var ScaleS, ScaleT: TDouble); override;
   procedure stScaleModel(Skin: PTexture3; var ScaleS, ScaleT: TDouble); override;
   procedure stScaleSprite(Skin: PTexture3; var ScaleS, ScaleT: TDouble); override;
   procedure stScaleBezier(Texture: PTexture3; var ScaleS, ScaleT: TDouble); override;
   procedure WriteVertex(PV: PChar; Source: Pointer; const ns,nt: Single; HiRes: Boolean); override;
   function StartBuildScene({var PW: TPaletteWarning;} var VertexSize: Integer) : TBuildMode; override;
   procedure EndBuildScene; override;
   procedure ReleaseResources;
   procedure BuildTexture(Texture: PTexture3); override;
 public
   constructor Create(nViewMode: TMapViewMode);
   destructor Destroy; override;
   procedure Init(Wnd: HWnd;
                  nCoord: TCoordinates;
                  DisplayMode: TDisplayMode;
                  DisplayType: TDisplayType;
                  const LibName: String;
                  var AllowsGDI: Boolean); override;
   procedure ClearScene; override;
   procedure Render3DView; override;
   procedure Copy3DView; override;
   procedure AddLight(const Position: TVect; Brightness: Single; Color: TColorRef); override;
   property Ready: Boolean read FReady write FReady;
   procedure SetViewRect(SX, SY: Integer); override;
   procedure SetViewDC(DC: HDC); override;
   function ChangeQuality(nQuality: Integer) : Boolean; override;
 end;

type  { this is the data shared by all existing TGLSceneObjects }
  TGLState = class
  public
    procedure ClearTexture(Tex: PTexture3);
  end;
var
  qrkGLState: TGlState;

 {------------------------}

procedure CheckOpenGLError(GlError: GLenum);

 {------------------------}

implementation

uses SysUtils, Quarkx, Setup, Python, Logging, {Math,}
     QkObjects, QkMapPoly, QkPixelSet, QkForm;

 {------------------------}

{$IFDEF DebugGLErr}
var
  HackIgnoreErrors: Boolean = False;

procedure DebugOpenGL(Pos: Integer; Text: string; Args: array of const);  { OpenGL error check }
var
  I, J: Integer;
  S: String;
begin
  if HackIgnoreErrors then
    Exit;
  Log(LOG_VERBOSE,'EdOpenGL #%d %s', [Pos, Format(Text, Args)]);
  S:='';
  for I:=1 to 25 do   {DanielPharos: Why is it trying exactly 25 times?}
  begin
    J:=glGetError;
    if J = GL_NO_ERROR then
      Break;
    S:=S+' '+IntToStr(J);
  end;
  if S<>'' then
  begin
    //Log(S);
    Raise EErrorFmt(6302, [S, Pos]);
  end
end;
{$ENDIF}

 {------------------------}

type
 PVertex3D = ^TVertex3D;
 TVertex3D = record
              st: array[0..1] of Single;
              xyz: vec3_t;
             end;

type
 PP3D = ^TP3D;
 TP3D = record
         v: TVertex3D;
         light_rgb: array[0..3] of GLfloat;
        end;

procedure UnpackColor(Color: TColorRef; var v: GLfloat4);
begin
  v[0]:=((Color       ) and $FF) * (1/255.0);
  v[1]:=((Color shr  8) and $FF) * (1/255.0);
  v[2]:=((Color shr 16) and $FF) * (1/255.0);
  v[3]:=((Color shr 24) and $FF) * (1/255.0);
end;

procedure Interpole(var Dest: TP3D; const De, A: TP3D; f: Single);
var
 f1: Single;
begin
  f1:=1-f;
  //with Dest.v do
  begin
    Dest.v.xyz[0]:=De.v.xyz[0]*f1 + A.v.xyz[0]*f;
    Dest.v.xyz[1]:=De.v.xyz[1]*f1 + A.v.xyz[1]*f;
    Dest.v.xyz[2]:=De.v.xyz[2]*f1 + A.v.xyz[2]*f;

    Dest.v.st[0]:=De.v.st[0]*f1 + A.v.st[0]*f;
    Dest.v.st[1]:=De.v.st[1]*f1 + A.v.st[1]*f;
  end;
end;

procedure LightAtPoint(var Point1: TP3D;
                       SubList: PLightList;
                       const Currentf: GLfloat4;
                       const LightParams: TLightParams;
                       const NormalePlan: vec3_t);
var
 LP: PLightList;
 Light: array[0..2] of TDouble;
 Incoming: vec3_t;
 Dist1, DistToSource: TDouble;
 K: Integer;
begin
  //with Point1 do
  begin
    LP:=SubList;
    Light[0]:=0;
    Light[1]:=0;
    Light[2]:=0;
    while Assigned(LP) do
    begin
      //with LP^ do
      begin
        //LP:=LP^.SubLightList;

        if  (Point1.v.xyz[0]>LP^.Min[0]) and (Point1.v.xyz[0]<LP^.Max[0])
        and (Point1.v.xyz[1]>LP^.Min[1]) and (Point1.v.xyz[1]<LP^.Max[1])
        and (Point1.v.xyz[2]>LP^.Min[2]) and (Point1.v.xyz[2]<LP^.Max[2]) then
        begin
          Incoming[0]:=LP^.Position[0]-Point1.v.xyz[0];
          Incoming[1]:=LP^.Position[1]-Point1.v.xyz[1];
          Incoming[2]:=LP^.Position[2]-Point1.v.xyz[2];
          DistToSource:=Sqr(Incoming[0])+Sqr(Incoming[1])+Sqr(Incoming[2]);
          //DanielPharos: Shouldn't it be this?
          //DistToSource:=Sqr(Incoming[0]*Incoming[0]+Incoming[1]*Incoming[1]+Incoming[2]*Incoming[2]);
          if DistToSource<LP^.Brightness2 then
          begin
            if DistToSource < rien then
              Dist1:=1E10
            else
            begin
              DistToSource:=Sqrt(DistToSource);
              Dist1:=(LP^.Brightness - DistToSource) * ((1.0-kScaleCos) + kScaleCos * (Incoming[0]*NormalePlan[0] + Incoming[1]*NormalePlan[1] + Incoming[2]*NormalePlan[2]) / DistToSource);
            end;

            if LP^.Color and $FF = $FF then
              Light[0]:=Light[0] + Dist1
            else
              Light[0]:=Light[0] + Dist1 * (LP^.Color and $FF) * (1/$100);

            if (LP^.Color shr 8) and $FF = $FF then
              Light[1]:=Light[1] + Dist1
            else
              Light[1]:=Light[1] + Dist1 * ((LP^.Color shr 8) and $FF) * (1/$100);

            if (LP^.Color shr 16) and $FF = $FF then
              Light[2]:=Light[2] + Dist1
            else
              Light[2]:=Light[2] + Dist1 * ((LP^.Color shr 16) and $FF) * (1/$100);
          end;
        end;

        LP:=LP^.SubLightList;
      end;
    end;

    Point1.light_rgb[3]:=Currentf[3];
    for K:=0 to 2 do
      if Light[K] >= LightParams.BrightnessSaturation then
        Point1.light_rgb[K]:=Currentf[K]
      else
        Point1.light_rgb[K]:=(LightParams.ZeroLight + (Light[K]*LightParams.LightFactor)) * Currentf[K];
  end;
end;

procedure RenderQuad(PV1, PV2, PV3, PV4: PVertex3D;
                     var Currentf: GLfloat4;
                     LP: PLightList;
                     const NormalePlan: vec3_t;
                     Dist: scalar_t;
                     const LightParams: TLightParams;
                     MakeSections: Boolean);
const
 StandardSectionSize = 77.0;
 SectionsI = 8;
 SectionsJ = 8;
var
 I, J, StepI, StepJ: Integer;
 Points: array[0..SectionsJ, 0..SectionsI] of TP3D;
 f, fstep: Single;
 SubList: PLightList;
 LPP: ^PLightList;
 DistToSource, Dist1: TDouble;
 light: array[0..3] of GLfloat;
 NormalVector: array[0..2] of GLfloat;
begin
  if MakeSections=False then
  begin
    {$IFDEF DebugGLErr} DebugOpenGL(-121, 'glBegin(GL_QUADS)', []); {$ENDIF}
    glBegin(GL_QUADS);
    light[0]:=LightParams.ZeroLight * Currentf[0];
    light[1]:=LightParams.ZeroLight * Currentf[1];
    light[2]:=LightParams.ZeroLight * Currentf[2];
    light[3]:=Currentf[3];
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@light);
    glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@light);
    glColor4fv(light);
    NormalVector[0]:=NormalePlan[0];
    NormalVector[1]:=NormalePlan[1];
    NormalVector[2]:=NormalePlan[2];
    glNormal3fv(@NormalVector);

    //with PV1^ do
    begin
      glTexCoord2fv(PV1^.st);
      glVertex3fv(PV1^.xyz);
    end;
    //with PV2^ do
    begin
      glTexCoord2fv(PV2^.st);
      glVertex3fv(PV2^.xyz);
    end;
    //with PV3^ do
    begin
      glTexCoord2fv(PV3^.st);
      glVertex3fv(PV3^.xyz);
    end;
    //with PV4^ do
    begin
      glTexCoord2fv(PV4^.st);
      glVertex3fv(PV4^.xyz);
    end;
    glEnd;
    {$IFDEF DebugGLErr} DebugOpenGL(121, 'glEnd', []); {$ENDIF}
  end
  else
  begin
    SubList:=Nil;
    LPP:=@SubList;
    while Assigned(LP) do
    begin
      with LP^ do
      begin
        if Position[0]*NormalePlan[0] + Position[1]*NormalePlan[1] + Position[2]*NormalePlan[2] > Dist then
        begin
          if ((PV1^.xyz[0]>Min[0]) and (PV1^.xyz[0]<Max[0])
          and (PV1^.xyz[1]>Min[1]) and (PV1^.xyz[1]<Max[1])
          and (PV1^.xyz[2]>Min[2]) and (PV1^.xyz[2]<Max[2]))
          or ((PV2^.xyz[0]>Min[0]) and (PV2^.xyz[0]<Max[0])
          and (PV2^.xyz[1]>Min[1]) and (PV2^.xyz[1]<Max[1])
          and (PV2^.xyz[2]>Min[2]) and (PV2^.xyz[2]<Max[2]))
          or ((PV3^.xyz[0]>Min[0]) and (PV3^.xyz[0]<Max[0])
          and (PV3^.xyz[1]>Min[1]) and (PV3^.xyz[1]<Max[1])
          and (PV3^.xyz[2]>Min[2]) and (PV3^.xyz[2]<Max[2]))
          or ((PV4^.xyz[0]>Min[0]) and (PV4^.xyz[0]<Max[0])
          and (PV4^.xyz[1]>Min[1]) and (PV4^.xyz[1]<Max[1])
          and (PV4^.xyz[2]>Min[2]) and (PV4^.xyz[2]<Max[2])) then
          begin
            LPP^:=LP;
            LP^.SubLightList:=Nil;
            LPP:=@LP^.SubLightList;
          end;
        end;
      end;
      LP:=LP^.Next;
    end;

    {$IFDEF DebugGLErr} DebugOpenGL(-109, '', []); {$ENDIF}
    Points[0,        0        ].v:=PV4^;
    Points[0,        SectionsI].v:=PV3^;
    Points[SectionsJ,SectionsI].v:=PV2^;
    Points[SectionsJ,0        ].v:=PV1^;

    DistToSource:=Abs(Points[0,        SectionsI].v.xyz[0]-Points[0,        0].v.xyz[0]);
    Dist1:=       Abs(Points[0,        SectionsI].v.xyz[1]-Points[0,        0].v.xyz[1]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[0,        SectionsI].v.xyz[2]-Points[0,        0].v.xyz[2]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,SectionsI].v.xyz[0]-Points[SectionsJ,0].v.xyz[0]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,SectionsI].v.xyz[1]-Points[SectionsJ,0].v.xyz[1]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,SectionsI].v.xyz[2]-Points[SectionsJ,0].v.xyz[2]); if Dist1>DistToSource then DistToSource:=Dist1;
    if DistToSource>2*StandardSectionSize then
    begin
      if DistToSource>4*StandardSectionSize then
        StepI:=1
      else
        StepI:=2;
    end
    else
    begin
      if DistToSource>StandardSectionSize then
        StepI:=4
      else
        StepI:=8;
    end;

    DistToSource:=Abs(Points[SectionsJ,0        ].v.xyz[0]-Points[0,0        ].v.xyz[0]);
    Dist1:=       Abs(Points[SectionsJ,0        ].v.xyz[1]-Points[0,0        ].v.xyz[1]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,0        ].v.xyz[2]-Points[0,0        ].v.xyz[2]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,SectionsI].v.xyz[0]-Points[0,SectionsI].v.xyz[0]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,SectionsI].v.xyz[1]-Points[0,SectionsI].v.xyz[1]); if Dist1>DistToSource then DistToSource:=Dist1;
    Dist1:=       Abs(Points[SectionsJ,SectionsI].v.xyz[2]-Points[0,SectionsI].v.xyz[2]); if Dist1>DistToSource then DistToSource:=Dist1;
    if DistToSource>2*StandardSectionSize then
    begin
      if DistToSource>4*StandardSectionSize then
        StepJ:=1
      else
        StepJ:=2;
    end
    else
    begin
      if DistToSource>StandardSectionSize then
        StepJ:=4
      else
        StepJ:=8;
    end;

    f:=0;
    fstep:=StepI*(1/SectionsI);
    I:=StepI;
    while I<SectionsI do
    begin
      f:=f+fstep;
      Interpole(Points[0,        I], Points[0,        0], Points[0,        SectionsI], f);
      Interpole(Points[SectionsJ,I], Points[SectionsJ,0], Points[SectionsJ,SectionsI], f);
      Inc(I, StepI);
    end;

    f:=0;
    fstep:=StepJ*(1/SectionsJ);
    J:=StepJ;
    while J<SectionsJ do
    begin
      f:=f+fstep;
      I:=0;
      while I<=SectionsI do
      begin
        Interpole(Points[J,I], Points[0,I], Points[SectionsJ,I], f);
        Inc(I, StepI);
      end;
      Inc(J, StepJ);
    end;

    J:=0;
    while J<=SectionsJ do
    begin
      I:=0;
      while I<=SectionsI do
      begin
        LightAtPoint(Points[J,I], SubList, Currentf, LightParams, NormalePlan);
        Inc(I, StepI);
      end;
      Inc(J, StepJ);
    end;

    J:=0;
    while J<SectionsJ do
    begin
      {$IFDEF DebugGLErr} DebugOpenGL(-122, 'glBegin(GL_QUAD_STRIP)', []); {$ENDIF}
      glBegin(GL_QUAD_STRIP);
      NormalVector[0]:=NormalePlan[0];
      NormalVector[1]:=NormalePlan[1];
      NormalVector[2]:=NormalePlan[2];
      glNormal3fv(@NormalVector);

      I:=0;
      while I<=SectionsI do
      begin
        //with Points[J,I] do
        begin
          glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@Points[J,I].light_rgb);
          glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@Points[J,I].light_rgb);
          glColor4fv(Points[J,I].light_rgb);
          glTexCoord2fv(Points[J,I].v.st);
          glVertex3fv(Points[J,I].v.xyz);
        end;
        //with Points[J+StepJ,I] do
        begin
          glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@Points[J+StepJ,I].light_rgb);
          glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@Points[J+StepJ,I].light_rgb);
          glColor4fv(Points[J+StepJ,I].light_rgb);
          glTexCoord2fv(Points[J+StepJ,I].v.st);
          glVertex3fv(Points[J+StepJ,I].v.xyz);
        end;
        Inc(I, StepI);
      end;

      glEnd;
      {$IFDEF DebugGLErr} DebugOpenGL(122, 'glEnd', []); {$ENDIF}
      Inc(J, StepJ);
    end;
    {$IFDEF DebugGLErr} DebugOpenGL(109, '', []); {$ENDIF}
  end;
end;

procedure RenderQuadStrip(PV: PVertex3D;
                          VertexCount: Integer;
                          var Currentf: GLfloat4;
                          LP: PLightList;
                          const NormalePlan: vec3_t;
                          const LightParams: TLightParams);
var
 LP1: PLightList;
 I: Integer;
 Point: TP3D;
 NormalVector: array[0..2] of GLfloat;
begin
  LP1:=LP;
  while Assigned(LP1) do
  begin
    LP1^.SubLightList:=LP1^.Next;
    LP1:=LP1^.SubLightList;
  end;
  glBegin(GL_TRIANGLE_STRIP);
  NormalVector[0]:=NormalePlan[0];
  NormalVector[1]:=NormalePlan[1];
  NormalVector[2]:=NormalePlan[2];
  glNormal3fv(@NormalVector);

  for I:=1 to VertexCount do
  begin
    Point.v:=PV^;
    Inc(PV);
    LightAtPoint(Point, LP, Currentf, LightParams, vec3_p(PV)^);
    Inc(vec3_p(PV));
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@Point.light_rgb);
    glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@Point.light_rgb);
    glColor4fv(Point.light_rgb);
    glTexCoord2fv(Point.v.st);
    glVertex3fv(Point.v.xyz);
  end;
  glEnd;
end;

 {------------------------}

procedure TGLSceneObject.SetViewRect(SX, SY: Integer);
begin
  if SX<1 then SX:=1;
  if SY<1 then SY:=1;
  ScreenX:=SX;
  ScreenY:=SY;
end;

procedure TGLSceneObject.SetViewDC(DC: HDC);
var
  DoubleBuffered: Boolean;
  pfd: TPixelFormatDescriptor;
  pfi: Integer;
  Setup: QObject;
  CurrentPixelFormat: Integer;
begin
  if ViewDC<>DC then
  begin
    ReleaseDC(DestWnd, ViewDC);
    ViewDC:=DC;
    Setup:=SetupSubSet(ssGeneral, 'OpenGL');
    DoubleBuffered:=Setup.Specifics.Values['DoubleBuffer']<>'';
    FillChar(pfd, SizeOf(pfd), 0);
    pfd.nSize:=SizeOf(pfd);
    pfd.nversion:=1;
    pfd.dwflags:=pfd_Support_OpenGl or pfd_Draw_To_Window;
    pfd.iPixelType:=pfd_Type_RGBA;
    if DoubleBuffered then
      pfd.dwflags:=pfd.dwflags or pfd_DoubleBuffer;
    if Setup.Specifics.Values['SupportsGDI']<>'' then
      pfd.dwflags:=pfd.dwflags or pfd_Support_GDI;
    pfd.cColorBits:=Round(Setup.GetFloatSpec('ColorBits', 0));
    if pfd.cColorBits<=0 then
      pfd.cColorBits:=GetDeviceCaps(ViewDC, BITSPIXEL);
    pfd.cDepthBits:=DepthBufferBits;
    pfd.iLayerType:=pfd_Main_Plane;
    pfi:=ChoosePixelFormat(ViewDC, @pfd);
    CurrentPixelFormat:=GetPixelFormat(ViewDC);
    if CurrentPixelFormat<>pfi then
     begin
      if not SetPixelFormat(ViewDC, pfi, @pfd) then
        Raise EErrorFmt(4869, ['SetPixelFormat']);
     end;
  end;
end;

function TGLSceneObject.ChangeQuality(nQuality: Integer) : Boolean;
begin
 if not ((nQuality=0) or (nQuality=1) or (nQuality=2)) then
 begin
  Result:=False;
  Exit;
 end;
 Result:=LightingQuality<>nQuality;
 LightingQuality:=nQuality;
end;

procedure TGLSceneObject.stScalePoly(Texture: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  //with Texture^ do
  begin
    ScaleS:=Texture^.TexW*( 1/EchelleTexture);
    ScaleT:=Texture^.TexH*(-1/EchelleTexture);
  end;
end;

procedure TGLSceneObject.stScaleModel(Skin: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  //with Skin^ do
  begin
    ScaleS:=1/Skin^.TexW;
    ScaleT:=1/Skin^.TexH;
  end;
end;

procedure TGLSceneObject.stScaleSprite(Skin: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  //with Skin^ do
  begin
    ScaleS:=1/Skin^.TexW;
    ScaleT:=1/Skin^.TexH;
  end;
end;

procedure TGLSceneObject.stScaleBezier(Texture: PTexture3; var ScaleS, ScaleT: TDouble);
begin
  ScaleS:=1;
  ScaleT:=1;
end;

procedure TGLSceneObject.WriteVertex(PV: PChar; Source: Pointer; const ns,nt: Single; HiRes: Boolean);
begin
  with PVertex3D(PV)^ do
  begin
    if HiRes then
    begin
      with PVect(Source)^ do
      begin
        xyz[0]:=X;
        xyz[1]:=Y;
        xyz[2]:=Z;
      end;
    end
    else
    begin
      xyz:=vec3_p(Source)^;
    end;

    st[0]:=ns;
    st[1]:=nt;
  end;
end;

procedure TGLSceneObject.ReleaseResources;
var
 I: Integer;
{ NameArray, NameAreaWalker: ^GLuint;}
begin
  RenderingTextureBuffer.Free;
  RenderingTextureBuffer:=Nil;

  {with TTextureManager.GetInstance do
  begin
    GetMem(NameArray, Textures.Count*SizeOf(GLuint));
    try
      NameAreaWalker:=NameArray;

      for I:=0 to Textures.Count-1 do
      begin
        with PTexture3(Textures.Objects[I])^ do
        begin
          if OpenGLName<>0 then
          begin
            NameAreaWalker^:=OpenGLName;
            Inc(NameAreaWalker);
            OpenGLName:=0;
          end;
        end;
      end;

      if OpenGlLoaded and (NameAreaWalker<>NameArray) then
      begin}
        {$IFDEF DebugGLErr} DebugOpenGL(-102, 'glDeleteTextures(<%d>, <%d>)', [(PChar(NameAreaWalker)-PChar(NameArray)) div SizeOf(GLuint), NameArray^]); {$ENDIF}
        {glDeleteTextures((PChar(NameAreaWalker)-PChar(NameArray)) div SizeOf(GLuint), NameArray^);}
        {$IFDEF DebugGLErr} DebugOpenGL(102, 'glDeleteTextures(<%d>, <%d>)', [(PChar(NameAreaWalker)-PChar(NameArray)) div SizeOf(GLuint), NameArray^]); {$ENDIF}
      {end;
    finally
      FreeMem(NameArray);
    end;
  end;}

  if RC<>0 then
  begin
    for I:=0 to 2 do
    begin
      if OpenGLDisplayLists[I]<>0 then
      begin
        SetLength(DisplayListsToDelete,Length(DisplayListsToDelete)+1);
        DisplayListsToDelete[Length(DisplayListsToDelete)-1]:=OpenGLDisplayLists[I];
        OpenGLDisplayLists[I]:=0;
      end;
    end;
    if OpenGLLoaded then
      if wglDeleteContext(RC) = false then
        raise EError(6312);

    ReleaseDC(DestWnd, ViewDC);
    ViewDC:=0;

    I:=0;
    while I<=Length(RCs)-1 do
    begin
      if RCs[I]=RC then
      begin
        RCs[I]:=RCs[Length(RCs)-1];
        SetLength(RCs,Length(RCs)-1);
      end
      else
        Inc(I);
    end;
    RC:=0;
  end;
end;

constructor TGLSceneObject.Create(nViewMode: TMapViewMode);
begin
  inherited Create(nViewMode);
  RC:=0;
  ViewDC:=0;
end;

destructor TGLSceneObject.Destroy;
begin
  {$IFDEF DebugGLErr} HackIgnoreErrors:=True; {$ENDIF}
  inherited;
  ReleaseResources;
  if OpenGLLoaded = true then
    UnloadOpenGl;
  {$IFDEF DebugGLErr} HackIgnoreErrors:=False; {$ENDIF}
end;

procedure TGLSceneObject.Init(Wnd: HWnd;
                              nCoord: TCoordinates;
                              DisplayMode: TDisplayMode;
                              DisplayType: TDisplayType;
                              const LibName: String;
                              var AllowsGDI: Boolean);
var
 pfd: TPixelFormatDescriptor;
 pfi: Integer;
 nFogColor: GLfloat4;
 FogColor{, FrameColor}: TColorRef;
 Setup: QObject;
 CurrentPixelFormat: Integer;
 LightParam: array[0..3] of GLfloat;
begin
  ClearScene;

  CurrentDisplayMode:=DisplayMode;
  CurrentDisplayType:=DisplayType;

  { has the OpenGL DLL already been loaded? }
  if not OpenGLLoaded then
  begin
    if LibName='' then
      Raise EError(6001);
    { try to load the OpenGL DLL, and set pointers to its functions }
    if not LoadOpenGl() then
      Raise EErrorFmt(6300, [GetLastError]);
    OpenGLLoaded := true;
  end;
  if (DisplayMode=dmFullScreen) then
   Raise InternalE(LoadStr1(6320));

  Coord:=nCoord;
  TTextureManager.AddScene(Self);

  try
   Setup:=SetupSubSet(ssGames, g_SetupSet[ssGames].Specifics.Values['GameCfg']);
   MapLimit:=Setup.VectSpec['MapLimit'];
  except
   Setup:=SetupSubSet(ssMap, 'Display');
   MapLimit:=Setup.VectSpec['MapLimit'];
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
  Setup:=SetupSubSet(ssGeneral, 'OpenGL');
  if (DisplayMode=dmWindow) or (DisplayMode=dmFullScreen) then
  begin
    Fog:=Setup.Specifics.Values['Fog']<>'';
    Transparency:=Setup.Specifics.Values['Transparency']<>'';
    Lighting:=Setup.Specifics.Values['Lights']<>'';
    Culling:=Setup.Specifics.Values['Culling']<>'';
    LightParams.ZeroLight:=Setup.GetFloatSpec('Ambient', 0.4);
    LightParams.BrightnessSaturation:=SetupGameSet.GetFloatSpec('3DLight', 256);
    LightParams.LightFactor:=(1.0-LightParams.ZeroLight)/LightParams.BrightnessSaturation;
  end
  else
  begin
    Fog:=False;
    Transparency:=False;
    Lighting:=False;
    Culling:=False;
    LightParams.ZeroLight:=1;
    LightParams.BrightnessSaturation:=256;
    LightParams.LightFactor:=(1.0-LightParams.ZeroLight)/LightParams.BrightnessSaturation;
  end;
  FullBright.ZeroLight:=1;
  FullBright.BrightnessSaturation:=0;
  FullBright.LightFactor:=0;
  VCorrection2:=2*Setup.GetFloatSpec('VCorrection',1);
  AllowsGDI:=Setup.Specifics.Values['AllowsGDI']<>'';
  DisplayLists:=Setup.Specifics.Values['GLLists']<>'';
  DepthBufferBits:=Round(Setup.GetFloatSpec('DepthBits', 16));
  if Lighting then
    MakeSections:=True
    {DanielPharos: Not configurable at the moment.
    It creates small sections out of big poly's, so the lighting effects are better.}
  else
    MakeSections:=False;

  ViewDC:=GetDC(Wnd);
  if Wnd<>DestWnd then
  begin
    DoubleBuffered:=Setup.Specifics.Values['DoubleBuffer']<>'';
    FillChar(pfd, SizeOf(pfd), 0);
    pfd.nSize:=SizeOf(pfd);
    pfd.nversion:=1;
    pfd.dwflags:=pfd_Support_OpenGl or pfd_Draw_To_Window;
    pfd.iPixelType:=pfd_Type_RGBA;
    if DoubleBuffered then
      pfd.dwflags:=pfd.dwflags or pfd_DoubleBuffer;
    if Setup.Specifics.Values['SupportsGDI']<>'' then
      pfd.dwflags:=pfd.dwflags or pfd_Support_GDI;
    pfd.cColorBits:=Round(Setup.GetFloatSpec('ColorBits', 0));
    if pfd.cColorBits<=0 then
      pfd.cColorBits:=GetDeviceCaps(ViewDC, BITSPIXEL);
    pfd.cDepthBits:=DepthBufferBits;
    pfd.iLayerType:=pfd_Main_Plane;
    pfi:=ChoosePixelFormat(ViewDC, @pfd);
    CurrentPixelFormat:=GetPixelFormat(ViewDC);
    if CurrentPixelFormat<>pfi then
     begin
      if not SetPixelFormat(ViewDC, pfi, @pfd) then
        Raise EErrorFmt(6301, ['SetPixelFormat']);
     end;
    DestWnd:=Wnd;
  end;

  if RC = 0 then
   begin
    RC:=wglCreateContext(ViewDC);
    if RC = 0 then
     raise EError(6311);

    for pfi:=0 to Length(RCs)-1 do
    begin
      if RCs[pfi]<>0 then
      begin
        if wglShareLists(RCs[pfi],RC)=false then
          Raise EErrorFmt(6301, ['wglShareLists']);
        break;
      end;
    end;
    SetLength(RCs,Length(RCs)+1);
    RCs[Length(RCs)-1]:=RC;
   end;

  if wglMakeCurrent(ViewDC,RC) = false then
    raise EError(6310);

  { set up OpenGL }
  {$IFDEF DebugGLErr} DebugOpenGL(0, '', []); {$ENDIF}
  UnpackColor(FogColor, nFogColor);
  glClearColor(nFogColor[0], nFogColor[1], nFogColor[2], 1);
 {glClearDepth(1);}
  if (DisplayMode=dmPanel) then
  begin
    glDisable(GL_DEPTH_TEST);
  end
  else
  begin
    glEnable(GL_DEPTH_TEST);
   {glDepthFunc(GL_LEQUAL);}
  end;
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
  glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
  glEnable(GL_NORMALIZE);  
  glEdgeFlag(0);
  {$IFDEF DebugGLErr} DebugOpenGL(1, '', []); {$ENDIF}

  { set up texture parameters }  //DanielPharos: These are set per texture, in the BuildTexture procedure
  {glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);}
  {glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);}
  {glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);}
  {glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);}
  {glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);}
  {glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);}
  if Setup.Specifics.Values['Bilinear']<>'' then
    Bilinear:=true
  else
    Bilinear:=false;

  { at this point the scene object is more or less initialized }
  if not Ready then
    PostMessage(Wnd, wm_InternalMessage, wp_OpenGL, 0);

  { set up fog }
  if Fog then
  begin
    glEnable(GL_FOG);
    glFogi(GL_FOG_MODE, GL_EXP2);
   {glFogf(GL_FOG_START, FarDistance * kDistFarToShort);
    glFogf(GL_FOG_END, FarDistance);}
    glFogf(GL_FOG_DENSITY, FogDensity/FarDistance);
    glFogfv(GL_FOG_COLOR, nFogColor);
    glHint(GL_FOG_HINT, GL_NICEST);
    CheckOpenGLError(glGetError);
  end
  else
  begin
    glDisable(GL_FOG);
    CheckOpenGLError(glGetError);
  end;
  
  if Lighting then
  begin
    glEnable(GL_LIGHTING);
    LightParam[0]:=LightParams.ZeroLight;
    LightParam[1]:=LightParams.ZeroLight;
    LightParam[2]:=LightParams.ZeroLight;
    LightParam[3]:=1.0;
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @LightParam);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
    glShadeModel(GL_SMOOTH);
    CheckOpenGLError(glGetError);
  end
  else
  begin
    glDisable(GL_LIGHTING);
    CheckOpenGLError(glGetError);
  end;

  if Transparency then
  begin
    glEnable(GL_BLEND);
    CheckOpenGLError(glGetError);
  end
  else
  begin
    glDisable(GL_BLEND);
    CheckOpenGLError(glGetError);
  end;
  //DanielPharos: Things like normal maps, bump-maps etc. should be added in a similar way

  glFrontFace(GL_CW);
  if Culling then
  begin
    glEnable(GL_CULL_FACE);
    CheckOpenGLError(glGetError);
  end
  else
  begin
    glDisable(GL_CULL_FACE);
    CheckOpenGLError(glGetError);
  end;

  glGetIntegerv(GL_MAX_LIGHTS, @MaxLights);
  CheckOpenGLError(glGetError);
  if MaxLights<=0 then
    MaxLights:=8;

  {$IFDEF DebugGLErr} DebugOpenGL(3, '', []); {$ENDIF}  
  wglMakeCurrent(0,0);
end;

procedure TGLSceneObject.Copy3DView;
begin
  if DoubleBuffered then
    if Windows.SwapBuffers(ViewDC)=false then
      raise exception.create(LoadStr1(6315));
end;

procedure TGLSceneObject.ClearScene;
var
 PL: PLightList;
begin
  while Assigned(Lights) do
  begin
    PL:=Lights;
    Lights:=PL^.Next;
    Dispose(PL);
  end;
  NumberOfLights:=0;
  inherited;
end;

procedure TGLSceneObject.AddLight(const Position: TVect; Brightness: Single; Color: TColorRef);
var
 PL: PLightList;
begin
  New(PL);

  PL^.Next:=Lights;
  Lights:=PL;

  PL^.Position[0]:=Position.X;
  PL^.Position[1]:=Position.Y;
  PL^.Position[2]:=Position.Z;

  PL^.Brightness:=Brightness;
  PL^.Brightness2:=Brightness*Brightness;

  PL^.Color:={SwapColor(Color)} Color and $FFFFFF;

  PL^.Min[0]:=Position.X-Brightness;
  PL^.Min[1]:=Position.Y-Brightness;
  PL^.Min[2]:=Position.Z-Brightness;

  PL^.Max[0]:=Position.X+Brightness;
  PL^.Max[1]:=Position.Y+Brightness;
  PL^.Max[2]:=Position.Z+Brightness;

  NumberOfLights:=NumberOfLights+1;
end;

function TGLSceneObject.StartBuildScene({var PW: TPaletteWarning;} var VertexSize: Integer) : TBuildMode;
var
  I: Integer;
begin
 {PW:=Nil;}
  VertexSize:=SizeOf(TVertex3D);
  Result:=bmOpenGL;
  if RenderingTextureBuffer=Nil then
    RenderingTextureBuffer:=TMemoryStream.Create;
  for I:=0 to 2 do
  begin
    if OpenGLDisplayLists[I]<>0 then
    begin
      SetLength(DisplayListsToDelete,Length(DisplayListsToDelete)+1);
      DisplayListsToDelete[Length(DisplayListsToDelete)-1]:=OpenGLDisplayLists[I];
      OpenGLDisplayLists[I]:=0;
    end;
  end;
  if wglMakeCurrent(ViewDC,RC) = false then
    raise EError(6310);
  for I:=0 to Length(DisplayListsToDelete)-1 do
  begin
    glDeleteLists(1,DisplayListsToDelete[I]);
    CheckOpenGLError(glGetError);
  end;
  SetLength(DisplayListsToDelete,0);
  for I:=0 to Length(TexturesToDelete)-1 do
  begin
    glDeleteTextures(1,TexturesToDelete[I]);
    CheckOpenGLError(glGetError);
  end;
  SetLength(TexturesToDelete,0);
  wglMakeCurrent(0,0);
end;

procedure TGLSceneObject.EndBuildScene;
begin
  RenderingTextureBuffer.Free;
  RenderingTextureBuffer:=Nil;
end;

procedure TGLSceneObject.Render3DView;
var
 SX, SY: Integer;
 DX, DY, DZ: Double;
 VX, VY, VZ: TVect;
 Scaling: TDouble;
 LocX, LocY: GLdouble;
 TransX, TransY, TransZ: GLdouble;
 MatrixTransform: TMatrix4f;
 PS: PSurfaces;
 PO: POpenGLLightingList;
 Surf: PSurface3D;
 SurfEnd: PChar;
 PL: PLightList;
 PV: PVertex3D;
 Distance: Double;
 LargestDistance: Double;
 FirstItem: Boolean;
 DistanceList: array of Double;
 TempDistance: Double;
 TempLight: LongInt;
 VertexNR: Integer;
 SurfAveragePosition: vec3_t;
 PAveragePosition: vec3_t;
 LightNR: LongInt;
 LightCurrent: LongInt;
 LightList: LongInt;
 Sz: Integer;
 PList: PSurfaces;
 CurrentPList: PSurfaces;
 RebuildDisplayList: Boolean;
begin
  if not OpenGlLoaded then
    Exit;
  if wglMakeCurrent(ViewDC,RC) = false then
   raise EError(6310);
  {$IFDEF DebugGLErr} DebugOpenGL(49); {$ENDIF}
  SX:=ScreenX;
  SY:=ScreenY;
  glViewport(0, 0, SX, SY);   {Viewport width and height are silently clamped to a range that depends on the implementation. This range is queried by calling glGet with argument GL_MAX_VIEWPORT_DIMS.}
  {$IFDEF DebugGLErr} DebugOpenGL(50, '', []); {$ENDIF}

  CheckOpenGLError(glGetError);

  if Coord.FlatDisplay then
   begin
    if CurrentDisplayType=dtXY then
     begin
      with TXYCoordinates(Coord) do
       begin
        Scaling:=ScalingFactor(Nil);
        LocX:=pDeltaX-ScrCenter.X;
        LocY:=-(pDeltaY-ScrCenter.Y);
        VX:=VectorX;
        VY:=VectorY;
        VZ:=VectorZ;
       end;
     end
    else if CurrentDisplayType=dtXZ then
     begin
      with TXZCoordinates(Coord) do
       begin
        Scaling:=ScalingFactor(Nil);
        LocX:=pDeltaX-ScrCenter.X;
        LocY:=-(pDeltaY-ScrCenter.Y);
        VX:=VectorX;
        VY:=VectorY;
        VZ:=VectorZ;
       end;
     end
    else {if (CurrentDisplayType=dtYZ) or (CurrentDisplayType=dt2D) then}
     begin
      with T2DCoordinates(Coord) do
       begin
        Scaling:=ScalingFactor(Nil);
        LocX:=pDeltaX-ScrCenter.X;
        LocY:=-(pDeltaY-ScrCenter.Y);
        VX:=VectorX;
        VY:=VectorY;
        VZ:=VectorZ;
       end;
     end;
    DX:=(SX/2)/(Scaling*Scaling);
    DY:=(SY/2)/(Scaling*Scaling);
    {DZ:=(MapLimitSmallest*2)/(Scaling*Scaling);}
    DZ:=100000;   //DanielPharos: Workaround for the zoom-in-disappear problem
    TransX:=LocX/(Scaling*Scaling);
    TransY:=LocY/(Scaling*Scaling);
    TransZ:=-MapLimitSmallest;
    MatrixTransform[0,0]:=VX.X;
    MatrixTransform[0,1]:=-VY.X;
    MatrixTransform[0,2]:=-VZ.X;
    MatrixTransform[0,3]:=0;
    MatrixTransform[1,0]:=VX.Y;
    MatrixTransform[1,1]:=-VY.Y;
    MatrixTransform[1,2]:=-VZ.Y;
    MatrixTransform[1,3]:=0;
    MatrixTransform[2,0]:=VX.Z;
    MatrixTransform[2,1]:=-VY.Z;
    MatrixTransform[2,2]:=-VZ.Z;
    MatrixTransform[2,3]:=0;
    MatrixTransform[3,0]:=0;
    MatrixTransform[3,1]:=0;
    MatrixTransform[3,2]:=0;
    MatrixTransform[3,3]:=1;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    glOrtho(-DX, DX, -DY, DY, -DZ, DZ);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glTranslated(TransX, TransY, TransZ);
    glMultMatrixd(MatrixTransform);
   end
  else
   begin
    with TCameraCoordinates(Coord) do
     begin
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      {gluPerspective(VCorrection2*VAngleDegrees, SX/SY, FarDistance / Power(2, DepthBufferBits), FarDistance);}
      gluPerspective(VCorrection2*VAngleDegrees, SX/SY, FarDistance / 65536, FarDistance);     //DanielPharos: Assuming 16 bit depth buffer

      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity;
      glRotated(PitchAngle * (180/pi), -1,0,0);
      glRotated(HorzAngle * (180/pi), 0,-1,0);
      glRotated(120, -1,1,1);
      TransX:=-Camera.X;
      TransY:=-Camera.Y;
      TransZ:=-Camera.Z;
      glTranslated(TransX, TransY, TransZ);
     end;
   end;
  CheckOpenGLError(glGetError);

  if (Lighting and (LightingQuality=0)) or Transparency then
  begin
    PS:=FListSurfaces;
    while Assigned(PS) do
    begin
      if (Lighting and (LightingQuality=0)) or (Transparency and ((PS^.Transparent=True) or (PS^.NumberTransparentFaces>0))) then
      begin
        Surf:=PS^.Surf;
        SurfEnd:=PChar(Surf)+PS^.SurfSize;
        PAveragePosition[0]:=0;
        PAveragePosition[1]:=0;
        PAveragePosition[2]:=0;
        while (Surf<SurfEnd) do
        begin
          with Surf^ do
          begin
            Inc(Surf);
            SurfAveragePosition[0]:=0;
            SurfAveragePosition[1]:=0;
            SurfAveragePosition[2]:=0;
            if not (VertexCount = 0) then
            begin
              PV:=PVertex3D(Surf);
              if VertexCount>=0 then
                Sz:=SizeOf(TVertex3D)
              else
                Sz:=SizeOf(TVertex3D)+SizeOf(vec3_t);
              for VertexNR:=1 to Abs(VertexCount) do
              begin
                SurfAveragePosition[0]:=SurfAveragePosition[0]+PV^.xyz[0];
                SurfAveragePosition[1]:=SurfAveragePosition[1]+PV^.xyz[1];
                SurfAveragePosition[2]:=SurfAveragePosition[2]+PV^.xyz[2];
                Inc(PChar(PV), Sz);
              end;
              SurfAveragePosition[0]:=SurfAveragePosition[0]/VertexCount;
              SurfAveragePosition[1]:=SurfAveragePosition[1]/VertexCount;
              SurfAveragePosition[2]:=SurfAveragePosition[2]/VertexCount;
            end;
            PAveragePosition[0]:=PAveragePosition[0]+SurfAveragePosition[0];
            PAveragePosition[1]:=PAveragePosition[1]+SurfAveragePosition[1];
            PAveragePosition[2]:=PAveragePosition[2]+SurfAveragePosition[2];
            OpenGLAveragePosition:=SurfAveragePosition;
            if VertexCount>=0 then
              Inc(PVertex3D(Surf), VertexCount)
            else
              Inc(PChar(Surf), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
          end;
        end;
      end;
      PS.OpenGLAveragePosition:=PAveragePosition;
      PS:=PS^.Next;
    end;
  end;

  if Lighting and (LightingQuality=0) then
  begin
    PS:=FListSurfaces;
    while Assigned(PS) do
    begin
      Surf:=PS^.Surf;
      SurfEnd:=PChar(Surf)+PS^.SurfSize;
      while (Surf<SurfEnd) do
      begin
        with Surf^ do
        begin
          Inc(Surf);
          if not (OpenGLLightList = nil) then
          begin
            FreeMem(OpenGLLightList);
            OpenGLLightList := nil;
          end;
          if (NumberOfLights<MaxLights) then
          begin
            GetMem(OpenGLLightList, NumberOfLights*sizeof(LongInt));
            PO:=OpenGLLightList;
            for LightNR := 0 to NumberOfLights-1 do
            begin
              PO^:=LightNR;
              Inc(PO);
            end;
          end
          else
          begin
            SetLength(DistanceList, MaxLights);
            for LightNR:=0 to MaxLights-1 do
            begin
              DistanceList[LightNR]:=-1;
            end;
            GetMem(OpenGLLightList, MaxLights*sizeof(LongInt));
            PL:=Lights;
            LightCurrent:=0;
            while Assigned(PL) do
            begin
              Distance:=(OpenGLAveragePosition[0]-PL.Position[0])*(OpenGLAveragePosition[0]-PL.Position[0])+(OpenGLAveragePosition[1]-PL.Position[1])*(OpenGLAveragePosition[1]-PL.Position[1])+(OpenGLAveragePosition[2]-PL.Position[2])*(OpenGLAveragePosition[2]-PL.Position[2]);
              //DanielPharos: Actually, this is distance squared. But we're only comparing, not calculating!
              LightList:=LightCurrent;
              PO:=OpenGLLightList;
              for LightNR:=0 to MaxLights-1 do
              begin
                if DistanceList[LightNR] = -1 then
                begin
                  DistanceList[LightNR]:=Distance;
                  PO^:=LightList;
                  break;
                end;
                if Distance < DistanceList[LightNR] then
                begin
                  TempDistance:=Distance;
                  Distance:=DistanceList[LightNR];
                  DistanceList[LightNR]:=TempDistance;
                  TempLight:=PO^;
                  PO^:=LightList;
                  LightList:=TempLight;
                end;
                Inc(PO);
              end;
              PL:=PL^.Next;
              LightCurrent:=LightCurrent+1;
            end;
          end;
          if VertexCount>=0 then
            Inc(PVertex3D(Surf), VertexCount)
          else
            Inc(PChar(Surf), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
        end;
      end;
      PS:=PS^.Next;
    end;
  end;

  {$IFDEF DebugGLErr} DebugOpenGL(51, 'glClear', []); {$ENDIF}
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); { clear screen }
  CurrentAlpha:=0;
  FillChar(Currentf, SizeOf(Currentf), 0);

  case ViewMode of
  vmWireframe:
    begin
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_COLOR_MATERIAL);
    end;
  vmSolidcolor:
    begin
      glDisable(GL_TEXTURE_2D);
      glDisable(GL_COLOR_MATERIAL);
    end;
  vmTextured:
    begin
      glEnable(GL_TEXTURE_2D);
      glEnable(GL_COLOR_MATERIAL);
    end;
  else
    begin
      glEnable(GL_TEXTURE_2D);
      glEnable(GL_COLOR_MATERIAL);
    end;
  end;
  CheckOpenGLError(glGetError);

  RebuildDisplayList:=False;
  if DisplayLists then
  begin
    if (OpenGLDisplayLists[LightingQuality]=0) then
    begin
      OpenGLDisplayLists[LightingQuality]:=glGenLists(1);
      if OpenGLDisplayLists[LightingQuality] = 0 then
        raise EError(6313);

      {$IFDEF DebugGLErr} DebugOpenGL(-110, 'glNewList(<%d>, <%d>)', [OpenGLDisplayLists[LightingQuality], GL_COMPILE_AND_EXECUTE]); {$ENDIF}
      glNewList(OpenGLDisplayLists[LightingQuality], GL_COMPILE_AND_EXECUTE);
      {$IFDEF DebugGLErr} DebugOpenGL(110, 'glNewList(<%d>, <%d>)', [OpenGLDisplayLists[LightingQuality], GL_COMPILE_AND_EXECUTE]); {$ENDIF}

      CheckOpenGLError(glGetError);
      RebuildDisplayList:=True;
    end;
  end;

  if RebuildDisplayList or not (DisplayLists) then
  begin
    PList:=FListSurfaces;
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

    if RebuildDisplayList then
    begin
      {$IFDEF DebugGLErr} DebugOpenGL(-113, 'glEndList', []); {$ENDIF}
      glEndList;
      {$IFDEF DebugGLErr} DebugOpenGL(113, 'glEndList', []); {$ENDIF}
      CheckOpenGLError(glGetError);
    end;
  end
  else
  begin
    {$IFDEF DebugGLErr} DebugOpenGL(-114, 'glCallList(<%d>)', [OpenGLDisplayLists[LightingQuality]]); {$ENDIF}
    glCallList(OpenGLDisplayLists[LightingQuality]);
    {$IFDEF DebugGLErr} DebugOpenGL(114, 'glCallList(<%d>)', [OpenGLDisplayLists[LightingQuality]]); {$ENDIF}
    CheckOpenGLError(glGetError);
  end;

  if Transparency then
  begin
    glDisable(GL_CULL_FACE);
    CheckOpenGLError(glGetError);

    PList:=FListSurfaces;
    while Assigned(PList) do
    begin
      if (PList^.Transparent=True) or (PList^.NumberTransparentFaces>0) then
      begin
        PList^.TransparentDrawn:=false;
        PList.OpenGLDistance:=(Plist.OpenGLAveragePosition[0]-TransX)*(Plist.OpenGLAveragePosition[0]-TransX)+(Plist.OpenGLAveragePosition[1]-TransY)*(Plist.OpenGLAveragePosition[1]-TransY)+(Plist.OpenGLAveragePosition[2]-TransZ)*(Plist.OpenGLAveragePosition[2]-TransZ);
      end
      else
        PList^.TransparentDrawn:=true;
      PList:=PList^.Next;
    end;
    repeat
      FirstItem:=true;
      LargestDistance:=-1;
      CurrentPList:=nil;
      PList:=FListSurfaces;
      while Assigned(PList) do
      begin
        if PList^.TransparentDrawn=false then
        begin
          Distance:=PList.OpenGLDistance;
          //DanielPharos: Actually, this is distance squared. But we're only comparing, not calculating!
          if (FirstItem or ((not FirstItem) and (Distance>LargestDistance))) then
          begin
            FirstItem:=false;
            LargestDistance:=Distance;
            CurrentPList:=Plist;
          end;
        end;
        PList:=PList^.Next;
      end;

      if not (CurrentPList=nil) then
      begin
        RenderPList(CurrentPList, True, Coord);
        CurrentPList^.TransparentDrawn:=true;
      end;
    until (CurrentPList=nil);
    if Culling then
    begin
      glEnable(GL_CULL_FACE);
      glFrontFace(GL_CW);
      CheckOpenGLError(glGetError);
    end;
  end;

  {$IFDEF DebugGLErr} DebugOpenGL(54, 'glFinish', []); {$ENDIF}
  glFinish;
  {$IFDEF DebugGLErr} DebugOpenGL(55, '', []); {$ENDIF}
  wglMakeCurrent(0,0);
end;

procedure TGLSceneObject.BuildTexture(Texture: PTexture3);
var
 TexData: PChar;
 MemSize, W, H, J: Integer;
 Alphasource, Source, Dest: PChar;
 PaletteEx: array[0..255] of LongInt;
{BasePalette: Pointer;}
 PSD, PSD2: TPixelSetDescription;
 GammaBuf: Pointer;
 MaxTexDim: GLint;
 NumberOfComponents: GLint;
 BufferType: GLenum;
begin
  if Texture^.OpenGLName=0 then
  begin
    {$IFDEF DebugGLErr}
    if (Texture^.SourceTexture <> nil) then
      DebugOpenGL(-104, 'BuildTexture(<%s>)', [Texture^.SourceTexture.Name])
    else
      DebugOpenGL(-104, 'BuildTexture(<Nil>)', []);
    {$ENDIF}

 (*   // This broke OpenGL for odd sized textures in version 1.24 2004/12/14
    PSD:=GetTex3Description(Texture^);

    //normally this would also handle paletted textures, but it breaks
    //Q2 models . so we have to keep the assembler stuff till it is understood
    //and fixed
    if PSD.Format = psf24bpp then
    begin
    try

      //a paletted textures is convert to BGR format first and flipped
      PSD2.Init;
      PSD2.Format := psf24bpp;
      PSD2.Palette := pspDefault;
      PSD2.AlphaBits := PSD.AlphaBits;
      PSD2.Size:=PSD.Size;
      PSD2.FlipBottomUp;
      PSDConvert(PSD2, PSD, 0);

      //tbd: setup gamma at gl window setup}

      glGenTextures(1, Texture^.OpenGLName);
      {$IFDEF DebugGLErr} DebugOpenGL(104, 'glGenTextures(1, <%d>)', [Texture^.OpenGLName]); {$ENDIF}
      if Texture^.OpenGLName=0 then
        Raise InternalE(LoadStr(6314));
      glBindTexture(GL_TEXTURE_2D, Texture^.OpenGLName);
      {$IFDEF DebugGLErr} DebugOpenGL(105, '', []); {$ENDIF}

      //making use of alpha channel of textures
      if PSD2.AlphaBits = psa8bpp then
      begin
        MemSize:=PSD2.Size.X * PSD2.Size.Y * 4;
        RenderingTextureBuffer.SetSize(MemSize);
        TexData:=RenderingTextureBuffer.Memory;
        Source:=PSD2.Data;
        AlphaSource:=PSD2.AlphaData;
        Dest:=TexData;
        J:= PSD2.Size.X * PSD2.Size.Y;

        // tbd: more efficient copying
        while J > 0 do
        begin
          Dest^ := Source^;        inc(Source);      Inc(Dest);
          Dest^ := Source^;        inc(Source);      Inc(Dest);
          Dest^ := Source^;        inc(Source);      Inc(Dest);
          Dest^ := AlphaSource^;   inc(AlphaSource); Inc(Dest);
          Dec(J);
        end;
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,PSD2.Size.X, PSD2.Size.Y,0, GL_BGRA, GL_UNSIGNED_BYTE, TexData);
      end       // end of making use of alpha channel of textures
      else
        glTexImage2D(GL_TEXTURE_2D, 0, 3,PSD2.Size.X, PSD2.Size.Y,0, GL_BGR, GL_UNSIGNED_BYTE, PSD2.Data);

    finally
      PSD.Done;
      PSD2.Done;
    end;
    end
    else
    begin //handle paletted textures   *)

    {GetwhForTexture(Texture^.info, W, H);}
    
    if wglMakeCurrent(ViewDC,RC) = false then
      raise EError(6310);
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, @MaxTexDim);
    CheckOpenGLError(glGetError);
    wglMakeCurrent(0,0);
    if MaxTexDim<=0 then
      MaxTexDim:=256;
    W:=Texture^.LoadedTexW;
    H:=Texture^.LoadedTexH;
    while (W>MaxTexDim) or (H>MaxTexDim) do
     begin
      W:=W div 2;
      H:=H div 2;
     end;

    MemSize:=W*H*4;

    if RenderingTextureBuffer.Size < MemSize then
      RenderingTextureBuffer.SetSize(MemSize);

    TexData:=RenderingTextureBuffer.Memory;

    PSD2.Init;
   // Removing line below broke OpenGL for odd sized textures in version 1.24 2004/12/14
    {PSD2.AlphaBits:=psaNoAlpha;}
    PSD:=GetTex3Description(Texture^);

    try
      PSD2.Size.X:=W;
      PSD2.Size.Y:=H;
      PSDConvert(PSD2, PSD, ccTemporary);

      Source:=PSD2.StartPointer;
      Dest:=TexData;

      GammaBuf:=@(TTextureManager.GetInstance.GammaBuffer);

      NumberOfComponents:=3;
      BufferType:=GL_RGB;
      if PSD2.Format = psf24bpp then
      begin
        if (PSD2.AlphaBits = psa8bpp) then
        begin
          NumberOfComponents:=4;
          BufferType:=GL_RGBA;
          AlphaSource:=PSD2.AlphaStartPointer;
          for J:=1 to H do
          begin
            asm
             push esi
             push edi
             push ebx
             mov ecx, [W]             { get the width, and put it into ecx-register, for the 'loop' to work with }
             mov esi, [Source]        { get the Source-pointer, and put it into esi-register }
             mov edi, [Dest]          { get the Dest-pointer, and put it into edi-register }
             mov ebx, [AlphaSource]   { get the AlphaSource-pointer, and put it into ebx-register }
             cld
             xor edx, edx             { clear the edx-register value (edx-high-register must be zero!) }

             @xloop:
              mov dl, [esi+2]         { copy 'Red' byte from source to edx-low-register }
              mov al, dl          {R} { copy the gamma-corrected 'Red'-byte from gammabuf to eax-low-register }
              mov dl, [esi+1]         { copy 'Green' byte from source to edx-low-register }
              mov ah, dl          {G} { copy the gamma-corrected 'Green'-byte from gammabuf to eax-high-register }
              stosw                   { store the two-byte (word) eax value to dest which edi-register points to, and increment edi with 2 }
              mov dl, [esi]           { copy 'Blue' byte from source to edx-low-register }
              mov al, dl          {B} { copy the gamma-corrected 'Blue'-byte from gammabuf to eax-low-register }
              mov dl, [ebx]
              mov ah, dl
              stosw                   { store the two-byte (word) eax value to dest which edi-register points to, and increment edi with 2 }
              add esi, 3              { increment source-pointer, the esi-register with 3 }
              add ebx, 1              { increment alphasource-pointer, the ebx-register with 1 }
             loop @xloop              { decrement ecx-register with 1, and continue to loop if ecx value is bigger than zero }

             mov [Dest], edi          { put the now incremented edi-register value, back as the Dest-pointer }
             pop ebx
             pop edi
             pop esi
            end;
            Inc(Source, PSD2.ScanLine);
            Inc(AlphaSource, PSD2.AlphaScanLine);
          end;
        end
        else
        begin
          { Make a gamma-corrected copy of the 24-bits (RGB) texture to TexData-buffer }
          for J:=1 to H do
          begin
            asm
             push esi
             push edi
             push ebx
             mov ecx, [W]             { get the width, and put it into ecx-register, for the 'loop' to work with }
             mov esi, [Source]        { get the Source-pointer, and put it into esi-register }
             mov edi, [Dest]          { get the Dest-pointer, and put it into edi-register }
             mov ebx, [GammaBuf]      { get the GammaBuf-pointer, and put it into ebx-register }
             cld
             xor edx, edx             { clear the edx-register value (edx-high-register must be zero!) }

             @xloop:
              mov dl, [esi+2]         { copy 'Red' byte from source to edx-low-register }
              mov al, [ebx+edx]   {R} { copy the gamma-corrected 'Red'-byte from gammabuf to eax-low-register }
              mov dl, [esi+1]         { copy 'Green' byte from source to edx-low-register }
              mov ah, [ebx+edx]   {G} { copy the gamma-corrected 'Green'-byte from gammabuf to eax-high-register }
              stosw                   { store the two-byte (word) eax value to dest which edi-register points to, and increment edi with 2 }
              mov dl, [esi]           { copy 'Blue' byte from source to edx-low-register }
              mov al, [ebx+edx]   {B} { copy the gamma-corrected 'Blue'-byte from gammabuf to eax-low-register }
              stosb                   { store the single-byte eax-low-register value to dest which edi-register points to, and increment edi with 1 }
              add esi, 3              { increment source-pointer, the esi-register with 3 }
             loop @xloop              { decrement ecx-register with 1, and continue to loop if ecx value is bigger than zero }

             mov [Dest], edi          { put the now incremented edi-register value, back as the Dest-pointer }
             pop ebx
             pop edi
             pop esi
            end;
            Inc(Source, PSD2.ScanLine);
          end;
        end;
      end
      else
      begin
        { Make a gamma-corrected RGBA-palette with 256 entries, from an RGB-palette.
          Note that the Alpha-value (of RGBA) will never be used, as it contains
          un-initialized values. }
        asm
         push edi
         push esi
         push ebx
         mov esi, [PSD2.ColorPalette] { get the RGB-palette-pointer, and put it into esi-register }
         add esi, 3*255               { increment esi-register, so it points at the last palette-entry }
         lea edi, [PaletteEx]         { load PaletteEx-pointer to the edi-register }
         mov ebx, [GammaBuf]          { get the GammaBuf-pointer, and put it into ebx-register }
         mov ecx, 255                 { there are 256 entries in the palette, load ecx-register to act as a counter }
         xor edx, edx                 { clear the edx-register value (edx-high-register must be zero!) }

         @Loop1:
          mov dl, [esi+2]             { copy 'Blue' byte from source to edx-low-register }
          mov ah, [ebx+edx]   {B}     { copy the gamma-corrected 'Blue'-byte from gammabuf to eax-high-register }
          shl eax, 8                  { shift eax-register 8 bits to the left, effectually multiplying it with 256 }
          mov dl, [esi+1]             { copy 'Green' byte from source to edx-low-register }
          mov ah, [ebx+edx]   {G}     { copy the gamma-corrected 'Green'-byte from gammabuf to eax-high-register }
          mov dl, [esi]               { copy 'Red' byte from source to edx-low-register }
          mov al, [ebx+edx]   {R}     { copy the gamma-corrected 'Red'-byte from gammabuf to eax-low-register }
          mov [edi+4*ecx], eax        { store the four-byte eax-register to PaletteEx-pointer + (4 * ecx-register value) }
          sub esi, 3                  { subtract 3 from esi-register, moving backwards in the RGB-palette entries }
          dec ecx                     { decrement ecx-register counter with 1, and set the sign-flag if decrements beyond 0 }
         jns @Loop1                   { jump to Loop1 if the decrement did not set the sign-flag }

         pop ebx
         pop esi
         pop edi
        end;

        { Make a gamma-corrected copy of the 256-color-texture to a 24-bits (RGB) TexData-buffer,
          using the RGBA-palette for RGB-color lookup. }
        for J:=1 to H do
        begin
          asm
           push edi
           push esi
           push ebx
           mov ecx, [W]               { get the width, and put it into ecx-register, for the 'loop' to work with }
           mov esi, [Source]          { get the Source-pointer, and put it into esi-register }
           mov edi, [Dest]            { get the Dest-pointer, and put it into edi-register }
           lea ebx, [PaletteEx]       { get the RGBA-palette-pointer, and put it into ebx-register }
           cld
           xor edx, edx               { clear the edx-register value (edx-high-register must be zero!) }

           @xloop:
            mov dl, [esi]             { copy the 'palette-index' byte from source to edx-low-register }
            mov eax, [ebx+4*edx]      { get the RGBA-color from the RGBA-palette, and put it into eax-register }
            stosw                     { store the two-byte (word) eax value to dest which edi-register points to, and increment edi with 2 }
            shr eax, 16               { shift eax-register 16 bits to the right, effectually dividing it by 65536 }
            stosb                     { store the single-byte eax-low-register value to dest which edi-register points to, and increment edi with 1 }
            inc esi                   { increment source-pointer, the esi-register with 1 }
           loop @xloop                { decrement ecx-register with 1, and continue to loop if ecx value is bigger than zero }

           mov [Dest], edi            { put the now incremented edi-register value, back as the Dest-pointer }
           pop ebx
           pop esi
           pop edi
          end;

          Inc(Source, PSD2.ScanLine);
        end;
      end;
    finally
      PSD.Done;
      PSD2.Done;
    end;

    if wglMakeCurrent(ViewDC,RC) = false then
     raise EError(6310);
    {gluBuild2DMipmaps(GL_TEXTURE_2D, 3, W, H, GL_RGBA, GL_UNSIGNED_BYTE, TexData^);}
    {$IFDEF DebugGLErr} DebugOpenGL(104, 'glGenTextures(1, <%d>)', [Texture^.OpenGLName]); {$ENDIF}
    glGenTextures(1, Texture^.OpenGLName);
    CheckOpenGLError(glGetError);

    if Texture^.OpenGLName=0 then
      Raise InternalE(LoadStr(6314));
    {$IFDEF DebugGLErr} DebugOpenGL(105, 'glBindTexture(GL_TEXTURE_2D, <%d>)', [Texture^.OpenGLName]); {$ENDIF}
    glBindTexture(GL_TEXTURE_2D, Texture^.OpenGLName);

    {$IFDEF DebugGLErr} DebugOpenGL(106, '', []); {$ENDIF}
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    if Bilinear then
    begin
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    end
    else
    begin
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    end;
    CheckOpenGLError(glGetError);

      // To reverse changes that broke OpenGL for odd sized textures in version 1.24 2004/12/14
    glTexImage2D(GL_TEXTURE_2D, 0, NumberOfComponents, W, H, 0, BufferType, GL_UNSIGNED_BYTE, TexData^);
  (*  glTexImage2D(GL_TEXTURE_2D, 0, 3, W, H, 0, GL_RGB, GL_UNSIGNED_BYTE, TexData)
    end;//paletted textures   *)
    CheckOpenGLError(glGetError);

    wglMakeCurrent(0,0);

    {$IFDEF DebugGLErr} DebugOpenGL(107, '', []); {$ENDIF}
  end;
end;

procedure TGLSceneObject.RenderPList(PList: PSurfaces; TransparentFaces: Boolean; SourceCoord: TCoordinates);
var
 CurrentSurf: PSurface3D;
 Surf: PSurface3D;
 Surf2: PSurface3D;
 SurfEnd: PChar;
 PV, PVBase, PV2, PV3: PVertex3D;
 NeedTex, NeedColor: Boolean;
 I: Integer;
 MaxLightNumber: LongInt;
 LightIndex: LongInt;
 PL: PLightList;
 PO: POpenGLLightingList;
 LightNR: LongInt;
 LightParam: array[0..3] of GLfloat;
 GLColor: GLfloat4;
 PSD: TPixelSetDescription;
 CurrentfTMP: GLfloat4;
 Distance: Double;
 LargestDistance: Double;
 FirstItem: Boolean;
 Scaling: TDouble;
 LocX, LocY: GLdouble;
 TransX, TransY, TransZ: GLdouble;
begin
  case ViewMode of
  vmWireframe:
    begin
      NeedColor:=False;
      NeedTex:=False;
    end;
  vmSolidcolor:
    begin
      NeedColor:=True;
      NeedTex:=False;
    end;
  vmTextured:
    begin
      NeedColor:=False;
      NeedTex:=True;
    end;
  else
    begin
      NeedColor:=False;
      NeedTex:=True;
    end;
  end;

  if (NumberOfLights<MaxLights) then
    MaxLightNumber:=NumberOfLights
  else
    MaxLightNumber:=MaxLights;
  for LightNR := 0 to MaxLights-1 do
  begin
    if (LightNR<NumberOfLights) then
      glEnable(GL_LIGHT0+LightNR)
    else
      glDisable(GL_LIGHT0+LightNR);
    CheckOpenGLError(glGetError);
  end;
  if Lighting and (LightingQuality=0) then
    glEnable(GL_LIGHTING)
  else
    glDisable(GL_LIGHTING);
  CheckOpenGLError(glGetError);

  {if Transparency and TransparentFaces then
  begin}
    if Coord.FlatDisplay then
    begin
      if CurrentDisplayType=dtXY then
      begin
        with TXYCoordinates(Coord) do
        begin
          Scaling:=ScalingFactor(Nil);
          LocX:=pDeltaX-ScrCenter.X;
          LocY:=-(pDeltaY-ScrCenter.Y);
        end;
      end
      else if CurrentDisplayType=dtXZ then
      begin
        with TXZCoordinates(Coord) do
        begin
          Scaling:=ScalingFactor(Nil);
          LocX:=pDeltaX-ScrCenter.X;
          LocY:=-(pDeltaY-ScrCenter.Y);
        end;
      end
      else {if (CurrentDisplayType=dtYZ) or (CurrentDisplayType=dt2D) then}
      begin
        with T2DCoordinates(Coord) do
        begin
          Scaling:=ScalingFactor(Nil);
          LocX:=pDeltaX-ScrCenter.X;
          LocY:=-(pDeltaY-ScrCenter.Y);
        end;
      end;
      TransX:=LocX/(Scaling*Scaling);
      TransY:=LocY/(Scaling*Scaling);
      TransZ:=-MapLimitSmallest;
    end
    else
    begin
      with TCameraCoordinates(Coord) do
      begin
        TransX:=-Camera.X;
        TransY:=-Camera.Y;
        TransZ:=-Camera.Z;
      end;
    end;
  {end;}

  if Transparency and TransparentFaces then
  begin
    Surf:=PList^.Surf;
    SurfEnd:=PChar(Surf)+PList^.SurfSize;
    while Surf<SurfEnd do
    begin
      with Surf^ do
      begin
        Inc(Surf);

        TransparentDrawn:=false;

        if VertexCount>=0 then
          Inc(PVertex3D(Surf), VertexCount)
        else
          Inc(PChar(Surf), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
      end;
    end;
  end;

  Surf:=PList^.Surf;
  SurfEnd:=PChar(Surf)+PList^.SurfSize;
  while Surf<SurfEnd do
  begin
    if Transparency and TransparentFaces then
    begin
      FirstItem:=true;
      LargestDistance:=-1;
      Surf2:=PList^.Surf;
      CurrentSurf:=nil;
      while Surf2<SurfEnd do
      begin
        with Surf2^ do
        begin
          if TransparentDrawn=false then
          begin
            Distance:=(OpenGLAveragePosition[0]-TransX)*(OpenGLAveragePosition[0]-TransX)+(OpenGLAveragePosition[1]-TransY)*(OpenGLAveragePosition[1]-TransY)+(OpenGLAveragePosition[2]-TransZ)*(OpenGLAveragePosition[2]-TransZ);
            //DanielPharos: Actually, this is distance squared. But we're only comparing, not calculating!

            if (FirstItem or ((not FirstItem) and (Distance>LargestDistance))) then
            begin
              FirstItem:=false;
              LargestDistance:=Distance;
              CurrentSurf:=Surf2;
            end;
          end;

          Inc(Surf2);

          if VertexCount>=0 then
            Inc(PVertex3D(Surf2), VertexCount)
          else
            Inc(PChar(Surf2), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
        end;
      end;
      if CurrentSurf=nil then
        raise InternalE(LoadStr1(6321));
      CurrentSurf^.TransparentDrawn:=true;
    end
    else
      CurrentSurf:=Surf;

    with CurrentSurf^ do
    begin
      Inc(CurrentSurf);
      
      if ((PList^.Transparent=TransparentFaces) or (((AlphaColor and $FF000000)=$FF000000) xor TransparentFaces)) then
      begin

      if Lighting and (LightingQuality=0) then
      begin
        if not(OpenGLLightList = nil) then
        begin
          for LightNR := 0 to MaxLightNumber-1 do
          begin
            PO:=OpenGLLightList;
            for LightIndex := 1 to LightNR do
              Inc(PO);
            PL:=Lights;
            for LightIndex := 0 to PO^-1 do
              PL:=PL^.Next;
            LightParam[0]:=PL.Position[0];
            LightParam[1]:=PL.Position[1];
            LightParam[2]:=PL.Position[2];
            LightParam[3]:=1.0;

            glLightfv(GL_LIGHT0+LightNR, GL_POSITION, @LightParam);
            CheckOpenGLError(glGetError);

            UnpackColor(PL.Color, GLColor);
            LightParam[0]:=GLColor[0];
            LightParam[1]:=GLColor[1];
            LightParam[2]:=GLColor[2];
            //LightParam[3]:=GLColor[3];
            LightParam[3]:=1.0;
            glLightfv(GL_LIGHT0+LightNR, GL_DIFFUSE, @LightParam);
            CheckOpenGLError(glGetError);

            glLightf(GL_LIGHT0+LightNR, GL_CONSTANT_ATTENUATION, 1.0);
            glLightf(GL_LIGHT0+LightNR, GL_LINEAR_ATTENUATION, 0.0);
            glLightf(GL_LIGHT0+LightNR, GL_QUADRATIC_ATTENUATION, 5.0/PL.Brightness2);
            CheckOpenGLError(glGetError);
          end;
        end;
      end;

      CurrentAlpha:=AlphaColor;
      UnpackColor(AlphaColor, Currentf);

      if NeedColor then
      begin
        with PList^.Texture^ do
        begin
          if MeanColor = MeanColorNotComputed then
          begin
            PSD:=GetTex3Description(PList^.Texture^);
            try
              MeanColor:=ComputeMeanColor(PSD);
            finally
              PSD.Done;
            end;
          end;
          UnpackColor(MeanColor, CurrentfTMP);
          Currentf[0]:=Currentf[0]*CurrentfTMP[0];
          Currentf[1]:=Currentf[1]*CurrentfTMP[1];
          Currentf[2]:=Currentf[2]*CurrentfTMP[2];
          Currentf[3]:=Currentf[3];
        end;
      end;

      if NeedTex then
      begin
        {$IFDEF Debug}
        if PList^.Texture^.OpenGLName=0 then
          Raise InternalE(LoadStr1(6010));
        {$ENDIF}
        {$IFDEF DebugGLErr} DebugOpenGL(-108, '', []); {$ENDIF}
        glBindTexture(GL_TEXTURE_2D, PList^.Texture^.OpenGLName);
        {$IFDEF DebugGLErr} DebugOpenGL(108, '', []); {$ENDIF}
        CheckOpenGLError(glGetError);
      end;

      PV:=PVertex3D(CurrentSurf);

      if Transparency and TransparentFaces then
      begin
        {$IFDEF DebugGLErr} DebugOpenGL(-112, '', []); {$ENDIF}
        glColor4fv(Currentf);
        {$IFDEF DebugGLErr} DebugOpenGL(112, '', []); {$ENDIF}

        Case TextureMode of
        0:
          glBlendFunc(GL_ONE, GL_ZERO);
        1,2,3:
          glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        4:
          glBlendFunc(GL_ONE, GL_ZERO);
        5:
          glBlendFunc(GL_ONE, GL_ONE);
        end;
      end;

      if VertexCount>=0 then
      begin  { normal polygon }
        PVBase:=PV;
        if not Odd(VertexCount) then
          Inc(PV);
        for I:=0 to (VertexCount-3) div 2 do
        begin
          PV2:=PV;
          Inc(PV);
          PV3:=PV;
          Inc(PV);
          If Byte(Ptr(LongWord(@AlphaColor)+3)^)<>0 then
            Case TextureMode of
            0:
              if Lighting and (LightingQuality=1) then
                RenderQuad(PVBase, PV2, PV3, PV, Currentf, Lights, Normale, Dist, LightParams, MakeSections)
              else
                RenderQuad(PVBase, PV2, PV3, PV, Currentf, nil, Normale, Dist, FullBright, MakeSections);
            4:
              if Lighting and (LightingQuality=1) then
                RenderQuad(PVBase, PV2, PV3, PV, Currentf, Lights, Normale, Dist, LightParams, MakeSections)
              else
                RenderQuad(PVBase, PV2, PV3, PV, Currentf, nil, Normale, Dist, FullBright, MakeSections);
            else
            begin
              if TextureMode=5 then
              begin
                Currentf[0]:=Byte(Ptr(LongWord(@AlphaColor)+3)^)/255;
                Currentf[1]:=Currentf[0];
                Currentf[2]:=Currentf[0];
              end;
              if Lighting and (LightingQuality=1) then
                RenderQuad(PVBase, PV2, PV3, PV, Currentf, Lights, Normale, Dist, LightParams, MakeSections)
              else
                RenderQuad(PVBase, PV2, PV3, PV, Currentf, nil, Normale, Dist, FullBright, MakeSections);
            end;
          end;
        end;
      end
      else
      begin { strip }
        if Lighting and (LightingQuality=1) then
          RenderQuadStrip(PV, -VertexCount, Currentf, Lights, Normale, LightParams)
        else
          RenderQuadStrip(PV, -VertexCount, Currentf, nil, Normale, FullBright);
      end;

      end;
    Inc(Surf);
    if VertexCount>=0 then
      Inc(PVertex3D(Surf), VertexCount)
    else
      Inc(PChar(Surf), VertexCount*(-(SizeOf(TVertex3D)+SizeOf(vec3_t))));
    end;
  end;
end;

 {------------------------}

procedure TGLState.ClearTexture(Tex: PTexture3);
{var
  I: Integer;
  UseRC: HGLRC;
  UseViewDC: HDC;}
begin
  //DanielPharos: How can you be sure OpenGL has been loaded?
  if (Tex^.OpenGLName<>0) then
  begin
    SetLength(TexturesToDelete,Length(TexturesToDelete)+1);
    TexturesToDelete[Length(TexturesToDelete)-1]:=Tex^.OpenGLName;
    Tex^.OpenGLName:=0;

    {DanielPharos: OK, let me explain this hack:
    At the moment, the Device Context (DC) of the window in with OpenGL renders
    gets destroyed before the TextureManager gets the call to clean up. This
    means we can't make the context that's going to be destroyed current,
    because of the invalid DC we're using. So instead of hacking into the code
    to make a call to delete the texture before deleting the DC, we're keeping
    track of the textures that need to be destroyed, and destroy them when
    StartBuildScene is called.
    We're doing the same for DisplayLists.}
    
(*    UseRC:=0;
    UseViewDC:=0;
    for I:=0 to Length(RCs)-1 do
    begin
      if RCs[I]<>0 then
      begin
        UseRC:=RCs[I];
        UseViewDC:=ViewDCs[I];
        break;
      end;
    end;
    if (UseRC<>0) and (UseViewDC<>0) then
    begin
      if wglMakeCurrent(UseViewDC,UseRC) = false then
        raise EError(6310);
      {$IFDEF DebugGLErr} DebugOpenGL(-101, 'glDeleteTextures(1, <%d>)', [Tex^.OpenGLName]); {$ENDIF}
      glDeleteTextures(1, Tex^.OpenGLName);
      {$IFDEF DebugGLErr} DebugOpenGL(101, 'glDeleteTextures(1, <%d>)', [Tex^.OpenGLName]); {$ENDIF}
      CheckOpenGLError(glGetError);
      wglMakeCurrent(0,0);
    end;
    Tex^.OpenGLName:=0; *)
  end;
end;

 {------------------------}

procedure CheckOpenGLError(GlError: GLenum);
begin
  if GlError = GL_INVALID_VALUE then
    Raise EErrorFmt(6303, ['GL_INVALID_VALUE'])
  else if GlError = GL_INVALID_ENUM then
    Raise EErrorFmt(6303, ['GL_INVALID_ENUM'])
  else if GlError = GL_INVALID_OPERATION then
    Raise EErrorFmt(6303, ['GL_INVALID_OPERATION'])
  else if GlError = GL_STACK_OVERFLOW then
    Raise EErrorFmt(6303, ['GL_STACK_OVERFLOW'])
  else if GlError = GL_STACK_UNDERFLOW then
    Raise EErrorFmt(6303, ['GL_STACK_UNDERFLOW'])
  else if GlError = GL_OUT_OF_MEMORY then
    Raise EErrorFmt(6303, ['GL_OUT_OF_MEMORY']);
end;

end.
