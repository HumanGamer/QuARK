{
$Header$
----------- REVISION HISTORY ------------
$Log$
Revision 1.1  2000/10/11 18:58:21  aiv
Initial Release

}

unit Qk3ds;

interface

uses
  SysUtils, Classes, QkObjects, QkFileObjects, QkImages, Python, Game, QkModelFile, QMath,
  Graphics, Windows, QkModelRoot, QkMdlObject, QkFrame, QkComponent;

const
  TAG_MAIN      = $4d4d;
  TAG_VERSION   = $0002;
  TAG_3DEDIT    = $3d3d;
  TAG_OBJECT    = $4000;
  TAG_MESH      = $4100;
  TAG_VERTEX    = $4110;
  TAG_TRIANGLE  = $4120;
  TAG_TEXVERTEX = $4140;

type
  TChunkHeader = packed record
    Tag: Word;
    Length: DWord;
  end;
  Q3DSFile = class(QModelFile)
  private
    BeginOfFile: Longint; // Can put here as it doesn't get saved.
    Procedure ReadMainChunk(F: TStream; FSize: Integer; org: Longint; Root: QModelRoot);
    Procedure ReadVersionChunk(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint);
    Procedure Read3dEditorChunk(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Root: QModelRoot);
    Procedure ReadObjects(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Root: QModelRoot);
    Procedure ReadObject(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Root: QModelRoot);
    Procedure ReadMesh(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Comp: QComponent);
    Procedure SkipChunk(var s: TStream; Chunk: TChunkHeader);
    Function Overflowed(F: TStream; Parent: TChunkHeader): boolean;
    Function SkipUntilFound(F: TStream; Parent: TChunkHeader; org: Longint; LookingFor: DWord): boolean;
  protected
    procedure LoadFile(F: TStream; FSize: Integer); override;
    procedure SaveFile(Info: TInfoEnreg1); override;
  public
    class function TypeInfo: String; override;
    class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
  end;

implementation

uses QuarkX, Setup, Travail;

class function Q3DSFile.TypeInfo;
begin
  Result:='.3ds';
end;

class procedure Q3DSFile.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5178);
  Info.FileExt:=807;
end;

Procedure Q3dsFile.SkipChunk(var s: TStream; Chunk: TChunkHeader);
begin
  s.position:=s.position + Chunk.Length-6;
end;

Procedure Q3dsFile.ReadVersionChunk(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint);
var
  chunk: TChunkHeader;
  version: dword;
begin
  f.readbuffer(chunk, sizeof(TChunkHeader));
  if (chunk.tag<>TAG_VERSION) then
    raise exception.create('Invalid .3ds File'#13#10'Q3dsfile.ReadVersionChunk: chunk.Tag<>TAG_VERSION');
  f.readbuffer(version, sizeof(version));
  if (version<>3) then
    raise exception.create('Invalid .3ds File version'#13#10'Q3dsfile.ReadVersionChunk: Version<>3');
end;

Procedure Q3dsFile.ReadMainChunk(F: TStream; FSize: Integer; org: Longint; Root: QModelRoot);
var
  chunk: TChunkHeader;
begin
  f.readbuffer(chunk, sizeof(TChunkHeader));
  if (Chunk.tag<>TAG_MAIN) then
    raise exception.create('Invalid .3ds File'#13#10'Q3dsfile.ReadMainChunk: Chunk.Tag<>TAG_MAIN');
  ReadVersionChunk(F, FSize, Chunk, f.position-sizeof(chunk));
  Read3dEditorChunk(F, FSize, Chunk, f.position-sizeof(chunk), Root);
end;

Function Q3dsFile.Overflowed(F: TStream; Parent: TChunkHeader): boolean;
begin
  Result:=F.Position+sizeof(TChunkHeader)>BeginOfFile+Parent.length
end;

Function Q3dsFile.SkipUntilFound(F: TStream; Parent: TChunkHeader; org: Longint; LookingFor: DWord): boolean;
var
  chunk: TChunkHeader;
  found: boolean;
begin
  f.readbuffer(chunk, sizeof(TChunkHeader));
  found:=chunk.tag=LookingFor;
  while not found do begin
    SkipChunk(F, Chunk);
    if OverFlowed(F, Parent) then begin
      found:=false;
      break;
    end;
    f.readbuffer(chunk, sizeof(TChunkHeader));
    found:=chunk.tag=LookingFor;
  end;
  result:=found;
  if found then
    f.position:=f.position-6
  else
    f.position:=org;
end;

Procedure Q3dsFile.Read3dEditorChunk(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Root: QModelRoot);
var
  chunk: TChunkHeader;
  found: boolean;
begin
  found:=SkipUntilFound(F, Parent, Org, TAG_3DEDIT);
  if not found then
    raise exception.create('Cannot read .3ds File (no 3d editor chunk)'#13#10'Q3dsfile.Read3dEditorChunk: SkipUntilFound(TAG_3DEDIT)=false');
  f.readbuffer(chunk, sizeof(TChunkHeader));
  ReadObjects(F, FSize, Chunk, f.position-sizeof(chunk), Root);
end;

Procedure Q3dsFile.ReadObjects(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Root: QModelRoot);
var
  objchunk: TChunkHeader;
  found: boolean;
  org2: Integer;
begin
  found:=SkipUntilFound(F, Parent, Org, TAG_OBJECT);
  if not found then
    raise exception.create('Cannot read .3ds File (no object chunk)'#13#10'Q3dsfile.ReadObjects: SkipUntilFound(TAG_OBJECT)=false');
  org2:=f.position;
  f.readbuffer(objchunk, sizeof(TChunkHeader));
  while objchunk.tag = TAG_OBJECT do begin
    ReadObject(F, FSize, objchunk, f.position-sizeof(TChunkHeader), Root);
    if OverFlowed(F, Parent) then
      break;
    f.seek(objchunk.length+org2, soFromBeginning);
    f.readbuffer(objchunk, sizeof(TChunkHeader));
  end;
end;

Function ReadStrZ(F: TStream): string;
var
  ch: char;
begin
  result:='';
  repeat
    f.readbuffer(ch, 1);
    if ch<>#0 then
      result:=result+ch;
  until ch=#0;
end;

Procedure Q3dsFile.ReadObject(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Root: QModelRoot);
var
  chunk: TChunkHeader;
  found: boolean;
  s: string;
  Comp: QComponent;
begin
  s:=readstrz(F);
  found:=SkipUntilFound(F, Parent, Org, TAG_MESH);
//  if not found then
//    raise exception.create('Cannot read .3ds File (no object mesh)'#13#10'Q3dsfile.ReadObject: SkipUntilFound(TAG_MESH)=false');
  Comp:=Self.Loaded_Component(Root, s);
  if found then begin
    f.readbuffer(chunk, sizeof(TChunkHeader));
    ReadMesh(F, FSize, Chunk, f.position-sizeof(TChunkHeader), Comp);
  end;
end;

type
  ttexvert = record
    u,v: single;
  end;
  ttexarray = array[0..0] of ttexvert;

Procedure Q3dsFile.ReadMesh(F: TStream; FSize: Integer; Parent: TChunkHeader; org: Longint; Comp: QComponent);
const
  Spec1 = 'Tris=';
  Spec2 = 'Vertices=';
var
  found: boolean;
  texvert: ^ttexarray;
  abcf: array[0..3] of word;
  num_texvert, num_faces, num_vert: word;
  chunk: TChunkHeader;
  CTris: PComponentTris;
  CVert: vec3_p;
  v: vec3_t;
  s: string;
  i,k,org2: integer;
  FrameObj: QFrame;
begin
  org2:=org+6;
  f.seek(org2, sofrombeginning);
  Self.CantFindTexture(Comp, 'Texture1', point(512,512));
  found:=SkipUntilFound(F, Parent, Org, TAG_TEXVERTEX);
  if not found then
    raise exception.create('Cannot read .3ds File (mesh has no texture vertices)'#13#10'Q3dsfile.ReadObject: SkipUntilFound(TAG_TEXVERTEX)=false');
  /////////////////////////////////////////
  // Read Texture Vertices and Triangles //
  /////////////////////////////////////////
  f.readbuffer(chunk, sizeof(chunk));
  f.readbuffer(num_texvert, sizeof(word));
  getmem(texvert, num_texvert * sizeof(ttexvert));
  try
    f.readbuffer(texvert^, num_texvert * sizeof(ttexvert));
    f.seek(org2, sofrombeginning);
    found:=SkipUntilFound(F, Parent, Org, TAG_TRIANGLE);
    if not found then
      raise exception.create('Cannot read .3ds File (mesh has no faces/triangles)'#13#10'Q3dsfile.ReadObject: SkipUntilFound(TAG_TRIANGLES)=false');
    f.readbuffer(chunk, sizeof(chunk));
    f.readbuffer(num_faces, sizeof(word));
    S:=Spec1;
    SetLength(S, Length(Spec1)+num_faces*SizeOf(TComponentTris));
    PChar(CTris):=PChar(S)+Length(Spec1);
    for i:=1 to num_faces do begin
      f.readbuffer(abcf, sizeof(abcf));
      for k:=0 to 2 do begin
        CTris[k].VertexNo:=abcf[k];
        CTris[k].S:=Round(texvert^[abcf[k]].U)*512;
        CTris[k].T:=Round(texvert^[abcf[k]].V)*512;
      end;
      inc(CTris);
    end;
    comp.SpecificsAdd(s);
  finally
    freemem(texvert, num_texvert * sizeof(ttexvert))
  end;
  /////////////////////////////////////////
  // Read Vertices                       //
  /////////////////////////////////////////
  FrameObj := Loaded_Frame(Comp, 'Frame');
  f.seek(org2, sofrombeginning);
  found:=SkipUntilFound(F, Parent, Org, TAG_VERTEX);
  if not found then
    raise exception.create('Cannot read .3ds File (mesh has no vertices)'#13#10'Q3dsfile.ReadObject: SkipUntilFound(TAG_VERTEX)=false');
  f.readbuffer(chunk, sizeof(chunk));
  f.readbuffer(num_vert, sizeof(word));
  S:=FloatSpecNameOf(Spec2);
  SetLength(S, Length(Spec2)+num_vert*SizeOf(vec3_t));
  PChar(CVert):=PChar(S)+Length(Spec2);
  for i:=1 to num_vert do begin
    f.readbuffer(v, sizeof(v));
    for k:=0 to 2 do begin
      CVert^[k]:=V[k];
    end;
    Inc(CVert);
  end;
  FrameObj.Specifics.Add(S);
end;

procedure Q3DSFile.LoadFile(F: TStream; FSize: Integer);
var
  Root: QModelRoot;
begin
  case ReadFormat of
    1: begin  { as stand-alone file }
      Root:=Loaded_Root;
      BeginOfFile:=F.Position;
      ObjectGameCode:=mjAny;
      try
        ReadMainChunk(F, FSize, F.Position, Root);
      except
        on EReadError do
          raise exception.create('Invalid .3ds File'#13#10'Q3dsfile.LoadFile: Stream Read Error');
        on E: Exception do
          raise exception.Create('Q3dsFile.LoadFile: '+e.message);
      end;
    end;
  end;
end;

procedure Q3DSFile.SaveFile(Info: TInfoEnreg1);
begin
  with Info do begin
    case Format of
      1: begin  { write the .3ds file }
        raise exception.create('Unsupported!');
      end;
      else
        inherited;
    end;
  end;
end;

initialization
  RegisterQObject(Q3DSFile, 'u');
end.
