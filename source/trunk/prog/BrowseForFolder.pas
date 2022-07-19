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
unit BrowseForFolder;

interface

{$I DelphiVer.inc}

uses Windows;

function BrowseForFolderDlg(hwnd: HWnd; var Path: String; Title: String; const CheckFile: String) : Boolean;
function CheckFileExists(const Path, CheckFile: String) : Boolean;

implementation

uses SysUtils, SystemDetails, {$IFDEF CompiledWithDelphi2}ShellObj, OLE2,{$ELSE}ShlObj, ActiveX,{$ENDIF} ExtraFunctionality;

function CheckFileExists(const Path, CheckFile: String) : Boolean;
var
  S, S2: String;
begin
 if (Path='') or (CheckFile='') then
  Result:=True
 else
  begin
   S:=IncludeTrailingPathDelimiter(Path);

   if pos(#$D, CheckFile) <> 0 then
   begin
     Result:=false;
     S2:=CheckFile;
     while (pos(#$D, S2) <> 0) do
     begin
       Result:=Result or FileExists(S+Copy(S2, 1, pos(#$D, S2)-1));
       Delete(S2, 1, pos(#$D, S2));
     end;
   end
   else if pos(#$A, CheckFile) <> 0 then
   begin
     Result:=true;
     S2:=CheckFile;
     while (pos(#$A, S2) <> 0) do
     begin
       Result:=Result and FileExists(S+Copy(S2, 1, pos(#$A, S2)-1));
       Delete(S2, 1, pos(#$A, S2));
     end;
   end
   else
   begin
     Result:=FileExists(S+CheckFile);
   end;
  end;
end;

function BrowseCallback(hWnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall; export;
var
 S: String;
 Ok: Boolean;
begin
 case uMsg of
  BFFM_INITIALIZED:
    begin
     S:=PChar(lpData);
     if S<>'' then
      begin
       if (S[Length(S)]='\') and (S[Length(S)-1]<>':') then
        SetLength(S, Length(S)-1);
       SendMessage(hwnd, BFFM_SETSELECTION, 1, LongInt(PChar(S)));
      end;
    end;
  BFFM_SELCHANGED:
    begin
     SetLength(S, MAX_PATH+1);
     if SHGetPathFromIDList(PItemIDList(lParam), PChar(S)) and (S[1]<>#0) then
      begin
       SetLength(S, StrLen(PChar(S)));
       Ok:=CheckFileExists(S, StrEnd(PChar(lpData))+1);
      end
     else
      Ok:=False;
     SendMessage(hwnd, BFFM_ENABLEOK, 0, Ord(Ok));
    end;
 end;
 Result:=0;
end;

function BrowseForFolderDlg(hwnd: HWnd; var Path: String; Title: String; const CheckFile: String) : Boolean;
var
 g_pMalloc: IMalloc;
 pidlFolder: PItemIDList;
 BrowseInfo: TBrowseInfo;
 S: String;
 I: Integer;
begin
 Result:=False;
 if not SUCCEEDED(SHGetMalloc(g_pMalloc)) then
  Exit;
 I:=Pos(#13+#10, Title);
 if I<>0 then
  SetLength(Title, I-1);
 FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
 BrowseInfo.hwndOwner:=hwnd;
 BrowseInfo.lpszTitle:=PChar(Title);
 BrowseInfo.lpfn:=BrowseCallback;
 S:=Path;
 if (S<>'') and (S[Length(S)]<>'\') then
  S:=S+'\';
 S:=S+#0+CheckFile;
 BrowseInfo.lParam:=LongInt(PChar(S));
 if CheckWindowsMEAnd2000 then //FIXME: And if Internet Explorer 5 is installed
  BrowseInfo.ulFlags:=BIF_NEWDIALOGSTYLE;
 pidlFolder:=SHBrowseForFolder( {$IFDEF CompiledWithDelphi2} @ {$ENDIF} BrowseInfo);
 try
  S:='';
  if pidlFolder<>Nil then
   begin
    SetLength(S, MAX_PATH+1);
    if SHGetPathFromIDList(pidlFolder, PChar(S)) then
     SetLength(S, StrLen(PChar(S)))
    else
     S:='';
   end;
 finally
  { Free the PIDL for the Programs folder. }
  if pidlFolder<>Nil then
   g_pMalloc.Free(pidlFolder);
 end;
 Result:=S<>'';
 if Result then
  Path:=S;
end;

end.
