; QuArK installer script for NSIS
; HomePage: http://quark.sourceforge.net/
; Author:  Fredrick Vamstad, DanielPharos & cdunde
; Date:     18 Aug. 2005 & 5 January 2007
; nullsoft NSIS installer program available at:
;   http://nsis.sourceforge.net

; Modern UI 2 ------
!include MUI2.nsh
!include WinVer.nsh
SetCompressor /SOLID lzma   ; We will use LZMA for best compression
;RequestExecutionLevel admin

!define BUILDDIR "C:\QuArK_installer_files"
!define SPLASHDIR "C:\QuArK_installer_splash_image"
!define DEPENDENCYDIR "C:\QuArK_installer_dependencies"
!define INSTALLER_EXENAME "quark-win32-6.6.0Beta8.exe"
!define PRODUCT_NAME "QuArK"
!define PRODUCT_NAME_FULL "Quake Army Knife"
!define PRODUCT_COPYRIGHT "Copyright (c) 2021"
!define PRODUCT_VERSION "6.6.0 Beta 8"
!define PRODUCT_VERSION_NUMBER "6.6.8.0"
!define PRODUCT_VERSION_STRING "6.6 (Beta-Release)"
!define PRODUCT_WEB_SITE "http://quark.sourceforge.net/"
!define PRODUCT_WEB_FORUM "http://quark.sourceforge.net/forums/"
!define PRODUCT_INFOBASE "http://quark.sourceforge.net/infobase/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\QuArK.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_PUBLISHER "QuArK Development Team"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_EXENAME}"
InstallDir "$PROGRAMFILES\QuArK 6.6"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_CANCEL_DEFAULT
!define MUI_UNABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install-blue.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue.ico"
; Loads the splash window
!define MUI_WELCOMEFINISHPAGE_BITMAP "${SPLASHDIR}\install_splash.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${SPLASHDIR}\install_splash.bmp"
; Loads the header picture
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${SPLASHDIR}\install_header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${SPLASHDIR}\install_header.bmp"

; Language Selection Dialog Settings
!define MUI_LANGDLL_ALWAYSSHOW
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "${BUILDDIR}\COPYING.txt"
; Component page
!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\QuArK.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_LINK "QuArK website"
!define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
;!define MUI_LANGDLL_ALLLANGUAGES
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "Norwegian"
!insertmacro MUI_LANGUAGE "Finnish"
;!insertmacro MUI_LANGUAGE "Greek"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Ukrainian"
!insertmacro MUI_LANGUAGE "Arabic"
!insertmacro MUI_RESERVEFILE_LANGDLL

; Language strings
LangString TEXT_SEC01_TITLE ${LANG_ENGLISH} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_FRENCH} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_GERMAN} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_TRADCHINESE} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_DUTCH} "Programma bestanden"
LangString TEXT_SEC01_TITLE ${LANG_NORWEGIAN} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_FINNISH} "Main Program files"
;LangString TEXT_SEC01_TITLE ${LANG_GREEK} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_RUSSIAN} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_POLISH} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_UKRAINIAN} "Main Program files"
LangString TEXT_SEC01_TITLE ${LANG_ARABIC} "Main Program files"

LangString TEXT_SEC02_TITLE ${LANG_ENGLISH} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_FRENCH} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_GERMAN} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_TRADCHINESE} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_DUTCH} "Help bestanden"
LangString TEXT_SEC02_TITLE ${LANG_NORWEGIAN} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_FINNISH} "Help files"
;LangString TEXT_SEC02_TITLE ${LANG_GREEK} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_RUSSIAN} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_POLISH} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_UKRAINIAN} "Help files"
LangString TEXT_SEC02_TITLE ${LANG_ARABIC} "Help files"

LangString TEXT_SEC03_TITLE ${LANG_ENGLISH} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_FRENCH} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_GERMAN} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_TRADCHINESE} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_DUTCH} "Afhankelijkheden"
LangString TEXT_SEC03_TITLE ${LANG_NORWEGIAN} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_FINNISH} "Dependencies"
;LangString TEXT_SEC03_TITLE ${LANG_GREEK} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_RUSSIAN} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_POLISH} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_UKRAINIAN} "Dependencies"
LangString TEXT_SEC03_TITLE ${LANG_ARABIC} "Dependencies"

LangString TEXT_SEC04_TITLE ${LANG_ENGLISH} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_FRENCH} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_GERMAN} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_TRADCHINESE} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_DUTCH} "Start Menu snelkoppelingen"
LangString TEXT_SEC04_TITLE ${LANG_NORWEGIAN} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_FINNISH} "Start Menu shortcuts"
;LangString TEXT_SEC04_TITLE ${LANG_GREEK} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_RUSSIAN} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_POLISH} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_UKRAINIAN} "Start Menu shortcuts"
LangString TEXT_SEC04_TITLE ${LANG_ARABIC} "Start Menu shortcuts"

LangString TEXT_SEC05_TITLE ${LANG_ENGLISH} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_FRENCH} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_GERMAN} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_TRADCHINESE} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_DUTCH} "Bureaublad icoon"
LangString TEXT_SEC05_TITLE ${LANG_NORWEGIAN} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_FINNISH} "Desktop icon"
;LangString TEXT_SEC05_TITLE ${LANG_GREEK} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_RUSSIAN} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_POLISH} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_UKRAINIAN} "Desktop icon"
LangString TEXT_SEC05_TITLE ${LANG_ARABIC} "Desktop icon"

LangString TEXT_SEC01_DESC ${LANG_ENGLISH} "Install QuArK."
LangString TEXT_SEC01_DESC ${LANG_FRENCH} "Main files."
LangString TEXT_SEC01_DESC ${LANG_GERMAN} "Main files."
LangString TEXT_SEC01_DESC ${LANG_TRADCHINESE} "Main files."
LangString TEXT_SEC01_DESC ${LANG_DUTCH} "Installeert QuArK."
LangString TEXT_SEC01_DESC ${LANG_NORWEGIAN} "Main files."
LangString TEXT_SEC01_DESC ${LANG_FINNISH} "Main files."
;LangString TEXT_SEC01_DESC ${LANG_GREEK} "Main files."
LangString TEXT_SEC01_DESC ${LANG_RUSSIAN} "Main files."
LangString TEXT_SEC01_DESC ${LANG_POLISH} "Main files."
LangString TEXT_SEC01_DESC ${LANG_UKRAINIAN} "Main files."
LangString TEXT_SEC01_DESC ${LANG_ARABIC} "Main files."

LangString TEXT_SEC02_DESC ${LANG_ENGLISH} "Without these help files, only online help will be available."
LangString TEXT_SEC02_DESC ${LANG_FRENCH} "Help files."
LangString TEXT_SEC02_DESC ${LANG_GERMAN} "Help files."
LangString TEXT_SEC02_DESC ${LANG_TRADCHINESE} "Help files."
LangString TEXT_SEC02_DESC ${LANG_DUTCH} "Zonder deze help bestanden kan alleen de online help geraadpleegd worden."
LangString TEXT_SEC02_DESC ${LANG_NORWEGIAN} "Help files."
LangString TEXT_SEC02_DESC ${LANG_FINNISH} "Help files."
;LangString TEXT_SEC02_DESC ${LANG_GREEK} "Help files."
LangString TEXT_SEC02_DESC ${LANG_RUSSIAN} "Help files."
LangString TEXT_SEC02_DESC ${LANG_POLISH} "Help files."
LangString TEXT_SEC02_DESC ${LANG_UKRAINIAN} "Help files."
LangString TEXT_SEC02_DESC ${LANG_ARABIC} "Help files."

LangString TEXT_SEC03_DESC ${LANG_ENGLISH} "Install dependencies that QuArK needs, such as DirectX."
LangString TEXT_SEC03_DESC ${LANG_FRENCH} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_GERMAN} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_TRADCHINESE} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_DUTCH} "Installeer benodigde afhankelijkheden, zoals DirectX."
LangString TEXT_SEC03_DESC ${LANG_NORWEGIAN} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_FINNISH} "Dependencies."
;LangString TEXT_SEC03_DESC ${LANG_GREEK} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_RUSSIAN} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_POLISH} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_UKRAINIAN} "Dependencies."
LangString TEXT_SEC03_DESC ${LANG_ARABIC} "Dependencies."

LangString TEXT_SEC04_DESC ${LANG_ENGLISH} "Create various shortcuts for QuArK in the Start Menu."
LangString TEXT_SEC04_DESC ${LANG_FRENCH} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_GERMAN} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_TRADCHINESE} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_DUTCH} "Creëert verschillende snelkoppelingen voor QuArK in het Start Menu."
LangString TEXT_SEC04_DESC ${LANG_NORWEGIAN} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_FINNISH} "Start Menu shortcuts."
;LangString TEXT_SEC04_DESC ${LANG_GREEK} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_RUSSIAN} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_POLISH} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_UKRAINIAN} "Start Menu shortcuts."
LangString TEXT_SEC04_DESC ${LANG_ARABIC} "Start Menu shortcuts."

LangString TEXT_SEC05_DESC ${LANG_ENGLISH} "Creates an icon to launch QuArK on the desktop."
LangString TEXT_SEC05_DESC ${LANG_FRENCH} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_GERMAN} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_TRADCHINESE} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_DUTCH} "Creëert een icoon om QuArK op te starten op het bureaublad."
LangString TEXT_SEC05_DESC ${LANG_NORWEGIAN} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_FINNISH} "Desktop icon."
;LangString TEXT_SEC05_DESC ${LANG_GREEK} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_RUSSIAN} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_POLISH} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_UKRAINIAN} "Desktop icon."
LangString TEXT_SEC05_DESC ${LANG_ARABIC} "Desktop icon."

LangString TEXT_UNINSTALL1 ${LANG_ENGLISH} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_FRENCH} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_GERMAN} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_TRADCHINESE} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_DUTCH} "Dit zal ALLE bestanden in de QuArK map en sub-mappen verwijderen, inclusief alle zelfgemaakte bestanden.$\n$\nVerplaats alle bestanden die U wilt bewaren voordat U op 'Ja' drukt om de deïnstallatie voort te zetten."
LangString TEXT_UNINSTALL1 ${LANG_NORWEGIAN} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_FINNISH} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
;LangString TEXT_UNINSTALL1 ${LANG_GREEK} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_RUSSIAN} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_POLISH} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_UKRAINIAN} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."
LangString TEXT_UNINSTALL1 ${LANG_ARABIC} "This will remove ALL files in the QuArK folder and sub-folders including any custom files.$\n$\nMove any files you wish to save before clicking 'Yes' to continue this uninstall."

LangString TEXT_UNINSTALL2 ${LANG_ENGLISH} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_FRENCH} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_GERMAN} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_TRADCHINESE} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_DUTCH} "Weet U het zeker dat U $(^Name) en al zijn componenten wilt verwijderen?"
LangString TEXT_UNINSTALL2 ${LANG_NORWEGIAN} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_FINNISH} "Are you sure you want to completely remove $(^Name) and all of its components now?"
;LangString TEXT_UNINSTALL2 ${LANG_GREEK} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_RUSSIAN} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_POLISH} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_UKRAINIAN} "Are you sure you want to completely remove $(^Name) and all of its components now?"
LangString TEXT_UNINSTALL2 ${LANG_ARABIC} "Are you sure you want to completely remove $(^Name) and all of its components now?"

LangString TEXT_UNINSTALL3 ${LANG_ENGLISH} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_FRENCH} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_GERMAN} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_TRADCHINESE} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_DUTCH} "$(^Name) werd succesvol verwijderd van Uw computer."
LangString TEXT_UNINSTALL3 ${LANG_NORWEGIAN} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_FINNISH} "$(^Name) was successfully removed from your computer."
;LangString TEXT_UNINSTALL3 ${LANG_GREEK} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_RUSSIAN} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_POLISH} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_UKRAINIAN} "$(^Name) was successfully removed from your computer."
LangString TEXT_UNINSTALL3 ${LANG_ARABIC} "$(^Name) was successfully removed from your computer."

; Installer executable settings
VIProductVersion "${PRODUCT_VERSION_NUMBER}"

VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_FRENCH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_FRENCH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_FRENCH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_FRENCH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_GERMAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_GERMAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_GERMAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_GERMAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_TRADCHINESE} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_TRADCHINESE} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_DUTCH} "ProductName" "Quake Army Knife installatiebestand"
;VIAddVersionKey /LANG=${LANG_DUTCH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_DUTCH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_DUTCH} "FileDescription" "Installatiebestand voor QuArK"
VIAddVersionKey /LANG=${LANG_DUTCH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_DUTCH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_NORWEGIAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_NORWEGIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_FINNISH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_FINNISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_FINNISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_FINNISH} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_FINNISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_FINNISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

;VIAddVersionKey /LANG=${LANG_GREEK} "ProductName" "Quake Army Knife installer"
;;VIAddVersionKey /LANG=${LANG_GREEK} "CompanyName" "QuArK Development Team"
;VIAddVersionKey /LANG=${LANG_GREEK} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
;VIAddVersionKey /LANG=${LANG_GREEK} "FileDescription" "Installer for QuArK"
;VIAddVersionKey /LANG=${LANG_GREEK} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
;VIAddVersionKey /LANG=${LANG_GREEK} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_RUSSIAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_RUSSIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_POLISH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_POLISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_POLISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_POLISH} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_POLISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_POLISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_UKRAINIAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_UKRAINIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_ARABIC} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_ARABIC} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_ARABIC} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ARABIC} "FileDescription" "Installer for QuArK"
VIAddVersionKey /LANG=${LANG_ARABIC} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_ARABIC} "ProductVersion" "${PRODUCT_VERSION_STRING}"
; MUI end ------

; Windows NT SP3 installer ------

Function InstallWinNT4SP3
  ${IfNot} ${IsWinNT4}
  ${OrIf} ${AtLeastServicePack} 3
    Goto AlreadyInstalled
  ${EndIf}

  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\WinNT4\winnt40sp3.exe"
  ExecWait "$TEMP\winnt40sp3.exe"
  Delete "$TEMP\winnt40sp3.exe"
AlreadyInstalled:
FunctionEnd

; Windows NT SP3 installer end ------

; Windows Installer ------

;The VC++ Runtime SP1 2005 installer lowered the requirements to Windows Installer 2.0.

;https://docs.microsoft.com/en-us/windows/win32/msi/released-versions-of-windows-installer

Function InstallWinInstall
  ${If} ${IsWin95}
  ${OrIf} ${IsWin98}
  ${OrIf} ${IsWinME}
  ${OrIf} ${IsWinNT4}
  ${OrIf} ${IsWin2000}
    SetOutPath $TEMP
    File "${DEPENDENCYDIR}\WindowsInstaller20\InstMsiA.exe"
    ExecWait "$TEMP\InstMsiA.exe /q"
    Delete "$TEMP\InstMsiA.exe"
    ; FIXME: Check return code: ERROR_SUCCESS_REBOOT_REQUIRED (or ERROR_SUCCESS)
  ${EndIf}
FunctionEnd

; Windows Installer end ------

; Visual C++ redistributable installers ------

; See: https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

;Microsoft Visual C++ 2005 runtime files
!define VC_2005_REDIST_X86 "{A49F249F-0C91-497F-86DF-B2585E8E76B7}"
!define VC_2005_REDIST_X64 "{6E8E85E8-CE4B-4FF5-91F7-04999C9FAE6A}"
!define VC_2005_REDIST_IA64 "{03ED71EA-F531-4927-AABD-1C31BCE8E187}"

;Microsoft Visual C++ 2005 SP1 runtime files
!define VC_2005_SP1_REDIST_X86 "{7299052B-02A4-4627-81F2-1818DA5D550D}"
!define VC_2005_SP1_REDIST_X64 "{071C9B48-7C32-4621-A0AC-3F809523288F}"
!define VC_2005_SP1_REDIST_IA64 "{0F8FB34E-675E-42ED-850B-29D98C2ECE08}"

;Microsoft Visual C++ 2005 SP1 ATL Security Update runtime files
!define VC_2005_SP1_ATL_SEC_UPD_REDIST_X86 "{837B34E3-7C30-493C-8F6A-2B0F04E2912C}"
!define VC_2005_SP1_ATL_SEC_UPD_REDIST_X64 "{6CE5BAE9-D3CA-4B99-891A-1DC6C118A5FC}"
!define VC_2005_SP1_ATL_SEC_UPD_REDIST_IA64 "{85025851-A784-46D8-950D-05CB3CA43A13}"

;Microsoft Visual C++ 2005 Service Pack 1 Redistributable Package MFC Security Update
!define VC_2005_SP1_MFC_SEC_UPD_REDIST_X86 "{710F4C1C-CC18-4C49-8CBF-51240C89A1A2}"
!define VC_2005_SP1_MFC_SEC_UPD_REDIST_X64 "{AD8A2FA1-06E7-4B0D-927D-6E54B3D31028}"
!define VC_2005_SP1_MFC_SEC_UPD_REDIST_IA64 "{C2F60BDA-462A-4A72-8E4D-CA431A56E9EA}"

;Microsoft Visual C++ 2008 runtime files
!define VC_2008_REDIST_X86 "{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}"
!define VC_2008_REDIST_X64 "{350AA351-21FA-3270-8B7A-835434E766AD}"
!define VC_2008_REDIST_IA64 "{2B547B43-DB50-3139-9EBE-37D419E0F5FA}"

;Microsoft Visual C++ 2008 SP1 runtime files
!define VC_2008_SP1_REDIST_X86 "{9A25302D-30C0-39D9-BD6F-21E6EC160475}"
!define VC_2008_SP1_REDIST_X64 "{8220EEFE-38CD-377E-8595-13398D740ACE}"
!define VC_2008_SP1_REDIST_IA64 "{5827ECE1-AEB0-328E-B813-6FC68622C1F9}"

;Microsoft Visual C++ 2008 SP1 ATL Security Update runtime files
!define VC_2008_SP1_ATL_SEC_UPD_REDIST_X86 "{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}"
!define VC_2008_SP1_ATL_SEC_UPD_REDIST_X64 "{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}"
!define VC_2008_SP1_ATL_SEC_UPD_REDIST_IA64 "{977AD349-C2A8-39DD-9273-285C08987C7B}"

;Microsoft Visual C++ 2008 SP1 MFC Security Update runtime files
!define VC_2008_SP1_MFC_SEC_UPD_REDIST_X86 "{9BE518E6-ECC6-35A9-88E4-87755C07200F}"
!define VC_2008_SP1_MFC_SEC_UPD_REDIST_X64 "{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}"
!define VC_2008_SP1_MFC_SEC_UPD_REDIST_IA64 "{515643D1-4E9E-342F-A75A-D1F16448DC04}"

;Microsoft Visual C++ 2010 runtime files
!define VC_2010_REDIST_X86 "{196BB40D-1578-3D01-B289-BEFC77A11A1E}"
!define VC_2010_REDIST_X64 "{DA5E371C-6333-3D8A-93A4-6FD5B20BCC6E}"
!define VC_2010_REDIST_IA64 "{C1A35166-4301-38E9-BA67-02823AD72A1B}"

;Microsoft Visual C++ 2010 SP1 runtime files (also for MFC security update)
!define VC_2010_SP1_REDIST_X86 "{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}"
!define VC_2010_SP1_REDIST_X64 "{1D8E6291-B0D5-35EC-8441-6616F567A0F7}"
!define VC_2010_SP1_REDIST_IA64 "{88C73C1C-2DE5-3B01-AFB8-B46EF4AB41CD}"

;Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.61030.0 (Update 4)
!define VC_2012_REDIST_MIN_UPD4_X86 "{BD95A8CD-1D9F-35AD-981A-3E7925026EBB}"
!define VC_2012_REDIST_MIN_UPD4_X64 "{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}"

;Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.61030.0 (Update 4)
!define VC_2012_REDIST_ADD_UPD4_X86 "{B175520C-86A2-35A7-8619-86DC379688B9}"
!define VC_2012_REDIST_ADD_UPD4_X64 "{37B8F9C7-03FB-3253-8781-2517C99D7C00}"

;Microsoft Visual C++ 2013 Redistributable 12.0.21005
;!define VC_2013_REDIST_X86_MIN "{13A4EE12-23EA-3371-91EE-EFB36DDFFF3E}"
;!define VC_2013_REDIST_X64_MIN "{A749D8E6-B613-3BE3-8F5F-045C84EBA29B}"
;!define VC_2013_REDIST_X86_ADD "{F8CFEB22-A2E7-3971-9EDA-4B11EDEFC185}"
;!define VC_2013_REDIST_X64_ADD "{929FBD26-9020-399B-9A7A-751D61F0B942}"

;Microsoft Visual C++ 2013 Redistributable 12.0.40664
!define VC_2013_REDIST_X86_MIN "{8122DAB1-ED4D-3676-BB0A-CA368196543E}"
!define VC_2013_REDIST_X86_ADD "{D401961D-3A20-3AC7-943B-6139D5BD490A}"
!define VC_2013_REDIST_X64_MIN "{53CF6934-A98D-3D84-9146-FC4EDF3D5641}"
!define VC_2013_REDIST_X64_ADD "{010792BA-551A-3AC0-A7EF-0FAB4156C382}"

;Microsoft Visual C++ 2015-2019 Redistributable 14.0.23026
;!define VC_2015_REDIST_X86_MIN "{A2563E55-3BEC-3828-8D67-E5E8B9E8B675}"
;!define VC_2015_REDIST_X64_MIN "{0D3E9E15-DE7A-300B-96F1-B4AF12B96488}"
;!define VC_2015_REDIST_X86_ADD "{BE960C1C-7BAD-3DE6-8B1A-2616FE532845}"
;!define VC_2015_REDIST_X64_ADD "{BC958BD2-5DAC-3862-BB1A-C1BE0790438D}"

;Microsoft Visual C++ 2015-2019 Redistributable 14.25.28508
;!define VC_2019_REDIST_X86_MIN "{2BC3BD4D-FABA-4394-93C7-9AC82A263FE2}"
;!define VC_2019_REDIST_X64_MIN "{EEA66967-97E2-4561-A999-5C22E3CDE428}"
;!define VC_2019_REDIST_X86_ADD "{0FA68574-690B-4B00-89AA-B28946231449}"
;!define VC_2019_REDIST_X64_ADD "{7D0B74C2-C3F8-4AF1-940F-CD79AB4B2DCE}"

;Microsoft Visual C++ 2015-2019 Redistributable 14.30.30708.0
!define VC_2019_REDIST_X86_MIN "{D436A6E9-EC92-40C9-BF09-1EF1D0ED8BCB}"
!define VC_2019_REDIST_X86_ADD "{C27CC672-3095-4DA8-9805-9BB2A4065704}"
!define VC_2019_REDIST_X64_MIN "{AE043016-3897-41D4-870B-1DAEE62CF152}"
!define VC_2019_REDIST_X64_ADD "{12A2980B-E47B-491B-92F5-0BC703841ED4}"
!define VC_2019_REDIST_ARM64 "{976D2A0F-2F0A-4BC0-B407-DF1BDBCD819B}"

Function InstallVC2005Redist
  ClearErrors
  ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VC_2005_SP1_MFC_SEC_UPD_REDIST_X86}" "Version"
  IfErrors 0 AlreadyInstalled

  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\VC2005SP1MFC\vcredist_x86.EXE"
  ExecWait "$TEMP\vcredist_x86.EXE /q:a /c:$\"msiexec /i vcredist.msi /qn REBOOT=ReallySuppress$\""
  Delete "$TEMP\vcredist_x86.EXE"
AlreadyInstalled:
FunctionEnd

;Function InstallVC2008Redist
;  ClearErrors
;  ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VC_2008_SP1_MFC_SEC_UPD_REDIST_X86}" "Version"
;  IfErrors 0 AlreadyInstalled
;
;  SetOutPath $TEMP
;  File "${DEPENDENCYDIR}\VC2008SP1MFC\vcredist_x86.exe"
;  ExecWait "$TEMP\vcredist_x86.exe /q"
;  Delete "$TEMP\vcredist_x86.exe"
;AlreadyInstalled:
;FunctionEnd

Function InstallVC2010Redist
  ClearErrors
  ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VC_2010_SP1_REDIST_X86}" "Version"
  IfErrors 0 AlreadyInstalled

  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\VC2010SP1MFC\vcredist_x86.exe"
  ExecWait "$TEMP\vcredist_x86.exe /q /norestart"
  Delete "$TEMP\vcredist_x86.exe"
AlreadyInstalled:
FunctionEnd

;Function InstallVC2013Redist
;  ClearErrors
;  ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${VC_2013_REDIST_X86_MIN}" "Version"
;  IfErrors 0 AlreadyInstalled
;
;  SetOutPath $TEMP
;  File "${DEPENDENCYDIR}\VC2013_12.0.40664.0\vcredist_x86.exe"
;  ExecWait "$TEMP\vcredist_x86.exe /install /quiet /norestart"
;  Delete "$TEMP\vcredist_x86.exe"
;AlreadyInstalled:
;FunctionEnd
; VC Redist end ------

; Internet Explorer 4 installer ------

Function InstallIE4SP2
  ${IfNot} ${IsWin95}
  ${AndIfNot} ${IsWinNT4}
    Goto AlreadyInstalled
  ${EndIf}

  ;Windows 95C and higher already include IE4
  ${If} ${IsWin95}
  ${AndIf} ${AtMostServicePack} 2
    Goto AlreadyInstalled
  ${EndIf}

  ;Official documentation says:
  ;- For Microsoft Windows NT:
  ;  You must be running Service Pack 3 (or higher)
  Call InstallWinNT4SP3

  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\Microsoft Internet Explorer 4.01 SP2\*.*"
  ExecWait "$TEMP\IE4SETUP.EXE /Q /T:$\"$TEMP\IE4Setup$\"" ;FIXME: Untested if this actually installs too, or only extracts!
  Delete "$TEMP\*.*"
  RMDir /r $TEMP\IE4Setup
AlreadyInstalled:
FunctionEnd

; Internet Explorer 4 installer end ------

; DirectX installer ------

; https://aka.ms/dxsetup

Function InstallDirectX
  ;Note: Not supported on Windows 95 or NT 4.
  ${If} ${IsWin98}
  ${OrIf} ${IsWinME}
    SetOutPath $TEMP
    File "${DEPENDENCYDIR}\DirectX\directx-9-0c-oct-06-directx_oct2006_redist.exe"
    ExecWait "$TEMP\directx-9-0c-oct-06-directx_oct2006_redist.exe /Q /T:$\"$TEMP\DirectX$\""
    Delete "$TEMP\directx-9-0c-oct-06-directx_oct2006_redist.exe"
    ExecWait "$TEMP\DirectX\DXSETUP.exe /silent"
    RMDir /r $TEMP\DirectX
    Goto AlreadyInstalled
  ${Else}
    ${If} ${IsWin2000}
      SetOutPath $TEMP
      File "${DEPENDENCYDIR}\DirectX\directx_feb2010_redist.exe"
      ExecWait "$TEMP\directx_feb2010_redist.exe /Q /T:$\"$TEMP\DirectX$\""
      Delete "$TEMP\directx_feb2010_redist.exe"
      ExecWait "$TEMP\DirectX\DXSETUP.exe /silent"
      RMDir /r $TEMP\DirectX
      Goto AlreadyInstalled
    ${Else}
      ${If} ${IsWinXP}
      ${OrIf} ${IsWin2003}
        SetOutPath $TEMP
        File "${DEPENDENCYDIR}\DirectX\directx_Jun2010_redist.exe"
        ExecWait "$TEMP\directx_Jun2010_redist.exe /Q /T:$\"$TEMP\DirectX$\""
        Delete "$TEMP\directx_Jun2010_redist.exe"
        ExecWait "$TEMP\DirectX\DXSETUP.exe /silent"
        RMDir /r $TEMP\DirectX
        Goto AlreadyInstalled
      ${EndIf}
    ${EndIf}
  ${EndIf}

AlreadyInstalled:
FunctionEnd
; DirectX installer end ------

Section "!$(TEXT_SEC01_TITLE)" SEC01
  SetOutPath "$INSTDIR\addons\6DX"
  File "${BUILDDIR}\addons\6DX\*.*"
  SetOutPath "$INSTDIR\addons\Alice"
  File "${BUILDDIR}\addons\Alice\*.*"
  SetOutPath "$INSTDIR\addons\Alice\maps"
  File "${BUILDDIR}\addons\Alice\maps\*.*"
  SetOutPath "$INSTDIR\addons\CoD1"
  File "${BUILDDIR}\addons\CoD1\*.*"
  SetOutPath "$INSTDIR\addons\CoD2"
  File "${BUILDDIR}\addons\CoD2\*.*"
  SetOutPath "$INSTDIR\addons\Cry_of_Fear"
  File "${BUILDDIR}\addons\Cry_of_Fear\*.*"
  SetOutPath "$INSTDIR\addons\Crystal_Space"
  File "${BUILDDIR}\addons\Crystal_Space\*.*"
  SetOutPath "$INSTDIR\addons\Doom_3"
  File "${BUILDDIR}\addons\Doom_3\*.*"
  SetOutPath "$INSTDIR\addons\EF2"
  File "${BUILDDIR}\addons\EF2\*.*"
  SetOutPath "$INSTDIR\addons\FAKK2"
  File "${BUILDDIR}\addons\FAKK2\*.*"
  SetOutPath "$INSTDIR\addons\Genesis3D"
  File "${BUILDDIR}\addons\Genesis3D\*.*"
  SetOutPath "$INSTDIR\addons\Half-Life"
  File "${BUILDDIR}\addons\Half-Life\*.*"
  SetOutPath "$INSTDIR\addons\Half-Life2"
  File "${BUILDDIR}\addons\Half-Life2\*.*"
  SetOutPath "$INSTDIR\addons\Heretic_II"
  File "${BUILDDIR}\addons\Heretic_II\*.*"
  SetOutPath "$INSTDIR\addons\Hexen_II"
  File "${BUILDDIR}\addons\Hexen_II\*.*"
  SetOutPath "$INSTDIR\addons\JA"
  File "${BUILDDIR}\addons\JA\*.*"
  SetOutPath "$INSTDIR\addons\JK2"
  File "${BUILDDIR}\addons\JK2\*.*"
  SetOutPath "$INSTDIR\addons\KingPin"
  File "${BUILDDIR}\addons\KingPin\*.*"
  SetOutPath "$INSTDIR\addons\MOHAA"
  File "${BUILDDIR}\addons\MOHAA\*.*"
  SetOutPath "$INSTDIR\addons\NEXUIZ"
  File "${BUILDDIR}\addons\NEXUIZ\*.*"
  SetOutPath "$INSTDIR\addons\Prey"
  File "${BUILDDIR}\addons\Prey\*.*"
  SetOutPath "$INSTDIR\addons\Quake_1"
  File "${BUILDDIR}\addons\Quake_1\*.*"
  SetOutPath "$INSTDIR\addons\Quake_2"
  File "${BUILDDIR}\addons\Quake_2\*.*"
  SetOutPath "$INSTDIR\addons\Quake_3"
  File "${BUILDDIR}\addons\Quake_3\*.*"
  SetOutPath "$INSTDIR\addons\Quake_4"
  File "${BUILDDIR}\addons\Quake_4\*.*"
  SetOutPath "$INSTDIR\addons\RTCW"
  File "${BUILDDIR}\addons\RTCW\*.*"
  SetOutPath "$INSTDIR\addons\RTCW-ET"
  File "${BUILDDIR}\addons\RTCW-ET\*.*"
  SetOutPath "$INSTDIR\addons\Sin"
  File "${BUILDDIR}\addons\Sin\*.*"
  SetOutPath "$INSTDIR\addons\SOF"
  File "${BUILDDIR}\addons\SOF\*.*"
  SetOutPath "$INSTDIR\addons\SoF2"
  File "${BUILDDIR}\addons\SoF2\*.*"
  SetOutPath "$INSTDIR\addons\STVEF"
  File "${BUILDDIR}\addons\STVEF\*.*"
  SetOutPath "$INSTDIR\addons\Sylphis"
  File "${BUILDDIR}\addons\Sylphis\*.*"
  SetOutPath "$INSTDIR\addons\Torque"
  File "${BUILDDIR}\addons\Torque\*.*"
  SetOutPath "$INSTDIR\addons\Warsow"
  File "${BUILDDIR}\addons\Warsow\*.*"
  SetOutPath "$INSTDIR\addons\WildWest"
  File "${BUILDDIR}\addons\WildWest\*.*"
  SetOutPath "$INSTDIR\addons"
  File "${BUILDDIR}\addons\*.*"
  SetOutPath "$INSTDIR\dlls"
  File "${BUILDDIR}\dlls\*.*"
  SetOutPath "$INSTDIR\images"
  File "${BUILDDIR}\images\*.*"
  SetOutPath "$INSTDIR\lgicons"
  File "${BUILDDIR}\lgicons\*.*"
  SetOutPath "$INSTDIR\Lib"
  File "${BUILDDIR}\Lib\*.*"
  SetOutPath "$INSTDIR\plugins"
  File "${BUILDDIR}\plugins\*.*"
  SetOutPath "$INSTDIR\quarkpy"
  File "${BUILDDIR}\quarkpy\*.*"
  SetOutPath "$INSTDIR"
  File "${BUILDDIR}\*.*"
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
SectionEnd

Section "$(TEXT_SEC02_TITLE)" SEC02
  ;FIXME: Manually update required!
  SetOutPath "$INSTDIR\help\colorconverter"
  File "${BUILDDIR}\help\colorconverter\*.*"
  SetOutPath "$INSTDIR\help\triangleUV"
  File "${BUILDDIR}\help\triangleUV\*.*"

  SetOutPath "$INSTDIR\help\pics"
  File "${BUILDDIR}\help\pics\*.*"
  SetOutPath "$INSTDIR\help\zips"
  File "${BUILDDIR}\help\zips\*.*"
  SetOutPath "$INSTDIR\help"
  File "${BUILDDIR}\help\*.*"
SectionEnd

Section "$(TEXT_SEC03_TITLE)" SEC03
  ;These are needed:
  ;DevIL.dll needs VC2005 runtime (MSVCP80.dll, MSVCR80.dll)
  ;HLLib.dll needs VC2010 runtime (MSVCP100.dll, MSVCR100.dll)
  ;md5dll.dll needs default VC runtime (msvcrt.dll)
  ;python.dll needs VC2003 runtime (MSVCR71.dll) ;Note that there are no VC2003, so we will have to include this library manually.

  Call InstallWinInstall ;First, we need to install Windows Install 3.1 (minimum) in order to run the rest of the installers.
  Call InstallVC2005Redist
  ;Call InstallVC2008Redist
  Call InstallVC2010Redist
  ;Call InstallVC2013Redist

  Call InstallIE4SP2

  Call InstallDirectX
SectionEnd

Section "$(TEXT_SEC04_TITLE)" SEC04
  ;SetShellVarContext all
  SetOutPath $INSTDIR ;To set the working directory for the shortcuts
  CreateDirectory "$SMPROGRAMS\QuArK"
  CreateShortCut "$SMPROGRAMS\QuArK\QuArK.lnk" "$INSTDIR\QuArK.exe"
  CreateShortCut "$SMPROGRAMS\QuArK\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\QuArK\Forum.lnk" "${PRODUCT_WEB_FORUM}"
  CreateShortCut "$SMPROGRAMS\QuArK\Online Infobase.lnk" "${PRODUCT_INFOBASE}"
  CreateShortCut "$SMPROGRAMS\QuArK\Readme.lnk" "$INSTDIR\README.txt"
  ;CreateShortCut "$SMPROGRAMS\QuArK\Uninstall.lnk" "$INSTDIR\uninst.exe"   ;Against Windows 95+ Guidelines; can be done through the Add/Remove Programs configuration screen panel.
SectionEnd

Section /o "$(TEXT_SEC05_TITLE)" SEC05
  ;SetShellVarContext all
  SetOutPath $INSTDIR ;To set the working directory for the shortcuts
  CreateShortCut "$DESKTOP\QuArK.lnk" "$INSTDIR\QuArK.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\QuArK.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME_FULL} (${PRODUCT_NAME})"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\QuArK.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "HelpLink" "${PRODUCT_WEB_FORUM}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Readme" "$INSTDIR\README.txt"
SectionEnd

Section Uninstall
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\addons\WildWest\*.*"
  Delete "$INSTDIR\addons\Warsow\*.*"
  Delete "$INSTDIR\addons\Torque\*.*"
  Delete "$INSTDIR\addons\Sylphis\*.*"
  Delete "$INSTDIR\addons\STVEF\*.*"
  Delete "$INSTDIR\addons\SoF2\*.*"
  Delete "$INSTDIR\addons\SOF\*.*"
  Delete "$INSTDIR\addons\Sin\*.*"
  Delete "$INSTDIR\addons\RTCW-ET\*.*"
  Delete "$INSTDIR\addons\RTCW\*.*"
  Delete "$INSTDIR\addons\Quake_4\*.*"
  Delete "$INSTDIR\addons\Quake_3\*.*"
  Delete "$INSTDIR\addons\Quake_2\*.*"
  Delete "$INSTDIR\addons\Quake_1\*.*"
  Delete "$INSTDIR\addons\Prey\*.*"
  Delete "$INSTDIR\addons\NEXUIZ\*.*"
  Delete "$INSTDIR\addons\MOHAA\*.*"
  Delete "$INSTDIR\addons\KingPin\*.*"
  Delete "$INSTDIR\addons\JK2\*.*"
  Delete "$INSTDIR\addons\JA\*.*"
  Delete "$INSTDIR\addons\Hexen_II\*.*"
  Delete "$INSTDIR\addons\Heretic_II\*.*"
  Delete "$INSTDIR\addons\Half-Life2\*.*"
  Delete "$INSTDIR\addons\Half-Life\*.*"
  Delete "$INSTDIR\addons\Genesis3D\*.*"
  Delete "$INSTDIR\addons\FAKK2\*.*"
  Delete "$INSTDIR\addons\EF2\*.*"
  Delete "$INSTDIR\addons\Doom_3\*.*"
  Delete "$INSTDIR\addons\Crystal_Space\*.*"
  Delete "$INSTDIR\addons\Cry_of_Fear\*.*"
  Delete "$INSTDIR\addons\CoD2\*.*"
  Delete "$INSTDIR\addons\CoD1\*.*"
  Delete "$INSTDIR\addons\Alice\maps\*.*"
  Delete "$INSTDIR\addons\Alice\*.*"
  Delete "$INSTDIR\addons\6DX\*.*"
  Delete "$INSTDIR\addons\*.*"
  Delete "$INSTDIR\dlls\*.*"
  Delete "$INSTDIR\help\pics\*.*"
  Delete "$INSTDIR\help\*.*"
  Delete "$INSTDIR\images\*.*"
  Delete "$INSTDIR\lgicons\*.*"
  Delete "$INSTDIR\Lib\*.*"
  Delete "$INSTDIR\plugins\*.*"
  Delete "$INSTDIR\quarkpy\*.*"
  Delete "$INSTDIR\*.*"


  Delete "$SMPROGRAMS\QuArK\*.*"
  Delete "$DESKTOP\QuArK.lnk"


  RMDir "$INSTDIR\addons\WildWest"
  RMDir "$INSTDIR\addons\Warsow"
  RMDir "$INSTDIR\addons\Torque"
  RMDir "$INSTDIR\addons\Sylphis"
  RMDir "$INSTDIR\addons\STVEF"
  RMDir "$INSTDIR\addons\SoF2"
  RMDir "$INSTDIR\addons\SOF"
  RMDir "$INSTDIR\addons\Sin"
  RMDir "$INSTDIR\addons\RTCW-ET"
  RMDir "$INSTDIR\addons\RTCW"
  RMDir "$INSTDIR\addons\Quake_4"
  RMDir "$INSTDIR\addons\Quake_3"
  RMDir "$INSTDIR\addons\Quake_2"
  RMDir "$INSTDIR\addons\Quake_1"
  RMDir "$INSTDIR\addons\Prey"
  RMDir "$INSTDIR\addons\NEXUIZ"
  RMDir "$INSTDIR\addons\MOHAA"
  RMDir "$INSTDIR\addons\KingPin"
  RMDir "$INSTDIR\addons\JK2"
  RMDir "$INSTDIR\addons\JA"
  RMDir "$INSTDIR\addons\Hexen_II"
  RMDir "$INSTDIR\addons\Heretic_II"
  RMDir "$INSTDIR\addons\Half-Life2"
  RMDir "$INSTDIR\addons\Half-Life"
  RMDir "$INSTDIR\addons\Genesis3D"
  RMDir "$INSTDIR\addons\FAKK2"
  RMDir "$INSTDIR\addons\EF2"
  RMDir "$INSTDIR\addons\Doom_3"
  RMDir "$INSTDIR\addons\Crystal_Space"
  RMDir "$INSTDIR\addons\Cry_of_Fear"
  RMDir "$INSTDIR\addons\CoD2"
  RMDir "$INSTDIR\addons\CoD1"
  RMDir "$INSTDIR\addons\Alice"
  RMDir "$INSTDIR\addons\6DX"
  RMDir "$INSTDIR\addons"
  RMDir "$INSTDIR\dlls"
  RMDir "$INSTDIR\help\pics"
  RMDir "$INSTDIR\help"
  RMDir "$INSTDIR\images"
  RMDir "$INSTDIR\lgicons"
  RMDir "$INSTDIR\Lib"
  RMDir "$INSTDIR\plugins"
  RMDir "$INSTDIR\quarkpy"
  RMDir "$INSTDIR"
  RMDir "$SMPROGRAMS\QuArK"


  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "$(TEXT_SEC01_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "$(TEXT_SEC02_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "$(TEXT_SEC03_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "$(TEXT_SEC04_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "$(TEXT_SEC05_DESC)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONEXCLAMATION|MB_YESNO|MB_DEFBUTTON2 "$(TEXT_UNINSTALL1)" IDYES +2
  Abort
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(TEXT_UNINSTALL2)" IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(TEXT_UNINSTALL3)"
FunctionEnd
