unit u_J16CommonDef;

interface
uses
  SysUtils, u_ExamineGlobal;
type
  IStatText2XLS = interface
    ['{EF27DD16-E612-470E-8529-331C1FC101A5}']
    Procedure DoStatText2XLS;
  end;




  PLevelWithFilterOption = ^TLevelWithFilterOption;
  TLevelWithFilterOption = Record
    ManualMode: Integer;
  End;
//type
//  TSlopeCalibrateSetting = Record
//    InsLoss: Double;
//  End;
   Function TextDir_NoFilter: String;
implementation
uses
  CnCommon;
  Function TextDir_NoFilter: String;
  begin
    Result:= _CnExtractFilePath(ParamStr(0)) + 'Excel\'+ 'Êý¾Ý\';
  end;


  
end.
