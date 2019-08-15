unit u_J16Receiver;

interface
uses
  Classes, SysUtils, u_J08Task;
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


  ISlopeCalibrate = Interface
    ['{F36DF0F2-74FF-4A3C-85BD-46C00FFC43B3}']
    Procedure LevelDataFormat(Value : Integer); //0: orginal value  1: calibrated value
    Procedure SetCoeffValid(Value : Boolean); //false: Coeff invalid and not used  1: Coeff valid can used by leveldata format
    Procedure SetAMCoeff(AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single); //three coff to define the calibrateequtions:
                                                          //1 : A0 * x + B0   放大状态系数(小信号)
                                                          //2 : A1 * x + B1   直通状态系数(中信号)
                                                          //3 : A2 * x + B2   衰减状态系数(大信号)
    Procedure SetAMCoeff2(const Value: TCoffs);
    Procedure SetFMCoeff2(const Value: TCoffs);
    Procedure SetFMCoeff(AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single); //same with SetAMCoeff
    Function  QueryCoeffInfo(var Value: TCoffReport): Boolean;     // the receiver will be report the coeff info as responding this command,
                                                          // the value will return to  TCoffReport struct,
                                                          // 此命令发送后，应该用消息循环等待一会儿，以处理串口发送出来的数据
                                                          //保证返回的变量有效
    Procedure WriteToE2PROM;
  End;

  TJ16Receiver = Class(TJ08Receiver, ISlopeCalibrate)
  Private
    FCoffReport: TCoffReport;
    Procedure ProcessLevelCoffStatus(const Raw: String);
    procedure SetCoeff(AM_FM_indicate: Byte; AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single);
  Public Type
    TJ16RawPaser = class(TJ08Receiver.TJ08RawParser)
    Protected
//      Procedure DoParser(var ABuf: AnsiString; const ACtrl: TJ08Receiver); Override;
      Procedure DoParse2(var ABuf: AnsiString; const ACtrl: TJ08Receiver; var MatchCode: Byte); Override;
    end;
  protected
    function GetParserClass: TRawParserClass; override;
  Protected //interface
    Procedure LevelDataFormat(Value : Integer);
    Procedure SetCoeffValid(Value : Boolean);
    Procedure SetAMCoeff(AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single);
    Procedure SetFMCoeff(AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single);
    Function  QueryCoeffInfo(var Value: TCoffReport): Boolean;
    Procedure WriteToE2PROM;
    Procedure SetAMCoeff2(const Value: TCoffs);
    Procedure SetFMCoeff2(const Value: TCoffs);    
  End;

implementation
uses
  StrUtils, PlumUtils, Windows;

Procedure DebugText(const Info: String);
begin

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


{ TJ16Receiver }

function TJ16Receiver.GetParserClass: TRawParserClass;
begin
  Result:= TJ16RawPaser;
end;

procedure TJ16Receiver.LevelDataFormat(Value: Integer);
const
  L_Cmds: Array[0..1] of AnsiString = (#$7B#$05#$53#$00#$7D, #$7B#$05#$53#$01#$7D);
begin
  WriteRawData(PAnsiChar(L_Cmds[Value]), Length(L_Cmds[Value]));
end;

procedure TJ16Receiver.ProcessLevelCoffStatus(const Raw: String);
begin
  FCoffReport.FromString(Raw);
  DebugText(PlumUtils.Buf2Hex(FCoffReport.ToString));
end;

Function TJ16Receiver.QueryCoeffInfo(var Value: TCoffReport): Boolean;
const
  L_Cmd: AnsiString =  #$7B#$04#$56#$7D;
var
  Try_Time: Integer;
begin
  {$IFNDEF Debug_Emu}
  Result:= False;
  WriteRawData(PAnsiChar(L_Cmd), Length(L_Cmd));
  FCoffReport.SOF:= 0;
  Try_Time:= 0;
  while (Try_Time < 3) and (FCoffReport.SOF = 0) do
  begin
    WaitMS(100);
    Inc(Try_Time);
  end;

  if FCoffReport.SOF <> 0 then
  begin
    Value:= FCoffReport;
    Result:= True;
  end;
  {$ELSE}
  Result:= True;
  {$ENDIF}
end;



Procedure ReverseDWORD(var  value: DWORD);
type
  PtrLongRec = ^LongRec;
var
  PtrOld: PtrLongRec;
  PtrNew: PtrLongRec;
  RAW: LongInt;
begin
  PtrOld:= @Value;
  PtrNew:= @Raw;
  PtrNew.Bytes[0]:= PtrOld.Bytes[3];
  PtrNew.Bytes[1]:= PtrOld.Bytes[2];
  PtrNew.Bytes[2]:= PtrOld.Bytes[1];
  PtrNew.Bytes[3]:= PtrOld.Bytes[0];
  PLongInt(PtrOld)^:= Raw;
end;

Procedure ReverseCoffsByteOrder(var Coffs: TCoffs);
var
  i: Integer;
  Ptr: PDWORD;
begin
  Ptr:= @Coffs;
  for i:= 0 to (SizeOf(Coffs) div SizeOf(Single)) - 1 do
  begin
    ReverseDWORD(Ptr^);
    Inc(Ptr);
  end;
end;

procedure TJ16Receiver.SetCoeff(AM_FM_indicate: Byte; AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single);
var
  L_Packate: TSetCoffPackate;
  L_Buf: AnsiString;
begin
  L_Packate.Fill(AM_FM_indicate, AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2);

  ReverseCoffsByteOrder(L_Packate.Coffs);
  L_Buf:= L_Packate.ToString;
  WriteRawData(PAnsiChar(L_Buf), Length(L_Buf));

  DebugText('写入串口：' + PlumUtils.Buf2Hex(AnsiLeftStr(L_Buf, Length(L_Buf))));
end;

procedure TJ16Receiver.SetAMCoeff(AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single);
begin
  SetCoeff(0, AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2);
end;

procedure TJ16Receiver.SetAMCoeff2(const Value: TCoffs);
begin
  SetCoeff(0,
            Value[0, 0], Value[0, 1],
            Value[1, 0], Value[1, 1],
            Value[2, 0], Value[2, 1]);
end;

procedure TJ16Receiver.SetCoeffValid(Value: Boolean);
const
  L_Cmds: Array[0..1] of String = (#$7B#$05#$54#$00#$7D, #$7B#$05#$54#$01#$7D);
begin
  if Value then
    WriteRawData(PAnsiChar(L_Cmds[1]), Length(L_Cmds[1]))
  else
    WriteRawData(PAnsiChar(L_Cmds[0]), Length(L_Cmds[0]));
end;

procedure TJ16Receiver.SetFMCoeff(AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2: Single);
begin
  SetCoeff(0, AmpA0, AmpB0, DirA1, DirB1, AttenA2, AttenB2);
end;

procedure TJ16Receiver.SetFMCoeff2(const Value: TCoffs);
begin
  SetCoeff(1,
            Value[0, 0], Value[0, 1],
            Value[1, 0], Value[1, 1],
            Value[2, 0], Value[2, 1]);
end;

procedure TJ16Receiver.WriteToE2PROM;
const
  L_Cmds:Array[0..0] of String = (#$7B#$04#$57#$7D);
begin
  WriteRawData(PAnsiChar(L_Cmds[0]), Length(L_Cmds[0]));
end;

{ TJ16Receiver.TJ16RawPaser }

procedure TJ16Receiver.TJ16RawPaser.DoParse2(var ABuf: AnsiString;
  const ACtrl: TJ08Receiver; var MatchCode: Byte);
var
  L_PackLen: WORD;
  L_HexStr: AnsiString;
begin
  //DebugText( PlumUtils.Buf2Hex(ABuf));
  While (Length(ABuf) >= 3)  do
  begin
    if strlcomp(#$7B, PAnsiChar(ABuf),1) = 0 then
    begin
      if Length(ABuf) >= 3  then //可以取得长度了
      begin
        if (Byte(ABuf[1]) = $7B) and (Byte(ABuf[3]) = $7D) then    //原来的协议，无长度，真是要命
        begin
          Case Byte(ABuf[2]) of
            $33:
            begin
              DebugText('接收到协议格式正确应答');
            end
          else
            DebugText('接收到协议其它应答');
          end;
          ABuf:= RightStr(ABuf, Length(ABuf) - 3);
        end
        else
        begin        //有长度的协议
          L_PackLen:= byte(ABuf[2]);
          if Length(ABuf) >= L_PackLen then
          begin
            if ABuf[L_PackLen] = #$7D then
            begin
              L_HexStr:= PlumUtils.Buf2Hex(AnsiLeftStr(ABuf, L_PackLen));
              DebugText('接收到数据: ' + L_HexStr);
              Case Byte(ABuf[3]) of   //Cmd
                $56:
                begin
                  TJ16Receiver(ACtrl).ProcessLevelCoffStatus(ABuf);
                end;

              end;

              ABuf:= AnsiRightStr(ABuf, Length(ABuf) - L_PackLen);
            end
            else
            begin
              ABuf:= RightStr(ABuf, Length(ABuf) - 1);
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
      ABuf:= RightStr(ABuf, Length(ABuf) - 1);
    end;
  end;
end;


var
  x: DWORD;
initialization
  x:= $11223344;
  windows.OutputDebugString(PChar(Format('%x', [x])));  
  ReverseDWORD(x);
  windows.OutputDebugString(PChar(Format('%x', [x])));
end.
