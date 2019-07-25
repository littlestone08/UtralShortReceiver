object FrameCustomExamineItemUI: TFrameCustomExamineItemUI
  Left = 0
  Top = 0
  Width = 707
  Height = 46
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 707
    Height = 46
    Align = alClient
    TabOrder = 0
    DesignSize = (
      707
      46)
    object Label1: TLabel
      Left = 171
      Top = 16
      Width = 92
      Height = 13
      Caption = #36755#20837#32447#25554#25439'(dB)'#65306
    end
    object lbExamineItemCaption: TLabel
      Left = 32
      Top = 16
      Width = 60
      Height = 13
      Caption = #27979#35797#39033#21517#31216
    end
    object Gauge1: TGauge
      Left = 351
      Top = 13
      Width = 267
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Progress = 0
    end
    object btnToggle: TButton
      Left = 624
      Top = 13
      Width = 69
      Height = 22
      Anchors = [akTop, akRight]
      Caption = #31561#24453
      TabOrder = 1
      OnClick = btnToggleClick
    end
    object edInlineInsLoss: TCnEdit
      Left = 269
      Top = 13
      Width = 76
      Height = 21
      TabOrder = 0
      Text = '0'
      TextType = FloatText
    end
  end
end
