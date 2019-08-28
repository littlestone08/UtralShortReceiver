unit u_FrameLevelWithFilterUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameExamineItemUIBase, StdCtrls, CnEdit, Gauges, ExtCtrls;

type
  TLevelWithFilterUI = class(TFrameCustomExamineItemUI)
    Button1: TButton;
    RadioGroup1: TRadioGroup;
    edtLevelStableDelay: TCnEdit;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  Protected
    Procedure SyncUI(Ptr: Pointer); override;
  public
    { Public declarations }
  end;

var
  LevelWithFilterUI: TLevelWithFilterUI;

implementation
uses
  u_J16CommonDef;

{$R *.dfm}

procedure TLevelWithFilterUI.Button1Click(Sender: TObject);
begin
  inherited;
  (get_ExamineItem as  IStatText2XLS).DoStatText2XLS;
end;

procedure TLevelWithFilterUI.SyncUI(Ptr: Pointer);
var
  Value: Integer;
begin
  if Ptr <> Nil then
  begin
    PLevelWithFilterOption(Ptr)^.ManualMode:= self.RadioGroup1.ItemIndex;
    Value:= edtLevelStableDelay.value;
    if Value = 0 then
      Value:= 1000;
    edtLevelStableDelay.Text:= IntToStr(Value);
    PLevelWithFilterOption(Ptr)^.StableDelay:= Value;
  end;
end;

end.
