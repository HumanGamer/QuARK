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
unit QkGCF;

interface

uses Windows, SysUtils, Classes, QkObjects, QkFileObjects, QkPak, QkHLLib;

type
 QGCFFolder = class(QPakFolder)
              private
               HasAPackage : Boolean;
               uiPackage : hlUInt;
               GCFRoot : PHLDirectoryItem;
              protected
                procedure SaveFile(Info: TInfoEnreg1); override;
                procedure LoadFile(F: TStream; FSize: Integer); override;
              public
                constructor Create(const nName: String; nParent: QObject);
                destructor Destroy; override;
                class function TypeInfo: String; override;
                class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
                function FindFile(const PakPath: String) : QFileObject; override;
                function GetFolder(Path: String) : QGCFFolder;
              end;

 QGCF = class(QGCFFolder)
        protected
        public
          class function TypeInfo: String; override;
          procedure ObjectState(var E: TEtatObjet); override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

 {------------------------}

implementation

uses Quarkx, QkExceptions, PyObjects, Game, QkObjectClassList, Logging;

var
  HLLoaded: Boolean;

 {------------ QGCFFolder ------------}

class function QGCFFolder.TypeInfo;
begin
 Result:='.gcffolder';
end;

class procedure QGCFFolder.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5711);
 Info.WndInfo:=[wiSameExplorer];
end;

constructor QGCFFolder.Create(const nName: String; nParent: QObject);
begin
 inherited;
 HasAPackage := false;
end;

destructor QGCFFolder.Destroy;
begin
 if HasAPackage then
   hlDeletePackage(uiPackage);
 inherited;
end;

function MakeFileQObject(const FullName: String; nParent: QObject) : QFileObject;
var
  i: LongInt;
begin
  {wraparound for a stupid function OpenFileObjectData having obsolete parameters }
  {tbd: clean this up in QkFileobjects and at all referencing places}
 Result:=OpenFileObjectData(nil, FullName, i, nParent);
end;

Function GCFAddRef(Ref: PQStreamRef; var S: TStream) : Integer;
var
  mem: TMemoryStream;
  filesize: hlUInt;
  read: hlUInt;
  name: string;
  gcfelement: PHLDirectoryItem;
  GCFStream: PHLStream;
begin
  Ref^.Self.Position:=Ref^.Position;
  mem := TMemoryStream.Create;
  gcfelement := PHLDirectoryItem(Ref^.PUserdata);
  filesize := hlFileGetSize(gcfelement);
  name := PChar(hlItemGetName(gcfelement));
  mem.SetSize(filesize);
  if filesize<> 0 then
  begin
    if hlFileCreateStream(gcfelement, @GCFStream) = hlFalse then
      LogAndRaiseError(FmtLoadStr1(5707, ['hlPackageGetRoot', PChar(hlGetString(HL_ERROR))]));
    try
      if hlStreamOpen(GCFStream, HL_MODE_READ) = hlFalse then
        LogAndRaiseError(FmtLoadStr1(5707, ['hlStreamOpen', PChar(hlGetString(HL_ERROR))]));
      try
        read := hlStreamRead(GCFStream, mem.Memory, filesize);
        if read<>filesize then
          LogAndRaiseError(FmtLoadStr1(5707, ['hlStreamRead', 'Number of bytes read does not equal the file size!']));
      finally
        hlStreamClose(GCFStream);
      end;
    finally
      hlFileReleaseStream(gcfelement, GCFStream);
    end;
  end;
  Result:=mem.Size;
  mem.Position:=0;
  S:=mem;
end;

Procedure AddTree(ParentFolder: QObject; GCFDirectoryFile : PHLDirectoryItem; root: Bool; F: TStream);
var
  Nsubelements : hlUInt;
  GCFDirectoryItem : PHLDirectoryItem;
  I: Integer;
  Folder, Q: QObject;
begin
  if hlItemGetType(GCFDirectoryFile) = HL_ITEM_FOLDER then
  begin
    {handle a folder}
    Folder:= QGCFFolder.Create( PChar(hlItemGetName(GCFDirectoryFile)), ParentFolder) ;
    Log(LOG_VERBOSE,'Made gcf folder object :'+Folder.name);
    ParentFolder.SubElements.Add( Folder );
    if root then
      Folder.TvParent:= nil
    else
      Folder.TvParent:= ParentFolder;

    {recurse into subelements of folder}
    Nsubelements := hlFolderGetCount(GCFDirectoryFile);
    for I:=0 to Nsubelements-1 do
    begin
      GCFDirectoryItem := hlFolderGetItem(GCFDirectoryFile, I);
      AddTree(Folder, GCFDirectoryItem, False, F);
    end;
  end
  else
  begin
    Q := MakeFileQObject( PChar(hlItemGetName(GCFDirectoryFile)), ParentFolder);

    ParentFolder.SubElements.Add( Q );

    Log(LOG_VERBOSE,'Made gcf file object :'+Q.name);
    if Q is QFileObject then
      QFileObject(Q).ReadFormat := rf_default
    else
      Raise InternalE('LoadedItem '+Q.GetFullName+' '+IntToStr(rf_default));
    Q.Open(TQStream(F), 0);
    // i must access the object, from inside the onaccess function
    Q.FNode^.PUserdata:=GCFDirectoryFile;
    Q.FNode^.OnAccess:=GCFAddRef;
  end;
end;

procedure QGCFFolder.LoadFile(F: TStream; FSize: Integer);
var
  //RawBuffer: String;

  GCFDirectoryItem : PHLDirectoryItem;
  Nsubelements, I : hlUInt;
begin
  Log(LOG_VERBOSE,'Loading GCF file: %s',[self.name]);
  case ReadFormat of
    rf_Default: begin  { as stand-alone file }
         if not HLLoaded then
         begin
           if not LoadHLLib then
             Raise EErrorFmt(5719, [GetLastError]);
           HLLoaded:=true;
         end;

         if hlCreatePackage(HL_PACKAGE_GCF, @uiPackage) = hlFalse then
           LogAndRaiseError(FmtLoadStr1(5722, ['hlCreatePackage', PChar(hlGetString(HL_ERROR))]));
         HasAPackage := true;

         if hlBindPackage(uiPackage) = hlFalse then
           LogAndRaiseError(FmtLoadStr1(5722, ['hlBindPackage', PChar(hlGetString(HL_ERROR))]));

         (*//This code would load the entire file --> OutOfMemory!
         SetLength(RawBuffer, FSize);
         F.ReadBuffer(Pointer(RawBuffer)^, FSize);

         if hlPackageOpenMemory(Pointer(RawBuffer), Length(RawBuffer), HL_MODE_READ + HL_MODE_WRITE) = hlFalse then
           LogAndRaiseError(FmtLoadStr1(5722, ['hlPackageOpenMemory', PChar(hlGetString(HL_ERROR))]));

         //so instead, do this:*)

         if hlPackageOpenFile(PhlChar(LoadName), HL_MODE_READ) = hlFalse then //+ HL_MODE_WRITE
           LogAndRaiseError(FmtLoadStr1(5722, ['hlPackageOpenFile', PChar(hlGetString(HL_ERROR))]));

         GCFRoot := hlPackageGetRoot();
         if GCFRoot=nil then
           LogAndRaiseError(FmtLoadStr1(5707, ['hlPackageGetRoot', 'Root element not found!']));

         Nsubelements := hlFolderGetCount(GCFRoot);
         if Nsubelements > 0 then //Prevent underflow by -1 in for-loop
           for I:=0 to Nsubelements-1 do
           begin
             GCFDirectoryItem := hlFolderGetItem(GCFRoot, I);
             AddTree(Self, GCFDirectoryItem, False, F);
           end;
       end;
    else
      inherited;
  end;
end;

procedure QGCFFolder.SaveFile(Info: TInfoEnreg1);
begin
 Log(LOG_VERBOSE,'Saving GCF file: %s',[self.name]);
 with Info do case Format of
  rf_Default: begin  { as stand-alone file }
      if not HLLoaded then
      begin
        if not LoadHLLib then
          Raise EErrorFmt(5719, [GetLastError]);
        HLLoaded:=true;
      end;

      raise EQObjectSavingNotSupported.Create('Saving GCF files is currently not supported.');
     end;
 else inherited;
 end;
end;

function QGCFFolder.FindFile(const PakPath: String) : QFileObject;
var
  I: Integer;
  Folder: QObject;
begin
  Acces;
  for I:=1 to Length(PakPath) do
  begin
    if PakPath[I] in ['/','\'] then
    begin
      Folder:=SubElements.FindName(Copy(PakPath, 1, I-1) + '.gcffolder');
      if (Folder=Nil) or not (Folder is QGCFFolder) then
        Result:=Nil
      else
        Result:=QGCFFolder(Folder).FindFile(Copy(PakPath, I+1, MaxInt));
      Exit;
    end;
  end;
  Result:=SubElements.FindName(PakPath) as QFileObject;
end;

function QGCFFolder.GetFolder(Path: String) : QGCFFolder;
var
 I, J: Integer;
 Folder: QObject;
begin
 Result:=Self;
 while Path<>'' do
  begin
   I:=Pos('/',Path); if I=0 then I:=Length(Path)+1;
   J:=Pos('\',Path); if J=0 then J:=Length(Path)+1;
   if I>J then I:=J;
   Folder:=Self.SubElements.FindName(Copy(Path, 1, I-1) + '.gcffolder');
   if Folder=Nil then
    begin
     Folder:=QGCFFolder.Create(Copy(Path, 1, I-1), Self);
     Self.SubElements.Add(Folder);
    end;
   Result:=Folder as QGCFFolder;
   System.Delete(Path, 1, I);
  end;
end;

 {------------ QGCF ------------}

class function QGCF.TypeInfo;
begin
 Result:='.gcf';
end;

procedure QGCF.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiPak;
end;

class procedure QGCF.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5710);
 Info.FileExt:=816;
 Info.WndInfo:=[wiOwnExplorer];
end;

 {------------------------}

initialization
begin
  {tbd is the code ok to be used ?  }
  RegisterQObject(QGCF, 's');
  RegisterQObject(QGCFFolder, 'a');
end;

finalization
  if HLLoaded then
    UnloadHLLib;
end.
