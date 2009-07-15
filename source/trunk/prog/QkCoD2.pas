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

{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.4  2009/02/21 17:06:18  danielpharos
Changed all source files to use CRLF text format, updated copyright and GPL text.

Revision 1.3  2008/10/09 12:58:48  danielpharos
Added decent Sylphis map file support, and removed some redundant 'uses'.

Revision 1.2  2008/10/09 11:28:38  danielpharos
Fix mistake.

Revision 1.1  2008/09/16 12:12:48  danielpharos
Added support for CoD2 iwd files.
}

unit QkCoD2;

interface

uses
  QkZip2, QkFileObjects, QkObjects;

type
  CoD2Pak = class(QZipPak)
        public
         class function TypeInfo: String; override;
         class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

implementation

uses QuarkX, QkObjectClassList;

{------------------------}

class function CoD2Pak.TypeInfo;
begin
 Result:='.iwd';
end;

class procedure CoD2Pak.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5147);
 Info.FileExt:=821;
end;

 {------------------------}

initialization
  RegisterQObject(CoD2Pak, 's');
end.

