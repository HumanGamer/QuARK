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

}


unit NewFolder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, TB97, StdCtrls, ExtCtrls, QkForm, ToolBox1;

type
  TNewFolderDlg = class(TQkForm)
    ListView1: TListView;
    Bevel1: TBevel;
    Label1: TLabel;
    RadioButton1: TRadioButton;
    Label2: TLabel;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Label3: TLabel;
    CancelBtn: TToolbarButton97;
    OkBtn: TToolbarButton97;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    Source: TToolBoxForm;
  end;

implementation

uses Game, Qk1, Setup, QkGroup, QkObjects, QkFileObjects, Undo, Quarkx,
  PyImages, ToolBoxGroup;

{$R *.DFM}

procedure TNewFolderDlg.FormCreate(Sender: TObject);
begin
 MarsCap.ActiveBeginColor:=clMaroon;
 MarsCap.ActiveEndColor:=clYellow;
 UpdateMarsCap;
 OpenGlobalImageList(ListView1);
 SaveDialog1.FileName:=ApplicationPath+'*.qrk';
 DisplayAddOnsList(ListView1);
end;

procedure TNewFolderDlg.RadioButton2Click(Sender: TObject);
begin
 ListView1.Font.Color:=clWindowText;
end;

procedure TNewFolderDlg.ListView1Click(Sender: TObject);
begin
 RadioButton2.Checked:=True;
end;

procedure TNewFolderDlg.RadioButton1Click(Sender: TObject);
begin
 ListView1.Selected:=Nil;
 ListView1.Font.Color:=clGrayText;
end;

procedure TNewFolderDlg.OkBtnClick(Sender: TObject);
var
 ToolBox: QToolBox;
 Folder: QToolBoxGroup;
 Gr: QExplorerGroup;
 Target, AddOns: QObject;
begin
 Target:=Nil; try
 if RadioButton2.Checked then
  begin
   if ListView1.Selected=Nil then
    begin
     ListView1.SetFocus;
     MessageBeep(0);
     Exit;
    end;
   AddOns:=MakeAddonsList; try
   Target:=AddOns.SousElements.FindName(ListView1.Selected.Caption);
   Target.AddRef(+1);
   finally AddOns.AddRef(-1); end;
   if Target=Nil then
    Raise InternalE('No Target for Add-on');
  end;
 if RadioButton3.Checked then
  begin
   SaveDialog1.Filter:=LoadStr1(772)+'|'+LoadStr1(774);
   SaveDialog1.Title:=LoadStr1(5257);
   if not SaveDialog1.Execute then Exit;
   if CompareText(ExtractFilePath(SaveDialog1.FileName), ApplicationPath) <> 0 then
    Raise EError(5596);
   Target:=BuildFileRoot(SaveDialog1.FileName, Nil);
   Target.AddRef(+1);
   if ListView1.FindCaption(0, Target.Name+Target.TypeInfo, False, True, False) <> Nil then
    Raise EError(5600);
   Target.Specifics.Values['Description']:=LoadStr1(5230);
  end;
 ToolBox:=QToolBox.Create(LoadStr1(5258), Target);
 ToolBox.AddRef(+1); try
 ToolBox.Specifics.Values['ToolBox']:=Source.GetToolBoxSingleName;
 Folder:=QToolBoxGroup.Create(LoadStr1(5259), ToolBox);
 ToolBox.SousElements.Add(Folder);
 ToolBox.Specifics.Values['Root']:=Folder.Name+Folder.TypeInfo;

 if RadioButton3.Checked then
  begin
   Target.SousElements.Add(ToolBox);
   (Target as QFileObject).TrySavingNow;
   AddAddOn(Target);
  end
 else
  if RadioButton2.Checked then
   Undo.Action(Target, TQObjectUndo.Create(LoadStr1(606),
    Nil, ToolBox))
  else
   begin
    Gr:=ClipboardGroup;
    Gr.AddRef(+1); try
    Gr.SousElements.Add(ToolBox);
    Form1.Explorer.DropObjectsNow(Gr, LoadStr1(606), True);
    finally Gr.AddRef(-1); end;
   end;

 finally ToolBox.AddRef(-1); end;
 finally Target.AddRef(-1); end;
 ModalResult:=mrOk;
end;

procedure TNewFolderDlg.CancelBtnClick(Sender: TObject);
begin
 ModalResult:=mrCancel;
end;

procedure TNewFolderDlg.FormDestroy(Sender: TObject);
begin
 CloseGlobalImageList(ListView1);
end;

end.
