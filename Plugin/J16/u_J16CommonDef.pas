unit u_J16CommonDef;

interface
uses
  SysUtils, u_ExamineGlobal;
type
  IStatText2XLS = interface
    ['{EF27DD16-E612-470E-8529-331C1FC101A5}']
    Procedure DoStatText2XLS;
  end;


  Function TextDir_NoFilter: String;
//type
//  TSlopeCalibrateSetting = Record
//    InsLoss: Double;
//  End;
implementation
  Function TextDir_NoFilter: String;
  begin
    Result:= Excel_Dir +  'ÎÞÂË²¨Æ÷Êý¾Ý\';
  end;
end.
