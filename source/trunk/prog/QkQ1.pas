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
unit QkQ1;

interface

uses
  Classes,
  QkObjects,
  QkFileObjects,
  QkTextures,
  QkBsp,
  Sysutils,
  Dialogs,
  QkImages;

type
 TQ1Miptex = packed record
              Nom: array[0..15] of Byte;
              W,H: LongInt;
              Indexes: array[0..3] of LongInt;
             end;

 QTexture1 = class(QTextureFile)
             protected
               procedure ChargerFin(F: TStream; TailleRestante: Integer); virtual;
              {procedure LireEnteteFichier(Source: TStream; const Nom: String; var SourceTaille: Integer); override;}
               procedure SaveFile(Info: TInfoEnreg1); override;
               procedure LoadFile(F: TStream; FSize: TStreamPos); override;
             public
               class function TypeInfo: String; override;
               class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
               function CheckAnim(Seq: Integer) : String; override;
               function GetTexOpacity : Integer; override;  { 0-255 }
               function BaseGame : Char; override;
               class function CustomParams : Integer; override;
             end;

 QBsp1FileHandler = class(QBspFileHandler)
  public
   procedure LoadBsp(F: TStream; StreamSize: TStreamPos); override;
   procedure SaveBsp(Info: TInfoEnreg1); override;
   function GetEntryName(const EntryIndex: Integer) : String; override;
   function GetLumpEdges: Integer; override;
   function GetLumpEntities: Integer; override;
   function GetLumpFaces: Integer; override;
   function GetLumpLeafs: Integer; override;
   function GetLumpLeafFaces: Integer; override;
   function GetLumpModels: Integer; override;
   function GetLumpNodes: Integer; override;
   function GetLumpPlanes: Integer; override;
   function GetLumpSurfEdges: Integer; override;
   function GetLumpTexInfo: Integer; override;
   function GetLumpTextures: Integer; override;
   function GetLumpVertexes: Integer; override;
 end;

function CheckQ1Miptex(var Header: TQ1Miptex; FileSize: TStreamPos) : TStreamPos;


implementation

uses
  Travail, Quarkx, QkExceptions, Setup, QkText, QkWad, QkObjectClassList;

const
 LUMP_ENTITIES = 0;
 LUMP_PLANES = 1;
 LUMP_TEXTURES = 2;
 LUMP_VERTEXES = 3;
 LUMP_VISIBILITY = 4;
 LUMP_NODES = 5;
 LUMP_TEXINFO = 6;
 LUMP_FACES = 7;
 LUMP_LIGHTING = 8;
 LUMP_CLIPNODES = 9;
 LUMP_LEAFS = 10;
 LUMP_MARKSURFACES = 11;
 LUMP_EDGES = 12;
 LUMP_SURFEDGES = 13;
 LUMP_MODELS = 14;

 HEADER_LUMPS = 15;

type
 TBspEntries = record
               EntryPosition: LongInt;
               EntrySize: LongInt;
              end;

 TBsp1Header = record
               Signature: LongInt;
               Entries: array[0..HEADER_LUMPS-1] of TBspEntries;
              end;

const
 Bsp1EntryNames : array[0..HEADER_LUMPS-1] of String =
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
  QBsp1   = class(QFileObject)  protected class function TypeInfo: String; override; end;
  QBsp1a  = class(QZText)       protected class function TypeInfo: String; override; end;
  QBsp1c  = class(QTextureList) protected class function TypeInfo: String; override; end;

class function QBsp1 .TypeInfo; begin TypeInfo:='.bsp1';                       end;
class function QBsp1a.TypeInfo; begin TypeInfo:='.a.bsp1'; {'Entities.a.bsp1'} end;
class function QBsp1c.TypeInfo; begin TypeInfo:='.c.bsp1'; {'MipTex.c.bsp1'}   end;

 { --------------- }

function CheckQ1Miptex(var Header: TQ1Miptex; FileSize: TStreamPos) : TStreamPos;
var
  I, J: Integer;
  DataSize, MaxSize: TStreamPos;

  function EndPos(I: Integer) : TStreamPos;
  begin
    Result:=Header.Indexes[I]+(DataSize shr (2*I));
  end;

begin
  Result:=0;
  if (Header.W<=0) or (Header.H<=0) or
     (Header.W and 7 <> 0) or (Header.H and 7 <> 0) then
    Exit;
  DataSize:=Header.W*Header.H;
  MaxSize:=SizeOf(Header);
  for I:=0 to 3 do
  begin
    if Header.Indexes[I]=0 then
      if I=0 then
        Header.Indexes[I]:=SizeOf(Header)
      else
        Header.Indexes[I]:=EndPos(I-1);
  end;
  for I:=0 to 3 do
  begin
    J:=EndPos(I);
    if (Header.Indexes[I]<SizeOf(Header)) or (J>FileSize) then
      Exit;
    if J>MaxSize then
      MaxSize:=J;
    for J:=I+1 to 3 do
      if (EndPos(I)>Header.Indexes[J]) and
         (EndPos(J)>Header.Indexes[I]) then
      Exit;
  end;
  Result:=MaxSize;
end;

 { --------------- }

class function QTexture1.CustomParams : Integer;
begin
  Result:=cp4MipIndexes or cpFixedOpacity;
end;

class function QTexture1.TypeInfo: String;
begin
  TypeInfo:='.wad_D';
end;

class procedure QTexture1.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5131);
end;

procedure QTexture1.ChargerFin(F: TStream; TailleRestante: Integer);
begin
end;

procedure QTexture1.LoadFile(F: TStream; FSize: TStreamPos);
const
  Spec1 = 'Image#=';
  PosNb = 6;
var
  S: String;
  Header: TQ1Miptex;
  V: array[1..2] of Single;
  I: Integer;
  Base, Taille1, Max: TStreamPos;
begin
  case ReadFormat of
  rf_Default:
    begin  { as stand-alone file }
        if FSize<SizeOf(Header) then
          Raise EError(5519);
        Base:=F.Position;
        F.ReadBuffer(Header, SizeOf(Header));
        Max:=CheckQ1Miptex(Header, FSize);
        if Max=0 then
          Raise EErrorFmt(5514, [LoadName, 1]);
        CheckTexName(CharToPas(Header.Nom));
        V[1]:=Header.W;
        V[2]:=Header.H;
        SetFloatsSpec('Size', V);
        Taille1:=Header.W*Header.H;
        for I:=0 to 3 do
        begin
          S:=Spec1;
          S[PosNb]:=Chr(49+I);  { '1' to '4' }
          SetLength(S, Length(Spec1)+Taille1);
          F.Position:=Base+Header.Indexes[I];
          F.ReadBuffer(S[Length(Spec1)+1], Taille1);
          Specifics.Add(S);
          Taille1:=Taille1 div 4;  { next images are scaled-down }
        end;
        F.Position:=Base+Max;
        ChargerFin(F, FSize-Max);
        F.Position:=Base+FSize;
    end;
  else
    inherited;
  end;
end;

procedure QTexture1.SaveFile(Info: TInfoEnreg1);
begin
  with Info do
  begin
    case Format of
    rf_Default:
      SaveAsQuake1(F);  { as stand-alone file }
    else
      inherited;
    end;
  end;
end;

function QTexture1.CheckAnim(Seq: Integer) : String;
var
  Zero, Next, A: String;
begin
  Result:='';
  if (Length(Name)>=2) and (Name[1]='+') and (Name[2] in ['0'..'9', 'A'..'J', 'a'..'j']) then
  begin
    Zero:=Name+#13; Zero[2]:='0';
    A   :=Name+#13; A[2]   :='a';
    if Name[2] in ['9', 'J', 'j'] then
      Next:=''
    else
    begin
     Next:=Name+#13;
     Next[2]:=Succ(Next[2]);
    end;
    if Name[2] in ['0'..'9'] then   { first sequence }
    begin
      case Seq of
        0: Result:= Next +   A  + Zero;
        1: Result:= Next + Zero +   A ;
        2: Result:=   A  + Next + Zero;
      end;
    end
    else    { second sequence }
    begin
      case Seq of
        0: Result:= Next + Zero +   A ;
        1: Result:= Zero + Next +   A ;
        2: Result:= Next +   A  + Zero;
      end;
    end;
  end;
end;

function QTexture1.GetTexOpacity : Integer;
begin
  if Copy(Name,1,1)='*' then
    Result:=144
  else
    Result:=255;
end;

function QTexture1.BaseGame;
begin
  Result:=mjNotQuake2;
end;

 { --------------- }

function MakeFileQObject(F: TStream; const FullName: String; nParent: QObject) : QFileObject;
var
  i: TStreamPos;
begin
  {wraparound for a stupid function OpenFileObjectData having obsolete parameters }
  {tbd: clean this up in QkFileobjects and at all referencing places}
 Result:=OpenFileObjectData(F, FullName, i, nParent);
end;

procedure QBsp1FileHandler.LoadBsp(F: TStream; StreamSize: TStreamPos);
var
 Header: TBsp1Header;
 Origine: TStreamPos;
 Q: QObject;
 I: Integer;
begin
  if StreamSize < SizeOf(Header) then
    Raise EError(5519);

  Origine:=F.Position;
  F.ReadBuffer(Header, SizeOf(Header));

  for I:=0 to HEADER_LUMPS-1 do
  begin
    if (Header.Entries[I].EntryPosition+Header.Entries[I].EntrySize > StreamSize)
    or (Header.Entries[I].EntryPosition < SizeOf(Header))
    or (Header.Entries[I].EntrySize < 0) then
      Raise EErrorFmt(5509, [82]);

    F.Position := Origine + Header.Entries[I].EntryPosition;
    Q := MakeFileQObject(F, Bsp1EntryNames[I], FBsp); //FIXME: Used Header.Entries[I].EntrySize as third argument to OpenFileObjectData.
    {if (I=LUMP_TEXTURES) and (Header.Signature = cSignatureBspHL) then
      Q.SetSpecificsList.Values['TextureType']:='.wad3_C';}
    FBsp.SubElements.Add(Q);
    LoadedItem(rf_Default, F, Q, Header.Entries[I].EntrySize);
  end;
end;

procedure QBsp1FileHandler.SaveBsp(Info: TInfoEnreg1);
var
 Header: TBsp1Header;
 Origine, Fin: TStreamPos;
 Zero: LongInt;
 Q: QObject;
 I: Integer;
begin
  ProgressIndicatorStart(5450, HEADER_LUMPS);
  try
    Origine := Info.F.Position;
    Info.F.WriteBuffer(Header, SizeOf(Header));  { updated later }

    { write .bsp entries }
    for I:=0 to HEADER_LUMPS-1 do
    begin
      Q := FBsp.BspEntry[I];
      Header.Entries[I].EntryPosition := Info.F.Position;

      Q.SaveFile1(Info);   { save in non-QuArK file format }

      Header.Entries[I].EntrySize := Info.F.Position - Header.Entries[I].EntryPosition;
      Dec(Header.Entries[I].EntryPosition, Origine);

      Zero:=0;
      Info.F.WriteBuffer(Zero, (-Header.Entries[I].EntrySize) and 3);  { align to 4 bytes }

      ProgressIndicatorIncrement;
    end;

    { update header }
    Fin := Info.F.Position;
    Info.F.Position := Origine;
    if FBsp.NeedObjectGameCode =mjHalfLife then
      Header.Signature := cSignatureBspHL
    else
      Header.Signature := cSignatureBspQ1H2;
    Info.F.WriteBuffer(Header, SizeOf(Header));

    Info.F.Position := Fin;
  finally
    ProgressIndicatorStop;
  end;
end;

function QBsp1FileHandler.GetEntryName(const EntryIndex: Integer) : String;
begin
  if (EntryIndex<0) or (EntryIndex>=HEADER_LUMPS) then
    raise InternalE('Tried to retrieve name of invalid BSP lump!');
  Result:=Bsp1EntryNames[EntryIndex];
end;

function QBsp1FileHandler.GetLumpEdges: Integer;
begin
  Result:=LUMP_EDGES;
end;

function QBsp1FileHandler.GetLumpEntities: Integer;
begin
  Result:=LUMP_ENTITIES;
end;

function QBsp1FileHandler.GetLumpFaces: Integer;
begin
  Result:=LUMP_FACES;
end;

function QBsp1FileHandler.GetLumpLeafs: Integer;
begin
  Result:=LUMP_LEAFS;
end;

function QBsp1FileHandler.GetLumpLeafFaces: Integer;
begin
  Result:=-1;
end;

function QBsp1FileHandler.GetLumpModels: Integer;
begin
  Result:=LUMP_MODELS;
end;

function QBsp1FileHandler.GetLumpNodes: Integer;
begin
  Result:=LUMP_NODES;
end;

function QBsp1FileHandler.GetLumpPlanes: Integer;
begin
  Result:=LUMP_PLANES;
end;

function QBsp1FileHandler.GetLumpSurfEdges: Integer;
begin
  Result:=LUMP_SURFEDGES;
end;

function QBsp1FileHandler.GetLumpTexInfo: Integer;
begin
  Result:=LUMP_TEXINFO;
end;

function QBsp1FileHandler.GetLumpTextures: Integer;
begin
  Result:=LUMP_TEXTURES;
end;

function QBsp1FileHandler.GetLumpVertexes: Integer;
begin
  Result:=LUMP_VERTEXES;
end;

initialization
  RegisterQObject(QTexture1, 'a');

  RegisterQObject(QBsp1,  '!');
  RegisterQObject(QBsp1a, 'a');
  RegisterQObject(QBsp1c, 'a');
end.

