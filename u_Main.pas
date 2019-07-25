unit u_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_frameMain, u_FrameUart, u_Version;

type
  TfrmMain = class(TForm)
    frameMain1: TframeMain;
    procedure FormShow(Sender: TObject);
    procedure frameMain1ToolButton3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frameMain1ToolButton4Click(Sender: TObject);
  private
    { Private declarations }
    FframeMainInited: Boolean;
  public
    { Public declarations }
    Destructor Destroy; Override;
  end;

var
  frmMain: TfrmMain;

implementation
uses
  u_ExamineGlobal;

{$R *.dfm}

destructor TfrmMain.Destroy;
begin
  Log('****************¹Ø±Õ****************');
  inherited;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption:= Caption + '-' + CONST_VERISION;
  u_ExamineGlobal.g_RS232:= self.frameMain1.RS232;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if Not FframeMainInited then
  begin
    Log('****************Æô¶¯****************');
    frameMain1.InitMeasureItemsUI();

  end;
end;

procedure TfrmMain.frameMain1ToolButton3Click(Sender: TObject);
begin
  frameMain1.ToolButton3Click(Sender);

end;

procedure TfrmMain.frameMain1ToolButton4Click(Sender: TObject);
begin
  frameMain1.ToolButton4Click(Sender);

end;

end.
