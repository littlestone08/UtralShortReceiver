unit u_frmParallelIOTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmPalla = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(AOwner: TComponent); Override;
  end;

var
  frmPalla: TfrmPalla;

implementation

{$R *.dfm}

{ TfrmPalla }

procedure TfrmPalla.Button1Click(Sender: TObject);
var
  Value: Integer;
  Port: Cardinal;
begin
  Value:= StrToIntDef(Edit1.Text, 0);
  Port:= StrToIntDef(Edit2.Text, 0);
  Edit1.Text:= '$' + IntToHex(Value, 2);
  //FIntf.TranByte(Value);
  //FIntf.Out32($378, Value);
  FIntf.Out32(Port, Value);

end;

procedure TfrmPalla.Button2Click(Sender: TObject);
var
  Value: Integer;
  Port: Cardinal;
begin
  Port:= StrToIntDef(Edit2.Text, 0);
  Value:= FIntf.Inp32(Port);
  Edit1.Text:= '$' + IntToHex(Value, 2)
end;

constructor TfrmPalla.Create(AOwner: TComponent);
begin
  inherited;
  FIntf:= TIOProxy.Create;
  //FIntf.OpenPort('LPT1');
end;

end.
