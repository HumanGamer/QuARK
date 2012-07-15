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
Revision 1.11  2009/02/21 17:09:53  danielpharos
Changed all source files to use CRLF text format, updated copyright and GPL text.

Revision 1.10  2009/01/29 14:50:23  danielpharos
Removed 'index' dictspec from QFrames, and small fixes to get MD3 tagging working again (partially).

Revision 1.9  2008/07/17 14:47:57  danielpharos
Big (experimental) change to model bones, tags and boundframes

Revision 1.8  2007/09/10 10:24:15  danielpharos
Build-in an Allowed Parent check. Items shouldn't be able to be dropped somewhere where they don't belong.

Revision 1.7  2005/09/28 10:49:02  peter-b
Revert removal of Log and Header keywords

Revision 1.5  2001/03/20 21:36:53  decker_dk
Updated copyright-header

Revision 1.4  2001/02/18 20:03:46  aiv
attaching models to tags almost finished

Revision 1.3  2001/01/21 15:51:31  decker_dk
Moved RegisterQObject() and those things, to a new unit; QkObjectClassList.

Revision 1.2  2000/10/11 19:01:08  aiv
Small updates
}

unit QkModelTag;

interface

uses
  QkObjects, QkMdlObject, QkTagFrame;

type
  QModelTag = Class(QMdlObject)
  public
    class function TypeInfo: String; override;
    function IsAllowedParent(Parent: QObject) : Boolean; override;
    procedure ObjectState(var E: TEtatObjet); override;
    function GetTagFrameFromIndex(N: Integer) : QTagFrame;
    function GetTagFrameFromName(const nName: String) : QTagFrame;
  end;

implementation

uses QkObjectClassList, QkMiscGroup;

function QModelTag.IsAllowedParent(Parent: QObject) : Boolean;
begin
  if (Parent=nil) or (Parent is QMiscGroup) then
    Result:=true
  else
    Result:=false;
end;

class function QModelTag.TypeInfo;
begin
  TypeInfo:=':tag';
end;

procedure QModelTag.ObjectState(var E: TEtatObjet);
begin
  inherited;
  E.IndexImage:=iiModelTag;
end;

function QModelTag.GetTagFrameFromName(const nName: String) : QTagFrame;
begin
  Result:=FindSubObject(nName, QTagFrame, Nil) as QTagFrame;
end;

function QModelTag.GetTagFrameFromIndex(N: Integer) : QTagFrame;
var
  L: TQList;
begin
  if N<0 then
  begin
    Result:=Nil;
    Exit;
  end;
  L:=TQList.Create; try
  FindAllSubObjects('', QTagFrame, Nil, L);
  if N>=L.Count then
    Result:=Nil
  else
    Result:=L[N] as QTagFrame;
  finally
    L.Free;
  end;
end;

initialization
  RegisterQObject(QModelTag,  'a');
end.

