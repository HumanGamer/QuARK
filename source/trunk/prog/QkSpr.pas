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
unit QkSpr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkForm, QkFileObjects, QSplitter, StdCtrls, ComCtrls, ExtCtrls, TB97,
  QkObjects, Game, Setup, Menus, QkImages, Sprite;

type
  THLSprHeader = packed record // Half Life Sprite
    ident           :  Longint;
    version         :  Longint;
    stype           :  Longint;
    texFormat       :  Longint;
    boundingradius  :  Single;
    width           :  Longint;
    height          :  Longint;
    numframes       :  Longint;
    beamlength      :  Single;
    synctype        :  Single;
  end;
  TQ1SprHeader = packed record  // Quake 1 Sprite
    ident           :  Longint;
    version         :  Longint;
    stype           :  Longint;
    boundingradius  :  Single;
    width           :  Longint;
    height          :  Longint;
    numframes       :  Longint;
    beamlength      :  Single;
    synctype        :  Single; //FIXME: Single? --> https://github.com/id-Software/Quake/blob/bf4ac424ce754894ac8f1dae6a3981954bc9852d/QW/client/spritegn.h
  end;
  TQ2SprHeader = packed record  // Quake 2 Sprite
    ident: Longint;
    version: Longint;
    noFrames: Longint;
  end;
  TQ2SprFrame = packed record
    x,y,w,h: longint;
    fn: array[1..64]of char;
  end;
  QSprFile = class(QFileObject)
  public
    function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
    class function TypeInfo: String; override;
    class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
    procedure ObjectState(var E: TEtatObjet); override;
    function OpenWindow(nOwner: TComponent) : TQForm1; override;
    procedure LoadFile(F: TStream; FSize: TStreamPos); override;
    procedure LoadQ1Spr(fs:TStream; PPPalette:PGameBuffer; Sprite: QSprite);
    procedure LoadHLSpr(Fs:TStream; Sprite: QSprite);
    Procedure WriteQ1Spr(F:TStream);
    Procedure WriteHLSpr(F:TStream);
    procedure SaveFile(Info: TInfoEnreg1); override;
    function Loaded_Frame(Root: QObject; const Name: String; const Size: array of Single; var P: PChar; var DeltaW: Integer; pal:TPaletteLmp; var palout:String) : QImage;
    function Loaded_FrameFile(Root: QObject; const Name: String) : QImage;
    procedure GetWidthHeight(var size:TPoint);
    function GetSprite: QSprite;
    Function CreateSpriteObject: QSprite;
  end;
  QSp2File = class(QSprFile)
  public
    class function TypeInfo: String; override;
    class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
    procedure LoadFile(F: TStream; FSize: TStreamPos); override;
    procedure SaveFile(Info: TInfoEnreg1); override;
  end;
  TQSprForm = class(TQForm1)
    Panel1: TPanel;
    ListView1: TListView;
    QSplitter1: TQSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    ComboBox2: TComboBox;
    Label2: TLabel;
    ComboBox3: TComboBox;
    Panel3: TPanel;
    ffw: TToolbarButton97;
    play: TToolbarButton97;
    back: TToolbarButton97;
    rew: TToolbarButton97;
    Bevel1: TBevel;
    Label3: TLabel;
    procedure QSplitter1Resized(Sender: TObject; nPosition: Integer);
    procedure FormCreate(Sender: TObject);
    procedure playClick(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
  private
    Index: Longint;
    procedure UpdateListView;
    { Private declarations }
  public
    ImageDisplayer: TImageDisplayer;
    function AssignObject(const Q: QFileObject; State: TFileObjectWndState) : Boolean; override;
    procedure wmInternalMessage(var Msg: TMessage); override;
    { Public declarations }
  end;

implementation

uses CommCtrl, Math, Quarkx, QkExceptions, QkPcx, QkTextures, QkObjectClassList;

{$R *.DFM}

 {------------------------}

Procedure MySetIntSpec(s:QSprFile; ident:String; value:Integer);
begin
  s.Specifics.Values[ident]:=inttostr(value);
end;

Function MyIntSpec(s:QSprFile; const ident:String):Integer;
begin
  if s.Specifics.IndexOfName(ident)=-1 then
    result:=0
  else
    try
      result:=strtoint(s.Specifics.Values[ident]);
    except
      on EConvertError do result:=0;
    end;
end;

Function MyStrSpec(s:QSprFile; const ident:String):String;
begin
  if s.Specifics.IndexOfName(ident)=-1 then
    result:=''
  else
    result:=s.Specifics.Values[ident];
end;

Function MyFloatSpec(s:QSprFile; const ident:String):Single;
begin
  if s.Specifics.IndexOfName(ident)=-1 then
    result:=0.0
  else
    try
      result:=strtofloat(s.Specifics.Values[ident]);
    except
      on EConvertError do result:=0.0;
    end;
end;

 {------------------------}
 
function QSprFile.IsExplorerItem(Q: QObject) : TIsExplorerItem;
begin
// if (Q is QSprite) then
//   Result:=ieResult[True]
// else
   Result:=[];
end;

procedure QSprFile.LoadFile(F: TStream; FSize: TStreamPos);
var
  ID_SPRHEADER,head,ver: Longint;
  org: TStreamPos;
  pgb: PGameBuffer;
  spr: QSprite;
begin
  case ReadFormat of
    rf_Default: begin  { as stand-alone file }
      ID_SPRHEADER:=(ord('P') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
      org:=f.Position;
      f.ReadBuffer(head,4);
      if (head<>ID_SPRHEADER) then
        raise EErrorFmt(5797, [head,ID_SPRHEADER]);
      f.ReadBuffer(ver,4);
      f.seek(org,soBeginning);
      spr:=getsprite;
      if (ver=1) then begin
          pgb:=GameBuffer(mjQuake);
          f.seek(org,soBeginning); // something happens to f after gamebuffer is called, so i reset the position to org.
          LoadQ1Spr(f, pgb, spr);
        end
      else if (ver=2)  then
        LoadHLSpr(f, spr)
      else
        raise EErrorFmt(5798, [ver]);
      end;
    else inherited;
  end;
end;

procedure QSprFile.LoadQ1Spr(fs:TStream; PPPalette:PGameBuffer; Sprite: QSprite);
var
  dst:TQ1SprHeader;
  group,ID_SPRHeader,i,j,k,nopics{,noframes}:longint;
  pos: TStreamPos;
  xoffset,yoffset,width,height:Longint;
  aPalette: TPaletteLmp;
  p: PChar;
  DeltaW:Integer;
  pout:String;
  times: array[1..1024] of Single; //FIXME: Hardcoded limit...? THERE IS NO LIMIT IN Q1!!! REWRITE!!! Make an ARRAY!!! SetLength!!!
begin
  aPalette:=PPPalette^.PaletteLmp;
  fs.ReadBuffer(dst,sizeof(dst));
  ID_SPRHeader:=(ord('P') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
  if dst.ident<>ID_SPRHEADER then
    raise EErrorFmt(5799, [dst.ident,ID_SPRHEADER]);
  if dst.version<>1 then
    raise EErrorFmt(5800, [dst.version,2]);
  ObjectGameCode:=mjQuake;
  Self.Specifics.Add(format('SPR_STYPE=%d',[dst.sType]));
  Self.Specifics.Add(format('SPR_TXTYPE=%d',[-1]));
  Self.Specifics.Add(format('SPR_RADIUS=%f',[dst.boundingradius]));
  Self.Specifics.Add(format('SPR_WIDTH=%d',[dst.width]));
  Self.Specifics.Add(format('SPR_HEIGHT=%d',[dst.height]));
  //FIXME: If dst.numframes < 1 THEN ERROR! Invalid number of frames!
  for i:=1 to dst.numframes do begin
    fs.ReadBuffer(group,4);
    if group=0 then begin
      fs.ReadBuffer(xoffset,4);
      fs.ReadBuffer(yoffset,4);
      fs.ReadBuffer(width,4);
      fs.ReadBuffer(height,4);
      J:=Fs.Position;
      Loaded_Frame(Sprite, format('Frame %d',[i]), [width,height], p, DeltaW, apalette,pout);
      Fs.Position:=J;
      for J:=1 to height do begin
        Fs.ReadBuffer(P^, width);
        Inc(P, DeltaW);
      end;
    end else begin
      fs.readbuffer(nopics,4);
      for j:=1 to nopics do
        fs.readbuffer(times[j],4);
      for j:=1 to nopics do begin
        fs.ReadBuffer(xoffset,4);
        fs.ReadBuffer(yoffset,4);
        fs.ReadBuffer(width,4);
        fs.ReadBuffer(height,4);
        Pos:=Fs.Position;
        Loaded_Frame(Sprite, format('Frame %d',[i]), [width,height], p, DeltaW, apalette,pout);
        Fs.Position:=Pos;
        for k:=1 to height do begin
          Fs.ReadBuffer(P^, width);
          Inc(P, DeltaW);
        end;
      end;
    end;
  end;
end;

procedure QSprFile.LoadHLSpr(Fs:TStream; Sprite: QSprite);
var
  dst:THLSprHeader;
  ID_SPRHEADER, i, w, h, lint, lint2, J:Longint;
  DeltaW:Integer;
  fshort:SmallInt;
  aPalette: TPaletteLmp;
  P:PChar;
  pout:String;
begin
  ID_SPRHEADER:=(ord('P') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
  fs.ReadBuffer(dst,sizeof(dst));
  if dst.ident<>ID_SPRHEADER then
    raise EErrorFmt(5773, [dst.ident,ID_SPRHEADER]);
  if dst.version<>2 then
    raise EErrorFmt(5774, [dst.version,2]);
  ObjectGameCode:=mjHalfLife;
  Self.Specifics.Add(format('SPR_STYPE=%d',[dst.sType]));
  Self.Specifics.Add(format('SPR_TXTYPE=%d',[dst.texformat]));
  Self.Specifics.Add(format('SPR_RADIUS=%f',[dst.boundingradius]));
  Self.Specifics.Add(format('SPR_WIDTH=%d',[dst.width]));
  Self.Specifics.Add(format('SPR_HEIGHT=%d',[dst.height]));
  Self.Specifics.Add(format('SPR_NOFRAMES=%d',[dst.numframes]));

  fs.ReadBuffer(FShort,2);
  for i:=0 to FShort-1 do begin
    fs.ReadBuffer(lint2,1);
    aPalette[i,0]:=lint2;
    fs.ReadBuffer(lint2,1);
    aPalette[i,1]:=lint2;
    fs.ReadBuffer(lint2,1);
    aPalette[i,2]:=lint2;
  end;
  for i:=1 to dst.numframes do begin
    fs.ReadBuffer(lint,4);
    fs.ReadBuffer(lint,4);
    fs.ReadBuffer(lint,4);
    fs.ReadBuffer(W,4);
    fs.ReadBuffer(H,4);
    J:=Fs.Position;
    Loaded_Frame(Sprite, format('Frame %d',[i]), [w,h], p, DeltaW, apalette,pout);
    Fs.Position:=J;
    for J:=1 to h do begin
      Fs.ReadBuffer(P^, w);
      Inc(P, DeltaW);
    end;
  end;
end;

Procedure QSprFile.WriteQ1Spr(F:TStream);
var
  ID_SPRHEADER,Ver,cnt,typ,i,j,delta:Longint;
  rad:Single;
  w,h,z:Longint;
  P:PByte;
  SkinObj : QImage;
  Spr: QSprite;
  pt:TPoint;
begin
  z:= 0;
  ID_SPRHeader:=(ord('P') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
  f.WriteBuffer(ID_SPRHEADER,4);
  ver:=1;
  f.WriteBuffer(ver,4);
  typ:=myIntSpec(self,'SPR_STYPE');
  f.Writebuffer(typ,4);

  GetWidthHeight(pt);
  w:=pt.x;
  h:=pt.y;
  rad:=Sqrt(Sqr(w/2)+Sqr(h/2));
  f.Writebuffer(rad,4);
  f.WriteBuffer(w,4);
  f.WriteBuffer(h,4);
  cnt:=SubElements.count;
  f.Writebuffer(cnt,4);
  f.WriteBuffer(z,4);
  f.WriteBuffer(z,4);
  Spr:= GetSprite;
  if (Spr = nil) then
    raise EError(5502);
  for i:=1 to cnt do begin
    SkinObj:=QImage(spr.SubElements[i-1]);
    SkinObj.NotTrueColor;
    pt:=SkinObj.GetSize;
    f.WriteBuffer(z,4);
    f.WriteBuffer(z,4);
    f.WriteBuffer(z,4);
    f.WriteBuffer(pt.x,4);
    f.WriteBuffer(pt.y,4);
    P:=SkinObj.GetImagePtr1;
    Delta:=(w + 3) and not 3;
    Inc(P, Delta*h);   { FIXME: check palette }
    for J:=1 to h do begin
      Dec(P, Delta);
      F.WriteBuffer(P^, w);
    end;
  end;
end;

const
  SpriteName: String = 'Sprite';

Function QSprFile.CreateSpriteObject: QSprite;
begin
  result:=QSprite.Create(SpriteName,Self);
  Subelements.add(Result);
end;

Function QSprFile.getSprite: QSprite;
var
  Obj : QObject;
begin
  Obj:=FindSubObject(SpriteName, QSprite, nil);
  if Obj=nil then
    result:=CreateSpriteObject // if not found then create it.
//  else if not(Obj is QSprite) then
//    result:=CreateSpriteObject // ???
  else
    result:=QSprite(Obj);
end;

procedure QSprFile.GetWidthHeight(var size:TPoint);
var
 SizeTemp:TPoint;
 WTemp,HTemp,i:Longint;
 Spr: QSprite;
begin
  WTemp:=0;HTemp:=0;
  Spr:= GetSprite;
  if (Spr = nil) then
    raise EError(5502);
  for i:=0 to spr.SubElements.Count-1 do begin
    SizeTemp:=QPcx(spr.SubElements.Items1[i]).GetSize;
    WTemp:=Max(SizeTemp.X,WTemp);
    HTemp:=Max(SizeTemp.X,HTemp);
  end;
  Size.X:=WTemp;
  Size.Y:=HTemp;
end;

Procedure QSprFile.WriteHLSpr(F:TStream);
var
  ID_SPRHEADER,Ver,cnt,typ,i,j,delta:Longint;
  rad:Single;
  w,h,z:Longint;
  P:PByte;
  SkinObj : QImage;
  bt:Byte;
  pt:TPoint;
  Pal:TPaletteLmp;
  Spr: QSprite;
begin
  z:= 0;
  ID_SPRHeader:=(ord('P') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
  f.WriteBuffer(ID_SPRHEADER,4);
  ver:=2;
  f.WriteBuffer(ver,4);
  typ:=myIntSpec(self,'SPR_STYPE');
  f.Writebuffer(typ,4);
  typ:=myIntSpec(self,'SPR_TXTYPE');
  f.Writebuffer(typ,4);

  GetWidthHeight(pt);
  w:=pt.x;
  h:=pt.y;

  rad:=Sqrt(Sqr(w/2)+Sqr(h/2));
  f.Writebuffer(rad,4);
  f.WriteBuffer(w,4);
  f.WriteBuffer(h,4);
  cnt:=SubElements.count;
  f.Writebuffer(cnt,4);
  f.WriteBuffer(z,4);
  f.WriteBuffer(z,4);
  typ:=256;
  f.WriteBuffer(typ,2);
  Spr := GetSprite;
  if (Spr = nil) then
    raise EError(5502);
  SkinObj:=QImage(Spr.SubElements[0]); // use palette of first image for sprite.
  SkinObj.NotTrueColor;
  skinobj.GetPalette1(pal);
  for i:=0 to 255 do begin
    for j:=0 to 2 do begin
      bt:=ord(pal[i,j]);
      f.WriteBuffer(bt,1);
    end;
  end;

  for i:=1 to cnt do begin
    SkinObj:=QImage(Spr.SubElements[i-1]);
    SkinObj.NotTrueColor;
    pt:=SkinObj.GetSize;
    f.WriteBuffer(z,4);
    f.WriteBuffer(z,4);
    f.WriteBuffer(z,4);
    f.WriteBuffer(pt.x,4);
    f.WriteBuffer(pt.y,4);
    P:=SkinObj.GetImagePtr1;
    Delta:=(w + 3) and not 3;
    Inc(P, Delta*h);   { FIXME: check palette }
    for J:=1 to h do begin
      Dec(P, Delta);
      F.WriteBuffer(P^, w);
    end;
  end;
end;

procedure QSp2File.LoadFile(F: TStream; FSize: TStreamPos);
const
  ID_SP2Header = (ord('2') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
var
  dst:TQ2SprHeader;
  i:Longint;
  frame: TQ2SprFrame;
  str:String;
begin
  f.ReadBuffer(Dst,sizeof(dst));
  if dst.ident<>ID_SP2HEADER then
    raise EErrorFmt(5801, [dst.ident,ID_SP2HEADER]);
  if dst.version<>2 then
    raise EErrorFmt(5802, [dst.version,2]);
  ObjectGameCode:=mjQuake2;
  Self.Specifics.Add(format('SPR_STYPE=%d',[-1]));
  Self.Specifics.Add(format('SPR_TXTYPE=%d',[-1]));
  Self.Specifics.Add(format('SPR_RADIUS=%s',['N / A']));
  Self.Specifics.Add(format('SPR_WIDTH=%s',['N / A']));
  Self.Specifics.Add(format('SPR_HEIGHT=%s',['N / A']));
  Self.Specifics.Add(format('SPR_NOFRAMES=%d',[Dst.noframes]));
  fillchar(Frame,sizeof(Frame),#0);
  For i:=1 to dst.Noframes do begin
    f.Readbuffer(frame,sizeof(frame));
    str:=frame.fn;
    setlength(str,pos(#0,frame.fn));
    Self.Specifics.Add(Format('SPR_FRAME%d_CAPTION=%d',[i,i]));
    Self.Specifics.Add(Format('SPR_FRAME%d_FTYPE=%s',[i,str]));
    Self.Specifics.Add(Format('SPR_FRAME%d_XORG=%d',[i,frame.x]));
    Self.Specifics.Add(Format('SPR_FRAME%d_YORG=%d',[i,frame.y]));
    Self.Specifics.Add(Format('SPR_FRAME%d_WIDTH=%d',[i,frame.w]));
    Self.Specifics.Add(Format('SPR_FRAME%d_HEIGHT=%d',[i,frame.h]));
    Self.Specifics.Add(Format('SPR_FRAME%d_IDATASIZE=%s',[i,'N / A']));
//    Loaded_FrameFile(self, fStr); //FIXME: Doesn't Work. Wonder Why??
  end;
end;

Procedure QSp2File.SaveFile(Info: TInfoEnreg1);
var
  ID_SP2HEADER,Ver,cnt,i:Longint;
  x,y,w,h:Longint;
  data:String;
begin
  with Info do begin
    case Format of
      rf_Default: begin  { as stand-alone file }
        ID_SP2Header:=(ord('2') shl 24)+(ord('S')shl 16)+(ord('D') shl 8)+ord('I');
        f.WriteBuffer(ID_SP2HEADER,4);
        ver:=2;
        f.WriteBuffer(ver,4);
        cnt:=IntSpec['SPR_NOFRAMES'];
        f.Writebuffer(cnt,4);
        for i:=1 to cnt do begin
          x:=myIntSpec(self,Sysutils.format('SPR_FRAME%d_XORG',[i]));
          y:=myIntSpec(self,Sysutils.format('SPR_FRAME%d_YORG',[i]));
          w:=myIntSpec(self,Sysutils.format('SPR_FRAME%d_WIDTH',[i]));
          h:=myIntSpec(self,Sysutils.format('SPR_FRAME%d_HEIGHT',[i]));
          Data:=myStrSpec(self,Sysutils.format('SPR_FRAME%d_FTYPE',[i]));
          f.WriteBuffer(x,4);
          f.WriteBuffer(y,4);
          f.WriteBuffer(w,4);
          f.WriteBuffer(h,4);
          f.WriteBuffer(PChar(Data)^,64);
        end;
      end;
      else
        inherited;
    end;
  end;
end;

procedure QSprFile.SaveFile(Info: TInfoEnreg1);
var
  fg:Char;
begin
  with Info do
    case Format of
      rf_Default: begin  { as stand-alone file }
        fg:=ObjectGameCode;
        if fg=mjQuake then
          WriteQ1Spr(Info.F)
        else if fg=mjHalfLife then
          WriteHLSpr(Info.F)
        else
          raise EErrorFmt(5796, [fg]);
       end;
    else
      inherited;
  end;
end;

function QSprFile.OpenWindow(nOwner: TComponent) : TQForm1;
begin
  Result:=TQSprForm.Create(nOwner);
end;

class function QSprFile.TypeInfo;
begin
  Result:='.spr';
end;

procedure QSprFile.ObjectState(var E: TEtatObjet);
begin
  inherited;
  E.IndexImage:=iiSpriteFile;
end;

class procedure QSprFile.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5171);
  Info.FileExt:=799;
  Info.WndInfo:=[];
end;

function QSprFile.Loaded_Frame(Root: QObject; const Name: String; const Size: array of Single; var P: PChar; var DeltaW: Integer; pal:TPaletteLmp; var palout:String) : QImage;
const
  Spec1 = 'Pal=';
  Spec2 = 'Image1=';
var
  S: String;
begin
  Result:=QPcx.Create(Name, Root);
  Root.SubElements.Add(Result);
  Result.SetFloatsSpec('Size', Size);
  S:=Spec1;
  SetLength(S, Length(Spec1) + SizeOf(TPaletteLmp));
  if ObjectGameCode=mjQuake then
    Move(GameBuffer(ObjectGameCode)^.PaletteLmp, S[Length(Spec1)+1], SizeOf(TPaletteLmp))
  else if ObjectGameCode=mjHalfLife then
    Move(pal,S[Length(Spec1)+1],sizeof(TPaletteLmp));
  palout:=s;
  Result.Specifics.Add(S);
  S:=Spec2;
  DeltaW:=-((Round(Size[0])+3) and not 3);
  SetLength(S, Length(Spec2) - DeltaW*Round(Size[1]));
  P:=PChar(S)+Length(S)+DeltaW;
  Result.Specifics.Add(S);
end;

function QSprFile.Loaded_FrameFile(Root: QObject; const Name: String) : QImage;
var
  Path: String;
  J: Integer;
  nImage: QFileObject;
begin
  GameBuffer(ObjectGameCode);
  Path:=Name;
  repeat
    nImage:=LoadSibling(Path);
    if nImage<>Nil then
      try
        if nImage is QTextureFile then begin
          Result:=QPcx.Create('', Root);
          try
            Result.ConversionFrom(QTextureFile(nImage));
          except
            Result.Free;
            Raise;
          end;
        end
      else begin
        Result:=nImage as QImage;
        Result:=Result.Clone(Root, False) as QImage;
      end;
      Root.SubElements.Add(Result);
      Result.Name:=Copy(Name, 1, Length(Name)-Length(nImage.TypeInfo));
     {Result.Flags:=Result.Flags or ofFileLink;}
     Exit;
   finally
     nImage.AddRef(-1);
   end;
   J:=Pos('/',Path);
   if J=0 then Break;
   System.Delete(Path, 1, J);
  until False;
  GlobalWarning(FmtLoadStr1(5575, [Name, LoadName]));
  Result:=Nil;
end;

class function QSp2File.TypeInfo;
begin
  Result:='.sp2';
end;

class procedure QSp2File.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5171);
  Info.FileExt:=800;
  Info.WndInfo:=[wiWindow,wiSameExplorer];
end;

function TQSprForm.AssignObject(const Q: QFileObject; State: TFileObjectWndState) : Boolean;
begin
  Result:=((Q is QSprFile) or (Q is QSp2File))and inherited AssignObject(Q, State);
end;

procedure TQSprForm.QSplitter1Resized(Sender: TObject; nPosition: Integer);
begin
  Panel2.Height:=nPosition;
end;

procedure TQSprForm.wmInternalMessage(var Msg: TMessage);
var
  s:QSprFile;
  fg:char;
begin
  case Msg.wParam of
    wp_AfficherObjet:
      if FileObject<>Nil then begin
        ListView1.Items.Clear;
        s:=QSprFile(FileObject);
        if FileObject is QSp2File then begin
          ListView1.Visible:=true;
          panel3.visible:=false;
        end else begin
          ListView1.Visible:=false;
          panel3.visible:=true;
          rew.click;
          ImageDisplayer.AutoSize;
        end;
        fg:=s.ObjectGameCode;
        if fg=mjQuake then begin
          Combobox2.Enabled:=true;
          Combobox3.Enabled:=false;
          Combobox2.ItemIndex:=myintspec(s,'SPR_STYPE');
          Combobox3.ItemIndex:=-1;
        end else if FG=mjQuake2 then begin
          Combobox2.Enabled:=false;
          Combobox3.Enabled:=false;
          Combobox2.ItemIndex:=-1;
          Combobox3.ItemIndex:=-1;
        end else if FG=mjHalfLife then begin
          Combobox2.Enabled:=true;
          Combobox3.Enabled:=true;
          Combobox2.ItemIndex:=myintspec(s,'SPR_STYPE');
          Combobox3.ItemIndex:=myintspec(s,'SPR_TXTYPE');
        end;
        UpdateListView;
      end;
    end;
  inherited;
end;

procedure TQSprForm.UpdateListView;
var
  li:TListItem;
  cnt,i:Integer;
  s:QSprFile;
begin
  s:=QSprFile(FileObject);
  listview1.items.clear;
  cnt:=myintspec(s,'SPR_NOFRAMES');
  for i:=1 to cnt do begin
    li:=ListView1.Items.add;
    li.Caption:=s.Specifics.Values[format('SPR_FRAME%d_CAPTION',[i])];
    li.SubItems.add(s.Specifics.Values[format('SPR_FRAME%d_FTYPE',[i])]);
    li.SubItems.add(s.Specifics.Values[format('SPR_FRAME%d_XORG',[i])]);
    li.SubItems.add(s.Specifics.Values[format('SPR_FRAME%d_YORG',[i])]);
    li.SubItems.add(s.Specifics.Values[format('SPR_FRAME%d_WIDTH',[i])]);
    li.SubItems.add(s.Specifics.Values[format('SPR_FRAME%d_HEIGHT',[i])]);
    li.SubItems.add(s.Specifics.Values[format('SPR_FRAME%d_IDATASIZE',[i])]);
  end;
end;

Function SetRowSelect(h: THandle):Boolean;
var
  lvflags: DWord;
begin
  lvflags:=SendMessage(h, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);              // Send Message to Get ListViews Flags
  lvflags:=lvflags or LVS_EX_FULLROWSELECT;                                 // Add in Row Select Flag
  result:=bool(SendMessage(h, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, lvflags));   // Send Message to Set ListViews Flags
end;

procedure TQSprForm.FormCreate(Sender: TObject);
begin
  inherited;
  ImageDisplayer:=TImageDisplayer.Create(Self);
  ImageDisplayer.Parent:=Panel1;
  ImageDisplayer.Align:=alClient;
  SetRowSelect(ListView1.Handle);
end;

procedure TQSprForm.playClick(Sender: TObject);
var
  s:QSprite;
  ps:QPcx;
begin
  s:=QSprFile(FileObject).getSprite;
  case TComponent(Sender).Tag of
    -100: index:=0;
     100: index:=s.SubElements.count-1;
       1: if index+1>s.SubElements.count-1 then index:=s.SubElements.count-1 else index:=index+1;
      -1: if index-1<0 then index:=0 else index:=index-1;
    else
      raise EErrorFmt(5803, [TComponent(Sender).Tag]);
  end;
  if index>s.SubElements.count-1 then
    index:=s.SubElements.count-1;
  if index<>-1 then
    if s.SubElements[index]<>nil then begin
      ps:=QPcx(s.SubElements[index]);
      ImageDisplayer.Source:=ps;
      ImageDisplayer.AutoSize;
    end;
  label3.caption:=Format('Frame %d / %d',[(index+1),s.SubElements.Count]);
end;

procedure TQSprForm.ComboBox2Change(Sender: TObject);
begin
  MySetIntSpec(QSprFile(FileObject), 'SPR_STYPE', Combobox2.ItemIndex);
end;

procedure TQSprForm.ComboBox3Change(Sender: TObject);
begin
  MySetIntSpec(QSprFile(FileObject), 'SPR_TXTYPE', Combobox3.ItemIndex);
end;

initialization
  RegisterQObject(QSprFile, 'p');
  RegisterQObject(QSp2File, 'p');
end.

