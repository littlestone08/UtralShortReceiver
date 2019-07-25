unit BT_WeakGlobal;

interface
uses
  Windows, SysUtils, Messages;
const
  BTM_PROC_SUMMARY_UPDATE   = WM_USER + 1;
  BTM_TASK_UPDATE           = WM_USER + 2;
  BTM_TASK_REDRAW_BMPHINT   = WM_USER + 3;
  BTM_TASK_LOG              = WM_USER + 4;  //WPARAM: PChar
  BTM_DEV_LOG               = WM_USER + 5;  //WPARAM: PChar
  BTM_DEV_PROGRESS          = WM_USER + 6;

  BTM_CUSTOM               = WM_USER + 30;
const
  const_1tb = Char(VK_TAB);
  const_2tb = Char(VK_TAB) + Char(VK_TAB);
  const_3tb = Char(VK_TAB) + Char(VK_TAB) + Char(VK_TAB);
  const_4tb = Char(VK_TAB) + Char(VK_TAB) + Char(VK_TAB) + Char(VK_TAB);
var
  S_BTNCAPTION_ADDNEW: String = '     添加';
  S_BTNCAPTION_CLRALL: String = '     清空';
  S_BTNCAPTION_START: String = '开始';
  S_BTNCAPTION_STOP: String = '停止';
  S_CapCn: String = '自动测试模板';
  S_CapEn: String = 'Auto Calibrate Templated';

Procedure g_SetTaskStartTick;
function g_LogBasePath: AnsiString;


implementation
var
  g_var_TaskStartTick: TDateTime;


Procedure g_SetTaskStartTick;
begin
  g_var_TaskStartTick:= Now();
end;


function g_LogBasePath: AnsiString;
begin
  Result:= ExtractFilePath(ParamStr(0)) + 'Log\'
    + FormatDateTime('YYYYMMDDHHNNSS', g_var_TaskStartTick)+ '\';
  ForceDirectories(Result);
end;


end.
