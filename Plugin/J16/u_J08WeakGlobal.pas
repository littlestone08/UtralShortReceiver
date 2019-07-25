unit u_J08WeakGlobal;

interface
uses
  Types, Messages, Windows, BT_WeakGlobal;

type
  TAppGlobalFuncSel = (gfsCalibrate, gfsInspect);

  PJ08InitInfo = ^TJ08InitInfo;
  TJ08InitInfo = Record
    SerialPort: String;
    SerialCode: String;
  End;

  TJ08_ModuType     = (mtUnknown, mtAM, mtFM);
  TJ08_Band         = (F0, F1, F2, F3, F4, F5, F6, F7, F8, F9);
  TJ08_Level        = (lvl_Azero,
                        lvl_neg10, lvl_neg20, lvl_neg30, lvl_neg40, lvl_neg50,
                        lvl_neg60, lvl_neg70, lvl_neg80, lvl_neg90, lvl_neg100,
                        lvl_neg110) ;
  TJ08_DevAmpMode   =(damUnkown, damAuto, damManual);
  TJ08_DevManualMode= (dmmUnknown, dmmAmpli, dmmDirect, dmmAttent);

  TJ08_FMModulFreqOffsetKHz =(fo0KHz, fo10KHz, fo20KHz, fo30KHz, fo40KHz, fo50KHz, fo60KHz, fo70KHz, fo75KHz );
  TCardinalDoublePair = Record
    a: Cardinal;
    b: Double;
  End;
  TCardinalDoubleDynArray = Array of TCardinalDoublePair;

  TJ08_AMIFBandWidth = (aibw_4K, aibw_6K, aibw_8K);
  TJ08_AMDepthCalcBandWidth = (adbw_15K, adbw_3K);
  TJ08_CarrierBandWidth = (cbw_Wide, cbw_Middle, cbw_Narrow);
  TJ08_SSBMode = (sm_CW, sm_LSB, sm_USB);
const
  BTM_J08_UPDATEUI_SAMPLEDATA  = BTM_CUSTOM + 0 ;
const

  CONST_STR_BAND: Array[Low(TJ08_Band)..High(TJ08_Band)] of String = (
    'F0', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9');
  CONST_STR_LEVEL:Array[Low(TJ08_Level)..High(TJ08_Level)] of String = (
    '   0dBm', ' -10dBm',' -20dBm', ' -30dBm',' -40dBm', ' -50dBm',' -60dBm',
    ' -70dBm',' -80dBm', ' -90dBm', '-100dBm', '-110dBm');
  CONST_STR_DEVMANUALMODE: Array[Low(TJ08_DevManualMode)..High(TJ08_DevManualMode)] of String = (
    '未知', '放大', '直通', '衰减');
  CONST_STR_DEVAMPMODE: Array[Low(TJ08_DevAmpMode)..High(TJ08_DevAmpMode)] of String = (
    '未知', '自动', '手动');
  CONST_LEVEL_VALUE: Array [Low(TJ08_Level)..High(TJ08_Level)] of Integer = (
    0, -10, -20, -30, -40, -50, -60, -70, -80, -90, -100, -110);
  //扫频时使用的步长
  CONST_SCAN_STEPKHZ_OFBAND: Array[Low(TJ08_Band)..High(TJ08_Band)] of Cardinal = (
    9, 9, 9, 5, 5, 5, 5, 5, 5, 100
  );
  CONST_FMMODULFREQOFFSETKHZ_VALUE: Array[Low(TJ08_FMModulFreqOffsetKHz)..High(TJ08_FMModulFreqOffsetKHz)] of Integer =
  (0, 10, 20, 30, 40, 50, 60, 70, 75);
  CONST_STR_MODUL: Array[Low(TJ08_ModuType)..High(TJ08_ModuType)] of String = ('未知', 'AM', 'FM');

const
  //AM电平校准时有效的数据值范围
  //衰减时 0~-70  直通时-10~-80  放大时-10~-110
  CONST_VALIDLEVELS_AM_LEVEL: Array[dmmAmpli..dmmAttent] of set of TJ08_Level = (
            [lvl_neg40..lvl_neg110],
            [lvl_neg10..lvl_neg80],
            [lvl_Azero..lvl_neg60]
  );
  //FM电平校准时有效的数据值范围
  //衰减时 0~-70  直通时-10~-80  放大时-10~-110
  CONST_VALIDLEVELS_FM_LEVEL: Array[dmmAmpli..dmmAttent] of set of TJ08_Level = (
            [lvl_neg50..lvl_neg100],
            [lvl_neg20..lvl_neg80],
            [lvl_neg10..lvl_neg60]
  );

const //ini配置文件相关
  //电平
  CONST_INI_SECTION_LEVEL: Array[dmmAmpli..dmmAttent] of AnsiString = ('LevelParam0', 'LevelParam2', 'LevelParam1');
  CONST_INI_FIELD_BAND_LEVEL  : Array[F0..F9] of AnsiString = ('LevelDbmXS0', 'LevelDbmXS1', 'LevelDbmXS2', 'LevelDbmXS3', 'LevelDbmXS4',
                                                       'LevelDbmXS5', 'LevelDbmXS6', 'LevelDbmXS7', 'LevelDbmXS8', 'LevelDbmXS9');
  CONST_INI_SECTION_FREQRESPON_COMPATIBLE: AnsiString = 'LevelParam';       
  //平坦度(频率响应)
  CONST_INI_SECTION_FREQRESPON: Array[dmmAmpli..dmmAttent] of AnsiString = ('FreqRespose0', 'FreqRespose2', 'FreqRespose1');
  CONST_INI_FIELD_FREQRESPON  : Array[F0..F9] of AnsiString = ('F0', 'F1', 'F2', 'F3', 'F4',
                                                       'F5', 'F6', 'F7', 'F8', 'F9');
  //扫描数据
  CONST_INI_SECTION_SCAN: AnsiString = 'ScanLevelZYParam';
  CONST_INI_FIELD_BAND_SCAN  : Array[F0..F9] of AnsiString = ('ScanLevelZYXS0', 'ScanLevelZYXS1', 'ScanLevelZYXS2', 'ScanLevelZYXS3', 'ScanLevelZYXS4',
                                                       'ScanLevelZYXS5', 'ScanLevelZYXS6', 'ScanLevelZYXS7', 'ScanLevelZYXS8', 'ScanLevelZYXS9');


  CONST_INI_FIELD_FMMODU_DEPTH: Array[dmmAmpli..dmmAttent] of AnsiString = ('FMModu10', 'FMModu20', 'FMModu30');
  //其它参数
  CONST_INI_SECTION_OTHER: AnsiString = 'OtherParam';
  CONST_INI_SECTION_AMEND: AnsiString = 'AmendParam';
  CONST_INI_FIELD_AMMODU: AnsiString = 'AMModu';
  CONST_INI_FIELD_FMMODU: AnsiString = 'FMModu';
type
  TJ08BandFreqInfo = Record
    BandIden      : String;
    BandTextHint  : String;
    BandCenterKHZ : Cardinal;
  End;

const
  CONST_MEASURE_LEVEL_BANDINFOS: Array[Low(TJ08_Band)..High(TJ08_Band)]of TJ08BandFreqInfo = (
    (BandIden: 'F0'; BandTextHint: '0.5MHZ-1.5MHZ';     BandCenterKHZ : 1120),
    (BandIden: 'F1'; BandTextHint: '1.5MHZ-2.181MHZ';   BandCenterKHZ : 1826),
    (BandIden: 'F2'; BandTextHint: '2.181MHZ-3.172MHZ'; BandCenterKHZ : 2670),
    (BandIden: 'F3'; BandTextHint: '3.172MHZ-4.613MHZ'; BandCenterKHZ : 3890),
    (BandIden: 'F4'; BandTextHint: '4.613MHZ-6.708MHZ'; BandCenterKHZ : 5660),
    (BandIden: 'F5'; BandTextHint: '6.708MHZ-9.775MHZ'; BandCenterKHZ : 8200),
    (BandIden: 'F6'; BandTextHint: '9.775MHZ-14.186MHZ';BandCenterKHZ : 12340),
    (BandIden: 'F7'; BandTextHint: '14.186MHZ-20.630MHZ'; BandCenterKHZ:17430),
    (BandIden: 'F8'; BandTextHint: '20.630MHZ-30.00MHZ';BandCenterKHZ : 25120),
    (BandIden: 'F9'; BandTextHint: '88MHZ-108MHZ';      BandCenterKHZ : 98760)
  );



//===========================================自动测试相关的定义===================================
type
  TJ08_LevelSet = set of TJ08_Level;
  //自动测试界面更新时使用的传递结构
  TJ08InspectResultRec = Record
  Public
    constructor Create(ASubId: Integer; a: Double);
  Public
    SubId: Integer;
    case Integer of
      1: (dBmLevel: Double);
      2: (ScandbmLevel: Double);
      3, 4: (Depth: Double);
      5: (AMFreqOffsetHz: Double);
  end;
const
  CONST_STR_DEPTHAM_AF : Array [0..1] of AnsiString = ('1000Hz', '400Hz');

  CONST_STR_DEPTHAM_CF : Array [0..1] of AnsiString = ('1MHz', '10MHz');
  CONST_AM_CF_MHZ: Array[0..1] of Byte = (1, 10);

  CONST_AM_DEPTH_PERCENT: Array[0..2] of Byte = (30, 60, 90);

  CONST_FM_DEPTH_KHZ: Array[0..2] of Byte = (25, 50, 75);
type
  TJ08MeasureType = (mtUndefined,  mtPre, mtAMLevel, mtAMFreRsponInBand, mtFMLevel, mtFMFreRsponInBand,
                      mtAMScan, mtFMScan, mtFMModul, mtWriteFlash, mtInspect);
const
  CONST_STR_MEASURETYPE: Array[Low(TJ08MeasureType)..High(TJ08MeasureType)] of Ansistring = (
  '未定义', '预测', 'AM电平校准', 'AM段内频响', 'FM电平校准', 'FM段内频响', 'AM扫频', 'FM扫频', 'FM调制度(频偏)', 'Flash写入',
  '自动测试');



var
  g_GlobalFuncSel: Set of TAppGlobalFuncSel;
  g_IniTemplateFileName: AnsiString;

function g_CubicEquationHtml(const ACoeff: TDoubleDynArray): AnsiString;


implementation
uses
  SysUtils, PlumUtils;



function g_CubicEquationHtml(const ACoeff: TDoubleDynArray): AnsiString;
const
  const_fmtstr_FormualFormat: AnsiString = '<P align="right">Y=<FONT  color = "#FF0000">%s</FONT>X<SUP>3</SUP>+'+
                                          '<FONT  color = "#FF0000">%s</FONT>X<SUP>2</SUP>+'+
                                          '<FONT  color = "#FF0000">%s</FONT>X+'+
                                          '<FONT  color = "#FF0000">%s</FONT></P>';

  const_fmtstr_coeff: AnsiString = '#.####E+00';

begin
    Result:= Format(const_fmtstr_FormualFormat,[
      FormatFloat(const_fmtstr_coeff, ACoeff[0]),
      FormatFloat(const_fmtstr_coeff, ACoeff[1]),
      FormatFloat(const_fmtstr_coeff, ACoeff[2]),
      FormatFloat(const_fmtstr_coeff, ACoeff[3]),
      FormatFloat(const_fmtstr_coeff, ACoeff[4])
    ]);
end;




{ TJ08InspectMeasure.TJ08InspectResultRec }

constructor TJ08InspectResultRec.Create(ASubId: Integer; a: Double);
begin
  SubId:= ASubId;
  case ASubId of
    1:
    begin
      dBmLevel:= a;
    end;
    2:
    begin
      ScandbmLevel:= a;
    end;
    3, 4:
    begin
      Depth:= a;
    end;
    5:
    begin
      AMFreqOffsetHz:= a;
    end;
  end;
end;
//var
//  x: String;
initialization
//
//  if PlumUtils.FindCmdLineSwitch('Plugin', x, ['-', '/', '\'], True) then
//  begin
//    OutputDebugString(PChar(x));
//  end;
//  OutputDebugString(PChar(Format('%s', [GetModuleName(FindHInstance(Pointer(@g_CubicEquationHtml)))])));
//  OutputDebugString(PChar(Format('%s', [GetModuleName(FindHInstance(0))])));
//  OutputDebugString(PChar(Format('%s', [GetModuleName(HInstance)])));





end.
