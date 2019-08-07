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
  u_GPIB_DEV2, u_J16Receiver, u_ExamineGlobal, u_J08WeakGlobal, PlumUtils, u_J16Utils;

{ TSlopeCalibrateMeasure }

procedure TSlopeCalibrateMeasure.DoProcess;
const
  CONST_MODULS: Array[0..1] of TJ08_ModuType = (mtAM, mtFM);
  CONST_MODULS_FREQS: Array[0..1] of Integer = (15000, 90000);
  CONST_AMP_STATES: Array[0..2] of TJ08_DevManualMode = (dmmAttent, dmmDirect, dmmAmpli );
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
  i, j, k : Integer;
  {$IFDEF DEBUG}
  L_DummyHint: String;
  {$ENDIF}
  SampledLevels: Array[0..1] of Array[0..2] of Array[0..1] of Double;
  SlopCoeff: Array[0..2] of Array[0..1] of Double;
  Coeffs: Array of TSlopCoffRecArray;
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

  if not Radio.ReceiverTrunedOn then
    Radio.OpenReceiver;
  Calibrator.SetCoeffValid(False);
  Calibrator.LevelDataFormat(0);
  Log('打开接收机，并设置为上报原始数据');
  //-------------------
  //AM斜率测试
  //-------------------



//  //打开信号源，设置为15M， -60dB 单音

//  Log('信号源输出 15MHz');
//

  for i:= 0 to Length(CONST_MODULS) - 1 do
  begin


    SG.SetFreqency(CONST_MODULS_FREQS[i] / 1000);
    SG.SetOnOff(True);
    Log(Format('信号源输出 %.0fMHz', [CONST_MODULS_FREQS[i] / 1000]));

    InternalCheck(Radio.SetFrequency(CONST_MODULS[i], CONST_MODULS_FREQS[i]),
          '设置AM频率失败');

    Log(Format('接收机设置: %s  %d KHz', [CONST_STR_MODUL[CONST_MODULS[i]],
                                          CONST_MODULS_FREQS[i]
                                      ]));
    for j := 0 to Length(CONST_AMP_STATES) - 1 do
    begin
      InternalCheck(Radio.SetHiGain(damManual, CONST_AMP_STATES[j]), '设置手动增益模式失败');
      if CONST_AMP_STATES[j] = dmmAttent then
        WaitMS(500);

      Log(Format('接收机增益模式: %s', [CONST_STR_DEVMANUALMODE[CONST_AMP_STATES[j]]]));

      for k := 0 to Length(CONST_AM_LEVELS_PER_MODE[j]) - 1 do
      begin
        SG.SetLevelDbm(CONST_AM_LEVELS_PER_MODE[j, k]);
        Log(Format('信号源电平设置: %d dBm', [CONST_AM_LEVELS_PER_MODE[j, k]]));
        WaitMS(100);
        {$IFDEF DEBUG}
        InternalCheck(Radio.ReadLevel(SampledLevels[i, j, k], mtAM, L_DummyHint),  '读取电平值失败');
        {$ELSE}
        InternalCheck(Radio.ReadLevel(SampledLevels[i, j, k], mtAM),  '读取电平值失败');
        {$ENDIF}
        Log(Format('读取到接收机电平值: %.0f', [CONST_AM_LEVELS_PER_MODE[j, k]]));
      end;
    end;

    SetLength(Coeffs, 3);
    for i := 0 to 2 - 1 do
    begin
      Coeffs[i].AX:= CONST_AM_LEVELS_PER_MODE[]
      SampledLevels[i]
    end;
  end;



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
