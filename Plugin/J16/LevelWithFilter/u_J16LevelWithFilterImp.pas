unit u_J16LevelWithFilterImp;

interface
uses
  Classes, SysUtils, StrUtils, u_ExamineImp, u_J08TaskIntf, u_J08Task, u_J16CommonDef;
type
  TLevelWithFilterMeasure = Class(TCustomExamineItem, IStatText2XLS)
  Private
    FOption: TLevelWithFilterOption;
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

{ TLevelWithFilterMeasure }

procedure TLevelWithFilterMeasure.CallBack_TextFileFound(
  const FileName: string; const Info: TSearchRec; var Abort: Boolean);
begin
  self.FLevelDataFileList.Add(FileName);
  Log(FileName);
end;

procedure TLevelWithFilterMeasure.DoProcess;
{------------------------------------------------------------------------------
共分10个段，每段三个测试频点，最后一个段为ＦＭ段，根据界面选项进行放大或直通模式下进行测试
----------------------------------------------------------------------------}
const
  CONST_SG_LEVEL: Array[0..1] of Integer = (-60, -40);
  CONST_BAND_FREQS: Array[0..9] of Array[0..2] of Integer = (
    (0500, 1000, 1490),
    (1500, 1800, 2180),
    (2200, 2600, 3100),
    (3200, 3800, 4600),
    (4700, 5500, 6700),
    (6800, 8300, 9700),
    (9800, 11500, 14100),
    (14200, 16600, 20600),
    (20700, 25000, 30000),
    (88000, 98000, 108000)
  );
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
  ManualMode: TJ08_DevManualMode;
  LevelsMeasured: Array[0..9] of Array[0..2] of Double;

  Procedure SaveLevelsMeasured2TextFile;
  var
    iBand, iFreq : integer;
    TextFileName: String;
    StrList: TStringList;
    TextDir: STring;
  begin
    TextDir:= TextDir_NoFilter();
    if Not DirectoryExists(TextDir) then
    begin
      ForceDirectories(TextDir);
    end;
    TextFileName:= TextDir  + ProductSN  + '_' + CONST_STR_DEVMANUALMODE[ManualMode] +'.txt';
    StrList:= TStringList.Create;
    try
      for iBand := 0 to Length(LevelsMeasured) - 1 do
        for iFreq := 0 to Length(LevelsMeasured[iBand]) - 1 do
        begin
          //FM不进行首尾0dBm激励的测试
          StrList.Add(IntToStr(Trunc(LevelsMeasured[iBand, iFreq])));
        end;
      StrList.SaveToFile(TextFileName);
    finally
      StrList.Free;
    end;
    Log('记录数据文件: ' + TextFileName);
  end;
var
  iBand, iFreq: Integer;

  Modulate: TJ08_ModuType;
  FreqKHz: Integer;
  DummyHInt: STring;
begin
  Log('------有滤波器电平读数测试(自动切换)------------');
  self.FUI.SyncUI(@Self.FOption);
  
  CurrStep:= 0;
  TotalStep:= 31;
  InsLost:= FUI.ExamineItem.InlineInsertLost;
    
  Radio:=  TJ16Receiver.Create;
  Calibrator:= Radio as ISlopeCalibrate;

  ManualMode:= dmmAmpli;
  if FOption.ManualMode = 1 then
    ManualMode:= dmmDirect;
  Log('----------'+CONST_STR_DEVMANUALMODE[ManualMode] +
      '模式 ' +InttoStr(CONST_SG_LEVEL[FOption.ManualMode])+
      'dBm -------------');
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
    InternalCheck(Radio.SetHiGain(damManual, ManualMode), '设置' + CONST_STR_DEVMANUALMODE[ManualMode] + '模式失败');
    {$ENDIF}

    Log('打开接收机,上报校准后数据');

    for iBand:= 0 to Length(CONST_BAND_FREQS) - 1 do
    begin
      Log('第'+ IntToStr(iBand + 1)  +'段');
      for iFreq := 0 to Length(CONST_BAND_FREQS[iBand]) - 1 do
      begin
        FreqKHz:= CONST_BAND_FREQS[iBand, iFreq];

        if iBand <= Length(CONST_BAND_FREQS) - 2 then
        begin
          Modulate:= mtAM;
        end
        else
        begin
          Modulate:= mtFM;
        end;



        {$IFNDEF Debug_Emu}
        SG.SetFreqency(FreqKHz / 1000);
        SG.SetLevelDbm(CONST_SG_LEVEL[FOption.ManualMode] + InsLost)
        SG.SetOnOff(True);
        {$ENDIF}
        

        {$IFNDEF Debug_Emu}
        InternalCheck(Radio.SetFrequency(Modulate, FreqKHz),
              '设置频率失败');
        {$ENDIF}

        //Log(Format('接收机设置: %s  %d KHz', [CONST_STR_MODUL[Modulate], FreqKHz]));

        WaitMS(100);

        {$IFDEF DEBUG_emu}
        if Modulate = mtAM then
        begin
          if ManualMode =  dmmAmpli then
            LevelsMeasured[iBand, iFreq]:= -550 + Random(10) - 5
          else
            LevelsMeasured[iBand, iFreq]:= -350 + Random(10) - 5;
        end
        else
        begin
          LevelsMeasured[iBand, iFreq]:= -5500 + Random(500) - 250
        end;
        {$ELSE}
        InternalCheck(Radio.ReadLevel(LevelsMeasured[iBand, iFreq], Modulate, DummyHint),  '读取电平值失败');
        {$ENDIF}
        Log(Format('      %6.0f @%.3f MHz', [LevelsMeasured[iBand, iFreq], FreqKHz / 1000]));

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
//    save to text file
    SaveLevelsMeasured2TextFile();
    Inc(CurrStep);
    FUI.set_Percent((CurrStep / TotalStep) * 100); //curr step count value should be 13
    CheckWishStop();
    Log('完成');
  finally
    Set_Status(esComplete);
  end;
end;

procedure TLevelWithFilterMeasure.DoStatText2XLS;
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
const
  AM_ROW_STR = '1';
  FM_ROW_STR = '24';
begin
  Log('统计文本被调用');
  FLevelDataFileList:= TStringList.Create;
  LevelStrs:= TStringList.Create;
  try
    CnCommon.FindFile(TextDir_NoFilter(), '*.txt',  CallBack_TextFileFound);
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
        if FileExists(StatXLSFileName) then
        begin
          wb.LoadFromFile(StatXLSFilename);
        end
        else
        begin
          rs:= TResourceStream.Create(HInstance, 'StatWithoutFilterTemplate', 'MYFILE');
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

          //Level[0]数组填充到B2开始的列,B1为SN号

          iRow:= 0;
          ASheet.AsString[iCol, iRow]:= SN;
          for iLine := 0 to Length(Level[0]) - 1  do
          begin
            ASheet.AsInteger[iCol, iRow + iLine + 1]:= Level[0, iLine];
          end;
          //Level[1]数组填充到B25开始的列,B24为SN号

          iRow:= 23;
          ASheet.AsString[iCol, iRow]:= SN;
          for iLine := 0 to Length(Level[1]) - 3 do
          begin
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
        Log('统计完成');
      finally
        wb.Free;
      end;
    end;
  finally
    LevelStrs.Free;
    FLevelDataFileList.Free;
  end;
end;

procedure TLevelWithFilterMeasure.Init;
begin
  inherited;
  //FExamineCaption:= '电平测试'#$D#$A'(无滤波器)';
  FExamineCaption:= '有滤波器电平';
//  FExamineCaption:= '一本振';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', '一本振.exe');
end;

procedure TLevelWithFilterMeasure.InternalCheck(const Value: Boolean;
  const ExceptionInfo: String);
begin
 if Not Value then
    Raise Exception.Create(ExceptionInfo);
end;





end.
