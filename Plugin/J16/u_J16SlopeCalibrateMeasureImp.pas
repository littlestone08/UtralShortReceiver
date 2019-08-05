unit u_J16SlopeCalibrateMeasureImp;

interface
uses
  Classes, SysUtils, u_ExamineImp, u_J08TaskIntf, u_J08Task;
type
  TSlopeCalibrateMeasure = Class(TCustomExamineItem)
  Private
//    FLog: TLO1MesureLog;
    Procedure InternalCheck(const Value: Boolean; const ExceptionInfo: String);
  Protected
    Procedure Init; Override;
    Procedure DoProcess; Override;
  Public

  End;

implementation
uses
  u_GPIB_DEV2, u_J16Receiver, u_ExamineGlobal, u_J08WeakGlobal;

{ TSlopeCalibrateMeasure }

procedure TSlopeCalibrateMeasure.DoProcess;
const
  CONST_AM_MODES: Array[0..2] of TJ08_DevManualMode = (dmmAttent, dmmDirect,  dmmAmpli);
  CONST_AM_LEVELS_PER_MODE: Array[0..2] of Array[0..1] of Integer = (
    (-10, -30),
    (-30, -60),
    (-60, -90)
  );
var
  SG: ISignalGenerator;
  Radio: IJ08Receiver;
  Calibrator: ISlopeCalibrate;
  bid, pid, sid: integer;
  i: Integer;
begin
  inherited;
   //------------------
   //初始化设备
   //------------------

  SG:= TMG36XX.Create;
  With SG do
  begin
    pid:= 3;
    Iden:= 'SG';
    LoadInstrumentParam(bid, pid, sid);
    Connnect(bid, pid, sid);
  end;                                             
  Radio:=  TJ16Receiver.Create;
  Calibrator:= Radio as ISlopeCalibrate;
  //-------------------
  //AM斜率测试
  //-------------------



//  //打开信号源，设置为15M， -60dB 单音
  SG.SetFreqency(15);
  SG.SetOnOff(True);
//  Log('信号源输出 15MHz');
//
  for i:= 0 to Length(CONST_AM_MODES) -1 do
  begin
    {$IFDEF EMU}
    L_Level:= Random(100);
    {$ELSE}
    if not L_Receiver.ReceiverTrunedOn then
      L_Receiver.OpenReceiver;

    InternalCheck(L_Receiver.SetFrequency(mtAM, CONST_MEASURE_LEVEL_BANDINFOS[FBProcParam.Band].BandCenterKHZ * 1000),
          '设置AM频率失败');

    InternalCheck(L_Receiver.SetHiGain(damManual, FBProcParam.ManualMode),
            RevrPropSetFaildStr(CONST_STR_DEVAMPMODE[damManual] + '---' + CONST_STR_DEVMANUALMODE[FBProcParam.ManualMode],
                                  CONST_STR_DEVAMPMODE[L_Receiver.AmpMode] + '---' +  CONST_STR_DEVMANUALMODE[L_Receiver.ManualMode[mtAM]]));

    Sleep(FSampleTimeMs);
    if FBProcParam.ManualMode = dmmAttent then
      Sleep(500);

    InternalCheck(L_Receiver.ReadDepth(L_Depth, mtAM),  '读取调制度值失败');
    //OutputDebugString(PChar(Format('%.2f', [L_Depth / 100])));
      {$IFDEF DEBUG}
    InternalCheck(L_Receiver.ReadLevel(L_Level, mtAM, L_Hint),  '读取电平值失败');
    Sender.LogDebug(L_Hint);
      {$ELSE}
    InternalCheck(L_Receiver.ReadLevel(L_Level, mtAM),  '读取电平值失败');
      {$ENDIF}
    {$ENDIF}

    TJ08BProcStore(Sender.BProcStore).SetValue(
                TJ08MeasureType(Parent.Iden),
                FBProcParam.Band,
                FBProcParam.Level,
                FBProcParam.ManualMode,
                L_Level);
    HintInfo:= Description[dufThreadHint] + Format('电平值为 %.2f', [L_Level]);

    Sender.LogDebug(HintInfo);
  end
//  //打开接收机，进入非修正模式
//  if not Radio.ReceiverTrunedOn then
//    Radio.OpenReceiver;
//  Calibrator.SetCoeffValid(False);
//  Calibrator.LevelDataFormat(0);
//  Radio.SetFrequency(mtAM, 15 * 1000);
//  Log('接收机系数设置为无效, 输出原始电平数据, 频率15MHz');
//
//  //小信号, 放大状态
//  SG.SetLevelDbm(-60);
//  Log('信号源输出 -60dBm');
//  InternalCheck(Radio.SetHiGain(damManual, dmmAmpli), '接收机手动模式'
//  //中信号,直通状态
//  //大信号,衰减状态

end;

procedure TSlopeCalibrateMeasure.Init;
begin
  inherited;
  FExamineCaption:= '斜率校准';
//  FExamineCaption:= '一本振';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', '一本振.exe');
end;

procedure TSlopeCalibrateMeasure.InternalCheck(const Value: Boolean;
  const ExceptionInfo: String);
begin
 if Not Value then
    Raise Exception.Create(ExceptionInfo);
end;

end.
