unit PlumUtils;

interface
uses
  {$IFDEF WIN32}windows, {$ENDIF}Classes, SysUtils;
  function Buf2Hex(ABuf: AnsiString): Ansistring;
  Procedure RetrieveSerialPorts(const PortNameList: TStrings);
  function Cardinal2BCD(Value: Cardinal): AnsiString;
  {$IFDEF WIN32}
  procedure WaitMS(milliseconds: Cardinal);
  function SerialPortIsFree(const PortName: AnsiString): Boolean;
    {$ENDIF}
  function CalcByteSum(const AData: AnsiString): DWORD;
//  function FindCmdLineSwitch(const Switch: string; const Chars: TSysCharSet;
//                              IgnoreCase: Boolean): Boolean; Overload;
  function FindCmdLineSwitch(const AName: string; var AValue: String;
                            const Chars: TSysCharSet;
                            IgnoreCase: Boolean): Boolean; Overload;
  function PatchSerialPortName(const APortName: String): String;
  {$IFDEF WIN32}
  function IsControlEndScroll(AWindow: HWND): Boolean;
  {$ENDIF}
  function FileContextMenu(AFileExts: TStrings; MenuCaption: String; ACommand: String; IsAdd: Boolean): Boolean;
implementation
uses
  StrUtils, Registry, Forms;

function Cardinal2BCD(Value: Cardinal): AnsiString;
var
  Quotient: Cardinal;
  Residual: Cardinal;
  L_Temp: AnsiString;
  i: Integer;
begin
  L_Temp:= '';
  Result:= '';
  Quotient:= Value;
  while Quotient > 0 do
  begin
    Residual:= Quotient mod 10;
    Quotient:= Quotient div 10;
    L_Temp:=  AnsiChar(Residual) + L_Temp;
  end;
  if Length(L_Temp) mod 2 <> 0 then
  begin
    L_Temp:= #0 + L_Temp
  end;

  SetLength(Result, Length(L_Temp) div 2);
  for i := 1 to Length(L_Temp) div 2 do
  begin
    Result[i]:= AnsiChar((Byte(L_Temp[(i * 2 - 1)]) shl 4) or
      Byte(L_Temp[i * 2]));
  end;
end;

Procedure RetrieveSerialPorts(const PortNameList: TStrings);
var
  Names: TStrings;
  i: Integer;
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  Names:= TStringList.Create;
  try
    Reg.RootKey:= HKEY_LOCAL_MACHINE;
    Reg.OpenKey('HARDWARE\DEVICEMAP\SERIALCOMM',  False);
    Reg.GetValueNames(Names);
    for i := 0 to Names.Count - 1 do
      PortNameList.Add(Reg.ReadString(Names[i]));
  finally
    Names.Free;
    Reg.Free;
  end;
end;

function Buf2Hex(ABuf: AnsiString): Ansistring;
var
  L_Len: Integer;
  L_Compact: AnsiString;
  i: Integer;
begin
  Result:= '';

  L_Len:= Length(ABuf);
  if L_Len > 0 then
  begin
    SetLength(L_Compact, L_Len * 2);
    BinToHex(PAnsiChar(ABuf), PAnsiChar(L_Compact), L_Len);

    Result:= L_Compact[1];
    for i := 2 to Length(L_Compact) do
    begin
      if Odd(i) then
        Result:= Result + ' ';
      Result:= Result + L_Compact[i];
    end;
  end;
end;
{$IFDEF WIN32}
procedure WaitMS(milliseconds: Cardinal);
var
  L_Tick: Cardinal;
begin
  L_Tick:= GetTickCount;
  while GetTickCount() - L_Tick < milliseconds do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;
end;

function SerialPortIsFree(const PortName: AnsiString): Boolean;
var
  hNewCommFile: THandle;
begin
  Result:= False;
   hNewCommFile := CreateFile( PChar(PatchSerialPortName(PortName)),
                               GENERIC_READ or GENERIC_WRITE,
                               0, {not shared}
                               nil, {no security ??}
                               OPEN_EXISTING,
                               FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED,
                               0 {template} );
  if hNewCommFile <> INVALID_HANDLE_VALUE then
  begin
    Result:= True;
    CloseHandle( hNewCommFile );
  end;
end;
{$ENDIF}

function CalcByteSum(const AData: AnsiString): DWORD;
var
  i: Integer;
begin
  Result:= 0;
  for I := 1 to Length(AData) do
  begin
    Result:= Result + Byte(AData[i]);
  end;
end;

//function FindCmdLineSwitch(const Switch: string; const Chars: TSysCharSet;
//  IgnoreCase: Boolean): Boolean;
//var
//  I: Integer;
//  S: string;
//begin
//  for I := 1 to ParamCount do
//  begin
//    S := ParamStr(I);
//    if (Chars = []) or (S[1] in Chars) then
//      if IgnoreCase then
//      begin
//        if (AnsiCompareText(Copy(S, 2, Maxint), Switch) = 0) then
//        begin
//          Result := True;
//          Exit;
//        end;
//      end
//      else begin
//        if (AnsiCompareStr(Copy(S, 2, Maxint), Switch) = 0) then
//        begin
//          Result := True;
//          Exit;
//        end;
//      end;
//  end;
//  Result := False;
//end;

function FindCmdLineSwitch(const AName: string; var AValue: String; const Chars: TSysCharSet;
  IgnoreCase: Boolean): Boolean;
var
  I: Integer;
  S: string;
begin
  Result := False;
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if (Chars = []) or (S[1] in Chars) then
      if IgnoreCase then
      begin
        if AnsiStartsText(AName + ':', Copy(S, 2, Maxint)) then
        begin
          AValue:= Copy(S, 3+ Length(AName), Maxint);
          Result := True;
          Break;
        end;
      end
      else begin
        if AnsiStartsStr(AName + ':', Copy(S, 2, Maxint)) then
        begin
          AValue:= Copy(S, 3+ Length(AName), Maxint);
          Result := True;
          Break;
        end;
      end;
  end;

end;

function PatchSerialPortName(const APortName: String): String;
begin
  if Not AnsiStartsText('//./', APortName) then
    Result:= '//./' + APortName
  else
    Result:=  APortName;
end;
{$IFDEF WIN32}
function IsControlEndScroll(AWindow: HWND): Boolean;
var
  si: TScrollInfo;
begin
  Result:= False;
  si.cbSize:= SizeOf(si);
  si.fMask:= SIF_ALL;
  if GetScrollInfo(AWindow, SB_VERT, si) then
    Result:= SI.nPos + SI.nPage = SI.nmax + 1;
end;
{$ENDIF}

function FileContextMenu(AFileExts: TStrings; MenuCaption: String; ACommand: String; IsAdd: Boolean): Boolean;
var
  i: Integer;
  L_Reg: TRegistry;
  L_List: TStrings;
  L_Keys: TStringList;
  L_Reg2: TRegistry;
begin
  Result:= False;
  if AFileExts = Nil then Exit;

  L_List:= TStringList.Create;

  L_Keys:= TStringList.Create;
  L_Keys.CaseSensitive:= False;
  L_Keys.Duplicates:= dupIgnore;

  try

    L_Reg:= TRegistry.Create;
    try
      L_Reg.RootKey:= HKEY_CLASSES_ROOT;
      for i := 0 to AFileExts.Count - 1 do
      begin
        if L_Reg.OpenKeyReadOnly(AFileExts[i]) then
        begin
          L_Reg.GetValueNames(L_List);
          L_Keys.Add(L_Reg.ReadString(''));
          L_Reg.CloseKey;
        end;
                  //OutputDebugString(PChar(L_List.Text));
      end;
      for i := 0 to L_Keys.Count - 1 do
      begin
        if IsAdd then
        begin
          if L_Reg.OpenKey(L_Keys[i]+ '\shell\' + MenuCaption + '\Command', True) then
          begin
            L_Reg2:= TRegistry.Create;
            try
              L_Reg2.RootKey:= HKEY_CLASSES_ROOT;
              if L_Reg2.OpenKey(L_Keys[i]+ '\shell\' + MenuCaption + '\Command', False) then
              begin
                L_Reg2.WriteString('', ACommand);
                L_Reg2.CloseKey;
              end;
            finally
              L_Reg2.Free;
              L_Reg.CloseKey;
            end;
          end;
        end
        else
        begin
          L_Reg.DeleteKey(L_Keys[i]+ '\shell\' + MenuCaption);
        end;
      end;
    finally
      L_Reg.Free;
    end;
  finally
    L_Keys.Free;
    L_List.Free;
  end;
end;
end.
