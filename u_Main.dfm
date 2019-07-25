object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'J16'#32447#24615#26657#20934#19982#27979#35797
  ClientHeight = 606
  ClientWidth = 1371
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inline frameMain1: TframeMain
    Left = 0
    Top = 0
    Width = 1371
    Height = 606
    Align = alClient
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    ExplicitWidth = 1371
    ExplicitHeight = 606
    inherited Splitter1: TSplitter
      Left = 801
      Top = 76
      Height = 511
      ExplicitLeft = 801
      ExplicitTop = 95
      ExplicitHeight = 511
    end
    inherited ToolBar: TToolBar
      Width = 1371
      Height = 19
      ButtonWidth = 64
      ExplicitWidth = 1371
      inherited ToolButton1: TToolButton
        ExplicitWidth = 63
      end
      inherited tbUartRefresh: TToolButton
        Left = 152
        ExplicitLeft = 152
        ExplicitWidth = 63
      end
      inherited tblUartParam: TToolButton
        Left = 215
        Top = 0
        ExplicitLeft = 215
        ExplicitWidth = 63
      end
      inherited ToolButton2: TToolButton
        Left = 278
        Top = 0
        ExplicitLeft = 278
        ExplicitTop = 0
        ExplicitWidth = 68
      end
      inherited ToolButton3: TToolButton
        Left = 346
        Top = 0
        OnClick = frameMain1ToolButton3Click
        ExplicitLeft = 346
        ExplicitTop = 0
        ExplicitWidth = 68
      end
      inherited ToolButton4: TToolButton
        Left = 414
        Top = 0
        OnClick = frameMain1ToolButton4Click
        ExplicitLeft = 414
        ExplicitTop = 0
        ExplicitWidth = 68
      end
    end
    inherited StatusBar: TStatusBar
      Top = 587
      Width = 1371
      ExplicitTop = 587
      ExplicitWidth = 1371
    end
    inherited Panel1: TPanel
      Top = 76
      Width = 801
      Height = 511
      ExplicitTop = 76
      ExplicitWidth = 801
      ExplicitHeight = 511
      inherited Splitter2: TSplitter
        Top = 416
        Width = 801
        ExplicitTop = 362
        ExplicitWidth = 727
      end
      inherited frameExamineList1: TframeExamineList
        Width = 801
        Height = 416
        ExplicitWidth = 801
        ExplicitHeight = 416
        inherited ScrollBox1: TScrollBox
          Width = 801
          Height = 416
          ExplicitWidth = 801
          ExplicitHeight = 416
          inherited GridPanel1: TGridPanel
            Width = 353
            ExplicitWidth = 353
          end
        end
      end
      inherited pnlBatchTest: TPanel
        Top = 419
        Width = 801
        ExplicitTop = 419
        ExplicitWidth = 801
        inherited Splitter3: TSplitter
          Left = 672
          ExplicitLeft = 627
        end
        inherited gpCheckedItems: TGridPanel
          Width = 671
          ColumnCollection = <
            item
              Value = 22.970737982250380000
            end
            item
              Value = 19.745326080385360000
            end
            item
              Value = 18.220699647641890000
            end
            item
              Value = 19.206189347743140000
            end
            item
              Value = 19.857046941979220000
            end>
          ExplicitWidth = 671
        end
        inherited Panel2: TPanel
          Left = 675
          ExplicitLeft = 675
        end
      end
    end
    inherited Memo1: TMemo
      Left = 804
      Top = 76
      Height = 511
      ExplicitLeft = 804
      ExplicitTop = 76
      ExplicitHeight = 511
    end
    inherited ToolBar1: TToolBar
      Top = 19
      Width = 1371
      ExplicitTop = 19
      ExplicitWidth = 1371
    end
  end
end
