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
�ֱ���AM��FM��,�ö�Ӧ�ĵ���Ƶ���ڲ�ͬ�ķ���������,��ȡ��Ӧ���ϱ�LEVELֵ,������
ֵ�����Ϊ�ļ���,��STRINGLIST�ķ�ʽ�洢���ı�Ŀ¼��,���Ժ�ͳ��ʹ��
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
    TextDir:= Excel_Dir +  '���˲�������\';
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
    Log('��¼�����ļ�: ' + TextFileName);
  end;
var
  i, k: Integer;
begin
  Log('------���˲�����ƽ��������(�Զ��л�)------------');

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
    InternalCheck(Radio.SetHiGain(damAuto, CONST_AMP_STATES[j]), '�����Զ�����ģʽʧ��');
    {$ENDIF}

    Log('�򿪽��ջ�,������Ϊ�Զ��л�ģʽ,�ϱ�У׼������');

    for i:= 0 to Length(CONST_MODULS) - 1 do
    begin
      {$IFNDEF Debug_Emu}
      SG.SetFreqency(CONST_MODULS_FREQS[i] / 1000);
      SG.SetOnOff(True);
      {$ENDIF}
      Log(Format('�ź�Դ��� %.0fMHz', [CONST_MODULS_FREQS[i] / 1000]));

      {$IFNDEF Debug_Emu}
      InternalCheck(Radio.SetFrequency(CONST_MODULS[i], CONST_MODULS_FREQS[i]),
            '����Ƶ��ʧ��');
      {$ENDIF}

      Log(Format('���ջ�����: %s  %d KHz', [CONST_STR_MODUL[CONST_MODULS[i]],
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
        InternalCheck(Radio.ReadLevel(LevelsMeasured[i, k], CONST_MODULS[i]),  '��ȡ��ƽֵʧ��');
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

procedure TLevelWithoutFilterMeasure.Init;
begin
  inherited;
  FExamineCaption:= '��ƽ����(���˲���)';
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
