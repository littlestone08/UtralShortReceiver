inherited frameMain: TframeMain
  ParentShowHint = False
  ShowHint = True
  object Splitter1: TSplitter [0]
    Left = -119
    Top = 76
    Height = 209
    Align = alRight
    ExplicitLeft = 432
    ExplicitTop = 192
    ExplicitHeight = 100
  end
  inherited ToolBar: TToolBar
    TabOrder = 3
    object ToolButton2: TToolButton
      Left = 266
      Top = 0
      Caption = #34920#26684#30446#24405
      ImageIndex = 0
      Style = tbsTextButton
      OnClick = ToolButton2Click
    end
    object ToolButton3: TToolButton
      Left = 330
      Top = 0
      Caption = #26085#24535#30446#24405
      ImageIndex = 1
      Style = tbsTextButton
      OnClick = ToolButton3Click
    end
    object ToolButton4: TToolButton
      Left = 394
      Top = 0
      Caption = #21319#32423#27169#26495
      ImageIndex = 2
      Style = tbsTextButton
      Visible = False
      OnClick = ToolButton4Click
    end
  end
  object Panel1: TPanel [3]
    Left = 0
    Top = 76
    Width = 190
    Height = 209
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter2: TSplitter
      Left = 0
      Top = 114
      Width = 190
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 300
      ExplicitWidth = 186
    end
    inline frameExamineList1: TframeExamineList
      Left = 0
      Top = 0
      Width = 190
      Height = 114
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 190
      ExplicitHeight = 95
      inherited ScrollBox1: TScrollBox
        Width = 190
        Height = 95
        Color = clActiveBorder
        ParentColor = False
        ExplicitWidth = 190
        ExplicitHeight = 95
        inherited GridPanel1: TGridPanel
          Width = 0
          Color = clGreen
          ExplicitWidth = 0
        end
      end
    end
    object pnlBatchTest: TPanel
      Left = 0
      Top = 117
      Width = 190
      Height = 92
      Align = alBottom
      TabOrder = 1
      object Splitter3: TSplitter
        Left = 61
        Top = 1
        Height = 90
        Align = alRight
        ExplicitLeft = 536
        ExplicitTop = 56
        ExplicitHeight = 100
      end
      object gpCheckedItems: TGridPanel
        Left = 1
        Top = 1
        Width = 60
        Height = 90
        Align = alClient
        Color = clMedGray
        ColumnCollection = <
          item
            Value = 20.000000000568860000
          end
          item
            Value = 19.999999999776800000
          end
          item
            Value = 19.999999999606610000
          end
          item
            Value = 19.999999999936150000
          end
          item
            Value = 20.000000000111570000
          end>
        ControlCollection = <>
        ParentBackground = False
        RowCollection = <
          item
            SizeStyle = ssAuto
            Value = 50.000000000000000000
          end
          item
            SizeStyle = ssAuto
            Value = 100.000000000000000000
          end
          item
            SizeStyle = ssAuto
          end>
        TabOrder = 0
      end
      object Panel2: TPanel
        Left = 64
        Top = 1
        Width = 125
        Height = 90
        Align = alRight
        TabOrder = 1
        DesignSize = (
          125
          90)
        object btnBatchToggle: TButton
          Left = 12
          Top = 40
          Width = 101
          Height = 37
          Anchors = [akLeft, akTop, akRight, akBottom]
          Caption = #24320#22987
          TabOrder = 1
          OnClick = btnBatchToggleClick
        end
        object edtSN: TEdit
          Left = 12
          Top = 13
          Width = 101
          Height = 21
          TabOrder = 0
          Text = 'edtSN'
        end
      end
    end
  end
  object Memo1: TMemo [4]
    Left = -116
    Top = 76
    Width = 567
    Height = 209
    Align = alRight
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    OnDblClick = Memo1DblClick
    ExplicitTop = 95
    ExplicitHeight = 190
  end
  object ToolBar1: TToolBar [5]
    Left = 0
    Top = 19
    Width = 451
    Height = 57
    ButtonHeight = 57
    ButtonWidth = 13
    Caption = 'ToolBar1'
    Color = clBtnFace
    DrawingStyle = dsGradient
    Flat = False
    ParentColor = False
    TabOrder = 2
    Transparent = True
    ExplicitTop = 38
  end
end
