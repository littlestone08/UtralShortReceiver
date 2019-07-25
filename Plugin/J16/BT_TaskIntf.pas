unit BT_TaskIntf;

interface
uses
  Classes, Contnrs, Types, SysUtils;

type
  TMeasureIden = type Integer;

  TBTTaskStatus = (tsReady, tsRunning, tsFinished, tsStoped);
//  TBTIden = AnsiString;
  TBTProcStatus = (psSucc, psFailDueToError, psDueToTimeout);


  TBTProcUIHint = Record
    MeasureIndex  : Integer;
    MeasureProcCode  : Integer;
    ProcResult: TBTProcStatus;
    Info  : AnsiString;
  End;

  PBTDevItemUIHint = ^TBTDevItemUIHint;
  TBTDevItemUIHint = Record
    Curr,
    Last: TBTProcUIHint;
  End;


type


  IDevCtrl = Interface
    ['{A41BD88B-C6AD-4C4A-86AD-E9B6D7916544}']
    Procedure StartPort;
    Procedure StopPort;    
  End;



  TBTInitInfo = type Pointer;
  IBTDevItem = Interface
    ['{808D4D00-A2B3-44E1-B09D-FE42C35E75B2}']
    function get_ProcSummary: PBTDevItemUIHint;
    function get_InitInfo: TBTInitInfo;
//    function get_ExecuteCount: Integer;
//    Procedure set_ExecuteCount(const Value: Integer);
    function get_Executing: Boolean;
    function get_BProcStore: TObject;
    function get_DevCtrl: IDevCtrl;
    function get_LogFile: TFileName;

    function ThreadExecuteBProc(const AProc: TObject): Boolean;

    Procedure ResetLog;
    Procedure LogDebug(Info: AnsiString);

    Property ProcSummary: PBTDevItemUIHint Read get_ProcSummary;
    Property InitInfo: TBTInitInfo Read get_InitInfo;
//    Property ExecutedCount: Integer Read get_ExecuteCount Write set_ExecuteCount;
    Property Executing: Boolean Read get_Executing;
    Property BProcStore: TObject Read get_BProcStore;
    Property DevCtrl: IDevCtrl Read get_DevCtrl;
    Property LogFile: TFileName Read get_LogFile;

  End;

  IBTProgress = Interface
    ['{1C56D84C-6160-4C77-89BC-236FACD32816}']
    function get_ProgressNumerator: Cardinal;
//    Procedure set_ProgressNumerator(Value: Cardinal);
    function get_ProgressDenominator: Cardinal;
//    Procedure set_ProgresDenominator(Value: Cardinal);
    Procedure IncNumerator;
    Procedure ResetNumerator;
    Property Numerator: Cardinal Read get_ProgressNumerator;// Write set_ProgressNumerator;
    Property Denominator: Cardinal Read get_ProgressDenominator;// Write set_ProgresDenominator;
  End;


  //任务接口用来控制协调所有工作的进行。
  IBTTask = Interface
  ['{2FD5A1A9-1F92-4F34-A4B0-02F1F92467DD}']
    function get_WorkItemUIList: TComponentList;
    function get_Status: TBTTaskStatus;
    function get_HasValidDevice: Boolean;
    function get_WishCatchEInterruptByUser: Boolean;
    Procedure Start;
    Procedure Stop;
    Procedure LogDebug(Info: AnsiString);
    Procedure _AllDevExecuteBProcAndWait(ACustomMeasureProc: TObject{TBTCustomMeasureProc});
    Procedure _SingleDevExecuteBProcAndWait(ACustomMeasureProc: TObject{TBTCustomMeasureProc}; ADevice: IBTDevItem);
    Procedure GetProgress(var ANumerator, ADenominator: Cardinal);
    Property TestItemUIList: TComponentList Read get_WorkItemUIList;
    Property HasValidDevice: Boolean Read get_HasValidDevice;
    Property Status: TBTTaskStatus Read get_Status;
    Property WishCatchEInterruptByUser: Boolean Read get_WishCatchEInterruptByUser;
  End;

  ISaveData2XLS = Interface
    ['{D779ED9A-443B-4D80-853A-27C063CD447E}']
    Procedure Save;
  End;

  ISaveData2XLS2 = Interface
    ['{9356D930-BE13-4E38-9FB3-4932ECBFD39C}']
    Procedure Save(const ATag: Integer);
  End;


  TBTInitInfoHelperClass = Class of TBTInitInfoHelper;
  TBTInitInfoHelper = Class
    function UniqueDesc(const AInitInfo: TBTInitInfo): String; virtual; abstract;
    Procedure Clone(const AFrom: TBTInitInfo; var ADest: TBTInitInfo; AllowMem: Boolean = False); virtual; abstract;
    function PortName(const AInitInfo: TBTInitInfo): String; virtual; abstract;
    function SerialCode(const AInitInfo: TBTInitInfo): String; virtual; abstract;
//    Procedure UpdateInfo(const APortName: String; const ASerialCode: String; var ADest: TBTInitInfo); virtual; abstract;
//    Procedure NewInfo(const APortName: String; const ASerialCode: String; var ADest: TBTInitInfo); virtual; abstract;
    Procedure DisposeInfo(var ADest: TBTInitInfo); virtual; abstract;
  end;

  TGetBTInitInfoHelperClassFunc = function:TBTInitInfoHelper;  
const
  CONST_STR_WORKSTATUS: Array [Low(TBTTaskStatus)..High(TBTTaskStatus)] of String =
    (' 准备就绪 ', ' 正在测试 ', ' 测试完成 ', ' 测试被中止 ');

  CONST_STR_WORKPROCRESULT: Array [Low(TBTProcStatus)..High(TBTProcStatus)] of String =
    ('成功', '出错失败', '超时失败');
implementation




end.

