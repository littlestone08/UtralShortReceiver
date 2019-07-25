unit u_J08TaskIntf;

interface
uses
  Classes, BT_Taskintf, u_J08WeakGlobal, IniFiles;

type
//  IJ08Task = Interface(IBTTask)
//    ['{A65C7629-3C31-4A10-8568-ABCF98EC6A0B}']
//    function get_Instrument: ISignalGenerator;
//    function  CalcuCompensateSignalOutLevel(AFreqMHz: Double; AWishDbm: Double): Double;
//    Property Instrument: ISignalGenerator Read get_Instrument;
//  End;
//  IJ08DevItem = Interface(IBTDevItem)
//    ['{5C22C0AD-9CAA-4439-B9A2-2E2B49582A2F}']
//    function get_CoeffInifile: TIniFile;
//    Property CoeffIniFile: TIniFile Read get_CoeffInifile;
//  End;


  //接收机通信接口
  IAMData = interface
    function get_Depth: Integer;
    Procedure set_Depth(Value: Integer);
    function get_Level: Smallint;
    Procedure set_Level(Value: Smallint);
    function get_Frequency: Integer;
    Procedure set_Frequency(Value: Integer);
//    function get_FreqOffset: shortInt;
//    Procedure set_FreqOffset(Value: shortInt);
//    function get_TEF6901_REG(Index: Integer): Byte;
//    Procedure set_TEF6901_REG(Index: Integer; Value: Byte);
    function get_LevelAmendment(Index: Integer): Byte;
    Procedure set_LevelAmendment(Index: Integer; Value: Byte);
    function get_AmpMode: TJ08_DevAmpMode;
    Procedure set_AmpMode(Value: TJ08_DevAmpMode);
    function get_DevManualMode: TJ08_DevManualMode;
    function get_CarrierLock: Boolean;
    Procedure set_CarrierLock(Value: Boolean);

    Property Depth: Integer Read get_Depth Write set_Depth;
    Property Level: Smallint Read get_Level Write set_Level;
    {$IFDEF DEBUG}
    function get_LevelAvgLog: AnsiString;
    Property LevelAvgLog: AnsiString Read get_LevelAvgLog;
    {$ENDIF}    
    Property Frequency: Integer Read get_Frequency Write set_Frequency;
//    Property FreqOffset: shortInt Read get_FreqOffset Write set_FreqOffset;
//    Property TEF6901_REG[Index: Integer]: Byte Read get_TEF6901_REG Write set_TEF6901_REG;
    Property LevelAmendment[Index: Integer]: Byte Read get_LevelAmendment Write set_LevelAmendment;
    Property AmpMode: TJ08_DevAmpMode Read get_AmpMode Write set_AmpMode;
    Property DevManualMode: TJ08_DevManualMode Read get_DevManualMode;
    Property CarrierLock: Boolean Read get_CarrierLock Write set_CarrierLock;
  end;

  IFMData = interface
    function get_Depth: Integer;
    Procedure set_Depth(Value: Integer);
    function get_Unused: Integer;
    Procedure set_Unused(Value: Integer);

    function get_Level: Integer;
    Procedure set_Level(Value: Integer);
//    function get_TEF6901_REG(Index: Integer): Byte;
//    Procedure set_TEF6901_REG(Index: Integer; Value: Byte);
    function get_LevelAmendment(Index: Integer): Byte;
    Procedure set_LevelAmendment(Index: Integer; Value: Byte);
    function get_DevManualMode: TJ08_DevManualMode;

//    function get_R_Level: Integer;
//    function get_L_Level: Integer;
//    function get_R_Power: Integer;
//    function get_L_Power: Integer;
//    Procedure set_R_Level(Value: Integer);
//    Procedure set_L_Level(Value: Integer);
//    Procedure set_R_Power(Value: Integer);
//    Procedure set_L_Power(Value: Integer);


    Property Depth: Integer Read get_Depth Write set_Depth;
    Property Unused: Integer Read get_Unused Write set_Unused;
//    Property R_Level: Integer Read get_R_Level Write set_R_Level;
//    Property L_Level: Integer Read get_L_Level Write set_L_Level;
//    Property R_Power: Integer Read get_R_Power Write set_R_Power;
//    Property L_Power: Integer Read get_L_Power Write set_L_Power;
    Property Level: Integer Read get_Level Write set_Level;
    //Property Frequency: Cardinal Read get_Frequency Write set_Frequency;
//    Property TEF6901_REG[Index: Integer]: Byte Read get_TEF6901_REG Write set_TEF6901_REG;
    {$IFDEF DEBUG}
    function get_LevelAvgLog: AnsiString;
    Property LevelAvgLog: AnsiString Read get_LevelAvgLog;
    {$ENDIF}
    Property LevelAmendment[Index: Integer]: Byte Read get_LevelAmendment Write set_LevelAmendment;
    Property DevManualMode: TJ08_DevManualMode Read get_DevManualMode;
  end;

  IFMFreqSpectData = interface
    function get_Data(Index: Byte): Byte;
    Procedure set_Data(Index: Byte; Value: Byte);
    function get_Count: Byte;
    Procedure Clear;

    Property Data[Index: Byte]: Byte Read get_Data Write set_Data;
    Property Count: Byte Read get_Count;
  end;

  IScanData = interface
    function get_LevelData(Index: Integer): WORD;

    function get_RawData(Index: Integer): WORD;
    Procedure set_RawData(Index: Integer; Value: WORD);
    function get_Count: Integer;
    Procedure Clear;

    Property RawData[Index: Integer]: WORD Read get_RawData Write set_RawData;
    Property LevelData[Index: Integer]: WORD Read get_LevelData;
    Property Count: Integer Read get_Count;
  end;



  IJ08Receiver = interface
    ['{8555CC60-0EE4-4ECB-A9FE-565860C9B8FB}']
    Procedure StartPort;
    Procedure StopPort;

    {$IFDEF DEBUG}
    Procedure Internal_SetFrequency(ModuType: TJ08_ModuType; ValueHz: Cardinal);
    Procedure Internal_SetTEF6901Volumn(Value: Byte);
    Procedure internal_SetFMDepthCalcTime(Value: WORD = $1FFF);
    Procedure Internal_SetScanParam(ModuType: TJ08_ModuType;
                                    FreqBeginHz: Cardinal;
                                    StepKHz: Byte;
                                    PointCount: Word;
                                    SampleTimePerPointMs: Word;
                                    IFGain: SmallInt);
    Procedure Internal_SetReportData(Value: Boolean = False);
    Procedure Internal_StopScan();
    Procedure Internal_SetHiGain(Mode: TJ08_DevAmpMode; Value: TJ08_DevManualMode);
    Procedure Internal_SetAMIFBandWidth(Value: TJ08_AMIFBandWidth = aibw_8K);
    Procedure Internal_SetAMDepthCalcBandWidth(Value: TJ08_AMDepthCalcBandWidth = adbw_3K);
    Procedure Internal_SetReceiverActive(Value: Boolean);
    Procedure Internal_SetCarrierBandWidth(Value: TJ08_CarrierBandWidth = cbw_Wide); //设置载波环带宽
    Procedure Internal_SetAMVolumn(Value: Byte = 127{0~127});
    Procedure Internal_SetAGCActive(Value: Boolean = True);
    Procedure Internal_CoefficientWrite(Value: AnsiString);
    Procedure Internal_CoefficientRead(WishLen: Word; var Value: AnsiString);
    Procedure Internal_SetFMScanBenchmark(Value: WORD = 20000);
    Procedure Internal_SetSSBMode(Value: TJ08_SSBMode);
    Procedure Internal_SetSSBGain(Value: WORD = 600{0~1290});
    Procedure Internal_SetFMThreshold(Amp2Dir: Smallint = 11300;
                                      Dir2Att: Smallint = 11300;
                                      Att2Dir: Smallint = -6000;
                                      Dir2Amp: Smallint = -8000);
    Procedure Internal_SetAMThreshold(Amp2Dir: Smallint = 290;
                                      Dir2Att: Smallint = 290;
                                      Att2Dir: Smallint = 840;
                                      Dir2Amp: Smallint = 840);
    Procedure Internal_SetIFFilerOffset(Value: Smallint = 0);
    function Internal_WriteFlash(AStream: TMemoryStream; MaxTryTimes: Integer; TimeOutMs: Integer): Boolean;
    function Internal_ReadFlash(AStream: TMemoryStream): Boolean;
    {$ENDIF}

    function get_AmpMode: TJ08_DevAmpMode;
    function get_ManualMode(Modutype: TJ08_ModuType): TJ08_DevManualMode;

    function SetHiGain(const AmpMode: TJ08_DevAmpMode; const ManualMode: TJ08_DevManualMode): Boolean;

    {$IFDEF DEBUG}
    function ReadLevel(out Value: Double; const ModuType: TJ08_ModuType; var AHint: AnsiString): Boolean;
    {$ELSE}
    function ReadLevel(out Value: Double; const ModuType: TJ08_ModuType): Boolean;
    {$ENDIF}
    function ReadDepth(out Value: Double; const ModuType: TJ08_ModuType): Boolean;
    function ReadScanValue(ModuType: TJ08_ModuType; CFHz: Cardinal; StepKHz: Cardinal; PointCount: Cardinal;
            DetectTimeMS: Cardinal; Gain: Cardinal;
            var ValueList: TCardinalDoubleDynArray; var CFValue: TCardinalDoublePair): Boolean;
    function SetFrequency(AModual: TJ08_ModuType; AFreq: Cardinal):Boolean;

    Procedure OpenReceiver;
    Procedure CloseReceiver;

    function get_ReportDataType: TJ08_ModuType;
    function get_AMData: IAMData;
    function get_FMData: IFMData;
    function get_ScanData: IScanData;
    function get_OnScanData: TNotifyEvent;
    Procedure set_OnScanData(Value: TNotifyEvent);
    function get_OnAMData: TNotifyEvent;
    Procedure set_OnAMData(Value: TNotifyEvent);
    function get_OnFMData: TNotifyEvent;
    Procedure set_OnFMData(Value: TNotifyEvent);

    function get_ReceiverTrunedOn: Boolean;
    function get_OnFMFreqSpectData: TNotifyEvent;
    Procedure set_OnFMFreqSpectData(Value: TNotifyEvent);
    function FlashWrite(AStream: TMemoryStream; MaxTryTimes: Integer; TimeOutMs: Integer): Boolean;
    function FlashRead(AStream: TMemoryStream): Boolean;


    function get_RS232Opened: Boolean;


    Property PortOpened: Boolean read get_RS232Opened;
    Property ReportDataType: TJ08_ModuType Read get_ReportDataType;
    Property AmpMode: TJ08_DevAmpMode Read get_AmpMode;
    Property ManualMode[Modutype: TJ08_ModuType]: TJ08_DevManualMode Read get_ManualMode;
    Property AMData: IAMData Read get_AMData;
    Property FMData: IFMData Read get_FMData;
    Property ScanData: IScanData Read get_ScanData;

    Property ReceiverTrunedOn: Boolean Read get_ReceiverTrunedOn;

    Property OnScanData: TNotifyEvent Read get_OnScanData Write set_OnScanData;
    Property OnAMData: TNotifyEvent Read get_OnAMData Write set_OnAMData;
    Property OnFMData: TNotifyEvent Read get_OnScanData Write set_OnFMData;
    Property OnFMFreqSpectData: TNotifyEvent Read get_OnFMFreqSpectData Write set_OnFMFreqSpectData;
    
  end;

implementation

end.
