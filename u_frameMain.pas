unit u_frameMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  StdCtrls, ExtCtrls, ComCtrls, ToolWin,
  Buttons, ButtonGroup, u_frameExamineList, u_CommonDef, u_ExamineImp,
  u_frameExamineItemUI, u_FrameUart, ActnList, u_Version,
  PlumUtils, u_frameExamineItemUIBase;

type

  TframeMain = class(TframeUart)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Memo1: TMemo;
    ToolBar1: TToolBar;
    frameExamineList1: TframeExamineList;
    Splitter2: TSplitter;
    pnlBatchTest: TPanel;
    gpCheckedItems: TGridPanel;
    btnBatchToggle: TButton;
    ToolButton2: TToolButton;
    Panel2: TPanel;
    Splitter3: TSplitter;
    ToolButton3: TToolButton;
    edtSN: TEdit;
    ToolButton4: TToolButton;
    procedure btnBatchToggleClick(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
  private
    { Private declarations }
    procedure UISyncItemsToBatchPanel;
    Procedure _Log_HandleProc(const Str: String);
    Function _GetSNProc: String;
  public
    { Public declarations }
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; Override;
    Procedure InitMeasureItemsUI;
  end;

implementation
uses
  u_ExamineGlobal, Types, CnDebug, CnCommon, u_dmUpgrade;

{$R *.dfm}

constructor TframeMain.Create(AOwner: TComponent);
var
  R, R1, R2: TRect;
begin
  g_dele_Log_Proc:= _Log_HandleProc;
  g_Dele_ProductSN:= _GetSNProc;
  inherited;
//  FillChar(R1, SizeOf(R1), #0);
//  R2.Top:= 0;
//  R2.Left:= 0;
//  R2.Right:= 10;
//  R2.Bottom:= 20;
//  if UnionRect(R, R1, R2) then
//  begin
//    Cndebugger.LogMsg(Format('%d , %d, %d, %d', [R.Left, R.Right, R.Bottom, R.Top]));
//  end;
  {$IFDEF RELEASE}
  SpeedButton2.Visible:= False;
  SpeedButton3.Visible:= False;
  SpeedButton5.Visible:= False;
  {$ELSE}

  {$ENDIF}
  if IsDevloper then ToolButton4.Visible:= True;
  edtSN.Text:= FormatDateTime('YYMM', Now);
end;



destructor TframeMain.Destroy;
begin
  g_dele_Log_Proc:= Nil;
  inherited;
end;

procedure TframeMain.InitMeasureItemsUI;
var
  i: Integer;
  AItem: IExamineItem;
begin
  AItem:= Nil;
  //初始化测试项
  LockWindowUpdate(Handle);
  for i:= 0 to  g_ExamineRegList.Count - 1 do
  With TExamineRegList(g_ExamineRegList).Items[i]^ do
  begin
    AItem:= frameExamineList1.Add(ControllerClass.Create,
      UIClass.Create(frameExamineList1.GridPanel1)
    );
  end;
  UISyncItemsToBatchPanel();
  frameExamineList1.RecalcuSize();
  //调整测试项状态
  if AItem <> Nil then
  begin
    AItem.SetAll_Status(esComplete, Nil);
    AItem.SetAll_Status(esReady, Nil);
  end;
  LockWindowUpdate(0);
end;

procedure TframeMain.Memo1DblClick(Sender: TObject);
begin
  inherited;
  if Dialogs.MessageDlg('清除所有内容吗?', mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    Memo1.Lines.Clear;
  end;
end;

{ TframeSWCtrl }


procedure TframeMain.btnBatchToggleClick(Sender: TObject);
const
  CONST_STOP_TEXT = '停止';
  CONST_START_TEXT = '开始';

  Procedure BatchStart;
  var
    AItem: IExamineItem;
    i: Integer;
    ABatchList: TList;
  begin
    ABatchList:= TList.Create;

    for i := 0 to gpCheckedItems.ControlCount - 1 do
    begin
      With TCheckBox(gpCheckedItems.Controls[i]) do
      begin
        if Checked then
        begin
          if tag <> 0 then
          begin
            ABatchList.Add(Pointer(tag));
          end
        end;
      end;
    end;


    if ABatchList.Count = 0 then Exit;

    g_BatchWishStop:= False;
    g_ExamineMode:= emBatch;
    AItem:= IExamineItem(ABatchList[0]);

    btnBatchToggle.Caption:= CONST_STOP_TEXT;
    btnBatchToggle.Tag:= Integer(True);
    Log('---------------批测开始---------------');
    try
      //----恢复所有项的状态、全部项待命、禁止输入、进入等待--
      AItem.RecallAll_FromWaiting(Nil);

      AItem.SetAll_Status(esReady, Nil);
      AItem.SetAll_Status(esWait, Nil);
      AItem.SetAll_Enable(False, Nil, False);

      //依次测试
      for i := 0 to ABatchList.Count - 1 do
      begin
        if g_BatchWishStop then Break;
        AItem:= IExamineItem(ABatchList[i]);
        AItem.RecallStatus;
        AItem.Start;
      end;
    finally
      AItem.RecallAll_FromWaiting(Nil);
      AItem.SetAll_Enable(True, Nil, True);
      g_ExamineMode:= emSingle;
      g_BatchWishStop:= False;
      ABatchList.Free;


      btnBatchToggle.Caption:= CONST_START_TEXT;
      btnBatchToggle.Tag:= Integer(False);
      Log('---------------批测结束---------------');
    end;

  end;
  Procedure BatchStop;
  begin
    g_BatchWishStop:= True;
  end;
begin
  inherited;
  if btnBatchToggle.Caption = CONST_START_TEXT then
  begin
    BatchStart();
  end
  else if btnBatchToggle.Caption = CONST_STOP_TEXT then
  begin
    BatchStop();
  end;

end;

procedure TframeMain.UISyncItemsToBatchPanel;
var
  i: Integer;
  ACheckBox: TCheckBox;
begin
  gpCheckedItems.ControlCollection.Clear;
  while gpCheckedItems.ControlCollection.Count > 0 do
  begin

    gpCheckedItems.ControlCollection[gpCheckedItems.ControlCollection.Count - 1].Free;
  end;

  for i := 0 to self.frameExamineList1.List.Count - 1 do
  begin
    ACheckBox:= TCheckBox.Create(gpCheckedItems);
    ACheckBox.Width:= ACheckBox.Width * 2;
    ACheckBox.Caption:= IExamineItem(self.frameExamineList1.List[i]).ExamineCaption;
    ACheckBox.Tag:= Integer(self.frameExamineList1.List[i]);
    gpCheckedItems.InsertControl(ACheckBox);
  end;

end;

function TframeMain._GetSNProc: String;
begin
  Result:= edtSN.Text;
end;

procedure TframeMain._Log_HandleProc(const Str: String);
begin
  Memo1.Lines.Add(FormatDateTime('HH:NN:SS', Now) + ':  ' + Str)
end;

procedure TframeMain.ToolButton2Click(Sender: TObject);
begin
  inherited;
  if DirectoryExists(Excel_Dir) then
    ExploreDir(Excel_Dir);
end;

procedure TframeMain.ToolButton3Click(Sender: TObject);
begin
  inherited;
  if DirectoryExists(Log_Dir) then
    ExploreDir(Log_Dir);
end;


procedure TframeMain.ToolButton4Click(Sender: TObject);
begin
  inherited;
  dmUpgrade.UpdateDeplyConfigFile();
end;

end.
