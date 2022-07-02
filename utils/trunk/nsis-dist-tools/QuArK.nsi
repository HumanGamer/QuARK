; QuArK installer script for NSIS
; HomePage: https://quark.sourceforge.io/
; Author:  Fredrick Vamstad, DanielPharos & cdunde
; Date:     18 Aug. 2005 & 5 January 2007
; nullsoft NSIS installer program available at:
;   http://nsis.sourceforge.net

; Modern UI 2 ------
!include MUI2.nsh
!include LogicLib.nsh
SetCompressor /SOLID lzma   ; We will use LZMA for best compression
;RequestExecutionLevel admin

!define BUILDDIR "Z:\workspace\Copy of runtime"
!define SPLASHDIR "Z:\workspace\utils\nsis-dist-tools"
!define INSTALLER_EXENAME "quark-win32-6.6.0Beta8.exe"
!define PRODUCT_NAME "QuArK"
!define PRODUCT_NAME_FULL "Quake Army Knife"
!define PRODUCT_COPYRIGHT "Copyright (c) 2022"
!define PRODUCT_VERSION "6.6.0 Beta 8"
!define PRODUCT_VERSION_NUMBER "6.6.8.0"
!define PRODUCT_VERSION_STRING "6.6 (Beta-Release)"
!define PRODUCT_WEB_SITE "https://quark.sourceforge.io/"
!define PRODUCT_WEB_FORUM "https://quark.sourceforge.io/forums/"
!define PRODUCT_INFOBASE "https://quark.sourceforge.io/infobase/"
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

LangString TEXT_SEC03_TITLE ${LANG_ENGLISH} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_FRENCH} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_GERMAN} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_TRADCHINESE} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_DUTCH} "Start Menu snelkoppelingen"
LangString TEXT_SEC03_TITLE ${LANG_NORWEGIAN} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_FINNISH} "Start Menu shortcuts"
;LangString TEXT_SEC03_TITLE ${LANG_GREEK} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_RUSSIAN} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_POLISH} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_UKRAINIAN} "Start Menu shortcuts"
LangString TEXT_SEC03_TITLE ${LANG_ARABIC} "Start Menu shortcuts"

LangString TEXT_SEC04_TITLE ${LANG_ENGLISH} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_FRENCH} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_GERMAN} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_TRADCHINESE} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_DUTCH} "Bureaublad icoon"
LangString TEXT_SEC04_TITLE ${LANG_NORWEGIAN} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_FINNISH} "Desktop icon"
;LangString TEXT_SEC04_TITLE ${LANG_GREEK} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_RUSSIAN} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_POLISH} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_UKRAINIAN} "Desktop icon"
LangString TEXT_SEC04_TITLE ${LANG_ARABIC} "Desktop icon"

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

LangString TEXT_SEC03_DESC ${LANG_ENGLISH} "Create various shortcuts for QuArK in the Start Menu."
LangString TEXT_SEC03_DESC ${LANG_FRENCH} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_GERMAN} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_TRADCHINESE} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_DUTCH} "Creëert verschillende snelkoppelingen voor QuArK in het Start Menu."
LangString TEXT_SEC03_DESC ${LANG_NORWEGIAN} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_FINNISH} "Start Menu shortcuts."
;LangString TEXT_SEC03_DESC ${LANG_GREEK} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_RUSSIAN} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_POLISH} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_UKRAINIAN} "Start Menu shortcuts."
LangString TEXT_SEC03_DESC ${LANG_ARABIC} "Start Menu shortcuts."

LangString TEXT_SEC04_DESC ${LANG_ENGLISH} "Creates an icon to launch QuArK on the desktop."
LangString TEXT_SEC04_DESC ${LANG_FRENCH} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_GERMAN} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_TRADCHINESE} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_DUTCH} "Creëert een icoon om QuArK op te starten op het bureaublad."
LangString TEXT_SEC04_DESC ${LANG_NORWEGIAN} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_FINNISH} "Desktop icon."
;LangString TEXT_SEC04_DESC ${LANG_GREEK} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_RUSSIAN} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_POLISH} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_UKRAINIAN} "Desktop icon."
LangString TEXT_SEC04_DESC ${LANG_ARABIC} "Desktop icon."

LangString TEXT_DEPENDENCIES ${LANG_ENGLISH} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_FRENCH} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_GERMAN} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_TRADCHINESE} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_DUTCH} "Niet alle afhankelijkheden voor QuArK zijn geïnstalleerd. Voer a.u.b. ook de QuArK afhankelijkheden installer uit."
LangString TEXT_DEPENDENCIES ${LANG_NORWEGIAN} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_FINNISH} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
;LangString TEXT_DEPENDENCIES ${LANG_GREEK} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_RUSSIAN} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_POLISH} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_UKRAINIAN} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."
LangString TEXT_DEPENDENCIES ${LANG_ARABIC} "Not all dependencies necessary for QuArK are installed. Please also run the QuArK dependencies installer."

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
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_FRENCH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_FRENCH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_FRENCH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_FRENCH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_GERMAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_GERMAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_GERMAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_GERMAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_TRADCHINESE} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_TRADCHINESE} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_DUTCH} "ProductName" "Quake Army Knife installatiebestand"
;VIAddVersionKey /LANG=${LANG_DUTCH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_DUTCH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_DUTCH} "FileDescription" "Installatiebestand voor de Quake Army Knife"
VIAddVersionKey /LANG=${LANG_DUTCH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_DUTCH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_NORWEGIAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_NORWEGIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_FINNISH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_FINNISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_FINNISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_FINNISH} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_FINNISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_FINNISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

;VIAddVersionKey /LANG=${LANG_GREEK} "ProductName" "Quake Army Knife installer"
;;VIAddVersionKey /LANG=${LANG_GREEK} "CompanyName" "QuArK Development Team"
;VIAddVersionKey /LANG=${LANG_GREEK} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
;VIAddVersionKey /LANG=${LANG_GREEK} "FileDescription" "Installer for the Quake Army Knife"
;VIAddVersionKey /LANG=${LANG_GREEK} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
;VIAddVersionKey /LANG=${LANG_GREEK} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_RUSSIAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_RUSSIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_POLISH} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_POLISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_POLISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_POLISH} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_POLISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_POLISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_UKRAINIAN} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_UKRAINIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_ARABIC} "ProductName" "Quake Army Knife installer"
;VIAddVersionKey /LANG=${LANG_ARABIC} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_ARABIC} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ARABIC} "FileDescription" "Installer for the Quake Army Knife"
VIAddVersionKey /LANG=${LANG_ARABIC} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_ARABIC} "ProductVersion" "${PRODUCT_VERSION_STRING}"
; MUI end ------


!include "VisualCRuntimeGUIDs.nsh"


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
  SetOutPath "$INSTDIR\addons\Daikatana"
  File "${BUILDDIR}\addons\Daikatana\*.*"
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
  SetOutPath "$INSTDIR\addons\Warfork"
  File "${BUILDDIR}\addons\Warfork\*.*"
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

  ;---

  ;These are needed:
  ;DevIL.dll needs VC2005 runtime (MSVCP80.dll, MSVCR80.dll)
  ;HLLib.dll needs VC2010 runtime (MSVCP100.dll, MSVCR100.dll)
  ;md5dll.dll needs default VC runtime (msvcrt.dll)
  ;python.dll needs VC2003 runtime (MSVCR71.dll) ;Note that there are no VC2003, so we will have to include this library manually.

  Call _isInstalledVC2005
  Pop $0

  Call _isInstalledVC2010
  Pop $1

  ;FIXME: Check Windows IE4 SP2
  ;FIXME: Check DirectX9

  ${If} $0 == 0
  ${OrIf} $1 == 0
    MessageBox MB_ICONEXCLAMATION|MB_OK "$(TEXT_DEPENDENCIES)"
  ${EndIf}
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

Section /o "$(TEXT_SEC04_TITLE)" SEC04
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
  Delete "$INSTDIR\addons\Warfork\*.*"
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
  Delete "$INSTDIR\addons\Daikatana\*.*"
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
  RMDir "$INSTDIR\addons\Warfork"
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
  RMDir "$INSTDIR\addons\Daikatana"
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
