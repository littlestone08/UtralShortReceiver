unit u_CommonDef;

interface
uses
  Classes;
type
  TExamineMode = (emSingle, emBatch);
  TExamineStatus = (esReady, esWait, esExecute, esComplete);
  
  IExamineItem = Interface;


  //===================================
  IExamineItemUI = Interface
  ['{E0847D71-7731-48A8-BF5E-A59E37626696}']
    function get_ExamineItem: IExamineItem;
    Procedure set_ExamineItem(const Value: IExamineItem);
    Procedure set_Percent(const Value: Single);
    function get_Enabled(): Boolean;
    Procedure set_Enabled(const Value: Boolean);

    function get_ButtonCaption: String;
    Procedure set_ButtonCaption(const Value: String);

    function get_ButtonEnabled: Boolean;
    Procedure set_ButtonEnabled(const Value: Boolean);

    Procedure SetEnableRecursion(const Value: Boolean);

    Procedure SyncUI(Ptr: Pointer);
    Property ExamineItem: IExamineItem Read get_ExamineItem Write set_ExamineItem;
    Property Enabled: Boolean Read get_Enabled Write set_Enabled;
    Property ButtonCaption: String Read get_ButtonCaption Write set_ButtonCaption;
    Property ButtonEnabled: Boolean Read get_ButtonEnabled Write set_ButtonEnabled;
  End;
  
  IChannelUI = interface
    ['{9BE12CDA-126B-4CB9-8DF2-C0A24FD918AE}']
    function get_EnvIndex: Integer;
    Property EnvIndex: Integer Read get_EnvIndex;
  end;


  IExamineItem = Interface
  //实现时需要负责销毁掉UI界面
  ['{9D4D91F5-2D94-46EA-8266-A9268F090FD2}']
    Procedure Start();
    Procedure Stop();

    function get_Status: TExamineStatus;
    Procedure Set_Status(const Value: TExamineStatus);
    function get_UI: IExamineItemUI;
    Procedure set_UI(const Value: IExamineItemUI);

    function get_InlineInsertLost: Double;
    Procedure set_InlineInsertLost(const Value: double);
    function get_ExamineCaption: String;
    Procedure set_ExamineCaption(const Value: String);

    function get_ManageList: TInterfaceList;
    Procedure set_ManageList(const Value: TInterfaceList);


    Procedure RecallStatus; //恢复状态，仅在等待状态中可以调用
    Procedure SetAll_Status(Value: TExamineStatus;  const ExceptItem: IExamineItem);
    Procedure RecallAll_FromWaiting(const ExceptItem: IExamineItem);
    Procedure SetAll_Enable(Value: Boolean; const ExceptItem: IExamineItem; Recursion: Boolean);
    Procedure CheckWishStop(Delay: Integer = 2);
    //============================


    Property Status: TExamineStatus Read get_Status Write Set_Status;
    Property UI: IExamineItemUI Read get_UI Write set_UI;
    Property InlineInsertLost: Double read get_InlineInsertLost write set_InlineInsertLost;
    Property ExamineCaption: String read get_ExamineCaption write set_ExamineCaption;
    Property ManageList: TInterfaceList Read get_ManageList Write set_ManageList;

  End;



implementation

end.
