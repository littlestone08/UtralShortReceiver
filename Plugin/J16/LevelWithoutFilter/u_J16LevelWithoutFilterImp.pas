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
�ֱ���AM��FM��,�ö�Ӧ�ĵ���Ƶ���ڲ�ͬ�ķ���������,��ȡ��Ӧ���ϱ�LEVELֵ,������
ֵ�����Ϊ�ļ���,��STRINGLIST�ķ�ʽ�洢���ı�Ŀ¼��,���Ժ�ͳ��ʹ��
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
    TextFileName:= TextDir  + ProductSN  + '.���˲���.txt';
    StrList:= TStringList.Create;
    try
      for i := 0 to Length(LevelsMeasured) - 1 do
        for j := 0 to Length(LevelsMeasured[i]) - 1 do
        begin
          //FM��������β0dBm�����Ĳ���
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
    Log('��¼�����ļ�: ' + TextFileName);
  end;
var
  i, k: Integer;
  UIOption: TLevelWithoutFilterOption;
begin
  Log('------���˲�����ƽ��������(�Զ��л�)------------');

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
    InternalCheck(Radio.SetHiGain(damAuto, dmmAttent), '�����Զ�����ģʽʧ��');

    Calibrator.SetCoeffValid( True );
    WaitMS(100);
    Calibrator.LevelDataFormat( 1 );

    WaitMS(100);


    Log('�򿪽��ջ�,������Ϊ�Զ��л�ģʽ,�ϱ�У׼������');

    for i:= 0 to Length(CONST_MODULS) - 1 do
    begin
      {$IFNDEF Debug_Emu}
      SG.SetFreqency(CONST_MODULS_FREQS[i] / 1000);
      SG.SetOnOff(True);
      {$ENDIF}
      Log(Format('�ź�Դ��� %.0fMHz', [CONST_MODULS_FREQS[i] / 1000]));

      WaitMS(200);
      {$IFNDEF Debug_Emu}
      InternalCheck(Radio.SetFrequency(CONST_MODULS[i], CONST_MODULS_FREQS[i] * 1000),
            '����Ƶ��ʧ��');
      {$ENDIF}

      Log(Format('���ջ�����: %s  %d KHz', [CONST_STR_MODUL[CONST_MODULS[i]],
                                            CONST_MODULS_FREQS[i]
                                        ]));

      for k := 0 to Length(CONST_TEST_LEVELS) - 1 do
      begin
        if CONST_MODULS[i] = mtFM then
        begin
          //FM��������β0dBm�����Ĳ���
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

        InternalCheck(Radio.ReadLevel(LevelRead, CONST_MODULS[i]),  '��ȡ��ƽֵʧ��');
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
    Log('���');
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
  CalcExp: String;
//const
//  AM_ROW_STR = '1';
//  FM_ROW_STR = '24';
begin
  Log('ͳ���ı�������');
  FLevelDataFileList:= TStringList.Create;
  LevelStrs:= TStringList.Create;
  try
    CnCommon.FindFile(TextDir_NoFilter(), '*.���˲���.txt',  CallBack_TextFileFound);
    FLevelDataFileList.Sort();
    //ÿ���ļ���44����
    Log('���ҵ�' + IntToStr(FLevelDataFileList.Count) + '���ļ�');
    //���ļ��е�������䵽EXCEL��, ǰ22����AM����, ��B2��ʼ(B1�Ǳ���),
    //��22��FM����,��B25��ʼ((B24�Ǳ���))
    if FLevelDataFileList.Count > 0 then
    begin
      wb:= TXLSReadWriteII5.Create(Nil);
      try
        StatXLSFileName:=  TextDir_NoFilter() + '\����ͳ��.xlsx';
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

          //Level[0]������䵽B2��ʼ����,B1ΪSN��

          iRow:= 0;
          ASheet.ClearCell(iCol, iRow);
          ASheet.AsString[iCol, iRow]:= SN;
          for iLine := 0 to Length(Level[0]) - 1  do
          begin
            ASheet.ClearCell(iCol, iRow + iLine + 1);
            ASheet.AsInteger[iCol, iRow + iLine + 1]:= Level[0, iLine];
          end;
          //Level[1]������䵽B25��ʼ����,B24ΪSN��

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
        //��д��ʽ, ÿ�е���С���Ͳ�ֵ
        //COL: 1~iCol
        //ROW: 1~22, 24~43
        ASheet.AsString[iCol + 0, 0]:= '��Сֵ';
        ASheet.AsString[iCol + 1, 0]:= '���ֵ';
        ASheet.AsString[iCol + 2, 0]:= '��ֵ';
        for i := 1 to 22 do
        begin
          CalcExp:= 'Min(' + ColRowToRefStr(1, i) + ':' + ColRowToRefStr(iCol - 1, i) +')';
          ASheet.AsFormula[iCol + 0, i]:= CalcExp;

          CalcExp:= 'Max(' + ColRowToRefStr(1, i) + ':' + ColRowToRefStr(iCol - 1, i) +')';
          ASheet.AsFormula[iCol + 1, i]:= CalcExp;

          CalcExp:= ColRowToRefStr(iCol + 1, i) + ' - ' + ColRowToRefStr(iCol + 0, i);
          ASheet.AsFormula[iCol + 2, i]:= CalcExp;
        end;

        ASheet.AsString[iCol + 0, 23]:= '��Сֵ';
        ASheet.AsString[iCol + 1, 23]:= '���ֵ';
        ASheet.AsString[iCol + 2, 23]:= '��ֵ';
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
        Log('ͳ�����: ' + StatXLSFileName);
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
  //FExamineCaption:= '��ƽ����'#$D#$A'(���˲���)';
  FExamineCaption:= '���˲�����ƽ';
//  FExamineCaption:= 'һ����';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', 'һ����.exe');
end;

procedure TLevelWithoutFilterMeasure.InternalCheck(const Value: Boolean;
  const ExceptionInfo: String);
begin
 if Not Value then
    Raise Exception.Create(ExceptionInfo);
end;




end.
