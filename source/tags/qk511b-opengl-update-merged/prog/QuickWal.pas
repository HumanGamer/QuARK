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

unit QuickWal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB97, StdCtrls, ExtCtrls, QkForm;

type
  TQuickWalParser = class(TQkForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    Label3: TLabel;
    OkBtn: TToolbarButton97;
    CancelBtn: TToolbarButton97;
    procedure CancelBtnClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
    Toolbox: TForm;
  end;

implementation

uses QkGroup, Game, QkTextures, QkObjects, QkWad, QkExplorer, 
  Quarkx, Travail, ToolBox1, QkPak, QkFileObjects, QkHL, ToolBoxGroup,
  Setup;

{$R *.DFM}

procedure TQuickWalParser.CancelBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TQuickWalParser.ListBox1Click(Sender: TObject);
begin
 OkBtn.Enabled:=ListBox1.ItemIndex>=0;
end;

function Link1(var ResultFolder: QObject; const FolderName, Name, Spec, Arg: String) : QObject;
begin
 if ResultFolder=Nil then
  ResultFolder:=QTextureList.Create(Copy(FolderName, 1, Length(FolderName)-1), Nil);
 Result:=QTextureLnk.Create(FolderName+Name, ResultFolder);
 Result.Specifics.Values[Spec]:=Arg;
 ResultFolder.SousElements.Add(Result);
end;

procedure LinkFolder(Q: QObject; var Result: QObject; const FolderName: String);
begin
 if Q<>Nil then
  begin
   if Result=Nil then
    Result:=QToolBoxGroup.Create(FolderName, Nil);
   Q.FParent:=Result;
   Result.SousElements.Add(Q);
  end;
end;

function TryToLink1(var ResultFolder: QObject; const Name, FolderName, Base: String; Loaded: QObject) : Boolean;
var
 I: Integer;
 Folder, Q, Tex: QObject;
begin
 Result:=False;
 if CompareText(ExtractFileExt(Name), '.wal') = 0 then
  Link1(ResultFolder, FolderName, Copy(Name, 1, Length(Name)-4), 'w', Base)
 else if CompareText(ExtractFileExt(Name), '.m8') = 0 then
  Link1(ResultFolder, FolderName, Copy(Name, 1, Length(Name)-3), 'm', Base)
 else if CompareText(ExtractFileExt(Name), '.swl') = 0 then
  Link1(ResultFolder, FolderName, Copy(Name, 1, Length(Name)-4), 'i', Base)
 else if CompareText(ExtractFileExt(Name), '.wad') = 0 then
  begin
   if Loaded=Nil then
    begin
     Result:=True;   { load the file }
     Exit;
    end;
   Loaded.Acces;
   Folder:=Nil;
   for I:=0 to Loaded.SousElements.Count-1 do
    begin
     Tex:=Loaded.SousElements[I];
     if Tex is QTextureFile then
      begin
       Q:=Link1(Folder, Loaded.Name+'/', Tex.Name, 's', Base);
       Q.Name:=Tex.Name;
       Q.Specifics.Values['d']:=FolderName + Loaded.Name;
       if Tex is QTextureHL then
        Q.Specifics.Values['h']:=Copy(Tex.TypeInfo, 7, 1);
      end;
    end;
   LinkFolder(Folder, ResultFolder, FolderName);
  end;
end;

function ParseRecPak(Pak: QPakFolder; const Base, FolderName: String) : QObject;
var
 I: Integer;
 Q: QObject;
begin
 Result:=Nil;
 Pak.Acces;
 for I:=0 to Pak.SousElements.Count-1 do
  begin
   Q:=Pak.SousElements[I];
   if Q is QPakFolder then
    LinkFolder(ParseRecPak(QPakFolder(Q), Base, FolderName+Q.Name+'/'),
     Result, FolderName)
   else
    TryToLink1(Result, Q.Name+Q.TypeInfo, FolderName, Base, Q);
  end;
end;

function ParseRec(const Path, Base, FolderName: String) : QObject;
var
 F: TSearchRec;
 I, DosError: Integer;
 L: TStringList;
 Loaded: QObject;
begin
 Result:=Nil;
 L:=TStringList.Create; try
 DosError:=FindFirst(PathAndFile(Path, '*.*'), faAnyFile, F);
 try
  while DosError=0 do
   begin
    if F.Attr and faDirectory = 0 then
     begin
      Loaded:=Nil; try
      while TryToLink1(Result, F.Name, FolderName, Base, Loaded) do
       begin
        Loaded:=LienFichierExact(PathAndFile(Path, F.Name), Nil, False);
        Loaded.AddRef(+1);
       end;
      finally Loaded.AddRef(-1); end;
     end
    else
     if (F.Name<>'.') and (F.Name<>'..') then
      L.Add(F.Name);
    DosError:=FindNext(F);
   end;
 finally
  FindClose(F);
 end;
 for I:=0 to L.Count-1 do
  LinkFolder(ParseRec(PathAndFile(Path, L[I]), Base, FolderName+L[I]+'/'),
   Result, FolderName);
 finally L.Free; end;
end;

procedure TQuickWalParser.OkBtnClick(Sender: TObject);
var
 Gr: QExplorerGroup;
 E: TQkExplorer;
 S, Base, Path: String;
 Q, Q1: QObject;
 J, DosError: Integer;
 F: TSearchRec;
 Pak: QPak;
begin
 DebutTravail(0,0); try
 Base:=ListBox1.Items[ListBox1.ItemIndex];
 E:=TQkExplorer(Toolbox.Perform(wm_MessageInterne, wp_TargetExplorer, 0));
 if E<>Nil then
  begin
   Path:=PathAndFile(QuakeDir, Base);
   S:=PathAndFile(Path, Q2TexPath);
   Q:=ParseRec(S, Base, '');

   DosError:=FindFirst(PathAndFile(Path, '*'+SetupGameSet.Specifics.Values['PakExt']), faAnyFile, F);
   try
    while DosError=0 do
     begin
      Pak:=LienFichierExact(PathAndFile(Path, F.Name), Nil, False) as QPak;
      Pak.AddRef(+1); try
      Pak.Acces;
      Q1:=Pak.GetFolder(Q2TexPath);
      if Q1<>Nil then
       begin
        Q1:=ParseRecPak(Q1 as QPakFolder, Base, '');
        if Q1<>Nil then
         begin
          Q1.Name:=F.Name;
          LinkFolder(Q1, Q, '');
         end;
       end;
      finally Pak.AddRef(-1); end;
      DosError:=FindNext(F);
     end;
   finally
    FindClose(F);
   end;

   if Q=Nil then
    Raise EErrorFmt(5660, [S]);
   try
    Gr:=ClipboardGroup;
    Gr.AddRef(+1); try
    for J:=0 to Q.SousElements.Count-1 do
     Gr.SousElements.Add(Q.SousElements[J]);
    if E.DropObjectsNow(Gr, LoadStr1(623), False) then
     begin
      Close;
      Exit;
     end;
    finally Gr.AddRef(-1); end;
   finally
    Q.Free;
   end;
  end;
 finally FinTravail; end; 
 MessageBeep(0);
end;

procedure TQuickWalParser.FormActivate(Sender: TObject);
var
 F: TSearchRec;
 DosError: Integer;
begin
 OnActivate:=Nil;
 CheckQuakeDir;
 DosError:=FindFirst(PathAndFile(QuakeDir, '*.*'), faAnyFile, F);
 try
  while DosError=0 do
   begin
    if (F.Attr and faDirectory <> 0) and (F.Name<>'.') and (F.Name<>'..') then
     ListBox1.Items.Add(F.Name);
    DosError:=FindNext(F);
   end;
 finally
  FindClose(F);
 end;
end;

procedure TQuickWalParser.FormCreate(Sender: TObject);
begin
 MarsCap.ActiveBeginColor:=clGreen;
 MarsCap.ActiveEndColor:=clYellow;
 UpdateMarsCap;
end;

end.
