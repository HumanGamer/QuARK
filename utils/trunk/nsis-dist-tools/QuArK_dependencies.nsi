; QuArK dependencies installer script for NSIS
; HomePage: https://quark.sourceforge.io/
; Author:  DanielPharos

; Modern UI 2 ------
!include MUI2.nsh
!include LogicLib.nsh
!include Sections.nsh
!include WinVer.nsh
SetCompress off ;To massively speed up starting the installer on older systems
CRCCheck off ;To massively speed up starting the installer on older systems
RequestExecutionLevel admin

!define SPLASHDIR "Z:\workspace\utils\nsis-dist-tools"
!define DEPENDENCYDIR "Z:\workspace\utils\nsis-dist-tools"
!define INSTALLER_EXENAME "quark-dependencies.exe"
!define PRODUCT_NAME "QuArK dependencies"
!define PRODUCT_NAME_FULL "Quake Army Knife dependencies"
!define PRODUCT_COPYRIGHT "Copyright (c) 2022"
!define PRODUCT_VERSION_NUMBER "1.0.0.0"
!define PRODUCT_VERSION_STRING "1.0.0.0"
!define PRODUCT_WEB_SITE "https://quark.sourceforge.io/"
!define PRODUCT_PUBLISHER "QuArK Development Team"

Name "${PRODUCT_NAME}"
OutFile "${INSTALLER_EXENAME}"
ShowInstDetails show

; MUI Settings
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install-blue.ico"
; Loads the splash window
!define MUI_WELCOMEFINISHPAGE_BITMAP "${SPLASHDIR}\install_splash.bmp"
; Loads the header picture
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${SPLASHDIR}\install_header.bmp"

; Language Selection Dialog Settings
!define MUI_LANGDLL_ALWAYSSHOW

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Component page
!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_COMPONENTS
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_LINK "QuArK website"
!define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"
!insertmacro MUI_PAGE_FINISH

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
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_ENGLISH} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_FRENCH} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_GERMAN} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_TRADCHINESE} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_DUTCH} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_NORWEGIAN} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_FINNISH} "Windows NT4 SP3"
;LangString TEXT_SecWinNT4SP3_TITLE ${LANG_GREEK} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_RUSSIAN} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_POLISH} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_UKRAINIAN} "Windows NT4 SP3"
LangString TEXT_SecWinNT4SP3_TITLE ${LANG_ARABIC} "Windows NT4 SP3"

LangString TEXT_SecWinNT4SP3_DESC ${LANG_ENGLISH} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_FRENCH} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_GERMAN} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_TRADCHINESE} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_DUTCH} "Service Pack 3 voor Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_NORWEGIAN} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_FINNISH} "Service Pack 3 for Microsoft Windows NT 4."
;LangString TEXT_SecWinNT4SP3_DESC ${LANG_GREEK} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_RUSSIAN} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_POLISH} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_UKRAINIAN} "Service Pack 3 for Microsoft Windows NT 4."
LangString TEXT_SecWinNT4SP3_DESC ${LANG_ARABIC} "Service Pack 3 for Microsoft Windows NT 4."

LangString TEXT_SecWinInstaller2_TITLE ${LANG_ENGLISH} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_FRENCH} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_GERMAN} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_TRADCHINESE} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_DUTCH} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_NORWEGIAN} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_FINNISH} "Windows Installer 2"
;LangString TEXT_SecWinInstaller2_TITLE ${LANG_GREEK} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_RUSSIAN} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_POLISH} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_UKRAINIAN} "Windows Installer 2"
LangString TEXT_SecWinInstaller2_TITLE ${LANG_ARABIC} "Windows Installer 2"

LangString TEXT_SecWinInstaller2_DESC ${LANG_ENGLISH} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_FRENCH} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_GERMAN} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_TRADCHINESE} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_DUTCH} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_NORWEGIAN} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_FINNISH} "Windows Installer 2.0."
;LangString TEXT_SecWinInstaller2_DESC ${LANG_GREEK} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_RUSSIAN} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_POLISH} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_UKRAINIAN} "Windows Installer 2.0."
LangString TEXT_SecWinInstaller2_DESC ${LANG_ARABIC} "Windows Installer 2.0."

LangString TEXT_SecVC2005Redist_TITLE ${LANG_ENGLISH} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_FRENCH} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_GERMAN} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_TRADCHINESE} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_DUTCH} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_NORWEGIAN} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_FINNISH} "Visual C++ 2005 runtime"
;LangString TEXT_SecVC2005Redist_TITLE ${LANG_GREEK} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_RUSSIAN} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_POLISH} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_UKRAINIAN} "Visual C++ 2005 runtime"
LangString TEXT_SecVC2005Redist_TITLE ${LANG_ARABIC} "Visual C++ 2005 runtime"

LangString TEXT_SecVC2005Redist_DESC ${LANG_ENGLISH} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_FRENCH} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_GERMAN} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_TRADCHINESE} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_DUTCH} "Microsoft Visual C++ 2005 runtime bestanden."
LangString TEXT_SecVC2005Redist_DESC ${LANG_NORWEGIAN} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_FINNISH} "Microsoft Visual C++ 2005 runtime files."
;LangString TEXT_SecVC2005Redist_DESC ${LANG_GREEK} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_RUSSIAN} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_POLISH} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_UKRAINIAN} "Microsoft Visual C++ 2005 runtime files."
LangString TEXT_SecVC2005Redist_DESC ${LANG_ARABIC} "Microsoft Visual C++ 2005 runtime files."

LangString TEXT_SecVC2008Redist_TITLE ${LANG_ENGLISH} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_FRENCH} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_GERMAN} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_TRADCHINESE} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_DUTCH} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_NORWEGIAN} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_FINNISH} "Visual C++ 2008 runtime"
;LangString TEXT_SecVC2008Redist_TITLE ${LANG_GREEK} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_RUSSIAN} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_POLISH} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_UKRAINIAN} "Visual C++ 2008 runtime"
LangString TEXT_SecVC2008Redist_TITLE ${LANG_ARABIC} "Visual C++ 2008 runtime"

LangString TEXT_SecVC2008Redist_DESC ${LANG_ENGLISH} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_FRENCH} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_GERMAN} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_TRADCHINESE} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_DUTCH} "Microsoft Visual C++ 2008 runtime bestanden."
LangString TEXT_SecVC2008Redist_DESC ${LANG_NORWEGIAN} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_FINNISH} "Microsoft Visual C++ 2008 runtime files."
;LangString TEXT_SecVC2008Redist_DESC ${LANG_GREEK} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_RUSSIAN} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_POLISH} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_UKRAINIAN} "Microsoft Visual C++ 2008 runtime files."
LangString TEXT_SecVC2008Redist_DESC ${LANG_ARABIC} "Microsoft Visual C++ 2008 runtime files."

LangString TEXT_SecVC2010Redist_TITLE ${LANG_ENGLISH} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_FRENCH} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_GERMAN} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_TRADCHINESE} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_DUTCH} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_NORWEGIAN} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_FINNISH} "Visual C++ 2010 runtime"
;LangString TEXT_SecVC2010Redist_TITLE ${LANG_GREEK} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_RUSSIAN} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_POLISH} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_UKRAINIAN} "Visual C++ 2010 runtime"
LangString TEXT_SecVC2010Redist_TITLE ${LANG_ARABIC} "Visual C++ 2010 runtime"

LangString TEXT_SecVC2010Redist_DESC ${LANG_ENGLISH} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_FRENCH} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_GERMAN} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_TRADCHINESE} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_DUTCH} "Microsoft Visual C++ 2010 runtime bestanden."
LangString TEXT_SecVC2010Redist_DESC ${LANG_NORWEGIAN} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_FINNISH} "Microsoft Visual C++ 2010 runtime files."
;LangString TEXT_SecVC2010Redist_DESC ${LANG_GREEK} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_RUSSIAN} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_POLISH} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_UKRAINIAN} "Microsoft Visual C++ 2010 runtime files."
LangString TEXT_SecVC2010Redist_DESC ${LANG_ARABIC} "Microsoft Visual C++ 2010 runtime files."

LangString TEXT_SecVC2013Redist_TITLE ${LANG_ENGLISH} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_FRENCH} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_GERMAN} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_TRADCHINESE} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_DUTCH} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_NORWEGIAN} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_FINNISH} "Visual C++ 2013 runtime"
;LangString TEXT_SecVC2013Redist_TITLE ${LANG_GREEK} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_RUSSIAN} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_POLISH} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_UKRAINIAN} "Visual C++ 2013 runtime"
LangString TEXT_SecVC2013Redist_TITLE ${LANG_ARABIC} "Visual C++ 2013 runtime"

LangString TEXT_SecVC2013Redist_DESC ${LANG_ENGLISH} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_FRENCH} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_GERMAN} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_TRADCHINESE} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_DUTCH} "Microsoft Visual C++ 2013 runtime bestanden."
LangString TEXT_SecVC2013Redist_DESC ${LANG_NORWEGIAN} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_FINNISH} "Microsoft Visual C++ 2013 runtime files."
;LangString TEXT_SecVC2013Redist_DESC ${LANG_GREEK} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_RUSSIAN} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_POLISH} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_UKRAINIAN} "Microsoft Visual C++ 2013 runtime files."
LangString TEXT_SecVC2013Redist_DESC ${LANG_ARABIC} "Microsoft Visual C++ 2013 runtime files."

LangString TEXT_SecIE4SP2_TITLE ${LANG_ENGLISH} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_FRENCH} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_GERMAN} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_TRADCHINESE} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_DUTCH} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_NORWEGIAN} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_FINNISH} "Internet Explorer 4 SP2"
;LangString TEXT_SecIE4SP2_TITLE ${LANG_GREEK} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_RUSSIAN} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_POLISH} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_UKRAINIAN} "Internet Explorer 4 SP2"
LangString TEXT_SecIE4SP2_TITLE ${LANG_ARABIC} "Internet Explorer 4 SP2"

LangString TEXT_SecIE4SP2_DESC ${LANG_ENGLISH} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_FRENCH} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_GERMAN} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_TRADCHINESE} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_DUTCH} "Service Pack 2 voor Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_NORWEGIAN} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_FINNISH} "Service Pack 2 for Microsoft Internet Explorer 4.01."
;LangString TEXT_SecIE4SP2_DESC ${LANG_GREEK} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_RUSSIAN} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_POLISH} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_UKRAINIAN} "Service Pack 2 for Microsoft Internet Explorer 4.01."
LangString TEXT_SecIE4SP2_DESC ${LANG_ARABIC} "Service Pack 2 for Microsoft Internet Explorer 4.01."

LangString TEXT_SecDirectX9_TITLE ${LANG_ENGLISH} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_FRENCH} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_GERMAN} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_TRADCHINESE} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_DUTCH} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_NORWEGIAN} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_FINNISH} "DirectX 9"
;LangString TEXT_SecDirectX9_TITLE ${LANG_GREEK} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_RUSSIAN} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_POLISH} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_UKRAINIAN} "DirectX 9"
LangString TEXT_SecDirectX9_TITLE ${LANG_ARABIC} "DirectX 9"

LangString TEXT_SecDirectX9_DESC ${LANG_ENGLISH} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_FRENCH} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_GERMAN} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_TRADCHINESE} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_DUTCH} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_NORWEGIAN} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_FINNISH} "DirectX 9.0."
;LangString TEXT_SecDirectX9_DESC ${LANG_GREEK} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_RUSSIAN} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_POLISH} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_UKRAINIAN} "DirectX 9.0."
LangString TEXT_SecDirectX9_DESC ${LANG_ARABIC} "DirectX 9.0."

; Installer executable settings
VIProductVersion "${PRODUCT_VERSION_NUMBER}"

VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_FRENCH} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_FRENCH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_FRENCH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_FRENCH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_GERMAN} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_GERMAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_GERMAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_GERMAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_GERMAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_TRADCHINESE} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_TRADCHINESE} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_TRADCHINESE} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_DUTCH} "ProductName" "Quake Army Knife afhankelijkheden installatiebestand"
;VIAddVersionKey /LANG=${LANG_DUTCH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_DUTCH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_DUTCH} "FileDescription" "Installatiebestand voor QuArK afhankelijkheden"
VIAddVersionKey /LANG=${LANG_DUTCH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_DUTCH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_NORWEGIAN} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_NORWEGIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_NORWEGIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_FINNISH} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_FINNISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_FINNISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_FINNISH} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_FINNISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_FINNISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

;VIAddVersionKey /LANG=${LANG_GREEK} "ProductName" "Quake Army Knife dependencies installer"
;;VIAddVersionKey /LANG=${LANG_GREEK} "CompanyName" "QuArK Development Team"
;VIAddVersionKey /LANG=${LANG_GREEK} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
;VIAddVersionKey /LANG=${LANG_GREEK} "FileDescription" "Installer for QuArK dependencies"
;VIAddVersionKey /LANG=${LANG_GREEK} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
;VIAddVersionKey /LANG=${LANG_GREEK} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_RUSSIAN} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_RUSSIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_RUSSIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_POLISH} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_POLISH} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_POLISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_POLISH} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_POLISH} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_POLISH} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_UKRAINIAN} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_UKRAINIAN} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_UKRAINIAN} "ProductVersion" "${PRODUCT_VERSION_STRING}"

VIAddVersionKey /LANG=${LANG_ARABIC} "ProductName" "Quake Army Knife dependencies installer"
;VIAddVersionKey /LANG=${LANG_ARABIC} "CompanyName" "QuArK Development Team"
VIAddVersionKey /LANG=${LANG_ARABIC} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ARABIC} "FileDescription" "Installer for QuArK dependencies"
VIAddVersionKey /LANG=${LANG_ARABIC} "FileVersion" "${PRODUCT_VERSION_NUMBER}"
VIAddVersionKey /LANG=${LANG_ARABIC} "ProductVersion" "${PRODUCT_VERSION_STRING}"
; MUI end ------

; Windows NT SP3 installer ------

Function _isInstalledWinNT4SP3
  ${IfNot} ${IsWinNT4}
  ${OrIf} ${AtLeastServicePack} 3
    Push 1
    Return
  ${EndIf}
  Push 0
FunctionEnd

Section /o "$(TEXT_SecWinNT4SP3_TITLE)" SecWinNT4SP3
  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\WinNT4\winnt40sp3.exe"
  ExecWait "$TEMP\winnt40sp3.exe"
  Delete "$TEMP\winnt40sp3.exe"
SectionEnd



; Windows Installer ------

; The VC++ Runtime SP1 2005 installer lowered the requirements to Windows Installer 2.0.
; https://docs.microsoft.com/en-us/windows/win32/msi/released-versions-of-windows-installer

Section /o "$(TEXT_SecWinInstaller2_TITLE)" SecWinInstaller2
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
    ; Reboot
  ${EndIf}
SectionEnd



; Internet Explorer 4 installer ------

;Official documentation says:
;- For Microsoft Windows NT:
;  You must be running Service Pack 3 (or higher)

Function _isInstalledIE4SP2
  ${IfNot} ${IsWin95}
  ${AndIfNot} ${IsWinNT4}
    Push 1
    Return
  ${EndIf}

  ;Windows 95C (version 4.03.1216) and higher already include IE4
  ;Note: WinVer.nsh's service pack code doesn't work for Windows 95 OSR's
  ${WinVerGetMinor} $0
  ${If} ${IsWin95}
  ${AndIf} $0 > 2
    Push 1
    Return
  ${EndIf}
  Push 0
FunctionEnd

Section /o "$(TEXT_SecIE4SP2_TITLE)" SecIE4SP2
  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\Microsoft Internet Explorer 4.01 SP2\*.*"
  ExecWait "$TEMP\IE4SETUP.EXE /Q /T:$\"$TEMP\IE4Setup$\"" ;FIXME: Untested if this actually installs too, or only extracts!
  Delete "$TEMP\*.*"
  RMDir /r $TEMP\IE4Setup
SectionEnd



; Visual C++ redistributable installers ------

; See: https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

; Note that (at least) the VC2010 installer needs Internet Explorer 3.02 to be installed.

!include "VisualCRuntimeGUIDs.nsh"

Section /o "$(TEXT_SecVC2005Redist_TITLE)" SecVC2005Redist
  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\VC2005SP1MFC\vcredist_x86.EXE"
  ExecWait "$TEMP\vcredist_x86.EXE /q:a /c:$\"msiexec /i vcredist.msi /qn REBOOT=ReallySuppress$\""
  Delete "$TEMP\vcredist_x86.EXE"
SectionEnd

;Section /o "$(TEXT_SecVC2008Redist_TITLE)" SecVC2008Redist
;  SetOutPath $TEMP
;  File "${DEPENDENCYDIR}\VC2008SP1MFC\vcredist_x86.exe"
;  StrCpy $0 0
;  IfFileExists $SYSDIR\msvcrt.dll +2 0
;  File "${DEPENDENCYDIR}\MSVCRT\6.0.8797.0\msvcrt.dll"
;  StrCpy $0 1
;  ExecWait "$TEMP\vcredist_x86.exe /q"
;  Delete "$TEMP\vcredist_x86.exe"
;  ${If} $0 != 0
;    Delete "$TEMP\msvcrt.dll"
;  ${EndIf}
;SectionEnd

Section /o "$(TEXT_SecVC2010Redist_TITLE)" SecVC2010Redist
  SetOutPath $TEMP
  File "${DEPENDENCYDIR}\VC2010SP1MFC\vcredist_x86.exe"
  StrCpy $0 0
  IfFileExists $SYSDIR\msvcrt.dll +2 0
  File "${DEPENDENCYDIR}\MSVCRT\6.0.8797.0\msvcrt.dll"
  StrCpy $0 1
  ExecWait "$TEMP\vcredist_x86.exe /q /norestart"
  Delete "$TEMP\vcredist_x86.exe"
  ${If} $0 != 0
    Delete "$TEMP\msvcrt.dll"
  ${EndIf}
SectionEnd

;Section /o "$(TEXT_SecVC2013Redist_TITLE)" SecVC2013Redist
;  SetOutPath $TEMP
;  File "${DEPENDENCYDIR}\VC2013_12.0.40664.0\vcredist_x86.exe"
;  ExecWait "$TEMP\vcredist_x86.exe /install /quiet /norestart"
;  Delete "$TEMP\vcredist_x86.exe"
;SectionEnd



; DirectX installer ------

; https://aka.ms/dxsetup

; Based on: https://nsis.sourceforge.io/Detect_DirectX_Version
; Registry key only works for DirectX <= 9

Function _isInstalledDirectX9
  ;Pretend Windows 95 and NT 4 already have DirectX 9, so we don't try to install it.
  ${If} ${IsWin95}
  ${OrIf} ${IsWinNT4}
    Push 1
    Return
  ${EndIf}

  ;Windows 8 was released after DirectX 9's latest version.
  ${If} ${AtLeastWin8}
    Push 1
    Return
  ${EndIf}

  ClearErrors
  ReadRegStr $0 HKLM "Software\Microsoft\DirectX" "Version"
  IfErrors 0 AlreadyInstalled
  Push 0
  Return
AlreadyInstalled:
  StrCmp $0 "4.09.00.0904" RightVersion
  Push 0
  Return
RightVersion:
  Push 1
FunctionEnd

Section /o "$(TEXT_SecDirectX9_TITLE)" SecDirectX9
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
SectionEnd



!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecWinNT4SP3} "$(TEXT_SecWinNT4SP3_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecWinInstaller2} "$(TEXT_SecWinInstaller2_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecIE4SP2} "$(TEXT_SecIE4SP2_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecVC2005Redist} "$(TEXT_SecVC2005Redist_DESC)"
  ;!insertmacro MUI_DESCRIPTION_TEXT ${SecVC2008Redist} "$(TEXT_SecVC2008Redist_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecVC2010Redist} "$(TEXT_SecVC2010Redist_DESC)"
  ;!insertmacro MUI_DESCRIPTION_TEXT ${SecVC2013Redist} "$(TEXT_SecVC2013Redist_DESC)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDirectX9} "$(TEXT_SecDirectX9_DESC)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY

  Call _isInstalledIE4SP2
  Pop $0
  ${If} $0 == 0
    SectionGetFlags ${SecIE4SP2} $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags ${SecIE4SP2} $0

    Call _isInstalledWinNT4SP3
    Pop $0
    ${If} $0 == 0
      SectionGetFlags ${SecWinNT4SP3} $0
      IntOp $0 $0 | ${SF_SELECTED}
      SectionSetFlags ${SecWinNT4SP3} $0
    ${EndIf}
  ${EndIf}

  Call _isInstalledVC2005
  Pop $0
  ${If} $0 == 0
    SectionGetFlags ${SecVC2005Redist} $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags ${SecVC2005Redist} $0

    SectionGetFlags ${SecWinInstaller2} $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags ${SecWinInstaller2} $0
  ${EndIf}

;  Call _isInstalledVC2008
;  Pop $0
;  ${If} $0 == 0
;    SectionGetFlags ${SecVC2008Redist} $0
;    IntOp $0 $0 | ${SF_SELECTED}
;    SectionSetFlags ${SecVC2008Redist} $0
;
;    SectionGetFlags ${SecWinInstaller2} $0
;    IntOp $0 $0 | ${SF_SELECTED}
;    SectionSetFlags ${SecWinInstaller2} $0
;  {$EndIf}

  Call _isInstalledVC2010
  Pop $0
  ${If} $0 == 0
    SectionGetFlags ${SecVC2010Redist} $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags ${SecVC2010Redist} $0

    SectionGetFlags ${SecWinInstaller2} $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags ${SecWinInstaller2} $0
  ${EndIf}

;  Call _isInstalledVC2013
;  Pop $0
;  ${If} $0 == 0
;    SectionGetFlags ${SecVC2013Redist} $0
;    IntOp $0 $0 | ${SF_SELECTED}
;    SectionSetFlags ${SecVC2013Redist} $0
;
;    SectionGetFlags ${SecWinInstaller2} $0
;    IntOp $0 $0 | ${SF_SELECTED}
;    SectionSetFlags ${SecWinInstaller2} $0
;  ${EndIf}

  Call _isInstalledDirectX9
  Pop $0
  ${If} $0 == 0
    SectionGetFlags ${SecDirectX9} $0
    IntOp $0 $0 | ${SF_SELECTED}
    SectionSetFlags ${SecDirectX9} $0
  ${EndIf}
FunctionEnd
