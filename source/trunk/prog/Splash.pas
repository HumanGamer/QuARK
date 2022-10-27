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
unit Splash;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  ExtCtrls, Messages;

type
  TSplashScreen = class;

  //PDisclaimerThread = ^TDisclaimerThread;
  TDisclaimerThread = class(TThread)
  private
    FlashCount: Cardinal;
    Form: TSplashScreen;
  protected
    procedure Execute; override;
  end;

  TSplashScreen = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender : TObject);
  private
    Disclaimer: TDisclaimerThread;
    DisclaimerFont: HFont;
    TextColor: COLORREF;
    function GetWaitHandle: THandle;
  public
    procedure UpdateDisclaimerColor;
    property WaitHandle: THandle read GetWaitHandle;
  end;

function OpenSplashScreen : TSplashScreen;

implementation

{$IFDEF Debug}
uses QConsts;
{$ENDIF}

const
  FLASH_COUNT = 3; //Must be larger than zero!
  AFTER_FLASH_DELAY = 1200; //in ms

{$R *.DFM}

 {-------------------}

procedure TDisclaimerThread.Execute;
var
  I, C: Integer;
begin
  I := FlashCount * 10 - 5;
  repeat
    C := (I + 5) mod 10;
    if C > 5 then
      C := 10 - C;
    //Form.TextColor := clWhite - ($203333 * C);
    Form.TextColor := clWhite - ($333300 * C);
    Synchronize(Form.UpdateDisclaimerColor);
    Sleep(50);
    Dec(I);
  until I < 0;
  Sleep(AFTER_FLASH_DELAY);
end;

function OpenSplashScreen : TSplashScreen;
begin
  Result:=TSplashScreen.Create(Application);
  //Result.FormStyle:=fsStayOnTop;
  Result.Show;
end;

 {-------------------}

procedure TSplashScreen.FormCreate(Sender: TObject);
var
  TextRect: TRect;
begin
  {$IF RTLVersion < 20}
  FDoubleBuffered:=True;
  {$IFEND}
  Image1.Picture.Bitmap.LoadFromResourceName(HInstance, 'QUARKLOGO');
  ClientWidth:=Image1.Width;
  ClientHeight:=Image1.Height;

  Disclaimer := TDisclaimerThread.Create(True);
  Disclaimer.Priority := tpHigher;
  Disclaimer.FlashCount := FLASH_COUNT;
  Disclaimer.Form := Self;

  {$IFDEF Debug}
  Label1.Caption := 'DEBUG ' + QuArKVersion + ' ' + QuArKMinorVersion;
  Label1.Font.Size := 22;
  Label1.Font.Style := Label1.Font.Style + [fsBold];
  {$ELSE}
  Label1.Caption := 'QuArK comes with ABSOLUTELY NO WARRANTY; this is free software, and you are welcome '
                  + 'to redistribute it under certain conditions. For details, see ''?'', ''About''.';
  Label1.Font.Size := 10;
  {$ENDIF}

  TextRect := ClientRect;
  InflateRect(TextRect, -7, -4);
  TextRect.Top := TextRect.Bottom - (10 + Label1.Font.Size);
  Label1.SetBounds(TextRect.Left, TextRect.Top, TextRect.Right - TextRect.Left, TextRect.Bottom - TextRect.Top);

  //Delphi doesn't have font searching, and the default font can't handle small text. So let's have Windows pick a fitting font.
  if fsBold in Font.Style then
    DisclaimerFont:=CreateFont(Label1.Font.Size, 0, 0, 0, FW_BOLD, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH or FF_SWISS, nil)
  else
    DisclaimerFont:=CreateFont(Label1.Font.Size, 0, 0, 0, FW_DONTCARE, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH or FF_SWISS, nil);
  Label1.Font.Handle:=DisclaimerFont;
end;

procedure TSplashScreen.FormActivate(Sender : TObject);
begin
  OnActivate := Nil; //Only run once
  Disclaimer.Resume;
end;

procedure TSplashScreen.FormClose(Sender : TObject; var Action : TCloseAction);
begin
  //We are never going to need to show this again, so let's free it completely.
  Action := caFree;
end;

procedure TSplashScreen.FormDestroy(Sender : TObject);
begin
  DeleteObject(DisclaimerFont);
  Disclaimer.Free;
end;

function TSplashScreen.GetWaitHandle: THandle;
begin
  Result:=Disclaimer.Handle;
end;

procedure TSplashScreen.UpdateDisclaimerColor;
begin
  //Set the changed font-color for the disclaimer text.
  Label1.Font.Color := TextColor;

  //This will post a message to the message loop, triggering a repaint.
  Label1.Invalidate;
end;

end.
