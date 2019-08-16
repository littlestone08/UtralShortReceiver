unit u_J16LevelWithoutFilterImp;

interface
uses
  Classes, SysUtils, u_ExamineImp, u_J08TaskIntf, u_J08Task;
type
  TLevelWithoutFilterMeasure = Class(TCustomExamineItem)
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
  u_GPIB_DEV2, u_J16Receiver, u_ExamineGlobal, u_J08WeakGlobal, PlumUtils, u_J16Utils,
  u_CommonDef;

{ TLevelWithoutFilterMeasure }

procedure TLevelWithoutFilterMeasure.DoProcess;
{------------------------------------------------------------------------------
分别在AM和FM下,用对应的单音频率在不同的幅度下输入,读取对应的上报LEVEL值,读到的
值以序号为文件名,用STRINGLIST的方式存储在文本目录中,供以后统计使用
----------------------------------------------------------------------------}
const
  CONST_MODULS: Array[0..1] of TJ08_ModuType = (mtAM, mtFM);
  CONST_MODULS_FREQS: Array[0..1] of Integer = (15000, 90000);
  CONST_TEST_LEVELS: Array[0..21] of Integer = (0, -10, -20, -30, -40, -50, -60,
        -70, -80, -90, -100, -100, -90, -80, -70, -60, -50, -40, -30, -20, -10, 0);
var
  InsLost: Double;
  CurrStep, TotalStep: Integer;
var
  SG: ISignalGenerator;
  Radio: IJ08Receiver;
  Calibrator: ISlopeCalibrate;
  bid, pid, sid: integer;
var
  LevelsMeasured: Array[0..1] of Array of Single;

  Procedure SaveLevelsMeasured2TextFile;
  var
    i, j : integer;
    TextFileName: String;
    StrList: TStringList;
    TextDir: STring;
  begin
    TextDir:= Excel_Dir +  '无滤波器数据\';
    if Not DirectoryExists(TextDir) then
    begin
      ForceDirectories(TextDir);
    end;
    TextFileName:= TextDir  + ProductSN  + '.txt';
    StrList:= TStringList.Create;
    try
      for i := 0 to Length(LevelsMeasured) - 1 do
        for j := 0 to Length(LevelsMeasured[i]) - 1 do
        begin
          StrList.Add(IntToStr(Trunc(LevelsMeasured[i, j])));
        end;
      StrList.SaveToFile(TextFileName);
    finally
      StrList.Free;
    end;
    Log('记录数据文件: ' + TextFileName);
  end;
var
  i, k: Integer;
begin
  Log('------无滤波器电平读数测试(自动切换)------------');

  CurrStep:= 0;
  TotalStep:= 45;
  InsLost:= FUI.ExamineItem.InlineInsertLost;
    
  Radio:=  TJ16Receiver.Create;
  Calibrator:= Radio as ISlopeCalibrate;
  SetLength( LevelsMeasured[0], Length(CONST_TEST_LEVELS));
  SetLength( LevelsMeasured[1], Length(CONST_TEST_LEVELS));
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
    Calibrator.SetCoeffValid( True );
    Calibrator.LevelDataFormat( 1 );
    InternalCheck(Radio.SetHiGain(damAuto, CONST_AMP_STATES[j]), '设置自动增益模式失败');
    {$ENDIF}

    Log('打开接收机,并设置为自动切换模式,上报校准后数据');

    for i:= 0 to Length(CONST_MODULS) - 1 do
    begin
      {$IFNDEF Debug_Emu}
      SG.SetFreqency(CONST_MODULS_FREQS[i] / 1000);
      SG.SetOnOff(True);
      {$ENDIF}
      Log(Format('信号源输出 %.0fMHz', [CONST_MODULS_FREQS[i] / 1000]));

      {$IFNDEF Debug_Emu}
      InternalCheck(Radio.SetFrequency(CONST_MODULS[i], CONST_MODULS_FREQS[i]),
            '设置频率失败');
      {$ENDIF}

      Log(Format('接收机设置: %s  %d KHz', [CONST_STR_MODUL[CONST_MODULS[i]],
                                            CONST_MODULS_FREQS[i]
                                        ]));

      for k := 0 to Length(CONST_TEST_LEVELS) - 1 do
      begin
        {$IFNDEF Debug_Emu}
        SG.SetLevelDbm(CONST_TEST_LEVES[k] + InsLost);
        {$ENDIF}

        WaitMS(100);

        if CONST_MODULS[i] = mtAM then
        begin
          if Radio.AMData.DevManualMode = dmmAttent then
          begin
            WaitMS(500);
          end;
        end
        else if CONST_MODULS[i] = mtFM then
        begin
          if Radio.FMData.DevManualMode = dmmAttent then
          begin
            WaitMS(500);
          end;
        end;
             


        {$IFDEF DEBUG_emu}
        LevelsMeasured[i, k]:= CONST_TEST_LEVELS[k] * 9 + 34 + Random(10) - 5;
        {$ELSE}
        InternalCheck(Radio.ReadLevel(LevelsMeasured[i, k], CONST_MODULS[i]),  '读取电平值失败');
        {$ENDIF}
        Log(Format('      %6.0f @%5d dBm', [LevelsMeasured[i, k], CONST_TEST_LEVELS[k]]));

//        if k = 0 then
//        begin
//          CoeffSrc[i, j].AX:= CONST_LEVELS_PER_MODE[j, k];
//          CoeffSrc[i, j].AY:= SampledLevels[i, j, k];
//        end
//        else
//        begin
//          CoeffSrc[i, j].BX:= CONST_LEVELS_PER_MODE[j, k];
//          CoeffSrc[i, j].BY:= SampledLevels[i, j, k];
//        end;

        Inc(CurrStep);
        FUI.set_Percent((CurrStep / TotalStep) * 100);
        CheckWishStop();
      end;
    end;
    //save to text file 
    SaveLevelsMeasured2TextFile();
    Inc(CurrStep);
    FUI.set_Percent((CurrStep / TotalStep) * 100); //curr step count value should be 13
    CheckWishStop();
    Log('完成');
  finally
    Set_Status(esComplete);
  end;
end;

procedure TLevelWithoutFilterMeasure.Init;
begin
  inherited;
  FExamineCaption:= '电平测试(无滤波器)';
//  FExamineCaption:= '一本振';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', '一本振.exe');
end;

procedure TLevelWithoutFilterMeasure.InternalCheck(const Value: Boolean;
  const ExceptionInfo: String);
begin
 if Not Value then
    Raise Exception.Create(ExceptionInfo);
end;




end.
