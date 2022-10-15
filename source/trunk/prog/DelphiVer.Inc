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

// Versions of this unit are floating freely in several Delphi User Group forums out there I don't know the origin.
// It was added because it is a misnomer that a compiler constant is defined for that compiler and all newer versions. - SilverPaladin

// DanielPharos: For more complete list of defines, see: http://delphi.wikia.com/wiki/Borland_Compiler_Conditional_Defines

{$IFDEF VER80}
  {$DEFINE CompiledWithDelphi1}
  {$DEFINE Delphi1orNewerCompiler}
{$ENDIF}
{$IFDEF VER90}
  {$DEFINE CompiledWithDelphi2}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
{$ENDIF}
{$IFDEF VER100}
  {$DEFINE CompiledWithDelphi3}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
{$ENDIF}
{$IFDEF VER120}
  {$DEFINE CompiledWithDelphi4}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
{$ENDIF}
{$IFDEF VER130}
  {$DEFINE CompiledWithDelphi5}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
{$ENDIF}
{$IFDEF VER140}
  {$DEFINE CompiledWithDelphi6}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
{$ENDIF}
{$IFDEF VER150}
  {$DEFINE CompiledWithDelphi7}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
{$ENDIF}
{$IFDEF VER160}
  {$DEFINE CompiledWithDelphi8}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
{$ENDIF}
{$IFDEF VER170}
  {$DEFINE CompiledWithDelphi2005}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
{$ENDIF}
{$IFDEF VER185}
  {$DEFINE CompiledWithDelphi2006}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
{$ENDIF}
{$IFDEF VER185}
  {$DEFINE CompiledWithDelphi2007}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
{$ENDIF}
{$IFDEF VER190}
  {$DEFINE CompiledWithDelphi2007}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
{$ENDIF}
{$IFDEF VER200}
  {$DEFINE CompiledWithDelphi2009}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
{$ENDIF}
{$IFDEF VER210}
  {$DEFINE CompiledWithDelphi2010}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
{$ENDIF}
{$IFDEF VER220}
  {$DEFINE CompiledWithDelphiXE}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
{$ENDIF}
{$IFDEF VER230}
  {$DEFINE CompiledWithDelphiXE2}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
{$ENDIF}
{$IFDEF VER240}
  {$DEFINE CompiledWithDelphiXE3}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
{$ENDIF}
{$IFDEF VER250}
  {$DEFINE CompiledWithDelphiXE4}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
{$ENDIF}
{$IFDEF VER260}
  {$DEFINE CompiledWithDelphiXE5}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
{$ENDIF}
{$IFDEF VER270}
  {$DEFINE CompiledWithDelphiXE6}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
{$ENDIF}
{$IFDEF VER280}
  {$DEFINE CompiledWithDelphiXE7}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
{$ENDIF}
{$IFDEF VER290}
  {$DEFINE CompiledWithDelphiXE8}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
{$ENDIF}
{$IFDEF VER300}
  {$DEFINE CompiledWithDelphi10_0}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
  {$DEFINE Delphi10_0orNewerCompiler}
{$ENDIF}
{$IFDEF VER310}
  {$DEFINE CompiledWithDelphi10_1}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
  {$DEFINE Delphi10_0orNewerCompiler}
  {$DEFINE Delphi10_1orNewerCompiler}
{$ENDIF}
{$IFDEF VER320}
  {$DEFINE CompiledWithDelphi10_2}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
  {$DEFINE Delphi10_0orNewerCompiler}
  {$DEFINE Delphi10_1orNewerCompiler}
  {$DEFINE Delphi10_2orNewerCompiler}
{$ENDIF}
{$IFDEF VER330}
  {$DEFINE CompiledWithDelphi10_3}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
  {$DEFINE Delphi10_0orNewerCompiler}
  {$DEFINE Delphi10_1orNewerCompiler}
  {$DEFINE Delphi10_2orNewerCompiler}
  {$DEFINE Delphi10_3orNewerCompiler}
{$ENDIF}
{$IFDEF VER340}
  {$DEFINE CompiledWithDelphi10_4}
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
  {$DEFINE Delphi10_0orNewerCompiler}
  {$DEFINE Delphi10_1orNewerCompiler}
  {$DEFINE Delphi10_2orNewerCompiler}
  {$DEFINE Delphi10_3orNewerCompiler}
  {$DEFINE Delphi10_4orNewerCompiler}
{$ENDIF}
{$IFDEF VER350}
  {$DEFINE CompiledWithDelphi11} //11.0 or 11.1 or 11.2
  {$DEFINE Delphi1orNewerCompiler}
  {$DEFINE Delphi2orNewerCompiler}
  {$DEFINE Delphi3orNewerCompiler}
  {$DEFINE Delphi4orNewerCompiler}
  {$DEFINE Delphi5orNewerCompiler}
  {$DEFINE Delphi6orNewerCompiler}
  {$DEFINE Delphi7orNewerCompiler}
  {$DEFINE Delphi8orNewerCompiler}
  {$DEFINE Delphi2005orNewerCompiler}
  {$DEFINE Delphi2006orNewerCompiler}
  {$DEFINE Delphi2007orNewerCompiler}
  {$DEFINE Delphi2009orNewerCompiler}
  {$DEFINE Delphi2010orNewerCompiler}
  {$DEFINE DelphiXEorNewerCompiler}
  {$DEFINE DelphiXE2orNewerCompiler}
  {$DEFINE DelphiXE3orNewerCompiler}
  {$DEFINE DelphiXE4orNewerCompiler}
  {$DEFINE DelphiXE5orNewerCompiler}
  {$DEFINE DelphiXE6orNewerCompiler}
  {$DEFINE DelphiXE7orNewerCompiler}
  {$DEFINE DelphiXE8orNewerCompiler}
  {$DEFINE Delphi10_0orNewerCompiler}
  {$DEFINE Delphi10_1orNewerCompiler}
  {$DEFINE Delphi10_2orNewerCompiler}
  {$DEFINE Delphi10_3orNewerCompiler}
  {$DEFINE Delphi10_4orNewerCompiler}
  {$DEFINE Delphi11orNewerCompiler}
{$ENDIF}
