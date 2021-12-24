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
unit QkZip2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkObjects, QkFileObjects, TB97, QkFileExplorer, QkListView, BrowseForFolder,
  ComCtrls, QkForm, QkGroup, Python, QkPak;

{
  Zip File Structure is as follows:

  +============================+
  |  Local File Header (1)     |
  +----------------------------+
  |   File Data        (1)     |
  +----------------------------+
  |             .              |
  |             .              |
  |             .              |
  +----------------------------+
  |  Local File Header (n)     |
  +----------------------------+
  |   File Data        (n)     |
  +============================+
  | Central Dir File Header(1) |
  +----------------------------+
  |             .              |
  |             .              |
  |             .              |
  +----------------------------+
  | Central Dir File Header(n) |
  +============================+
  |     End Of Central Dir     |
  +============================+
}

type
  TLocalfileheader = packed record
    version_needed       : SmallInt;
    bit_flag             : SmallInt;
    compression_method   : SmallInt;
    last_mod_datetime    : Longint;
    crc_32               : Longint;
    compressed           : Longint;
    uncompressed         : Longint;
    filename_len         : SmallInt;
    extrafield_len       : SmallInt;
  end;

  TFileHeader = packed record
    version_by            : smallint;
    version_needed        : smallint;
    bit_flag              : smallint;
    compression_method    : smallint;   //  8
    last_mod_datetime     : longint;
    crc_32                : longint;
    compressed            : longint;
    uncompressed          : longint;    //  24
    filename_len          : smallint;
    extrafield_len        : smallint;
    filecomment_len       : smallint;
    disk_start_no         : smallint;
    internal_attrs        : smallint;   //  34
    external_attrs        : longint;
    local_header_offset   : longint;    //  42
  end;

  TEndOfCentralDir = packed record
    disk_no             : smallint;
    start_of_cd         : smallint;
    no_entries_disk     : smallint;
    no_entries          : smallint;  //  8
    size_cd             : longint;
    offset_CD           : longint;   //  16
    zipfilecomment_len  : smallint;  //  18
  end;

  PEndOfCentralDir = ^TEndOfCentralDir;

  QZipFolder = class(QPakFolder)
  private
//    procedure RecGO1(const SubPath: String; extracted: PyObject);
  protected
    procedure WritePakEntries(Info: TInfoEnreg1; Origine: TStreamPos; const Chemin: String; TailleNom: Integer; Repertoire: TStream; eocd: PEndOfCentralDir);
    procedure SaveFile(Info: TInfoEnreg1); override;
    procedure LoadFile(F: TStream; FSize: TStreamPos); override;
//    function OpenWindow(nOwner: TComponent) : TQForm1; override;
//    procedure SortPakFolder;
  public
    class function TypeInfo: String; override;
    class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
    function FindFile(const PakPath: String) : QFileObject; override;
    function GetFolder(Path: String) : QZipFolder;
//    function PyGetAttr(attr: PChar) : PyObject; override;
//    procedure ObjectState(var E: TEtatObjet); override;
//    function CreateOwnExplorer(nOwner: TComponent) : TWinControl; override;
//    function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
//    procedure AddFileWithPath(PathAndShortName: String; Q: QFileObject; SetName: Boolean);
//    function ExtractTo(PathBase: String) : Integer;
//    procedure Go1(maplist, extracted: PyObject; var FirstMap: String; var QCList: TQList); override;
  end;

  QZipPak = class(QZipFolder)
  public
    class function TypeInfo: String; override;
    class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
    procedure ObjectState(var E: TEtatObjet); override;
  end;

implementation

uses Travail, QkExplorer, Quarkx, QkExceptions, PyObjects, Game, crc32, UNZIP, ZIP, QkObjectClassList,
     ExtraFunctionality;

const
  cZIP_HEADER   = $04034B50;
  cCFILE_HEADER = $02014B50;
  cEOCD_HEADER  = $06054B50;
  quark_zip_comment = 'by QuArK';
  quark_zip_comment_temp = quark_zip_comment + ' (temporary)';
  cSTORED_COMPRESSION = 0;
  cSHRUNK_COMPRESSION = 1;
  cIMPLODED_COMPRESSION = 6;
  cDEFLATED_COMPRESSION = 8;

function BuildLFH(ver, bit, com, las, crc, cmp, unc, fil, ext:longint) : TLocalFileHeader;
begin
  Result.version_needed     := ver;
  Result.bit_flag           := bit;
  Result.compression_method := com;
  Result.last_mod_datetime  := las;
  Result.crc_32             := crc;
  Result.compressed         := cmp;
  Result.uncompressed       := unc;
  Result.filename_len       := fil;
  Result.extrafield_len     := ext;
end;

function BuildFH(ver, vby, bit, com, las, crc, cmp, unc, fil, ext, fcm, ita, exa, lho, dsn:longint) : TFileHeader;
begin
  Result.version_by          := vby;
  Result.version_needed      := ver;
  Result.bit_flag            := bit;
  Result.compression_method  := com;
  Result.last_mod_datetime   := las;
  Result.crc_32              := crc;
  Result.compressed          := cmp;
  Result.uncompressed        := unc;
  Result.filename_len        := fil;
  Result.extrafield_len      := ext;
  Result.filecomment_len     := fcm;
  Result.internal_attrs      := ita;
  Result.external_attrs      := exa;
  Result.local_header_offset := lho;
  Result.disk_start_no       := dsn;
end;

function BuildEOCD(dn, sod, nod, ent, siz, off, zfn:Longint) : TEndOfCentralDir;
begin
  Result.disk_no            := dn;
  Result.start_of_cd        := sod;
  Result.no_entries_disk    := nod;
  Result.no_entries         := ent;
  Result.size_cd            := siz;
  Result.offset_CD          := off;
  Result.zipfilecomment_len := zfn;
end;

procedure ReadaString(f:TStream; var s:String; size:Integer);
begin
  SetLength(s, size);   { reserve space for the string }
  f.readbuffer(PChar(s)^, size);  { read it in a single operation }
end;

type
  TPakSibling = class(TInfoEnreg1)
  private
    BaseFolder: String;
    Folder: QZipFolder;
  public
    procedure WriteSibling(const Path: String; Obj: QObject); override;
  end;

procedure TPakSibling.WriteSibling(const Path: String; Obj: QObject);
var
  I: Integer;
begin
  if Obj is QFileObject then
  begin
    if CompareText(BaseFolder, Copy(Path, 1, Length(BaseFolder))) = 0 then
      I:=Length(BaseFolder)+1
    else
    begin
      GlobalWarning(FmtLoadStr1(5666, [Path, BaseFolder]));
      I:=1;
    end;
    Folder.AddFileWithPath(Copy(Path, I, MaxInt), QFileObject(Obj), True);
  end
  else
    inherited;
end;

procedure QZipFolder.WritePakEntries(Info: TInfoEnreg1; Origine: TStreamPos; const Chemin: String; TailleNom: Integer; Repertoire: TStream; eocd: PEndOfCentralDir);
var
  I: Integer;
  Q: QObject;
  S: String;
  Info1: TPakSibling;
  TempStream,T2:TMemoryStream;
  tInfo: TInfoEnreg1;
  LFS: TLocalFileHeader;
  OrgSize,Size,pos: TStreamPos;
  crc: DWORD;
  cdir:TFileHeader;
  sig:Longint;
begin
  Acces;
  ProgressIndicatorStart(5442, SubElements.Count);
  try
    Info1:=TPakSibling.Create;
    try
      Info1.BaseFolder:=Chemin;
      Info1.Folder:=Self;
      WriteSiblingsTo(Info1);
      Info.TempObject.AddRef(-1);
      Info.TempObject:=Info1.TempObject;
      Info.TempObject.AddRef(+1);
    finally
      Info1.Free;
    end;

    for I:=0 to SubElements.Count-1 do
    begin
      Q:=SubElements[I];
      if Q is QPakFolder then   { save as folder in the .pak }
        QZipFolder(Q).WritePakEntries(Info, Origine, Chemin+Q.Name+'/', TailleNom, Repertoire, eocd)
      else
      begin
        S:=Chemin+Q.Name+Q.TypeInfo;
        T2:=TMemoryStream.Create;
        try
         { First Save The File Data To A Memory Stream}
          TempStream:=TMemoryStream.Create;
          try
            tInfo:=TInfoEnreg1.Create;
            try
              tInfo.Format:=Info.Format;
              tInfo.TransfertSource:=Info.TransfertSource;
              tInfo.TempObject:=Info.TempObject;
              tInfo.F:=TempStream;
              Q.SaveFile1(tInfo);   { save in non-QuArK file format }
            finally
              tInfo.Free;
            end;
            crc:=$FFFFFFFF;
            CalcCRC32(TempStream.Memory, TempStream.Size, crc);
            crc:=not crc;
            TempStream.Seek(0, soFromBeginning);
            OrgSize:=TempStream.Size;

           { Compress Data From TempStream To T2}
            CompressStream(TempStream, T2);
            T2.Seek(0, soFromBeginning);
            Size:=T2.Size;
          finally
            TempStream.Free;
          end;

          pos:=Info.F.Position; // Save Local Header Offset
         {Write File Entry}
          LFS:=BuildLFH(10, 0, 8, DateTimeToFileDate(Now()), crc, Size, OrgSize, length(s), 0);
          sig:=cZIP_HEADER;
          Info.F.WriteBuffer(sig, 4);
          Info.F.WriteBuffer(LFS, Sizeof(TLocalFileHeader));
          Info.F.WriteBuffer(PChar(S)^, Length(S));
         {/Write File Entry}

          cdir:=BuildFH(10, 20, 0, 8, DateTimeToFileDate(Now()), crc, Size, OrgSize, length(s), 0, 0, 0, {-2118778880} LongInt($81B60000), pos, 0);
          sig:=cCFILE_HEADER;
          Repertoire.WriteBuffer(sig, 4);
          Repertoire.WriteBuffer(cdir, sizeof(TFileHeader));
          Repertoire.WriteBuffer(PChar(S)^, Length(S));

          inc(eocd^.no_entries_disk);
          inc(eocd^.no_entries);
          inc(eocd^.size_cd, (4 + sizeof(TFileHeader) + Length(S)));

          Info.F.CopyFrom(T2, T2.Size);       {Write Actual File Data ( Compressed ) }
        finally
          T2.Free;
        end;
      end;
      ProgressIndicatorIncrement;
    end;
  finally
    ProgressIndicatorStop;
  end;
end;

procedure QZipFolder.SaveFile(Info: TInfoEnreg1);
var
  Repertoire: TMemoryStream;
  Origine, Fin: TStreamPos;
  sig: LongInt;
  EOCDHeader: TEndOfCentralDir;
  comment: string;
begin
  with Info do begin
    case Format of
      rf_Default: begin  { as stand-alone file }
        Fin:=0;
        Origine:=F.Position;
        { write .pak entries }
        Repertoire:=TMemoryStream.Create;
        try
          if Specifics.Values['temp']<>'' then
          begin
            comment:=quark_zip_comment_temp;
          end
          else
          begin
            comment:=quark_zip_comment;
          end;

          EOCDHeader:=BuildEOCD(0, 0, 0, 0, 0, 0, Length(comment));

          WritePakEntries(Info, Origine, '', Fin, Repertoire, @EOCDHeader);

          EOCDHeader.offset_CD:=F.Position;

          Repertoire.Seek(0, soFromBeginning);
          F.CopyFrom(Repertoire, 0);
        finally
          Repertoire.Free;
        end;

        sig:=cEOCD_HEADER;
        F.WriteBuffer(sig, 4);
        F.WriteBuffer(EOCDHeader, sizeof(TEndOfCentralDir));
        F.WriteBuffer(comment[1], Length(comment));
      end;
      else
        inherited;
    end;
  end;
end;

Function ZipAddRef(Ref: PQStreamRef; var S: TStream) : TStreamPos;
var
  mem: TMemoryStream;
  err: integer;
begin
  Ref^.Self.Position:=Ref^.Position;
  mem:=TMemoryStream.Create;
  try
    err:=UnZipFile(Ref^.Self, mem, Ref^.Position);
    if err<>0 then
      raise EErrorFmt(5815, [err]);
    Result:=mem.Size;
    mem.Position:=0;
    S:=mem;
  except
    mem.Free;
    raise
  end;
end;

procedure QZipFolder.LoadFile(F: TStream; FSize: TStreamPos);
var
  J: Integer;
  Dossier, nDossier: QObject;
  Chemin, CheminPrec,fn: String;
  dummystring: String;
  Q: QObject;
  FH: TFileHeader;
  org,Size:TStreamPos;
  files: TMemoryStream;
  EoSig,s: Longint;
  nEnd:TStreamPos;
  eocd: TEndOfCentralDir;
  I:Smallint;
  eocd_found: boolean;
begin
  case ReadFormat of
    rf_Default: begin  { as stand-alone file }
      Dossier:=Self;
      CheminPrec:='';
      org:=f.position;

      if (FSize < sizeof(TEndOfCentralDIR)) then
        raise Exception.CreateFmt('File "%s" is corrupt, please correct or remove it.\nFilesize less than minimum required size (%d < %d).', [LoadName, FSize, sizeof(TEndOfCentralDIR)]);

      f.seek(FSize-sizeof(TEndOfCentralDIR), soFromBeginning); // EOCD is stored at least -Sizeof(endofcentraldir) header
      eocd_found:=false;
      while (f.position > org) do
      begin
        f.ReadBuffer(eosig, 4);                         // check for cEOCD_HEADER signature
        eocd_found := (eosig = cEOCD_HEADER);
        if not eocd_found then
          f.seek(-5, soFromCurrent)                     // Skip back 1 byte, and recheck
        else
          break;
      end;
      if not eocd_found then
      begin
        f.seek(org, soFromBeginning); // Restore original file position, just in case
        raise Exception.CreateFmt('File "%s" is corrupt. cEOCD_HEADER(%d) not found', [LoadName, cEOCD_HEADER]);
      end;

      f.readbuffer(eocd, sizeof(eocd));
      if eocd.disk_no<>0 then
        raise Exception.CreateFmt('File "%s" cannot be loaded: it is spanned across several disks', [LoadName]);
      if eocd.zipfilecomment_len <> 0 then
      begin
        setlength(dummystring, eocd.zipfilecomment_len);
        f.readbuffer(dummystring[1], eocd.zipfilecomment_len);
        if dummystring = quark_zip_comment_temp then
        begin
          Specifics.Values['temp']:= '1';
        end;
      end;
      f.seek(org + eocd.offset_cd, soFromBeginning); {seek to central directory}
      files:=TMemoryStream.Create;    {ms for central directory}
      try
        files.CopyFrom(f, eocd.size_cd); {read in central dir}
        files.seek(0, soFromBeginning);

        ProgressIndicatorStart(5461, eocd.no_entries);
        try
          for i:=1 to eocd.no_entries do
          begin
            files.ReadBuffer(s, 4); // Signature
            if s<>cCFILE_HEADER then
              raise Exception.CreateFmt('Central directory for file "%s" is corrupt: %d<>%d(cCFILE_HEADER)', [LoadName, s, cCFILE_HEADER]);

            files.ReadBuffer(FH, sizeof(TFileHeader));

            ReadaString(files, chemin,      FH.filename_len);
            ReadaString(files, dummystring, FH.extrafield_len);
            ReadaString(files, dummystring, FH.filecomment_len);

            { store original filename for later check }
            fn:=Chemin;

            { check compression method, that it is one we can decompress }
            if  (FH.compression_method<>cSTORED_COMPRESSION)
            and (FH.compression_method<>cSHRUNK_COMPRESSION)
            and (FH.compression_method<>cIMPLODED_COMPRESSION)
            and (FH.compression_method<>cDEFLATED_COMPRESSION) then
              Raise EErrorFmt(5692, [LoadName, FH.compression_method]);

            { if previous file's path, is the same as this file's path, then reuse the Dossier-pointer.
              Else reset the Dossier-pointer to self. }
            if Copy(Chemin, 1, Length(CheminPrec)) = CheminPrec then
              Delete(Chemin, 1, Length(CheminPrec))
            else
            begin
              Dossier:=Self;
              CheminPrec:='';
            end;

            { Find the correct .zipfolder, or create a new one for this file. }
            repeat
              J:=Pos('/', Chemin);
              if J=0 then
                Break;
              nDossier:=Dossier.SubElements.FindName(Copy(Chemin, 1, J-1) + '.zipfolder');
              if (nDossier=Nil) then
              begin
                nDossier:=QZipFolder.Create(Copy(Chemin, 1, J-1), Dossier);
                Dossier.SubElements.Add(nDossier);
              end;
              CheminPrec:=CheminPrec + Copy(Chemin, 1, J);
              Delete(Chemin, 1, J);
              Dossier:=nDossier;
            until False;

            Size:=FH.compressed;

            { if this file, really is a file and not just a path, then add it as a sub-element }
            if fn[length(fn)]<>'/' then
            begin
              Size:=Size + (FH.extrafield_len + FH.filename_len + 4 + sizeof(FH) + FH.filecomment_len);
              Q:=OpenFileObjectData(nil, Chemin, Size, Dossier);
              Dossier.SubElements.Add(Q);
              F.Seek(Org + fh.local_header_offset, soFromBeginning);
              {Copied From LoadedItem & Modified}
              if Q is QFileObject then
                QFileObject(Q).ReadFormat:=rf_default
              else
                Raise InternalE('LoadedItem '+Q.GetFullName+' '+IntToStr(rf_default));
              nEnd:=F.Position+Size;
              Q.Open(TQStream(F), Size);
              F.Position:=nEnd;
              {/Copied From LoadedItem & Modified}
              Q.FNode^.OnAccess:=ZipAddRef;
            end;
            ProgressIndicatorIncrement;
          end;
          SortPakFolder;
        finally
          ProgressIndicatorStop;
        end;
      finally
        files.free;
      end;
    end;
    else
      inherited;
  end;
end;

class function QZipFolder.TypeInfo;
begin
  Result:='.zipfolder';
end;

class procedure QZipFolder.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5136);
  Info.WndInfo:=[wiSameExplorer];
end;

function QZipFolder.FindFile(const PakPath: String) : QFileObject;
var
  I: Integer;
  Folder: QObject;
begin
  Acces;
  for I:=1 to Length(PakPath) do
  begin
    if PakPath[I] in ['/','\'] then
    begin
      Folder:=SubElements.FindName(Copy(PakPath, 1, I-1) + '.zipfolder');
      if (Folder=Nil) or not (Folder is QZipFolder) then
        Result:=Nil
      else
        Result:=QZipFolder(Folder).FindFile(Copy(PakPath, I+1, MaxInt));
      Exit;
    end;
  end;
  Result:=SubElements.FindName(PakPath) as QFileObject;
end;

function QZipFolder.GetFolder(Path: String) : QZipFolder;
var
  I, J: Integer;
  Folder: QObject;
begin
  Result:=Self;
  while Path<>'' do
  begin
    I:=Pos('/',Path); if I=0 then I:=Length(Path)+1;
    J:=Pos('\',Path); if J=0 then J:=Length(Path)+1;
    if I>J then
      I:=J;
    Folder:=Result.SubElements.FindName(Copy(Path, 1, I-1) + '.zipfolder');
    if Folder=Nil then
    begin
      Folder:=QZipFolder.Create(Copy(Path, 1, I-1), Result);
      Result.SubElements.Add(Folder);
    end;
    Result:=Folder as QZipFolder;
    System.Delete(Path, 1, I);
  end;
end;

class function QZipPak.TypeInfo;
begin
  Result:='.zip';
end;

class procedure QZipPak.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5169);
  Info.FileExt:=797;
  Info.WndInfo:=[wiOwnExplorer];
end;

procedure QZipPak.ObjectState(var E: TEtatObjet);
begin
  inherited;
  E.IndexImage:=iiPak;
end;

{
procedure QZipFolder.SortPakFolder;
var
 Q: QObject;
 I: Integer;
begin
  SubElements.Sort(ByPakOrder);
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if not (Q is QZipFolder) then
      Break;
    QZipFolder(Q).SortPakFolder;
  end;
end;
}
{
procedure QZipFolder.ObjectState(var E: TEtatObjet);
begin
  inherited;
  E.IndexImage:=iiPakFolder;
  E.MarsColor:=clLime;
end;
}
{
function ByPakOrder(Item1, Item2: Pointer) : Integer;
var
 Q1: QObject absolute Item1;
 Q2: QObject absolute Item2;
begin
 if Q1 is QZipFolder then
  if Q2 is QZipFolder then
   Result:=CompareText(Q1.Name, Q2.Name)
  else
   Result:=-1
 else
  if Q2 is QZipFolder then
   Result:=1
  else
   begin
    Result:=CompareText(Q1.Name, Q2.Name);
    if Result=0 then
     Result:=CompareText(Q1.TypeInfo, Q2.TypeInfo);
   end;
end;
}
{
function QZipFolder.CreateOwnExplorer;
begin
  Result:=TPakExplorer.Create(nOwner);
  Result.Width:=170;
end;
}
{
procedure QZipFolder.AddFileWithPath(PathAndShortName: String; Q: QFileObject; SetName: Boolean);
var
  I: Integer;
  Folder: QZipFolder;
  Q1: QObject;
begin
  Q.AddRef(+1);
  try
    I:=Length(PathAndShortName);
    while (I>0) and not (PathAndShortName[I] in ['/','\']) do
      Dec(I);
    Folder:=GetFolder(Copy(PathAndShortName, 1, I));
    Q.FParent:=Folder;
    PathAndShortName:=Copy(PathAndShortName, I+1, MaxInt);
    if SetName then
      Q.Name:=PathAndShortName;
    Q1:=Folder.SubElements.FindName(PathAndShortName);
    if Q1<>Nil then begin
      I:=Folder.SubElements.IndexOf(Q1);
      Folder.SubElements[I]:=Q;
    end else
      Folder.SubElements.Add(Q);
  finally
    Q.AddRef(-1);
  end;
end;
}
{
function QZipFolder.ExtractTo(PathBase: String) : Integer;
var
  I: Integer;
  Q: QObject;
begin
  Result:=0;
  if PathBase<>'' then PathBase:=IncludeTrailingPathDelimiter(PathBase);
  for I:=1 to Length(PathBase) do
    if IsPathDelimiter(PathBase, I) then begin
      PathBase[I]:=#0;
      CreateDirectory(PChar(PathBase), Nil);
      PathBase[I]:=PathDelim;
    end;
  Acces;
  for I:=0 to SubElements.Count-1 do begin
    Q:=SubElements[I];
    if Q is QZipFolder then
      Inc(Result, QZipFolder(Q).ExtractTo(PathBase+Q.Name))
    else
      if Q is QFileObject then begin
        QFileObject(Q).SaveInFile(rf_Default, PathBase+Q.Name+Q.TypeInfo);
        Inc(Result);
      end;
  end;
end;
}
{
procedure QZipFolder.Go1(maplist, extracted: PyObject; var FirstMap: String; var QCList: TQList);
begin
  RecGO1('', extracted);
end;
}
{
function QZipFolder.PyGetAttr(attr: PChar) : PyObject;
var
  I: Integer;
begin
  Result:=inherited PyGetAttr(attr);
  if Result<>Nil then
    Exit;
  for I:=Low(MethodTable) to High(MethodTable) do
    if StrComp(attr, MethodTable[I].ml_name) = 0 then begin
      Result:=PyCFunction_New(MethodTable[I], @PythonObj);
      Exit;
    end;
end;
}
{
procedure QZipFolder.RecGO1(const SubPath: String; extracted: PyObject);
var
  I: Integer;
  Q: QObject;
  S: String;
  v: PyObject;
begin
  Acces;
  ProgressIndicatorStart(175, SubElements.Count);
  try
    for I:=0 to SubElements.Count-1 do begin
      Q:=SubElements[I];
      if Q is QZipFolder then
        QZipFolder(Q).RecGO1(SubPath+Q.Name+'/', extracted)
      else
        if Q is QFileObject then begin
          S:=SubPath+Q.Name+Q.TypeInfo;
          v:=PyString_FromString(PChar(S));
          PyList_Append(extracted, v);
          Py_DECREF(v);
          S:=OutputFile(S);
          QFileObject(Q).SaveInFile(rf_Default, S);
        end;
      ProgressIndicatorIncrement;
    end;
  finally
    ProgressIndicatorStop;
  end;
end;
}
{
function pExtract(self, args: PyObject) : PyObject; cdecl;
var
  pathbase: PChar;
begin
  Result:=Nil;
  try
    if not PyArg_ParseTupleX(args, 's', [@pathbase]) then
      Exit;
    ProgressIndicatorStart(0,0);
    try
      Result:=PyInt_FromLong((QkObjFromPyObj(self) as QZipFolder).ExtractTo(pathbase));
    finally
      ProgressIndicatorStop;
    end;
  except
    Py_XDECREF(Result);
    EBackToPython;
    Result:=Nil;
  end;
end;
}
{
function pGetFolder(self, args: PyObject) : PyObject; cdecl;
var
  path: PChar;
begin
  Result:=Nil;
  try
    if not PyArg_ParseTupleX(args, 's', [@path]) then
      Exit;
    Result:=GetPyObj((QkObjFromPyObj(self) as QZipFolder).GetFolder(path));
  except
    Py_XDECREF(Result);
    EBackToPython;
    Result:=Nil;
  end;
end;
}
{
const
  MethodTable: array[0..1] of TyMethodDef =
  ((ml_name: 'extract';        ml_meth: pExtract;        ml_flags: METH_VARARGS),
   (ml_name: 'getfolder';      ml_meth: pGetFolder;      ml_flags: METH_VARARGS));
}

initialization
  RegisterQObject(QZipPak, 't');
  RegisterQObject(QZipFolder, 'a');
end.
