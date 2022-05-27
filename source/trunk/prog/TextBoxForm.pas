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
unit TextBoxForm;

interface

uses Windows, SysUtils, Classes, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  TB97;

type
  TTextBoxForm = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Image1: TImage;
    OKBtn: TToolbarButton97;
    procedure OKBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    WidthReserved, HeightReserved: Integer;
  public
    constructor Create(AOwner: TComponent; const nCaption, nLabel, nText: String; DlgType: TMsgDlgType); reintroduce; overload; virtual;
  end;

procedure ShowTextBox(const nCaption, nLabel, nText: String); overload;
procedure ShowTextBox(const nCaption, nLabel, nText: String; DlgType: TMsgDlgType); overload;
procedure ShowTextBox(const nCaption, nLabel: String; const nText: TStringList); overload;
procedure ShowTextBox(const nCaption, nLabel: String; const nText: TStringList; DlgType: TMsgDlgType); overload;

 {------------------------}

implementation

{$R *.DFM}

 {------------------------}

procedure ShowTextBox(const nCaption, nLabel, nText: String);
begin
  ShowTextBox(nCaption, nLabel, nText, mtCustom);
end;

procedure ShowTextBox(const nCaption, nLabel, nText: String; DlgType: TMsgDlgType);
var
  TextBoxForm: TTextBoxForm;
begin
  TextBoxForm:=TTextBoxForm.Create(Application, nCaption, nLabel, nText, DlgType);
  try
    TextBoxForm.ShowModal;
  finally
    TextBoxForm.Free;
  end;
end;

procedure ShowTextBox(const nCaption, nLabel: String; const nText: TStringList);
begin
  ShowTextBox(nCaption, nLabel, nText, mtCustom);
end;

procedure ShowTextBox(const nCaption, nLabel: String; const nText: TStringList; DlgType: TMsgDlgType);
var
  TextBoxForm: TTextBoxForm;
begin
  TextBoxForm:=TTextBoxForm.Create(Application, nCaption, nLabel, nText.Text, DlgType);
  try
    TextBoxForm.ShowModal;
  finally
    TextBoxForm.Free;
  end;
end;

var
  //Copied from Dialogs.pas
  IconIDs: array[TMsgDlgType] of PChar = (IDI_EXCLAMATION, IDI_HAND,
    IDI_ASTERISK, IDI_QUESTION, nil);

constructor TTextBoxForm.Create(AOwner: TComponent; const nCaption, nLabel, nText: String; DlgType: TMsgDlgType);
var
  IconID: PChar;
  ShowLabel, ShowIcon: Boolean;
  TMP: Integer;
begin
  inherited Create(AOwner);

  //Memo1 is the resizable component
  WidthReserved := ClientWidth - Memo1.Width;
  HeightReserved := ClientHeight - Memo1.Height;
  Constraints.MinWidth := Width - Memo1.Width - 8; //Set some minimum for the Memo1 width
  Constraints.MinHeight := Height - Memo1.Height - 19; //MinHeight of Memo1 is actually font-dependent

  Caption := nCaption;
  IconID := IconIDs[DlgType];
  ShowIcon := (IconID <> nil);
  if ShowIcon then
  begin
    Image1.Picture.Icon.Handle := LoadIcon(0, IconID);
    Memo1.Left := Memo1.Left + Image1.Width + 8;
    Memo1.Width := Memo1.Width - (Image1.Width + 8);
    WidthReserved := WidthReserved + (Image1.Width + 8);
    Constraints.MinWidth := Constraints.MinWidth + Image1.Width + 8;
    TMP := Height - (Memo1.Height - Image1.Height);
    if TMP > Constraints.MinHeight then
      Constraints.MinHeight := TMP;
  end
  else
    Image1.Visible := False;

  ShowLabel := (Length(nLabel) <> 0);
  if ShowLabel then
  begin
    Label1.Caption := nLabel;
    Memo1.Top := Memo1.Top + Label1.Height + 4;
    Memo1.Height := Memo1.Height - (Label1.Height + 4);
    HeightReserved := HeightReserved + Label1.Height + 4;
    Constraints.MinHeight := Constraints.MinHeight + Label1.Height + 4;
    if ShowIcon then
      Label1.Left := Label1.Left + Image1.Width + 8;
  end
  else
    Label1.Visible := False;

  Memo1.Text := nText;

  //Never cut into the OK-button
  TMP := OKBtn.Width + 8;
  if TMP > Constraints.MinWidth then
    Constraints.MinWidth := TMP;
end;

procedure TTextBoxForm.OKBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TTextBoxForm.FormResize(Sender: TObject);
begin
  Label1.Width := ClientWidth - WidthReserved;
  Memo1.Width := ClientWidth - WidthReserved;
  Memo1.Height := ClientHeight - HeightReserved;
  Image1.Top := Memo1.Top + ((Memo1.Height - Image1.Height) div 2);
  OKBtn.Left := (ClientWidth - OKBtn.Width) div 2;
  OKBtn.Top := ClientHeight - 37;
end;

end.
