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
Revision 1.15  2007/09/13 15:09:06  danielpharos
Improved the find-texture-belonging-to-material-file

Revision 1.14  2007/09/13 14:34:53  danielpharos
The name of a pakfile containing a texture can now be specified per texture

Revision 1.13  2007/08/15 16:28:09  danielpharos
HUGE update to HL2: Took out some code that's now not needed anymore.

Revision 1.12  2007/08/14 16:33:00  danielpharos
HUGE update to HL2: Loading files from Steam should work again, now using the new QuArKSAS utility!

Revision 1.11  2007/07/05 10:18:28  danielpharos
Moved a string to the dictionary.

Revision 1.10  2007/04/30 21:52:45  danielpharos
Small cleanup of code around VTFLib.

Revision 1.9  2007/04/11 16:14:52  danielpharos
Full support for VMT files: loading everything and saving everything. Note: Saving not fully correct.

Revision 1.8  2007/03/29 21:01:39  danielpharos
Changed a few comments and error messages

Revision 1.7  2007/03/27 19:22:22  danielpharos
Fixed loading VTF files from inside a gcf-file.

Revision 1.6  2007/03/25 13:51:30  danielpharos
Moved the material texture loading to the correct function.

Revision 1.5  2007/03/20 21:18:04  danielpharos
Fix for 1.4

Revision 1.4  2007/03/20 21:07:00  danielpharos
Even textures for cstrike should now load correctly. GCF file access through VMT files is (still) broken.

Revision 1.3  2007/03/20 20:38:07  danielpharos
VTF textures should now load correctly from VMT files.

Revision 1.2  2007/03/19 15:27:54  danielpharos
Added a few more keywords to find a texture for a VMT file.

Revision 1.1  2007/03/15 22:19:13  danielpharos
Re-did the entire VMT file loading! It's using the VTFLib now. Saving VMT files not supported yet.


}

unit QkVMT;

interface
uses Windows, Classes, QkWad, QkPixelSet, QkObjects, QkFileObjects, QkVTFLib;

type
  QVMTStage = class(QObject)
         private
           function DumpData: String;
         public
           class function TypeInfo: String; override;
         end;
  QVMTFile = class(QPixelSet)
         private
           DefaultImageName: array[0..7] of String;
           DefaultImageIndex: Integer;
         protected
           DefaultImageCache : QPixelSet;
         public
           procedure SaveFile(Info: TInfoEnreg1); override;
           procedure LoadFile(F: TStream; FSize: Integer); override;
           class function TypeInfo: String; override;
           class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
           function DefaultImage : QPixelSet;
           function GetSize : TPoint; override;
           procedure SetSize(const nSize: TPoint); override;
           function Description : TPixelSetDescription; override;
           function SetDescription(const PSD: TPixelSetDescription;
                                   Confirm: TSDConfirm) : Boolean; override;
         end;

{-------------------}

implementation

uses SysUtils, Setup, Quarkx, QkObjectClassList, Game, Logging, QkVTF, StrUtils,
     ExtraFunctionality, QkApplPaths;

var
  VMTLoaded: Boolean;

procedure Fatal(x:string);
begin
  Log(LOG_CRITICAL,'load vmt %s',[x]);
  Windows.MessageBox(0, pchar(X), PChar(LoadStr1(401)), MB_TASKMODAL or MB_ICONERROR or MB_OK);
  Raise Exception.Create(x);
end;

class function QVMTStage.TypeInfo: String;
begin
 TypeInfo:='.vmtstage';
end;

function QVMTStage.DumpData : String;
const
  NumberChars: string = '0123456789-';
type
  vlDataType = (vlString, vlInteger, vlSingle);
var
  I, J, K: Integer;
  Q: QObject;
  Spec: String;
  SpecName: String;
  SpecDataType: vlDataType;
  CharFound: Boolean;
begin
  for I:=0 to Specifics.Count-1 do
  begin
    Spec:=Specifics[I];
    J:=Pos('=', Spec);
    SpecName:=LeftStr(Spec,J-1);
    Spec:=RightStr(Spec,Length(Spec)-J);

    //DanielPharos: Ugly, slow and inaccurate way of determining the type...
    SpecDataType:=vlInteger;
    for J:=0 to Length(Spec) do
    begin
      CharFound:=false;
      for K:=0 to 10 do
      begin
        if NumberChars[K]=Spec[J] then
        begin
          CharFound:=true;
          break;
        end;
      end;
      if CharFound=false then
      begin
        SpecDataType:=vlString;
        break;
      end;
    end;
    if SpecDataType=vlInteger then
    begin
      K:=Pos(Spec,'.');
      if K>0 then
        SpecDataType:=vlSingle;
    end;

    case SpecDataType of
    vlString: vlMaterialAddNodeString(PChar(SpecName),PChar(Spec));
    vlInteger: vlMaterialAddNodeInteger(PChar(SpecName),StrToInt(Spec));
    vlSingle: vlMaterialAddNodeSingle(PChar(SpecName),StrToFloat(Spec));
    end;
  end;

  for I:=0 to SubElements.Count-1 do
  begin
    Q:=SubElements[I];
    if Q is QVMTStage then
    begin
      vlMaterialAddNodeGroup(PChar(Q.name));
      vlMaterialGetChildNode(PChar(Q.name));
      QVMTStage(Q).DumpData;
      vlMaterialGetParentNode;
    end;
  end;
end;

class function QVMTFile.TypeInfo: String;
begin
 TypeInfo:='.vmt';
end;

class procedure QVMTFile.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5716);
  Info.FileExt:=815;
  Info.WndInfo:=[wiWindow];
end;

function QVMTFile.DefaultImage : QPixelSet;
var
 GCFFilename: String;
 TexturePath: String;
 FullTextureFile: String;
 ImageFileName: String;
 Size: TPoint;
 V: array [1..2] of Single;
 TexExt: String;
begin
  Acces;
  Result:=nil;
  {if DefaultImageCache<>Nil then
  begin
    result:=DefaultImageCache
  end
  else
  begin}

  if ReverseLink<>nil then
  begin
    GCFFilename:=ReverseLink.Specifics.Values['PakFile'];
    TexturePath:=ConvertPath(ReverseLink.Specifics.Values['path']);
  end
  else
  begin
    GCFFilename:='';
    TexturePath:='';
  end;

  //TexExt:=SetupGameSet.Specifics.Values['TextureFormat'];
  TexExt:='.vtf';
  while ((Result=nil) and (DefaultImageIndex<8)) do
  begin
    if (DefaultImageName[DefaultImageIndex]<>'') then
    begin
      ImageFileName:=DefaultImageName[DefaultImageIndex]+TexExt;
      FullTextureFile:=IncludeTrailingPathDelimiter(TexturePath) + ImageFileName;
      Log(LOG_VERBOSE,'attempting to load '+FullTextureFile);
      try
        Result:=NeedGameFile(FullTextureFile, GCFFilename) as QPixelSet
      except
        Result:=nil;
      end;
    end;
    if Result=nil then
      DefaultImageIndex:=DefaultImageIndex+1;
  end;

  if (Result=nil) then
  begin
    if ReverseLink<>nil then
      ImageFileName:=ReverseLink.name + TexExt
    else
      ImageFileName:=self.name + TexExt;
    FullTextureFile:=IncludeTrailingPathDelimiter(TexturePath) + ImageFileName;
    Log(LOG_VERBOSE,'attempting to load '+FullTextureFile);
    try
      Result:=NeedGameFile(FullTextureFile, GCFFilename) as QPixelSet;
    except
      Result:=nil;
    end;
  end;
  //DefaultImageCache:=Result;

  {tiglari: giving shaders a size.  a presumably
  horrible place to do it, but doesn't work when
  shaders are being loaded }
  if Result<>Nil then
  begin
    Log(LOG_VERBOSE, LoadStr1(5708), [ImageFileName]);
    Size:=Result.GetSize;
    V[1]:=Size.X;
    V[2]:=Size.Y;
    SetFloatsSpec('Size',V);
  end
  else
  begin
    Log(LOG_WARNING, LoadStr1(5695), [self.name]);
    Raise EErrorFmt(5695, [self.name]);
  end;
end;

function QVMTFile.GetSize : TPoint;
var
 Image: QPixelSet;
begin
 Image:=DefaultImage;
 if Image=Nil then Raise EErrorFmt(5534, ['Size']);
 Image.Acces;
 Result:=Image.GetSize;
end;

function QVMTFile.Description : TPixelSetDescription;
var
 Image: QPixelSet;
begin
 Image:=DefaultImage;
 if Image=Nil then Raise EErrorFmt(5695, [Name]);
 Result:=Image.Description;
end;

procedure QVMTFile.SetSize;
begin
 Raise EError(5696);
end;

function QVMTFile.SetDescription;
begin
 Raise EError(5696);
end;

procedure QVMTFile.LoadFile(F: TStream; FSize: Integer);
var
  RawBuffer: String;
  VMTMaterial: Cardinal;
  Stage: QVMTStage;
  StageList: array of QObject;
  ImageType: Integer;
  GroupEndWorkaround: Boolean;
  GroupEndWorkaroundName: String;

  NodeLevel: Cardinal;
  NodeType: VMTNodeType;
  NodeName: String;
  NodeValueString: String;
  NodeValueInteger: Cardinal;
  NodeValueSingle: Single;
  I: Integer;
begin
  Log(LOG_VERBOSE,'load vmt %s',[self.name]);;
  case ReadFormat of
    1: begin  { as stand-alone file }
      if not VMTLoaded then
      begin
        if not LoadVTFLib then
          Raise EErrorFmt(5718, [GetLastError]);
        VMTLoaded:=true;
      end;

      SetLength(RawBuffer, F.Size);
      F.Seek(0, 0);
      F.ReadBuffer(Pointer(RawBuffer)^, Length(RawBuffer));

      if vlCreateMaterial(@VMTMaterial)=false then
        Fatal('Unable to load VMT file. Call to vlCreateMaterial failed.');

      if vlBindMaterial(VMTMaterial)=false then
      begin
        vlDeleteMaterial(VMTMaterial);
        Fatal('Unable to load VMT file. Call to vlBindMaterial failed.');
      end;

      if vlMaterialLoadLump(Pointer(RawBuffer), Length(RawBuffer), false)=false then
      begin
        vlDeleteMaterial(VMTMaterial);
        Fatal('Unable to load VMT file. Call to vlMaterialLoadLump failed. Please make sure the file is a valid VMT file, and not damaged or corrupt.');
      end;

      if vlMaterialGetFirstNode=false then
      begin
        vlDeleteMaterial(VMTMaterial);
        Fatal('Unable to load VMT file. Call to vlMaterialGetFirstNode failed.');
      end;
      for I:=0 to 7 do
        DefaultImageName[I]:='';
      DefaultImageIndex:=8;
      NodeLevel:=0;
      SetLength(StageList, NodeLevel+1);
      StageList[NodeLevel]:=Self;
      GroupEndWorkaround:=false;
      { DanielPharos:
        We need a workaround for the fact that VTFLib reports a GROUP with
        exactly the same name AFTER each GROUPEND (unless it's the last one
        of the file). So we will simply ignore the first GROUP after any
        GROUPEND if it has the same name as the GROUPEND.}

      repeat
        NodeName:=vlMaterialGetNodeName;
        NodeType:=vlMaterialGetNodeType;
        case NodeType of
        NODE_TYPE_GROUP:
          begin
            if (GroupEndWorkaround=false) or (NodeName<>GroupEndWorkaroundName) then
            begin
              NodeLevel:=NodeLevel+1;
              Stage:=QVMTStage.Create(NodeName, StageList[NodeLevel-1]);
              StageList[NodeLevel-1].SubElements.Add(Stage);
              SetLength(StageList, NodeLevel+1);
              StageList[NodeLevel]:=Stage;
            end;
          end;
        NODE_TYPE_GROUP_END:
          begin
            NodeLevel:=NodeLevel-1;
            SetLength(StageList, NodeLevel+1);
          end;
        NODE_TYPE_STRING:
          begin
            NodeValueString:=vlMaterialGetNodeString;
            StageList[NodeLevel].Specifics.Add(NodeName+'='+NodeValueString);

            if LowerCase(NodeName)='%tooltexture' then
              ImageType:=0
            else if LowerCase(NodeName)='$basetexture' then
              ImageType:=1
            else if LowerCase(NodeName)='$material' then
              ImageType:=2
            else if LowerCase(NodeName)='$bumpmap' then
              ImageType:=3
            else if LowerCase(NodeName)='$normalmap' then
              ImageType:=4
            else if LowerCase(NodeName)='$dudvmap' then
              ImageType:=5
            else if LowerCase(NodeName)='$envmap' then
              ImageType:=6
            else if LowerCase(NodeName)='$parallaxmap' then
              ImageType:=7
            else
              ImageType:=8;
            if ImageType<8 then
            begin
              DefaultImageName[ImageType]:=NodeValueString;
              if ImageType<DefaultImageIndex then
              begin
                DefaultImageIndex:=ImageType;
              end;
            end;
          end;
        NODE_TYPE_INTEGER:
          begin
            NodeValueInteger:=vlMaterialGetNodeInteger;
            StageList[NodeLevel].Specifics.Add(NodeName+'='+IntToStr(NodeValueInteger));
          end;
        NODE_TYPE_SINGLE:
          begin
            NodeValueSingle:=vlMaterialGetNodeSingle;
            StageList[NodeLevel].Specifics.Add(NodeName+'='+FloatToStr(NodeValueSingle));
          end;
        end;

        if NodeType=NODE_TYPE_GROUP_END then
        begin
          GroupEndWorkaround:=true;
          GroupEndWorkaroundName:=NodeName;
        end
        else
          GroupEndWorkaround:=false;
      until vlMaterialGetNextNode=false;

      vlDeleteMaterial(VMTMaterial);
    end;
    else
      inherited;
  end;
end;

procedure QVMTFile.SaveFile(Info: TInfoEnreg1);
var
  I: Integer;
  Q: QObject;
  RawBuffer: String;
  VMTMaterial, OutputSize: Cardinal;
begin
 Log(LOG_VERBOSE,'save vmt %s',[self.name]);
 with Info do case Format of
  1:
  begin  { as stand-alone file }

    if not VMTLoaded then
    begin
      if not LoadVTFLib then
        Raise EErrorFmt(5718, [GetLastError]);
      VMTLoaded:=true;
    end;

    if vlCreateMaterial(@VMTMaterial)=false then
      Fatal('Unable to save VMT file. Call to vlCreateMaterial failed.');

    if vlBindMaterial(VMTMaterial)=false then
      Fatal('Unable to save VMT file. Call to vlBindMaterial failed.');

    for I:=0 to SubElements.Count-1 do
    begin
      Q:=SubElements[I];
      if Q is QVMTStage then
      begin
        //DanielPharos: There should only one subelement: the root
        if vlMaterialCreate(PChar(Q.name))=false then
          Fatal('Unable to save VMT file. Call to vlMaterialCreate failed.');
        if vlMaterialGetFirstNode=false then
          Fatal('Unable to save VMT file. Call to vlMaterialGetFirstNode failed.');

        QVMTStage(Q).DumpData;
        break;
      end;
    end;

    SetLength(RawBuffer, 1024);     {1024 is just a number. We need a better way!}
    if vlMaterialSaveLump(Pointer(RawBuffer), Length(RawBuffer), @OutputSize)=false then
      Fatal('Unable to save VMT file. Call to vlMaterialSaveLump failed.');

    F.WriteBuffer(Pointer(RawBuffer)^,OutputSize);

    vlDeleteMaterial(VMTMaterial);
  end
 else inherited;
 end;
end;

{-------------------}

initialization
begin
  RegisterQObject(QVMTFile, 'v');
end;

finalization
  UnloadVTFLib(true);
end.
