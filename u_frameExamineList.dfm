object frameExamineList: TframeExamineList
  Left = 0
  Top = 0
  Width = 744
  Height = 474
  TabOrder = 0
  OnResize = FrameResize
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 744
    Height = 474
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 0
    DesignSize = (
      724
      470)
    object GridPanel1: TGridPanel
      Left = 0
      Top = 0
      Width = 564
      Height = 474
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      ColumnCollection = <
        item
          Value = 100.000000000000000000
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
        end>
      TabOrder = 0
      ExplicitWidth = 584
    end
  end
end
