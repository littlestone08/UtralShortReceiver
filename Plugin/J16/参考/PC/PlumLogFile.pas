unit PlumLogFile;

interface
uses
  Classes, SysUtils;
type
  ILogFile = Interface
    ['{0B1AB8A8-6CEE-4B61-9638-55C622807642}']
    Procedure Log(Info: AnsiString; CRLF: Boolean = True);
    function get_FileName: TFileName;
    Property FileName: TFileName Read get_FileName;
  End;

  function IntfCreateLogFile(AFileName: TFileName): ILogFile;

implementation
uses
  StrUtils;

type
  TLogFile = Class(TInterfacedObject, ILogFile)
  Private
    FFile: TFileStream;
  Protected
    Procedure Log(Info: AnsiString; CRLF: Boolean = True);
    function get_FileName: TFileName;
  PUblic
    Constructor Create(AFileName: AnsiString);
    Destructor Destroy; Override;
  End;



  function IntfCreateLogFile(AFileName: TFileName): ILogFile;
  begin
    Result:= TLogFile.Create(AFileName);
  end;
{ TLogFile }

constructor TLogFile.Create(AFileName: AnsiString);
begin
  inherited Create;
  if Not FileExists(AFileName) then
  begin
    With TFileStream.Create(AFileName, fmCreate) do
      Free;
  end;
  FFile:= TFileStream.Create(AFileName, fmOpenWrite or fmShareDenyWrite);
  FFile.Seek(0, soFromEnd);
end;

destructor TLogFile.Destroy;
begin
  FreeAndNil(FFile);
  inherited;
end;

function TLogFile.get_FileName: TFileName;
begin
  Result:= FFile.FileName;
end;

procedure TLogFile.Log(Info: AnsiString; CRLF: Boolean);
begin

  Info:= FormatDateTime('YYYY-MM-DD HH:NN:SS.ZZZ', Now) + Char(#$09{vk_tab}) +  Info;

  if CRLF and Not AnsiEndsText(#$D#$A, Info) then
    Info:= Info + #$D#$A;
  FFile.Write(PAnsiChar(Info)^, Length(Info));
end;

end.
