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
Revision 1.3  2001/03/20 21:41:57  decker_dk
Updated copyright-header

Revision 1.2  2000/06/03 10:46:49  alexander
added cvs headers
}


unit TbTexture;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
     QkObjects, QkFileObjects, Forms, QkForm;

 {------------------------}

function GetTextureToolbar(nOwner: TComponent) : TWinControl;
function MakeTextureToolbar(nOwner: TCustomForm; LocalAction: Integer) : TWinControl;
procedure DynamicTextureToolbar(Tex: TWinControl; nLinks: TList);

 {------------------------}

implementation

uses Setup, FormCfg, Undo, Quarkx, QkFormCfg;

const
 txName = '_FORMTex';

type
 TTbTex = class(TIconToolbox)
          protected
           {Link: QObject;}
            FormCfg1: TFormCfg;
            ObjFormCfg: QFormCfg;
            destructor Destroy; override;
           {procedure Unlink;}
            procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
            procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
            procedure Activate; override;
          end;

 {------------------------}

function GetTextureToolbar(nOwner: TComponent) : TWinControl;
var
 C: TComponent;
begin
 C:=nOwner.FindComponent(txName);
 if C<>Nil then
  Result:=C as TTbTex
 else
  Result:=Nil;
end;

function MakeTextureToolbar(nOwner: TCustomForm; LocalAction: Integer) : TWinControl;
var
 ClipRect: TRect;
 SetupQrk: QFileObject;
begin
 with nOwner.ClientRect do
  begin
   ClipRect.TopLeft:=nOwner.ClientToScreen(TopLeft);
   ClipRect.BottomRight:=nOwner.ClientToScreen(BottomRight);
  end;
 Result:=GetTextureToolbar(nOwner);
 if Result=Nil then
  begin
   Result:=TTbTex.CreateNew(nOwner);
   with ClipRect.BottomRight do
    Result.SetBounds(X-200, Y-370, 180, 270);
   Result.Name:=txName;
  {Result.CanDockLeftRight:=False;
   Result.CanDockTopBottom:=False;
   Result.FreeSizing:=True;}
   with TTbTex(Result) do
    begin
     BorderStyle:=bsSizeToolWin;
     Caption:=LoadStr1(5388);
     MarsCap.ActiveBeginColor:=clGreen;
     MarsCap.ActiveEndColor:=clOlive;
     SetFormIcon(iiTexParams);
     FormCfg1:=TFormCfg.Create(Result);
     FormCfg1.SetBounds(0,0,180,170);
     FormCfg1.Parent:=Result;
     FormCfg1.TxtSpec:=5389;
     FormCfg1.TxtArg:=5390;
     FormCfg1.Delta:=0.39;
     FormCfg1.ActionChanging:=596;
     FormCfg1.ActionNiveau:=LocalAction;
     SetupQrk:=MakeAddOnsList; try
     ObjFormCfg:=SetupQrk.FindSubObject('TextureFlags', QFormCfg, QFileObject)
      as QFormCfg;
     ObjFormCfg.AddRef(+1);
     finally SetupQrk.AddRef(-1); end;
    end;
  end;
{PostMessage(Result.Handle, CM_MOUSELEAVE, 0, 0);}
(* with TTbTex(Result) do
  begin
  {Parent:=nOwner;
   Unlink;}
  end; *)
end;

procedure DynamicTextureToolbar(Tex: TWinControl; nLinks: TList);
begin
 with TTbTex(Tex) do
  begin
  {Unlink;}
   ObjFormCfg.Acces;
  {Link:=nLink;
   Link.AddRef(+1);}
    { reads the flags from the object }
   FormCfg1.Show;
   FormCfg1.SetFormCfg(nLinks, ObjFormCfg);
  end;
end;

 {------------------------}

destructor TTbTex.Destroy;
begin
{Unlink;}
{Inc(DisableArrangeControls);}
 FormCfg1.Free;
 if ObjFormCfg<>Nil then ObjFormCfg.AddRef(-1);
 inherited;
end;

(*procedure TTbTex.Unlink;
begin
 FormCfg1.Hide;
 FormCfg1.SetFormCfg(Nil, Nil, False, False);
 if Link<>Nil then
  begin
   Link.AddRef(-1);
   Link:=Nil;
  end;
end;*)

procedure TTbTex.CMMouseEnter(var Message: TMessage);
begin
 inherited;
 if (Owner as TForm).Active and CanFocus then
  SetFocus;
end;

procedure TTbTex.CMMouseLeave(var Message: TMessage);
var
 P: TPoint;
begin
 inherited;
 if Active then
  begin
   GetCursorPos(P);
   if not PtInRect(BoundsRect, P) and (Owner as TForm).CanFocus then
    if TForm(Owner).Visible then
     TForm(Owner).SetFocus
    else
     Release;
  end;
end;

procedure TTbTex.Activate;
begin
 inherited;
 PostMessage(Handle, cm_MouseLeave, 0, 0);
end;

 {------------------------}

end.
