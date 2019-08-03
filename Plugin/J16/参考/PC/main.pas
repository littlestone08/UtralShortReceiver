unit main;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, StdCtrls, ActnList, ExtCtrls, PlumLogFile, vsComPort, vsComPortBase,
   LazFileUtils, PlumUtils, LCLType, ToolWin;

type
    PSetCoffPackate = ^TSetCoffPackate;

    { TSetCoffPackate }
    TCoffs = Array[0..2, 0..1] of Single;

    TSetCoffPackate = packed Record
      SOF: Byte;
      LEN: Byte;
      Cmd: Byte;
      AM_FM: Byte;
      Coffs: TCoffs;
      EOF: Byte;
      Procedure Fill(AM_FMSel: Byte; V0_A, V0_B, V1_A, V1_B, V2_A, V2_B: Single);
      function ToString: AnsiString;
    end;

    { TCoffReport }

    TCoffReport = packed Record
      SOF: Byte;
      LEN: Byte;
      Cmd: Byte;
      Applied: Byte;
      Valid: Byte;
      AMCoff: TCoffs;
      FMCoff: TCoffs;
      EOF: Byte;
      Procedure FromString(const Raw: String);
      function ToString: AnsiString;
    end;


  { TfrmUart }

  TfrmUart = class(TForm)
    actClose: TAction;
    actRefresh: TAction;
    actSetupSerial: TAction;
    actOpen: TAction;
    ActionList1: TActionList;
    Bevel1: TBevel;
    Bevel2: TBevel;
    btnAMCoffSet: TButton;
    btnAMCoffSet1: TButton;
    btnSetReportSel: TButton;
    btnSetCoffValid: TButton;
    Button1: TButton;
    Button2: TButton;
    btnWriteE2PROM: TButton;
    cbbComPort: TComboBox;
    AM0_A: TEdit;
    FM1_B: TEdit;
    FM2_A: TEdit;
    FM2_B: TEdit;
    AM0_B: TEdit;
    AM1_A: TEdit;
    AM1_B: TEdit;
    AM2_A: TEdit;
    AM2_B: TEdit;
    FM0_A: TEdit;
    FM0_B: TEdit;
    FM1_A: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lbCoffApplied: TLabel;
    lbCoffValid: TLabel;
    lb_AM0_A: TLabel;
    lb_AM0_B: TLabel;
    lb_FM0_B: TLabel;
    lb_FM1_B: TLabel;
    lb_AM1_A: TLabel;
    lb_AM1_B: TLabel;
    lb_AM2_A: TLabel;
    lb_AM2_B: TLabel;
    lb_FM2_B: TLabel;
    lb_FM2_A: TLabel;
    lb_FM1_A: TLabel;
    lb_FM0_A: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    rgReportSel: TRadioGroup;
    rgCoffValid: TRadioGroup;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure actCloseExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSerialUpdateInfo(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure btnCoffSetClick(Sender: TObject);
    procedure btnWriteE2PROMClick(Sender: TObject);
    procedure btnSetCoffValidClick(Sender: TObject);
    procedure btnSetReportSelClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
    procedure actSetupSerialExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure rbgSubAttensClick(Sender: TObject);
    procedure vsComPort1RxData(Sender: TObject);
  private
    procedure ProcessLevelCoffStatus(const Raw: String);
  private
    { private declarations }
    FBuf: AnsiString;
    FDataInCount: Int64;
    FLog: ILogFile;
    FLogErr: ILogFile;
    Procedure FloatValue2Edits(const Values: Array of Single);
    Procedure FloatValue2Labels(const Values: Array of Single);
    Procedure UI2FloatValue(var Values: Array of Single);
    procedure update_statusbar();
    Procedure ProcessData();
    Procedure DebugText(value: string);
    Procedure DoProcessFrame(const Value: TSetCoffPackate);
  public
    { public declarations }
  end;


var
  frmUart: TfrmUart;

implementation
uses
  //Windows,
  DateUtils, LazLogger, synaser, strUtils, LazUTF8; //MultiLog;

{$R *.dfm}

Procedure ReverseCoffsByteOrder(var Coffs: TCoffs);
var
  i: Integer;
  Ptr: PDWord;
  Temp: DWORD;
begin
  Ptr:= @Coffs;
  for i:= 0 to (SizeOf(Coffs) div SizeOf(Single)) - 1 do
  begin
    Temp:= ((PByte(Ptr) + 0)^ shl 24 ) or ((PByte(Ptr) + 1)^ shl 16) or
    ((PByte(Ptr) + 2)^ shl 8 ) or ((PByte(Ptr) + 3)^ shl 0);
    DebugLn(Format('%8x %8x', [Ptr^, Temp]));
    Ptr^:= Temp;
    Inc(Ptr);
  end;
end;

{ TfrmUart }
procedure update_serial_port(AComboBox: TComboBox);
var
  sList: TStringList;
begin

  sList:= TStringList.Create;
  try
    sList.Delimiter:= ',';
    sList.DelimitedText:= GetSerialPortNames();
    AComboBox.Items.Assign(sList);
    if AComboBox.Items.Count > 0 then
      AComboBox.ItemIndex:= 0;
  finally
    sList.Free;
  end;
end;

{ TCoffReport }

procedure TCoffReport.FromString(const Raw: String);
begin
  Move(PChar(Raw)^, Self, SizeOf(Self));
end;

function TCoffReport.ToString: AnsiString;
begin
  SetLength(Result, SizeOf(Self));
  Move(Pointer(@Self.SOF)^, PAnsiChar(Result)^, SizeOf(Self));
end;

{ TSetCoffPackate }

procedure TSetCoffPackate.Fill(AM_FMSel: Byte; V0_A, V0_B, V1_A, V1_B, V2_A, V2_B: Single);
begin
  self.SOF:= $7B;
  self.LEN:= SizeOf(Self);
  self.Cmd:= $55;
  self.AM_FM:= AM_FMSel;
  self.Coffs[0, 0]:= V0_A;
  self.Coffs[0, 1]:= V0_B;
  self.Coffs[1, 0]:= V1_A;
  self.Coffs[1, 1]:= V1_B;
  self.Coffs[2, 0]:= V2_A;
  self.Coffs[2, 1]:= V2_B;
  self.EOF:= $7D;
end;



function TSetCoffPackate.ToString: AnsiString;
begin
  SetLength(Result, SizeOf(Self));
  Move(Pointer(@Self.SOF)^, PAnsiChar(Result)^, SizeOf(Self));
end;


procedure TfrmUart.FormCreate(Sender: TObject);
var
  LoggerFile: TLazLoggerFile;
  x: TSetCoffPackate;
  s1: String;
  s2: AnsiString;
  s3: UTF8String;
  s4: string;
begin
  {
  s1:= '中a人';
  s2:= '中a人';
  s3:= SysToUTF8('中a人');

  Debugln(Format('%d, %d, %d, %d', [Length('中a人'), UTF8Length(s1), Length(s2), Length(s3)]));
  s4:= LazUTF8.UTF8Copy(s3, 3, 1);
  caption:= s4;
  DebugLn(s4);
  }
  //Debugln(UTF8ToConsole(LazUTF8.UTF8Copy(s3, 0, 1)));;
  {
  Debugln(MidStr(s1, 4, 1));

  Debugln(Format('%d, %s, %s, %s', [Length(s1), s1[2], s1[3], s1[4]]));
  Debugln(Format('%d', [Length(BytesOf(s1))]));
  Debugln(Format('%d', [Length(s2)]));
  Debugln(Format('%d', [Length(BytesOf(s2))]));}
  FloatValue2Edits([-12.5, 0, -0, 1, -1 , 2, -2, 3, -3, 4, -4, -12.5]);
  LoggerFile:= TLazLoggerFile.Create();
  LoggerFile.UseStdOut:= True;
  DebugLogger:= LoggerFile;

  //DebugLogger.DbgOut('test');
  {$IFDEF USED_BY_LAZLOGGER}
  DbgStr('123');
  {$ENDIF}
  vsComPort1.BaudRate:= br_19200;
  update_serial_port(cbbComPort);
  if cbbComPort.Items.Count > 0 then
  begin
    cbbComPort.ItemIndex:= 0;
  end;
  SetDebugLogger(TLazLoggerFile.Create());
end;


procedure TfrmUart.rbgSubAttensClick(Sender: TObject);
var
    s: TBytesStream;
begin

end;



procedure TfrmUart.actSetupSerialExecute(Sender: TObject);
begin
  self.vsComPort1.ShowSetupDialog;
end;

procedure TfrmUart.actSerialUpdateInfo(Sender: TObject);
begin
  actOpen.Enabled:= Not vsComPort1.Active;
  actSetupSerial.Enabled:= Not vsComPort1.Active;

  actClose.Enabled:= vsComPort1.Active;
  update_statusbar();
end;

procedure TfrmUart.actOpenExecute(Sender: TObject);
begin
  if cbbComPort.ItemIndex >= 0 then
  begin
    vsComPort1.Device:= cbbComPort.Text;
    vsComPort1.Open;
  end;

  ForceDirectory(ExtractFilePath(ParamStr(0)) + 'LOG\');
  FLog:= IntfCreateLogFile(ExtractFilePath(ParamStr(0)) + 'LOG\' + FormatDateTime('YYYYMMDDHHNNSS', Now) +'.Log');
  FLogErr:= IntfCreateLogFile(ExtractFilePath(ParamStr(0)) + 'LOG\' + FormatDateTime('YYYYMMDDHHNNSS', Now) +'_Error.Log');
end;

procedure TfrmUart.actCloseExecute(Sender: TObject);
begin
    vsComPort1.Close;
    FLogErr:= Nil;
    FLog:= Nil;
    FDataInCount:= 0;
end;

procedure TfrmUart.actRefreshExecute(Sender: TObject);
begin
  update_serial_port(cbbComPort);
end;



procedure TfrmUart.btnCoffSetClick(Sender: TObject);
var
  L_Packate: TSetCoffPackate;
  Values: Array of Single;
  L_Buf: AnsiString;
begin
  SetLength(Values, 12);
  self.UI2FloatValue(Values);
  if sender = btnAMCoffSet then
    L_Packate.Fill(0, Values[0], Values[1], Values[2], Values[3], Values[4], Values[5])
  else
    L_Packate.Fill(1, Values[6], Values[7], Values[8], Values[9], Values[10], Values[11]);

  ReverseCoffsByteOrder(L_Packate.Coffs);
  L_Buf:= L_Packate.ToString;
  Self.vsComPort1.WriteData(L_Buf);
  DebugText('写入串口：' + PlumUtils.Buf2Hex(AnsiLeftStr(L_Buf, Length(L_Buf))));
end;

procedure TfrmUart.btnWriteE2PROMClick(Sender: TObject);
const
  L_Cmd: String = #$7B#$04#$57#$7D;
begin
  vsComPort1.WriteData(L_Cmd);
end;

procedure TfrmUart.btnSetCoffValidClick(Sender: TObject);
const
  L_Cmds: Array[0..1] of String = (#$7B#$05#$54#$00#$7D, #$7B#$05#$54#$01#$7D);
begin
  vsComPort1.WriteData(L_Cmds[rgCoffValid.ItemIndex])
end;

procedure TfrmUart.btnSetReportSelClick(Sender: TObject);
const
  L_Cmds: Array[0..1] of String = (#$7B#$05#$53#$00#$7D, #$7B#$05#$53#$01#$7D);
begin
  vsComPort1.WriteData(L_Cmds[self.rgReportSel.ItemIndex]);
end;

procedure TfrmUart.Button2Click(Sender: TObject);
begin
  vsComPort1.WriteData(#$7B#$04#$56#$7D);
end;

procedure TfrmUart.Memo1DblClick(Sender: TObject);
begin
  if Dialogs.MessageDlg('是否要清空记录?', mtConfirmation, mbYesNo, 0) = mrYes then
    Memo1.Lines.Clear;
end;



procedure TfrmUart.vsComPort1RxData(Sender: TObject);
var
  L_Data: AnsiString;
begin
  if vsComPort1.DataAvailable then
  begin
    L_Data:= vsComPort1.ReadData;
    Write(PlumUtils.Buf2Hex(L_Data));
    Write(' ');
    FDataInCount:= FDataInCount + Length(L_Data);
    FBuf:= FBuf + L_Data;
    self.StatusBar1.Panels[1].Text:= IntToStr(FDataInCount);
    ProcessData();
  end;
end;

procedure TfrmUart.ProcessLevelCoffStatus(const Raw: String);
var
  L_Frame: TCoffReport;
begin
  L_Frame.FromString(Raw);
  self.DebugText(PlumUtils.Buf2Hex(L_Frame.ToString));
  lbCoffApplied.Caption:= IntToStr(L_frame.Applied);
  lbCoffValid.Caption:= IntToStr(L_Frame.Valid);
  ReverseCoffsByteOrder(L_Frame.AMCoff);
  ReverseCoffsByteOrder(L_Frame.FMCoff);
  FloatValue2Labels([
    L_Frame.AmCoff[0][0], L_Frame.AmCoff[0][1],
    L_Frame.AmCoff[1][0], L_Frame.AmCoff[1][1],
    L_Frame.AmCoff[2][0], L_Frame.AmCoff[2][1],
    L_Frame.FmCoff[0][0], L_Frame.FmCoff[0][1],
    L_Frame.FmCoff[1][0], L_Frame.FmCoff[1][1],
    L_Frame.FmCoff[2][0], L_Frame.FmCoff[2][1]]);

end;

procedure TfrmUart.FloatValue2Edits(const Values: array of Single);
begin
  //FloatToStrF(Argument,ffexponent,Precision,3)

  AM0_A.Text:= Format('%.7E', [Values[0]]);
  AM0_B.Text:= Format('%.7E', [Values[1]]);
  AM1_A.Text:= Format('%.7E', [Values[2]]);
  AM1_B.Text:= Format('%.7E', [Values[3]]);
  AM2_A.Text:= Format('%.7E', [Values[4]]);
  AM2_B.Text:= Format('%.7E', [Values[5]]);

  FM0_A.Text:= Format('%.7E', [Values[6]]);
  FM0_B.Text:= Format('%.7E', [Values[7]]);
  FM1_A.Text:= Format('%.7E', [Values[8]]);
  FM1_B.Text:= Format('%.7E', [Values[9]]);
  FM2_A.Text:= Format('%.7E', [Values[10]]);
  FM2_B.Text:= Format('%.7E', [Values[11]]);
end;

procedure TfrmUart.FloatValue2Labels(const Values: array of Single);
begin
  lb_AM0_A.Caption:= Format('%.7E', [Values[0]]);
  lb_AM0_B.Caption:= Format('%.7E', [Values[1]]);
  lb_AM1_A.Caption:= Format('%.7E', [Values[2]]);
  lb_AM1_B.Caption:= Format('%.7E', [Values[3]]);
  lb_AM2_A.Caption:= Format('%.7E', [Values[4]]);
  lb_AM2_B.Caption:= Format('%.7E', [Values[5]]);

  lb_FM0_A.Caption:= Format('%.7E', [Values[6]]);
  lb_FM0_B.Caption:= Format('%.7E', [Values[7]]);
  lb_FM1_A.Caption:= Format('%.7E', [Values[8]]);
  lb_FM1_B.Caption:= Format('%.7E', [Values[9]]);
  lb_FM2_A.Caption:= Format('%.7E', [Values[10]]);
  lb_FM2_B.Caption:= Format('%.7E', [Values[11]]);

end;

procedure TfrmUart.UI2FloatValue(var Values: array of Single);
begin
  //SetLength(Values, 12);
  DebugLn();
  Values[0]:= StrToFloat(AM0_A.Text);
  DebugLn(Format('%s, %f', [AM0_A.Text, Values[0]]));
  Values[1]:= StrToFloat(AM0_B.Text);
  DebugLn(Format('%s, %f', [AM0_B.Text, Values[1]]));

  Values[2]:= StrToFloat(AM1_A.Text);
  Values[3]:= StrToFloat(AM1_B.Text);
  Values[4]:= StrToFloat(AM2_A.Text);
  Values[5]:= StrToFloat(AM2_B.Text);

  Values[6]:= StrToFloat(FM0_A.Text);
  Values[7]:= StrToFloat(FM0_B.Text);
  Values[8]:= StrToFloat(FM1_A.Text);
  Values[9]:= StrToFloat(FM1_B.Text);
  Values[10]:= StrToFloat(FM2_A.Text);
  Values[11]:= StrToFloat(FM2_B.Text);
end;



procedure TfrmUart.update_statusbar;
var
  L_Info: String;
begin
  L_Info:= '';
  if vsComPort1.Active then
  begin
   L_Info:= vsComPort1.Device;
   L_Info:= L_Info + ' ' +  IntToStr(ConstsBaud[vsComPort1.BaudRate]);
   L_Info:= L_Info + ' ' +  ConstsParity[vsComPort1.Parity];
   L_Info:= L_Info + ' ' +  DataBitsStrings[vsComPort1.DataBits];
   L_Info:= L_Info + ' ' +  StopBitsStrings[vsComPort1.StopBits];
  end
  else
  begin
    L_Info:= '关闭';
  end;
  StatusBar1.Panels[0].Text:= L_Info;
end;

procedure TfrmUart.ProcessData;
var
  L_PackLen: WORD;
  L_HexStr: AnsiString;
begin
  //DebugText( PlumUtils.Buf2Hex(FBuf));
  While (Length(FBuf) >= 3)  do
  begin
    if strlcomp(#$7B, PAnsiChar(FBuf),1) = 0 then
    begin
      if Length(FBuf) >= 3  then //可以取得长度了
      begin
        if (Byte(FBuf[1]) = $7B) and (Byte(FBuf[3]) = $7D) then    //原来的协议，无长度，真是要命
        begin
          Case Byte(FBuf[2]) of
            $33:
            begin
              DebugText('接收到协议格式正确应答');
            end
          else
            DebugText('接收到协议其它应答');
          end;
          FBuf:= RightStr(FBuf, Length(FBuf) - 3);
        end
        else
        begin        //有长度的协议
          L_PackLen:= byte(FBuf[2]);
          if Length(FBuf) >= L_PackLen then
          begin
            if FBuf[L_PackLen] = #$7D then
            begin
              L_HexStr:= PlumUtils.Buf2Hex(AnsiLeftStr(FBuf, L_PackLen));
              DebugText('接收到数据: ' + L_HexStr);
              Case Byte(FBuf[3]) of   //Cmd
                $56:
                begin
                  ProcessLevelCoffStatus(FBuf);
                end;

              end;

              FBuf:= AnsiRightStr(FBuf, Length(FBuf) - L_PackLen);
            end
            else
            begin
              FBuf:= RightStr(FBuf, Length(FBuf) - 1);
              DebugText('找不到数据尾，弹出1字节');
            end;
          end
          else
          begin
            Break;
          end;
        end;
      end
      else
      begin
        break;
      end;
    end
    else
    begin
      FBuf:= RightStr(FBuf, Length(FBuf) - 1);
    end;
  end;
end;

procedure TfrmUart.DebugText(value: string);
begin
  self.Memo1.Lines.Add(FormatDateTime('YYYY-MM-DD HH:NN:SS:  ', Now()) + Value);
end;

procedure TfrmUart.DoProcessFrame(const Value: TSetCoffPackate);
var
  L_Error: Boolean;
begin
  L_Error:= True;
  {
  DebugText(Format('源: %-.2x%-.2xH, 目: %-.2x%-.2xH, 类型: %-.2xH, 长度: %-.2xH', [
                                      Byte(Value.Src), Byte(Value.Src shr 8),
                                      Byte(Value.Dest), Byte(Value.Dest shr 8),
                                      Value.AType,
                                      Value.len]));

  if Value.AType = $A2 then
  begin
    Case Value.len of
      $07:
      begin
        if (Value.AckContent.ContentIden = $5000) and (Value.AckContent.LengthBits = $1800) then
        begin
          if (Value.AckContent.DlCmdA = Value.AckContent.DlCmdB) then
          begin
            UpdateActStatus(Value.AckContent.DlCmdA, Value.AckContent.Act);
            L_Error:= False;
          end;
        end;

        if L_Error then
        begin
          DebugText(Format('信息类: %-.2x%-.2xH, 信息长: %-.2x%-.2xH, %-.2xH %-.2xH %-.2xH', [
                                              Byte(Value.AckContent.ContentIden), Byte(Value.AckContent.ContentIden shr 8),
                                              Byte(Value.AckContent.LengthBits), Byte(Value.AckContent.LengthBits shr 8),
                                              Value.AckContent.DlCmdA, Value.AckContent.DlCmdB, Value.AckContent.Act]));
        end;
      end;
      $09:
      begin
        if (Value.AckContent.ContentIden = $0000) and (Value.AckContent.LengthBits = $2800) then
        begin
          UpdateStatus(Value.ULContent.ChA, Value.ULContent.ChB, Value.ULContent.ChC, Value.ULContent.ChMain, Value.ULContent.Feed);
          L_Error:= False;
        end;

        if L_Error then
          DebugText(Format('信息类: %-.2x%-.2xH, 信息长度: %-.2x%-.2xH, %-.2xH %-.2xH %-.2xH %-.2xH %-.2xH', [
                                            Byte(Value.ULContent.ContentIden), Byte(Value.ULContent.ContentIden shr 8),
                                            Byte(Value.ULContent.LengthBits), Byte(Value.ULContent.LengthBits shr 8),
                                            Value.ULContent.ChA, Value.ULContent.ChB, Value.ULContent.ChC, Value.ULContent.ChMain, Value.ULContent.Feed
                                            ]));
      end;
    else
      DebugText('不识别的协议长度')
    end;
  end
  else
  begin
    DebugText('不识别的协议类型')
  end;
  }
end;


initialization
  DebugLogger.RegisterLogGroup('log', False);
  //DebugLogger.ParamForEnabledLogGroups:= '--debug-enabled=';
  //DebugLogger.ParamForLogFileName:= '--debug-logfile=';
  DebugLogger.UseStdOut:= True;
  DebugLn('RDA1005L Started.....');
end.

