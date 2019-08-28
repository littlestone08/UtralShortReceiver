unit u_FrameLevelWithoutFilterUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameExamineItemUIBase, StdCtrls, CnEdit, Gauges, ExtCtrls;

type
  TLevelWithoutFilterUI = class(TFrameCustomExamineItemUI)
    Button1: TButton;
    edtLevelStableDelay: TCnEdit;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    Procedure SyncUI(Ptr: Pointer);  Override;
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

procedure TLevelWithoutFilterUI.SyncUI(Ptr: Pointer);
var
  Value: Integer;
begin
  if Ptr <> Nil then
  begin
    Value:= edtLevelStableDelay.value;
    if Value = 0 then
      Value:= 1000;
    edtLevelStableDelay.Text:= IntToStr(Value);
    PInteger(Ptr)^:= Value;
  end;
end;

end.
