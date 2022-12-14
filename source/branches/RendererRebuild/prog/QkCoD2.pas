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
}

unit QkCoD2;

interface

uses
  SysUtils, Windows, Classes, QkZip2, QkFileObjects, QkObjects, QkText,
  QkJpg, QkTextures, Setup, QkWad, QkPixelSet;

type
  CoD2Pak = class(QZipPak)
        public
         class function TypeInfo: String; override;
         class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

implementation

uses QuarkX, QkExceptions, Game, Travail, QkObjectClassList, Logging;

{------------------------}

class function CoD2Pak.TypeInfo;
begin
 Result:='.iwd';
end;

class procedure CoD2Pak.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5147);
 Info.FileExt:=798;
end;

 {------------------------}

initialization
  RegisterQObject(CoD2Pak, 's');
end.

