{
************

 THIS IS AN EXTREME HACK! - we create a zip file containing only one file
 then open the zip file and copy the compressed data... slooow....!... But
 it works!

************
}

{

$Header$
 ----------- REVISION HISTORY ------------
$Log$

}


unit ZIP;

interface

uses Forms, Sysutils, Classes, Windows, Dialogs;

procedure CompressStream(var Input: TMemoryStream; var Output: TMemoryStream);

implementation

uses QkFileObjects, ZipMstr, QkZip2, Game, Setup;

{$R ZipMsgUS.res}

procedure CompressStream(var Input: TMemoryStream; var Output: TMemoryStream);
var
  TempZipName, TempZipName2, TempFileName: String;
  ZM:TZipMaster;
  T:TFileStream;
  F:TLocalFileHeader;
  sig:Longint;
begin
  TempZipName2:=MakeTempFileName(TagToDelete);
  TempFileName:=MakeTempFileName(TagToDelete);
  TempZipName:=ChangeFileExt(TempZipName2,'.zip');
  Input.SaveToFile(TempFileName);
  ZM:=TZipMaster.Create(Nil);
  ZM.DLLDirectory:=GetDLLDirectory;
  ZM.ZipFilename:=TempZipName;
  ZM.AddCompLevel:=8;
  ZM.List;
  ZM.FSpecArgs.Clear;
  ZM.FSpecArgs.Add(TempFileName);
  ZM.Add;
  ZM.Free;
  T:=TFileStream.Create(TempZipName,fmOpenRead);
  T.Seek(0,soFromBeginning);
  T.ReadBuffer(Sig,4);
  T.ReadBuffer(F,Sizeof(F));
  T.Seek(F.FileName_Len+F.ExtraField_Len, soFromCurrent);
  Output.CopyFrom(T,F.Compressed);
  T.Free;
end;

end.
