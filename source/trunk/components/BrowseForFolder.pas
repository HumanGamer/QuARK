{
$Header$
 ----------- REVISION HISTORY ------------
$Log$
Revision 1.2  2000/09/10 14:05:21  alexander
added cvs headers


}
unit BrowseForFolder;

interface

uses Windows;

function BrowseForFolderDlg(hwnd: HWnd; var Path: String; Title, CheckFile: String) : Boolean;
function CheckFileExists(const Path, CheckFile: String) : Boolean;

implementation

uses SysUtils, {$IFDEF VER90} ShellObj, OLE2; {$ELSE} ShlObj, ActiveX; {$ENDIF}

function CheckFileExists(const Path, CheckFile: String) : Boolean;
var
  S, S2: String;
begin
 if (Path='') or (CheckFile='') then
  Result:=True
 else
  begin
   S:=Path;
   if S[Length(S)]<>'\' then
    S:=S+'\';

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

function BrowseCallback(hwnd: HWnd; uMsg, lParam, lpData: Integer) : Integer;
 stdcall; export;
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

function BrowseForFolderDlg(hwnd: HWnd; var Path: String; Title, CheckFile: String) : Boolean;
var
 g_pMalloc: IMALLOC;
 pidlFolder: PITEMIDLIST;
 BrowseInfo: TBrowseInfo;
 S: String;
begin
 Result:=False;
 if not SUCCEEDED(CoGetMalloc(MEMCTX_TASK,g_pMalloc)) then
  Exit;

 FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
 BrowseInfo.hwndOwner:=hwnd;
 BrowseInfo.lpszTitle:=PChar(Title);
 BrowseInfo.lpfn:=@BrowseCallback;
 S:=Path;
 if (S<>'') and (S[Length(S)]<>'\') then
  S:=S+'\';
 S:=S+#0+CheckFile;
 BrowseInfo.lParam:=LongInt(PChar(S));
 pidlFolder:=SHBrowseForFolder( {$IFDEF VER90} @ {$ENDIF} BrowseInfo);
 S:='';
 if pidlFolder<>Nil then
  begin
   SetLength(S, MAX_PATH+1);
   if SHGetPathFromIDList(pidlFolder, PChar(S)) then
    SetLength(S, StrLen(PChar(S)))
   else
    S:='';
   { Free the PIDL for the Programs folder. }
   g_pMalloc.Free(pidlFolder);
  end;
  { Release the shell's allocator. }
 // g_pMalloc.Release;   DONE AUTOMATICALLY BY DELPHI 4 (I hope)

 Result:=S<>'';
 if Result then
  Path:=S;
end;

end.
