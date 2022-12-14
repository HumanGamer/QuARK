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
Revision 1.9  2007/02/09 10:44:17  danielpharos
Fixes for memory leaks

Revision 1.8  2005/09/28 10:48:32  peter-b
Revert removal of Log and Header keywords

Revision 1.6  2003/03/12 12:50:18  decker_dk
Fixed a minor problem in TTexHintWindow.ActivateHint(), in case GlobalFindTexture() returned NIL.

Revision 1.5  2001/03/20 21:41:41  decker_dk
Updated copyright-header

Revision 1.4  2000/07/18 19:38:01  decker_dk
Englishification - Big One This Time...

Revision 1.3  2000/06/03 10:46:49  alexander
added cvs headers
}


unit TexHints;

interface

uses Windows, SysUtils, Classes, Graphics, Controls, Forms,
     QkObjects, QkPixelSet, QkTextures;
type
  TTexHintWindow = class(THintWindow)
  protected
    Textures: TQList;
    procedure Paint; override;
  public
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    destructor Destroy; override;
  end;

implementation

uses Setup, Game, Travail;

procedure TTexHintWindow.Paint;
var
{Data: String;}
 I, X: Integer;
 Texture1: QPixelSet;
 PSD: TPixelSetDescription;
begin
 if Textures=Nil then
  inherited
 else
  begin
   X:=0;
   for I:=0 to Textures.Count-1 do
    begin
     Texture1:=Textures[I] as QPixelSet;
     PSD:=Texture1.Description; try
     PSD.Paint(Canvas.Handle, X, 0);
     Inc(X, PSD.Size.X+1);
     finally PSD.Done; end;
    end;
  end;
end;

procedure TTexHintWindow.ActivateHint(Rect: TRect; const AHint: string);
var
 Tex: QPixelSet;
 Size: TPoint;
 S: String;
 J: Integer;
 L: TQList;
 nRect: TRect;
begin
 Textures.Free;
 Textures:=Nil;
 if Copy(AHint, 1, 4) = 'TEX?' then
  begin
   S:=Copy(AHint, 5, MaxInt);
   if (S<>'') and (S[Length(S)]=';') then
    SetLength(S, Length(S)-1);
   L:=TQList.Create;
   try
    nRect.Left:=Rect.Left;
    nRect.Top:=Rect.Top;
    nRect.Right:=nRect.Left;
    nRect.Bottom:=nRect.Top;
    ProgressIndicatorStart(0,0);
    try
      while S<>'' do
       begin
        J:=Pos(';', S);
        if J=0 then J:=Length(S)+1;
        Tex:=GlobalFindTexture(Copy(S, 1, J-1), Nil);
        if Tex<>Nil then
        begin
          Tex.LoadPixelSet;
          Size:=Tex.GetSize;
          Inc(nRect.Right, Size.X+1);
          if nRect.Bottom-nRect.Top < Size.Y then
           nRect.Bottom:=nRect.Top + Size.Y;
          L.Add(Tex);
        end;
        System.Delete(S, 1, J);
       end;
    finally
      ProgressIndicatorStop;
    end;
    if nRect.Right=nRect.Left then Abort;
    Textures:=L;
    L:=Nil;
    inherited ActivateHint(nRect, '');
    Color:=clBlack;
    Exit;
   except
    L.Free;
   end;
   inherited ActivateHint(Rect, S);
  end
 else
  inherited;
end;

destructor TTexHintWindow.Destroy;
begin
 Textures.Free;
 inherited;
end;

initialization
  HintWindowClass:=TTexHintWindow;
  {Application.ShowHint:=False;}
  Application.ShowHint:=True;
end.
