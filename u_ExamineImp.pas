unit u_ExamineImp;

interface
uses
  Classes, SysUtils, Windows, StrUtils, Graphics,Math, u_CommonDef, PlumUtils, XLSSheetData5, Xc12Utils5,
  u_frameExamineItemUIBase, u_frameExamineItemUI, CnCommon;


const //滤波器模式定义
  SW_FILTER_STR_WIDE = '宽带常规';
  SW_FILTER_STR_WDYN = '宽带大动态';
  SW_FILTER_STR_NARR = '窄带低噪';
  SW_FILTER_STR_ARR: Array[0..1] of String = (SW_FILTER_STR_WIDE, SW_FILTER_STR_NARR);
const //衰减器定义
  SW_ATT_0DB = '不衰减';
  SW_ATT_ALL = '全衰减';
  SW_ATT1_STR_1DB = 'ATT1-1dB';
  SW_ATT1_STR_2DB = 'ATT1-2dB';
  SW_ATT1_STR_4DB = 'ATT1-4dB';
  SW_ATT1_STR_8DB = 'ATT1-8dB';
  SW_ATT1_STR_16DB = 'ATT1-16dB';
  SW_ATT1_STR_32DB = 'ATT1-32dB';

  SW_ATT2_STR_1DB = 'ATT2-1dB';
  SW_ATT2_STR_2DB = 'ATT2-2dB';
  SW_ATT2_STR_4DB = 'ATT2-4dB';
  SW_ATT2_STR_8DB = 'ATT2-8dB';
  SW_ATT2_STR_16DB = 'ATT2-16dB';
  SW_ATT2_STR_32DB = 'ATT2-32dB';

  SW_ATT_STR_ARR: Array[0..1] of Array[0..5] of String =(
    (SW_ATT1_STR_1DB, SW_ATT1_STR_2DB, SW_ATT1_STR_4DB, SW_ATT1_STR_8DB, SW_ATT1_STR_16DB, SW_ATT1_STR_32DB),
    (SW_ATT2_STR_1DB, SW_ATT2_STR_2DB, SW_ATT2_STR_4DB, SW_ATT2_STR_8DB, SW_ATT2_STR_16DB, SW_ATT2_STR_32DB)
    );



type
  TFilterInfo = Record
    Name: String;
    Freqs: Array[0..2] of Single;
  end;
  TFilterInfox = Record
    Name: String;
    Freqs: Array[0..2] of Single;
  end;

const
  x: Array[0..1] of TFilterInfox = (
    (Name: '1'; Freqs: (1,2 ,3)),
    (Name: '1'; Freqs: (1,2 ,3))
  );
const
//  SW_FILTER_0030M = '滤波器-0030M';
  SW_FILTER_0040M = '滤波器-0040M';
//  SW_FILTER_0050M = '滤波器-0050M';
  SW_FILTER_0060M = '滤波器-0060M';
//  SW_FILTER_0070M = '滤波器-0070M';
  SW_FILTER_0090M = '滤波器-0090M';
//  SW_FILTER_0110M = '滤波器-0110M';
  SW_FILTER_0130M = '滤波器-0130M';
//  SW_FILTER_0150M = '滤波器-0150M';
  SW_FILTER_0190M = '滤波器-0190M';
//  SW_FILTER_0230M = '滤波器-0230M';
  SW_FILTER_0290M = '滤波器-0290M';
//  SW_FILTER_0350M = '滤波器-0350M';
  SW_FILTER_0431M = '滤波器-0431M';
//  SW_FILTER_0512M = '滤波器-0512M';
  SW_FILTER_0631M = '滤波器-0631M';
//  SW_FILTER_0750M = '滤波器-0750M';
  SW_FILTER_0905M = '滤波器-0905M';
//  SW_FILTER_1060M = '滤波器-1060M';
  SW_FILTER_1280M = '滤波器-1280M';
//  SW_FILTER_1500M = '滤波器-1500M';
  SW_FILTER_1810M = '滤波器-1810M';
//  SW_FILTER_2120M = '滤波器-2120M';
  SW_FILTER_2560M = '滤波器-2560M';
//  SW_FILTER_3000M = '滤波器-3000M';

//  SW_FILTER_ARR: Array[0..11] of Array[0..2] of String = (
//    (SW_FILTER_0030M,  SW_FILTER_0040M,  SW_FILTER_0050M),
//    (SW_FILTER_0050M,  SW_FILTER_0060M,  SW_FILTER_0070M),
//    (SW_FILTER_0070M,  SW_FILTER_0090M,  SW_FILTER_0110M),
//    (SW_FILTER_0110M,  SW_FILTER_0130M,  SW_FILTER_0150M),
//    (SW_FILTER_0150M,  SW_FILTER_0190M,  SW_FILTER_0230M),
//    (SW_FILTER_0230M,  SW_FILTER_0290M,  SW_FILTER_0350M),
//    (SW_FILTER_0350M,  SW_FILTER_0431M,  SW_FILTER_0512M),
//    (SW_FILTER_0512M,  SW_FILTER_0631M,  SW_FILTER_0750M),
//    (SW_FILTER_0750M,  SW_FILTER_0905M,  SW_FILTER_1060M),
//    (SW_FILTER_1060M,  SW_FILTER_1280M,  SW_FILTER_1280M),
//    (SW_FILTER_1280M,  SW_FILTER_1810M,  SW_FILTER_2120M),
//    (SW_FILTER_2120M,  SW_FILTER_2560M,  SW_FILTER_3000M)
//    );
  SW_FILTERS: ArrAY[0..11] of TFilterInfo = (
    (Name: SW_FILTER_0040M; Freqs:(30, 40, 50)),
    (Name: SW_FILTER_0060M; Freqs:(50, 60, 70)),
    (Name: SW_FILTER_0090M; Freqs:(70, 90, 110)),
    (Name: SW_FILTER_0130M; Freqs:(110, 130, 150)),
    (Name: SW_FILTER_0190M; Freqs:(150, 190, 230)),
    (Name: SW_FILTER_0290M; Freqs:(230, 290, 350)),
    (Name: SW_FILTER_0431M; Freqs:(350, 431, 512)),

    (Name: SW_FILTER_0631M; Freqs:(512, 631, 750)),
    (Name: SW_FILTER_0905M; Freqs:(750, 905, 1060)),
    (Name: SW_FILTER_1280M; Freqs:(1060, 1280, 1500)),
    (Name: SW_FILTER_1810M; Freqs:(1500, 1810, 2120)),
    (Name: SW_FILTER_2560M; Freqs:(2120, 2560, 3000))
  );
const
  CONST_CHECK_EMPTY = '合格□     不合格□';
  CONST_CHECK_ELIGIBLE = '合格☑     不合格□';
  CONST_CHECK_UNELIGIBLE = '合格□     合格☑';
const
  CONST_LO1_LEVEL_DEF = 3;

  CONST_FS_LEVEL_DEF = -60;
  CONST_FS_FREQ_ARR: Array[0..2] of Double = (30, 1500, 3000);
  CONST_FS_FREQ_FILTER: Array[0..2] of String = (SW_FILTER_0040M, SW_FILTER_1280M, SW_FILTER_2560M);
  CONST_CELL_FONT_COLOR: Array[False..True] of CARDINAL = ($FF0000, clBlack);
  CONST_ELIGLE_STR: Array[False..True] of WideString = (CONST_CHECK_UNELIGIBLE, CONST_CHECK_ELIGIBLE);
type


  TCustomExamineItem = Class(TInterfacedObject, IExamineItem)
  Protected
    FExamineCaption: String;
    FStatus: TExamineStatus;
    FInsertLost: double;

    FUI: IExamineItemUI;
    FWishStop: Boolean;
    FManageList: TInterfaceList; //Weak
    FStatusRecall: TObject;
  Protected //interface

    Procedure Start();
    Procedure Stop();
    function get_UI: IExamineItemUI;
    Procedure set_UI(const Value: IExamineItemUI);

    function get_InlineInsertLost: Double;
    Procedure set_InlineInsertLost(const Value: double);
    function get_ExamineCaption: String;
    Procedure set_ExamineCaption(const Value: String);

    function get_ManageList: TInterfaceList;
    Procedure set_ManageList(const Value: TInterfaceList);

    function get_Status: TExamineStatus;
    Procedure Set_Status(const Value: TExamineStatus);

    Procedure DoProcess; Virtual;

    Procedure RecallStatus;
    Procedure SetAll_Status(Value: TExamineStatus;  const ExceptItem: IExamineItem);

    Procedure RecallAll_FromWaiting(const ExceptItem: IExamineItem);
    Procedure SetAll_Enable(Value: Boolean; const ExceptItem: IExamineItem; Recursion: Boolean);
    Procedure CheckWishStop(Delay: Integer = 2);
  Protected
    Procedure Init; virtual; Abstract;
  Public
    Constructor Create;
    Destructor Destroy ; Override;

  End;
  TExamineItemClass  = Class of TCustomExamineItem;

  TStatusRecall = Class
  Private
    FUIEnabled: Boolean;
    FUIButtonEnabled: Boolean;
    FUIButtonCaption: String;

    FItem: TCustomExamineItem;
    FStatus: TExamineStatus;
  Public
    Constructor Create(Value: TCustomExamineItem);
    Destructor Destroy; override;
  End;

//  TExamineLO1 = Class(TCustomExamineItem)
//  Private
//    FLog: TLO1MesureLog;
//  Protected
//    Procedure Init; Override;
//    Procedure DoProcess; Override;
//  Public
//
//  End;



  PExamineRegItemInfo = ^TExamineRegItemInfo;
  TExamineRegItemInfo = Record
    ControllerClass :  TExamineItemClass;
    UIClass         : TExamineItemUIClass;
  end;

  TExamineRegList = Class(TList)
  private
    function Get(Index: Integer): PExamineRegItemInfo;
  Public
    Procedure Add(AControllerClass :  TExamineItemClass;
                      AUIClass: TExamineItemUIClass); Overload;
    property Items[Index: Integer]: PExamineRegItemInfo read Get;
    Destructor Destroy; Override;

  End;

implementation
uses
  u_ExamineGlobal, U_GPIB_DEV2;

 function CompareDoublePtr(Item1, Item2: Pointer): Integer;
 begin
  if PDouble(Item1)^ > PDouble(Item2)^ then
    Result:= 1
  else  if PDouble(Item1)^ = PDouble(Item2)^ then
    Result:= 0
  else
    Result:= -1;
 end;
{ TExamineItem }

procedure TCustomExamineItem.CheckWishStop(Delay: Integer);
begin
  WaitMS(Delay);
  if FWishStop or g_BatchWishStop then
  begin
    FWishStop:= False;
    Raise Exception.Create('用户中止测试');
  end;
end;

constructor TCustomExamineItem.Create;
begin
  inherited;
  Init;
end;

destructor TCustomExamineItem.Destroy;
var
  UIComp: TComponent;
begin

  if get_Status = esExecute then
  begin
    Stop;
    while get_Status <> esExecute do
      Sleep(10);
  end;

  if FUI <> Nil  then
  begin
    UIComp:= (FUI as IInterfaceComponentReference).GetComponent;
    if UIComp <> Nil then
    begin
      UIComp.Free;
    end;
  end;

  inherited;
end;

procedure TCustomExamineItem.DoProcess;
var
  i: integer;
begin
  try
    for i := 0 to 10 do
    begin
      WaitMS(50);
//      if FWishStop or g_BatchWishStop then
//      begin
//        FWishStop:= False;
//        Break;
//      end;
      CheckWishStop();
      FUI.set_Percent(i * 10);
    end;
  finally
    Set_Status(esComplete);
  end;
end;

function TCustomExamineItem.get_ExamineCaption: String;
begin
  Result:= FExamineCaption;
end;

function TCustomExamineItem.get_Status: TExamineStatus;
begin
  Result:= FStatus;
end;

function TCustomExamineItem.get_InlineInsertLost: Double;
begin

  Result:= FInsertLost;
end;



function TCustomExamineItem.get_ManageList: TInterfaceList;
begin
  Result:= FManageList;
end;

function TCustomExamineItem.get_UI: IExamineItemUI;
begin
  Result:= FUI;
end;


procedure TCustomExamineItem.RecallAll_FromWaiting(
  const ExceptItem: IExamineItem);
var
  i: integer;
begin
  for i := 0 to FManageList.Count - 1 do
  begin
    if (FManageList[i] <> ExceptItem) and (IExamineItem(FManageList[i]).Status = esWait) then
    begin
      IExamineItem(FManageList[i]).RecallStatus;
    end;
  end;
end;

procedure TCustomExamineItem.RecallStatus;
begin
  Assert(FStatusRecall <> Nil, '恢复状态对象为空');
  FreeAndNil(FStatusRecall);
end;

procedure TCustomExamineItem.SetAll_Enable(Value: Boolean;
  const ExceptItem: IExamineItem; Recursion: Boolean);
var
  i: integer;
  AUI: IExamineItemUI;
begin
  for i := 0 to FManageList.Count - 1 do
  begin
    if FManageList[i] <> ExceptItem then
    begin
      AUI:= IExamineItem(FManageList[i]).UI;
      if AUI <> NIl then
      begin
        if Recursion then
          AUI.SetEnableRecursion(Value)
        else
          AUI.Enabled:= Value;

      end;
    end;
  end;
end;

procedure TCustomExamineItem.SetAll_Status(Value: TExamineStatus;
  const ExceptItem: IExamineItem);
var
  i: integer;
begin
  for i := 0 to FManageList.Count - 1 do
  begin
    if FManageList[i] <> ExceptItem then
    begin
      IExamineItem(FManageList[i]).Status:= Value;
    end;
  end;
end;

procedure TCustomExamineItem.set_ExamineCaption(const Value: String);
begin
  FExamineCaption:= Value;
end;

procedure TCustomExamineItem.Set_Status(const Value: TExamineStatus);
  Procedure SetStatusForSingleMode;
  begin
    if FStatus <> Value then
    begin
      if FUI <> Nil then
      begin
        case Value of
          esReady:
          begin
            FUI.Enabled:= True;
            FUI.ButtonEnabled:= True;
            FUI.ButtonCaption:= '开始';

            FUI.set_Percent(0);
          end;
          esWait:
          begin
            Assert(FStatusRecall = Nil, '进入等待时恢复状态对象不为空');
            FStatusRecall:= TStatusRecall.Create(Self);

            FUI.Enabled:= True;
            FUI.ButtonEnabled:= False;
            FUI.ButtonCaption:= '等待';
          end;
          esExecute:
          begin
            FUI.Enabled:= True;
            FUI.ButtonEnabled:= True;
            FUI.ButtonCaption:= '停止';
          end;
          esComplete:
          begin
            RecallAll_FromWaiting(Nil);

            FUI.Enabled:= True;
            FUI.ButtonEnabled:= g_ExamineMode = emSingle;
            FUI.ButtonCaption:= '完成';
          end;
        end;
        FStatus:= Value;
      end;
    end;
  end;
  Procedure SetStatusForBatchMode;
  begin
    if FStatus <> Value then
    begin
      if FUI <> Nil then
      begin
        case Value of
          esReady:
          begin
            FUI.Enabled:= True;
            FUI.ButtonEnabled:= True;
            FUI.ButtonCaption:= '开始';

            FUI.set_Percent(0);
          end;
          esWait:
          begin
            Assert(FStatusRecall = Nil, '进入等待时恢复状态对象不为空');
            FStatusRecall:= TStatusRecall.Create(Self);

            FUI.Enabled:= True;
            FUI.ButtonEnabled:= False;
            FUI.ButtonCaption:= '等待';
          end;
          esExecute:
          begin
            FUI.Enabled:= True;
            FUI.ButtonEnabled:= True;
            FUI.ButtonCaption:= '停止';
          end;
          esComplete:
          begin
            FUI.Enabled:= True;
            FUI.ButtonEnabled:= g_ExamineMode = emSingle;
            FUI.ButtonCaption:= '完成';
          end;
        end;
        FStatus:= Value;
      end;
    end;
  end;
begin
  if FStatus = esWait then exit; //仅可以调用撤消等待方法恢复到原来的状态

  case g_ExamineMode of
    emSingle: SetStatusForSingleMode();
    emBatch: SetStatusForBatchMode();
  end;



end;

procedure TCustomExamineItem.set_InlineInsertLost(const Value: double);
begin
  FInsertLost:= Value;
end;

procedure TCustomExamineItem.set_ManageList(const Value: TInterfaceList);
begin
  FManageList:= Value;
end;

procedure TCustomExamineItem.set_UI(const Value: IExamineItemUI);
begin
  FUI:= Value;
end;

procedure TCustomExamineItem.Start;
var
  AItem: IExamineItem;
  List: TInterfaceList;
  i: Integer;
begin
  Set_Status(esExecute);
  if g_ExamineMode = emSingle then
  begin
    List:= self.get_ManageList;
    for i := 0 to List.Count - 1 do
    begin
      AItem:= IExamineItem(List.Items[i]);
      if AItem <> self as IExamineItem then
      begin
        AItem.Status:= esWait;
      end;
    end;
  end;


  ;
  Log('****************************************');
  Log('*  SN: ' + ProductSN +
        '    < ' +
        StringReplace(FExamineCaption, #$D#$A, '', [rfReplaceAll, rfIgnoreCase]) +
        ' >     ');
  Log('****************************************');
  DoProcess;
end;

procedure TCustomExamineItem.Stop;
begin
  FWishStop:= True;
end;

{ TStatusRecall }

constructor TStatusRecall.Create(Value: TCustomExamineItem);
begin
  inherited Create;
  FItem:= Value;

  FUIEnabled:= FItem.FUI.Enabled;
  FUIButtonEnabled:= FItem.FUI.ButtonEnabled;
  FUIButtonCaption:= FItem.FUI.ButtonCaption;

  FStatus:= FItem.FStatus;
end;

destructor TStatusRecall.Destroy;
begin
  FItem.FStatus:= FStatus;
  FItem.Set_Status(FStatus);
  
  FItem.FUI.Enabled:= FUIEnabled;
  FItem.FUI.ButtonEnabled:= FUIButtonEnabled;
  FItem.FUI.ButtonCaption:= FUIButtonCaption;
  inherited;
end;




{ TExamineRegList }

procedure TExamineRegList.Add(AControllerClass: TExamineItemClass;
  AUIClass: TExamineItemUIClass);
var
  P: PExamineRegItemInfo;
begin
  New(P);
  P.ControllerClass:= AControllerClass;
  P.UIClass:= AUIClass;
  inherited Add(P);
end;

destructor TExamineRegList.Destroy;
begin
  while Count > 0 do
  begin
    Dispose(PExamineRegItemInfo(Last));
    Delete(Count - 1);
  end;
  inherited;
end;

function TExamineRegList.Get(Index: Integer): PExamineRegItemInfo;
begin
  Result:= PExamineRegItemInfo(inherited Get(Index));
end;
//
//{ TExamineLO1 }
//
//
//procedure TExamineLO1.DoProcess;
//var
//  InsLost: double;
//  SARaw: IGPIBInstrument;
//  Freqs: Array of Double;
//  TotalStep: Integer;
//  CurrStep: Integer;
//  {$REGION 'PHASENOISE'}
//  Procedure MeasurePhaseNoise;
//  var
//    i, j: Integer;
//  begin
//
//
//    //Measure PhaseNoise
//
//    //.....make e444a sa enter the phase noise mode and init the params
//    //...........show the marks table and fill the marker
//    SARaw.WriteCmdFlush('INST PNOISE');
//    Log('进入相噪测试模式');
//    WaitMS(500);
//    SARaw.WriteCmdFlush('CALC:LPLOT:MARK:TABL:STAT ON');
//    Log('显示MARKER表');
//    WaitMS(100);
//
//    for  i:= Low(FLog.PhaseNoise) to High(FLog.PhaseNoise) do
//    begin
//      SARaw.WriteCmdFlush(Format('CALC:LPLOT:MARK%d:MODE POS', [i + 1]));
//      WaitMS(50);
//      SARaw.WriteCmdFlush(Format('CALC:LPLOT:MARK%d:X %s', [i + 1, LO1_PHASENOISE_FREQ[i]]));
//      WaitMS(50);
//      Log(Format('设置 Marker%d 为 %s ', [i, LO1_PHASENOISE_FREQ[i]]));
//    end;
//
//    Log('开始测量相噪');
//    for i := Low(Freqs) to High(Freqs) do
//    begin
//      g_LO1.SetFreq(Format('%.0f', [Freqs[i]]));
//      SARaw.WriteCmdFlush(Format('FREQ:CARR %.2fMHz', [Freqs[i]]));
//      WaitMS(100);
//      SARaw.WriteCmdFlush('FREQ:CARR:SEAR');
//      WaitMS(15000);
//
//      //:INITiate[:IMMediate]
//      //SARaw.WriteCmdFlush(':INITiate:IMMediate');
//      //WaitMS(100);
//      Log(Format('频率: %.2fMHz', [Freqs[i]]));
//      for j := Low(FLog.PhaseNoise) to High(FLog.PhaseNoise) do
//      begin
//        SARaw.WriteCmdFlush('CALC:LPLOT:MARK' + IntToStr(j + 1)+ ':Y?');
//        FLog.PhaseNoise[j].Values[i]:=
//          {$IFDEF DEBUG}i + j - 115
//          {$ELSE}SARaw.InternalReadFloat()
//          {$ENDIF};
//        Log(Format('       %.2fdBc/Hz@%s ',
//              [FLog.PhaseNoise[j].Values[i],  LO1_PHASENOISE_FREQ[j]]));
//      end;
//      Inc(CurrStep);
//      FUI.set_Percent((CurrStep / TotalStep) * 100);
//      CheckWishStop();
//    end;
//  end;
//  {$ENDREGION}
//
//  {$REGION 'SIGNALLEVEL'}
//  Procedure MeasureSignalLevel;
//  var
//    i: Integer;
//    iPort: Integer;
//    StrengthValue: Double;
//  begin
//    //Measure PhaseNoise
//
//    //.....make e444a sa enter the phase noise mode and init the params
//    //...........show the marks table and fill the marker
//    SARaw.WriteCmdFlush('INST SA');
//    Log('进入频谱分析模式');
//    WaitMS(500);
//    SARaw.WriteCmdFlush('BWID:AUTO On');
//    WaitMS(100);
//    //SARaw.WriteCmdFlush('BAND 3 MHz');
//    //WaitMS(100);
//    SARaw.WriteCmdFlush('DISP:WIND:TRAC:Y:RLEV 10 dbm');
//    Log('电平设置为10dBm');
//    WaitMS(100);
//    SARaw.WriteCmdFlush('FREQ:SPAN 1 MHZ');
//    Log('显示带宽 1MHz');
//    SARaw.WriteCmdFlush('CALC:MARK:MODE POS');
//    WaitMS(100);
//
//    Log('开始测量信号电平');
//
//    for iPort := 0 to 5 do
//    begin
//      if FLog.SignalLevel[iPort].Checked then
//      begin
//        LOG('检测[' + LO1_PORT_NAME[iPort] +  ']端口');
//        for i := Low(Freqs) to High(Freqs) do
//        begin
//
//
//          g_LO1.SetFreq(Format(' %.0f', [Freqs[i]]));  //MHz
//          //WaitMS(100);
//          SARaw.WriteCmdFlush(Format('FREQ:CENT %.3fMHz', [Freqs[i]]));
//          //WaitMS(100);
//          SARaw.WriteCmdFlush(':INITiate:IMMediate');
//          WaitMS(2000);
//          SARaw.WriteCmdFlush('CALC:MARK:MAX');
//          //WaitMS(100);
//          SARaw.WriteCmdFlush('CALC:MARK:Y?');
//          WaitMS(100);
//          {$IFDEF DEBUG}
//          StrengthValue:= iPort + i - 1;
//          {$ELSE}
//          StrengthValue:= SARaw.InternalReadFloat();
//          {$ENDIF}
//          StrengthValue:= StrengthValue + InsLost;
//          FLog.SignalLevel[iPort].Values[i]:= StrengthValue;
//          Log(Format('     %.2f dBm@%.3fMHz', [StrengthValue, Freqs[i]]));
//          Inc(CurrStep);
//          FUI.set_Percent((CurrStep / TotalStep) * 100);
//          CheckWishStop();
//
//          if (iPort = 0) and (i = 0) then
//          begin
//            //在X4端口上测量首个频率的5MHz偏移来作为5MHz的指标
//            g_LO1.SetFreq(Format(' %.0f', [Freqs[i] + 5]));  //MHz
//            //WaitMS(100);
//            SARaw.WriteCmdFlush(Format('FREQ:CENT %.3fMHz', [Freqs[i]]));
//            //WaitMS(100);
//            SARaw.WriteCmdFlush(':INITiate:IMMediate');
//            WaitMS(2000);
//            SARaw.WriteCmdFlush('CALC:MARK:MAX');
//            //WaitMS(100);
//            SARaw.WriteCmdFlush('CALC:MARK:Y?');
//            WaitMS(100);
//            {$IFDEF DEBUG}
//            StrengthValue:= iPort + i - 1;
//            {$ELSE}
//            StrengthValue:= SARaw.InternalReadFloat();
//            {$ENDIF}
//            StrengthValue:= StrengthValue + InsLost;
//            //如果>= 3dBm则认为5MHz指标合格
//            FLog.Offset5Mhz:= StrengthValue;
//
//            if StrengthValue > 3 then
//            begin
//              Log( Format('     %.2f dBm@%.3fMHz, 5MHz 合格', [StrengthValue, Freqs[i] + 5]))
//            end
//            else
//            begin
//              Log( Format('     %.2f dBm@%.3fMHz, 5MHz 不合格', [StrengthValue, Freqs[i] + 5]));
//            end;
//
//            FUI.set_Percent((CurrStep / TotalStep) * 100);
//            CheckWishStop();
//          end;
//        end
//      end
//    end;
//  end;
//  {$ENDREGION}
//
//  {$REGION 'SPURIOUS'}
//  Procedure MeasureSignalSpurious;
//  var
//    i: Integer;
//    iPort: Integer;
//    RejectionRatio: Double;
//    Peak: Double;
//    HarmPeakL, HarmPeakR: Double;
//  begin
//    //Measure PhaseNoise
//
//    //.....make e444a sa enter the phase noise mode and init the params
//    //...........show the marks table and fill the marker
//    SARaw.WriteCmdFlush('INST SA');
//    Log('进入频谱分析模式');
//    WaitMS(500);
////    SARaw.WriteCmdFlush('BWID:AUTO OFF');
////    WaitMS(100);
////    SARaw.WriteCmdFlush('BAND 10 kHz');
////    Log('RES BAND 设置为 30kHz');
////    WaitMS(100);
//
//    SARaw.WriteCmdFlush('DISP:WIND:TRAC:Y:RLEV 10 dbm');
//    Log('电平设置为10dBm');
//    WaitMS(100);
////    SARaw.WriteCmdFlush('FREQ:SPAN 1 MHZ');
////    Log('X SCALE 1MHz');
//    SARaw.WriteCmdFlush('CALC:MARK:MODE POS');
//    WaitMS(100);
//
//    Log('开始测量信号电平');
//
//    for iPort := 0 to 5 do
//    begin
//      if FLog.Spurious[iPort].Checked then
//      begin
//        LOG('检测[' + LO1_PORT_NAME[iPort] +  ']端口');
//        for i := Low(Freqs) to High(Freqs) do
//        begin
//          SARaw.WriteCmdFlush('BWID:AUTO ON');
//          WaitMS(100);
//
//          g_LO1.SetFreq(Format(' %.0f', [Freqs[i]]));  //MHz
//          //WaitMS(100);
//          //Read the Singal strength
//          SARaw.WriteCmdFlush(Format('FREQ:STAR %.3f MHz', [Freqs[i] - 1]));
//          //WaitMS(100);
//          SARaw.WriteCmdFlush(Format('FREQ:STOP %.3f MHz', [Freqs[i] + 1]));
//          //WaitMS(100);
//          SARaw.WriteCmdFlush(':INITiate:IMMediate');
//          WaitMS(1000);
//          SARaw.WriteCmdFlush('CALC:MARK:MAX');
//          //WaitMS(100);
//          SARaw.WriteCmdFlush('CALC:MARK:Y?');
//          //WaitMS(100);
//          Peak:= SARaw.InternalReadFloat();
//          Peak:= Peak + InsLost;
//          //Read the left Spurious strength
//          SARaw.WriteCmdFlush('BWID:AUTO OFF');
//          WaitMS(100);
//          SARaw.WriteCmdFlush('BAND 30 kHz');
//          Log('RES BAND 设置为 30kHz');
//          WaitMS(100);
//
//          SARaw.WriteCmdFlush(Format('FREQ:STAR %.3f MHz', [Freqs[i] - 500]));
//          WaitMS(100);
//          SARaw.WriteCmdFlush(Format('FREQ:STOP %.3f MHz', [Freqs[i] - 3]));
//          WaitMS(100);
//          SARaw.WriteCmdFlush(':INITiate:IMMediate');
//          WaitMS(1000);
//          SARaw.WriteCmdFlush('CALC:MARK:MAX');
//          WaitMS(100);
//          SARaw.WriteCmdFlush('CALC:MARK:Y?');
//          WaitMS(100);
//          HarmPeakL:= SARaw.InternalReadFloat();
//          HarmPeakL:= HarmPeakL + InsLost;
//
//          //Read the right Spurious strength
//          SARaw.WriteCmdFlush(Format('FREQ:STAR %.3f MHz', [Freqs[i] + 3]));
//          WaitMS(100);
//          SARaw.WriteCmdFlush(Format('FREQ:STOP %.3f MHz', [Freqs[i] + 500]));
//          WaitMS(100);
//          SARaw.WriteCmdFlush(':INITiate:IMMediate');
//          WaitMS(1000);
//          SARaw.WriteCmdFlush('CALC:MARK:MAX');
//          WaitMS(100);
//          SARaw.WriteCmdFlush('CALC:MARK:Y?');
//          WaitMS(100);
//          HarmPeakR:= SARaw.InternalReadFloat();
//          HarmPeakR:= HarmPeakR + InsLost;
//          {$IFDEF DEBUG}
//            RejectionRatio:= 60 + iPort + i;
//          {$ELSE}
//          if HarmPeakL > HarmPeakR then
//            RejectionRatio:= Peak - HarmPeakL
//          else
//            RejectionRatio:= Peak - HarmPeakR;
//          {$ENDIF}
//
//          FLog.Spurious[iPort].Values[i]:= RejectionRatio;
//          Log(Format('    %.2f dB@%.3fMHz', [RejectionRatio, Freqs[i]]));
//
//          Inc(CurrStep);
//          FUI.set_Percent((CurrStep / TotalStep) * 100);
//          CheckWishStop();
//        end
//      end
//    end;
//  end;
//{$ENDREGION}
//  //不同的环境测试需要不同的频点
//  //只进行选择的项进行测试
//var
//  i: Integer;
//  bid, pid, sid: integer;
//  DisQualification: Boolean;
//begin
//  //inherited;
//
//  SARaw:= TAgilentE4440ARaw.Create;
//  With SARaw do
//  begin
//    Iden:= 'LO1';
//    bid:= 0;
//    pid:= 18;
//    sid:= 0;
//    LoadInstrumentParam(bid, pid, sid);
//    //Connnect(bid, pid, sid);
//  end;
////  SARaw.pid:= 19;
////    Iden:= 'SIGNAL_2';
////    LoadInstrumentParam(bid, pid, sid);
//
////  SARaw.LoadInstrumentParam();
//  SARaw.Connect2;
//  try
//    get_UI.SyncUI(@self.FLog);
//    InsLost:= FUI.ExamineItem.InlineInsertLost;
//    CurrStep:= 0;
//    TotalStep:= self.FLog.CalcuTotalStep;
//    //Choice the freq point according UI option
//    case self.FLog.EnvType of
//      etLo1Low,
//      etLo1High,
//      etLo1TempStriked,
//      etLo1shainkStriked,
//      etLo1Delivery:
//      begin
//        SetLength(Freqs, Length(LO1_SIMPLE_TEST_FREQ));
//        for i := 0 to Length(Freqs) - 1 do
//        begin
//          Freqs[i]:= LO1_SIMPLE_TEST_FREQ[i];
//        end;
//      end
//    else
//      SetLength(Freqs, Length(LO1_TEMP_NORMAL_FREQ));
//      for i := 0 to Length(Freqs) - 1 do
//      begin
//        Freqs[i]:= LO1_TEMP_NORMAL_FREQ[i];
//      end;
//    end;
//
//    if FLog.PhaseNoiseChecked then
//      MeasurePhaseNoise()
//    else
//      Log('不进行相噪测试');
//
//    MeasureSignalLevel();
//    MeasureSignalSpurious();
//
//    FLog.ToExcel(ProductSN, DisQualification);
//    Log('结束写入Excel数据报表');
//
//    if DisQualification then
//      Log('本次测试有不合格数据')
//    else
//      Log('本次测试合格');
//
//  finally
//    Set_Status(esComplete);
//  end;
//end;
//
//
//procedure TExamineLO1.Init;
//begin
//  FExamineCaption:= '一本振';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', '一本振.exe');
//
//end;





end.
