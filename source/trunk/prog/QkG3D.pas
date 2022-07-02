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
unit QkG3D;

interface

uses
  Windows, SysUtils, Classes, QkFileObjects, QkObjects, QkText,
  QkTextures, QkBsp, Setup, QkWad, QkPixelSet;

type
 QBspG3DFileHandler = class(QBspFileHandler)
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

implementation

uses QuarkX, QkExceptions, Game, Travail, QkObjectClassList, Logging;

const
 GBSP_VERSION = 15;

 GBSP_CHUNK_HEADER = 0;
 GBSP_CHUNK_MODELS = 1;
 GBSP_CHUNK_NODES = 2;
 GBSP_CHUNK_BNODES = 3;
 GBSP_CHUNK_LEAFS = 4;
 GBSP_CHUNK_CLUSTERS = 5;
 GBSP_CHUNK_AREAS = 6;
 GBSP_CHUNK_AREA_PORTALS = 7;
 GBSP_CHUNK_LEAF_SIDES = 8;
 GBSP_CHUNK_PORTALS = 9;
 GBSP_CHUNK_PLANES = 10;
 GBSP_CHUNK_FACES = 11;
 GBSP_CHUNK_LEAF_FACES = 12;
 GBSP_CHUNK_VERT_INDEX = 13;
 GBSP_CHUNK_VERTS = 14;
 GBSP_CHUNK_RGB_VERTS = 15;
 GBSP_CHUNK_ENTDATA = 16;

 GBSP_CHUNK_TEXINFO = 17;
 GBSP_CHUNK_TEXTURES = 18;
 GBSP_CHUNK_TEXDATA = 19;

 GBSP_CHUNK_LIGHTDATA = 20;
 GBSP_CHUNK_VISDATA = 21;
 GBSP_CHUNK_SKYDATA = 22;
 GBSP_CHUNK_PALETTES = 23;
 GBSP_CHUNK_MOTIONS = 24;

 GBSP_CHUNK_END = $ffff;

 HEADER_CHUNKS = 25;

type
 TGBSP_Chunk = record
                xType: LongInt;
                Size: LongInt;
                Elements: LongInt;
               end;
 TGBSP_Header = record
                 TAG: array[0..4] of Byte;	// 'G','B','S','P','0'
                 Version: LongInt;
                 BSPTime: SYSTEMTIME;
                end;

const
 BspG3DEntryNames : array[1..HEADER_CHUNKS-1] of String =
   (              {Actually a 'FilenameExtension' - See TypeInfo()}
    'models'      + '.a.bspg3d'
   ,'nodes'       + '.b.bspg3d'
   ,'bnodes'      + '.c.bspg3d'
   ,'leafs'       + '.d.bspg3d'
   ,'clusters'    + '.e.bspg3d'
   ,'areas'       + '.f.bspg3d'
   ,'areaportals' + '.g.bspg3d'
   ,'leafsides'   + '.h.bspg3d'
   ,'portals'     + '.i.bspg3d'
   ,'planes'      + '.j.bspg3d'
   ,'faces'       + '.k.bspg3d'
   ,'leaffaces'   + '.l.bspg3d'
   ,'vertindex'   + '.m.bspg3d'
   ,'verts'       + '.n.bspg3d'
   ,'rgbverts'    + '.o.bspg3d'
   ,'entdata'     + '.p.bspg3d'
   ,'texinfo'     + '.q.bspg3d'
   ,'textures'    + '.r.bspg3d'
   ,'texdata'     + '.s.bspg3d'
   ,'lightdata'   + '.t.bspg3d'
   ,'visdata'     + '.u.bspg3d'
   ,'skydata'     + '.v.bspg3d'
   ,'palettes'    + '.w.bspg3d'
   ,'motions'     + '.x.bspg3d'
   );

type
  QBspG3D  = class(QFileObject)  protected class function TypeInfo: String; override; end;

class function QBspG3D.TypeInfo; begin TypeInfo:='.bspg3d'; end;

 {------------------------}

function MakeFileQObject(F: TStream; const FullName: String; nParent: QObject) : QFileObject;
var
  i: TStreamPos;
begin
  {wraparound for a stupid function OpenFileObjectData having obsolete parameters }
  {tbd: clean this up in QkFileobjects and at all referencing places}
 Result:=OpenFileObjectData(F, FullName, i, nParent);
end;

procedure QBspG3DFileHandler.LoadBsp(F: TStream; StreamSize: TStreamPos);
var
 DataRemaining: TStreamPos;
 Chunk: TGBSP_Chunk;
 Header: TGBSP_Header;
 Q: QObject;
begin
  DataRemaining:=StreamSize;
  while true do
  begin
    if DataRemaining < SizeOf(Chunk) then
      Raise EError(5519);

    F.ReadBuffer(Chunk, SizeOf(Chunk));
    Dec(DataRemaining, SizeOf(Chunk));

    if Chunk.xType=0 then
    begin
      if Chunk.Size<>SizeOf(Header) then
        Raise EErrorFmt(5509, [85]);

      if Chunk.Elements<>1 then
        Raise EErrorFmt(5509, [85]);

      if DataRemaining < SizeOf(Header) then
        Raise EError(5519);
      F.ReadBuffer(Header, SizeOf(Header));
      if (Header.TAG[0]<>Ord('G'))
      or (Header.TAG[1]<>Ord('B'))
      or (Header.TAG[2]<>Ord('S'))
      or (Header.TAG[3]<>Ord('P'))
      or (Header.TAG[4]<>0) then
        Raise EErrorFmt(5520, [FBsp.Name, 0]); //FIXME: Bad values!

      if Header.Version<>GBSP_VERSION then
        Raise EErrorFmt(5509, [85]);

      FBsp.Specifics.Values['BSPTime']:=Format('%d-%d-%d-%d-%d-%d-%d-%d',
        [Header.BSPTime.wYear,
         Header.BSPTime.wMonth,
         Header.BSPTime.wDayOfWeek,
         Header.BSPTime.wDay,
         Header.BSPTime.wHour,
         Header.BSPTime.wMinute,
         Header.BSPTime.wSecond,
         Header.BSPTime.wMilliseconds]);

      continue;
    end;

    if (Chunk.xType<0) or (Chunk.xType>=HEADER_CHUNKS) then
    begin
      if Chunk.xType=GBSP_CHUNK_END then
        break;
      Raise EErrorFmt(5509, [83]);
    end;

    if Chunk.Size*Chunk.Elements < 0 then
      Raise EErrorFmt(5509, [84]);

    Q:=MakeFileQObject(F, BspG3DEntryNames[Chunk.xType], FBsp);
    FBsp.SubElements.Add(Q);
    LoadedItem(rf_Default, F, Q, Chunk.Size*Chunk.Elements);
    Dec(DataRemaining, Chunk.Size*Chunk.Elements);
  end;
end;

procedure QBspG3DFileHandler.SaveBsp(Info: TInfoEnreg1);
var
  Chunk: TGBSP_Chunk;
  Header: TGBSP_Header;
  ChunkOrigine, Fin: TStreamPos;
  Q: QObject;
  I: Integer;
begin
  ProgressIndicatorStart(5450, HEADER_CHUNKS);
  try
    { write header }
    Chunk.xType:=GBSP_CHUNK_HEADER;
    Chunk.Size:=SizeOf(Header);
    Chunk.Elements:=1;
    Info.F.WriteBuffer(Chunk, SizeOf(Chunk));

    Header.TAG[0]:=Ord('G');
    Header.TAG[1]:=Ord('B');
    Header.TAG[2]:=Ord('S');
    Header.TAG[3]:=Ord('P');
    Header.TAG[4]:=0;
    Header.Version:=GBSP_VERSION;
    GetSystemTime(Header.BSPTime);
    Info.F.WriteBuffer(Header, SizeOf(Header));

    { write .bsp entries }
    for I:=1 to HEADER_CHUNKS-1 do
    begin
      Q := FBsp.BspEntry[I];
      if Q=nil then
        continue;

      ChunkOrigine := Info.F.Position;
      Chunk.xType:=I;
      Chunk.Size:=0;  { updated later }
      Chunk.Elements:=0; //FIXME
      Info.F.WriteBuffer(Chunk, SizeOf(Chunk));

      Q.SaveFile1(Info);   { save in non-QuArK file format }

      { update header }
      Fin := Info.F.Position;
      Info.F.Position := ChunkOrigine;
      Info.F.WriteBuffer(Chunk, SizeOf(Chunk));
      Info.F.Position := Fin;

      ProgressIndicatorIncrement;
    end;

    Chunk.xType:=GBSP_CHUNK_END;
    Chunk.Size:=0;
    Chunk.Elements:=0;
    Info.F.WriteBuffer(Chunk, SizeOf(Chunk));
  finally
    ProgressIndicatorStop;
  end;
end;

function QBspG3DFileHandler.GetEntryName(const EntryIndex: Integer) : String;
begin
  if (EntryIndex<0) or (EntryIndex>=HEADER_CHUNKS) then
    raise InternalE('Tried to retrieve name of invalid BSP chunk!');
  Result:=BspG3DEntryNames[EntryIndex];
end;

function QBspG3DFileHandler.GetLumpEdges: Integer;
begin
  Result:=-1;
end;

function QBspG3DFileHandler.GetLumpEntities: Integer;
begin
  Result:=GBSP_CHUNK_ENTDATA;
end;

function QBspG3DFileHandler.GetLumpFaces: Integer;
begin
  Result:=GBSP_CHUNK_FACES;
end;

function QBspG3DFileHandler.GetLumpLeafs: Integer;
begin
  Result:=GBSP_CHUNK_LEAFS;
end;

function QBspG3DFileHandler.GetLumpLeafFaces: Integer;
begin
  Result:=GBSP_CHUNK_LEAF_FACES;
end;

function QBspG3DFileHandler.GetLumpModels: Integer;
begin
  Result:=GBSP_CHUNK_MODELS;
end;

function QBspG3DFileHandler.GetLumpNodes: Integer;
begin
  Result:=GBSP_CHUNK_NODES;
end;

function QBspG3DFileHandler.GetLumpPlanes: Integer;
begin
  Result:=GBSP_CHUNK_PLANES;
end;

function QBspG3DFileHandler.GetLumpSurfEdges: Integer;
begin
  Result:=-1;
end;

function QBspG3DFileHandler.GetLumpTexInfo: Integer;
begin
  Result:=GBSP_CHUNK_TEXINFO;
end;

function QBspG3DFileHandler.GetLumpTextures: Integer;
begin
  Result:=GBSP_CHUNK_TEXTURES;
end;

function QBspG3DFileHandler.GetLumpVertexes: Integer;
begin
  Result:=GBSP_CHUNK_VERTS;
end;

 {------------------------}

initialization
  RegisterQObject(QBspG3D,  '!');
end.
