unit u_J08Task;

interface
uses
  Classes, SysUtils, StrUtils, Windows, Forms, WinSock, IniFiles,
   u_J08WeakGlobal,  u_J08TaskIntf,  CnRS232,
  PlumTickIntAverager{$IFDEF DEBUG}, CnDebug{$ENDIF}, PlumUtils,
  u_ExamineGlobal;
type
  TJ08Receiver = Class;

  TRawParser = Class
  Strict Private
    FInBuf: AnsiString;
    FCtrl: TJ08Receiver;
  Protected
    Procedure DoParser(var ABuf: AnsiString; const ACtrl: TJ08Receiver) ; virtual; abstract;
    class function PopBuf(const ALen: Cardinal; var AData: AnsiString): Boolean;
  Public
    Constructor Create(ACtrl: TJ08Receiver);
    Procedure Push(const Raw: AnsiString);
  End;
  TRawParserClass = class of TRawParser;

  TJ08Receiver = Class(TInterfacedObject, IJ08Receiver)
  {$REGION '私有工具类'}
  Private Type
    PAMReportRec = ^TAMReportRec;
    TAMReportRec = Packed Record
      case Integer of
        0:(
          FrameStart: Byte;
          FrameLen  : Byte;
          Depth     : WORD;
          Level     : Smallint;
          Freq      : Cardinal;
          TEF6901   : Array[0..6] of Byte;
          LevelAmendmentA: Byte;
          LevelAmendmentB: Byte;
          GainMode  : Byte;
          CarrierLocked: Byte;
          FrameEnd  : Byte;
          );
        1:(
          Raw: Array[0..21] of Byte
          )
    End;

    PFMReportRec = ^TFMReportRec;
    TFMReportRec = Packed Record
      case Integer of
        0:(
          FrameStart: Byte;
          FrameLen  : Byte;
          Depth     : WORD;
          Level     : WORD;
          Unused    : Cardinal;
          TEF6901   : Array[0..6] of Byte;
          R_Level   : WORD;
          L_Level   : WORD;
          R_Power   : WORD;
          L_Power   : WORD;
          LevelAmendmentA: Byte;
          LevelAmendmentB: Byte;
          FrameEnd  : Byte;
          );
        1:(
          Raw: Array[0..27] of Byte
          )
    End;

    PFMFreqSpectRec = ^TFMFreqSpectRec;
    TFMFreqSpectRec = packed record
      case Integer of
        0:(
          FrameStart: Byte;
          FrameLen  : Byte;
          FreqSpectData: Array[0..$C8] of Byte;
          FrameEnd  : Byte;
          );
        1:(
          Raw: Array[0..$CB] of Byte
          )
    end;
    TAMData = Class(TInterfacedObject, IAMData)
    Private
      FDepth: TTickIntAverager;
      FLevel: TTickIntAverager;
      FFrequency: Integer;
      FLevelAmendment: Array of Byte;
      FAmpMode: TJ08_DevAmpMode;
      FCarrierLock: Boolean;
    Protected
      function get_Depth: Integer;
      Procedure set_Depth(Value: Integer);
      function get_Level: Smallint;
      Procedure set_Level(Value: Smallint);
      function get_Frequency: Integer;
      Procedure set_Frequency(Value: Integer);
      function get_LevelAmendment(Index: Integer): Byte;
      Procedure set_LevelAmendment(Index: Integer; Value: Byte);
      function get_CarrierLock: Boolean;
      Procedure set_CarrierLock(Value: Boolean);

      function get_AmpMode: TJ08_DevAmpMode;
      Procedure set_AmpMode(Value: TJ08_DevAmpMode);
      function get_DevManualMode: TJ08_DevManualMode;
      {$IFDEF DEBUG}
      function get_LevelAvgLog: AnsiString;
      {$ENDIF}
    Public
      Constructor Create;
      Destructor Destroy; Override;
    End;

    TFMData = Class(TInterfacedObject, IFMData)
    Private
      FDepth: TTickIntAverager;
      FUnused: TTickIntAverager;
      FLevel: TTickIntAverager;
//      FLevelAmendment: Array of TTickIntAverager;
      FLevelAmendment: Array of Byte;
    Protected
      function get_Depth: Integer;
      Procedure set_Depth(Value: Integer);
      function get_Unused: Integer;
      Procedure set_Unused(Value: Integer);

      function get_Level: Integer;
      Procedure set_Level(Value: Integer);

      function get_LevelAmendment(Index: Integer): Byte;
      Procedure set_LevelAmendment(Index: Integer; Value: Byte);
      function get_DevManualMode: TJ08_DevManualMode;
      {$IFDEF DEBUG}
      function get_LevelAvgLog: AnsiString;
      {$ENDIF}
    public
      Constructor Create;
      Destructor Destroy; Override;
    End;

    TScanData = Class(TInterfacedObject, IScanData)
    Private
      FData: Array of WORD;
    Protected
      function get_LevelData(Index: Integer): WORD;
      function get_RawData(Index: Integer): WORD;
      Procedure set_RawData(Index: Integer; Value: WORD);
      function get_Count: Integer;
      Procedure Clear;
    public
      Constructor Create;
      Destructor Destroy; Override;
    End;

    TFMFreqSpectData = Class(TInterfacedObject, IFMFreqSpectData )
    Private
      FData: Array of Byte;
    Protected
      function get_Data(Index: Byte): Byte;
      Procedure set_Data(Index: Byte; Value: Byte);
      function get_Count: Byte;
      Procedure Clear;
    End;
  {$ENDREGION}
  Public type
  {$REGION '协议分析类'}
    TJ08RawParser = Class(TRawParser)
    Strict Private
      FWishScanDataN: Byte;
    Protected
      Procedure DoParser(var ABuf: AnsiString; const ACtrl: TJ08Receiver); override;
      Procedure DoParse2(var ABuf: AnsiString; const ACtrl: TJ08Receiver; var MatchCode: Byte); Virtual;
//      Procedure DoParser2(var ABuf: AnsiString; const ACtrl: TJ08Receiver)
    Public
      Property WishScanDataN: Byte read FWishScanDataN write FWishScanDataN;
    End;
  {$ENDREGION}
  Private
    FParser           : TRawParser;
    FRaw             : AnsiString;
    FWishRawDataCount: Cardinal;

    FReceiverTrunedOn: Boolean;

    FModuType: TJ08_ModuType;
    FAMData: IAMData;
    FFMData: IFMData;
    FScanData: IScanData;
    FFMFreqSpectData: IFMFreqSpectData;


    FOnScanData: TNotifyEvent;
    FOnAMData: TNotifyEvent;
    FOnFMData: TNotifyEvent;
    FOnFMFreqSpectData: TNotifyEvent;
  Private
    _FCmdWriteSucc: Boolean;
    _FStoreWriteSucc: Boolean;
    _FScanValueHandled: Boolean;

    Procedure WriteSetCmd(CmdStr: AnsiString; MaxTryTimes: Integer = 3; TimeOutMs: Cardinal = 5000);

  Private
    procedure OnRs232ReceiveHandler(Sender: TObject;
                                    Buffer: Pointer;
                                    BufferLength: Word);


  Protected
    Procedure WriteRawData(APtr: Pointer; ALen: Cardinal);
    function GetParserClass: TRawParserClass; virtual;
    function get_ReceiverTrunedOn: Boolean;
    Procedure OnCmdAckHandler;
    Procedure OnStoreAckHandler;
    Procedure OnReportHandler(const AData: AnsiString);
    Procedure OnScanDataHandler(const N: Byte; const AData: AnsiString); virtual;

    function Internal_MakeFreqData(ModuType: TJ08_ModuType; ValueHz: Cardinal): AnsiString;

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
    function Internal_ReadFlashRawData(out AData: AnsiString; ASize: WORD): Boolean;
  Protected
    function get_ReportDataType: TJ08_ModuType;
    function get_AmpMode: TJ08_DevAmpMode;
    function get_ManualMode(Modutype: TJ08_ModuType): TJ08_DevManualMode;

    function SetHiGain(const AmpMode: TJ08_DevAmpMode; const ManualMode: TJ08_DevManualMode): Boolean;
    {$IFDEF DEBUG}
    function ReadLevel(out Value: Double; const ModuType: TJ08_ModuType; var AHint: AnsiString): Boolean;
    {$ELSE}
    function ReadLevel(out Value: Double; const ModuType: TJ08_ModuType): Boolean;
    {$ENDIF}

    function ReadDepth(out Value: Double; const ModuType: TJ08_ModuType): Boolean;
    function SetFrequency(AModual: TJ08_ModuType; AFreq: Cardinal):Boolean;
    function WriteFlash(AStream: TMemoryStream; MaxTryTimes: Integer; TimeOutMs: Integer): Boolean;
    function ReadFlash(AStream: TMemoryStream): Boolean;
    function ReadScanValue(ModuType: TJ08_ModuType; CFHz: Cardinal; StepKHz: Cardinal; PointCount: Cardinal;
            DetectTimeMS: Cardinal; Gain: Cardinal;
            var ValueList: TCardinalDoubleDynArray; var CFValue: TCardinalDoublePair): Boolean;
    Procedure OpenReceiver;
    Procedure CloseReceiver;
    function get_AMData: IAMData;
    function get_FMData: IFMData;
    function get_ScanData: IScanData;
    Procedure StartPort;
    Procedure StopPort;
    function get_PortName: AnsiString;
    function get_RS232Opened: Boolean;
    function get_OnScanData: TNotifyEvent;
    Procedure set_OnScanData(Value: TNotifyEvent);
    function get_OnAMData: TNotifyEvent;
    Procedure set_OnAMData(Value: TNotifyEvent);
    function get_OnFMData: TNotifyEvent;
    Procedure set_OnFMData(Value: TNotifyEvent);
    function get_OnFMFreqSpectData: TNotifyEvent;
    Procedure set_OnFMFreqSpectData(Value: TNotifyEvent);
    //接口别名
    function IJ08Receiver.FlashWrite = WriteFlash;
    function IJ08Receiver.FlashRead = ReadFlash;
  Protected
    Procedure Init(AInitInfo: Pointer);
    Procedure Fina;
  Public
    Constructor Create;
    Destructor Destroy; override;
  End;
  //===================================================================


implementation




{ TUartCommCtrl1 }

procedure TJ08Receiver.StopPort;
begin
  if (g_RS232 <> Nil) and (g_RS232.Connected) then
  begin
    g_RS232.StopComm;
  end;
end;

procedure TJ08Receiver.CloseReceiver;
begin
  if FReceiverTrunedOn then
    try
      self.Internal_SetReportData(False);

      self.Internal_SetReceiverActive(False);
      self.FReceiverTrunedOn:= False;
    except
    end;

end;

Procedure TJ08Receiver.Init(AInitInfo: Pointer);
var
  L_PortName: String;
begin
  inherited;
  FParser           := self.GetParserClass().Create(Self);
  FAMData:= TAMData.Create;
  FFMData:= TFMData.Create;
  FScanData:= TScanData.Create;
  FFMFreqSpectData:= TFMFreqSpectData.Create;


  g_RS232.OnReceiveData:= OnRs232ReceiveHandler;
  {TODO:  注意默认波特率的配置}

  {$IFNDEF EMU}
  if Not g_RS232.Connected then
    g_RS232.StartComm;
  {$ENDIF}
  {$IFDEF DEBUG}
  CnDebugger.LogMsg(Format('打开串口 %s', [g_RS232.CommName]));
  {$ENDIF}

end;



constructor TJ08Receiver.Create;
begin
  inherited Create;
  self.Init(Nil);
end;

destructor TJ08Receiver.Destroy;
begin

  Fina();
  inherited;
end;

Procedure  TJ08Receiver.Fina;
begin
//  if FRS232Opened then
//  begin
//    FRS232.StopComm;
//    FRS232Opened:= False;
//  end;
//  FRS232.Free;
  g_RS232.OnReceiveData:= Nil;
  FScanData:= Nil;
  FFMData:= Nil;
  FAMData:= Nil;
  FFMFreqSpectData:= Nil;
  FParser.Free;
  inherited;
end;

function TJ08Receiver.GetParserClass: TRawParserClass;
begin
  Result:= TJ08RawParser;
end;

function TJ08Receiver.get_PortName: AnsiString;
begin
//  Result:= FRS232.CommName;
end;

function TJ08Receiver.get_AMData: IAMData;
begin
  Result:= FAMData;
end;

function TJ08Receiver.get_AmpMode: TJ08_DevAmpMode;
begin
  Result:= FAMData.AmpMode;
end;

function TJ08Receiver.get_FMData: IFMData;
begin
  Result:= FFMData;
end;

function TJ08Receiver.get_ManualMode(Modutype: TJ08_ModuType): TJ08_DevManualMode;
begin
  Result:= dmmUnknown;
  case Modutype of
    mtUnknown: ;
    mtAM: Result:= FAMData.DevManualMode;
    mtFM: Result:= FFMData.DevManualMode;
  end;
end;


function TJ08Receiver.get_ReportDataType: TJ08_ModuType;
begin
  Result:= FModuType;
end;

function TJ08Receiver.get_OnAMData: TNotifyEvent;
begin
  Result:= FOnAMData;
end;

function TJ08Receiver.get_OnFMData: TNotifyEvent;
begin
  Result:= FOnFMData;
end;

function TJ08Receiver.get_OnFMFreqSpectData: TNotifyEvent;
begin
  Result:= FOnFMFreqSpectData;
end;

function TJ08Receiver.get_OnScanData: TNotifyEvent;
begin
  Result:= FOnScanData;
end;

function TJ08Receiver.get_ReceiverTrunedOn: Boolean;
begin
  Result:= FReceiverTrunedOn;
end;

function TJ08Receiver.get_RS232Opened: Boolean;
begin
//  Result:= FRS232Opened;
end;

function TJ08Receiver.get_ScanData: IScanData;
begin
  Result:= FScanData;
end;


function TJ08Receiver.Internal_MakeFreqData(ModuType: TJ08_ModuType;
  ValueHz: Cardinal): AnsiString;
const
  const_ModuCde: Array[mtAM..mtFM] of AnsiChar = (#1, #0);
var
  L_BCD: AnsiString;
begin
  if ModuType <> mtUnknown then
  begin
    L_BCD:= Cardinal2BCD(ValueHz);
    while Length(L_BCD) < 5 do L_BCD:= #0 + L_BCD;
    //如果是多于5个，则取低位，相当于频率值被截尾
    if Length(L_BCD) > 5 then
    begin
      Move(L_BCD[1], L_BCD[Length(L_BCD) - 5 + 1], 5);
      SetLength(L_BCD, 5);
    end;
  end;
  Result:= L_BCD + const_ModuCde[ModuType];
end;

function TJ08Receiver.Internal_ReadFlash(AStream: TMemoryStream): Boolean;
var
  L_Raw: AnsiString;
  L_RawLen: Integer;
  L_Len: WORD;
  L_Verify: Integer;
begin
  Result:= False;

  if (g_RS232 <> NIl) and (AStream <> Nil) then
  begin
    //停止回报,RAW缓冲清空
    if Internal_ReadFlashRawData(L_Raw, 8) then
    begin
      L_Raw:= RightStr(L_Raw, Length(L_Raw) - 3);
      if StrUtils.StartsText('AAAA', L_Raw) then
      begin
        L_Len:= StrToIntDef(String(PAnsiChar(@L_Raw[5])), $0);
        if (L_Len <> $0) and (Internal_ReadFlashRawData(L_Raw, L_Len + 8)) then
        begin
          L_Raw:= RightStr(L_Raw, Length(L_Raw) - 3);
          L_RawLen:= Length(L_Raw);
          if StrUtils.StartsText('AAAA', L_Raw) then
          begin
            L_Verify:= CalcByteSum(L_Raw) - Byte(L_Raw[L_RawLen]); //不对最后一个字节求和

            L_Verify:= L_Verify and $8000000F;
            if L_Verify < 0 then
            begin
              Dec(L_Verify);
              L_Verify:= L_Verify or $FFFFFFF0;
              Inc(L_Verify);
            end
            else
            begin
              Inc(L_Verify, $30);
            end;
            if Byte(L_Raw[L_RawLen]) = Byte(L_Verify) then
            begin
              AStream.Write(L_Raw[9], L_RawLen - 9);
              Result:= True;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TJ08Receiver.Internal_ReadFlashRawData(out AData: AnsiString;
  ASize: WORD): Boolean;
var
  L_Tick: Cardinal;
  L_Cmd: AnsiString;
begin
  Result:= False;
  Internal_SetReportData(False);
  FRaw:= '';
  FWishRawDataCount:= ASize;
  try
    L_Cmd:= #$7B#$07#$10#$02+ AnsiChar(HiByte(ASize)) + AnsiChar(Byte(ASize))+#$7D;
    WriteRawData(PAnsiChar(L_Cmd), 7);
    L_Tick:= GetTickCount;
    while GetTickCount - L_Tick < 5000 do
    begin
      if Length(FRaw) >= ASize then
      begin
        Result:= True;
        AData:= FRaw;
        Break;
      end
      else
      begin
        WaitMS(2);
      end;
    end;
  finally
    FWishRawDataCount:= 0;
    FRaw:= '';
  end;
end;

procedure TJ08Receiver.Internal_CoefficientRead(WishLen: Word; var Value: AnsiString);
var
  L_Len_Data: AnsiString;
  P_Len: PWord;
begin
  SetLength(L_Len_Data, 2);
  P_Len:= @L_Len_Data[1];
  P_Len^:= Length(Value);

  WriteSetCmd(#$10#$02
    + AnsiChar(HiByte(WishLen))
    + AnsiChar(WishLen and $FF));
end;

function TJ08Receiver.Internal_WriteFlash(AStream: TMemoryStream; MaxTryTimes: Integer; TimeOutMs: Integer): Boolean;
const
  const_can_raise: boolean = true;
//  const_end_char: Byte = $36;
var
  L_Len: WORD;
  L_Tick: Cardinal;
  L_ConfigRaw: AnsiString;
  L_Verify: Integer;
begin
  Result:= False;

  if (g_RS232 <> Nil) and (g_RS232.Connected) and (AStream <> Nil) then
  begin
    L_ConfigRaw:= Format('AAAA%-.4d', [AStream.Size + 1]);

    SetLength(L_ConfigRaw, AStream.Size + 8);
    Move(AStream.Memory^, L_ConfigRaw[9], AStream.Size);

    L_Len:= Length(L_ConfigRaw) + 1;

    WriteSetCmd(#$10#$01 + AnsiChar(HiByte(L_Len)) + AnsiChar(Byte(L_Len)));

    _FStoreWriteSucc:= False;
    //加入和校验

    L_Verify:= Integer(CalcByteSum(L_ConfigRaw) and $8000000F);
    if L_Verify < 0 then
    begin
      Dec(L_Verify);
      L_Verify:= L_Verify or $FFFFFFF0;
      Inc(L_Verify);
    end
    else
    begin
      Inc(L_Verify, $30);
    end;

    SetLength(L_ConfigRaw, Length(L_ConfigRaw) + 1);
    L_ConfigRaw[Length(L_ConfigRaw)]:= AnsiChar(Byte(L_Verify));


//    OutputDebugString(PChar(Format('sum = $%x, %d', [L_Byte, L_Byte])));
    while MaxTryTimes > 0 do
    begin
      WriteRawData(PAnsiChar(L_ConfigRaw), Length(L_ConfigRaw));
      L_Tick:= GetTickCount;
      while GetTickCount - L_Tick < TimeOutMs do
      begin
        Application.ProcessMessages;
        if _FStoreWriteSucc then
          Break;
        Sleep(1);
      end;
      if _FStoreWriteSucc then
      begin
        Result:= True;
        Break;
      end;
      Dec(MaxTryTimes);
    end;
    if const_can_raise and Not _FStoreWriteSucc then
      Raise Exception.Create('接收机发送存储的数据无回应: ' + Buf2Hex(L_ConfigRaw));
  end
  else
  begin
    Raise Exception.Create('串口未打开');
  end;
end;



procedure TJ08Receiver.Internal_SetAGCActive(Value: Boolean);
const
  CONST_DATA: Array[False..True] of AnsiChar = (#$00, #$01);
begin
  WriteSetCmd(#$0F + CONST_DATA[Value]);
end;


procedure TJ08Receiver.Internal_SetAMDepthCalcBandWidth(
  Value: TJ08_AMDepthCalcBandWidth);
const
  CONST_BAND_DATA: Array[adbw_15K..adbw_3K] of AnsiChar = (#$00, #$01);
begin
  WriteSetCmd(#$09 + CONST_BAND_DATA[Value]);
end;

procedure TJ08Receiver.Internal_SetAMIFBandWidth(Value: TJ08_AMIFBandWidth);
const
  CONST_BAND_DATA: Array[aibw_4K..aibw_8K] of AnsiChar = (#$01, #$02, #$04);
begin
  WriteSetCmd(#$08 + CONST_BAND_DATA[Value]);
end;

procedure TJ08Receiver.Internal_SetAMThreshold(Amp2Dir, Dir2Att, Att2Dir,
  Dir2Amp: Smallint);
begin
  WriteSetCmd(#$41 + AnsiChar(HiByte(Word(Amp2Dir))) + AnsiChar(Byte(Word(Amp2Dir)))
                   + AnsiChar(HiByte(Word(Dir2Att))) + AnsiChar(Byte(Word(Dir2Att)))
                   + AnsiChar(HiByte(Word(Att2Dir))) + AnsiChar(Byte(Word(Att2Dir)))
                   + AnsiChar(HiByte(Word(Dir2Amp))) + AnsiChar(Byte(Word(Dir2Amp))));
end;

procedure TJ08Receiver.Internal_SetAMVolumn(Value: Byte);
begin
  if Value > $7F then
    Value:= $7F;
  Value:= Value or $80;
  WriteSetCmd(#$0C + AnsiChar(Value));
end;

procedure TJ08Receiver.Internal_SetCarrierBandWidth(
  Value: TJ08_CarrierBandWidth);
const
  CONST_BAND_DATA: Array[cbw_Wide..cbw_Narrow] of AnsiChar = (#$00, #$01, #$02);
begin
  WriteSetCmd(#$0B + CONST_BAND_DATA[Value]);
end;

procedure TJ08Receiver.internal_SetFMDepthCalcTime(Value: WORD);
begin
  WriteSetCmd(#$03 + AnsiChar(HiByte(Value)) + AnsiChar(Value and $FF));
end;

procedure TJ08Receiver.Internal_SetFMScanBenchmark(Value: WORD);
begin
  WriteSetCmd(#$20 + AnsiChar(HiByte(Value)) + AnsiChar(Byte(Value and $FF)));
end;

procedure TJ08Receiver.Internal_SetFMThreshold(Amp2Dir, Dir2Att, Att2Dir,
  Dir2Amp: Smallint);
begin
  WriteSetCmd(#$40 + AnsiChar(HiByte(Word(Amp2Dir))) + AnsiChar(Byte(Word(Amp2Dir)))
                   + AnsiChar(HiByte(Word(Dir2Att))) + AnsiChar(Byte(Word(Dir2Att)))
                   + AnsiChar(HiByte(Word(Att2Dir))) + AnsiChar(Byte(Word(Att2Dir)))
                   + AnsiChar(HiByte(Word(Dir2Amp))) + AnsiChar(Byte(Word(Dir2Amp))));

end;

procedure TJ08Receiver.Internal_SetFrequency(ModuType: TJ08_ModuType;
  ValueHz: Cardinal);
const
  const_ModuCde: Array[mtAM..mtFM] of AnsiChar = (#1, #0);
begin
  if ModuType <> mtUnknown then
    WriteSetCmd(#$01 + internal_MakeFreqData(ModuType, ValueHz));
end;


procedure TJ08Receiver.Internal_SetHiGain(Mode: TJ08_DevAmpMode; Value: TJ08_DevManualMode);
const
  CONST_VALUE_DATA: Array[dmmAmpli..dmmAttent] of AnsiChar = (#$01, #$00, #$02);
  CONST_MODE_DATA: Array[damAuto..damManual] of AnsiChar = (#$00, #$01);
begin
  WriteSetCmd(#$7 + CONST_VALUE_DATA[Value] + CONST_MODE_DATA[Mode]);
end;

procedure TJ08Receiver.internal_SetIFFilerOffset(Value: Smallint);
begin
  WriteSetCmd(#$51
    + AnsiChar(HiByte(Word(Value)))
    + AnsiChar(Byte(Word(Value and $FF)))
  );
end;

procedure TJ08Receiver.Internal_SetReceiverActive(Value: Boolean);
const
  CONST_DATA: Array[False..True] of AnsiChar = (#$00, #$01);
begin
  WriteSetCmd(#$0A + CONST_DATA[Value]);
end;

procedure TJ08Receiver.Internal_SetReportData(Value: Boolean);
const
  Const_Report_Data: Array[False..True] of AnsiChar = (#$0, #$1);
begin
  WriteSetCmd(#$05 + Const_Report_Data[Value]);
end;

procedure TJ08Receiver.Internal_SetScanParam(ModuType: TJ08_ModuType;
  FreqBeginHz: Cardinal; StepKHz: Byte; PointCount, SampleTimePerPointMs: Word;
  IFGain: SmallInt);
var
  L_FreqStr: AnsiString;
  L_PointCountStr: AnsiString;
  L_SampleTimeStr: AnsiString;
  L_GainData: AnsiString;
begin
  {协议数据举例:
  电平范围分2档：0--　-100dBm~-
  例如：起始频率105.7MHz，FM，频率步进100kHz，扫描20个点，每个频点检测时间33ms，中放增益2000
  7b 11 04 01 05 70 00 00 00 64 00 20 00 21 07 d0 7d

  起始频率5.7MHz，AM，频率步进10kHz，扫描20个点，每个频点检测时间33ms，中放增益50
  7b 11 04 00 05 70 00 00 01 0a 00 20 00 21 fd d0 7d

  起始频率0.9MHz，AM，频率步进10kHz，扫描500个点，每个频点检测时间2ms，中放增益50
  7b 11 04 00 00 90 00 00 01 0a 05 00 00 02 fd d0 7d
  }

  //频率及调制
  L_FreqStr:= internal_MakeFreqData(ModuType, FreqBeginHz);
  Assert(Length(L_FreqStr) = 6, '设置扫描参数时频率长度不为6');
  //采样点数
  if PointCount > 9999 then
    L_PointCountStr:= Cardinal2BCD(9999)
  else
    L_PointCountStr:= Cardinal2BCD(PointCount);
  while Length(L_PointCountStr) < 2 do L_PointCountStr:= #0 + L_PointCountStr;
  //每点采样时间
  L_SampleTimeStr:= AnsiChar(HiByte(SampleTimePerPointMs)) + AnsiChar(SampleTimePerPointMs and $FF);
  //中放增益
  L_GainData:= AnsiChar(HiByte(Word(IFGain))) + AnsiChar(Word(IFGain) and $FF);

  TJ08RawParser(FParser).WishScanDataN:=  PointCount;
  WriteSetCmd(#$4
    + L_FreqStr
    + AnsiChar(StepKHz)
    + L_PointCountStr
    + L_SampleTimeStr
    + L_GainData);

end;

procedure TJ08Receiver.Internal_SetSSBGain(Value: WORD);
begin
  if Value > 1290 then
    Value:= 1290;
  WriteSetCmd(#$31
    + AnsiChar(HiByte(Value))
    + AnsiChar(Value and $FF)
    )
end;

procedure TJ08Receiver.internal_SetSSBMode(Value: TJ08_SSBMode);
const
  CONST_DATA: Array[sm_CW..sm_USB] of AnsiChar = (#$00, #$01, #$02);
begin
  Self.WriteSetCmd(#$30 + CONST_DATA[Value]);
end;

procedure TJ08Receiver.Internal_SetTEF6901Volumn(Value: Byte);
begin
  Self.WriteSetCmd(#$02#$14#$01+AnsiChar((Value and $3F) or (Not $3F)));//高两位置为10b
end;

procedure TJ08Receiver.internal_StopScan;
begin
  Self.WriteSetCmd(#$06);
end;

procedure TJ08Receiver.Internal_CoefficientWrite(Value: AnsiString);
var
  L_Len_Data: AnsiString;
  P_Len: PWord;
begin
  SetLength(L_Len_Data, 2);
  P_Len:= @L_Len_Data[1];
  P_Len^:= Length(Value);
  WriteSetCmd(#$10#$01 + L_Len_Data);

  g_RS232.WriteCommData(PAnsiChar(Value), Length(Value));
end;

procedure TJ08Receiver.OnCmdAckHandler;
begin
  _FCmdWriteSucc:= True;
  //OutputDebugString('!!!CMD ACK Received!!!');
end;

procedure TJ08Receiver.OnScanDataHandler(const N: Byte; const AData: AnsiString);
var
  Ptr: PWORD;
  i: Integer;
begin
  {$IFDEF DEBUG}
  OutputDebugString('!!!FM SCAN Report Received!!!');
  {$ENDIF}
  if Length(AData) = (N * 2 + 4) then
  begin
    if (AData[1] = #$7B) and (AData[2] = #$EB) and (AData[3] = #$90) and (AData[Length(AData)] = #$7D) then
    begin
      Ptr:= @AData[4];
      for i := 0 to N - 1 do
      begin
        self.FScanData.RawData[i]:= ntohs(Ptr^);
        Inc(Ptr);
      end;
      _FScanValueHandled:= True;
      if Assigned(self.FOnScanData) then
        FOnScanData(Self);

    end
    else
    begin
      {$IFDEF DEBUG}
      OutputDebugString('解析出的SCAN数据数据格式有错误');
      {$ENDIF}
    end;
  end
  else
  begin
    {$IFDEF DEBUG}
    OutputDebugString('解析出的SCAN数据长度和点数有错误');
    {$ENDIF}
  end;
end;

procedure TJ08Receiver.OnReportHandler(const AData: AnsiString);
var
  i: Integer;
  L_Len: Integer;
  L_PAM: PAMReportRec;
  L_PFM: PFMReportRec;
  L_PFMFreqSpect: PFMFreqSpectRec;
//  L_Temp: Integer;
begin
//  OutputDebugString('!!!Report Received!!!');
  L_Len:= Length(AData);

  case L_Len of
    22:
    begin
      L_PAM:= PAMReportRec(@AData[1]);
      if (L_PAM.FrameStart = $7B) and (L_PAM.FrameLen = 22) and (L_PAM.FrameEnd = $7D) then
      begin
        FModuType:= mtAM;
        self.FAMData.Depth:= ntohs(L_PAM.Depth);
//        self.FAMData.Depth:= (L_PAM.Depth);

        self.FAMData.Level:= ntohs(L_PAM.Level);

//        L_Temp:= ntohl(L_PAM.Freq);
         
        self.FAMData.Frequency:= Integer(ntohl(L_PAM.Freq));
//        self.FAMData.FreqOffset:= ShortInt(Byte(L_Temp and $FF));
        self.FAMData.LevelAmendment[0]:= L_PAM.LevelAmendmentA;
        self.FAMData.LevelAmendment[1]:= L_PAM.LevelAmendmentB;
        
        case L_PAM.GainMode of
          0: FAMData.AmpMode:= damAuto;
          1: FAMData.AmpMode:= damManual;
        else
          FAMData.AmpMode:= damUnkown;
        end;

        if L_PAM.CarrierLocked = 1 then
          FAMData.CarrierLock:= True
        else
          FAMData.CarrierLock:= False;
        if Assigned(FOnAMData)then
          FOnAMData(Self);
      end
      else
      begin
        {$IFDEF DEBUG}
        OutputDebugString('解析出的AM上报数据头长和尾有错误');
        {$ENDIF}
      end;
    end;
    28:
    begin
      L_PFM:= PFMReportRec(@AData[1]);

      if (L_PFM.FrameStart = $7B) and (L_PFM.FrameLen = 28) and (L_PFM.FrameEnd = $7D) then
      begin
        FModuType:= mtFM;
        self.FFMData.Depth:= ntohs(L_PFM.Depth);
        self.FFMData.Unused:= ntohl(L_PFM.Unused);
        self.FFMData.Level:= SmallInt(ntohs(L_PFM.Level));
//        self.FFMData.Level:= SmallInt(L_PFM.Level);
        self.FFMData.LevelAmendment[0]:= L_PFM.LevelAmendmentA;
        self.FFMData.LevelAmendment[1]:= L_PFM.LevelAmendmentB;
        if Assigned(FOnFMData)then
          FOnFMData(Self);
      end
      else
      begin
        {$IFDEF DEBUG}
        OutputDebugString('解析出的FM上报数据头长和尾有错误');
        {$ENDIF}
      end;
    end;
    $CC:
    begin
      L_PFMFreqSpect:= PFMFreqSpectRec(@AData[1]);
      if (L_PFMFreqSpect.FrameStart = $7B) and (L_PFMFreqSpect.FrameLen = $CC) and (L_PFMFreqSpect.FrameEnd = $7D) then
      begin
        FFMFreqSpectData.Clear;
        for i := 0 to Length(L_PFMFreqSpect.FreqSpectData) - 1 do
        begin
          FFMFreqSpectData.Data[i]:= L_PFMFreqSpect.FreqSpectData[i]
        end;
          
        if Assigned(FOnFMFreqSpectData)then
          FOnFMFreqSpectData(Self);
      end
      else
      begin
        {$IFDEF DEBUG}
        OutputDebugString('解析出的FM上报数据头长和尾有错误');
        {$ENDIF}
      end;
    end;
  end;
end;

procedure TJ08Receiver.OnRs232ReceiveHandler(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var
  L_Buf: AnsiString;
begin
    SetLength(L_Buf, BufferLength);
    Move(Buffer^, L_Buf[1], BufferLength);
    if FWishRawDataCount = 0 then
      TJ08RawParser(FParser).Push(L_Buf)
    else
      FRaw:= FRaw + L_Buf;
end;

procedure TJ08Receiver.OnStoreAckHandler;
begin
  _FStoreWriteSucc:= True;
  OutputDebugString('!!!STORE ACK Received!!!');
end;

procedure TJ08Receiver.OpenReceiver;
begin
//  if Not FReceiverTrunedOn then
//    try
//      self.Internal_SetReceiverActive(True);
//      self.FReceiverTrunedOn:= True;
//
//      self.Internal_SetReportData(False);
//      self.Internal_SetFMScanBenchmark(0);
//      //self.Internal_SetReportData(False);
//    except
//    end;

  if Not FReceiverTrunedOn then
    try
      self.Internal_SetReportData(False);
      Internal_SetFMScanBenchmark(26000);
      self.Internal_SetReceiverActive(False);
      self.FReceiverTrunedOn:= True;
    except
    end;
end;


function TJ08Receiver.ReadDepth(out Value: Double;
  const ModuType: TJ08_ModuType): Boolean;
begin
  Result:= False;
  case ModuType of
    mtUnknown:;
    mtAM:
    begin
      Value:= FAMData.Depth;
      Result:= True;
    end;
    mtFM:
    begin
      Value:= FFMData.Depth;
      Result:= True;
    end;
  end;
end;


function TJ08Receiver.ReadFlash(AStream: TMemoryStream): Boolean;
begin
  Result:= Internal_ReadFlash(AStream);
end;

{$IFDEF DEBUG}
function TJ08Receiver.ReadLevel(out Value: Double; const ModuType: TJ08_ModuType; var AHint: AnsiString): Boolean;
begin
  Result:= False;
  case ModuType of
    mtUnknown:;
    mtAM:
    begin
      Value:= FAMData.Level;
      AHint:= FAMData.LevelAvgLog;
      Result:= True;
    end;
    mtFM:
    begin
      Value:= FFMData.Level;
      AHint:= FFMData.LevelAvgLog;
      Result:= True;
    end;
  end;

end;
{$ELSE}
function TJ08Receiver.ReadLevel(out Value: Double; const ModuType: TJ08_ModuType): Boolean;
begin
  Result:= False;
  case ModuType of
    mtUnknown:;
    mtAM:
    begin
      Value:= FAMData.Level;
      Result:= True;
    end;
    mtFM:
    begin
      Value:= FFMData.Level;
      Result:= True;
    end;
  end;
end;
{$ENDIF}

function TJ08Receiver.ReadScanValue(ModuType: TJ08_ModuType; CFHz: Cardinal; StepKHz, PointCount, DetectTimeMS,
  Gain: Cardinal; var ValueList: TCardinalDoubleDynArray; var CFValue: TCardinalDoublePair): Boolean;
var
  L_Tick: Cardinal;
  i: Integer;
  L_FStart: Cardinal;
begin
  Result:= False;

  L_FStart:= CFHz - StepKHz * 1000 * (PointCount div 2) ;
  _FScanValueHandled:= False;
  try
    Internal_SetScanParam(ModuType,
                    L_FStart,
                    StepKHz,
                    PointCount,
                    DetectTimeMS,
                    Gain);

    L_Tick:= GetTickCount;
    while GetTickCount - L_Tick < 2000 do
    begin
      if _FScanValueHandled then
      begin
        if self.FScanData.Count = PointCount then
        begin
          SetLength(ValueList, PointCount);
          for i := 0 to PointCount - 1 do
          begin
            ValueList[i].a:= L_FStart + i * StepKHz * 1000;
            ValueList[i].b:= FScanData.LevelData[i];
          end;
          CFValue:= ValueList[PointCount div 2];
          Result:= True;
          Break;
        end;
      end;
      WaitMS(10);
    end;
  except

  end;
end;


function TJ08Receiver.SetHiGain(const AmpMode: TJ08_DevAmpMode;
  const ManualMode: TJ08_DevManualMode): Boolean;
begin
  Result:= True;
  Internal_SetHiGain(AmpMode, ManualMode);
end;

function TJ08Receiver.SetFrequency(AModual: TJ08_ModuType;
  AFreq: Cardinal): Boolean;
begin
  self.Internal_SetReportData(False);
  self.Internal_SetAMVolumn($40);
  self.Internal_SetFrequency(AModual, AFreq);
  self.Internal_SetReportData(True);
  Result:= True;
end;


procedure TJ08Receiver.set_OnAMData(Value: TNotifyEvent);
begin
  FOnAMData:= Value;
end;

procedure TJ08Receiver.set_OnFMData(Value: TNotifyEvent);
begin
  FOnFMData:= Value;
end;

procedure TJ08Receiver.set_OnFMFreqSpectData(Value: TNotifyEvent);
begin
  FOnFMFreqSpectData:= Value;
end;

procedure TJ08Receiver.set_OnScanData(Value: TNotifyEvent);
begin
  FOnScanData:= Value;
end;


procedure TJ08Receiver.StartPort;
begin
  if (g_RS232 <> Nil) and (Not g_RS232.Connected) then
  begin
    g_RS232.StartComm;
  end;
  //OutputDebugString(PChar(IntToStr(SizeOf(TAMReportRec))));
  //OutputDebugString(PChar(IntToStr(SizeOf(TFMReportRec))));
end;

function TJ08Receiver.WriteFlash(AStream: TMemoryStream; MaxTryTimes,
  TimeOutMs: Integer): Boolean;
begin
  Result:= Internal_WriteFlash(AStream, MaxTryTimes, TimeOutMs);
end;

procedure TJ08Receiver.WriteRawData(APtr: Pointer; ALen: Cardinal);
begin
 {$IFNDEF EMU}
  g_RS232.WriteCommData(APtr, ALen);
  {$ENDIF}
end;

procedure TJ08Receiver.WriteSetCmd(CmdStr: AnsiString; MaxTryTimes: Integer; TimeOutMs: Cardinal);
const
  const_can_raise: boolean = true;
var
  L_Len: Byte;
  L_Tick: Cardinal;
begin
  {$IFNDEF Debug_Emu}
  if g_RS232.Connected then
  begin
    L_Len:= Byte(Length(CmdStr) + 3);
    CmdStr:= #$7B + AnsiChar(L_Len) + CmdStr + #$7D;

    _FCmdWriteSucc:= False;
    while MaxTryTimes > 0 do
    begin
      WriteRawData(PAnsiChar(CmdStr), L_Len);
      L_Tick:= GetTickCount;
      while GetTickCount - L_Tick < TimeOutMs do
      begin
        Application.ProcessMessages;
        if _FCmdWriteSucc then
          Break;
        Sleep(1);
      end;
      if _FCmdWriteSucc then
        Break;
      Dec(MaxTryTimes);
    end;
    if const_can_raise and Not _FCmdWriteSucc then
      Raise Exception.Create('接收机发送命令无回应: ' + Buf2Hex(CmdStr));
  end
  else
  begin
    Raise Exception.Create('串口未打开');
  end;
  {$ENDIF}
end;

{ TUartCommCtrl1.TAMData }

constructor TJ08Receiver.TAMData.Create;
begin
  FDepth:= TTickIntAverager.Create(1000, 200);
  FLevel:= TTickIntAverager.Create(1000, 200);
end;

destructor TJ08Receiver.TAMData.Destroy;
//var
//  i: Integer;
begin
  FLevel.Free;
//  FFreqOffset.Free;
//  FFrequency.Free;
//  for i := 0 to Length(FLevelAmendment) - 1 do
//    FreeAndNil(FLevelAmendment[i]);
  FDepth.Free;
  inherited;
end;

function TJ08Receiver.TAMData.get_AmpMode: TJ08_DevAmpMode;
begin
  Result:= FAmpMode;
end;

function TJ08Receiver.TAMData.get_CarrierLock: Boolean;
begin
  Result:= FCarrierLock;
end;

function TJ08Receiver.TAMData.get_Depth: Integer;
begin
  Result:= FDepth.AvgValue;
end;

function TJ08Receiver.TAMData.get_DevManualMode: TJ08_DevManualMode;
begin
  Result:= dmmUnknown;
  if Length(FLevelAmendment) >= 2 then
  begin
    if (FLevelAmendment[0] = 1) and (FLevelAmendment[1] = 0) then
      Result:=  dmmDirect
    else if (FLevelAmendment[0] = 0) and (FLevelAmendment[1] = 1) then
      Result:=  dmmAttent
    else  if (FLevelAmendment[0] = 0) and (FLevelAmendment[1] = 0) then
      Result:=  dmmAmpli
  end
end;

//function TUartCommCtrl1.TAMData.get_FreqOffset: shortInt;
//begin
//  Result:= FFreqOffset.AvgValue;
//  result:= FFreqOffset;
//end;

function TJ08Receiver.TAMData.get_Frequency: Integer;
begin
//  Result:= FFrequency.AvgValue;
  Result:= FFrequency;
end;

function TJ08Receiver.TAMData.get_Level: Smallint;
begin
  Result:= FLevel.AvgValue;
end;



function TJ08Receiver.TAMData.get_LevelAmendment(Index: Integer): Byte;
begin
  Result:= Self.FLevelAmendment[INdex]
end;

{$IFDEF DEBUG}
function TJ08Receiver.TAMData.get_LevelAvgLog: AnsiString;
begin
  Result:= FLevel.LastAvgLog;
end;
{$ENDIF}

procedure TJ08Receiver.TAMData.set_AmpMode(Value: TJ08_DevAmpMode);
begin
  FAmpMode:= Value;
end;

procedure TJ08Receiver.TAMData.set_CarrierLock(Value: Boolean);
begin
  FCarrierLock:= Value;
end;

procedure TJ08Receiver.TAMData.set_Depth(Value: Integer);
begin
  FDepth.PushValue(Value);
end;

//procedure TUartCommCtrl1.TAMData.set_FreqOffset(Value: shortInt);
//begin
//  FFreqOffset.PushValue(Value);
//  FFreqOffset:= Value;
//end;

procedure TJ08Receiver.TAMData.set_Frequency(Value: Integer);
begin
//  FFrequency.PushValue(Value);
  FFrequency:= Value;
end;

procedure TJ08Receiver.TAMData.set_Level(Value: Smallint);
begin
  FLevel.PushValue(Value);
//  OutputDebugString(PChar('AM Level Push: ' + IntToStr(Value)));
end;

procedure TJ08Receiver.TAMData.set_LevelAmendment(Index: Integer; Value: Byte);
begin
  if Index >= Length(FLevelAmendment) then
    SetLength(FLevelAmendment, Index + 1);



  FLevelAmendment[Index]:= Value;
end;


{ TUartCommCtrl1.TFMData }

constructor TJ08Receiver.TFMData.Create;
begin
  inherited Create;
  FDepth:= TTickIntAverager.Create(1500, 250);
  FUnused:= TTickIntAverager.Create(1500, 250);
  FLevel:= TTickIntAverager.Create(1500, 250);
end;

destructor TJ08Receiver.TFMData.Destroy;
//var
//  i: Integer;
begin
  FLevel.Free;
  FUnused.Free;
//  for i := 0 to Length(FLevelAmendment) - 1 do
//    FreeAndNil(FLevelAmendment[i]);
  FDepth.Free;

  inherited;
end;

function TJ08Receiver.TFMData.get_Depth: Integer;
begin
  Result:= FDepth.AvgValue;
end;

function TJ08Receiver.TFMData.get_DevManualMode: TJ08_DevManualMode;
begin
  Result:= dmmUnknown;
  if Length(FLevelAmendment) >= 2 then
  begin
    if (FLevelAmendment[0] = 1) and (FLevelAmendment[1] = 0) then
      Result:=  dmmDirect
    else if (FLevelAmendment[0] = 0) and (FLevelAmendment[1] = 1) then
      Result:=  dmmAttent
    else  if (FLevelAmendment[0] = 0) and (FLevelAmendment[1] = 0) then
      Result:=  dmmAmpli
  end
end;

function TJ08Receiver.TFMData.get_Unused: Integer;
begin
  Result:= FUnused.AvgValue;
end;

function TJ08Receiver.TFMData.get_Level: Integer;
begin
  Result:= FLevel.AvgValue;
end;

function TJ08Receiver.TFMData.get_LevelAmendment(Index: Integer): Byte;
begin
  Result:= FLevelAmendment[Index];
end;

{$IFDEF DEBUG}
function TJ08Receiver.TFMData.get_LevelAvgLog: AnsiString;
begin
  Result:= FLevel.LastAvgLog;
end;
{$ENDIF}

procedure TJ08Receiver.TFMData.set_Depth(Value: Integer);
begin
  FDepth.PushValue(Value);
end;

procedure TJ08Receiver.TFMData.set_Unused(Value: Integer);
begin
  FUnused.PushValue(Value);
end;

procedure TJ08Receiver.TFMData.set_Level(Value: Integer);
begin
  Self.FLevel.PushValue(Value);
end;

procedure TJ08Receiver.TFMData.set_LevelAmendment(Index: Integer; Value: Byte);
begin
  if Index >= Length(FLevelAmendment) then
    SetLength(FLevelAmendment, Index + 1);

  FLevelAmendment[Index]:= Value;
end;


{ TUartCommCtrl1.TScanData }

procedure TJ08Receiver.TScanData.Clear;
begin
  SetLength(FData, 0);
end;

constructor TJ08Receiver.TScanData.Create;
begin
  inherited;

end;

destructor TJ08Receiver.TScanData.Destroy;
//var
//  i: Integer;
begin
//  for i := 0 to Length(FData) - 1 do
//    FreeAndNil(FData[i]);
  inherited;
end;

function TJ08Receiver.TScanData.get_Count: Integer;
begin
  Result:= Length(self.FData);
end;

function TJ08Receiver.TScanData.get_LevelData(Index: Integer): WORD;
begin
  Result:= FData[Index] and $0FFF;
end;

function TJ08Receiver.TScanData.get_RawData(Index: Integer): WORD;
begin
  Result:= FData[Index];
//  if Index < Length(FData) then
//    if FData[Index] <> Nil then
//      Result:= FData[Index].AvgValue;
end;

procedure TJ08Receiver.TScanData.set_RawData(Index: Integer; Value: WORD);
begin
  if Index >= Length(FData) then
    SetLength(FData, Index + 1);
  FData[Index]:= Value;
end;

{ TUartCommCtrl1.TRawParser }


procedure TJ08Receiver.TJ08RawParser.DoParse2(var ABuf: AnsiString;
  const ACtrl: TJ08Receiver; var MatchCode: Byte);
begin
  //place holder
end;

procedure TJ08Receiver.TJ08RawParser.DoParser(var ABuf: AnsiString; const ACtrl: TJ08Receiver);
const
  CONST_MATCH_FAILD: Byte = 0;
  CONST_MATCH_SUCC: Byte = 1;
  CONST_MATCH_NOTENOUGH: Byte = 2;
    {$REGION '匹配固定内容数据'}
    function TryMatch(const ASubStr: AnsiString; const AStartPos: Integer;
                         var AData,  AFragment: AnsiString): Byte; Overload;
    var
      L_FragLen: integer;
    begin
      Result:= CONST_MATCH_FAILD;
      if Length(ABuf) >= Length(ASubStr) + AStartPos - 1 then
      begin
        if PosEx(ASubStr, ABuf, AStartPos) = 1 then
        begin
          //第一个头有配对的尾
          AData:= ASubStr;
          //有数据碎片则保存
          if AStartPos > 1 then
          begin
            L_FragLen:= AStartPos - 1;
            SetLength(AFragment, L_FragLen);
            Move(ABuf[1], AFragment[1], L_FragLen);
          end;
          //已经解析的数据从缓冲中弹出
          PopBuf(Length(ASubStr), ABuf);
          Result:= CONST_MATCH_SUCC;
        end
        else
        begin
          Result:=  CONST_MATCH_FAILD;
        end;
      end
      else
      begin
        Result:= CONST_MATCH_NOTENOUGH;
      end;


    end;
    {$ENDREGION}

    {$REGION '匹配定长数据(上报数据)'}
    function TryMatch(const ALen: Integer; const AStartPos: Integer;
                         var AData,  AFragment: AnsiString): Byte; Overload;
    var
      L_FragLen: Integer;
    begin
      Result:= CONST_MATCH_FAILD;
      if Byte(ABuf[2]) = ALen then
      begin
        if Length(ABuf) >= ALen + AStartPos - 1 then
        begin//数据长度足够
          if ABuf[AStartPos + ALen - 1] = #$7D then //正确的尾
          begin
            //保存帧数据
            SetLength(AData, ALen);
            Move(ABuf[AStartPos], AData[1], ALen);
            //有数据碎片则保存
            if AStartPos > 1 then
            begin
              L_FragLen:= AStartPos - 1;
              SetLength(AFragment, L_FragLen);
              Move(ABuf[1], AFragment[1], L_FragLen);
            end;
            //已经解析的数据从缓冲中弹出
            PopBuf(ALen , ABuf);
            Result:= CONST_MATCH_SUCC;
          end
          else
          begin
            Result:=  CONST_MATCH_FAILD;
          end;
        end
        else
        begin
          Result:= CONST_MATCH_NOTENOUGH;
        end;
      end;
    end;
    {$ENDREGION}

   {$REGION '匹配标志并定长数据(上报数据)'}
    function TryMatchNoCheckLen(const ALen: Integer; const AStartPos: Integer;
                         var AData,  AFragment: AnsiString): Byte;
    var
      L_FragLen: Integer;
    begin
      Result:= CONST_MATCH_FAILD;
      if Length(ABuf) >= ALen + AStartPos - 1 then
      begin//数据长度足够
        if ABuf[AStartPos + ALen - 1] = #$7D then //正确的尾
        begin
          //保存帧数据
          SetLength(AData, ALen);
          Move(ABuf[AStartPos], AData[1], ALen);
          //有数据碎片则保存
          if AStartPos > 1 then
          begin
            L_FragLen:= AStartPos - 1;
            SetLength(AFragment, L_FragLen);
            Move(ABuf[1], AFragment[1], L_FragLen);
          end;
          //已经解析的数据从缓冲中弹出
          PopBuf(ALen , ABuf);
          Result:= CONST_MATCH_SUCC;
        end
        else
        begin
          Result:=  CONST_MATCH_FAILD;
        end;
      end
      else
      begin
        Result:= CONST_MATCH_NOTENOUGH;
      end;
    end;
    {$ENDREGION}
const
  CONST_ACK_CMD: AnsiString = #$7B#$33#$7D;
  CONST_ACK_STORE: AnsiString = #$7B#$AA#$7D;
var
  L_PosA: Integer;
  L_MatchCode: Byte;
  L_Data, L_Fragment: AnsiString;
begin
  repeat
    L_MatchCode:= CONST_MATCH_FAILD;

    L_PosA:= Pos(#$7B, ABuf);
    if L_PosA > 0 then
    begin
      if Length(ABuf) >= L_PosA - 1 + 3 then
      begin
        {$REGION '试解析命令ACK'}
        L_MatchCode:= TryMatch(CONST_ACK_CMD, L_PosA, L_Data, L_Fragment);
        if L_MatchCode = CONST_MATCH_SUCC then
        begin
          if Assigned(ACtrl) then
            TJ08Receiver(ACtrl).OnCmdAckHandler;
          {$IFDEF DEBUG}
          //OutputDebugString('!!!CMD ACK Report Received!!!');
          {$ENDIF}

          Continue;
        end
        else if L_MatchCode = CONST_MATCH_NOTENOUGH then
        begin
          Break;
        end;
        {$ENDREGION}

        {$REGION '试解析存储命令ACK'}
        L_MatchCode:= TryMatch(CONST_ACK_STORE, L_PosA, L_Data, L_Fragment);
        if L_MatchCode = CONST_MATCH_SUCC then
        begin
          if Assigned(ACtrl) then
            TJ08Receiver(ACtrl).OnStoreAckHandler;
          {$IFDEF DEBUG}
          OutputDebugString('!!!Store ACK Report Received!!!');
          {$ENDIF}
          Continue;
        end
        else if L_MatchCode = CONST_MATCH_NOTENOUGH then
        begin
          Break;
        end;
        {$ENDREGION}

        {$REGION '试解析AM上报'}
        L_MatchCode:= TryMatch(19 + 3, L_PosA, L_Data, L_Fragment);
        if L_MatchCode = CONST_MATCH_SUCC then
        begin
          if byte(L_Data[2]) = 19 + 3 then
          begin
            if Assigned(ACtrl) then
              TJ08Receiver(ACtrl).OnReportHandler(L_Data);
            {$IFDEF DEBUG}         
//            OutputDebugString('!!!AM Report Received!!!');
            {$ENDIF}
          end
          else
          begin
            OutputDebugString('!!!解析到上AM报数据，但是长度不正确!!!');
          end;
          Continue;
        end
        else if L_MatchCode = CONST_MATCH_NOTENOUGH then
        begin
          Break;
        end;
        {$ENDREGION}

        {$REGION '试解析FM上报'}
        L_MatchCode:= TryMatch(25 + 3, L_PosA, L_Data, L_Fragment);
        if L_MatchCode = CONST_MATCH_SUCC then
        begin
          if byte(L_Data[2]) = 25 + 3 then
          begin
            if Assigned(ACtrl) then
              TJ08Receiver(ACtrl).OnReportHandler(L_Data);
            {$IFDEF DEBUG}
//            OutputDebugString('!!!FM Report Received!!!');
            {$ENDIF}
          end
          else
          begin
            //OutputDebugString('!!!解析到FM上报数据，但是长度不正确!!!');
          end;
          Continue;
        end
        else if L_MatchCode = CONST_MATCH_NOTENOUGH then
        begin
          Break;
        end;
        {$ENDREGION}

        {$REGION '试解析FM频谱(金耳朵？)'}
        L_MatchCode:= TryMatch($CC, L_PosA, L_Data, L_Fragment);
        if L_MatchCode = CONST_MATCH_SUCC then
        begin
          if byte(L_Data[2]) = $CC then
          begin
            if Assigned(ACtrl) then
              TJ08Receiver(ACtrl).OnReportHandler(L_Data);
            {$IFDEF DEBUG}         
            //OutputDebugString('!!!FM FreqSpect Received!!!');
            {$ENDIF}
          end
          else
          begin
            OutputDebugString('!!!解析到FM上报数据，但是长度不正确!!!');
          end;
          Continue;
        end
        else if L_MatchCode = CONST_MATCH_NOTENOUGH then
        begin
          Break;
        end;
        {$ENDREGION}

        {$REGION '如果需要解析扫频，则试解析扫描数据'}
        if FWishScanDataN > 0 then
        begin
          L_MatchCode:= TryMatchNoCheckLen(FWishScanDataN * 2 + 4, L_PosA, L_Data, L_Fragment);
          if L_MatchCode = CONST_MATCH_SUCC then
          begin
            if (L_Data[2] = #$EB) and (L_Data[3] = #$90) then
            begin
              if Assigned(ACtrl) then
                TJ08Receiver(ACtrl).OnScanDataHandler(FWishScanDataN, L_Data);
              {$IFDEF DEBUG}
              OutputDebugString('!!!Scan Report Received!!!');
              {$ENDIF}
            end
            else
            begin
              OutputDebugString('!!!解析到扫描数据，但是格式不正确!!!');
            end;
            Continue;
          end
          else if L_MatchCode = CONST_MATCH_NOTENOUGH then
          begin
            Break;
          end;
        end;
        {$ENDREGION}

        DoParse2(ABuf, ACtrl, L_MatchCode);

        if L_MatchCode = CONST_MATCH_FAILD then
        begin
          PopBuf(1, ABuf);
          if Pos(#$7B, ABuf) > 0 then
          begin
            L_MatchCode:= CONST_MATCH_SUCC
          end;
        end;
      end
      else
      begin
        Break;
      end;
    end
    else
    begin
      Break;
    end;
  until (L_MatchCode <> CONST_MATCH_SUCC);
end;



{ TUartCommCtrl1.TFMFreqSpectData }

procedure TJ08Receiver.TFMFreqSpectData.Clear;
begin
  SetLength(FData, 0)
end;

function TJ08Receiver.TFMFreqSpectData.get_Count: Byte;
begin
  Result:= length(FData);
end;

function TJ08Receiver.TFMFreqSpectData.get_Data(Index: Byte): Byte;
begin
  Result:= 0;
  if Index < Length(FData) then
    Result:= FData[Index];
end;

procedure TJ08Receiver.TFMFreqSpectData.set_Data(Index, Value: Byte);
begin
  if Index >= Length(FData) then
    SetLength(FData, Index + 1);

  FData[Index]:= Value;
end;



{ TRawParser }

constructor TRawParser.Create(ACtrl: TJ08Receiver);
begin
  inherited Create;
  FCtrl:= ACtrl;
end;




class function TRawParser.PopBuf(const ALen: Cardinal;
  var AData: AnsiString): Boolean;
var
  L_NewLen: Integer;
begin
  Result:= False;
  if Length(AData) >= ALen then
  begin
    L_NewLen:= Length(AData) - ALen;
    Move(AData[ALen + 1], AData[1], L_NewLen);
    SetLength(AData, L_NewLen);
    Result:= True;
  end;
end;

procedure TRawParser.Push(const Raw: AnsiString);
begin
  if Raw <> '' then
  begin
    FInBuf:= FInBuf + Raw;
    DoParser(FInBuf, FCtrl);
  end;
end;

end.
