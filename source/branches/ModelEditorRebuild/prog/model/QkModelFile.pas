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
Revision 1.9  2005/09/28 10:49:02  peter-b
Revert removal of Log and Header keywords

Revision 1.7  2002/03/07 19:17:48  decker_dk
Removed QImages, as it was just another name for QImage

Revision 1.6  2002/02/26 23:16:10  tiglari
support for forward slash in path to skin of md2, by Andy Vincent,
committed by tiglari

Revision 1.5  2001/03/20 21:37:04  decker_dk
Updated copyright-header

Revision 1.4  2001/02/28 19:03:25  aiv
Fixed ref count prob.

Revision 1.3  2001/02/14 20:46:28  aiv
Fixed Loading of Shaders used by md3 files.

Revision 1.2  2000/10/11 19:01:08  aiv
Small updates
}

unit QkModelFile;

interface

uses
  windows, sysutils, QkObjects, QkFileObjects, QkForm, QkImages, Python, Game,
  QkModel, QkModelRoot, qkcomponent, qkframe, qkskin, qktextures, qkmiscgroup,
  graphics, QkModelBone, qkpcx;

type
  QModelFile = class(QModel)
  private
    function CreateModelRoot: QModelRoot;
  protected
    function ModelRoot : QModelRoot;
    function Saving_Root : QModelRoot;
    function Loaded_Skin(Component: QComponent; const Name: String; const Size: array of Single; var P: PChar; var DeltaW: Integer) : QSkin;
    function Loaded_Frame(Component: QComponent; const Name: String) : QFrame;
    function Loaded_SkinFile(Component: QComponent; const Name: String; warnifnotfound: Boolean) : QSkin;
    function Loaded_Component(Root: QModelRoot; cname: string): QComponent;
    function Loaded_Bone(Component: QComponent; const Name: String): QModelBone;
    function CantFindTexture(Component: QComponent; name: string; SZ: TPoint): QImage;
  end;

implementation

uses quarkx, qkskindrawobject;

function QModelFile.Loaded_Component(Root: QModelRoot; cname: string): QComponent;
var
  L: TQList;
begin
  L:=TQList.Create;
  try
    Root.FindAllSubObjects('', QComponent, Nil, L);
    if cname='' then
      cname:=format('Component %d',[L.Count+1]);
    Result:=QComponent.Create(cname, Root);
    Result.IntSpec['show']:=1;
    Root.SubElements.Add(Result);
  finally
    L.Free;
  end;
end;

function QModelFile.Loaded_Skin(Component: QComponent; const Name: String; const Size: array of Single; var P: PChar; var DeltaW: Integer) : QSkin;
const
  Spec1 = 'Pal=';
  Spec2 = 'Image1=';
var
  S: String;
  Skins: QSkinGroup;
begin
  if component=nil then
    Skins:=nil
  else
    Skins:=Component.SkinGroup;
  Result:=QSkin.Create(Name, Skins);
  if component<>nil then
    Skins.SubElements.Add(Result);
  Result.SetFloatsSpec('Size', Size);
  S:=Spec1;
  SetLength(S, Length(Spec1) + SizeOf(TPaletteLmp));
  Move(GameBuffer(ObjectGameCode)^.PaletteLmp, S[Length(Spec1)+1], SizeOf(TPaletteLmp));
  Result.SpecificsAdd(S);
  S:=Spec2;
  DeltaW:=-((Round(Size[0])+3) and not 3);
  SetLength(S, Length(Spec2) - DeltaW*Round(Size[1]));
  P:=PChar(S)+Length(S)+DeltaW;
  Result.Specifics.Add(S);
end;

function QModelFile.Loaded_Frame(Component: QComponent; const Name: String) : QFrame;
var
  Frames: QFrameGroup;
begin
  Frames:=Component.FrameGroup;
  Result:=QFrame.Create(Name, Frames);
  Result.ParentComponent:=Component;
  Frames.SubElements.Add(Result);
end;

function QModelFile.Loaded_Bone(Component: QComponent; const Name: String): QModelBone;
var
  Bones: QBoneGroup;
begin
  Bones:=Component.BoneGroup;
  Result:=QModelBone.Create(Name, Bones);
  Result.ParentComponent:=Component;
  Bones.SubElements.Add(Result);
end;

function QModelFile.Loaded_SkinFile(Component: QComponent; const Name: String; warnifnotfound: Boolean) : QSkin;
var
  Path: String;
  J: Integer;
  nImage: QObject;
  Skins: QSkinGroup;
begin
  Skins:=Component.SkinGroup;
  Path:=Name;
  repeat
    nImage:=LoadSibling(Path);
    if nImage<>Nil then
    begin
      try
        if nImage is QTextureFile then
        begin
          Result:=QSkin.Create('', Skins);
          try
            Result.ConversionFrom(QTextureFile(nImage));
          except
            Result.Free;
            Raise;
          end;
        end
        else
        begin
          Result:=QSkin.Create('', Skins);
          Result.ConversionFrom(QPcx(nImage));
        end;
        Skins.SubElements.Add(Result);
        Result.Name:=Copy(Name, 1, Length(Name)-Length(nImage.TypeInfo));
        {Result.Flags:=Result.Flags or ofFileLink;}
        Exit;
      finally
        nImage.AddRef(-1);
      end;
    end;
    J:=Pos('/',Path);
    if J=0 then
    begin
      J:=Pos('\',Path);
      if J = 0 then
        Break;
    end;
    System.Delete(Path, 1, J);
  until False;
  if warnifnotfound then
    GlobalWarning(FmtLoadStr1(5575, [Name, LoadName]));
  Result:=Nil;
end;

function QModelFile.ModelRoot : QModelRoot;
var
  i: Integer;
  x: QObject;
begin
  result:=nil;
  for i:=0 to SubElements.Count-1 do begin
    x:=SubElements.Items1[i];
    if x is QModelRoot then begin
      result:=QModelRoot(x);
      exit;
    end;
  end;
  if result=nil then
    Result:=CreateModelRoot;
end;

function QModelFile.CreateModelRoot : QModelRoot;
begin
  Specifics.Values['FileName']:=ExtractFileName(LoadName);
  Result:=QModelRoot.Create(LoadStr1(2371), Self);
  Result.CreateMiscGroup;
  SubElements.Add(Result);
  Specifics.Values['Root']:=Result.Name+Result.TypeInfo;
end;

function QModelFile.Saving_Root;
begin
  LoadAll;
  Result:=GetRoot;
end;

function xoxox: TBitmap;
begin
  result:=TBitmap.Create;
  result.width:=10;
  result.height:=10;
  result.canvas.brush.color:=clWhite;
  result.canvas.FloodFill(result.Width div 2,result.Height div 2, clBlack, fsBorder);
  result.canvas.brush.color:=clBlack;
  result.canvas.pen.color:=clBlack;
  result.Canvas.Rectangle(0,0, 4,4);
  result.Canvas.Rectangle(5,5, 9,9);
end;

// Create a QImage object of size 'SZ' containing black and white squares,
// if a texture can't be found...
function QModelFile.CantFindTexture(Component: QComponent; name: string; SZ: TPoint): QImage;
var
  bmp: TBitmap;
  Skins: QSkinGroup;
begin
  Skins:=Component.SkinGroup;
  Result:=QSkin.Create(name, skins);
  bmp:=TBitmap.Create;
  if SZ.X<>0 then bmp.Width:=SZ.X else bmp.Width:=50;
  if SZ.Y<>0 then bmp.Height:=SZ.Y else bmp.Height:=50;
  bmp.canvas.brush.color:=clWhite;
  bmp.canvas.FloodFill(bmp.Width div 2,bmp.Height div 2, clBlack, fsBorder);
  bmp.Canvas.brush.color:=clBlack;
  bmp.canvas.brush.bitmap:=xoxox;
  bmp.canvas.FloodFill(bmp.Width div 2,bmp.Height div 2, clBlack, fsBorder);
  result.PasteBitmap(GameBuffer(ObjectGameCode), bmp);
  Skins.SubElements.Add(Result);
  bmp.free;
end;

end.
