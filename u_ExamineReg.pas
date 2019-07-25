unit u_ExamineReg;

interface
uses
  u_ExamineGlobal, u_ExamineImp,
  u_frameExamineItemUI;
implementation

Initialization
  g_ExamineRegList:= TExamineRegList.Create;
  With TExamineRegList(g_ExamineRegList) do
  begin
//    Add(TExamineLO, TFrameExamineLOUI);
  end;

Finalization
  g_ExamineRegList.Free;
end.
