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
Revision 1.33.4.2  2001/07/15 05:57:46  tiglari
now draws the 2d views! (many safeguards missing, no texture unfo)

Revision 1.33.4.1  2001/07/14 01:50:16  tiglari
Fix totally wrong Q3A lump names

Revision 1.33  2001/04/24 23:59:44  aiv
re-implementated again (hopefully less memory req'd)

Revision 1.32  2001/04/23 23:14:02  aiv
pretty much changed all entity maker code

Revision 1.31  2001/04/16 00:37:33  tiglari
extract entity lumps from .bsp's in pakfolder

Revision 1.30  2001/04/07 20:17:57  aiv
fix save as HL .bsp bug

Revision 1.29  2001/03/29 01:00:29  aiv
modifable :form objects!

Revision 1.28  2001/03/20 21:46:48  decker_dk
Updated copyright-header

Revision 1.27  2001/03/18 00:38:14  aiv
Misc Cleanups and Fixes

Revision 1.26  2001/03/15 20:50:55  aiv
split up get entities and get textures

Revision 1.25  2001/03/12 20:34:28  aiv
now get textures from .bsp files (Q1, H2, and any others that support textures in bsp files)

Revision 1.24  2001/03/12 03:41:04  aiv
bug fixes for entity tool.

Revision 1.23  2001/03/09 21:11:56  aiv
Misc. Bug fixes

Revision 1.22  2001/03/08 23:22:53  aiv
entity tool finished completly i think.

Revision 1.21  2001/03/08 21:57:42  tiglari
switch to Q2 from Q3A mode when loading Q2 .bsp

Revision 1.20  2001/03/06 22:16:53  tiglari
head off attempt to view Q3A bsp

Revision 1.19  2001/03/05 21:45:47  tiglari
different getbspentry

Revision 1.18  2001/03/05 11:02:32  tiglari
q3 bsp editing support, entities OK, map structure not there yet

Revision 1.17  2001/03/05 09:21:21  tiglari
Q3 lump names filled in

Revision 1.16  2001/03/04 17:02:45  aiv
fixed 'origin' adding bug in entity wizard.

Revision 1.15  2001/03/03 00:11:09  aiv
addon creation from bsp files!

Revision 1.14  2001/02/23 19:26:21  decker_dk
Small changes (which hopefully does not break anything)
SuivantDansGroupe => NextInGroup
TrimStringList => StringListConcatWithSeparator

Revision 1.13  2001/02/01 20:46:42  decker_dk
Can read a Quake-3/STVEF .BSP file, but only the entity-list can be displayed for now.

Revision 1.12  2001/01/21 15:47:04  decker_dk
updated with misc. comments and cleaned up code

Revision 1.11  2001/01/15 19:19:42  decker_dk
Replaced the name: NomClasseEnClair -> FileObjectDescriptionText

Revision 1.10  2000/11/25 20:51:33  decker_dk
- Misc. small code cleanups
- Replaced the names:
 = ofTvInvisible       -> ofTreeViewInvisible
 = ofTvAlreadyExpanded -> ofTreeViewAlreadyExpanded
 = ofTvExpanded        -> ofTreeViewExpanded
 = ofSurDisque         -> ofNotLoadedToMemory
 = ModeFichier         -> fmOpenReadOnly_ShareDenyWrite
 = ModeFichierEcr      -> fmOpenReadWrite_ShareDenyWrite

Revision 1.9  2000/11/19 15:31:51  decker_dk
- Added 'ImageListTextureDimension' and 'ImageListLoadNoOfTexAtEachCall' to
Defaults.QRK, for manipulating the TextureBrowser-TextureLists.
- Modified TFQWad.PopulateListView, so it reads the above settings.
- Changed two 'goto bail' statements to 'break' statements, in QkObjects.
- Found the problem in the .MAP exporting entity-numbering, and corrected it.
- Changed the '|' delimiting character in QObject.Ancestry to '->', as I think
it will be more readable in the .MAP file.
- Replaced the function-names:
  = SauverTexte         -> SaveAsText
  = SauverTextePolyedre -> SaveAsTextPolygon
  = SauverTexteBezier   -> SaveAsTextBezier
  = SauverSpec          -> SaveAsTextSpecArgs

Revision 1.8  2000/10/15 15:58:44  alexander
correct error message for v46 bsp files

Revision 1.7  2000/07/18 19:37:58  decker_dk
Englishification - Big One This Time...

Revision 1.6  2000/07/16 16:34:50  decker_dk
Englishification

Revision 1.5  2000/07/09 13:20:43  decker_dk
Englishification and a little layout

Revision 1.4  2000/05/21 18:58:55  decker_dk
A little more englishification

Revision 1.3  2000/05/21 13:11:51  decker_dk
Find new shaders and misc.
}

unit QkBsp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkObjects, QkFileObjects, TB97, ComCtrls, QkForm, QkMapObjects, qmath,
  StdCtrls, Python, PyObjects, Game, QkUnknown;

type
 TBsp1EntryTypes =
   (eEntities
   ,ePlanes
   ,eMipTex
   ,eVertices
   ,eVisiList
   ,eNodes
   ,eTexInfo
   ,eSurfaces
   ,eLightmaps
   ,eBoundNodes
   ,eLeaves
   ,eListSurf
   ,eEdges
   ,eListEdges
   ,eHulls);

 TBsp2EntryTypes =
   (lump_entities
   ,lump_planes
   ,lump_vertexes
   ,lump_visibility
   ,lump_nodes
   ,lump_texinfo
   ,lump_faces
   ,lump_lighting
   ,lump_leafs
   ,lump_leaffaces
   ,lump_leafbrushes
   ,lump_edges
   ,lump_surfedges
   ,lump_models
   ,lump_brushes
   ,lump_brushsides
   ,lump_pop
   ,lump_areas
   ,lump_areaportals);


  TBsp3EntryTypes =
   (eBsp3_entities
   ,eBsp3_texinfo
   ,eBsp3_planes
   ,eBsp3_nodes
   ,eBsp3_leafs
   ,eBsp3_leaffaces
   ,eBsp3_leafbrushes
   ,eBsp3_models
   ,eBsp3_brushes
   ,eBsp3_brushsides
   ,eBsp3_vertexes
   ,eBsp3_meshvertexes
   ,eBsp3_effects
   ,eBsp3_faces
   ,eBsp3_lighting
   ,eBsp3_lightvol
   ,eBsp3_visibility);

 const
  NoBsp1 = TBsp1EntryTypes(-1);
  NoBsp2 = TBsp2EntryTypes(-1);
  NoBsp3 = TBsp3EntryTypes(-1);

type
(*SurfaceList = ^TSurfaceList;
 TSurfaceList = record
                 Next: PSurfaceList;
                 {Surfaces: array of TSurface}
                end;*)
 PVertexList = ^TVertexList;
 {sleazy trick below, memory will be reserved for pointers to this }
 TVertexList = array[0..0] of TVect;

 PQ3Vertex = ^TQ3Vertex;
 TQ3Vertex = record
              Position : vec3_t;
              SurfCoord, LightCoord : vec2_t;
              Normal : vec3_t;
              Color : array[0..3] of Byte;
             end;

 QBsp = class(QFileObject)
        private
          FStructure: TTreeMapBrush;
          FVerticesRefCount, FTexCoordsRefCount: Integer;
          function GetStructure : TTreeMapBrush;
          function GetBspEntry(E1: TBsp1EntryTypes; E2: TBsp2EntryTypes; E3: TBsp3EntryTypes) : QFileObject;
          procedure LoadBsp1(F: TStream; StreamSize: Integer);
          function DetermineGameCodeForBsp1() : Char;
          procedure LoadBsp2(F: TStream; StreamSize: Integer);
          procedure LoadBsp3(F: TStream; StreamSize: Integer);
          procedure SaveBsp1(Info: TInfoEnreg1);
          procedure SaveBsp2(Info: TInfoEnreg1);
        protected
          _VertexCount: Integer;
          function OpenWindow(nOwner: TComponent) : TQForm1; override;
          procedure SaveFile(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; StreamSize: Integer); override;
        public
         {FSurfaces: PSurfaceList;}
          FVertices: PVertexList;
          Q3Vertices: PChar;
          property Structure: TTreeMapBrush read GetStructure;
          destructor Destroy; override;
          class function TypeInfo: String; override;
          procedure ObjectState(var E: TEtatObjet); override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
          function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
          property BspEntry[E1: TBsp1EntryTypes; E2: TBsp2EntryTypes; E3: TBsp3EntryTypes] : QFileObject read GetBspEntry;
          function GetBspEntryData(E1: TBsp1EntryTypes; E2: TBsp2EntryTypes; E3: TBsp3EntryTypes; var P: PChar) : Integer;
          procedure ReLoadStructure;
          procedure CloseStructure;
          procedure VerticesAddRef(Delta: Integer);
          function GetAltTextureSrc : QObject;
          procedure Go1(maplist, extracted: PyObject; var FirstMap: String; QCList: TQList); override;
          function PyGetAttr(attr: PChar) : PyObject; override;
          Function GetTextureFolder: QObject;
          Function CreateStringListFromEntities(ExistingAddons: QFileObject; var Found: TStringList): Integer;
          function GetEntityLump : String;
          function VertexCount : Integer;
        end;

type
  TFQBsp = class(TQForm1)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    procedure wmInternalMessage(var Msg: TMessage); message wm_InternalMessage;
  protected
    function AssignObject(Q: QFileObject; State: TFileObjectWndState) : Boolean; override;
    function GetConfigStr: String; override;
  public
  end;

 {------------------------}

Function StringListFromEntityLump(e_lump: String; ExistingAddons: QFileObject; var Found: TStringList): Integer;

implementation

uses Travail, QkWad, Setup, QkText, QkMap, QkBspHulls,
     Undo, Quarkx, PyForms, QkObjectClassList, ToolBox1,
     ToolBoxGroup, QkQuakeCtx, FormCFG, Logging, QkTextures, QkQ1, QkFormCfg;

{$R *.DFM}

type
 TBspEntries = record
               EntryPosition: LongInt;
               EntrySize: LongInt;
              end;

(***********  Quake 1, Hexen II and Half-Life .bsp format  ***********)

const
 cSignatureBspQ1H2 = $0000001D; {Quake-1/Hexen-2 .BSP, 4-digit header}
 cSignatureBspHL   = $0000001E; {Half-Life .BSP, 4-digit header}

const
 Bsp1EntryNames : array[TBsp1EntryTypes] of String =
   (              {Actually a 'FilenameExtension' - See TypeInfo()}
    'Entities'    + '.a.bsp1'   // eEntities
   ,'Planes'      + '.b.bsp1'   // ePlanes
   ,'MipTex'      + '.c.bsp1'   // eMipTex
   ,'Vertices'    + '.d.bsp1'   // eVertices
   ,'VisiList'    + '.e.bsp1'   // eVisiList
   ,'Nodes'       + '.f.bsp1'   // eNodes
   ,'TexInfo'     + '.g.bsp1'   // eTexInfo
   ,'Surfaces'    + '.h.bsp1'   // eSurfaces
   ,'Lightmaps'   + '.i.bsp1'   // eLightmaps
   ,'BoundNodes'  + '.j.bsp1'   // eBoundNodes
   ,'Leaves'      + '.k.bsp1'   // eLeaves
   ,'ListSurf'    + '.l.bsp1'   // eListSurf
   ,'Edges'       + '.m.bsp1'   // eEdges
   ,'ListEdges'   + '.n.bsp1'   // eListEdges
   ,'Hulls'       + '.o.bsp1'   // eHulls
   );

type
 PBsp1Header = ^TBsp1Header;
 TBsp1Header = record
               Signature: LongInt;
               Entries: array[TBsp1EntryTypes] of TBspEntries;
              end;

(***********  Quake 2 .bsp format  ***********)

const
 cSignatureBspQ2DKQ3  = $50534249; {"IBSP" 4-letter header, which Quake-2, Daikatana and Quake-3:Arena contains}

 cVersionBspQ2        = $00000026; {Quake-2 .BSP}
 cVersionBspDK        = $00000029; {Daikatana .BSP}

const
 Bsp2EntryNames : array[TBsp2EntryTypes] of String =
   (              {Actually a 'FilenameExtension' - See TypeInfo()}
    'entities'    + '.a.bsp2'   // lump_entities
   ,'planes'      + '.b.bsp2'   // lump_planes
   ,'vertexes'    + '.c.bsp2'   // lump_vertexes
   ,'visibility'  + '.d.bsp2'   // lump_visibility
   ,'nodes'       + '.e.bsp2'   // lump_nodes
   ,'texinfo'     + '.f.bsp2'   // lump_texinfo
   ,'faces'       + '.g.bsp2'   // lump_faces
   ,'lighting'    + '.h.bsp2'   // lump_lighting
   ,'leafs'       + '.i.bsp2'   // lump_leafs
   ,'leaffaces'   + '.j.bsp2'   // lump_leaffaces
   ,'leafbrushes' + '.k.bsp2'   // lump_leafbrushes
   ,'edges'       + '.l.bsp2'   // lump_edges
   ,'surfedges'   + '.m.bsp2'   // lump_surfedges
   ,'models'      + '.n.bsp2'   // lump_models
   ,'brushes'     + '.o.bsp2'   // lump_brushes
   ,'brushsides'  + '.p.bsp2'   // lump_brushsides
   ,'pop'         + '.q.bsp2'   // lump_pop
   ,'areas'       + '.r.bsp2'   // lump_areas
   ,'areaportals' + '.s.bsp2'   // lump_areaportals
   );

type
 TBsp2Header = record
           Signature: LongInt;
           Version: LongInt;
           Entries: array[TBsp2EntryTypes] of TBspEntries;
          end;

(***********  Quake-3 .bsp format  ***********)

const
 // Quake-3 and STVEF .BSPs, uses the same signature as Quake-2 .BSPs!

 cVersionBspQ3        = $0000002E; {Quake-3 or STVEF .BSP}

const
 Bsp3EntryNames : array[TBsp3EntryTypes] of String =
   (              {Actually a 'FilenameExtension' - See TypeInfo()}
    'entities'    + '.a.bsp3'   // eBsp3_entities
   ,'planes'      + '.b.bsp3'   // eBsp3_unknown01
   ,'vertexes'    + '.c.bsp3'   // eBsp3_unknown02
   ,'visibility'  + '.d.bsp3'   // eBsp3_unknown03
   ,'nodes'       + '.e.bsp3'   // eBsp3_unknown04
   ,'texinfo'     + '.f.bsp3'   // eBsp3_unknown05
   ,'faces'       + '.g.bsp3'   // eBsp3_unknown06
   ,'lighting'    + '.h.bsp3'   // eBsp3_unknown07
   ,'leafs'       + '.i.bsp3'   // eBsp3_unknown08
   ,'leaffaces'   + '.j.bsp3'   // eBsp3_unknown09
   ,'leafbrushes' + '.k.bsp3'   // eBsp3_unknown10
   ,'edges'       + '.l.bsp3'   // eBsp3_unknown11
   ,'surfedges'   + '.m.bsp3'   // eBsp3_unknown12
   ,'models'      + '.n.bsp3'   // eBsp3_unknown13
   ,'brushes'     + '.o.bsp3'   // eBsp3_unknown14
   ,'brushsides'  + '.p.bsp3'   // eBsp3_unknown15
   ,'pop'         + '.q.bsp3'   // eBsp3_unknown16
   );

type
 TBsp3Header = record
           Signature: LongInt;
           Version: LongInt;
           Entries: array[TBsp3EntryTypes] of TBspEntries;
          end;

(***********  FAKK .bsp format  ***********)
const
  cSignatureBspFAKK = $4B4B4146; {"FAKK" 4-letter header, which HW:FAKK contains}

  cVersionBspFAKK   = $0000000C; {FAKK .BSP}

{ (Comment by Decker 2001-01-21)
 Lots more missing here, for FAKK - but it could be a superset of Quake-3:Arena's .BSP structure!
}

(***********  QuArK objects  ***********)

type
  QBsp1   = class(QFileObject)  protected class function TypeInfo: String; override; end;
  QBsp1a  = class(QZText)       protected class function TypeInfo: String; override; end;
  QBsp1c  = class(QTextureList) protected class function TypeInfo: String; override; end;

  QBsp2   = class(QFileObject)  protected class function TypeInfo: String; override; end;
  QBsp2a  = class(QZText)       protected class function TypeInfo: String; override; end;

  QBsp3   = class(QFileObject)  protected class function TypeInfo: String; override; end;
  QBsp3a  = class(QZText)       protected class function TypeInfo: String; override; end;

class function QBsp1 .TypeInfo; begin TypeInfo:='.bsp1';                       end;
class function QBsp1a.TypeInfo; begin TypeInfo:='.a.bsp1'; {'Entities.a.bsp1'} end;
class function QBsp1c.TypeInfo; begin TypeInfo:='.c.bsp1'; {'MipTex.c.bsp1'}   end;

class function QBsp2 .TypeInfo; begin TypeInfo:='.bsp2';                       end;
class function QBsp2a.TypeInfo; begin TypeInfo:='.a.bsp2'; {'entities.a.bsp2'} end;

class function QBsp3 .TypeInfo; begin TypeInfo:='.bsp3';                       end;
class function QBsp3a.TypeInfo; begin TypeInfo:='.a.bsp3'; {'entities.a.bsp3'} end;

 {------------------------}

class function QBsp.TypeInfo;
begin
 Result:='.bsp';
end;

function QBsp.OpenWindow(nOwner: TComponent) : TQForm1;
begin
 if nOwner=Application then
  Result:=NewPyForm(Self)
 else
  Result:=TFQBsp.Create(nOwner);
end;

procedure QBsp.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiBsp;
 E.MarsColor:=clGray;
end;

class procedure QBsp.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5134);
{Info.FileExtCount:=1;}
 Info.FileExt{[0]}:=779;
{Info.DefaultExt[0]:='bsp';}
 Info.WndInfo:=[wiOwnExplorer, wiWindow];
 Info.PythonMacro:='displaybsp';
end;

function QBsp.IsExplorerItem(Q: QObject) : TIsExplorerItem;
var
 S: String;
begin
  S:=Q.Name+Q.TypeInfo;
  Result:=ieResult[
    { any ".bsp1" to ".bsp9" }
       ((CompareText(Copy(S, Length(S)-4, 4), '.bsp' ) = 0) and (S[Length(S)] in ['1'..'9']))
    { or any ".bsp10" to ".bsp15" }
    or ((CompareText(Copy(S, Length(S)-5, 5), '.bsp1') = 0) and (S[Length(S)] in ['0'..'5']))
  ];
end;

function QBsp.GetBspEntry(E1: TBsp1EntryTypes; E2: TBsp2EntryTypes; E3: TBsp3EntryTypes) : QFileObject;
var
 Q: QObject;
 S: String;
begin
  Acces;

(* truly I don't get what's supposed to be going on
  here; this seems to work a bit better *)

(*
  if (E2=NoBsp2) and (E3=NoBsp3) then
    S:=Bsp1EntryNames[E1]
  else
  if  ((NeedObjectGameCode>=mjQuake2) and (NeedObjectGameCode<mjQ3A)) then
    S:=Bsp2EntryNames[E2]
  else
  if (NeedObjectGameCode=mjQ3A) or (NeedObjectGameCode=mjStarTrekEF) then
    S:=Bsp3EntryNames[E3]
  else
    S:=Bsp1EntryNames[E1];
 *)


  (* this is set when the .bsp is opened, from the version,
      why isn't it just used below? *)
  if (ObjectGameCode=mjQ3A) or (ObjectGameCode=mjStarTrekEF) then
    S:=Bsp3EntryNames[E3]
  else
  if (ObjectGameCode>=mjQuake2) and (ObjectGameCode<mjQ3A) then
    S:=Bsp2EntryNames[E2]
  else
  if E2=NoBsp2 then
    S:=Bsp1EntryNames[E1]
  else
  if (E1=NoBsp1) or (NeedObjectGameCode>=mjQuake2) then
    S:=Bsp2EntryNames[E2]
  else
    S:=Bsp1EntryNames[E1];


  Q := SubElements.FindName(S);
  if (Q=Nil) or not (Q is QFileObject) then
    Raise EError(5521);

  Result := QFileObject(Q);
end;

function QBsp.GetBspEntryData(E1: TBsp1EntryTypes; E2: TBsp2EntryTypes; E3: TBsp3EntryTypes; var P: PChar) : Integer;
const
 Start = Length('Data=');
var
 Q: QObject;
 S: String;
begin
 Q:=BspEntry[E1, E2, E3];
 Q.Acces;
 S:=Q.GetSpecArg('Data');
 P:=PChar(S)+Start;
 Result:=Length(S)-Start;
 {$IFDEF Debug}
 if Result<0 then Raise InternalE(Format('No BSP Data for %d, %d', [Ord(E1), Ord(E2)]));
 {$ENDIF}
end;

function QBsp.GetAltTextureSrc : QObject;
var
 Code: Char;
begin
 Code := NeedObjectGameCode;
 if (Code >= mjQuake2) {or (Code = mjHalfLife)} then
  Result := Nil
 else
  Result := BspEntry[eMipTex, NoBsp2, NoBsp3];
end;

 {----------------------}

procedure QBsp.LoadBsp1(F: TStream; StreamSize: Integer);
var
 Header: TBsp1Header;
 Origine: LongInt;
 E: TBsp1EntryTypes;
 Q: QObject;
begin
  if StreamSize < SizeOf(Header) then
    Raise EError(5519);

  Origine:=F.Position;
  F.ReadBuffer(Header, SizeOf(Header));

  for E:=Low(E) to High(E) do
  begin
    if (Header.Entries[E].EntryPosition+Header.Entries[E].EntrySize > StreamSize)
    or (Header.Entries[E].EntryPosition < SizeOf(Header))
    or (Header.Entries[E].EntrySize < 0) then
      Raise EErrorFmt(5509, [82]);

    F.Position := Origine + Header.Entries[E].EntryPosition;
    Q := OpenFileObjectData(F, Bsp1EntryNames[E], Header.Entries[E].EntrySize, Self);
    {if (E=eMipTex) and (Header.Signature = cSignatureBspHL) then
      Q.SetSpecificsList.Values['TextureType']:='.wad3_C';}
    SubElements.Add(Q);
    LoadedItem(rf_Default, F, Q, Header.Entries[E].EntrySize);
  end;
end;

function QBsp.DetermineGameCodeForBsp1() : char;
{ (Comment by Decker 2001-01-21)
 After load of a cSignatureBspQ1H2 file, this function must be called to determine what
 game-mode the .BSP file are for; Quake-1 or Hexen-2.
}
var
 P: PChar;
 FaceCount, Taille1: Integer;
 ModeQ1, ModeH2: Boolean;
begin
    { determine map game : Quake 1 or Hexen II }
  FFlags := FFlags and not ofNotLoadedToMemory;  { to prevent infinite loop on "Acces" }

  FaceCount := GetBspEntryData(eSurfaces, NoBsp2, NoBsp3, P) div SizeOf(TbSurface);
  Taille1   := GetBspEntryData(eHulls, NoBsp2, NoBsp3,P);

  ModeQ1 := CheckQ1Hulls(PHull(P), Taille1, FaceCount);
  ModeH2 := CheckH2Hulls(PHullH2(P), Taille1, FaceCount);

  if ModeQ1 and ModeH2 then
    case MessageDlg(FmtLoadStr1(5573, [LoadName]), mtConfirmation, mbYesNoCancel, 0) of
      mrYes: ModeQ1 := False;
      mrNo: ModeH2 := False;
      mrCancel: Abort;
    end;

  if ModeQ1 then
    Result := mjQuake
  else
    if ModeH2 then
      Result := mjHexen
    else
      Raise EErrorFmt(5509, [84]);
end;

procedure QBsp.LoadBsp2(F: TStream; StreamSize: Integer);
var
 Header: TBsp2Header;
 Origine: LongInt;
 Q: QObject;
 E: TBsp2EntryTypes;
begin
  if StreamSize < SizeOf(Header) then
    Raise EError(5519);

  Origine:=F.Position;
  F.ReadBuffer(Header, SizeOf(Header));

  for E:=Low(E) to High(E) do
  begin
    if Header.Entries[E].EntrySize < 0 then
      Raise EErrorFmt(5509, [84]);

    if Header.Entries[E].EntrySize = 0 then
      Header.Entries[E].EntryPosition := SizeOf(Header)
    else
    begin
      if Header.Entries[E].EntryPosition < SizeOf(Header) then
        Raise EErrorFmt(5509, [85]);

      if Header.Entries[E].EntryPosition+Header.Entries[E].EntrySize > StreamSize then
      begin
        Header.Entries[E].EntrySize := StreamSize - Header.Entries[E].EntryPosition;
        GlobalWarning(LoadStr1(5641));
      end;
    end;

    F.Position:=Origine + Header.Entries[E].EntryPosition;
    Q:=OpenFileObjectData(F, Bsp2EntryNames[E], Header.Entries[E].EntrySize, Self);
    SubElements.Add(Q);
    LoadedItem(rf_Default, F, Q, Header.Entries[E].EntrySize);
  end;
end;

procedure QBsp.LoadBsp3(F: TStream; StreamSize: Integer);
var
 Header: TBsp3Header;
 Origine: LongInt;
 Q: QObject;
 E: TBsp3EntryTypes;
begin
  if StreamSize < SizeOf(Header) then
    Raise EError(5519);

  Origine:=F.Position;
  F.ReadBuffer(Header, SizeOf(Header));

  for E:=Low(E) to High(E) do
  begin
    if Header.Entries[E].EntrySize < 0 then
      Raise EErrorFmt(5509, [84]);

    if Header.Entries[E].EntrySize = 0 then
      Header.Entries[E].EntryPosition := SizeOf(Header)
    else
    begin
      if Header.Entries[E].EntryPosition < SizeOf(Header) then
        Raise EErrorFmt(5509, [85]);

      if Header.Entries[E].EntryPosition+Header.Entries[E].EntrySize > StreamSize then
      begin
        Header.Entries[E].EntrySize := StreamSize - Header.Entries[E].EntryPosition;
        GlobalWarning(LoadStr1(5641));
      end;
    end;

    F.Position:=Origine + Header.Entries[E].EntryPosition;
    Q:=OpenFileObjectData(F, Bsp3EntryNames[E], Header.Entries[E].EntrySize, Self);
    SubElements.Add(Q);
    LoadedItem(rf_Default, F, Q, Header.Entries[E].EntrySize);
  end;
end;

procedure QBsp.LoadFile(F: TStream; StreamSize: Integer);
{ (Comment by Decker 2001-01-21)
 Loads 4 bytes of signature, and 4 bytes of version, to determine what type of
 .BSP file it is. Then calls a specialized function to load the actual .BSP file-data
}
var
 Signature: LongInt;
 Version: LongInt;
begin
  case ReadFormat of
    1: { as stand-alone file }
    begin
      if StreamSize < SizeOf(Signature)+SizeOf(Version) then
        Raise EError(5519);

      F.ReadBuffer(Signature, SizeOf(Signature));
      F.ReadBuffer(Version, SizeOf(Version));
      F.Seek(-(SizeOf(Signature)+SizeOf(Version)), soFromCurrent);

      case Signature of
        cSignatureBspQ1H2: { Quake-1 or Hexen-2 }
        begin
          LoadBsp1(F, StreamSize);
          ObjectGameCode := DetermineGameCodeForBsp1();
        end;

        cSignatureBspHL: { Half-Life }
        begin
          LoadBsp1(F, StreamSize);
          ObjectGameCode := mjHalfLife;
        end;

        cSignatureBspQ2DKQ3:
        begin
          { Check version of a cSignatureBspQ2DKQ3 file type }
          case Version of
            cVersionBspQ2: { Quake-2 }
            begin
              ChangeGameMode(mjQuake2,true);
              LoadBsp2(F, StreamSize);
              ObjectGameCode := CurrentQuake2Mode;
            end;

            cVersionBspQ3: { Quake-3 }
            begin
              LoadBsp3(F, StreamSize);
              ObjectGameCode := mjQ3A
            end;

            else {version unknown}
              Raise EErrorFmt(5572, [LoadName, Version, cVersionBspQ2]);
          end;
        end;

      else
        Raise EErrorFmt(5520, [LoadName, Signature, cSignatureBspQ1H2, cSignatureBspQ2DKQ3]);
      end;
    end;
  else
    inherited;
  end;
end;

procedure QBsp.SaveBsp1(Info: TInfoEnreg1);
var
 Header: TBsp1Header;
 Origine, Fin: LongInt;
 Zero: Integer;
 Q: QObject;
 E: TBsp1EntryTypes;
begin
  ProgressIndicatorStart(5450, Ord(High(E)) - Ord(Low(E)) + 1);
  try
    Origine := Info.F.Position;
    Info.F.WriteBuffer(Header, SizeOf(Header));  { updated later }

    { write .bsp entries }
    for E:=Low(E) to High(E) do
    begin
      Q := BspEntry[E, NoBsp2, NoBsp3];
      Header.Entries[E].EntryPosition := Info.F.Position;

      Q.SaveFile1(Info);   { save in non-QuArK file format }

      Header.Entries[E].EntrySize := Info.F.Position - Header.Entries[E].EntryPosition;
      Dec(Header.Entries[E].EntryPosition, Origine);

      Zero:=0;
      Info.F.WriteBuffer(Zero, (-Header.Entries[E].EntrySize) and 3);  { align to 4 bytes }

      ProgressIndicatorIncrement;
    end;

    { update header }
    Fin := Info.F.Position;
    Info.F.Position := Origine;
    if NeedObjectGameCode =mjHalfLife then
      Header.Signature := cSignatureBspHL
    else
      Header.Signature := cSignatureBspQ1H2;
    Info.F.WriteBuffer(Header, SizeOf(Header));

    Info.F.Position := Fin;
  finally
    ProgressIndicatorStop;
  end;
end;

procedure QBsp.SaveBsp2(Info: TInfoEnreg1);
var
  Header: TBsp2Header;
  Origine, Fin: LongInt;
  Zero: Integer;
  Q: QObject;
  E: TBsp2EntryTypes;
begin
  ProgressIndicatorStart(5450, Ord(High(E)) - Ord(Low(E)) + 1);
  try
    Origine := Info.F.Position;
    Info.F.WriteBuffer(Header, SizeOf(Header));  { updated later }

    { write .bsp entries }
    for E:=Low(E) to High(E) do
    begin
      Q := BspEntry[NoBsp1, E, NoBsp3];
      Header.Entries[E].EntryPosition := Info.F.Position;

      Q.SaveFile1(Info);   { save in non-QuArK file format }

      Header.Entries[E].EntrySize := Info.F.Position - Header.Entries[E].EntryPosition;
      Dec(Header.Entries[E].EntryPosition, Origine);

      Zero:=0;
      Info.F.WriteBuffer(Zero, (-Header.Entries[E].EntrySize) and 3);  { align to 4 bytes }

      ProgressIndicatorIncrement;
    end;

    { update header }
    Fin := Info.F.Position;

    Info.F.Position := Origine;
    Header.Signature := cSignatureBspQ2DKQ3;
    Header.Version := cVersionBspQ2;
    Info.F.WriteBuffer(Header, SizeOf(Header));

    Info.F.Position := Fin;
  finally
    ProgressIndicatorStop;
  end;
end;

procedure QBsp.SaveFile(Info: TInfoEnreg1);
begin
  case Info.Format of
    1: { as stand-alone file }
    begin
      if NeedObjectGameCode >= mjQuake2 then
        SaveBsp2(Info)
      else
        SaveBsp1(Info);
    end;
  else
    inherited;
  end;
end;

 {------------------------}

destructor QBsp.Destroy;
begin
 CloseStructure;
 inherited;
end;

procedure QBsp.CloseStructure;
begin
(* ProgressIndicatorStart(0,0); try
 FStructure.AddRef(-1);
 FStructure:=Nil;
 VerticesAddRef(0);
 finally ProgressIndicatorStop; end; *)
 if FStructure<>Nil then
  begin
   SetPoolObj('', @FStructure.PythonObj);
   FStructure.AddRef(-1);
   FStructure:=Nil;
  end;
 VerticesAddRef(0);
end;

procedure QBsp.VerticesAddRef(Delta: Integer);
begin
 Inc(FVerticesRefCount, Delta);
 if FVerticesRefCount<=0 then
  ReallocMem(FVertices, 0);
end;

function QBsp.GetStructure;
var
 Q: QObject;
 P: vec3_p;
 PQ3: PQ3Vertex;
 I, Count: Integer;
 Dest: PVect;
 HullType: Char;
 Pozzie: vec3_t;
begin
 HullType:=NeedObjectGameCode;
 if FStructure=Nil then
  begin
   if FVertices<>Nil then
    Raise EError(5637);
   FVerticesRefCount:=0;
   ProgressIndicatorStart(0,0); try
   if HullType<mjQ3A then
      Count:=GetBspEntryData(eVertices, lump_vertexes, eBsp3_vertexes, PChar(P)) div SizeOf(vec3_t)
   else
   begin
      Count:=GetBspEntryData(eVertices, lump_vertexes, eBsp3_vertexes, Q3Vertices) div SizeOf(TQ3Vertex);
      PQ3:=PQ3Vertex(Q3Vertices);
   end;
   _VertexCount:=Count;
   ReallocMem(FVertices, Count*SizeOf(TVect));
   Dest:=PVect(FVertices);
   if HullType<mjQ3A then
   for I:=1 to Count do
   begin
     with Dest^ do
     begin
       X:=P^[0];
       Y:=P^[1];
       Z:=P^[2];
     end;
     Inc(P);
     Inc(Dest);
   end
   else
   for I:=1 to Count do
   begin
     with Dest^ do
     begin
       Pozzie:=PQ3^.Position;
       X:=Pozzie[0];
       Y:=Pozzie[1];
       Z:=Pozzie[2];
     end;
    { is this really necessary? }
     Inc(PQ3);
     Inc(Dest);
   end;
   FStructure:=TTreeMapBrush.Create('', Self);
   FStructure.AddRef(+1);
   Q:=BspEntry[eEntities, lump_entities, eBsp3_entities];
   Q.Acces;
{   if CharModeJeu>=mjQ3A then
      ShowMessage('Sorry, no bsp editing for this game')
   else
 }
     ReadEntityList(FStructure, Q.Specifics.Values['Data'], Self);
   finally ProgressIndicatorStop; end;
  end;
 GetStructure:=FStructure;
end;

procedure QBsp.ReLoadStructure;
var
 Dest: TStringList;
 Q: QObject;
 S: String;
begin
 if FStructure<>Nil then
  begin
   FStructure.LoadAll;
   Dest:=TStringList.Create;
   try
    FStructure.SaveAsText(Nil, Dest, soBSP, Nil);
    S:=Dest.Text;
   finally
    Dest.Free;
   end;
   Q:=BspEntry[eEntities, lump_entities, eBsp3_entities];
   Q.Acces;
   Action(Q, TSpecificUndo.Create(LoadStr1(614), 'Data', S, sp_Auto, Q));
  end;
end;

 {------------------------}

procedure QBsp.Go1(maplist, extracted: PyObject; var FirstMap: String; QCList: TQList);
var
 mapname: PyObject;
 S: String;
begin
 Acces;
 S:=Specifics.Values['FileName'];
 if S='' then
  S:=Name;
 BuildCorrectFileName(S);
 if FirstMap='' then
  FirstMap:=S;
 S:='maps/'+S+TypeInfo;
 SaveInFile(rf_Default, OutputFile(S));
 mapname:=PyString_FromString(PChar(S));
 PyList_Append(extracted, mapname);
 Py_DECREF(mapname);
end;


 {------------------------}

function QBsp.VertexCount : Integer;
begin
  Result:=_VertexCount;
end;

 {------------------------}

function qReloadStructure(self, args: PyObject) : PyObject; cdecl;
begin
 try
  with QkObjFromPyObj(self) as QBsp do
   ReLoadStructure;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

function qCloseStructure(self, args: PyObject) : PyObject; cdecl;
begin
 try
  with QkObjFromPyObj(self) as QBsp do
   CloseStructure;
  Result:=PyNoResult;
 except
  EBackToPython;
  Result:=Nil;
 end;
end;

const
 MethodTable: array[0..1] of TyMethodDef =
  ((ml_name: 'reloadstructure';  ml_meth: qReloadStructure;  ml_flags: METH_VARARGS),
   (ml_name: 'closestructure';   ml_meth: qCloseStructure;   ml_flags: METH_VARARGS));

function QBsp.PyGetAttr(attr: PChar) : PyObject;
var
 I: Integer;
begin
 Result:=inherited PyGetAttr(attr);
 if Result<>Nil then Exit;
 for I:=Low(MethodTable) to High(MethodTable) do
  if StrComp(attr, MethodTable[I].ml_name) = 0 then
   begin
    Result:=PyCFunction_New(MethodTable[I], @PythonObj);
    Exit;
   end;
 case attr[0] of
  't': if StrComp(attr, 'texsource') = 0 then
        begin
         Result:=GetPyObj(GetAltTextureSrc);
         Exit;
        end;
  's': if StrComp(attr, 'structure') = 0 then
        begin
         Result:=GetPyObj(Structure);
         Exit;
        end;
 end;
end;

 {------------------------}

procedure TFQBsp.wmInternalMessage(var Msg: TMessage);
begin
 case Msg.wParam of
  wp_AfficherObjet:
    FileObject.ChangeToObjectGameMode;
 end;
 inherited;
end;

function TFQBsp.AssignObject(Q: QFileObject; State: TFileObjectWndState) : Boolean;
begin
 Result:=(Q is QBsp) and inherited AssignObject(Q, State);
end;

function TFQBsp.GetConfigStr;
begin
 Result:='BSP';
end;

procedure TFQBsp.Button1Click(Sender: TObject);
begin
 with ValidParentForm(Self) as TQkForm do
{  if CharModeJeu>=mjQ3a then
    ShowMessage('Sorry, no bsp viewing for this game yet')
  else
}
    ProcessEditMsg(edOpen);
end;

(*
convert this:

{
"worldtype" "2"
"sounds" "6"
"classname" "worldspawn"
"wad" "gfx/base.wad"
"message" "the Slipgate Complex"
}
{
"classname" "info_player_start"
"origin" "480 -352 88"
"angle" "90"
}

into a stringlist for each entity (entity = { ... } )
*)
Function EntityTextToStringList(S0: String): TStringList;
var
  S, Spec, Arg: String;
  I: Integer;
  Es, E1: TStringList;
  function GetClassname(S: TStringList): string;
  begin
    result:=S.Values['classname'];
  end;
  procedure CreateFullEntity(S: TStringList);
  var
    E: TStringList;
    cn: String;
    z: integer;
  begin
    cn:=GetClassname(S);
    E:=nil;
    for z:=0 to Result.count-1 do
      if Result.Strings[z]=cn then
        E:=TStringList(Result.Objects[z]);
    if E=nil then
    begin
      E:=TStringList.Create;
      Result.AddObject(cn, E);
    end;
    for z:=0 to S.count-1 do
    begin
      if E.IndexOfName(S.names[z]) = -1 then
        E.Add(S.Strings[z]);
    end;
  end;
begin
  E1:=nil;
  Result:=TStringList.Create;
  for i:=1 to length(S0) do
    if (S0[i]<>#13) and (S0[i]<>#10) then
      S:=S+S0[i];
  i:=1;
  Es:=TStringlist.Create;
  while i<length(S)+1 do
  begin
    case s[i] of
      '{': E1:=TStringlist.Create;
      '"': begin
        Spec:='';
        Arg:='';
        while true do
        begin
          inc(i);
          if s[i] = '"' then
            break;
          Spec:=Spec+s[i];
        end;
        while s[i]='"' do
          inc(i);
        inc(i);
        while s[i]='"' do
          inc(i);
        while true do
        begin
          if s[i] = '"' then
            break;
          arg:=arg+s[i];
          inc(i);
        end;
        E1.Add(Spec+'='+Arg);
      end;
      '}': Es.AddObject('', E1);
    end;
    inc(i);
  end;
  for i:=Es.Count-1 downto 0 do
  begin
    CreateFullEntity(TStringList(Es.Objects[i]));
    TStringList(Es.Objects[i]).Free;
    Es.Delete(i);
  end;
  Es.Free;
end;

Function GetBaseDir(F: String; inPak: Boolean): String;
var
  i: Integer;
  slashCount, wSlashCount: Integer;
begin
  if not inPak then
    wSlashCount:=3
  else
    wSlashCount:=2;
  if F='' then
  begin
    result:=GetGameDir;
    exit;
  end;
  I:=Length(F)+1;
  SlashCount:=0;
  While SlashCount<wSlashCount do
  begin
    Dec(I);
    if F[I]='\' then
    begin
      Inc(SlashCount);
    end;
  end;
  Result:=Copy(F, I+1, length(F)-I+1);
  SlashCount:=Pos('\', Result);
  Result:=Copy(Result, 1, SlashCount-1);
end;

function ByName(Item1, Item2: Pointer) : Integer;
var
 Q1: QObject absolute Item1;
 Q2: QObject absolute Item2;
begin
 if Q1 is QTextureList then
  if Q2 is QTextureList then
   Result:=CompareText(Q1.Name, Q2.Name)
  else
   Result:=-1
 else
  if Q2 is QTextureList then
   Result:=1
  else
   begin
    Result:=CompareText(Q1.Name, Q2.Name);
    if Result=0 then
     Result:=CompareText(Q1.TypeInfo, Q2.TypeInfo);
   end;
end;

procedure SortTexFolder(TexFolder: QObject);
var
 Q: QObject;
 I: Integer;
begin
 TexFolder.SubElements.Sort(ByName);
 for I:=0 to TexFolder.SubElements.Count-1 do
  begin
   Q:=TexFolder.SubElements[I];
   if not (Q is QTextureList) then Break;
   SortTexFolder(Q);
  end;
end;

Function QBsp.GetEntityLump: String;
var
  e: QObject;
  S: String;
  I: Integer;
begin
  Acces;
  e:=GetBspEntry(eEntities, lump_entities, eBsp3_entities);
  if e=nil then
  begin
    raise Exception.Create('No Entities in BSP');
  end;
  e.acces;
  S:=e.Specifics.Values['Data'];
  for I:=Length(S) downto 1 do
  begin
     if S[I]='}' then
        Break;
     S[I]:=' ';
  end;
  Result:=S;
end;

Function StringListFromEntityLump(e_lump: String; ExistingAddons: QFileObject; var Found: TStringList): Integer;
var
  S: String;
  specList: TStringList;
  e_sl, f_sl: TStringList;
  i,J,k: Integer;
  Addons: QFileObject;
  bFound: Boolean;
begin
  S:=e_lump;
  (*
    Convert Entities in bsp to stringlists & remove "worldspawn" and "light" and
    pre-existing entities now.
  *)
  result:=0;
  specList:=EntityTextToStringList(S);
  Addons:=ExistingAddons;
  for i:=specList.count-1 downto 0 do
  begin
    e_sl:=TStringList(SpecList.Objects[i]);
    if (uppercase(e_sl.Values['classname']) = 'WORLDSPAWN') or
       (uppercase(e_sl.Values['classname']) = 'LIGHT') or
       (Addons.FindSubObject(e_sl.Values['classname'], QObject, QObject)<>nil) then
    begin
      specList.Delete(i);
      continue;
    end;
    if found.count=0 then
    begin
      found.addobject(e_sl.Values['classname'], e_sl);
      continue;
    end;
    bFound:=false;
    for j:=0 to found.count-1 do
    begin
      f_sl:=TStringList(found.objects[j]);
      if (uppercase(f_sl.Values['classname']) = uppercase(e_sl.Values['classname'])) then
      begin
        bFound:=true;
        for k:=0 to e_sl.count-1 do
        begin
          if f_sl.indexofname(e_sl.Names[k])=-1 then
          begin
            f_sl.add(e_sl.strings[k]);
          end;
        end;
      end
    end;
    if not bFound then
    begin
      found.addobject(e_sl.Values['classname'], e_sl);
      inc(result);
    end;
  end;
end;

Function QBsp.CreateStringListFromEntities(ExistingAddons: QFileObject; var Found: TStringList): Integer;
var
  e: QObject;
begin
  Acces;
  e:=GetBspEntry(eEntities, lump_entities, eBsp3_entities);
  if e=nil then
  begin
    raise Exception.Create('No Entities in BSP');
  end;
  e.acces;
end;

Function QBsp.GetTextureFolder: QObject;
var
  e: QObject;
  i: Integer;
  TexFolder, TexFolder2: QObject;
  Link: QTextureLnk;
  Tex: QObject;
begin
  Acces;
  e:=nil;
  try
    e:=GetBspEntry(eMipTex, NoBsp2, NoBsp3);
  except
    { nothing }
  end;

  TexFolder:=nil;
  if (e<>nil)and(ObjectGameCode <> mjHalfLife) then
  begin
    e.acces;
    TexFolder:=QToolboxGroup.Create('textures from '+GetFullName, nil);
    for i:=0 to e.subelements.count-1 do
    begin
      Tex:=e.subelements[i];
      TexFolder2:=TexFolder.FindSubObject(Tex.Name[1], QTextureList, nil);
      if TexFolder2=nil then
      begin
        TexFolder2:=QTextureList.Create(Tex.Name[1], TexFolder);
        TexFolder.Subelements.Add(TexFolder2);
      end;
      Link:=QTextureLnk.Create(Tex.name, TexFolder2);
      Link.SpecificsAdd('b='+Name);
      if FParent=nil then
        Link.SpecificsAdd('s='+GetBaseDir(Self.Filename, false))
      else
        Link.SpecificsAdd('s='+GetBaseDir(QFileObject(FParent.FParent).Filename, true));  // in a pak file
      TexFolder2.Subelements.Add(Link);
    end;
    SortTexFolder(TexFolder);
  end;
  Result:=TexFolder;
end;


initialization
  RegisterQObject(QBsp, 's');

  RegisterQObject(QBsp1,  ' ');
  RegisterQObject(QBsp1a, 'a');
  RegisterQObject(QBsp1c, 'a');

  RegisterQObject(QBsp2,  ' ');
  RegisterQObject(QBsp2a, 'a');

  RegisterQObject(QBsp3,  ' ');
  RegisterQObject(QBsp3a, 'a');
end.
