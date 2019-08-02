unit u_ExamineReg;

interface
uses
  u_ExamineGlobal, u_ExamineImp,
  u_frameExamineItemUI,
  u_J16SlopeCalibrateMeasureImp,
  u_frameJ16SlopeCalibrateMeasureUI;
implementation

Initialization
  g_ExamineRegList:= TExamineRegList.Create;
  With TExamineRegList(g_ExamineRegList) do
  begin
    Add(TSlopeCalibrateMeasure, TFrameCustomExamineItemUI1);
  end;

Finalization
  g_ExamineRegList.Free;
end.
