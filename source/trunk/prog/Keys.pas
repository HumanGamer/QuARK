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
unit Keys;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  KeySel, StdCtrls, Buttons, ComCtrls, ImgList;

type
  TKeyDlg = class(TForm)
    ListView1: TListView;
    ImageList1: TImageList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    KeySelDlg: TKeySelDlg;
  public
  end;

implementation

uses Quarkx;

{$R *.DFM}

procedure TKeyDlg.FormDestroy(Sender: TObject);
begin
 KeySelDlg.Free;
end;

procedure TKeyDlg.ListView1DblClick(Sender: TObject);
var
 S: TListItem;
begin
 S:=ListView1.Selected;
 if S=Nil then
  Exit;
 if KeySelDlg=Nil then
  KeySelDlg:=TKeySelDlg.Create(Application);
 KeySelDlg.Caption:=S.SubItems[0];
 KeySelDlg.ComboBox1.Text:=S.Caption;
 if KeySelDlg.ShowModal = mrOk then
  S.Caption:=KeySelDlg.ComboBox1.Text;
end;

procedure TKeyDlg.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then
  begin
   ListView1DblClick(Nil);
   Key:=#0;
  end;
end;

procedure TKeyDlg.FormActivate(Sender: TObject);
begin
 Caption:=LoadStr1(721);
 ListView1.Columns[0].Caption:=LoadStr1(722);
 ListView1.Columns[1].Caption:=LoadStr1(723);
{Label1.Caption:=LoadStr1(724);}
 ImageList1.AddMasked(BitBtn3.Glyph, clAqua);
 BitBtn3.Caption:=LoadStr1(725);
 ListView1.Selected:=ListView1.Items[0];
end;

procedure TKeyDlg.BitBtn3Click(Sender: TObject);
begin
 ListView1DblClick(Nil);
end;

end.
