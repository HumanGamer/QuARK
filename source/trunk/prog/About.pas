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
unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  ExtCtrls, Dialogs, QkForm, QkObjects, ComCtrls, Grids;

type
  TAboutBox = class(TQkForm)
    OKButton: TButton;
    Edit1: TEdit;
    Logo: TImage;
    Registration: TLabel;
    LabelLogo: TLabel;
    Bevel1: TBevel;
    ProgramIcon: TImage;
    ProductName1: TLabel;
    ProductName2: TLabel;
    ProductName3: TLabel;
    ProductName4: TLabel;
    ProductName5: TLabel;
    ProductName6: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    License: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    WebsiteAddress: TLabel;
    RepositoryAddress: TLabel;
    ForumAddress: TLabel;
    UsedCompilerLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  protected
    procedure MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean); override;
    procedure MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean); override;
  end;

procedure OpenAboutBox;
procedure ProcessRegistration;

implementation

uses Messages, Registry2, Qk1, Quarkx, QkConsts;

const
  RegistrationKey = '\Software\Armin Rigo\QuakeMap';
  RegistrationValueName = 'Registered';

  LabelSpacing = 2;

var
  RegisteredTo: String;

{$R *.DFM}

 {-------------------}

function DecodeEnregistrement(var S: string): Boolean;
var
  I: Integer;
  Code, Code2, Code3: Byte;
begin
  Result := False;
  if Length(S) > 2 then
  begin
    Code := 43;
    Code2 := 1;
    for I := 1 to Length(S) do
    begin
      Code3 := Code2;
      Code2 := Code;
      Code := ((Ord(S[I]) - 32) + Code2 - Code3 + 140) mod 95;
      S[I] := Chr(Code + 32);
    end;
    if (Code2 = 21) and (Code = 7) then
    begin
      SetLength(S, Length(S) - 2);
      Result := True;
    end;
  end;
end;

procedure ProcessRegistration;
var
  S: String;
  Reg: TRegistry2;
begin
  if RegisteredTo<>'' then
    Exit;
  Reg := TRegistry2.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if not Reg.OpenKey(RegistrationKey, False) then Exit;
    try
      S:=Reg.ReadString(RegistrationValueName);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  if DecodeEnregistrement(S) then
  begin
    RegisteredTo:=S;
    if g_Form1.Caption = 'QuArK Explorer' then
      g_Form1.Caption:=g_Form1.Caption+' [Registered]';
  end;
end;

procedure OpenAboutBox;
begin
 with TAboutBox.Create(Application) do
  try
   ShowModal
  finally
   Free;
  end;
end;

 {-------------------}

procedure TAboutBox.FormCreate(Sender: TObject);
{* DanielPharos: Commented out thread-safe date-conversion with the asterix.
  This because that is Delphi 7+, so it breaks compilation on Delphi 6.
var
  DateFormat: TFormatSettings;}
begin
  Caption := LoadStr1(5612);
  MarsCap.ActiveBeginColor := $A08000;
  MarsCap.ActiveEndColor := clYellow;
  SetFormIcon(iiQuArK);
  inherited;
  OnMouseWheelDown:=MouseWheelDown;
  OnMouseWheelUp:=MouseWheelUp;

  //Delphi 7 doesn't support setting only some font properties, so we have to override them.
  Registration.Font.Name:=Font.Name;
  ProductName1.Font.Name:=Font.Name;
  ProductName2.Font.Name:=Font.Name;
  ProductName3.Font.Name:=Font.Name;
  ProductName4.Font.Name:=Font.Name;
  ProductName5.Font.Name:=Font.Name;
  ProductName6.Font.Name:=Font.Name;

  Logo.Picture.Bitmap.LoadFromResourceName(HInstance, 'QUARKLOGO');
  if RegisteredTo<>'' then
  begin
    Registration.Caption:=FmtLoadStr1(5822, [RegisteredTo]);
    Registration.Visible:=True;
  end;

  ProgramIcon.Picture.Icon.Handle := LoadImage(HInstance, 'MAINICON', image_Icon, 0, 0, 0);
  Version.Caption := QuarkVersion + ' ' + QuArKMinorVersion;
  {$IFDEF Debug}
  Version.Caption := Version.Caption + '  DEBUG VERSION';
  {$ENDIF}
  Copyright.Caption := QuArKCopyright;

  License.Text :=
      'QuArK comes with ABSOLUTELY NO WARRANTY; for details, see below. '
    + 'This is free software, and you are welcome to redistribute it under certain conditions; '
    + 'for details, see below.'
    + #13#10#13#10
    + 'QuArK is protected by the GNU General Public License; text below is part of this Licence. '
    + 'The complete Licence can be found in the file COPYING.TXT.'
    + #13#10#13#10
    + 'NO WARRANTY'
    + #13#10#13#10
    + 'BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT '
    + 'PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER '
    + 'PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT '
    + 'LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO '
    + 'THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE '
    + 'COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION. '
    + #13#10#13#10
    + 'IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY '
    + 'OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, '
    + 'INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE '
    + 'THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED '
    + 'BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR '
    + 'OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.'
    + #13#10#13#10
    + 'REDISTRIBUTION'
    + #13#10#13#10
    + 'You may copy and distribute verbatim copies of the Program''s '
    + 'source code as you receive it, in any medium, provided that you '
    + 'conspicuously and appropriately publish on each copy an appropriate '
    + 'copyright notice and disclaimer of warranty; keep intact all the '
    + 'notices that refer to this License and to the absence of any warranty; '
    + 'and give any other recipients of the Program a copy of this License '
    + 'along with the Program.'
    + #13#10#13#10
    + 'You may charge a fee for the physical act of transferring a copy, and '
    + 'you may at your option offer warranty protection in exchange for a fee.';

  WebsiteAddress.Caption := QuArKWebsite;
  RepositoryAddress.Caption := QuArKRepository;
  ForumAddress.Caption := QuArKForum;
  {*GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, DateFormat);}
  UsedCompilerLabel.Caption := FmtLoadStr1(5823, [QuArKUsedCompiler, DateToStr(QuArKCompileDate{*, DateFormat})]);

  //Reposition the labels
  WebsiteAddress.Left := Label1.BoundsRect.Right + LabelSpacing;
  RepositoryAddress.Left := Label2.BoundsRect.Right + LabelSpacing;
  ForumAddress.Left := Label3.BoundsRect.Right + LabelSpacing;
  UsedCompilerLabel.Left := Label4.BoundsRect.Right + LabelSpacing;

  ProductName2.Left:=ProductName1.BoundsRect.Right;
  ProductName3.Left:=ProductName2.BoundsRect.Right + 6;
  ProductName4.Left:=ProductName3.BoundsRect.Right;
  ProductName5.Left:=ProductName4.BoundsRect.Right + 6;
  ProductName6.Left:=ProductName5.BoundsRect.Right;
end;

procedure TAboutBox.MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  License.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  Handled := true;
end;

procedure TAboutBox.MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  License.Perform(WM_VSCROLL, SB_LINEUP, 0);
  Handled := true;
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
var
  S: string;
  Reg: TRegistry2;
begin
  S := Edit1.Text;
  if DecodeEnregistrement(S) then
  begin
    MessageDlg(FmtLoadStr1(226, [S]), mtInformation, [mbOk], 0);
    Reg := TRegistry2.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if not Reg.OpenKey(RegistrationKey, True) then Exit;
      try
        Reg.WriteString(RegistrationValueName, Edit1.Text);
      finally
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;
    ProcessRegistration;
  end;
end;

end.
