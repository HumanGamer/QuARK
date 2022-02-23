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
unit QkText;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkObjects, QkFileObjects, QkForm, TB97, StdCtrls;

type
 QText   = class(QFileObject)
           protected
             function OpenWindow(nOwner: TComponent) : TQForm1; override;
           public
             class function TypeInfo: String; override;
             function TestConversionType(I: Integer) : QFileObjectClass; override;
             function ConversionFrom(Source: QFileObject) : Boolean; override;
             procedure ObjectState(var E: TEtatObjet); override;
             class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
             procedure CopyExtraData(var HasText: Boolean); override;
           end;
 QCfgFile = class(QText)
            public
              class function TypeInfo: String; override;
              procedure ObjectState(var E: TEtatObjet); override;
              class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
            end;
 QJsonFile = class(QText)
            public
              class function TypeInfo: String; override;
              class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
            end;
 QXmlFile = class(QText)
            public
              class function TypeInfo: String; override;
              class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
            end;
 QZText   = class(QText)
            protected
              procedure SaveFile(Info: TInfoEnreg1); override;
            end;

type
  TFQText = class(TQForm1)
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private
    MAJ: Boolean;
    procedure wmInternalMessage(var Msg: TMessage); message wm_InternalMessage;
  protected
    function AssignObject(Q: QFileObject; State: TFileObjectWndState) : Boolean; override;
    function GetConfigStr : String; override;
  public
   {function MacroCommand(Cmd: Integer) : Boolean; override;}
  end;

 {------------------------}

function TestConversionText(var I: Integer) : QFileObjectClass;
{function TextMacroCommand(F: TForm; FileObject: QFileObject; Cmd: Integer) : Boolean;}

 {------------------------}

implementation

uses QkQuakeC, QkQ1, Undo, Quarkx, QkObjectClassList;

{$R *.DFM}

function TestConversionText(var I: Integer) : QFileObjectClass;
begin
 case I of
  1: Result:=QText;
  2: Result:=QCfgFile;
  3: Result:=QJsonFile;
  4: Result:=QXmlFile;
  5: Result:=QRCFile;
 else
   begin
    Dec(I,5);
    Result:=Nil;
   end;
 end;
end;

(*function TextMacroCommand(F: TForm; FileObject: QFileObject; Cmd: Integer) : Boolean;
var
 C: TComponent;
begin
 Result:=True;
 if FileObject is QText then
  case Cmd of
   { TXSH } Ord('T')+256*Ord('X')+65536*Ord('S')+16777216*Ord('H'):
     begin
      C:=F.FindComponent('FindDlg_1');
      if C=Nil then
       C:=TFindDialog.Create(F);
      Exit;
     end;
  end;
 Result:=False;
end;*)

 {------------------------}

class function QText.TypeInfo;
begin
 Result:='.txt';
end;

function QText.OpenWindow(nOwner: TComponent) : TQForm1;
begin
 Result:=TFQText.Create(nOwner);
end;

procedure QText.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiText;
 E.MarsColor:=clWhite;
end;

class procedure QText.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5160);
 Info.FileExt:=790;
 Info.WndInfo:=[wiWindow];
end;

function QText.TestConversionType(I: Integer) : QFileObjectClass;
begin
 Result:=TestConversionText(I);
 if Result=Nil then
  Result:=TestConversionQC(I);
end;

function QText.ConversionFrom(Source: QFileObject) : Boolean;
begin
 Result:=Source is QText;
 if Result then
  begin
   Source.Acces;
   CopyAllData(Source, False);   { directly copies data }
  end;
end;

procedure QText.CopyExtraData;
var
 Data: String;
 H: THandle;
 P: PChar;
begin
 Data:=Specifics.Values['Data'];
 if Data='' then Exit;
 H:=GlobalAlloc(gmem_Moveable or gmem_DDEShare, Length(Data)+1);
 if H<>0 then
  begin
   P:=GlobalLock(H);
   Move(Data[1], P^, Length(Data)+1);
   GlobalUnlock(H);
   SetClipboardData(CF_TEXT, H);
   HasText:=True;
  end;
end;

 {------------------------}

procedure QZText.SaveFile(Info: TInfoEnreg1);
const
 Start = Length('Data=X');
var
 S: String;
 I: Integer;
begin  { write as unformatted data }
 with Info do case Format of
  rf_Default:            { as stand-alone file }
    begin
     S:=GetSpecArg('Data');
     I:=Length(S)-Start+1;
     if S[Length(S)]<>#0 then Inc(I);  { append a null character if not already present }
     F.WriteBuffer(S[Start], I);
    end;
  else
   inherited;
 end;
end;

 {------------------------}

class function QCfgFile.TypeInfo;
begin
 Result:='.cfg';
end;

procedure QCfgFile.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiCfgFile;
end;

class procedure QCfgFile.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5161);
 Info.FileExt:=791;
 Info.WndInfo:=[wiWindow];
end;

 {------------------------}

class function QJsonFile.TypeInfo;
begin
 Result:='.json';
end;

class procedure QJsonFile.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5854);
 Info.FileExt:=831;
 Info.WndInfo:=[wiWindow];
end;

 {------------------------}

class function QXmlFile.TypeInfo;
begin
 Result:='.xml';
end;

class procedure QXmlFile.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5855);
 Info.FileExt:=832;
 Info.WndInfo:=[wiWindow];
end;

 {------------------------}

procedure TFQText.wmInternalMessage(var Msg: TMessage);
begin
 case Msg.wParam of
  wp_AfficherObjet:
    if FileObject<>Nil then
     begin
      MAJ:=True; try
      Memo1.Clear;
      if FileObject is QCfgFile then
       begin
        Memo1.WordWrap:=False;
        Memo1.ScrollBars:=ssBoth;
       end
      else
       begin
        Memo1.WordWrap:=True;
        Memo1.ScrollBars:=ssVertical;
       end;
      Memo1.Lines.Text:=FileObject.Specifics.Values['data'];
      finally MAJ:=False; end;
     end;
 end;
 inherited;
end;

function TFQText.AssignObject(Q: QFileObject; State: TFileObjectWndState) : Boolean;
begin
 Result:=(Q is QText) and inherited AssignObject(Q, State);
end;

procedure TFQText.Memo1Change(Sender: TObject);
begin
 if not MAJ then
  ActionEx(na_Local, FileObject, TSpecificUndo.Create(
   'write text', 'data', Memo1.Lines.Text, sp_Auto, FileObject));
end;

function TFQText.GetConfigStr : String;
begin
 GetConfigStr:='Text';
end;

{function TFQText.MacroCommand(Cmd: Integer) : Boolean;
begin
 Result:=TextMacroCommand(Self, FileObject, Cmd) or inherited MacroCommand(Cmd);
end;}

initialization
  RegisterQObject(QText, 'd');
  RegisterQObject(QCfgFile, 'c');
  RegisterQObject(QJsonFile, 'b');
  RegisterQObject(QXmlFile, 'b');
end.
