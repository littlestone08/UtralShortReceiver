unit u_FreqCtrl;

interface

type
  IOuterFreq = interface
    ['{02E8A8EA-CE29-4F7E-80ED-18D4BE8CA1E5}']
    function get_Frequency: String;
    procedure set_Frequency(const Value: String);
    Property Frequency: String Read get_Frequency Write set_Frequency;
  end;


  TOuterFreq = Class(TInterfacedObject, IOuterFreq)
  Protected
    function get_Frequency: String;
    procedure set_Frequency(const Value: String);
  End;
implementation

{ TOuterFreq }

function TOuterFreq.get_Frequency: String;
begin

end;

procedure TOuterFreq.set_Frequency(const Value: String);
begin

end;

end.
