unit u_frameExamineList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, u_CommonDef, StdCtrls, u_frameExamineItemUI,
  u_frameExamineItemUIBase;

type

  TframeExamineList = class(TFrame)
    GridPanel1: TGridPanel;
    ScrollBox1: TScrollBox;
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
    FList: TInterfaceList;
    function GetItems(Index: Integer): IExamineItem;
    function GetCount: Integer;
  public
    { Public declarations }
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    function  Add(AExamineItem: IExamineItem; AExamineItemUI: TFrameCustomExamineItemUI): IExamineItem;
//    Procedure Delete(const AExamineItem: IExamineItem);
    Procedure RecalcuSize;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: IExamineItem read GetItems;
    Property List: TInterfaceList Read FList;
  end;

implementation
uses
  CnDebug, TypInfo, Types;


{$R *.dfm}

{ TframeExamineList }

function TframeExamineList.Add(AExamineItem: IExamineItem; AExamineItemUI: TFrameCustomExamineItemUI): IExamineItem;
//var
//  AControl: TExamineItemDefaultControl;
begin
  Result:= AExamineItem;

//  AControl:= TExamineItemDefaultControl.Create(GridPanel1);
  AExamineItemUI.Name:= AExamineItemUI.Name + IntToStr(FList.Count);
  AExamineItemUI.Parent:= GridPanel1;
  AExamineItemUI.Align:= alTop;


  Result.UI:= AExamineItemUI;
  (AExamineItemUI as IExamineItemUI).ExamineItem:= Result;
  
  FList.Add(Result);
  Result.ManageList:= FList;
end;

constructor TframeExamineList.Create(AOwner: TComponent);
begin
  inherited;
  FList:= TInterfaceList.Create;

//  GridPanel1.Tag:= -2;
//  GridPanel1.InsertControl();
end;

//procedure TframeExamineList.Delete(const AExamineItem: IExamineItem);
//begin
//  FList.Remove(AExamineItem);
//end;

destructor TframeExamineList.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TframeExamineList.FrameResize(Sender: TObject);
begin
  GridPanel1.Width:= ScrollBox1.Width - 10;
end;

function TframeExamineList.GetCount: Integer;
begin
  Result:= FList.Count;
end;

function TframeExamineList.GetItems(Index: Integer): IExamineItem;
begin
  Result:= IExamineItem(FList[Index]);
end;




procedure TframeExamineList.RecalcuSize;
var
  i: Integer;
  ABound: TRect;
begin
  FillChar(ABound, SizeOf(TRect), #0);
  for i := 0 to self.GridPanel1.ControlCount - 1 do
  begin
    Types.UnionRect(ABound, ABound, GridPanel1.Controls[i].BoundsRect);
//    CnDebugger.LogFmt('Top: %d', [GridPanel1.Controls[i].BoundsRect.Top]);
  end;
  GridPanel1.SetBounds(Left, Top, ABound.Right - ABound.Left, ABound.Bottom - ABound.Top + 1);
end;




end.
