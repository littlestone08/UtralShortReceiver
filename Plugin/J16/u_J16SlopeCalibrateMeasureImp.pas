unit u_J16SlopeCalibrateMeasureImp;

interface
uses
  Classes, SysUtils, u_ExamineImp;
type
  TSlopeCalibrateMeasure = Class(TCustomExamineItem)
  Private
//    FLog: TLO1MesureLog;
  Protected
    Procedure Init; Override;
    Procedure DoProcess; Override;
  Public

  End;

implementation
uses
  u_GPIB_DEV2;

{ TSlopeCalibrateMeasure }

procedure TSlopeCalibrateMeasure.DoProcess;
var
  SG: ISignalGenerator;
begin
  inherited;
  //AMб�ʲ���

  //�򿪽��ջ������������ģʽ
end;

procedure TSlopeCalibrateMeasure.Init;
begin
  inherited;
  FExamineCaption:= 'б��У׼';
//  FExamineCaption:= 'һ����';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', 'һ����.exe');
end;

end.
