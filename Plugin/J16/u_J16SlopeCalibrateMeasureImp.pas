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
  CONST_LEVELS_PER_MODE: Array[0..2] of Array[0..1] of Integer = (
    (-10, -30),
    (-30, -60),
    (-60, -90)
  );
  CONST_YXRATIO: array[0..1] of Double = (9.2, 480.00);
var
  SG: ISignalGenerator;
  Radio: IJ08Receiver;
  Calibrator: ISlopeCalibrate;
  bid, pid, sid: integer;
  i, j, k, m: Integer;
  SampledLevels: Array[0..1] of Array[0..2] of Array[0..1] of Double;
  Coeffs: Array[0..1] of TSlopCoffRecArray;
begin
  inherited;
 //------------------
 //初始化设备
 //------------------
  {$IFNDEF Debug_Emu}
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
  {$ENDIF}

  Log('打开接收机，并设置为上报原始数据');
  //-------------------
  //AM斜率测试
  //-------------------



//  //打开信号源，设置为15M， -60dB 单音

//  Log('信号源输出 15MHz');
//
  SetLength(Coeffs[0], 3);
  SetLength(Coeffs[1], 3);
  //AM测试条件
  Coeffs[0, 0].AX     := -10;
  Coeffs[0, 0].BX     := -30;
  Coeffs[0, 0].AYWish := -60;
  Coeffs[0, 0].BYWish := -244;

  Coeffs[0, 1].AX     := -30;
  Coeffs[0, 1].BX     := -60;
  Coeffs[0, 1].AYWish:= -244;
  Coeffs[0, 1].BYWish:= -520;

  Coeffs[0, 2].AX     := -60;
  Coeffs[0, 2].BX     := -90;
  Coeffs[0, 2].AYWish:= -520;
  Coeffs[0, 2].BYWish:= -796;


  //FM测试条件
  Coeffs[1, 0].AX     := -10;
  Coeffs[1, 0].BX     := -30;
  Coeffs[1, 0].AYWish := 20000;
  Coeffs[1, 0].BYWish := 10400;

  Coeffs[1, 1].AX     := -30;
  Coeffs[1, 1].BX     := -60;
  Coeffs[1, 1].AYWish:= 10400;
  Coeffs[1, 1].BYWish:= -4000;

  Coeffs[1, 2].AX     := -60;
  Coeffs[1, 2].BX     := -90;
  Coeffs[1, 2].AYWish:= -4000;
  Coeffs[1, 2].BYWish:= -18400;
  {$IFDEF DEBUG_EMU}
  SampledLevels[0, 0, 0]:= -85;
  SampledLevels[0, 0, 1]:= -275;
  SampledLevels[0, 1, 0]:= -38;
  SampledLevels[0, 1, 1]:= -391;
  SampledLevels[0, 2, 0]:= -102;
  SampledLevels[0, 2, 1]:= -385;

  SampledLevels[1, 0, 0]:= 9004;
  SampledLevels[1, 0, 1]:= -763;
  SampledLevels[1, 1, 0]:= 11219;
  SampledLevels[1, 1, 1]:= -3015;
  SampledLevels[1, 2, 0]:= 8748;
  SampledLevels[1, 2, 1]:= -5783;
  {$ENDIF}

  for i:= 0 to Length(CONST_MODULS) - 1 do
  begin
    {$IFNDEF Debug_Emu}
    SG.SetFreqency(CONST_MODULS_FREQS[i] / 1000);
    SG.SetOnOff(True);
    {$ENDIF}
    Log(Format('信号源输出 %.0fMHz', [CONST_MODULS_FREQS[i] / 1000]));

    {$IFNDEF Debug_Emu}
    InternalCheck(Radio.SetFrequency(CONST_MODULS[i], CONST_MODULS_FREQS[i]),
          '设置AM频率失败');
    {$ENDIF}

    Log(Format('接收机设置: %s  %d KHz', [CONST_STR_MODUL[CONST_MODULS[i]],
                                          CONST_MODULS_FREQS[i]
                                      ]));
    for j := 0 to Length(CONST_AMP_STATES) - 1 do
    begin
      {$IFNDEF Debug_Emu}
      InternalCheck(Radio.SetHiGain(damManual, CONST_AMP_STATES[j]), '设置手动增益模式失败');
      {$ENDIF}
      if CONST_AMP_STATES[j] = dmmAttent then
        WaitMS(500);

      Log(Format('接收机增益模式: %s', [CONST_STR_DEVMANUALMODE[CONST_AMP_STATES[j]]]));

      for k := 0 to Length(CONST_LEVELS_PER_MODE[j]) - 1 do
      begin
        {$IFNDEF Debug_Emu}
        SG.SetLevelDbm(CONST_LEVELS_PER_MODE[j, k]);
        {$ENDIF}
        Log(Format('信号源电平设置: %d dBm', [CONST_LEVELS_PER_MODE[j, k]]));
        WaitMS(100);
        {$IFDEF DEBUG}
        //InternalCheck(Radio.ReadLevel(SampledLevels[i, j, k], mtAM, L_DummyHint),  '读取电平值失败');
        //使用预置数模拟
        {$ELSE}
        InternalCheck(Radio.ReadLevel(SampledLevels[i, j, k], mtAM),  '读取电平值失败');
        {$ENDIF}
        Log(Format('读取到接收机电平值: %.0f', [SampledLevels[i, j, k]]));

        if k = 0 then
        begin
          Coeffs[i, j].AX:= CONST_LEVELS_PER_MODE[j, k];
          Coeffs[i, j].AY:= SampledLevels[i, j, k];
        end
        else
        begin
          Coeffs[i, j].BX:= CONST_LEVELS_PER_MODE[j, k];
          Coeffs[i, j].BY:= SampledLevels[i, j, k];
        end;
      end;
    end;

    CalcuSlopeCoff(Coeffs[i], CONST_YXRATIO[i]);
    Log('计算系数完成:' );
    for m := 0 to Length(Coeffs[i]) - 1 do
    begin
      Log(Format('      [%d]  :%.8f, %.8f', [m + 1, Coeffs[i, m].PrimaryCoeff, Coeffs[i, m].ConstantTerm]));
    end;
//
//    for i := 0 to 2 - 1 do
//    begin
//      Coeffs[i].AX:= CONST_AM_LEVELS_PER_MODE[]
//      SampledLevels[i]
//    end;
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
