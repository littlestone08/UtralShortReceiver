unit u_frameJ16SlopeCalibrateMeasureUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameExamineItemUIBase, StdCtrls, CnEdit, Gauges, ExtCtrls, u_J16CommonDef;

type
  TSlopeCalibrateMeasureUI = class(TFrameCustomExamineItemUI)
    Label2: TLabel;
    edtLevelStableDelay: TCnEdit;
  private
    { Private declarations }
  Protected
    Procedure SyncUI(Ptr: Pointer);  Override;
  public
    { Public declarations }
  end;

//var
//  FrameCustomExamineItemUI1: TFrameCustomExamineItemUI1;

implementation

{$R *.dfm}

procedure TSlopeCalibrateMeasureUI.SyncUI(Ptr: Pointer);
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
