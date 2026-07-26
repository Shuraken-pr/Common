unit FDMoniCustomLoggerHelper;

interface

uses System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Vcl.Forms,
  FireDAC.Comp.Client, FireDAC.Moni.Base, FireDAC.Moni.Custom.Logger;

type
  TFDMoniCustomLogger = class(TFDMoniCustomClientLink)
  private
    FConType: integer;
    procedure FDMonitorOutput(ASender: TFDMoniClientLinkBase; const AClassName,
      AObjName, AMessage: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetConnection(AConnection: TFDConnection);
  end;

procedure SendMonitorMessage(const s: string);

implementation

uses FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Phys, Data.DB, System.Variants, strUtils;

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
  FConType := 0;
  Self.OnOutput := FDMonitorOutput;
end;

procedure TFDMoniCustomLogger.SetConnection(AConnection: TFDConnection);
begin
  if Assigned(AConnection) then
  begin
    if AConnection.Params.DriverID = 'Ora' then
      FConType := 1
    else if AConnection.Params.DriverID = 'MSSQL' then
      FConType := 2;
    AConnection.Params.MonitorBy := mbCustom;
    Self.Tracing := true;
    Self.EventKinds := [ekCmdExecute, ekSQL];
  end;
end;

type
  THackFDPhysCommand = class(TFDPhysCommand);

function GetMSSQLFDParamsStr(const AParams: TFDParams): string;
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
            paramName := 'nvarchar';
            if p.Size < 4000 then
              paramName := paramName + '(' + IntToStr(p.Size) + ')'
            else
              paramName := paramName + '(max)';
            SetParamValue(true);
          end;
        ftSmallint,
        ftWord,
        ftInteger:
          begin
            paramName := 'int';
            SetParamValue;
          end;
        ftBoolean:
          begin
            paramName := 'bit';
            SetParamValue(false, BoolToStr(p.AsBoolean));
          end;
        ftFloat,
        ftFMTBcd,
        ftCurrency:
          begin
            paramName := 'numeric(18,4)';
            SetParamValue(false, FormatFloat('0.0000', p.AsFloat))
          end;
        ftDateTime:
          begin
            paramName := 'datetime';
            SetParamValue(false, 'convert(datetime, ' +
            QuotedStr(FormatDateTime('dd.mm.yyyy hh:nn:ss', p.AsDateTime) + ', 104)'));
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
    Result := Result + #13#10#13#10;
end;

function GetPGMSG(const AParams: TFDParams; const AMsg: string): string;
var
  i: integer;
  p: TFDParam;
  paramValue: string;
begin
  Result := AMsg;
  for i := 0 to AParams.Count - 1 do
  begin
    p := TFDParam(AParams[i]);
    if p.ParamType in [ptInput, ptUnknown] then
    begin
      if not p.IsNull then
      begin
        if p.DataType in [ftString, ftWideString] then
          paramValue := QuotedStr(p.AsString)
        else if p.DataType in [ftDate, ftDateTime, ftTimeStamp] then
          paramValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', p.AsDateTime))
        else
          paramValue := p.AsString;
      end;
    end
      else
      paramValue := 'NULL';
    Result := AnsiReplaceText(Result, ':' + p.Name, paramValue)
  end;
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
      ParamStr := cmd.GetCommandText;
      if paramStr <> '' then
      begin
        case FConType of
          0: msg := GetPGMSG(cmd.GetParams, ParamStr);
          2: msg := GetMSSQLFDParamsStr(cmd.GetParams) + ParamStr;
        end;
        SendMonitorMessage(ObjName + '~' + AppName + '~' + msg);
      end;
    end;
  end;
end;


end.
