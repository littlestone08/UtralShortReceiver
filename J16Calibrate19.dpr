program J16Calibrate19;

{$R 'xlsx.res' 'xlsx.rc'}
{$R 'Plugin\J16\LevelWithoutFilter\LevelWithoutFilter.res' 'Plugin\J16\LevelWithoutFilter\LevelWithoutFilter.rc'}

uses
  Forms,
  u_Main in 'u_Main.pas' {Form1},
  NI448 in 'D:\WORK170619\PlumComm\GPIB2\NI448.pas',
  NI448_Status in 'D:\WORK170619\PlumComm\GPIB2\NI448_Status.pas',
  U_GPIB_DEV2 in 'D:\WORK170619\PlumComm\GPIB2\U_GPIB_DEV2.pas',
  u_frameExamineList in 'u_frameExamineList.pas' {frameExamineList: TFrame},
  u_CommonDef in 'u_CommonDef.pas',
  u_ExamineImp in 'u_ExamineImp.pas',
  u_FrameUart in 'uart\u_FrameUart.pas' {frameUart: TFrame},
  u_frameMain in 'u_frameMain.pas' {frameMain: TFrame},
  u_ExamineGlobal in 'u_ExamineGlobal.pas',
  u_AutoUpgraderEditorCrack in 'Upgrader\u_AutoUpgraderEditorCrack.pas' {AutoUpgraderEditorCrack},
  u_dmUpgrade in 'Upgrader\u_dmUpgrade.pas' {dmUpgrade: TDataModule},
  u_Version in 'Upgrader\u_Version.pas',
  u_frameExamineItemUIBase in 'u_frameExamineItemUIBase.pas' {FrameCustomExamineItemUI: TFrame},
  u_FreqCtrl in 'u_FreqCtrl.pas',
  u_ExamineReg in 'u_ExamineReg.pas',
  u_J08Task in 'Plugin\J16\u_J08Task.pas',
  u_J08WeakGlobal in 'Plugin\J16\u_J08WeakGlobal.pas',
  BT_WeakGlobal in 'Plugin\J16\BT_WeakGlobal.pas',
  u_J08TaskIntf in 'Plugin\J16\u_J08TaskIntf.pas',
  BT_TaskIntf in 'Plugin\J16\BT_TaskIntf.pas',
  u_J16Utils in 'Plugin\J16\u_J16Utils.pas',
  u_J16Receiver in 'Plugin\J16\u_J16Receiver.pas',
  PlumUtils in 'D:\WORK170619\PlumComm\PlumUtils.pas',
  u_J16CommonDef in 'Plugin\J16\u_J16CommonDef.pas',
  u_frameJ16SlopeCalibrateMeasureUI in 'Plugin\J16\SlopeCalibrate\u_frameJ16SlopeCalibrateMeasureUI.pas' {SlopeCalibrateMeasureUI: TFrame},
  u_J16SlopeCalibrateMeasureImp in 'Plugin\J16\SlopeCalibrate\u_J16SlopeCalibrateMeasureImp.pas',
  u_J16LevelWithoutFilterImp in 'Plugin\J16\LevelWithoutFilter\u_J16LevelWithoutFilterImp.pas',
  u_J16LevelWithFilterImp in 'Plugin\J16\LevelWithFilter\u_J16LevelWithFilterImp.pas',
  u_FrameLevelWithoutFilterUI in 'Plugin\J16\LevelWithoutFilter\u_FrameLevelWithoutFilterUI.pas' {LevelWithoutFilterUI: TFrame},
  u_FrameLevelWithFilterUI in 'Plugin\J16\LevelWithFilter\u_FrameLevelWithFilterUI.pas' {LevelWithFilterUI: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TdmUpgrade, dmUpgrade);
  Application.Run;
end.