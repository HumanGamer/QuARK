{ ZIPDLL.PAS   - Delphi translation of file "wizzip.h" by Eric W. Engler }
{ Import Unit for ZIPDLL - put this into the "uses" clause of any
  other unit that wants to access the DLL. }

{ I changed this to use dynamic loading of the DLL in order to allow
  the user program to control when to load and unload the DLLs.
  Thanks to these people for sending me dynamic loading code:
     Ewart Nijburg, Nijsoft@Compuserve.com
     P.A. Gillioz,  pag.aria@rhone.ch
}

Unit ZIPDLL;

Interface

Uses Windows, Dialogs, ZCallBck;

{ These records are very critical.  Any changes in the order of items, the
  size of items, or modifying the number of items, may have disasterous
  results.  You have been warned! }
Type ZipParms1 = packed record
   Handle:          THandle;
   Caller:          Pointer;    { "self" referance of the Delphi form }
                                { This is passed back to us in the callback function
                                  so we can direct the info to the proper form instance
                                - thanks to Dennis Passmore for this idea. }
   Version:         LongInt;    { version of DLL we expect to see }
   ZCallbackFunc:   ZFunctionPtrType; { type def in ZCallBck.PAS }
   fTraceEnabled:   LongBool;

   {============== Begin Zip Flag section ============== }
   pZipPassword:    PChar;      { password pointer }
   fSuffix:         LongBool;   { not used yet }
   fEncrypt:        LongBool;   { Encrypt files to be added? }

   { include system and hidden files }
   fSystem:         LongBool;

   { Include volume label }
   fVolume:         LongBool;

   { Include extra file attributes (read-only, unix timestamps, etc) }
   fExtra:          LongBool;

   { Do not add directory names to .ZIP archive }
   { see also: fJunkDir }
   fNoDirEntries:   LongBool;

   { Only add files newer a specified date }
   { See the "Date" array below if you set this to TRUE }
   fDate:           LongBool;

   { Give a little more information to the user via message boxes }
   fVerboseEnabled: LongBool;

   { Quiet operation - the DLL won't issue any messages at all. }
   { Delphi program MUST handle ALL errors via it's callback function. }
   fQuiet:          LongBool;

   { Compression level (0 - 9; 9=max, 0=none) }
   { All of these levels are variations of deflate. }
   { I strongly recommend you use one of 3 values here:
        0 = no compression, just store file
        3 = "fast" compression
        9 = "best" compression }
   fLevel:          LongInt;
   { Try to compress files that appear to be already compressed
     based on their extension: .zip, .arc, .gif, ... }
   fComprSpecial:   LongBool;

   { translate text file end-of-lines }
   fCRLF_LF:        LongBool;

   { junk the directory names }
   { If true, this says not to save dirnames as separate entries,
     in addition to being save with filenames. }
   { see also: fNoDirEntries }
   fJunkDir:        LongBool;

   { Recurse into subdirectories }
   fRecurse:        WordBool;
   fNoRecurseFiles: Word;

         { Allow appending to a zip file }
   fGrow:           LongBool;

   { Convert filenames to DOS 8x3 names - for compatibility
     with PKUNZIP v2.04g, which doesn't understand long filenames }
   fForce:          LongBool;

   { Delete orig files that were added or updated in zip file }
   { This is a variation of Add }
   fMove:           LongBool;

   { Delete specified files from zip file }
   fDeleteEntries:  LongBool;

   { Update zip -- if true, rezip changed, and add new files in fspec }
   { This is a variation of Add }
   fUpdate:         LongBool;

   { Freshen zip -- if true, rezip all changed files in fspec }
   { This is a variation of Add }
   fFreshen:        LongBool;

   { junk the SFX prefix on the self-extracing .EXE archives }
   fJunkSFX:        LongBool;

   { Set zip file time to time of newest file in it }
   fLatestTime:     LongBool;
   {============== End Zip Flag section ============== }

   { Cutoff Date for Add-by-date; add files newer than this day }
   { This is only used if the "fDate" option is TRUE }
   { format = MMDDYY plus 2 trailing nulls }
   Date:            Array[0..7] of Char;

   { Count of files to add or delete - don't forget to set this! }
   Argc:            LongInt;
   { ptr to name of zip file }
   pZipFN:          PChar;
   Seven:           LongInt;    { pass a 7 here to validate struct size }

   { Array of filenames contained in the ZIP archive }
   pFileNames:      Array[0..FilesMax] of PChar;
 end;

Type FileData = packed record
   fFileSpec:       PChar;
   fFileComment:    PChar;                      // NEW z->comment and z->com
   fFileAltName:    PChar;                      // NEW
   fPassword:       PChar;                      // NEW, Override
   fEncrypt:        LongBool;                   // NEW, Override
   fRecurse:        LongBool;                   // NEW, Override
   fNoRecurseFile:  LongBool;                   // NEW, Override
   fDateUsed:       LongBool;                   // NEW, Override
   fDate:           Array[0..7] of Char;        // NEW, Override
   fNotUsed:        Array[0..15] of Cardinal;   // NEW
 end;
Type pFileData = ^FileData;

Type ZipParms2 = packed record
   Handle:          THandle;
   Caller:          Pointer;
   Version:         LongInt;
   ZCallbackFunc:   ZFunctionPtrType;
   fTraceEnabled:   LongBool;
   pZipPassword:    PChar;
   fSuffix:         LongBool;
   fEncrypt:        LongBool;
   fSystem:         LongBool;
   fVolume:         LongBool;
   fExtra:          LongBool;
   fNoDirEntries:   LongBool;
   fDate:           LongBool;
   fVerboseEnabled: LongBool;
   fQuiet:          LongBool;
   fLevel:          LongInt;
   fComprSpecial:   LongBool;
   fCRLF_LF:        LongBool;
   fJunkDir:        LongBool;
   fRecurse:        WordBool;
   fNoRecurseFiles: Word;
   fGrow:           LongBool;
   fForce:          LongBool;
   fMove:           LongBool;
   fDeleteEntries:  LongBool;
   fUpdate:         LongBool;
   fFreshen:        LongBool;
   fJunkSFX:        LongBool;
   fLatestTime:     LongBool;
   Date:            Array[0..7] of Char;
   Argc:            LongInt;
   pZipFN:          PChar;
   // After this point the record is different from ZipParms1 structure.
   fTempPath:       PChar;      // NEW b option
   fArchComment:    PChar;      // NEW zcomment and zcomlen
   fExtensions:     PChar;      // NEW
   fFDS:            pFileData;  // pointer to Array of FileData
   fForceWin:       LongBool;   // NEW
   fNotUsed:        Array[0..15] of Cardinal;   // NEW
   fSeven:          Integer;    // End of record (eg. 7)
 end;

{ A (pointer) union of the two zip parameter records used in TZipMaster }
Type ParmCol = (Parms1, Parms2);
   ZipParms0 = record
   case ParmCol of
      Parms1: (zp1: ^ZipParms1);
      Parms2: (zp2: ^ZipParms2);
 end;

Type
   pZipParms = ^ZipParms1;

   ZipOpt = (ZipAdd, ZipDelete);
   { NOTE: Freshen, Update, and Move are only variations of Add }

{ Main call to execute a ZIP add or Delete.  This call returns the
  number of files that were sucessfully operated on. }
var ZipDllExec: function( ZipRec: pZipParms ): DWord; stdcall;

var GetZipDllVersion: function : DWord; stdcall;

var ZipDllHandle: THandle;

implementation

end.

