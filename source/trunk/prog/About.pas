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
  ExtCtrls, Registry, Dialogs, QkForm, QkObjects, Reg2;

type
  TAboutBox = class(TQkForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName1: TLabel;
    ProductName2: TLabel;
    ProductName3: TLabel;
    ProductName4: TLabel;
    ProductName5: TLabel;
    ProductName6: TLabel;
    Version: TLabel;
    OKButton: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Bevel1: TBevel;
    Label1: TLabel;
    WebsiteAddress: TLabel;
    Copyright: TLabel;
    Memo1: TMemo;
    UsedCompilerLabel: TLabel;
    RepositoryAddress: TLabel;
    ForumAddress: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
  private
    Event: THandle;
  public
  end;

function OpenSplashScreen : TForm;
procedure OpenAboutBox;
function DisclaimerThread(F: TForm): THandle;

implementation

uses Quarkx, PyProcess, QkConsts, ExtraFunctionality;

type
  PDisclaimerInfo = ^TDisclaimerInfo;
  TDisclaimerInfo = record
    H: HWnd;
    R: TRect;
    FlashCount: Cardinal;
    Delay: Cardinal;
    TextSize: Integer;
    Text: array[0..255] of Char;
    Event: THandle;
  end;
  TSplashScreen = class(TForm)
    procedure RedrawSplashScreen(Sender : Tobject);
  end;

const
  MAX_DELAY = 10;
  MIN_FLASH_COUNT = 2; //Must be larger than zero!

var RedrawDisclaimer: Boolean;

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
      DecodeEnregistrement := True;
    end;
  end;
end;

function DisclaimerProc(Info: PDisclaimerInfo): LongInt; stdcall;
var
  DC: HDC;
  I, C: Integer;
  Font, Font1: HFont;
  SkipDelay: Boolean;
begin
  InflateRect(Info^.R, -7, -4);
  Info^.R.Top := Info^.R.Bottom - 20;
  {X:=(Info^.R.Left+Info^.R.Right) div 2;
   Y:=Info^.R.Bottom - 7;}
  if Info^.TextSize >= 16 then
    I := FW_BOLD
  else
    I := 0;
  Font := CreateFont(Info^.TextSize, 0, 0, 0, I, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH or FF_SWISS, nil);
  DC := GetDC(Info^.H);
  try
    Font1 := SelectObject(DC, Font);
    SetBkColor(DC, clWhite);
    SetBkMode(DC, TRANSPARENT);
    {SetTextAlign(DC, TA_BOTTOM or TA_CENTER);}
    SkipDelay := false;
    I := Info^.FlashCount;
    if I < MIN_FLASH_COUNT then
      I := MIN_FLASH_COUNT;
    I := I * 10 - 5;
    repeat
      C := (I + 5) mod 10;
      if C > 5 then
        C := 10 - C;
      {SetTextColor(DC, clWhite - ($203333 * C));}
      SetTextColor(DC, clWhite - ($333300 * C));
      DrawText(DC, Info^.Text, -1, Info^.R, DT_CENTER or DT_NOPREFIX or DT_WORDBREAK);
      GDIFlush;
      if Info^.Event = 0 then
        Sleep(50)
      else
        if WaitForSingleObject(Info^.Event, 50) <> WAIT_TIMEOUT then
        begin
          SkipDelay := true;
          Break;
        end;
      Dec(I);
    until I < 0;
    if not SkipDelay then
    begin
      if Info^.Event = 0 then
      begin
        I := Info^.Delay;
        if I > MAX_DELAY then
          I := MAX_DELAY;
        I:=I*10;
        repeat
          if RedrawDisclaimer then
          begin
            RedrawDisclaimer:=false;
            DrawText(DC, Info^.Text, -1, Info^.R, DT_CENTER or DT_NOPREFIX or DT_WORDBREAK);
            GDIFlush;
          end;
          Sleep(100);
          Dec(I);
        until I < 0;
      end
      else
      begin
        repeat
          if RedrawDisclaimer then
          begin
            RedrawDisclaimer:=false;
            DrawText(DC, Info^.Text, -1, Info^.R, DT_CENTER or DT_NOPREFIX or DT_WORDBREAK);
            GDIFlush;
          end;
          if WaitForSingleObject(Info^.Event, 100) <> WAIT_TIMEOUT then
            SkipDelay := true;
        until SkipDelay;
      end;
    end;
    SelectObject(DC, Font1);
  finally
    ReleaseDC(Info^.H, DC);
    DeleteObject(Font);
    if Info^.Event <> 0 then
      CloseHandle(Info^.Event);
    Dispose(Info);
  end;
  Result := 0;
end;

function GetDisclaimer(Info: PDisclaimerInfo): THandle;
var
  Dummy: DWORD;
  S: string;
begin
  Info^.TextSize := 10;
  Info^.FlashCount := MIN_FLASH_COUNT;
  Info^.Delay := 2;
  S := 'QuArK comes with ABSOLUTELY NO WARRANTY; this is free software, and you are welcome '
       + 'to redistribute it under certain conditions. For details, see ''?'', ''About''.';
  {$IFDEF Debug}
  S := 'DEBUG ' + QuArKVersion + ' ' + QuArKMinorVersion;
  Info^.TextSize := 22;
  {$ENDIF}
  StrPCopy(Info^.Text, S); //DanielPharos: S must NOT be longer than 255 characters!
  Result := CreateThread(nil, 0, @DisclaimerProc, Info, 0, Dummy);
  SetThreadPriority(Result, THREAD_PRIORITY_ABOVE_NORMAL);
end;

function DisclaimerThread(F: TForm): THandle;
var
  Info: PDisclaimerInfo;
begin
  New(Info);
  Info^.H := F.Handle;
  Info^.R := F.ClientRect;
  Info^.Event := 0;
  Result := GetDisclaimer(Info);
end;

function OpenSplashScreen : TForm;
var
 SplashScreen: TSplashScreen;
 Image1: TImage;
begin
 SplashScreen:=TSplashScreen.CreateNew(Application);
 SplashScreen.Position:=poScreenCenter;
 SplashScreen.BorderStyle:=bsNone;
 SplashScreen.Color:=clWhite;
 {SplashScreen.FormStyle:=fsStayOnTop;}
 Image1:=TImage.Create(SplashScreen);
 Image1.Parent:=SplashScreen;
 Image1.Picture.Bitmap.LoadFromResourceName(HInstance, 'QUARKLOGO');
 Image1.AutoSize:=True;
 SplashScreen.ClientWidth:=Image1.Width;
 SplashScreen.ClientHeight:=Image1.Height;
 SplashScreen.OnPaint:=SplashScreen.RedrawSplashScreen;
 SplashScreen.Show;
 SplashScreen.Update;
 Result:=TForm(SplashScreen);
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
{* DanielPharos: Commented out thread-safe date-convertion with the asterix.
  This because that is Delphi 7+, so it breaks compilation on Delphi 6.
var
  DateFormat: TFormatSettings;}
begin
  Version.Caption := QuarkVersion + ' ' + QuArKMinorVersion;
  {*GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, DateFormat);}
  UsedCompilerLabel.Caption := QuArKUsedCompiler + ' on ' + DateToStr(QuArKCompileDate{*, DateFormat});
  Copyright.Caption := QuArKCopyright;
  {$IFDEF Debug}
  Version.Caption := Version.Caption + '  DEBUG VERSION';
  {$ENDIF}
  WebsiteAddress.Caption := QuArKWebsite;
  RepositoryAddress.caption := QuArKRepository;
  ForumAddress.caption := QuArKForum;
  ProgramIcon.Picture.Icon.Handle := LoadImage(HInstance, 'MAINICON', image_Icon, 0, 0, 0);
  Image1.Picture.Bitmap.LoadFromResourceName(HInstance, 'QUARKLOGO');

  Caption := LoadStr1(5612);
  MarsCap.ActiveBeginColor := $A08000;
  MarsCap.ActiveEndColor := clYellow;
  SetFormIcon(iiQuArK);

  Memo1.Text :=
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
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
var
  S: string;
  Reg: TRegistry;
begin
  S := Edit1.Text;
  if DecodeEnregistrement(S) then
  begin
    {with g_Form1 do
      begin
       PanelQM1.Free;
       PanelQM1:=Nil;
      end;}
    MessageDlg(FmtLoadStr1(226, [S]), mtInformation, [mbOk], 0);
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\Software\Armin Rigo\QuakeMap', True);
      Reg.WriteString('Registered', Edit1.Text);
    finally
      Reg.Free;
    end;
  end;
end;

procedure TAboutBox.FormActivate(Sender: TObject);
var
  Info: PDisclaimerInfo;
begin
  OnActivate := nil;
  Event := CreateEvent(nil, False, False, nil);
  New(Info);
  Info^.H := Panel1.Handle;
  Info^.R := Image1.BoundsRect;
  Info^.Event := 0;
  DuplicateHandle(GetCurrentProcess, Event, GetCurrentProcess, @Info^.Event, 0, False, DUPLICATE_SAME_ACCESS);
  CloseHandle(GetDisclaimer(Info));
end;

procedure TAboutBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Event <> 0 then
  begin
    SetEvent(Event);
    CloseHandle(Event);
    Event:=0;
    // Strange error if 'event' isn't set to 0 after call to CloseHandle(..)
    // DanielPharos: That's because this procedure is called multiple times !!!
  end;
end;

procedure TAboutBox.FormPaint(Sender: TObject);
begin
  RedrawDisclaimer:=true;
end;

 {-------------------}

procedure TSplashScreen.RedrawSplashScreen(Sender : Tobject);
begin
 RedrawDisclaimer:=true;
end;

end.

