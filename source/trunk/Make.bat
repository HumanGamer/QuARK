@echo off
CLS
ECHO Compiling QuArK.exe without debug information
ECHO ---------------------------------------------
ECHO.
REM Check if compiler is available
REM DCC32.EXE --version > NUL 2> NUL
REM The ERRORLEVEL for 'file not found' is 9009
REM IF ERRORLEVEL 9009 GOTO NoDCC32
REM B = recompile ALL units, H = show hints, W = show warnings, Q = don't list all the unit file names
REM $D- = no debug info, $L- = no local debug symbols, $O+ = optimization
REM DCC32.EXE QuArK.dpr -B -H -W -Q -$D- -$L- -$O+
REM If the Delphi compiler didn't exit with an error level of 0, exit the batch file.
REM IF NOT ERRORLEVEL 0 GOTO CompileFailed

ECHO.
ECHO.
ECHO Embedding manifest
ECHO ------------------
ECHO.
REM Make Windows look for UPX in the PATH system variable, but don't display the output.
"%ProgramFiles(x86)%\Windows Kits\10\bin\10.0.20348.0\x86\mt.exe" > NUL 2> NUL
REM The ERRORLEVEL for 'file not found' is 9009
IF ERRORLEVEL 9009 GOTO NoMT
"%ProgramFiles(x86)%\Windows Kits\10\bin\10.0.20348.0\x86\mt.exe" -nologo -validate_manifest -canonicalize -check_for_duplicates -manifest "QuArK.manifest" -outputresource:..\runtime\QuArK.exe

ECHO.
ECHO.
ECHO Applying UPX compression
ECHO ------------------------
ECHO.
REM Make Windows look for UPX in the PATH system variable, but don't display the output.
REM UPX.EXE > NUL 2> NUL
REM The ERRORLEVEL for 'file not found' is 9009
REM IF ERRORLEVEL 9009 GOTO NoUPX
REM UPX.EXE --best --ultra-brute ..\runtime\QuArK.exe
GOTO Finished

:NoDCC32
ECHO DCC32.EXE was not found!
ECHO Make sure the Delphi compiler is in the PATH variable!
GOTO Finished

:CompileFailed
ECHO The compile failed!
GOTO Finished

:NoMT
ECHO MT.EXE was not found!
ECHO Install the Windows SDK, and update the path in Make.bat
GOTO Finished

:NoUPX
ECHO UPX.EXE is not in your PATH variable!
ECHO If you don't have a copy check out:
ECHO https://upx.github.io/
GOTO Finished

:Finished
ECHO.
PAUSE
