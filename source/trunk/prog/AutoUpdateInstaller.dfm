object AutoUpdateInstaller: TAutoUpdateInstaller
  Left = 152
  Top = 123
  Width = 500
  Height = 350
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'QuArK - Online Update Installer'
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnResize = FormRezize
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 235
    Height = 13
    Caption = 'QuArK is now installing the updates. Please wait...'
  end
  object StopBtn: TButton
    Left = 192
    Top = 264
    Width = 105
    Height = 41
    Cancel = True
    Caption = 'Stop'
    TabOrder = 0
    OnClick = StopBtnClick
  end
  object pgbInstall: TProgressBar
    Left = 8
    Top = 128
    Width = 473
    Height = 49
    Step = 0
    TabOrder = 1
  end
end
