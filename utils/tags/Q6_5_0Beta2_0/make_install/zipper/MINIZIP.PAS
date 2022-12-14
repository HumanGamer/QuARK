Unit MiniZip;
{ minizip demo package by Gilles Vollant

  Usage : minizip [-o] file.zip [files_to_add]

  a file.zip file is created, all files listed in [files_to_add] are added
  to the new .zip file.
  -o an existing .zip file with be overwritten without warning

  Pascal tranlastion
  Copyright (C) 2000 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

{$ifdef WIN32}
  {$define Delphi}
  {$ifndef FPC}
    {$define Delphi32}
  {$endif}
{$endif}

interface

uses
  classes,
  SysUtils, Windows,
  zutil, zlib, ziputils, zip;

const
  WRITEBUFFERSIZE = Z_BUFSIZE;
  MAXFILENAME = Z_MAXFILENAMEINZIP;

function main : int;

implementation

{$ifdef Delphi32}
function filetime(f : PChar;               { name of file to get info on }
   var tmzip : tm_zip; { return value: access, modific. and creation times }
   var dt : uLong) : uLong;                { dostime }
var
  ret : int;
var
  ftLocal : TFileTime; // FILETIME;
  hFind : THandle; // HANDLE;
  ff32 : TWIN32FindData; //  WIN32_FIND_DATA;
begin
  ret := 0;
  hFind := FindFirstFile(f, ff32);
  if (hFind <> INVALID_HANDLE_VALUE) then
  begin
    FileTimeToLocalFileTime(ff32.ftLastWriteTime,ftLocal);
    FileTimeToDosDateTime(ftLocal,LongRec(dt).hi,LongRec(dt).lo);
    FindClose(hFind);
    ret := 1;
  end;
  filetime := ret;
end;
{$else}
{$ifdef FPC}
function filetime(f : PChar;               { name of file to get info on }
   var tmzip : tm_zip; { return value: access, modific. and creation times }
   var dt : uLong) : uLong;                { dostime }
var
  ret : int;
var
  ftLocal : TFileTime; // FILETIME;
  hFind : THandle; // HANDLE;
  ff32 : TWIN32FindData; //  WIN32_FIND_DATA;
begin
  ret := 0;
  hFind := FindFirstFile(f, @ff32);
  if (hFind <> INVALID_HANDLE_VALUE) then
  begin
    FileTimeToLocalFileTime(ff32.ftLastWriteTime,@ftLocal);
    FileTimeToDosDateTime(ftLocal,@LongRec(dt).hi,@LongRec(dt).lo);
    FindClose(hFind);
    ret := 1;
  end;
  filetime := ret;
end;
{$else}
function filetime(f : PChar;               { name of file to get info on }
   var tmzip : tm_zip; { return value: access, modific. and creation times }
   var dt : uLong) : uLong;                { dostime }
var
  fl : file;
  yy, mm, dd, dow : Word;
  h, m, s, hund : Word; { For GetTime}
  dtrec : TDateTime; { For Pack/UnpackTime}
begin
  {$i-}
  Assign(fl, f);
  Reset(fl, 1);
  if IOresult = 0 then
  begin
    GetFTime(fl,dt); { Get creation time }
    UnpackTime(dt, dtrec);
    Close(fl);
    tmzip.tm_sec  := dtrec.sec;
    tmzip.tm_min  := dtrec.min;
    tmzip.tm_hour := dtrec.hour;
    tmzip.tm_mday := dtrec.day;
    tmzip.tm_mon  := dtrec.month;
    tmzip.tm_year := dtrec.year;
  end;

  filetime := 0;
end;
{$endif}
{$endif}

function check_exist_file(const filename : PChar) : int;
var
  ftestexist : FILE;
  ret : int;
begin
  ret := 1;
  Assign(ftestexist, filename);
  {$i-}
  reset(ftestexist);
  if IOresult <> 0 then
    ret := 0
  else
    system.close(ftestexist);
  check_exist_file := ret;
end;

//////////////// BEGIN AiV ////////////////////    
procedure do_banner;
begin
  WriteLn('zipper by Andy Vincent');
  WriteLn;
end;
//////////////// END AiV ////////////////////    

//////////////// BEGIN AiV ////////////////////    
procedure do_help;
begin
  WriteLn('Usage : zipper [-rrelativedir] file.zip [files_to_add | @filelist]');
  WriteLn;
end;
//////////////// END AiV ////////////////////    

function main : int;
var
  argstr : string;
  i : int;
  opt_overwrite : int;
  opt_compress_level : int;
  zipfilenamearg : int;
  filename_try : array[0..MAXFILENAME-1] of char;
  zipok : int;
  err : int;
  size_buf : int;
  buf : voidp;
var
  p : PChar;
  c : char;
var
  len : int;
  dot_found : int;
var
  rep : char;
  answer : string[128];
var
  zf : zipFile;
  errclose : int;
var
  fin : FILEptr;
  size_read : int;
  filenameinzip : {const} PChar;
  zi : zip_fileinfo;
//////////////// BEGIN AiV ////////////////////    
var
  files: TStringlist;
  filenameinzip2: string;
  relative_to: string;
  opt_relative: int;
  s_pos: int;
//////////////// END AiV ////////////////////    
begin
  opt_overwrite := 0;
  opt_relative := 0;
  opt_compress_level := Z_DEFAULT_COMPRESSION;
  zipfilenamearg := 0;
  err := 0;
  main := 0;

  do_banner;
  if (ParamCount=0) then
  begin
    do_help;
    main := 0;
    exit;
  end
  else
  begin
    for i:=1 to ParamCount-1+1 do
    begin
      argstr := ParamStr(i)+#0;
      if (argstr[1]='-') then
      begin
        c := argstr[2];       {const char *p=argv[i]+1;}

	while (c<>#0) do
	begin
          if (c='r') or (c='R') then
          begin
            opt_relative := 1;
            relative_to:=System.copy(argstr, 3, length(argstr)-2);
            break;
          end;
	  if (c='o') or (c='O') then
	    opt_overwrite := 1;
          if (c>='0') and (c<='9') then
            opt_compress_level := Byte(c)-Byte('0');
	end;
      end
      else
        if (zipfilenamearg = 0) then
          zipfilenamearg := i;
    end;
  end;

  size_buf := WRITEBUFFERSIZE;
  buf := ALLOC(size_buf);
  if (buf=NIL) then
  begin
    WriteLn('Error allocating memory');
    main := ZIP_INTERNALERROR;
    exit;
  end;

  if (zipfilenamearg=0) then
    zipok := 0
  else
  begin
    dot_found := 0;

    zipok := 1 ;
    argstr := ParamStr(zipfilenamearg) + #0;
    strcopy(filename_try, PChar(@argstr[1]));
    len := strlen(filename_try);
    for i:=0 to len-1 do
      if (filename_try[i]='.') then
        dot_found := 1;

    if (dot_found = 0) then
      strcat(filename_try,'.zip');

    if (opt_overwrite=0) then
      if (check_exist_file(filename_try)<>0) then
      begin
        repeat
	  WriteLn('The file ',filename_try,
            ' exist. Overwrite ? [y]es, [n]o : ');
	  ReadLn(answer);
	  rep := answer[1] ;
	  if (rep>='a') and (rep<='z') then
	    Dec(rep, $20);
	until (rep='Y') or (rep='N');
        if (rep='N') then
          zipok := 0;
      end;
  end;

  if (zipok=1) then
  begin
    zf := zipOpen(filename_try,0);
    if (zf = NIL) then
    begin
      WriteLn('error opening ', filename_try);
      err := ZIP_ERRNO;
    end
    else
      WriteLn('creating ',filename_try);

    i := zipfilenamearg+1;
//////////////// BEGIN AiV ////////////////////
// allow for file lists and relative dir.
    files:=TStringList.Create;
    while (i<=ParamCount) do
    begin
      argstr := ParamStr(i)+#0;
      if ParamStr(i)[1]='@' then
      begin
        WriteLn('Loading file list from ' + system.copy(ParamStr(i), 2,length(ParamStr(i))-1));
        files.loadfromfile(system.copy(ParamStr(i), 2,length(ParamStr(i))-1));
        break;
      end else
        files.add(ParamStr(i));
      Inc(i);
    end;
    i:=0;
    while (i<files.count) do
    begin
      filenameinzip := PChar(files.strings[i]);
      if opt_relative = 1 then
      begin
        filenameinzip2:=files.strings[i];
        s_pos:=pos(uppercase(relative_to), uppercase(filenameinzip2));
        delete(filenameinzip2, 1, length(relative_to));
      end
      else
        filenameinzip2:=files.strings[i];
      if not fileexists(filenameinzip) then
      begin
        inc(i);
        continue;
      end;
//////////////// END - AiV ////////////////////    
      Write('Zipping "' + files.strings[i] +'" --> "'+filenameinzip2+'" ...');
      zi.tmz_date.tm_sec := 0;
      zi.tmz_date.tm_min := 0;
      zi.tmz_date.tm_hour := 0;
      zi.tmz_date.tm_mday := 0;
      zi.tmz_date.tm_min := 0;
      zi.tmz_date.tm_year := 0;
      zi.dosDate := 0;
      zi.internal_fa := 0;
      zi.external_fa := 0;
      filetime(filenameinzip,zi.tmz_date,zi.dosDate);

      if (opt_compress_level <> 0) then
        err := zipOpenNewFileInZip(zf,pchar(filenameinzip2), @zi,
              NIL,0,NIL,0,NIL { comment}, Z_DEFLATED, opt_compress_level)
      else
        err := zipOpenNewFileInZip(zf,pchar(filenameinzip2), @zi,
                 NIL,0,NIL,0,NIL, 0, opt_compress_level);

      if (err <> ZIP_OK) then
        WriteLn('error in opening ',filenameinzip,' in zipfile')
      else
      begin
        fin := fopen(filenameinzip, fopenread);
        if (fin=NIL) then
        begin
          err := ZIP_ERRNO;
          WriteLn('error in opening ',filenameinzip,' for reading');
        end;
         if (err = ZIP_OK) then
        repeat
          err := ZIP_OK;
          size_read := fread(buf,1,size_buf,fin);
           if (size_read < size_buf) then
            if feof(fin)=0 then
            begin
              WriteLn('error in reading ',filenameinzip);
              err := ZIP_ERRNO;
            end;
           if (size_read>0) then
          begin
            err := zipWriteInFileInZip (zf,buf,size_read);
            if (err<0) then
                WriteLn('error in writing ',filenameinzip,' in the zipfile');
          end;
        until (err <> ZIP_OK) or (size_read=0);
         fclose(fin);
      end;
      if (err<0) then
        err := ZIP_ERRNO
      else
      begin
        err := zipCloseFileInZip(zf);
        if (err<>ZIP_OK) then
          WriteLn('error in closing ',filenameinzip,' in the zipfile');
      end;
      if err=ZIP_OK then
        WriteLn('ok');
      inc(i);
    end; { if }
    files.free;
    errclose := zipClose(zf,NIL);
    if (errclose <> ZIP_OK) then
      WriteLn('error in closing ',filename_try);
  end;

  TRYFREE(buf); {FreeMem(buf, size_buf);}
end;

begin

end.
