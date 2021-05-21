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
unit QkQkl;

interface

uses
  Windows, Graphics, SysUtils, QkModel, QkModelRoot, QkComponent, QkFrame,
  QkModelBone, QkImages, QkObjects, QkFileObjects;

type
  QQkl = class(QModel)
  public
    class function TypeInfo: String; override;
    class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
  end;

implementation

uses QuarkX, QkObjectClassList, qkskindrawobject, Python, Game, QkExceptions,
  qkskingroup, qkframegroup, qkbonegroup, qkpcx, qktextures, qkmiscgroup;

class function QQkl.TypeInfo;
begin
  Result:='.qkl';
end;

class procedure QQkl.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
  inherited;
  Info.FileObjectDescriptionText:=LoadStr1(5143);
  Info.FileExt:=785;
  Info.QuArKFileObject:=True;
end;

initialization
  RegisterQObject(QQkl, 'w');
end.
