(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor
Copyright (C) 1996-99 Armin Rigo

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

Contact the author Armin Rigo by e-mail: arigo@planetquake.com
or by mail: Armin Rigo, La Cure, 1854 Leysin, Switzerland.
See also http://www.planetquake.com/quark
**************************************************************************)
{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.10  2000/07/18 19:38:01  decker_dk
Englishification - Big One This Time...

Revision 1.9  2000/07/16 16:34:51  decker_dk
Englishification

Revision 1.8  2000/07/09 13:20:44  decker_dk
Englishification and a little layout

Revision 1.7  2000/06/09 00:31:06  tiglari
Commented out unneeded imglist uses.

Revision 1.6  2000/05/21 13:11:50  decker_dk
Find new shaders and misc.

}

unit QkWad;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkFileObjects, TB97, QkObjects, StdCtrls, ExtCtrls, ComCtrls, CommCtrl,
  QkListView, QkTextures, Game, QkForm, QkPixelSet, ImgList{, ImgList};

type
 QWad = class(QLvFileObject)
        protected
          function OpenWindow(nOwner: TComponent) : TQForm1; override;
          procedure SaveFile(Info: TInfoEnreg1); override;
          procedure LoadFile(F: TStream; FSize: Integer); override;
        public
          class function TypeInfo: String; override;
          function TestConversionType(I: Integer) : QFileObjectClass; override;
          function ConversionFrom(Source: QFileObject) : Boolean; override;
          procedure ObjectState(var E: TEtatObjet); override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
          function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
        end;
 QTextureList = class(QWad)
                protected
                 {function OpenWindow(nOwner: TComponent) : TQForm1; override;}
                  procedure SaveFile(Info: TInfoEnreg1); override;
                  procedure LoadFile(F: TStream; FSize: Integer); override;
                public
                  class function TypeInfo: String; override;
                  class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
                  function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
                end;

type
  TFQWad = class(TQForm2)
    ImageList1: TImageList;
    TimerAnimation: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerAnimationTimer(Sender: TObject);
  private
    Tex: TBitmap;
    ImageTextures: TQList;
   {GameInfo: PGameBuffer;
    procedure SetInfo(nInfo: PGameBuffer);
    procedure wmInternalMessage(var Msg: TMessage); message wm_InternalMessage;}
    function PopulateListView(Counter: Integer) : Integer; override;
    function AnimationNextStep(Q: QPixelSet; Seq: Integer) : QPixelSet;
  protected
    function AssignObject(Q: QFileObject; State: TFileObjectWndState) : Boolean; override;
    function GetConfigStr : String; override;
    function EnumObjs(Item: TListItem; var Q: QObject) : Boolean; override;
  public
  end;

 {------------------------}

implementation

uses QkUnknown, Travail, Qk1, Setup, Quarkx, QkHL;

{$R *.DFM}

const
 SignatureWad2 = $32444157;   { 'WAD2' }

type
 TWadHeader = record
               Signature: LongInt;   { 'WAD2' }
               NoOfFileEntries, PosRep: LongInt;
              end;
 PWadFileRec = ^TWadFileRec;
 TWadFileRec = record
               Position, Taille, Idem: LongInt;
               InfoType, Compression: Char;
               Dummy: Word;
               Nom: array[0..15] of Byte;
              end;

{var
 ScreenColors: Integer;}

 {------------------------}

class function QWad.TypeInfo;
begin
 Result:='.wad';
end;

function QWad.OpenWindow(nOwner: TComponent) : TQForm1;
begin
 Result:=TFQWad.Create(nOwner);
end;

procedure QWad.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiWad;
 E.MarsColor:=$00004070;
end;

class procedure QWad.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.NomClasseEnClair:=LoadStr1(5129);
{Info.FileExtCount:=1;}
 Info.FileExt{[0]}:=776;
{Info.DefaultExt[0]:='wad';}
 Info.WndInfo:=[wiOwnExplorer, wiWindow];
end;

function QWad.IsExplorerItem(Q: QObject) : TIsExplorerItem;
var
 S: String;
begin
 if Q is QPixelSet then
  Result:=ieResult[True] + [ieListView]
 else
  begin
   S:=Q.Name+Q.TypeInfo;
   Result:=ieResult[       { allow any ".wad_?" or ".wad3_?" file }
       (CompareText(Copy(S, Length(S)-5, 5), '.wad_') = 0)
    or (CompareText(Copy(S, Length(S)-6, 6), '.wad3_') = 0)];
  end;
end;

(*procedure QWad.LireEnteteFichier(Source: TStream; const Nom: String; var SourceTaille: Integer);
var
 Header: TWadHeader;
begin
 Source.ReadBuffer(Header, SizeOf(Header));
 if Header.Signature<>SignatureWad2 then
  Raise EErrorFmt(5505, [Nom, Header.Signature, SignatureWad2]);
 if Header.PosRep + Header.NoOfFileEntries*SizeOf(TWadFileRec) > SourceTaille then
  Raise EErrorFmt(5186, [Nom]);
 Source.Seek(-SizeOf(Header), soFromCurrent);
 LoadFormat:=1;
end;*)

procedure QWad.LoadFile(F: TStream; FSize: Integer);
var
 Header: TWadHeader;
 I: Integer;
 Entrees, P: PWadFileRec;
 Origine: LongInt;
 Q: QObject;
 Prefix: String;
begin
 case ReadFormat of
  1: begin  { as stand-alone file }
      if FSize<SizeOf(Header) then
       Raise EError(5519);
      Origine:=F.Position;
      F.ReadBuffer(Header, SizeOf(Header));
      if Header.Signature=SignatureWad2 then
       Prefix:='.wad_'
      else
       if Header.Signature=SignatureWad3 then
        Prefix:='.wad3_'
       else
        Raise EErrorFmt(5505, [LoadName, Header.Signature, SignatureWad2]);
      I:=Header.NoOfFileEntries * SizeOf(TWadFileRec);
      if (I<0) or (Header.PosRep<SizeOf(TWadHeader)) then
       Raise EErrorFmt(5509, [71]);
      if Header.PosRep + I > FSize then
       Raise EErrorFmt(5186, [LoadName]);

      GetMem(Entrees, I);
      try
        F.Position:=Origine + Header.PosRep;
        F.ReadBuffer(Entrees^, I);
        P:=Entrees;
        for I:=1 to Header.NoOfFileEntries do
         begin
          if (P^.Position+P^.Taille > FSize)
          or (P^.Position<SizeOf(Header))
          or (P^.Taille<0) then
           Raise EErrorFmt(5509, [72]);
          F.Position:=P^.Position;
          Q:=OpenFileObjectData(F, CharToPas(P^.Nom)+Prefix+P^.InfoType, P^.Taille, Self);
          SubElements.Add(Q);
          LoadedItem(rf_Default, F, Q, P^.Taille);
          Inc(P);
         end;
      finally
        FreeMem(Entrees);
      end;
     end;
 else
   inherited;
 end;
end;

procedure QWad.SaveFile(Info: TInfoEnreg1);
var
 Header: TWadHeader;
 Entree: TWadFileRec;
 Repertoire: TMemoryStream;
 Origine, Fin: LongInt;
 I, Zero: Integer;
 Q: QObject;
 Tex: QPixelSet;
 TexFile: QTextureFile;
 S: String;
 Wad3, HalfLifeWad3: Boolean;
begin
 with Info do case Format of
  1: begin  { as stand-alone file }
      Origine:=F.Position;
      F.WriteBuffer(Header, SizeOf(Header));  { updated later }
      Header.Signature:=SignatureWad2;

       { write .wad entries }
      Repertoire:=TMemoryStream.Create;
      try
        Header.NoOfFileEntries:=0;
        if CharModeJeu=mjHalfLife then
          HalfLifeWad3:=True {If selected gamemode is HalfLife, the user is most likely to save it as WAD3 format}
        else
          HalfLifeWad3:=False;
        for I:=0 to SubElements.Count-1 do
         begin
          FillChar(Entree, SizeOf(Entree), 0);
          Q:=SubElements[I];
          S:=Q.Name+Q.TypeInfo;

          Wad3:=Copy(S, Length(S)-6, 6) = '.wad3_';
          if Wad3 or HalfLifeWad3 then
           Header.Signature:=SignatureWad3;
          if Wad3 or (Copy(S, Length(S)-5, 5) = '.wad_') then
           begin
            Entree.InfoType:=S[Length(S)];
            Tex:=Nil;   { can store directly }
            PasToChar(Entree.Nom, Copy(S, 1, Length(S)-6-Ord(Wad3)));
           end
          else
           begin
            if not (Q is QPixelSet) then
             Raise EErrorFmt(5511, [Q.Name+Q.TypeInfo]);
            if HalfLifeWad3 then
              Entree.InfoType:='C'
            else
              Entree.InfoType:='D';
            Tex:=QPixelSet(Q);  { must convert to Quake 1 texture }
            PasToChar(Entree.Nom, Q.Name);
           end;
          Entree.Position:=F.Position;
          if Tex<>Nil then
           begin
            TexFile:=CreateCopyTexture(Tex);
            try
              if HalfLifeWad3 then
                TexFile.SaveAsHalfLife(F)
              else
                TexFile.SaveAsQuake1(F);  { we turn the texure into Quake 1 format }
            finally
              TexFile.AddRef(-1);
            end;
           end
          else
           Q.SaveFile1(Info);   { default saving method }
          Entree.Taille:=F.Position-Entree.Position;
          if HalfLifeWad3 then
            Entree.Taille:=Entree.Taille+((-Entree.Taille) and 3); {Some weird fix to get the HalfLife colors right in Wally}
          Entree.Idem:=Entree.Taille;
          Dec(Entree.Position, Origine);
          Zero:=0;
          F.WriteBuffer(Zero, (-Entree.Taille) and 3);  { align to 4 bytes }
          Repertoire.WriteBuffer(Entree, SizeOf(Entree));
          Inc(Header.NoOfFileEntries);
          ProgressIndicatorIncrement;
         end;

         { write directory }
        Header.PosRep:=F.Position-Origine;
        F.CopyFrom(Repertoire, 0);
      finally
        Repertoire.Free;
      end;

       { update header }
      Fin:=F.Position;
      F.Position:=Origine;
      F.WriteBuffer(Header, SizeOf(Header));
      F.Position:=Fin;
     end;
 else
   inherited;
 end;
end;

function QWad.TestConversionType(I: Integer) : QFileObjectClass;
begin
 case I of
  1: Result:=QWad;
 else
  Result:=Nil;
 end; 
end;

function QWad.ConversionFrom(Source: QFileObject) : Boolean;
begin
 Result:=Source is QWad;
 if Result then
  begin
   Source.Acces;
   CopyAllData(Source, False);   { directly copies data }
  end;
end;

 {------------------------}

class function QTextureList.TypeInfo;
begin
 Result:='.txlist';
end;

{function QTextureList.OpenWindow(nOwner: TComponent) : TQForm1;
begin
 Result:=TFQWad.Create(nOwner);
end;}

class procedure QTextureList.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.NomClasseEnClair:=LoadStr1(5135);
 Info.FileExt{Count}:=0;
end;

function QTextureList.IsExplorerItem(Q: QObject) : TIsExplorerItem;
begin
 if Q is QPixelSet then
  Result:=ieResult[True] + [ieListView]
 else
  Result:=ieResult[Q is QFileObject];
end;

procedure QTextureList.LoadFile(F: TStream; FSize: Integer);
var
 Count: LongInt;
 Positions, P: ^LongInt;
 Min, Origine: LongInt;
 Q: QObject;
 MaxSize, Size: LongInt;
 Header: TQ1Miptex;
 S{, TT}: String;
 I: Integer;
begin
 case ReadFormat of
  1: begin  { as stand-alone file }
      if FSize<SizeOf(Count) then
       {Raise EError(5519);}Exit;   { assume an empty list }
      Origine:=F.Position;
      F.ReadBuffer(Count, SizeOf(Count));
      if Count<0 then
       Raise EErrorFmt(5509, [91]);
      if Count=0 then
       Exit;
      Min:=(Count+1)*SizeOf(LongInt);
      if Min > FSize then
       Raise EErrorFmt(5186, [LoadName]);

     {TT:=Specifics.Values['TextureType'];
      if TT='' then TT:='.wad_D';}
      I:=Count * SizeOf(LongInt);
      GetMem(Positions, I); try
      F.ReadBuffer(Positions^, I);
      P:=Positions;
      for I:=1 to Count do
       begin
        if P^<0 then  { missing texture }
         begin
          Size:=0;
          S:=LoadStr1(5522);
         end
        else
         begin
          if (P^>FSize) or (P^<Min) then
           Raise EErrorFmt(5509, [92]);
          F.Position:=Origine + P^;
          if I=Count then
           MaxSize:=FSize
          else
           MaxSize:=(PLongInt(PChar(P)+SizeOf(LongInt)))^;
          Dec(MaxSize, P^);
          if MaxSize<SizeOf(Header) then
           begin
            Size:=0;
            S:=LoadStr1(5523);
           end
          else
           begin
            F.ReadBuffer(Header, SizeOf(Header));
            S:=CharToPas(Header.Nom);
            if MaxSize>SizeOf(Header) then
             begin
              Size:=CheckQ1Miptex(Header, MaxSize);
              if Size>MaxSize then
               Size:=0
              else
               Size:=MaxSize;
             end
            else
             Size:=0;   { assumes an empty texture (for Half-Life .bsp's) }
            F.Seek(-SizeOf(Header), soFromCurrent);
           end;
         end;
        if Size=0 then
         Q:=OpenFileObjectData(F, S, Size, Self)
        else
         Q:=OpenFileObjectData(F, S+'.wad_D', Size, Self);
        SubElements.Add(Q);
        LoadedItem(rf_Default, F, Q, Size);
        Inc(P);
       end;
      finally FreeMem(Positions); end;
     end;
 else inherited;
 end;
end;

procedure QTextureList.SaveFile(Info: TInfoEnreg1);
var
 Count: LongInt;
 I: Integer;
 Positions, P: ^LongInt;
 Origine, Fin, P1: LongInt;
 Q: QObject;
 TexFile: QTextureFile;
begin
 with Info do case Format of
  1: begin  { as stand-alone file }
      Origine:=F.Position;
      Count:=SubElements.Count;
      F.WriteBuffer(Count, SizeOf(Count));

       { write dummy positions to be updated later }
      I:=Count*SizeOf(LongInt);
      GetMem(Positions, I);
      try
        FillChar(Positions^, I, $FF);
        F.WriteBuffer(Positions^, I);

         { write textures }
        P:=Positions;
        for I:=0 to SubElements.Count-1 do
         begin
          Q:=SubElements[I];
          if Q is QPixelSet then
           begin
            P1:=F.Position;
            try
             if Q is QTexture1 then
              Q.SaveFile1(Info)   { default saving method }
             else
              begin
               TexFile:=CreateCopyTexture(QPixelSet(Q));
               try
                 TexFile.SaveAsQuake1(F);  { convert to Quake 1 format }
               finally
                 TexFile.AddRef(-1);
               end;
              end;
             P^:=P1-Origine;  { ok }
            except
             F.Position:=P1;   { could not store texture }
            end;
           end;
          Inc(P);
          ProgressIndicatorIncrement;
         end;

         { update directory }
        Fin:=F.Position;
        F.Position:=Origine + SizeOf(Count);
        F.WriteBuffer(Positions^, Count*SizeOf(LongInt));
        F.Position:=Fin;
      finally
        FreeMem(Positions);
      end;
     end;
 else
   inherited;
 end;
end;

 {------------------------}

(*type
 TTex1 = record
          Q: QObject;
          ImageIndex: Integer;
         end;
 PListInternal = ^TListInternal;
 TListInternal = record
                  TexCount, ExtendedAnim: Integer;
                  Tex: array[0..0] of TTex1;
                 end;*)

(*function TextureCaption(Q: QTexture) : String;
var
 Header: TQ1Miptex;
 Reduction: Integer;
begin
 Result:=Q.Name;
 Header:=Q.BuildQ1Header;
 Reduction:=0;
 while (Reduction<3) and ((Header.W>64) or (Header.H>64)) do
  begin
   Header.W:=Header.W div 2;
   Header.H:=Header.H div 2;
   Inc(Reduction);
  end;
 case Reduction of
  1: Result:=Result + '  (�)';
  2: Result:=Result + '  (�)';
  3: Result:=Result + '  (1/8)';
 end;
end;*)

function TFQWad.AnimationNextStep(Q: QPixelSet; Seq: Integer) : QPixelSet;
var
 S: String;
 L: TStringList;
 I: Integer;
 QObj: QObject;
 QF: QTextureFile;
begin
 Result:=Q;
 if FileObject=Nil then Exit;
 try
  QObj:=Q.LoadPixelSet;
 except
  Exit;
 end;
 if not (QObj is QTextureFile) then Exit;
 QF:=QTextureFile(QObj);
 S:=QF.CheckAnim(Seq);  { find name of candidates }
 if S<>'' then
  begin
   L:=TStringList.Create; try
   L.Text:=S;
   for I:=0 to L.Count-1 do
    begin
     QObj:=FileObject.SubElements.FindShortName(L[I]);
     if (QObj<>Nil) and (QObj is QPixelSet) then
      begin
       Result:=QPixelSet(QObj);
       Exit;
      end;
    end;
   finally L.Free; end;
  end;
end;

(*procedure TFQWad.wmInternalMessage(var Msg: TMessage);
var
 Q: QObject;
 Modes: set of Boolean;
 I: Integer;
begin
 case Msg.wParam of
  wp_AfficherObjet:
    begin
     Modes:=[];
     if FileObject<>Nil then
      for I:=0 to FileObject.SubElements.Count-1 do
       begin
        Q:=FileObject.SubElements[I];
        if Q is QTexture then
         case QTexture(Q).NeededGame of       
          mjNotQuake2: Include(Modes, False);
          mjQuake2: Include(Modes, True);
         end;
       end;
     if Modes=[False] then
      SetInfo(DuplicateGameBuffer(GameBuffer(mjNotQuake2)))
     else
      if Modes=[True] then
       SetInfo(DuplicateGameBuffer(GameBuffer(mjQuake2)))
      else
       begin
        SetInfo(Nil);
        if Modes=[False, True] then
         Raise EError(5549);
       end;
    end;
 end;
 inherited;
end;*)

function TFQWad.AssignObject(Q: QFileObject; State: TFileObjectWndState) : Boolean;
begin
 Result:=(Q is QWad) and inherited AssignObject(Q, State);
end;

function TFQWad.GetConfigStr : String;
begin
 GetConfigStr:='Texture list';
end;

function TFQWad.PopulateListView(Counter: Integer) : Integer;
var
 NomTexture{, Image}, ErrorMsg: String;
 I, J, Reduction, Gauche{, Source}: Integer;
{P: PChar;
 Header: TQ1Miptex;}
 DC: HDC;
{Bits: array[0..63, 0..63] of Char;}
 Q: QObject;
 R: TRect;
 TexLoop: TList;
 BaseImage: Integer;
 SelectNow{, ZeroIsNotBlack}: Boolean;
 Item: TListItem;
{GameInfo: PGameBuffer;}
 PSD, NewPSD: TPixelSetDescription;
{Pal1: HPalette;}

(*procedure AjouterEl(Q: QObject; Nom: String; Numero: Integer; Compter: Boolean);
  var
   Item: TListItem;
   I, J, Compte: Integer;
  begin
   J:=PositionTexture^[Numero].ListIndex;
   if J<ListView1.Items.Count then
    begin
     Item:=ListView1.Items[J];
     if Compter then
      begin
       Compte:=1;
       for I:=0 to Numero-1 do
        if PositionTexture^[I].ListIndex=J then
         Inc(Compte);
       Nom:=Nom+' � '+IntToStr(Compte);
      end;
     Nom[2]:='#';
    end
   else
    Item:=ListView1.Items.Add;
   with Item do
    begin
     Data:=Q;
     Caption:=Nom;
     ImageIndex:=Numero;
    end;
  end;*)

begin
 if Counter<0 then
  begin
   TimerAnimation.Enabled:=False;
   TimerAnimation.Tag:=-1;
  {if ScreenColors<>0 then
    ImageList1.Handle:=ImageList_Create(64,64, ILC_COLOR24, ListView1.AllocBy, 4)
   else
    begin}
     ImageList1.Clear;
     ImageList1.AllocBy:=ListView1.AllocBy;
   {end;}
   if FileObject.SubElements.Count=0 then
    Result:=-1
   else
    begin
     if ImageTextures=Nil then
      ImageTextures:=TQList.Create
     else
      ImageTextures.Clear;
     Result:=0;
    end;
   Exit;  { quit here - we are in an idle job }
  end;
 NewPSD.Init;
 PSD.Init;
 while Counter < FileObject.SubElements.Count do
  begin
   Q:=FileObject.SubElements[Counter];
   Inc(Counter);
   if not (Q is QPixelSet)   { ignore the non-images }
   or (ImageTextures.IndexOf(Q)>=0) then      { already loaded }
    Continue;

    { build the animation loop }
   TexLoop:=TList.Create; try
   repeat
    TexLoop.Add(Q);
    Q:=AnimationNextStep(QPixelSet(Q), 0);
    I:=TexLoop.IndexOf(Q);
    if I>=0 then Break;   { closed the animation loop }
   until ImageTextures.IndexOf(Q)>=0;
   if I<0 then
    begin  { animation loop broken }
     while TexLoop.Count>1 do
      TexLoop.Delete(TexLoop.Count-1);   { keep only the first texture }
    end
   else
    while I>0 do
     begin
      Dec(I);
      TexLoop.Delete(I);  { keep only the textures in the loop }
     end;

    { read all textures from the loop }
   BaseImage:=ImageList1.Count;
   NomTexture:=QTexture(TexLoop[0]).Name;
   SelectNow:=False;
   for J:=0 to TexLoop.Count-1 do
    begin
     try
       { build the 64x64 image }
      if Tex=Nil then
       begin
        Tex:=TBitmap.Create;
        Tex.Width:=64;  {DECKER - try to figure out how to make these modifyable, so QuArK won't crash!}
        Tex.Height:=64; {       - and actually display the images in 32x32, 128x128, 256x256 or ...}
       end;
      Q:=QPixelSet(TexLoop[J]).LoadPixelSet;
      PSD.Size:=QPixelSet(Q).GetSize;
      Reduction:=0;
      while (PSD.Size.X>(*64*)Tex.Width) or (PSD.Size.Y>(*64*)Tex.Height) do
       begin
        PSD.Size.X:=PSD.Size.X div 2;
        PSD.Size.Y:=PSD.Size.Y div 2;
        Inc(Reduction);
       end;
      if J=0 then
       case Reduction of
        0: ;
        1: NomTexture:=NomTexture + '  (�)';
        2: NomTexture:=NomTexture + '  (�)';
       else
           NomTexture:=NomTexture + Format('  (1/%d)', [1 shl Reduction]);
       end;

      try
       if Reduction=0 then
        NewPSD:=QPixelSet(Q).Description
       else
        if (Q is QTextureFile) and (Reduction < (QTextureFile(Q).CustomParams and cpIndexesMax)) then
         NewPSD:=QTextureFile(Q).ScaledDownDescription(Reduction)
        else
         begin
          NewPSD.Init;
          NewPSD.Size:=PSD.Size;
          PSD:=QPixelSet(Q).Description;
          PSDConvert(NewPSD, PSD, ccTemporary);
         end;
       DC:=Tex.Canvas.Handle;
       PatBlt(DC, 0, 0, (*64*)Tex.Width, (*64*)Tex.Height, Blackness);
       Gauche:=((*64*)Tex.Width-NewPSD.Size.X) div 2;
       NewPSD.Paint(DC, Gauche, (*64*)Tex.Height-NewPSD.Size.Y);
      finally
       NewPSD.Done;
       PSD.Done;
      end;
     except
      on E: Exception do
       with Tex.Canvas do
        begin
         PatBlt(Handle, 0,0,(*64*)Tex.Width,(*64*)Tex.Height, Whiteness);
         Font.Name:='Small fonts';
         Font.Size:=6;
         ErrorMsg:=GetExceptionMessage(E);
         R.Left:=(*3*)1;
         R.Top:=(*5*)1;
         R.Right:=(*62*)Tex.Width-2;
         R.Bottom:=(*64*)Tex.Height-2;
         DrawText(Handle, PChar(ErrorMsg), Length(ErrorMsg), R,
          DT_NOCLIP or DT_NOPREFIX or DT_WORDBREAK);
(*DECKER - don't change the displayed texture-name to "texture/....."
         if J=0 then
          NomTexture:=Q.Name;
DECKER*)
        end;
     end;
    {if ScreenColors<>0 then
      ImageList_Add(ImageList1.Handle, Tex.Handle, 0)
     else}
      begin
     (*{$IFNDEF VER90}
       UpdateWindow(ListView1.Handle);
       LockWindowUpdate(ListView1.Handle); try
       {$ENDIF}
       ImageList1.Add(Tex, Nil);
       {$IFNDEF VER90}
       finally LockWindowUpdate(0); end;
       ValidateRect(ListView1.Handle, Nil);
       {$ENDIF}*)
       ImageList_Add(ImageList1.Handle, Tex.Handle, 0);
      end;
     Q:=QPixelSet(TexLoop[J]);
     ImageTextures.Add(Q);
     SelectNow:=SelectNow or (Q=SelectThis);
    end;

    { add the list view item }
   if TexLoop.Count>1 then
    NomTexture:=NomTexture+' � '+IntToStr(TexLoop.Count);
(*
{DECKER-begin - How can we detect that this "texture" is a shader?}
   if Q is QShader then
    NomTexture:=NomTexture+Chr(13)+'Shader';
{DECKER-end}
*)
   Q:=QObject(TexLoop[0]);
   Item:=ListView1.Items.Add;
   {$IFDEF Debug}
   if BaseImage>=ImageTextures.Count then
    Raise InternalE('QkWad/BaseImage');
   {$ENDIF}
   with Item do
    begin
     Data:=Q;
     ImageIndex:=BaseImage;
     Caption:=NomTexture;
    end;
   if TexLoop.Count>1 then
    TimerAnimation.Tag:=0;  { there are textures to animate }
   finally TexLoop.Free; end;

   if SelectNow then
    begin
     SelectListItem(Item);
     SelectThis:=Nil;
    end;
   Result:=Counter;
   Exit;  { quit here - we are in an idle job }
  end;

  { texture page completely loaded }
 Tex.Free;
 Tex:=Nil;
 Gauche:=GetScrollPos(ListView1.Handle, sb_Vert);
 Item:=ListView1.Selected;
 if Item<>Nil then
  ListView1.Selected:=Nil;
 ListView1.Arrange(arDefault);
 ListView1.Scroll(0, -2*Gauche);
 ListView1.Scroll(0, Gauche);
{ListView1.SetFocus;}
 if Item<>Nil then
  SelectListItem(Item);
 TimerAnimation.Enabled:=TimerAnimation.Tag=0;
 Result:=-1;  { end of the job }
end;

procedure TFQWad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 inherited;
 TimerAnimation.Enabled:=False;
 ImageList1.Clear;
 Tex.Free;
 Tex:=Nil;
 ImageTextures.Free;
 ImageTextures:=Nil;
{SetInfo(Nil);}
end;

(*procedure TFQWad.MakePositionTextures;
var
 I, J, Courant: Integer;
 L: TList;
 S, S2: String;
 Q: QObject;
begin
 TextureCount:=0;
 FreeMem(PositionTexture);
 PositionTexture:=Nil;

 L:=TStringList.Create; try
 for I:=0 to FileObject.SubElements.Count-1 do
  begin
   Q:=FileObject.SubElements[I];
   if Q is QTexture then
    L.Add(Q);
  end;
 J:=L.Count*SizeOf(TTextureInternal);
 GetMem(PositionTexture, J);
 FillChar(PositionTexture, J, $FF);
 TextureCount:=L.Count;
 Courant:=0;
 for I:=0 to TextureCount-1 do
  begin
   PositionTexture^[I].Q:=QTexture(L[I]);
   S:=QTexture(L[I]).Name;
   if PositionTexture^[I].ListIndex<0 then  { if not yet initialized }
    begin
     PositionTexture^[I].ListIndex:=Courant;
     if (Length(S)>=2) and (S[1]='+') then
      begin
       S:=Copy(S, 3,MaxInt);
       for J:=I+1 to TextureCount-1 do
        begin
         S2:=L[J];
         if (Length(S2)>=2) and (S2[1]='+')
         and (CompareText(Copy(S2, 3,MaxInt), S)=0) then
          PositionTexture^[J].ListIndex:=Courant;
        end;
      end;
     Inc(Courant);
    end;
  end;
 finally L.Free; end;
end;*)

procedure TFQWad.TimerAnimationTimer(Sender: TObject);
const
 k_ImagesAvantChangement = 20;
var
 P: Integer;
 Anime: Boolean;
 F: TCustomForm;

  procedure Animer(P: Integer);
  var
   Q1, Q2: QPixelSet;
  begin
   with ListView1.Items[P] do
    begin
     Q1:=QPixelSet(ImageTextures[ImageIndex]);
     Q2:=AnimationNextStep(Q1, Ord(TimerAnimation.Tag>=k_ImagesAvantChangement)+1);
     if Q1<>Q2 then
      begin
       ImageIndex:=ImageTextures.IndexOf(Q2);
       {$IFDEF Debug}
       if ImageIndex=-1 then
        raise InternalE('AnimationNextStep broken');
       {$ENDIF}
       Anime:=True;
      end;
    end;
  end;

(*procedure Animer(P: Integer);
  var
   I, I0, Suivant, Tst, TstSuivant: Integer;
   Car0: Char;
   S: String;
  begin
   I0:=ListView1.Items[P].ImageIndex;
   Suivant:=I0;
   TstSuivant:=MaxInt;
   S:=PositionTexture^[I0].Q.Name;
   Car0:=S[2];
   for I:=0 to ImageList1.Count-1 do
    if PositionTexture^[I].ListIndex=P then
     begin
      if I<>I0 then
       Anime:=True;
      S:=TexList[I];
      Tst:=Ord(S[2])-Ord(Car0);
      if Tst<=0 then
       Inc(Tst, 100);
      if (S[2]<'A') xor (TimerAnimation.Tag<k_ImagesAvantChangement) then
       Inc(Tst, 200);
      if Tst<TstSuivant then
       begin
        TstSuivant:=Tst;
        Suivant:=I;
       end;
     end;
   if Suivant<>I0 then
    ListView1.Items[P].ImageIndex:=Suivant;
  end;*)

begin
 F:=GetParentForm(ListView1);
 if (F=Nil) or not F.Visible then Exit;
 Anime:=False;
 ListView1.Update;
 for P:=0 to ListView1.Items.Count-1 do
  Animer(P);
 if Anime then
  begin
   ValidateRect(ListView1.Handle, Nil);
   InvalidateRect(ListView1.Handle, Nil, False);
  end;
 TimerAnimation.Tag:=TimerAnimation.Tag+1;
 if TimerAnimation.Tag>=2*k_ImagesAvantChangement then
  TimerAnimation.Tag:=0;
end;

function TFQWad.EnumObjs(Item: TListItem; var Q: QObject) : Boolean;
var
 Q1: QPixelSet;
begin
 Q1:=QPixelSet(Item.Data);
 if Q=Nil then
  begin
   Q:=Q1;  { return the first texture }
   Result:=True;
   Exit;
  end;
 Q:=AnimationNextStep(Q as QPixelSet, 0);  { find the next one }
 Result:=Q<>Q1;  { Result:=False if we closed the loop }
end;

(*procedure TFQWad.SetInfo(nInfo: PGameBuffer);
begin
 if GameInfo<>nil then
  DeleteGameBuffer(GameInfo);
 GameInfo:=nInfo;
end;*)

(*procedure TFQWad.FormCreate(Sender: TObject);
var
 DC: HDC;
begin
 inherited;
 DC:=GetDC(GetDesktopWindow);
 if (DC=0) or (GetDeviceCaps(DC, RASTERCAPS) and RC_PALETTE <> 0) then
  ScreenColors:=0  { palettized device }
 else
  case GetDeviceCaps(DC, BITSPIXEL) * GetDeviceCaps(DC, PLANES) of
   9..23: ScreenColors:=ILC_COLOR16;
   24..31: ScreenColors:=ILC_COLOR24;
   32..96: ScreenColors:=ILC_COLOR32;
  else
   ScreenColors:=0;
  end;
 ReleaseDC(GetDesktopWindow, DC);
end;*)

initialization
  RegisterQObject(QWad, 'p');
  RegisterQObject(QTextureList, 'a');
end.
