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

unit QkFormCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QkForm, QkObjects, QkFileObjects, TB97, QkFormVw, QkQuakeCtx;

type
 QInternal = class(QFormObject)
             public
               class function TypeInfo: String; override;
               function GetConfigStr1: String; override;
               procedure ObjectState(var E: TEtatObjet); override;
             end;
 QFormContext = class(QQuakeCtx)
             protected
               function GetConfigStr1: String; override;
             public
               class function TypeInfo: String; override;
               class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
               function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
               procedure ObjectState(var E: TEtatObjet); override;
             end;
 QFormCfg = class(QFormObject)
            public
              class function TypeInfo: String; override;
              function GetConfigStr1: String; override;
              function IsExplorerItem(Q: QObject) : TIsExplorerItem; override;
              procedure ObjectState(var E: TEtatObjet); override;
            end;

implementation

uses QkUnknown, Undo, TbPalette, Toolbar1, ToolBox1,
     Setup, QkInclude, QkMacro, QkImages, QkTextures,
     Python, Quarkx, PyMacros, PyToolbars, PyForms,
     QkPixelSet, QkObjectClassList;

class function QFormCfg.TypeInfo: String;
begin
 TypeInfo:=':form';
end;

function QFormCfg.GetConfigStr1: String;
begin
 Result:='FormCFG';
end;

procedure QFormCfg.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiForm;
end;

function QFormCfg.IsExplorerItem(Q: QObject) : TIsExplorerItem;
begin
  Result:=ieResult[Q is QInternal];
end;

 {------------------------}

class function QInternal.TypeInfo;
begin
  Result:=':';
end;

function QInternal.GetConfigStr1: String;
begin
 Result:='SpecArgForm';
end;

procedure QInternal.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiFormElement;
end;

 {------------------------}

class function QFormContext.TypeInfo;
begin
 TypeInfo:='.fctx';
end;

function QFormContext.GetConfigStr1: String;
begin
 Result:='FormContext';
end;

function QFormContext.IsExplorerItem(Q: QObject) : TIsExplorerItem;
begin
  Result:=ieResult[(Q is QFormCfg)]
end;

class procedure QFormContext.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.FileObjectDescriptionText:=LoadStr1(5179);
{Info.FileExt:=779;
 Info.WndInfo:=[wiWindow];}
end;

procedure QFormContext.ObjectState(var E: TEtatObjet);
begin
 inherited;
 E.IndexImage:=iiFormContext;
end;

initialization
  RegisterQObject(QFormCfg, 'a');
  RegisterQObject(QInternal, 'a');
  RegisterQObject(QFormContext, 'a');
end.
