unit u_ExamineReg;

interface
uses
  u_ExamineGlobal, u_ExamineImp,
  u_frameExamineItemUI,

  u_J16SlopeCalibrateMeasureImp,
  u_frameJ16SlopeCalibrateMeasureUI,

  u_J16LevelWithoutFilterImp,
  u_FrameLevelWithoutFilterUI;
implementation

Initialization
  g_ExamineRegList:= TExamineRegList.Create;
  With TExamineRegList(g_ExamineRegList) do
  begin
    Add(TLevelWithoutFilterMeasure, TLevelWithoutFilterUI);
    Add(TSlopeCalibrateMeasure, TSlopeCalibrateMeasureUI);
  end;

Finalization
  g_ExamineRegList.Free;
end.
