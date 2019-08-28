inherited LevelWithFilterUI: TLevelWithFilterUI
  Height = 84
  ExplicitHeight = 84
  inherited Panel1: TPanel
    Height = 84
    ExplicitHeight = 84
    inherited Label1: TLabel
      Top = 17
      ExplicitTop = 17
    end
    inherited lbExamineItemCaption: TLabel
      Top = 35
      ExplicitTop = 35
    end
    inherited Gauge1: TGauge
      Top = 14
      ExplicitTop = 14
    end
    object Label2: TLabel [3]
      Left = 171
      Top = 55
      Width = 97
      Height = 13
      Caption = #35835#25968#31283#23450#26102#38388'(ms):'
    end
    inherited edInlineInsLoss: TCnEdit
      Top = 14
      ExplicitTop = 14
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
    object RadioGroup1: TRadioGroup
      Left = 488
      Top = 41
      Width = 130
      Height = 32
      Caption = #25163#21160#27169#24335#36873#25321
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        #25918#22823
        #30452#36890)
      TabOrder = 3
    end
    object edtLevelStableDelay: TCnEdit
      Left = 269
      Top = 52
      Width = 76
      Height = 21
      ImeMode = imClose
      ImeName = #20013#25991'('#31616#20307') - '#26497#28857#20116#31508
      TabOrder = 4
      Text = '1000'
      TextType = FloatText
    end
  end
end
