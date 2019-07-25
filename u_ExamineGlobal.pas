unit u_ExamineGlobal;

interface
uses
  Classes, SysUtils, Windows, Buttons, u_CommonDef, PlumLogFile, CnCommon, CnDebug, u_GPIB_DEV2,
  XLSReadWriteII5, XLSSheetData5, PlumUtils, IniFiles, CnRS232;

type
  TStringEvent = Procedure (const Str: String) of Object;
  TFindSWEvent = Function (const Str: String): TSpeedButton of Object;
  TGetSNEvent = Function (): String Of Object;
const
  INI_SECT_SW = '开关定义';

//  SW_ATT_STR_ARR: Array[0..1] of String = ('', '');
var
  g_ExamineRegList: TList;
  g_ExamineMode: TExamineMode;
  g_BatchWishStop: Boolean;
var
  g_SG1: ISignalGenerator;
  g_SG2: ISignalGenerator;
  g_RS232: TCnRS232;


Procedure Log(const Info: String);
function  Log_Dir: String;
function  Excel_Dir: String;
Procedure CheckInitGPIBInstrument;
Procedure SWButtonRegister(const SWName: String);
Procedure SWButtonExec(const SWName: String);

Function ProductSN: String;
function ExcelLog(EnvIndex: Integer): TXLSWorksheet;
Procedure ExcelLog_Flush;

Procedure ExtractFileFromRes(AResName, DestFile: String);

var
  g_dele_Log_Proc: TStringEvent;
  g_dele_swb_reg : TFindSWEvent;
  g_dele_swb_exec : TStringEvent;
  g_Dele_ProductSN: TGetSNEvent;
var
  DefaultIniFileName: String;

implementation
var
  _Log_: ILogFile;

function  Log_Dir: String;
begin
  Result:= _CnExtractFilePath(ParamStr(0)) + 'Log\'+ FormatDateTime('YYYYMMDD', Now) + '\';
end;

function  Excel_Dir: String;
begin
  Result:= _CnExtractFilePath(ParamStr(0)) + 'Excel\'+ FormatDateTime('YYYYMMDD', Now) + '\';
end;

Procedure Log(const Info: String);
var
  APath: String;
  AFullFileName: String;
begin
  APath:= Log_Dir;
  ForceDirectories(APath);

  AFullFileName:= APath  + FormatDateTime('HH', Now) + '.Log';

  if (_Log_ = Nil)  or (_Log_.FileName <> AFullFileName) then
  begin
    _Log_:= IntfCreateLogFile(AFullFileName, 4096);
  end;

  _Log_.Log(Info);

    if Assigned(g_dele_Log_Proc) then
    begin
      g_dele_Log_Proc(Info);
    end;  
end;



Procedure CheckInitGPIBInstrument;
  function ReadSG1Class(SectName: String): Integer;
  var
    L_Ini: TIniFile;
  begin
    L_Ini:= TIniFile.Create(_g_U_GPIB_DEV_INI_FILE_NAME);
    try
      Result:= L_Ini.ReadInteger(SectName, 'ImpClass', 0);
      L_Ini.WriteInteger(SectName, 'ImpClass', Result);      
    finally
      L_Ini.Free;
    end;

  end;
var
  bid: Integer;
  pid: Integer;
  sid: Integer;
begin

//  g_Test:= THP8360.Create;
//  With g_Test do
//  begin
//    pid:= 19;
//    Iden:= 'HP836XX_0';
//    LoadInstrumentParam(bid, pid, sid);
//    Connect2;
//    SetFreqency(1024.22);
//    SetLevelDbm(-23);
//    SetOnOff(True);
//    SetOnOff(False);
//  end;

  case ReadSG1Class('SIGNAL_1') of
    0:
    begin
      g_SG1:= THP8360.Create;
    end
  else
    g_SG1:= TAgilentE44XX.Create;
  end;

  With g_SG1 do
  begin
    pid:= 5;
    Iden:= 'SIGNAL_1';
    LoadInstrumentParam(bid, pid, sid);

//    Connect2;
//    SetFreqency(1024.22);
//    SetLevelDbm(-23);
//    SetOnOff(True);
//    SetOnOff(False);
  end;

  g_SG2:= TAgilentE44XX.Create;
  With g_SG2 do
  begin
    pid:= 19;
    Iden:= 'SIGNAL_2';
    LoadInstrumentParam(bid, pid, sid);
    //Connnect(bid, pid, sid);
  end;
end;

Procedure ReleaseGPIBInstrument;
begin

end;
Procedure SWButtonRegister(const SWName: String);
begin
  g_dele_swb_reg(SWName);
end;

Procedure SWButtonExec(const SWName: String);
begin
  g_dele_swb_exec(SWName);
  WaitMS(100);
end;


Function ProductSN: String;
begin
  Result:= '';
  if Assigned(g_Dele_ProductSN) then
  begin
    Result:= g_Dele_ProductSN;
  end;
end;


var
  g_XLSBook: TXLSReadWriteII5;




Procedure ExcelLog_Flush;
begin
  if g_XLSBook.Filename <> '' then
  begin
    g_XLSBook.Write();
    g_XLSBook.Sheets[0].AsStringRef['C4']:= ProductSN;
  end;
end;

function ExcelLog(EnvIndex: Integer): TXLSWorksheet;
const
  CONST_ENV_RESNAMES: Array[0..6] of String = (
    'CHA_LOW',
    'CHA_HIG',
    'CHA_TSTR',
    'CHA_SSTR',
    'CHA_FIR',
    'CHA_FIN',
    'CHA_DELI'
  );
  CONST_ENV_DESCNAMES: Array[0..6] of String = (
    '低温',
    '高温',
    '温冲后',
    '振动后',
    '常温初测',
    '常温终测',
    '所检'
  );
var
  FullFileName: String;
  rs: TResourceStream;
begin
  if Not DirectoryExists(Excel_Dir) then
  begin
    ForceDirectories(Excel_Dir);
  end;
  FullFileName:= Excel_Dir + ProductSN + '_'+ CONST_ENV_DESCNAMES[EnvIndex] + '.xlsx';


  if g_XLSBook.Filename <> FullFileName then
  begin
    if g_XLSBook.Filename <> '' then
      g_XLSBook.Write();
                                           
    if Not FileExists(FullFileName) then
    begin
      rs:= TResourceStream.Create(HInstance, CONST_ENV_RESNAMES[EnvIndex], 'MYFILE');
      try
        rs.SaveToFile(FullFileName);
      finally
        rs.Free;
      end;
    end;

    g_XLSBook.LoadFromFile(FullFileName);
  end;

  Result:= g_XLSBook.Sheets[0];
end;



Procedure ExtractFileFromRes(AResName, DestFile: String);
var
  rs: TResourceStream;
begin
  if Not FileExists(DestFile) then
  begin
    rs:= TResourceStream.Create(HInstance,AResName, 'MYFILE');
    try
      rs.SaveToFile(_CnExtractFilePath(ParamStr(0)) + DestFile);
    finally
      rs.Free;
    end;
  end;
end;
Initialization

  CheckInitGPIBInstrument;
  DefaultIniFileName:= ChangeFileExt(GetModuleName(HInstance), '.ini');

  g_XLSBook:= TXLSReadWriteII5.Create(Nil);

finalization
  if FileExists(g_XLSBook.Filename) then
    g_XLSBook.Write;
  FreeAndNil(g_XLSBook);
  ReleaseGPIBInstrument;

end.
