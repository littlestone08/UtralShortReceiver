unit u_J16Utils;

interface
uses
  SysUtils, Types, Windows;


type
  TFloatPoint = Record
    X, Y, WishY: Double;
    Constructor Create(AX, AY, AWishY: double);
  End;
//  TFloatLine = Record
//    PtA, PtB: TFloatPoint;
//    Constructor Create(X, Y: double);
//  End;


  Procedure CalcuSlopeCoff(const PointA: TFloatPoint; const PointB: TFloatPoint;
    var PrimaryCoeff: Double; var ConstantTerm: Double);
implementation

  Procedure CalcuSlopeCoff(const PointA: TFloatPoint; const PointB: TFloatPoint;
    var PrimaryCoeff: Double; var ConstantTerm: Double);
  begin
    PrimaryCoeff:= 9.2/((PointA.Y - PointB.Y) / (PointA.X - Pointb.X));
    //ConstantTerm:= PointA.WishY - PrimaryCoeff * PointA.Y;
    ConstantTerm:= PointB.WishY - PrimaryCoeff * PointB.Y;
  end;

{ TFloatLine }


{ TFloatPoint }

constructor TFloatPoint.Create(AX, AY, AWishY: double);
begin
  X:= AX;
  Y:= AY;
  WishY:= AWishY;
end;

var
  a, b: Double;
initialization
  CalcuSlopeCoff(TFloatPoint.Create(-10, -85, -60), TFloatPoint.Create(-30, -275, -244), a, b);
  OutputDebugString(PAnsiChar(Format('%5f, %5f', [a, b])));
  OutputDebugString(PAnsiChar(Format('%5f', [a * -85 + b])));
end.
