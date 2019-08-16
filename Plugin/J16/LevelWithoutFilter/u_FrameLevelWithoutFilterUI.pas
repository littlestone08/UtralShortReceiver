unit u_FrameLevelWithoutFilterUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameExamineItemUIBase, StdCtrls, CnEdit, Gauges, ExtCtrls;

type
  TLevelWithoutFilterUI = class(TFrameCustomExamineItemUI)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LevelWithoutFilterUI: TLevelWithoutFilterUI;

implementation
uses
  u_J16CommonDef;

{$R *.dfm}

procedure TLevelWithoutFilterUI.Button1Click(Sender: TObject);
begin
  inherited;
  (get_ExamineItem as  IStatText2XLS).DoStatText2XLS;
end;

end.
