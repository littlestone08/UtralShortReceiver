unit u_LODef;

//同频异频: (IO 1~8)
//使用IO6, IO7, IO8控制
//同频时：IO6 = H, IO7 = H, IO8 = L
//异频时：IO6 = L, IO7 = L, IO8 = H
interface
uses
  CnCommon;
type
  //---------------------LO 测试使用的结构-------------------------------------
  TLOEnvironType = (loeNormalFirst, loeHighTemp, loeLowTemp, loeNormalFinal,
                        loeDelivery, loeSharinked, loeTempStriked);



  TPortPhaseNoise = Record
    Checked: Boolean;
    Values: Array  of Array[0..2] of Double;         //1个端口测试N个频率下的1K, 10K, 100K下的相噪
  End;

  TPortSpurious = Record
    Checked: Boolean;
    Values:  Array of Double;                //1个端口测试N个频点
  End;
  TPortSignalPower = Record
    Checked: Boolean;
    Values: Array of Double;                //3个端口测试N个频点
  End;

  TSignalPower = Array [0..2] of TPortSignalPower;
  TSpurious = Array[0..0] of TPortSpurious;
  TPhaseNoise = Array[0..0] of TPortPhaseNoise;

  TLOUnit = Record
    PhaseNoise  :  TPhaseNoise;
    SignalPower :  TSignalPower;
    Spurious    :  TSpurious;
    Offset      : Double;
    Procedure InitTestType(Environ: TLOEnvironType);
    function CalcuTotalStep: Integer;

    function NeedMeasurePhaseNoise(): Boolean;
    function NeedMeasureSignalPower(): Boolean;
    function NeedMeasureSpurious(): Boolean;
  End;

  TLOMesureLog = Record
    AutoNext    : Boolean;
    EnvType     : TLOEnvironType;
    LOUnits       : Array[0..1] of TLOUnit;
    Procedure InitTestType(Environ: TLOEnvironType);
    function CalcuTotalStep: Integer;

    function NeedMeasurePhaseNoise(): Boolean;
    function NeedMeasureSignalPower(): Boolean;
    function NeedMeasureSpurious(): Boolean;

    Procedure ToExcel(const SN: String; var Disqualification: Boolean);
  End;
  PLOMesureLog = ^TLOMesureLog;
const
  CONST_THREASHOLD_LO_PN: Array[0..2] of Double = (-93, -99, -107);

  CONST_SUBLO1_FREQ: Array[0..3] of Double = (1670, 2050, 2270, 2870);
  CONST_SUBLO1_APPFREQ: Array[0..3] of Double = (270, 250, 270, 270);
  CONST_SUBLO2_FREQ: Array[0..1] of Double = (790, 860);
  CONST_SUBLO_PN_OFFSET: Array[0..2] of String = ('1KHz', '10KHz', '100KHz');


  LO_ENV_DESC: Array[Low(TLOEnvironType)..HIgh(TLOEnvironType)] of string = (
                 '初测',
                  '高温',
                  '低温',
                  '终测',
                  '验收',
                  '震动后',
                  '温冲后'
  );
  LO_RES_NAME: Array[Low(TLOEnvironType)..HIgh(TLOEnvironType)] of string = (
                'LO_TFIR',
                'LO_HIG',
                'LO_LOW',
                'LO_TFIN',
                'LO_DELI',
                'LO_SSTR',
                'LO_TSTR'
  );
implementation
uses
  Classes, Graphics,
  XLSSheetData5, Xc12Utils5, SysUtils, u_ExamineGlobal, XLSReadWriteII5;

{ TMesureLog }

function TLOUnit.CalcuTotalStep: Integer;
var
  i: Integer;
begin
  Result:= 0;

  for i := 0 to Length(self.PhaseNoise) - 1 do
  begin
    if self.PhaseNoise[i].Checked then
      Inc(Result, Length(PhaseNoise[i].Values)); //相噪是一次测出的
  end;

  for i := 0 to Length(self.SignalPower) - 1 do
  begin
    if self.SignalPower[i].Checked then
      Inc(Result, Length(SignalPower[i].Values));
  end;

  for i := 0 to Length(self.Spurious) - 1 do
  begin
    if self.Spurious[i].Checked then
      Inc(Result, Length(Spurious[i].Values));
  end;

end;

function TLOMesureLog.CalcuTotalStep: Integer;
var
  i: integer;
begin
  Result:= 0;
  for i := 0 to Length(LOUnits) - 1 do
  begin
    Inc(Result, LOUnits[i].CalcuTotalStep);
  end;
end;

procedure TLOMesureLog.InitTestType(Environ: TLOEnvironType);
var
  iUnit: Integer;
  iPort: Integer;
  FreqCount: Integer;
begin
  EnvType:=  Environ;

  for iUnit := 0 to Length(LOUnits) - 1 do
  begin
    LOUnits[iUnit].InitTestType(Environ);

    if iUnit = 0 then
    begin
      FreqCount:= Length(CONST_SUBLO1_FREQ);
    end
    else
    begin
      FreqCount:= Length(CONST_SUBLO2_FREQ);
    end;

    SetLength(LOUnits[iUnit].PhaseNoise[0].Values, FreqCount);
    SetLength(LOUnits[iUnit].Spurious[0].Values, FreqCount);


    for iPort := 0 to Length(LOUnits[iUnit].SignalPower) - 1 do
    begin
      SetLength(LOUnits[iUnit].SignalPower[iPort].Values, FreqCount);
    end;
  end;
end;


function TLOMesureLog.NeedMeasurePhaseNoise: Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i := 0 to Length(self.LOUnits) - 1 do
  begin
    Result:= Result or LOUnits[i].NeedMeasurePhaseNoise;
  end;
end;

function TLOMesureLog.NeedMeasureSignalPower: Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i := 0 to Length(self.LOUnits) - 1 do
  begin
    Result:= Result or LOUnits[i].NeedMeasureSignalPower;
  end;
end;

function TLOMesureLog.NeedMeasureSpurious: Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i := 0 to Length(self.LOUnits) - 1 do
  begin
    Result:= Result or LOUnits[i].NeedMeasureSpurious;
  end;
end;


//  for i := Low(PhaseNoise) to High(PhaseNoise) do
//  begin
//    PhaseNoise[i].Checked:= True;
//  end;
//
//  for i := Low(SignalLevel) to High(SignalLevel) do
//  begin
//    SignalLevel[i].Checked:= True;
//  end;
//
//  for i := Low(Spurious) to High(Spurious) do
//  begin
//    SetLength(Spurious[i].Values, 5);
//    Spurious[i].Checked:= True;
//  end;




procedure TLOUnit.InitTestType(Environ: TLOEnvironType);
begin
//
end;

function TLOUnit.NeedMeasurePhaseNoise(): Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i := 0 to Length(PhaseNoise) - 1 do
  begin
    Result:= Result or PhaseNoise[i].Checked;
    if Result then
      Break;
  end;
end;



function TLOUnit.NeedMeasureSignalPower: Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i := 0 to Length(SignalPower) - 1 do
  begin
    Result:= Result or SignalPower[i].Checked;
    if Result then
      Break;
  end;
end;

function TLOUnit.NeedMeasureSpurious: Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i := 0 to Length(Spurious) - 1 do
  begin
    Result:= Result or Spurious[i].Checked;
    if Result then
      Break;
  end;
end;

procedure TLOMesureLog.ToExcel(const SN: String; var Disqualification: Boolean);
  Procedure DataToSheet(ASheet: TXLSWorksheet);
    Procedure Spurious2Sheet();
    var
      iUnit, iFreq, ARowNum, AColNum, CurrRow, CurrCol: Integer;
      AValue: Double;
    begin
      if NeedMeasureSpurious() then
      begin
        RefStrToColRow('I16', AColNum, ARowNum);
        for iUnit := 0 to Length(LOUnits) - 1 do
        begin
          if LOUnits[iUnit].Spurious[0].Checked then
          begin

            for iFreq := 0 to Length(LOUnits[iUnit].Spurious[0].Values) - 1 do
            begin
              AValue:= LOUnits[iUnit].Spurious[0].Values[iFreq];

              CurrRow:= ARowNum + iFreq  + iUnit * 9;
              CurrCol:= AColNum;

              if AValue >= 65 then
              begin
                ASheet.Cell[CurrCol, CurrRow].FontColor:= clBlack
              end
              else
              begin
                ASheet.Cell[CurrCol, CurrRow].FontColor:= $FF0000;
                Disqualification:= Disqualification or True;
              end;

              ASheet.AsString[CurrCol, CurrRow]:= Format('%.1f', [AValue]);
            end;
          end;
        end;
      end;
    end;
    Procedure PhaseNoise2Sheet();
    var
      iOffset: Integer;
      iFreq: Integer;
      iUnit: Integer;
      ARowNum, AColNum, CurrRow, CurrCol: Integer;
      AValue: Double;
    begin
      if NeedMeasurePhaseNoise() then
      begin
        RefStrToColRow('F16', AColNum, ARowNum);
        for iUnit := 0 to Length(LOUnits) - 1 do
        begin

          if LOUnits[iUnit].PhaseNoise[0].Checked then
          begin
            for iFreq := 0 to Length(LOUnits[iUnit].PhaseNoise[0].Values) - 1 do
            begin
              for iOffset := 0 to Length(LOUnits[iUnit].PhaseNoise[0].Values[iFreq]) - 1 do
              begin
                AValue:= LOUnits[iUnit].PhaseNoise[0].Values[iFreq][iOffset];
                //Row + iNoise
                //COL + 4 * iFreq + iPort + 16 * iUnit
                CurrRow:= ARowNum + iFreq  + iUnit * 9;
                CurrCol:= AColNum + iOffset;

                if AValue <= CONST_THREASHOLD_LO_PN[iOffset] then
                begin
                  ASheet.Cell[CurrCol, CurrRow].FontColor:= clBlack
                end
                else
                begin
                  ASheet.Cell[CurrCol, CurrRow].FontColor:= $FF0000;
                  Disqualification:= Disqualification or True;
                end;
                ASheet.AsString[CurrCol, CurrRow]:= Format('%.1f', [AValue]);
              end;
            end;
          end;
        end;
      end;
    end;
    Procedure Level2Sheet();
    var
      iUnit, iPort, iFreq: Integer;
      ARowNum: Integer;
      AColNum: Integer;
      AValue: Double;
      CurrRow, CurrCol: Integer;
    begin
      if NeedMeasureSignalPower() then
      begin
        RefStrToColRow('C16', AColNum, ARowNum);
        for iUnit := 0 to Length(LOUnits) - 1 do
        begin
          for iPort := 0 to Length(LOUnits[iUnit].SignalPower) - 1 do
          if LOUnits[iUnit].SignalPower[iPort].Checked then
          begin
            for iFreq := 0 to Length(LOUnits[iUnit].SignalPower[iPort].Values) - 1 do
            begin
              AValue:= LOUnits[iUnit].SignalPower[iPort].Values[iFreq];
              CurrRow:= ARowNum + iFreq  + iUnit * 9;
              CurrCol:= AColNum + iPort;

              if AValue >= 3 then
              begin
                ASheet.Cell[CurrCol, CurrRow].FontColor:= clBlack
              end
              else
              begin
                ASheet.Cell[CurrCol, CurrRow].FontColor:= $FF0000;
                Disqualification:= Disqualification or True;
              end;

              ASheet.AsString[CurrCol, CurrRow]:= Format('%.1f', [AValue]);

              if (iUnit = 0) and (iPort = 0) and (iFreq = 0) and (Not (EnvType in [loeSharinked, loeTempStriked])) then
              begin
                AValue:= LOUnits[iUnit].Offset;
                if AValue >= 3 then
                begin
                  ASheet.Cell[CurrCol + 7, CurrRow].FontColor:= clBlack
                end
                else
                begin
                  ASheet.Cell[CurrCol + 7, CurrRow].FontColor:= $FF0000;
                  Disqualification:= Disqualification or True;
                end;
                ASheet.AsString[CurrCol + 7, CurrRow]:= '100Hz';
              end;
            end;
          end;
        end;
      end;
    end;

  var
    ARowNum: Integer;
    AColNum: Integer;
  begin

    if EnvType = loeDelivery then
    begin
      RefStrToColRow('J4', AColNum, ARowNum);
      ASheet.AsString[AColNum, ARowNum]:= SN;
    end
    else
    begin
      RefStrToColRow('C4', AColNum, ARowNum);
      ASheet.AsString[AColNum, ARowNum]:= SN;
      RefStrToColRow('I4', AColNum, ARowNum);
      ASheet.AsString[AColNum, ARowNum]:= LO_ENV_DESC[EnvType];
    end;

    //相噪
    PhaseNoise2Sheet();
    //电平
    Level2Sheet();

    //杂散抑制
    Spurious2Sheet();
  end;


var
  Book: TXLSReadWriteII5;
  FullFileName: String;
  rs: TResourceStream;
  TemplateFullFileName: String;
begin
  Disqualification:= False;
  if Not DirectoryExists(Excel_Dir) then
  begin
    ForceDirectories(Excel_Dir);
  end;

  FullFileName:= Excel_Dir + ProductSN + '_本振_' + LO_ENV_DESC[EnvType] + '.xlsx';

  //如果没有模板文件，则生成模板文件
  TemplateFullFileName:= _CnExtractFilePath(ParamStr(0)) + 'template\LO\' + LO_ENV_DESC[EnvType] + '.xlsx';
  ForceDirectories(_CnExtractFileDir(TemplateFullFileName));

  if Not FileExists(TemplateFullFileName) then
  begin
    rs:= TResourceStream.Create(HInstance, LO_RES_NAME[EnvType], 'MYFILE');
    try
      rs.SaveToFile(TemplateFullFileName);
    finally
      rs.Free;
    end;
  end;

  Book:= TXLSReadWriteII5.Create(Nil);
  try
    if FileExists(FullFileName) then
      Book.LoadFromFile(FullFileName)
    else
      Book.LoadFromFile(TemplateFullFileName);
      
    DataToSheet(Book.Sheets[0]);
    Book.SaveToFile(FullFileName);
  finally
    Book.Free;
  end;
end;

end.
