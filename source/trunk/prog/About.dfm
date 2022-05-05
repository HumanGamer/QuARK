object AboutBox: TAboutBox
  Left = 153
  Top = 130
  HelpContext = -1
  ActiveControl = Edit1
  BorderStyle = bsDialog
  ClientHeight = 352
  ClientWidth = 753
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 737
    Height = 337
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    object Image1: TImage
      Left = 8
      Top = 8
      Width = 374
      Height = 297
    end
    object Bevel1: TBevel
      Left = 392
      Top = 8
      Width = 17
      Height = 321
      Shape = bsLeftLine
    end
    object ProgramIcon: TImage
      Left = 412
      Top = 13
      Width = 32
      Height = 32
      Stretch = True
      IsControl = True
    end
    object ProductName1: TLabel
      Left = 452
      Top = 11
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
    object ProductName2: TLabel
      Left = 468
      Top = 11
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
    object ProductName3: TLabel
      Left = 496
      Top = 11
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
    object ProductName4: TLabel
      Left = 508
      Top = 11
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
    object ProductName5: TLabel
      Left = 530
      Top = 11
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
    object ProductName6: TLabel
      Left = 537
      Top = 11
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
    object Version: TLabel
      Left = 452
      Top = 29
      Width = 3
      Height = 13
      IsControl = True
    end
    object Label1: TLabel
      Left = 28
      Top = 314
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
    object WebsiteAddress: TLabel
      Left = 472
      Top = 242
      Width = 2
      Height = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
    end
    object Copyright: TLabel
      Left = 452
      Top = 46
      Width = 3
      Height = 13
    end
    object UsedCompilerLabel: TLabel
      Left = 480
      Top = 290
      Width = 2
      Height = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
    end
    object RepositoryAddress: TLabel
      Left = 472
      Top = 258
      Width = 2
      Height = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 408
      Top = 256
      Width = 53
      Height = 13
      Caption = 'Repository:'
    end
    object Label2: TLabel
      Left = 408
      Top = 240
      Width = 56
      Height = 13
      Caption = 'HomePage:'
    end
    object Label4: TLabel
      Left = 408
      Top = 272
      Width = 120
      Height = 13
      Caption = 'QuArK Resource Forums:'
    end
    object ForumAddress: TLabel
      Left = 536
      Top = 274
      Width = 2
      Height = 11
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 408
      Top = 288
      Width = 68
      Height = 13
      Caption = 'Compiled with:'
    end
    object Registration: TLabel
      Left = 16
      Top = 256
      Width = 361
      Height = 24
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      Visible = False
    end
    object Memo1: TMemo
      Left = 408
      Top = 67
      Width = 313
      Height = 166
      ParentColor = True
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object OKButton: TButton
    Left = 535
    Top = 312
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
