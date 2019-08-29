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


const
  CONST_TXT_EXTFILENAME:  Array[dmmAmpli..dmmDirect] of String = ('.�Ŵ�.txt', '.ֱͨ.txt');
{ TLevelWithFilterMeasure }

procedure TLevelWithFilterMeasure.CallBack_TextFileFound(
  const FileName: string; const Info: TSearchRec; var Abort: Boolean);
begin
  self.FLevelDataFileList.Add(FileName);
  Log(FileName);
end;

procedure TLevelWithFilterMeasure.DoProcess;
{------------------------------------------------------------------------------
����10���Σ�ÿ����������Ƶ�㣬���һ����Ϊ�ƣͶΣ����ݽ���ѡ����зŴ��ֱͨģʽ�½��в���
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
//  CONST_MODULS_FREQS: Array[0..1] of Integer = (15000, 90000);
//  CONST_TEST_LEVELS: Array[0..21] of Integer = (0, -10, -20, -30, -40, -50, -60,
//        -70, -80, -90, -100, -100, -90, -80, -70, -60, -50, -40, -30, -20, -10, 0);
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
    TextFileName:= TextDir  + ProductSN  + CONST_TXT_EXTFILENAME[ManualMode];
    StrList:= TStringList.Create;
    try
      for iBand := 0 to Length(LevelsMeasured) - 1 do
        for iFreq := 0 to Length(LevelsMeasured[iBand]) - 1 do
        begin
          //FM��������β0dBm�����Ĳ���
          StrList.Add(IntToStr(Trunc(LevelsMeasured[iBand, iFreq])));
        end;
      StrList.SaveToFile(TextFileName);
    finally
      StrList.Free;
    end;
    Log('��¼�����ļ�: ' + TextFileName);
  end;
var
  iBand, iFreq: Integer;

  Modulate: TJ08_ModuType;
  FreqKHz: Integer;
  DummyHInt: STring;
begin
  Log('------���˲�����ƽ��������(�Զ��л�)------------');
  Randomize();
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
      'ģʽ ' +InttoStr(CONST_SG_LEVEL[FOption.ManualMode])+
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
    WaitMS(100);
    Calibrator.LevelDataFormat( 1 );
    WaitMS(100);
    InternalCheck(Radio.SetHiGain(damManual, ManualMode), '����' + CONST_STR_DEVMANUALMODE[ManualMode] + 'ģʽʧ��');
    WaitMS(100);
    {$ENDIF}

    Log('�򿪽��ջ�,�ϱ�У׼������');

    for iBand:= 0 to Length(CONST_BAND_FREQS) - 1 do
    begin
      Log('��'+ IntToStr(iBand + 1)  +'��');
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
        SG.SetLevelDbm(CONST_SG_LEVEL[FOption.ManualMode] + InsLost);
        SG.SetOnOff(True);
        {$ENDIF}
        WaitMS(200);

        {$IFNDEF Debug_Emu}
        InternalCheck(Radio.SetFrequency(Modulate, FreqKHz * 1000),
              '����Ƶ��ʧ��');
        {$ENDIF}


        WaitMS(self.FOption.StableDelay);

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
        InternalCheck(Radio.ReadLevel(LevelsMeasured[iBand, iFreq], Modulate),  '��ȡ��ƽֵʧ��');
//        InternalCheck(Radio.ReadLevel(LevelsMeasured[iBand, iFreq], Modulate, DummyHint),  '��ȡ��ƽֵʧ��');
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
    Log('���');
  finally
    Set_Status(esComplete);
  end;
end;

procedure TLevelWithFilterMeasure.DoStatText2XLS;
var
  Level: Array[0..29] of Integer;
  LevelStrs: TStringList;
  Procedure ReadLevelValue(FileName: String);
  var
    Ptr: PInteger;
    i: Integer;
  begin
    Ptr:= @Level[0];
    LevelStrs.LoadFromFile(FileName);
    if LevelStrs.Count <> 30 then
      Raise Exception.Create('���ݼ�¼����������ȷ');
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
  RangeExp: String;
var
  iMode: TJ08_DevManualMode;
begin
  Log('ͳ���ı�������');
  FLevelDataFileList:= TStringList.Create;
  LevelStrs:= TStringList.Create;
  try
    for iMode := dmmAmpli to dmmDirect do
    begin
      FLevelDataFileList.Clear();
      CnCommon.FindFile(TextDir_NoFilter(), '*' + CONST_TXT_EXTFILENAME[iMode],  CallBack_TextFileFound);
      FLevelDataFileList.Sort();
      //ÿ���ļ���44����
      Log('���ҵ�' + IntToStr(FLevelDataFileList.Count) + '���ļ�');
      //���ļ��е�������䵽EXCEL��, ��B49��ʼ(B47�Ǳ���), ��B94��ʼ((B92�Ǳ���))

      if FLevelDataFileList.Count > 0 then
      begin
        wb:= TXLSReadWriteII5.Create(Nil);
        try
          StatXLSFileName:=  TextDir_NoFilter() + '\����ͳ��.xlsx';
//          if FileExists(StatXLSFileName) then
//          begin
//            wb.LoadFromFile(StatXLSFilename);
//          end
//          else
          begin
            rs:= TResourceStream.Create(HInstance, 'StatTemplate', 'MYFILE');
            try
              wb.LoadFromStream(rs);
            finally
              rs.Free;
            end;
          end;
          ASheet:= wb.Sheets[0];

          iCol:= 1;
          for i := 0 to FLevelDataFileList.Count - 1 do
          begin
            ReadLevelValue(FLevelDataFileList[i]);

            SN:= ExtractFileName(FLevelDataFileList[i]);
            SetLength(SN, Length(SN) - Length(ExtractFileExt(SN)));
            SetLength(SN, Length(SN) - Length(ExtractFileExt(SN)));



            if iMode = dmmAmpli then
              iRow:= 46
            else
              iRow:= 91;
            ASheet.AsString[iCol, iRow]:= SN;

            Inc(iRow);

            for iLine := 0 to Length(Level) - 1  do
            begin
              if (iLine > 0) and (iLine Mod 3 = 0) then
              begin
                RangeExp:= Format('%s:%s', [
                  ColRowToRefStr(iCol, iRow + iLine - 2),
                  ColRowToRefStr(iCol, iRow + iLine)
                  ]);
                ASheet.AsFormula[iCol, iRow + iLine + 1]:=
                  Format('Max(%s) - Min(%s)', [RangeExp, RangeExp]);
                Inc(iRow);
              end;
              ASheet.AsInteger[iCol, iRow + iLine + 1]:= Level[iLine];
            end;

            if (iLine > 0) and (iLine Mod 3 = 0) then
            begin
              RangeExp:= Format('%s:%s', [
                ColRowToRefStr(iCol, iRow + iLine - 2),
                ColRowToRefStr(iCol, iRow + iLine)
                ]);
              ASheet.AsFormula[iCol, iRow + iLine + 1]:=
                Format('Max(%s) - Min(%s)', [RangeExp, RangeExp]);
            end;

            Inc(iCol);
          end;

          //��д��ʽ, ÿ�е���С���Ͳ�ֵ
          //COL: 1~iCol
          if iMode = dmmAmpli then
            iRow:= 46 //SN
          else
            iRow:= 91;//SN

          ASheet.AsString[iCol + 0, iRow]:= '��Сֵ';
          ASheet.AsString[iCol + 1, iRow]:= '���ֵ';
          ASheet.AsString[iCol + 2, iRow]:= '��ֵ';
          for i := 1 to 40 do
          begin
            RangeExp:= Format('%s:%s', [
              ColRowToRefStr(1, iRow + 1 + i),
              ColRowToRefStr(iCol - 1, iRow + 1 + i)
              ]);
            ASheet.AsFormula[iCol + 0, iRow + 1 + i]:= Format('Min(%s)', [RangeExp]);
            ASheet.AsFormula[iCol + 1, iRow + 1 + i]:= Format('Max(%s)', [RangeExp]);
            ASheet.AsFormula[iCol + 2, iRow + 1 + i]:= Format('Max(%s)-Min(%s)', [RangeExp, RangeExp]);
          end;
          wb.SaveToFile(StatXLSFileName);
          Log('ͳ�����');
        finally
          wb.Free;
        end;
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
  //FExamineCaption:= '��ƽ����'#$D#$A'(���˲���)';
  FExamineCaption:= '���˲�����ƽ';
//  FExamineCaption:= 'һ����';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', 'һ����.exe');
end;

procedure TLevelWithFilterMeasure.InternalCheck(const Value: Boolean;
  const ExceptionInfo: String);
begin
 if Not Value then
    Raise Exception.Create(ExceptionInfo);
end;





end.
