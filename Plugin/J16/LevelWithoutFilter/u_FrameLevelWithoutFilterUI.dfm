inherited LevelWithoutFilterUI: TLevelWithoutFilterUI
  Height = 86
  ExplicitHeight = 86
  inherited Panel1: TPanel
    Height = 86
    ExplicitHeight = 77
    inherited Label1: TLabel
      Top = 32
      ExplicitTop = 32
    end
    inherited lbExamineItemCaption: TLabel
      Top = 32
      ExplicitTop = 32
    end
    inherited Gauge1: TGauge
      Top = 29
      ExplicitTop = 29
    end
    object Label2: TLabel [3]
      Left = 171
      Top = 56
      Width = 97
      Height = 13
      Caption = #35835#25968#31283#23450#26102#38388'(ms):'
    end
    inherited edInlineInsLoss: TCnEdit
      Top = 29
      ExplicitTop = 29
    end
    object Button1: TButton
      Left = 624
      Top = 41
      Width = 69
      Height = 22
      Anchors = [akTop, akRight]
      Caption = #32479#35745#25968#25454
      TabOrder = 2
      OnClick = Button1Click
    end
    object edtLevelStableDelay: TCnEdit
      Left = 269
      Top = 53
      Width = 76
      Height = 21
      ImeMode = imClose
      ImeName = #20013#25991'('#31616#20307') - '#26497#28857#20116#31508
      TabOrder = 3
      Text = '1000'
      TextType = FloatText
    end
  end
end
