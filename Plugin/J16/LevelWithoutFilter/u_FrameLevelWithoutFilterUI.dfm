inherited LevelWithoutFilterUI: TLevelWithoutFilterUI
  Height = 184
  ExplicitHeight = 184
  inherited Panel1: TPanel
    Height = 184
    ExplicitHeight = 184
    inherited Label1: TLabel
      Top = 32
      ExplicitTop = 32
    end
    inherited lbExamineItemCaption: TLabel
      Top = 82
      ExplicitTop = 82
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
    inherited btnToggle: TButton
      Top = 73
      ExplicitTop = 73
    end
    inherited edInlineInsLoss: TCnEdit
      Top = 29
      ExplicitTop = 29
    end
    object Button1: TButton
      Left = 624
      Top = 101
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
    object gpFMThreshold: TGroupBox
      Left = 171
      Top = 80
      Width = 174
      Height = 98
      Caption = 'FM'#20999#25442#28857
      TabOrder = 4
      object Label3: TLabel
        Left = 16
        Top = 16
        Width = 64
        Height = 13
        Caption = #25918#22823'->'#30452#36890':'
      end
      object Label4: TLabel
        Left = 16
        Top = 35
        Width = 64
        Height = 13
        Caption = #30452#36890'->'#34928#20943':'
      end
      object Label5: TLabel
        Left = 16
        Top = 54
        Width = 64
        Height = 13
        Caption = #34928#20943'->'#30452#36890':'
      end
      object Label6: TLabel
        Left = 16
        Top = 73
        Width = 64
        Height = 13
        Caption = #30452#36890'->'#25918#22823':'
      end
      object CnEdit1: TCnEdit
        Left = 93
        Top = 12
        Width = 52
        Height = 21
        TabOrder = 0
        Text = '-4080'
        TextType = IntegerText
      end
      object CnEdit2: TCnEdit
        Left = 93
        Top = 31
        Width = 52
        Height = 21
        TabOrder = 1
        Text = '10320'
        TextType = IntegerText
      end
      object CnEdit3: TCnEdit
        Left = 93
        Top = 50
        Width = 52
        Height = 21
        TabOrder = 2
        Text = '2640'
        TextType = IntegerText
      end
      object CnEdit4: TCnEdit
        Left = 93
        Top = 69
        Width = 52
        Height = 21
        TabOrder = 3
        Text = '-11760'
        TextType = IntegerText
      end
    end
    object gpAMThreshold: TGroupBox
      Left = 379
      Top = 80
      Width = 174
      Height = 98
      Caption = 'AM'#20999#25442#28857
      TabOrder = 5
      object Label7: TLabel
        Left = 16
        Top = 16
        Width = 64
        Height = 13
        Caption = #25918#22823'->'#30452#36890':'
      end
      object Label8: TLabel
        Left = 16
        Top = 35
        Width = 64
        Height = 13
        Caption = #30452#36890'->'#34928#20943':'
      end
      object Label9: TLabel
        Left = 16
        Top = 54
        Width = 64
        Height = 13
        Caption = #34928#20943'->'#30452#36890':'
      end
      object Label10: TLabel
        Left = 16
        Top = 73
        Width = 64
        Height = 13
        Caption = #30452#36890'->'#25918#22823':'
      end
      object CnEdit5: TCnEdit
        Left = 93
        Top = 12
        Width = 52
        Height = 21
        TabOrder = 0
        Text = '-440'
        TextType = IntegerText
      end
      object CnEdit6: TCnEdit
        Left = 93
        Top = 31
        Width = 52
        Height = 21
        TabOrder = 1
        Text = '-216'
        TextType = IntegerText
      end
      object CnEdit7: TCnEdit
        Left = 93
        Top = 50
        Width = 52
        Height = 21
        TabOrder = 2
        Text = '-364'
        TextType = IntegerText
      end
      object CnEdit8: TCnEdit
        Left = 93
        Top = 69
        Width = 52
        Height = 21
        TabOrder = 3
        Text = '-548'
        TextType = IntegerText
      end
    end
  end
end
