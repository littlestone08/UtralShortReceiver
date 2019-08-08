unit u_J16Utils;

interface
uses
  SysUtils, Types, Windows;


type
  TSlopCoffRec = Record
    AX, AY, BX, BY, AYWish, BYWish: Double;
    PrimaryCoeff, ConstantTerm: double;
  End;
  TSlopCoffRecArray = Array of TSlopCoffRec;

  Procedure CalcuSlopeCoff(var Values: TSlopCoffRecArray; YXRatio: Double);
implementation


Procedure CalcuSlopeCoff(var Values: TSlopCoffRecArray; YXRatio: Double);
var
  i: integer;
begin
  for i := 0 to Length(Values) - 1 do
  begin
    With Values[i] do
    begin
      PrimaryCoeff:= YXRatio/((AY  - BY) / (AX - BX));
      ConstantTerm:= BYWish - PrimaryCoeff * BY;
    end;
  end;
end;

Procedure Test_CalcuSlopeCoff();
var
  Values: TSlopCoffRecArray;
begin
  SetLength(Values, 3);
  Values[0].AX:= -10;
  Values[0].AY:= -85;
  Values[0].AYWish:= -60;

  Values[0].BX:= -30;
  Values[0].BY:= -275;
  Values[0].BYWish:= -244;

  Values[1].AX:= -30;
  Values[1].AY:= -38;
  Values[1].AYWish:= -244;

  Values[1].BX:= -60;
  Values[1].BY:= -319;
  Values[1].BYWish:= -520;

  Values[2].AX:= -60;
  Values[2].AY:= -102;
  Values[2].AYWish:= -244;

  Values[2].BX:= -90;
  Values[2].BY:= -385;
  Values[2].BYWish:= -796;

  CalcuSlopeCoff(Values, 9.2);
  OutputDebugString(PAnsiChar(Format('%.5f', [Values[2].PrimaryCoeff * -385 +Values[2].ConstantTerm])));
end;

initialization


end.
