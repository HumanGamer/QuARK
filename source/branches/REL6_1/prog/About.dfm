object AboutBox: TAboutBox
  Left = 71
  Top = 104
  HelpContext = -1
  ActiveControl = Edit1
  BorderStyle = bsDialog
  ClientHeight = 402
  ClientWidth = 626
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 609
    Height = 387
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    object Image1: TImage
      Left = 8
      Top = 8
      Width = 350
      Height = 360
    end
    object Bevel1: TBevel
      Left = 368
      Top = 8
      Width = 17
      Height = 361
      Shape = bsLeftLine
    end
    object ProgramIcon: TImage
      Left = 388
      Top = 29
      Width = 32
      Height = 32
      Stretch = True
      IsControl = True
    end
    object ProductName: TLabel
      Left = 428
      Top = 27
      Width = 17
      Height = 13
      Caption = 'Qu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      IsControl = True
    end
    object Version: TLabel
      Left = 429
      Top = 45
      Width = 156
      Height = 36
      Alignment = taCenter
      AutoSize = False
      IsControl = True
    end
    object Label2: TLabel
      Left = 444
      Top = 27
      Width = 22
      Height = 13
      Caption = 'ake'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 472
      Top = 27
      Width = 13
      Height = 13
      Caption = 'Ar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 484
      Top = 27
      Width = 16
      Height = 13
      Caption = 'my'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 508
      Top = 27
      Width = 9
      Height = 13
      Caption = 'K'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 516
      Top = 27
      Width = 22
      Height = 13
      Caption = 'nife'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 20
      Top = 370
      Width = 329
      Height = 11
      Caption = 
        'Logo designed by leonard "paniq" ritter - graphics and icons by ' +
        'gryphon and paniq'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
    end
    object Label8: TLabel
      Left = 392
      Top = 328
      Width = 172
      Height = 13
      Caption = 'http://www.planetquake.com/quark'
    end
    object Label10: TLabel
      Left = 376
      Top = 80
      Width = 221
      Height = 13
      Caption = 'Copyright (C) 1996-2000 Armin Rigo and others'
    end
    object Label9: TLabel
      Left = 478
      Top = 7
      Width = 100
      Height = 11
      Caption = 'Compiled with Delphi 5.0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
    end
    object Copyright: TLabel
      Left = 392
      Top = 232
      Width = 176
      Height = 13
      Caption = 'Armin Rigo (arigo@planetquake.com)'
      IsControl = True
    end
    object Label1: TLabel
      Left = 392
      Top = 264
      Width = 170
      Height = 13
      Caption = 'Decker (decker@planetquake.com)'
      IsControl = True
    end
    object Label11: TLabel
      Left = 392
      Top = 248
      Width = 192
      Height = 13
      Caption = 'Avery Andrews (tiglari@hexenworld.com)'
      IsControl = True
    end
    object Label12: TLabel
      Left = 392
      Top = 280
      Width = 182
      Height = 13
      Caption = 'Andy Vincent (andyvinc@hotmail.com)'
      IsControl = True
    end
    object Label13: TLabel
      Left = 392
      Top = 296
      Width = 162
      Height = 13
      Caption = 'Alexander Haarer (mac.@gmx.net)'
      IsControl = True
    end
    object Memo1: TMemo
      Left = 376
      Top = 96
      Width = 225
      Height = 129
      ParentColor = True
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object OKButton: TButton
    Left = 455
    Top = 352
    Width = 75
    Height = 24
    Cancel = True
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object Edit1: TEdit
    Left = 64
    Top = 440
    Width = 265
    Height = 21
    TabOrder = 2
  end
end
