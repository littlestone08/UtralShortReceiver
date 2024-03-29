object frmUart: TfrmUart
  Left = 487
  Top = 156
  Caption = 'RDA1005L'
  ClientHeight = 597
  ClientWidth = 810
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clBlack
  Font.Height = -16
  Font.Name = #23435#20307
  Font.Pitch = fpVariable
  Font.Style = [fsBold]
  OldCreateOrder = True
  OnCreate = FormCreate
  DesignSize = (
    810
    597)
  PixelsPerInch = 96
  TextHeight = 16
  object StatusBar1: TStatusBar
    Left = 0
    Top = 577
    Width = 810
    Height = 20
    Panels = <
      item
        Width = 250
      end
      item
        Width = 50
      end>
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 810
    Height = 24
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 41
    Caption = 'ToolBar1'
    ShowCaptions = True
    TabOrder = 1
    object cbbComPort: TComboBox
      Left = 0
      Top = 0
      Width = 100
      Height = 24
      Style = csDropDownList
      ItemHeight = 16
      TabOrder = 0
    end
    object ToolButton1: TToolButton
      Left = 100
      Top = 0
      Action = actOpen
      AutoSize = True
      Caption = #25171#24320
    end
    object ToolButton2: TToolButton
      Left = 145
      Top = 0
      Action = actClose
      AutoSize = True
      Caption = #20851#38381
    end
    object ToolButton3: TToolButton
      Left = 190
      Top = 0
      Action = actSetupSerial
      AutoSize = True
      Caption = #35774#32622
    end
    object ToolButton4: TToolButton
      Left = 235
      Top = 0
      Action = actRefresh
      AutoSize = True
      Caption = #21047#26032
    end
  end
  object btnAMCoffSet: TButton
    Left = 0
    Top = 304
    Width = 376
    Height = 26
    Caption = #35774#32622'AM'#31995#25968
    TabOrder = 2
    OnClick = btnCoffSetClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 456
    Width = 805
    Height = 119
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #28729#23337#32139
    Font.Pitch = fpVariable
    Font.Style = [fsBold]
    ParentColor = True
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnDblClick = Memo1DblClick
  end
  object AM0_A: TEdit
    Left = 0
    Top = 216
    Width = 160
    Height = 24
    TabOrder = 4
    Text = '1.0E0'
  end
  object AM0_B: TEdit
    Left = 216
    Top = 216
    Width = 160
    Height = 24
    TabOrder = 5
    Text = '1.0E0'
  end
  object AM1_A: TEdit
    Left = 0
    Top = 244
    Width = 160
    Height = 24
    TabOrder = 6
    Text = '1.0E0'
  end
  object AM1_B: TEdit
    Left = 216
    Top = 244
    Width = 160
    Height = 24
    TabOrder = 7
    Text = '1.0E0'
  end
  object AM2_A: TEdit
    Left = 0
    Top = 271
    Width = 160
    Height = 24
    TabOrder = 8
    Text = '1.0E0'
  end
  object AM2_B: TEdit
    Left = 216
    Top = 271
    Width = 160
    Height = 24
    TabOrder = 9
    Text = '1.0E0'
  end
  object FM0_A: TEdit
    Left = 0
    Top = 336
    Width = 160
    Height = 24
    TabOrder = 10
    Text = '1.0E0'
  end
  object FM0_B: TEdit
    Left = 216
    Top = 336
    Width = 160
    Height = 24
    TabOrder = 11
    Text = '1.0E0'
  end
  object FM1_A: TEdit
    Left = 0
    Top = 364
    Width = 160
    Height = 24
    TabOrder = 12
    Text = '1.0E0'
  end
  object FM1_B: TEdit
    Left = 216
    Top = 364
    Width = 160
    Height = 24
    TabOrder = 13
    Text = '1.0E0'
  end
  object FM2_A: TEdit
    Left = 0
    Top = 391
    Width = 160
    Height = 24
    TabOrder = 14
    Text = '1.0E0'
  end
  object FM2_B: TEdit
    Left = 216
    Top = 391
    Width = 160
    Height = 24
    TabOrder = 15
    Text = '1.0E0'
  end
  object Panel1: TPanel
    Left = 0
    Top = 32
    Width = 376
    Height = 176
    BevelOuter = bvLowered
    TabOrder = 16
    object Bevel2: TBevel
      Left = 286
      Top = 8
      Width = 58
      Height = 20
    end
    object lb_AM0_A: TLabel
      Left = 16
      Top = 32
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_AM0_A'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_AM0_B: TLabel
      Left = 200
      Top = 32
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_AM0_B'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_AM1_A: TLabel
      Left = 16
      Top = 56
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_AM1_A'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_AM1_B: TLabel
      Left = 200
      Top = 56
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_AM1_B'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_AM2_A: TLabel
      Left = 16
      Top = 80
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_AM2_A'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_AM2_B: TLabel
      Left = 200
      Top = 80
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_AM2_B'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_FM2_B: TLabel
      Left = 200
      Top = 152
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_FM2_B'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_FM2_A: TLabel
      Left = 16
      Top = 152
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_FM2_A'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_FM1_A: TLabel
      Left = 16
      Top = 128
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_FM1_A'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_FM0_A: TLabel
      Left = 16
      Top = 104
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_FM0_A'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_FM0_B: TLabel
      Left = 200
      Top = 104
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_FM0_B'
      Color = clBtnFace
      ParentColor = False
    end
    object lb_FM1_B: TLabel
      Left = 200
      Top = 128
      Width = 140
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lb_FM1_B'
      Color = clBtnFace
      ParentColor = False
    end
    object Label1: TLabel
      Left = 16
      Top = 10
      Width = 111
      Height = 16
      Caption = #22238#25253#20351#29992#31995#25968':'
      Color = clBtnFace
      ParentColor = False
    end
    object Bevel1: TBevel
      Left = 131
      Top = 8
      Width = 66
      Height = 20
    end
    object lbCoffApplied: TLabel
      Left = 136
      Top = 10
      Width = 34
      Height = 16
      Caption = #26410#30693
      Color = clBtnFace
      ParentColor = False
    end
    object Label2: TLabel
      Left = 208
      Top = 10
      Width = 77
      Height = 16
      Caption = #31995#25968#26377#25928':'
      Color = clBtnFace
      ParentColor = False
    end
    object lbCoffValid: TLabel
      Left = 294
      Top = 10
      Width = 34
      Height = 16
      Caption = #26410#30693
      Color = clBtnFace
      ParentColor = False
    end
  end
  object rgReportSel: TRadioGroup
    Left = 384
    Top = 337
    Width = 104
    Height = 80
    Caption = #22238#25253#26041#24335
    ItemIndex = 0
    Items.Strings = (
      #21407#22987#20540
      #20462#27491#20540)
    TabOrder = 17
  end
  object btnSetReportSel: TButton
    Left = 384
    Top = 425
    Width = 104
    Height = 25
    Caption = #35774#32622
    TabOrder = 18
    OnClick = btnSetReportSelClick
  end
  object Button1: TButton
    Left = 584
    Top = 395
    Width = 231
    Height = 1
    Caption = 'Button1'
    TabOrder = 19
  end
  object Button2: TButton
    Left = 698
    Top = 344
    Width = 112
    Height = 25
    Caption = #26597#35810#19978#25253#29366#24577
    TabOrder = 20
    OnClick = Button2Click
  end
  object btnAMCoffSet1: TButton
    Left = 0
    Top = 424
    Width = 376
    Height = 26
    Caption = #35774#32622'FM'#31995#25968
    TabOrder = 21
    OnClick = btnCoffSetClick
  end
  object btnWriteE2PROM: TButton
    Left = 698
    Top = 424
    Width = 112
    Height = 25
    Caption = #20889#20837'E2PROM'
    TabOrder = 22
    OnClick = btnWriteE2PROMClick
  end
  object rgCoffValid: TRadioGroup
    Left = 488
    Top = 336
    Width = 104
    Height = 80
    Caption = #31995#25968#26377#25928
    ItemIndex = 0
    Items.Strings = (
      #26080#25928
      #26377#25928)
    TabOrder = 23
  end
  object btnSetCoffValid: TButton
    Left = 488
    Top = 425
    Width = 104
    Height = 25
    Caption = #35774#32622
    TabOrder = 24
    OnClick = btnSetCoffValidClick
  end
  object ActionList1: TActionList
    Left = 528
    Top = 504
    object actOpen: TAction
      Caption = #37813#25779#32017
      OnExecute = actOpenExecute
    end
    object actClose: TAction
      Caption = #37711#25277#26868
      OnExecute = actCloseExecute
      OnUpdate = actSerialUpdateInfo
    end
    object actSetupSerial: TAction
      Caption = #29825#21095#30086
      OnExecute = actSetupSerialExecute
    end
    object actRefresh: TAction
      Caption = #37714#38155#26570
      OnExecute = actRefreshExecute
    end
  end
end
