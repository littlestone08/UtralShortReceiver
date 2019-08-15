unit u_FrameLevelWithoutFilterUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameExamineItemUIBase, StdCtrls, CnEdit, Gauges, ExtCtrls;

type
  TLevelWithoutFilterUI = class(TFrameCustomExamineItemUI)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LevelWithoutFilterUI: TLevelWithoutFilterUI;

implementation

{$R *.dfm}

end.
