unit u_J16LevelWithoutFilterImp;

interface
uses
  Classes, SysUtils, StrUtils, u_ExamineImp, u_J08TaskIntf, u_J08Task, u_J16CommonDef;
type
  TLevelWithoutFilterMeasure = Class(TCustomExamineItem, IStatText2XLS)
  Private
//    FLog: TLO1MesureLog;
    Procedure InternalCheck(const Value: Boolean; const ExceptionInfo: String);
  Private
    FLevelDataFileList: TStringList;
    procedure CallBack_TextFileFound(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  Protected //inteface IStatText2XLS
    Procedure DoStatText2XLS;
  Protected
    Procedure Init; Override;
    Procedure DoProcess; Override;
  Public

  End;

implementation
uses
  u_GPIB_DEV2, u_J16Receiver, u_ExamineGlobal, u_J08WeakGlobal, PlumUtils, u_J16Utils,
  u_CommonDef, CnCommon, XLSReadWriteII5, XLSSheetData5, Xc12Utils5;

{ TLevelWithoutFilterMeasure }

procedure TLevelWithoutFilterMeasure.CallBack_TextFileFound(
  const FileName: string; const Info: TSearchRec; var Abort: Boolean);
begin
  self.FLevelDataFileList.Add(FileName);
  Log(FileName);
end;

procedure TLevelWithoutFilterMeasure.DoProcess;
{------------------------------------------------------------------------------
分别在AM和FM下,用对应的单音频率在不同的幅度下输入,读取对应的上报LEVEL值,读到的
值以序号为文件名,用STRINGLIST的方式存储在文本目录中,供以后统计使用
----------------------------------------------------------------------------}
const
  CONST_MODULS: Array[0..1] of TJ08_ModuType = (mtAM, mtFM);
  CONST_MODULS_FREQS: Array[0..1] of Integer = (15000, 98000);
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
  LevelRead: Double;
var
  LevelsMeasured: Array[0..1] of Array of Single;

  Procedure SaveLevelsMeasured2TextFile;
  var
    i, j : integer;
    TextFileName: String;
    StrList: TStringList;
    TextDir: STring;
  begin
    TextDir:= TextDir_NoFilter();
    if Not DirectoryExists(TextDir) then
    begin
      ForceDirectories(TextDir);
    end;
    TextFileName:= TextDir  + ProductSN  + '.无滤波器.txt';
    StrList:= TStringList.Create;
    try
      for i := 0 to Length(LevelsMeasured) - 1 do
        for j := 0 to Length(LevelsMeasured[i]) - 1 do
        begin
          //FM不进行首尾0dBm激励的测试
          if i = 1 then
          begin
            if (j = 0) or (j = Length(CONST_TEST_LEVELS) - 1) then
              continue;
          end;
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
  UIOption: TLevelWithoutFilterOption;
begin
  Log('------无滤波器电平读数测试(自动切换)------------');

  get_UI.SyncUI(@UIOption);
  
  CurrStep:= 0;
  TotalStep:= 43;
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
    {$ENDIF}
    
    if not Radio.ReceiverTrunedOn then
      Radio.OpenReceiver;

    WaitMS(100);
    Radio.Internal_SetFMThreshold(UIOption.FMThreshold[0], UIOption.FMThreshold[1],
                    UIOption.FMThreshold[2], UIOption.FMThreshold[3]);
    WaitMS(100);
    Radio.Internal_SetAMThreshold(UIOption.AMThreshold[0], UIOption.AMThreshold[1],
                  UIOption.AMThreshold[2], UIOption.AMThreshold[3]);

    WaitMS(100);
    InternalCheck(Radio.SetHiGain(damAuto, dmmAttent), '设置自动增益模式失败');

    Calibrator.SetCoeffValid( True );
    WaitMS(100);
    Calibrator.LevelDataFormat( 1 );

    WaitMS(100);


    Log('打开接收机,并设置为自动切换模式,上报校准后数据');

    for i:= 0 to Length(CONST_MODULS) - 1 do
    begin
      {$IFNDEF Debug_Emu}
      SG.SetFreqency(CONST_MODULS_FREQS[i] / 1000);
      SG.SetOnOff(True);
      {$ENDIF}
      Log(Format('信号源输出 %.0fMHz', [CONST_MODULS_FREQS[i] / 1000]));

      WaitMS(200);
      {$IFNDEF Debug_Emu}
      InternalCheck(Radio.SetFrequency(CONST_MODULS[i], CONST_MODULS_FREQS[i] * 1000),
            '设置频率失败');
      {$ENDIF}

      Log(Format('接收机设置: %s  %d KHz', [CONST_STR_MODUL[CONST_MODULS[i]],
                                            CONST_MODULS_FREQS[i]
                                        ]));

      for k := 0 to Length(CONST_TEST_LEVELS) - 1 do
      begin
        if CONST_MODULS[i] = mtFM then
        begin
          //FM不进行首尾0dBm激励的测试
          if (k = 0) or (k = Length(CONST_TEST_LEVELS) - 1) then
            continue;
        end;
        {$IFNDEF Debug_Emu}
        SG.SetLevelDbm(CONST_TEST_LEVELS[k] + InsLost);
        {$ENDIF}

        WaitMS(UIOption.StableDelay);
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

        InternalCheck(Radio.ReadLevel(LevelRead, CONST_MODULS[i]),  '读取电平值失败');
        LevelsMeasured[i, k]:= LevelRead;
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

procedure TLevelWithoutFilterMeasure.DoStatText2XLS;
var
  Level: Array[0..1] of Array[0..21] of Integer;
  LevelStrs: TStringList;
  Procedure ReadLevelValue(FileName: String);
  var
    Ptr: PInteger;
    i: Integer;
  begin
    Ptr:= @Level[0, 0];
    LevelStrs.LoadFromFile(FileName);
    if LevelStrs.Count <> 42 then
      Raise Exception.Create('数据记录的行数不正确');
    for i := 0 to LevelStrs.Count - 1 do
    begin
      Ptr^:= StrToInt(LevelStrs[i]);
      Inc(Ptr);
    end;
  end;
var
  i, iline: Integer;
  iCol: Integer;
  iRow: Integer;
  SN: String;
  StatXLSFileName: String;
  ASheet: TXLSWorksheet;
  rs: TResourceStream;
  wb: TXLSReadWriteII5;
  CalcExp: String;
//const
//  AM_ROW_STR = '1';
//  FM_ROW_STR = '24';
begin
  Log('统计文本被调用');
  FLevelDataFileList:= TStringList.Create;
  LevelStrs:= TStringList.Create;
  try
    CnCommon.FindFile(TextDir_NoFilter(), '*.无滤波器.txt',  CallBack_TextFileFound);
    FLevelDataFileList.Sort();
    //每个文件共44个数
    Log('共找到' + IntToStr(FLevelDataFileList.Count) + '个文件');
    //把文件中的数据填充到EXCEL中, 前22个是AM数据, 从B2开始(B1是标题),
    //后22是FM数据,从B25开始((B24是标题))
    if FLevelDataFileList.Count > 0 then
    begin
      wb:= TXLSReadWriteII5.Create(Nil);
      try
        StatXLSFileName:=  TextDir_NoFilter() + '\数据统计.xlsx';
//        if FileExists(StatXLSFileName) then
//        begin
//          wb.LoadFromFile(StatXLSFilename);
//        end
//        else
        begin
          rs:= TResourceStream.Create(HInstance, 'StatTemplate', 'MYFILE');
          try
            wb.LoadFromStream(rs);
          finally
            rs.Free;
          end;
        end;
        ASheet:= wb.Sheets[0];
        //B01:  iCol = 1, iRow =  0
        //B24: iCol = 1, iRow = 23
        iCol:= 1;
        for i := 0 to FLevelDataFileList.Count - 1 do
        begin
          ReadLevelValue(FLevelDataFileList[i]);

          SN:= ExtractFileName(FLevelDataFileList[i]);
          SetLength(SN, Length(SN) - Length(ExtractFileExt(SN)));
          SetLength(SN, Length(SN) - Length(ExtractFileExt(SN)));

          //Level[0]数组填充到B2开始的列,B1为SN号

          iRow:= 0;
          ASheet.ClearCell(iCol, iRow);
          ASheet.AsString[iCol, iRow]:= SN;
          for iLine := 0 to Length(Level[0]) - 1  do
          begin
            ASheet.ClearCell(iCol, iRow + iLine + 1);
            ASheet.AsInteger[iCol, iRow + iLine + 1]:= Level[0, iLine];
          end;
          //Level[1]数组填充到B25开始的列,B24为SN号

          iRow:= 23;
          ASheet.AsString[iCol, iRow]:= SN;
          for iLine := 0 to Length(Level[1]) - 3 do
          begin
            ASheet.ClearCell(iCol, iRow + iLine + 1);
            //ASheet.AsString[iCol, iRow + iLine + 1]:= '0';
            ASheet.AsInteger[iCol, iRow + iLine + 1]:= Level[1, iLine];
          end;
          //RefStrToColRow()
          Inc(iCol);
        end;
        //填写公式, 每行的最小最大和差值
        //COL: 1~iCol
        //ROW: 1~22, 24~43
        ASheet.AsString[iCol + 0, 0]:= '最小值';
        ASheet.AsString[iCol + 1, 0]:= '最大值';
        ASheet.AsString[iCol + 2, 0]:= '差值';
        for i := 1 to 22 do
        begin
          CalcExp:= 'Min(' + ColRowToRefStr(1, i) + ':' + ColRowToRefStr(iCol - 1, i) +')';
          ASheet.AsFormula[iCol + 0, i]:= CalcExp;

          CalcExp:= 'Max(' + ColRowToRefStr(1, i) + ':' + ColRowToRefStr(iCol - 1, i) +')';
          ASheet.AsFormula[iCol + 1, i]:= CalcExp;

          CalcExp:= ColRowToRefStr(iCol + 1, i) + ' - ' + ColRowToRefStr(iCol + 0, i);
          ASheet.AsFormula[iCol + 2, i]:= CalcExp;
        end;

        ASheet.AsString[iCol + 0, 23]:= '最小值';
        ASheet.AsString[iCol + 1, 23]:= '最大值';
        ASheet.AsString[iCol + 2, 23]:= '差值';
        for i := 24 to 43 do
        begin
          CalcExp:= 'Min(' + ColRowToRefStr(1, i) + ':' + ColRowToRefStr(iCol - 1, i) +')';
          ASheet.AsFormula[iCol + 0, i]:= CalcExp;

          CalcExp:= 'Max(' + ColRowToRefStr(1, i) + ':' + ColRowToRefStr(iCol - 1, i) +')';
          ASheet.AsFormula[iCol + 1, i]:= CalcExp;

          CalcExp:= ColRowToRefStr(iCol + 1, i) + ' - ' + ColRowToRefStr(iCol + 0, i);
          ASheet.AsFormula[iCol + 2, i]:= CalcExp;
        end;

        wb.SaveToFile(StatXLSFileName);
        Log('统计完成: ' + StatXLSFileName);
      finally
        wb.Free;
      end;
    end;
  finally
    LevelStrs.Free;
    FLevelDataFileList.Free;
  end;
end;

procedure TLevelWithoutFilterMeasure.Init;
begin
  inherited;
  //FExamineCaption:= '电平测试'#$D#$A'(无滤波器)';
  FExamineCaption:= '无滤波器电平';
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
