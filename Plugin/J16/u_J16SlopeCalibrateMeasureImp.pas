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
   //初始化设备
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
  //AM斜率测试
  //-------------------
  //打开接收机，进入非修正模式
  

  //打开信号源，设置为15M， -60dB 单音

end;

procedure TSlopeCalibrateMeasure.Init;
begin
  inherited;
  FExamineCaption:= '斜率校准';
//  FExamineCaption:= '一本振';
//  ExtractFileFromRes('LIB_INOUT32', 'inpout32.dll');
//  ExtractFileFromRes('LIB_ELEXS', 'ELEXS.dll');
//  ExtractFileFromRes('EXE_LO1', '一本振.exe');
end;

end.
