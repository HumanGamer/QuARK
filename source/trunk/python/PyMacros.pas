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

unit PyMacros;

interface

uses Graphics, QkObjects, PyForms, Quarkx, Python;

type
 QPyMacro = class(QObject)
            public
              class function TypeInfo: String; override;
              procedure ObjectState(var E: TEtatObjet); override;
              function RunMacro(const Macro: String) : Boolean;
              function RunMacro1(const Macro: String) : PyObject;
            end;

 {------------------------}

implementation

uses Travail;

 {------------------------}

class function QPyMacro.TypeInfo;
begin
 Result:=':py';
end;

procedure QPyMacro.ObjectState;
begin
 inherited;
 E.IndexImage:=iiPython;
 E.MarsColor:=clGreen;
end;

function QPyMacro.RunMacro(const Macro: String) : Boolean;
var
 o: PyObject;
begin
 ProgressIndicatorStart(0,0); try
 o:=RunMacro1(Macro);
 Result:=o<>Nil;
 Py_XDECREF(o);
 finally ProgressIndicatorStop; end;
 PythonCodeEnd;
end;

function QPyMacro.RunMacro1(const Macro: String) : PyObject;
begin
 Acces;
 Result:=CallMacro(@PythonObj, Macro);
end;

 {------------------------}

initialization
  RegisterQObject(QPyMacro, 'a');
end.
