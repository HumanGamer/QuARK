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
Revision 1.10  2004/01/05 22:01:43  silverpaladin
TrySavingNow was changed to display a warning if it fails rather than raising an error message.  Then if something like an MD3 is referenced in a qrk file, the rest of the qrk file can still be saved without erroring out.

Revision 1.9  2003/07/21 04:52:21  nerdiii
Linux compatibility ( '/' '\' )

Revision 1.8  2001/03/20 21:48:05  decker_dk
Updated copyright-header

Revision 1.7  2001/02/02 00:09:32  aiv
Added IsPathDelimiter & IncludeTrailingBackslash to new File : ExtraFunctionality.pas
for us non-D5 users.

Revision 1.6  2001/01/30 19:10:12  decker_dk
Added a function FindAndAddFilesOfMask(), which hopefully should make the future ./Addons with sub-directories per supported game, easier to make/search through.
Modified FormActivate() so it will search for *.QRK files in four places.
Changed to GetApplicationPath().

Revision 1.5  2001/01/07 13:21:05  decker_dk
Resized the dialog.

Revision 1.4  2000/07/18 19:37:58  decker_dk
Englishification - Big One This Time...

Revision 1.3  2000/06/03 10:46:49  alexander
added cvs headers
}

unit Game2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB97, ComCtrls, StdCtrls, Qk1, QkForm;

type
  TAddOnsAddDlg = class(TQkForm)
    GroupBox1: TGroupBox;
    Label2: TLabel;
    ListView1: TListView;
    CancelBtn: TToolbarButton97;
    OkBtn: TToolbarButton97;
    procedure OkBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
  private
    procedure FindAndAddFilesOfMask(const a_Path:String; const a_FileMask:String);
  public
    SrcListView: TListView;
  end;

implementation

uses Game, QkFileObjects, Setup, QkObjects, PyImages, Travail, QkApplPaths, ExtraFunctionality;

{$R *.DFM}

procedure TAddOnsAddDlg.OkBtnClick(Sender: TObject);
begin
 if (ListView1.Selected<>Nil)
 and not ListView1.Selected.Cut then
  begin
   SrcListView.Tag:=1;
   with SrcListView.Items.Add do
    begin
     Caption:=ListView1.Selected.Caption;
     if ListView1.Selected.SubItems.Count>0 then
      SubItems.Add(ListView1.Selected.SubItems[0]);
     ImageIndex:=ListView1.Selected.ImageIndex;
     Selected:=True;
     Focused:=True;
    end;
  end;
 ModalResult:=mrOk;
end;

procedure TAddOnsAddDlg.CancelBtnClick(Sender: TObject);
begin
 ModalResult:=mrCancel;
end;

procedure TAddOnsAddDlg.FormCreate(Sender: TObject);
begin
 MarsCap.ActiveBeginColor:=clRed;
 OpenGlobalImageList(ListView1);
 UpdateMarsCap;
end;

procedure TAddOnsAddDlg.FindAndAddFilesOfMask(const a_Path:String; const a_FileMask:String);
var
  rc: Integer;
  searchRec: TSearchRec;
begin
  rc:=FindFirst(IncludeTrailingPathDelimiter(a_Path)+a_FileMask, faAnyFile, searchRec);
  try
    while rc=0 do
    begin
      if ListView1.FindCaption(0, searchRec.Name, False, True, False) = Nil then
        with ListView1.Items.Add do
        begin
          Caption:=searchRec.Name;
          if SrcListView.FindCaption(0, Caption, False, True, False) <> Nil then
            Cut:=True;
        end;
      rc:=FindNext(searchRec);
    end;
  finally
    FindClose(searchRec);
  end;
end;

procedure TAddOnsAddDlg.FormActivate(Sender: TObject);
var
 I: Integer;
 Q: QFileObject;
begin
 OnActivate:=Nil;

 { search root-directory of QuArK "<appl.path>\" }
 FindAndAddFilesOfMask(GetApplicationPath(), '*.qrk');
(* possibility of an "<appl.path\UserData\<gamename>" directory?
 { search QuArK sub-directory for User Data. E.q. "<appl.path>\UserData" }
 FindAndAddFilesOfMask(GetApplicationUserdataPath(), '*.qrk');
 { search QuArK sub-directory named as the selected game. E.q. "<appl.path>\UserData\Quake_2" }
 FindAndAddFilesOfMask(GetApplicationUserdataGamePath(), '*.qrk');
*)
 { search QuArK addons sub-directory. E.q. "<appl.path>\addons" }
 FindAndAddFilesOfMask(GetApplicationAddonsPath(), '*.qrk');
 { search QuArK addons sub-sub-directory named as the selected game. E.q. "<appl.path>\addons\Quake_2" }
 FindAndAddFilesOfMask(GetApplicationAddonsGamePath(), '*.qrk');

 Update;

 ProgressIndicatorStart(5458, ListView1.Items.Count);
 try
  for I:=0 to ListView1.Items.Count-1 do
   with ListView1.Items[I] do
    try
     Q:=LienFichierQObject(Caption, Nil, False);
     Q.AddRef(+1);
     try
      Q.Acces;
      SubItems.Add(Q.Specifics.Values['Description']);
      ImageIndex:=LoadGlobalImageList(Q);
      MakeVisible(False);
      ListView1.Repaint;
     finally
      Q.AddRef(-1);
     end;
     ProgressIndicatorIncrement;
    except
     on EAbort do Break;
     else
      {rien};
    end;
 finally
  ProgressIndicatorStop;
  ListView1.Font.Color:=clWindowText;
 end;
end;

procedure TAddOnsAddDlg.FormDestroy(Sender: TObject);
begin
 CloseGlobalImageList(ListView1);
end;

procedure TAddOnsAddDlg.ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
 OkBtn.Enabled:=(ListView1.Selected<>Nil) and not ListView1.Selected.Cut;
end;

end.
