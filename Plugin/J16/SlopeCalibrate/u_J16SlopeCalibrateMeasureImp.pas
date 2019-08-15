unit u_J16SlopeCalibrateMeasureImp;

interface
uses
  Classes, SysUtils, u_ExamineImp, u_J08TaskIntf, u_J08Task, u_J16CommonDef;
type
  TSlopeCalibrateMeasure = Class(TCustomExamineItem)
  Private
    Procedure InternalCheck(const Value: Boolean; const ExceptionInfo: String);
  Protected
    Procedure Init; Override;
    Procedure DoProcess; Override;
  Public

  End;

implementation
uses
  u_GPIB_DEV2, u_J16Receiver, u_ExamineGlobal, u_J08WeakGlobal, PlumUtils, u_J16Utils,
  u_CommonDef;

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
  SampledLevels: Array[0..1] of Array[0..2] of Array[0..1] of Single;
  CoeffSrc: Array[0..1] of TSlopCoffRecArray;
  ReadBackCoff: TCoffReport;
  Coffs2Write: Array  of TCoffs;
  Procedure _Load_Coffs2Write_FromCoeffSrc();
  var
    i: Integer;
  begin
    SetLength(Coffs2Write, Length(CoeffSrc));
    for i := 0 to Length(CoeffSrc) - 1 do
    begin
      Coffs2Write[i, 0, 0]:= CoeffSrc[0, 2].PrimaryCoeff;
      Coffs2Write[i, 0, 1]:= CoeffSrc[0, 2].ConstantTerm;

      Coffs2Write[i, 1, 0]:= CoeffSrc[0, 1].PrimaryCoeff;
      Coffs2Write[i, 1, 1]:= CoeffSrc[0, 1].ConstantTerm;

      Coffs2Write[i, 2, 0]:= CoeffSrc[0, 0].PrimaryCoeff;
      Coffs2Write[i, 2, 1]:= CoeffSrc[0, 0].ConstantTerm;
    end;
  end;

  Function _CompareCoffs(const V1: TCoffs; const V2: TCoffs): Boolean;
  var
    i, j: Integer;
  begin
    Result:= True;
    for i := 0 to Length(V1) - 1 do
    begin
      for j := 0 to Length(V1[i]) - 1 do
      begin
        if V1[i, j] <> V2[i, j] then
        begin
          Result:= False;
          Log(Format('    比较失败: %.8f <> %.8f', [V1[i, j], V2[i, j]]));
          Break;
        end;
      end;
      if Not Result then
        Break;
    end;

  end;
var
  CurrStep, TotalStep: Integer;
  InsLost: Double;
begin
//  inherited;
  CurrStep:= 0;
  TotalStep:= 15;
//  Inc(CurrStep);
//  FUI.set_Percent((CurrStep / TotalStep) * 100);
//  CheckWishStop();

//          FUI.set_Percent((CurrStep / TotalStep) * 100);
 //------------------
 //初始化设备
 //------------------

  Radio:=  TJ16Receiver.Create;
  Calibrator:= Radio as ISlopeCalibrate;
  try
    {$IFNDEF Debug_Emu}
    SG:= TMG36XX.Create;
    With SG do
    begin
      pid:= 3;
      Iden:= 'SG';
      LoadInstrumentParam(bid, pid, sid);
      Connnect(bid, pid, sid);
    end;

    if not Radio.ReceiverTrunedOn then
      Radio.OpenReceiver;
    Calibrator.SetCoeffValid(False);
    Calibrator.LevelDataFormat(0);
    {$ENDIF}

    InsLost:= FUI.ExamineItem.InlineInsertLost;
    Log('打开接收机，并设置为上报原始数据');
    //-------------------
    //AM斜率测试
    //-------------------



  //  //打开信号源，设置为15M， -60dB 单音

  //  Log('信号源输出 15MHz');
  //
    SetLength(CoeffSrc[0], 3);
    SetLength(CoeffSrc[1], 3);
    //AM测试条件
    CoeffSrc[0, 0].AX     := -10;
    CoeffSrc[0, 0].BX     := -30;
    CoeffSrc[0, 0].AYWish := -60;
    CoeffSrc[0, 0].BYWish := -244;

    CoeffSrc[0, 1].AX     := -30;
    CoeffSrc[0, 1].BX     := -60;
    CoeffSrc[0, 1].AYWish:= -244;
    CoeffSrc[0, 1].BYWish:= -520;

    CoeffSrc[0, 2].AX     := -60;
    CoeffSrc[0, 2].BX     := -90;
    CoeffSrc[0, 2].AYWish:= -520;
    CoeffSrc[0, 2].BYWish:= -796;


    //FM测试条件
    CoeffSrc[1, 0].AX     := -10;
    CoeffSrc[1, 0].BX     := -30;
    CoeffSrc[1, 0].AYWish := 20000;
    CoeffSrc[1, 0].BYWish := 10400;

    CoeffSrc[1, 1].AX     := -30;
    CoeffSrc[1, 1].BX     := -60;
    CoeffSrc[1, 1].AYWish:= 10400;
    CoeffSrc[1, 1].BYWish:= -4000;

    CoeffSrc[1, 2].AX     := -60;
    CoeffSrc[1, 2].BX     := -90;
    CoeffSrc[1, 2].AYWish:= -4000;
    CoeffSrc[1, 2].BYWish:= -18400;
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
    //读取电平值并计算
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
          SG.SetLevelDbm(CONST_LEVELS_PER_MODE[j, k] + InsLost);
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
            CoeffSrc[i, j].AX:= CONST_LEVELS_PER_MODE[j, k];
            CoeffSrc[i, j].AY:= SampledLevels[i, j, k];
          end
          else
          begin
            CoeffSrc[i, j].BX:= CONST_LEVELS_PER_MODE[j, k];
            CoeffSrc[i, j].BY:= SampledLevels[i, j, k];
          end;

          Inc(CurrStep);
          FUI.set_Percent((CurrStep / TotalStep) * 100);
          CheckWishStop();
        end;
      end;
    end;

    //curr step count value should be 12 now
    //计算系数
    CalcuSlopeCoff(CoeffSrc[i], CONST_YXRATIO[i]);
    Log('计算系数完成:' );
    for m := 0 to Length(CoeffSrc[i]) - 1 do
    begin
      Log(Format('      [%d]  :%.8f, %.8f', [m + 1, CoeffSrc[i, m].PrimaryCoeff, CoeffSrc[i, m].ConstantTerm]));
    end;

    Inc(CurrStep);
    FUI.set_Percent((CurrStep / TotalStep) * 100); //curr step count value should be 13
    CheckWishStop();
    //写入接收机,校验成功后存储
    _Load_Coffs2Write_FromCoeffSrc();
  //    Calibrator.SetAMCoeff(CoeffSrc[0, 2].PrimaryCoeff, CoeffSrc[0, 2].ConstantTerm,
  //                          CoeffSrc[0, 1].PrimaryCoeff, CoeffSrc[0, 1].ConstantTerm,
  //                          CoeffSrc[0, 0].PrimaryCoeff, CoeffSrc[0, 0].ConstantTerm );
  //    WaitMS(50);
  //    Calibrator.SetFMCoeff(CoeffSrc[1, 2].PrimaryCoeff, CoeffSrc[1, 2].ConstantTerm,
  //                          CoeffSrc[1, 1].PrimaryCoeff, CoeffSrc[1, 1].ConstantTerm,
  //                          CoeffSrc[1, 0].PrimaryCoeff, CoeffSrc[1, 0].ConstantTerm );
  //    WaitMS(50);
    Calibrator.SetAMCoeff2( Coffs2Write[0] );
    WaitMS(50);
    Calibrator.SetFMCoeff2( Coffs2Write[1] );
    WaitMS(50);
    Calibrator.SetCoeffValid(True);
    WaitMS(10);
    Calibrator.LevelDataFormat(1);
    WaitMS(10);

    Log('设置系数完成,准备校验....');
    if Calibrator.QueryCoeffInfo(ReadBackCoff) then
    begin
      Log('校验AM写入数据...');
      if Not _CompareCoffs(Coffs2Write[0], ReadBackCoff.AMCoff) then
      begin
        {$IFNDEF Debug_Emu}
        Raise Exception.Create('AM数据校验不正确');
        {$ENDIF}
      end;
      Log('校验FM写入数据...');
      if Not _CompareCoffs(Coffs2Write[1], ReadBackCoff.FMCoff) then
      begin
        {$IFNDEF Debug_Emu}
        Raise Exception.Create('FM数据校验不正确');
        {$ENDIF}
      end;
      Log('校验完成');
      Calibrator.WriteToE2PROM;
      WaitMS(100);
      Log('写入完成');
      Inc(CurrStep);
      FUI.set_Percent((CurrStep / TotalStep) * 100);
      CheckWishStop();
    end
    else
    begin
      Raise Exception.Create('从接收机读取数据失败, 校准中断');
    end;
    Inc(CurrStep);
    FUI.set_Percent((CurrStep / TotalStep) * 100); //curr step count value should be 13
    CheckWishStop();
  finally
    Set_Status(esComplete);
  end;
end;

procedure TSlopeCalibrateMeasure.Init;
begin
  inherited;
  FExamineCaption:= '电平测试(无滤波器)';
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
