unit u_frameExamineItemUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameExamineItemUIBase, StdCtrls, CnEdit, Gauges, ExtCtrls, u_CommonDef;

type
  TExamineItemDefaultControl = class(TFrameCustomExamineItemUI, IChannelUI)
    rgEvnType: TRadioGroup;
  private
    { Private declarations }
  Protected
    function get_EnvIndex: Integer;
  public
    { Public declarations }
    Procedure SyncUI(Ptr: Pointer);  Override;
  end;



implementation

{$R *.dfm}

function TExamineItemDefaultControl.get_EnvIndex: Integer;
begin
  Result:= rgEvnType.ItemIndex
end;

procedure TExamineItemDefaultControl.SyncUI(Ptr: Pointer);
begin
  inherited;

end;

end.
