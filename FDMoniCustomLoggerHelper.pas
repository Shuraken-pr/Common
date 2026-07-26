unit FDMoniCustomLoggerHelper;

interface

uses System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Vcl.Forms,
  FireDAC.Comp.Client, FireDAC.Moni.Base, FireDAC.Moni.Custom.Logger;

type
  TFDMoniCustomLogger = class(TFDMoniCustomClientLink)
  private
    procedure FDMonitorOutput(ASender: TFDMoniClientLinkBase; const AClassName,
      AObjName, AMessage: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetConnection(AConnection: TFDConnection);
  end;

procedure SendMonitorMessage(const s: string);

implementation

uses FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Phys, Data.DB, System.Variants;

procedure SendMonitorMessage(const s: string);
var
  CopyData: TCopyDataStruct;
  MonitorHandle: THandle;
  Utf8Data: UTF8String;
begin
  MonitorHandle := FindWindow(PChar('TfrmSQLLogger'),
                               PChar('SQL Logger'));
  if MonitorHandle = 0 then
    Exit;

  Utf8Data := UTF8String(s);

  // Заполняем структуру
  CopyData.dwData := 1;
  CopyData.cbData := Length(Utf8Data);
  CopyData.lpData := PAnsiChar(Utf8Data);

  // данные копируются
  SendMessage(MonitorHandle, WM_COPYDATA, WPARAM(0), LPARAM(@CopyData));
end;


{ TFDMoniCustomLogger }

constructor TFDMoniCustomLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.OnOutput := FDMonitorOutput;
end;

procedure TFDMoniCustomLogger.SetConnection(AConnection: TFDConnection);
begin
  if Assigned(AConnection) then
  begin
    AConnection.Params.MonitorBy := mbCustom;
    Self.Tracing := true;
    Self.EventKinds := [ekCmdExecute, ekSQL];
  end;
end;

type
  THackFDPhysCommand = class(TFDPhysCommand);

function GetFDParamsStr(const AParams: TFDParams): string;
var
  p: TFDParam;
  paramName, paramValue: string;
  isNull: boolean;

  procedure SetParamValue(const useQuotedStr: boolean = false; AValue: string = '');
  begin
    if isNull then
      paramValue := 'NULL'
    else if (AValue <> '') then
      paramValue := AValue
    else begin
      if useQuotedStr then
        paramValue := QuotedStr(p.AsString)
      else
        paramValue := p.AsString;
    end;
  end;

begin
  Result := '';
  if AParams.Count > 0 then
  begin
    for var i := 0 to AParams.Count - 1 do
    begin
      p := TFDParam(AParams[i]);
      paramName := '';
      paramValue := '';
      isNull := VarIsNull(p.Value);
      case p.DataType of
        ftString,
        ftWideString:
          begin
            paramName := 'text';
            SetParamValue(true);
          end;
        ftSmallint,
        ftWord:
          begin
            paramName := 'smallint';
            SetParamValue;
          end;
        ftInteger:
          begin
            paramName := 'integer';
            SetParamValue;
          end;
        ftBoolean:
          begin
            paramName := 'boolean';
            SetParamValue(false, BoolToStr(p.AsBoolean, true));
          end;
        ftFloat:
          begin
            paramName := 'double';
            SetParamValue;
          end;
        ftCurrency:
          begin
            paramName := 'numeric(18,4)';
            SetParamValue(false, FormatFloat('0.0000', p.AsFloat))
          end;
        ftDate:
          begin
            paramName := 'date';
            SetParamValue(false, QuotedStr(FormatDateTime('yyyy-mm-dd', p.AsDateTime)));
          end;
        ftTime:
          begin
            paramName := 'time';
            SetParamValue(false, QuotedStr(FormatDateTime('hh:nn:ss', p.AsDateTime)));
          end;
        ftDateTime,
        ftTimeStamp:
          begin
            paramName := 'timestamp';
            SetParamValue(false, QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', p.AsDateTime)));
          end;
        ftLargeint:
          begin
            paramName := 'bigint';
            SetParamValue;
          end;
      end;
      if paramName <> '' then
      begin
        if Result = '' then
          Result := 'declare' + #13#10 + Format('%s %s := %s', [p.Name, paramName, ParamValue])
        else
          Result := Result + ', '#13#10 + Format('%s %s := %s', [p.Name, paramName, ParamValue]);
      end
    end;
  end;
  if Result <> '' then
    Result := '/*' + Result + ';*/' + #13#10#13#10;
end;

procedure TFDMoniCustomLogger.FDMonitorOutput(ASender: TFDMoniClientLinkBase;
  const AClassName, AObjName, AMessage: string);
var
  obj: TObject;
  AppName, ObjName, Msg, ParamStr: string;
  cmd: THackFDPhysCommand;
begin
  cmd := nil;
  AppName := ExtractFileName(Application.ExeName);
  ObjName := AObjName;
  if AMessage.Contains('>> Open') or AMessage.Contains('>> Execute') then
  begin
    msg := AMessage;
    obj := TFDMoniCustomClient(Self.CClient).CurSender;
    if Assigned(obj) and (obj is TFDPhysCommand) then
      cmd := THackFDPhysCommand(obj);

    if Assigned(cmd) then
    begin
      ParamStr := '';
      msg := GetFDParamsStr(cmd.GetParams) + cmd.GetCommandText;
      SendMonitorMessage(ObjName + '~' + AppName + '~' + msg);
    end;
  end;
end;


end.
