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
    Procedure SetAMCoeff(A0, B0, A1, B1, A2, B2: Double); //three coff to define the calibrateequtions:
                                                          //1 : A0 * x + B0
                                                          //2 : A1 * x + B1
                                                          //3 : A2 * x + B2
    Procedure SetFMCoeff(A0, B0, A1, B1, A2, B2: Double); //same with SetAMCoeff
    Procedure QueryCoeffInfo(var Value: TCoffReport);     // the receiver will be report the coeff info as responding this command,
                                                          // the value will return to  TCoffReport struct,
                                                          // 此命令发送后，应该用消息循环等待一会儿，以处理串口发送出来的数据
                                                          //保证返回的变量有效
    Procedure WriteToE2PROM;
  End;

  TJ16Receiver = Class(TJ08Receiver, ISlopeCalibrate)
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
    Procedure SetAMCoeff(A0, B0, A1, B1, A2, B2: Double);
    Procedure SetFMCoeff(A0, B0, A1, B1, A2, B2: Double);
    Procedure QueryCoeffInfo(var Value: TCoffReport);
    Procedure WriteToE2PROM;
  End;

implementation

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
begin

end;

procedure TJ16Receiver.QueryCoeffInfo;
begin

end;

procedure TJ16Receiver.SetAMCoeff(A0, B0, A1, B1, A2, B2: Double);
begin

end;

procedure TJ16Receiver.SetCoeffValid(Value: Boolean);
begin

end;

procedure TJ16Receiver.SetFMCoeff(A0, B0, A1, B1, A2, B2: Double);
begin

end;

procedure TJ16Receiver.WriteToE2PROM;
begin

end;

{ TJ16Receiver.TJ16RawPaser }

procedure TJ16Receiver.TJ16RawPaser.DoParse2(var ABuf: AnsiString;
  const ACtrl: TJ08Receiver; var MatchCode: Byte);
begin

end;

end.
