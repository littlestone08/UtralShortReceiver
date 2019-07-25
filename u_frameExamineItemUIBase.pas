unit u_frameExamineItemUIBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CnEdit, Gauges, ExtCtrls, u_CommonDef, PlumUtils;

type
  TPanel = Class(ExtCtrls.TPanel)
  Protected
    procedure Paint; override;
  End;

  TFrameCustomExamineItemUI = class(TFrame, IExamineItemUI)
    Panel1: TPanel;
    Label1: TLabel;
    edInlineInsLoss: TCnEdit;
    lbExamineItemCaption: TLabel;
    btnToggle: TButton;
    Gauge1: TGauge;
    procedure btnToggleClick(Sender: TObject);
  private
    { Private declarations }
    FExamineItem: Integer;//IExamineItem; //weak

  Protected
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;

  Protected    //Interface
    function get_ExamineItem: IExamineItem;
    Procedure set_ExamineItem(const Value: IExamineItem);

    Procedure set_Percent(const Value: Single);

    function get_Enabled(): Boolean;
    Procedure set_Enabled(const Value: Boolean);

    function get_ButtonCaption: String;
    Procedure set_ButtonCaption(const Value: String);

    function get_ButtonEnabled: Boolean;
    Procedure set_ButtonEnabled(const Value: Boolean);

    Procedure SetEnableRecursion(const Value: Boolean);

    Procedure SyncUI(Ptr: Pointer);  Virtual;
  public
    { Public declarations }
    Constructor Create(AOwner: TComponent); Override;

  end;

  TExamineItemUIClass = Class of TFrameCustomExamineItemUI;
implementation
uses
  u_ExamineGlobal;

{$R *.dfm}

{ TFrameCustomExamineItem }


procedure TFrameCustomExamineItemUI.btnToggleClick(Sender: TObject);
var
  AExamineItem: IExamineItem;
begin
  g_ExamineMode:= emSingle;

  AExamineItem:= IExamineItem(FExamineItem);
  AExamineItem.InlineInsertLost:= edInlineInsLoss.Value;
  case AExamineItem.Status of
    esReady:
    begin
      case g_ExamineMode of
        emSingle:
        begin
          AExamineItem.SetAll_Status(esWait, AExamineItem);
        end;
        emBatch:
        begin

        end;
      end;
      AExamineItem.Start;
    end;
    esWait: ;
    esExecute:
    begin
      case g_ExamineMode of
        emSingle:
        begin
          AExamineItem.SetAll_Status(esWait, AExamineItem);
        end;
        emBatch:
        begin

        end;
      end;
      AExamineItem.Stop;
    end;
    esComplete:
    begin
      case g_ExamineMode of
        emSingle:
        begin
          if Dialogs.MessageDlg('已经完成此项测试, 要重新开始吗?',
            mtConfirmation, mbYesNo, 0) =  mrYes then
          begin
            AExamineItem.Start;
          end;
        end;
        emBatch:
        begin

        end;
      end;

    end;
  end;

end;

procedure TFrameCustomExamineItemUI.CMEnabledChanged(var Message: TMessage);
var
  i: Integer;
begin
  inherited;
  if HandleAllocated and not (csDesigning in ComponentState) then
  begin
    for i := 0 to self.ControlCount - 1 do
    begin
      self.Controls[i].Enabled:= self.Enabled;
    end;
  end;
end;

constructor TFrameCustomExamineItemUI.Create(AOwner: TComponent);
begin
  inherited;
  lbExamineItemCaption.Font.Size:=   lbExamineItemCaption.Font.Size + 3;
  lbExamineItemCaption.Font.color:= clBlue;
end;





function TFrameCustomExamineItemUI.get_Enabled: Boolean;
begin
  Result:= Self.Enabled;
end;

function TFrameCustomExamineItemUI.get_ExamineItem: IExamineItem;
begin
  Result:= IExamineItem(FExamineItem);
end;





procedure TFrameCustomExamineItemUI.SetEnableRecursion(const Value: Boolean);
begin
  SetControlEnable(Self, Value, True);
end;

function TFrameCustomExamineItemUI.get_ButtonCaption: String;
begin
  Result:= btnToggle.Caption;
end;

function TFrameCustomExamineItemUI.get_ButtonEnabled: Boolean;
begin
  Result:= btnToggle.Enabled;
end;

procedure TFrameCustomExamineItemUI.set_Percent(const Value: Single);
begin
  Gauge1.Progress:= Trunc(Value);
end;


procedure TFrameCustomExamineItemUI.SyncUI(Ptr: Pointer);
begin
//
end;



procedure TFrameCustomExamineItemUI.set_ButtonCaption(const Value: String);
begin
  btnToggle.Caption:= Value;
end;

procedure TFrameCustomExamineItemUI.set_ButtonEnabled(const Value: Boolean);
begin
  btnToggle.Enabled:= Value;
end;

procedure TFrameCustomExamineItemUI.set_Enabled(const Value: Boolean);
begin
  if Self.Enabled <> Value then
  begin
    Self.Enabled:= Value;
  end;
end;

procedure TFrameCustomExamineItemUI.set_ExamineItem(const Value: IExamineItem);
begin
  FExamineItem:= Integer(Value);
  self.lbExamineItemCaption.Caption:= Value.ExamineCaption;
  self.edInlineInsLoss.Text:= FloatToStr(Value.InlineInsertLost);
end;

{ TPanel }

procedure TPanel.Paint;
begin
  inherited;
  Exit;
//  Canvas.Pen.Style:= psSolid;
//  Canvas.Pen.Color:= clBlack;
  Canvas.Brush.Style:= bsSolid;
  Canvas.Brush.Color:= clBlack;
  Canvas.FrameRect(self.BoundsRect);
end;

end.
