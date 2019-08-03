unit u_J16SlopeCalibrateMeasureImp;

interface
uses
  Classes, SysUtils, u_ExamineImp, u_J08TaskIntf, u_J08Task;
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
  Radio: IJ08Receiver;
  bid, pid, sid: integer;
begin
  inherited;
   //------------------
   //��ʼ���豸
   //------------------

  SG:= TMG36XX.Create;
  With SG do
  begin
    pid:= 3;
    Iden:= 'SG';
    LoadInstrumentParam(bid, pid, sid);
    Connnect(bid, pid, sid);
  end;
  Radio:=  TJ08Receiver.Create;
  //-------------------
  //AMб�ʲ���
  //-------------------
  //�򿪽��ջ������������ģʽ
  

  //���ź�Դ������Ϊ15M�� -60dB ����

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
