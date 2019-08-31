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
    gpFMThreshold: TGroupBox;
    CnEdit1: TCnEdit;
    Label3: TLabel;
    Label4: TLabel;
    CnEdit2: TCnEdit;
    Label5: TLabel;
    CnEdit3: TCnEdit;
    Label6: TLabel;
    CnEdit4: TCnEdit;
    gpAMThreshold: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    CnEdit5: TCnEdit;
    CnEdit6: TCnEdit;
    CnEdit7: TCnEdit;
    CnEdit8: TCnEdit;
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
  OptionPtr: PLevelWithoutFilterOption;
begin
  if Ptr <> Nil then
  begin
    OptionPtr:= PLevelWithoutFilterOption(Ptr);

    OptionPtr.StableDelay:= edtLevelStableDelay.value;
    if OptionPtr.StableDelay = 0 then
      OptionPtr.StableDelay:= 1000;
    edtLevelStableDelay.Text:= IntToStr(OptionPtr.StableDelay);

    OptionPtr.FMThreshold[0]:= CnEdit1.Value;
    OptionPtr.FMThreshold[1]:= CnEdit2.Value;
    OptionPtr.FMThreshold[2]:= CnEdit3.Value;
    OptionPtr.FMThreshold[3]:= CnEdit4.Value;

    OptionPtr.AMThreshold[0]:= CnEdit5.Value;
    OptionPtr.AMThreshold[1]:= CnEdit6.Value;
    OptionPtr.AMThreshold[2]:= CnEdit7.Value;
    OptionPtr.AMThreshold[3]:= CnEdit8.Value;
  end;
end;

end.
