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

unit FullScr1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PyMapView;

type
  TTwoMonitorsDlg = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    Src: TPyMapView;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure wmEraseBkgnd(var Msg: TMessage); message wm_EraseBkgnd;
  public
  end;

 {------------------------}

var
  TwoMonitorsDlg: TTwoMonitorsDlg;

procedure OpenTwoMonitorsDlg(nView: TPyMapView; Left: Boolean);

 {------------------------}

implementation

uses PyForms;

{$R *.DFM}

 {------------------------}

procedure OpenTwoMonitorsDlg(nView: TPyMapView; Left: Boolean);
const
 VMarginFrac = 8;
var
 Owner: TComponent;
 VMargin, VSize: Integer;
 P: TPoint;
begin
 TwoMonitorsDlg.Free;
 Owner:=GetParentPyForm(nView);
 if Owner=Nil then Owner:=Application;
 TwoMonitorsDlg:=TTwoMonitorsDlg.Create(Owner);
 VSize:=GetSystemMetrics(sm_CyScreen);
 VMargin:=VSize div VMarginFrac;
 TwoMonitorsDlg.Top:=VMargin;
 TwoMonitorsDlg.Height:=VSize-2*VMargin;
 if Left then
  begin
   TwoMonitorsDlg.Left:=1-TwoMonitorsDlg.Width;
   TwoMonitorsDlg.Cursor:=crLeftArrow;
  end
 else
  begin
   TwoMonitorsDlg.Left:=GetSystemMetrics(sm_CxScreen)-1;
   TwoMonitorsDlg.Cursor:=crRightArrow;
  end;
 TwoMonitorsDlg.Src:=nView;
{TwoMonitorsDlg.Visible:=True;
 if Owner is TForm then
  TForm(Owner).SetFocus;}
 TwoMonitorsDlg.Show;
 if GetCursorPos(P) then
  begin
   P.X:=TwoMonitorsDlg.Left;
   SetCursorPos(P.X, P.Y);
  end;
end;

 {------------------------}

procedure TTwoMonitorsDlg.CreateParams(var Params: TCreateParams);
begin
 inherited;
 with Params do
  begin
   Style:=WS_POPUP;
   ExStyle:=WS_EX_TRANSPARENT;
  end;
end;

procedure TTwoMonitorsDlg.wmEraseBkgnd(var Msg: TMessage);
begin
 Msg.Result:=1;
end;

procedure TTwoMonitorsDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=vk_Escape then
  Release
 else
  Src.DoKey3D(Key);
 Key:=0;
end;

procedure TTwoMonitorsDlg.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 SetFocus;
end;

procedure TTwoMonitorsDlg.FormDestroy(Sender: TObject);
begin
 TwoMonitorsDlg:=Nil;
 Src.ResetFullScreen(False);
end;

end.
