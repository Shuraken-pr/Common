unit uDBConnectionSettings;

interface

uses
  System.SysUtils, System.Classes, System.NetEncoding, Xml.XmlIntf, Xml.XmlDoc,
  FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Phys.MSSQL, FireDAC.Phys.Oracle,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.Stan.Intf, FireDAC.Stan.Pool,
  System.Generics.Collections;

type
  TDBType = (dbPostgreSQL, dbMSSQL, dbOracle, dbUnknown);

const
  DefaultPorts: array[TDBType] of Integer = (5432, 1433, 1521, 0);
  DriverIDs: array[TDBType] of string = ('PG', 'MSSQL', 'Ora', '');

  SDefaultDBFileName = 'db_settings.xml';
  SDefaultPoolMaxItems = 10;
  SDefaultPoolTimeout = 5000;
  SDefaultConnectionTimeout = 5000;

type
  TDBConnectionSettings = class
  private
    FDBType: TDBType;
    FHost: string;
    FPort: Integer;
    FDatabase: string;
    FUsername: string;
    FPassword: string;
    FShowDBTypeSelector: Boolean;
    FPoolMaxItems: Integer;
    FPoolTimeout: Integer;
    FConnectionTimeout: Integer;
    FValues: TDictionary<string,string>;
    FShowPoolMaxItems: Boolean;
    FShowPoolTimeout: Boolean;
    function GetDriverID: string;
    procedure SetDBType(const Value: TDBType);
    function GetValue(const Name: string): string;
    procedure SetValue(const Name, Value: string);
  protected
    procedure ApplyParamsToDef(AParams: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(ASource: TDBConnectionSettings);

    procedure SaveToFile(const AFileName: string; AAdditionalParams: array of string);
    procedure LoadFromFile(const AFileName: string; AAdditionalParams: array of string);

    procedure ApplyToConnection(AConn: TFDConnection);
    procedure RegisterInManager(var AManager: TFDManager; const ADefName: string);

    function TestConnection(out AErrorMsg: string; ATimeout: Integer = SDefaultConnectionTimeout): Boolean;
    function IsValid(out AErrorMsg: string): Boolean;

    property DBType: TDBType read FDBType write SetDBType;
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property Database: string read FDatabase write FDatabase;
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
    property DriverID: string read GetDriverID;
    property ShowDBTypeSelector: Boolean read FShowDBTypeSelector write FShowDBTypeSelector;
    property ShowPoolMaxItems: Boolean read FShowPoolMaxItems write FShowPoolMaxItems;
    property ShowPoolTimeout: Boolean read FShowPoolTimeout write FShowPoolTimeout;
    property PoolMaxItems: Integer read FPoolMaxItems write FPoolMaxItems;
    property PoolTimeout: Integer read FPoolTimeout write FPoolTimeout;
    property ConnectionTimeout: Integer read FConnectionTimeout write FConnectionTimeout;
    property Values[const Name: string]: string read GetValue write SetValue;
  end;

implementation

uses
  System.IOUtils;

const
  SXMLRoot = 'db_connection_settings';
  SXMLDBType = 'db_type';
  SXMLHost = 'host';
  SXMLPort = 'port';
  SXMLDatabase = 'database';
  SXMLUsername = 'username';
  SXMLPassword = 'password';
  SXMLShowDbType = 'show_db_type_selector';
  SXMLPoolMaxItems = 'pool_max_items';
  SXMLPoolTimeout = 'pool_timeout';
  SXMLConnectionTimeout = 'connection_timeout';

{ ============================================================================ }
{                               Вспомогательные                                }
{ ============================================================================ }

function DBTypeToStr(ADBType: TDBType): string;
begin
  case ADBType of
    dbPostgreSQL: Result := 'dbPostgreSQL';
    dbMSSQL:      Result := 'dbMSSQL';
    dbOracle:     Result := 'dbOracle';
  else
    Result := 'dbUnknown';
  end;
end;

function StrToDBType(const S: string): TDBType;
begin
  if SameText(S, 'dbPostgreSQL') then
    Result := dbPostgreSQL
  else if SameText(S, 'dbMSSQL') then
    Result := dbMSSQL
  else if SameText(S, 'dbOracle') then
    Result := dbOracle
  else
    Result := dbUnknown;
end;

function EncodePassword(const APwd: string): string;
begin
  if APwd = '' then
    Result := ''
  else
    Result := TNetEncoding.Base64.Encode(APwd);
end;

function DecodePassword(const AEncoded: string): string;
begin
  if AEncoded = '' then
    Result := ''
  else
    Result := TNetEncoding.Base64.Decode(AEncoded);
end;

{ ============================================================================ }
{                           TDBConnectionSettings                              }
{ ============================================================================ }

constructor TDBConnectionSettings.Create;
begin
  inherited Create;
  FDBType := dbPostgreSQL;
  FHost := 'localhost';
  FPort := DefaultPorts[dbPostgreSQL];
  FDatabase := 'postgres';
  FUsername := '';
  FPassword := '';
  FShowDBTypeSelector := True;
  FShowPoolMaxItems := False;
  FShowPoolTimeout := False;
  FPoolMaxItems := SDefaultPoolMaxItems;
  FPoolTimeout := SDefaultPoolTimeout;
  FConnectionTimeout := SDefaultConnectionTimeout;
  FValues := TDictionary<string,string>.Create;
end;

destructor TDBConnectionSettings.Destroy;
begin
  FreeAndNil(FValues);
  inherited;
end;

procedure TDBConnectionSettings.Assign(ASource: TDBConnectionSettings);
begin
  if ASource = nil then
    Exit;
  FDBType := ASource.FDBType;
  FHost := ASource.FHost;
  FPort := ASource.FPort;
  FDatabase := ASource.FDatabase;
  FUsername := ASource.FUsername;
  FPassword := ASource.FPassword;
  FShowDBTypeSelector := ASource.FShowDBTypeSelector;
  FPoolMaxItems := ASource.FPoolMaxItems;
  FPoolTimeout := ASource.FPoolTimeout;
  FConnectionTimeout := ASource.FConnectionTimeout;
end;

function TDBConnectionSettings.GetDriverID: string;
begin
  Result := DriverIDs[FDBType];
end;

function TDBConnectionSettings.GetValue(const Name: string): string;
var
  value: string;
begin
  if FValues.TryGetValue(Name, value) then
    Result := value
  else
    Result := '';
end;

procedure TDBConnectionSettings.SetDBType(const Value: TDBType);
begin
  FDBType := Value;
  if FDBType <> dbUnknown then
    FPort := DefaultPorts[FDBType];
end;

procedure TDBConnectionSettings.SetValue(const Name, Value: string);
begin
  if FValues.ContainsKey(Name) then
    FValues.AddOrSetValue(Name, Value);
end;

{procedure TDBConnectionSettings.SetValue(const Value: string);
begin

end;

 ---------------------------------------------------------------------------- }
{                                  Валидация                                   }
{ ---------------------------------------------------------------------------- }

function TDBConnectionSettings.IsValid(out AErrorMsg: string): Boolean;
begin
  Result := False;
  AErrorMsg := '';

  if FDBType = dbUnknown then
  begin
    AErrorMsg := 'Не выбран тип базы данных.';
    Exit;
  end;

  if Trim(FHost) = '' then
  begin
    AErrorMsg := 'Адрес сервера не может быть пустым.';
    Exit;
  end;

  if (FPort <= 0) or (FPort > 65535) then
  begin
    AErrorMsg := 'Некорректный порт (1-65535).';
    Exit;
  end;

  if Trim(FDatabase) = '' then
  begin
    AErrorMsg := 'Имя базы данных не может быть пустым.';
    Exit;
  end;

  if Trim(FUsername) = '' then
  begin
    AErrorMsg := 'Имя пользователя не может быть пустым.';
    Exit;
  end;

  Result := True;
end;

{ ---------------------------------------------------------------------------- }
{                              Сериализация в XML                              }
{ ---------------------------------------------------------------------------- }

procedure TDBConnectionSettings.SaveToFile(const AFileName: string; AAdditionalParams: array of string);
var
  XMLDoc: IXMLDocument;
  RootNode: IXMLNode;
  Dir, key, value: string;
begin
  Dir := ExtractFilePath(AFileName);
  if (Dir <> '') and not TDirectory.Exists(Dir) then
    TDirectory.CreateDirectory(Dir);

  XMLDoc := NewXMLDocument;
  XMLDoc.Options := [doNodeAutoIndent];
  XMLDoc.Active := True;

  RootNode := XMLDoc.AddChild(SXMLRoot);

  RootNode.AddChild(SXMLDBType).Text := DBTypeToStr(FDBType);
  RootNode.AddChild(SXMLHost).Text := FHost;
  RootNode.AddChild(SXMLPort).Text := IntToStr(FPort);
  RootNode.AddChild(SXMLDatabase).Text := FDatabase;
  RootNode.AddChild(SXMLUsername).Text := FUsername;
  RootNode.AddChild(SXMLPassword).Text := EncodePassword(FPassword);
  RootNode.AddChild(SXMLShowDbType).Text := BoolToStr(FShowDBTypeSelector, True);
  RootNode.AddChild(SXMLPoolMaxItems).Text := IntToStr(FPoolMaxItems);
  RootNode.AddChild(SXMLPoolTimeout).Text := IntToStr(FPoolTimeout);
  RootNode.AddChild(SXMLConnectionTimeout).Text := IntToStr(FConnectionTimeout);
  for var i := Low(AAdditionalParams) to High(AAdditionalParams) do
  begin
    key := AAdditionalParams[i];
    if FValues.TryGetValue(key, value) then
      RootNode.AddChild(key).Text := value;
  end;

  XMLDoc.SaveToFile(AFileName);
end;

procedure TDBConnectionSettings.LoadFromFile(const AFileName: string; AAdditionalParams: array of string);
var
  XMLDoc: IXMLDocument;
  RootNode, Node: IXMLNode;
  key: string;
begin
  if not TFile.Exists(AFileName) then
    raise EFileNotFoundException.CreateFmt('Файл настроек не найден: %s', [AFileName]);

  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.LoadFromFile(AFileName);
    XMLDoc.Active := True;
    RootNode := XMLDoc.DocumentElement;

    if not SameText(RootNode.NodeName, SXMLRoot) then
      raise Exception.Create('Некорректный формат файла настроек.');

    Node := RootNode.ChildNodes.FindNode(SXMLDBType);
    if Assigned(Node) then
      FDBType := StrToDBType(Node.Text);

    Node := RootNode.ChildNodes.FindNode(SXMLHost);
    if Assigned(Node) then
      FHost := Node.Text;

    Node := RootNode.ChildNodes.FindNode(SXMLPort);
    if Assigned(Node) then
      FPort := StrToIntDef(Node.Text, DefaultPorts[FDBType]);

    Node := RootNode.ChildNodes.FindNode(SXMLDatabase);
    if Assigned(Node) then
      FDatabase := Node.Text;

    Node := RootNode.ChildNodes.FindNode(SXMLUsername);
    if Assigned(Node) then
      FUsername := Node.Text;

    Node := RootNode.ChildNodes.FindNode(SXMLPassword);
    if Assigned(Node) then
      FPassword := DecodePassword(Node.Text);

    Node := RootNode.ChildNodes.FindNode(SXMLShowDbType);
    if Assigned(Node) then
      FShowDBTypeSelector := StrToBoolDef(Node.Text, True);

    Node := RootNode.ChildNodes.FindNode(SXMLPoolMaxItems);
    if Assigned(Node) then
      FPoolMaxItems := StrToIntDef(Node.Text, SDefaultPoolMaxItems);

    Node := RootNode.ChildNodes.FindNode(SXMLPoolTimeout);
    if Assigned(Node) then
      FPoolTimeout := StrToIntDef(Node.Text, SDefaultPoolTimeout);

    Node := RootNode.ChildNodes.FindNode(SXMLConnectionTimeout);
    if Assigned(Node) then
      FConnectionTimeout := StrToIntDef(Node.Text, SDefaultConnectionTimeout);

    for var i := Low(AAdditionalParams) to High(AAdditionalParams) do
    begin
      key := AAdditionalParams[i];
      Node := RootNode.ChildNodes.FindNode(key);
      if Assigned(Node) then
        FValues.TryAdd(key, Node.Text)
      else
        FValues.TryAdd(key, ' ');
    end;

  finally
    XMLDoc.Active := False;
  end;
end;

{ ---------------------------------------------------------------------------- }
{                   Применение параметров к FireDAC                           }
{ ---------------------------------------------------------------------------- }

procedure TDBConnectionSettings.ApplyParamsToDef(AParams: TStrings);
begin
  if AParams = nil then
    Exit;

  AParams.Clear;
  AParams.Values['DriverID'] := DriverID;

  case FDBType of
    dbPostgreSQL:
    begin
      AParams.Values['Database'] := FDatabase;
      AParams.Values['User_Name'] := FUsername;
      AParams.Values['Password'] := FPassword;
      AParams.Values['Server'] := FHost;
      AParams.Values['Port'] := IntToStr(FPort);
    end;

    dbMSSQL:
    begin
      AParams.Values['Database'] := FDatabase;
      AParams.Values['User_Name'] := FUsername;
      AParams.Values['Password'] := FPassword;
      // MS SQL: порт передаётся через строку Server вида "host,port"
      AParams.Values['Server'] := FHost + ',' + IntToStr(FPort);
    end;

    dbOracle:
    begin
      AParams.Values['User_Name'] := FUsername;
      AParams.Values['Password'] := FPassword;
      // Oracle Easy Connect: //host:port/service_name
      AParams.Values['Database'] := Format('//%s:%d/%s', [FHost, FPort, FDatabase]);
    end;
  end;
end;

procedure TDBConnectionSettings.ApplyToConnection(AConn: TFDConnection);
begin
  if AConn = nil then
    Exit;

  AConn.LoginPrompt := False;
  AConn.Connected := False;

  // Очищаем только параметры соединения, сохраняя опции ресурсов/пула
  AConn.Params.Clear;
  ApplyParamsToDef(AConn.Params);
end;

procedure TDBConnectionSettings.RegisterInManager(var AManager: TFDManager;
  const ADefName: string);
var
  ConnDef: IFDStanConnectionDef;
begin
  if AManager = nil then
    Exit;

  // Пытаемся получить существующий ConnectionDef или создаём новый
  ConnDef := AManager.ConnectionDefs.FindConnectionDef(ADefName);
  if not Assigned(ConnDef) then
    ConnDef := AManager.ConnectionDefs.AddConnectionDef;

  ApplyParamsToDef(ConnDef.Params);

  ConnDef.Name := ADefName;

  // Настройки пула
  ConnDef.Params.Pooled := (FPoolMaxItems > 0);
  ConnDef.Params.PoolMaximumItems := FPoolMaxItems;
  ConnDef.Params.PoolCleanupTimeout := FPoolTimeout;
end;

{ ---------------------------------------------------------------------------- }
{                               Тест соединения                                }
{ ---------------------------------------------------------------------------- }

function TDBConnectionSettings.TestConnection(out AErrorMsg: string;
  ATimeout: Integer): Boolean;
var
  TestConn: TFDConnection;
begin
  AErrorMsg := '';
  Result := False;

  // Валидация перед попыткой соединения
  if not IsValid(AErrorMsg) then
    Exit;

  TestConn := TFDConnection.Create(nil);
  try
    TestConn.LoginPrompt := False;
    TestConn.ResourceOptions.CmdExecTimeout := ATimeout;
    TestConn.ResourceOptions.AutoConnect := False;

    ApplyToConnection(TestConn);

    try
      TestConn.Open;
      try
        TestConn.Close;
      except
        // Закрытие может упасть на некоторых драйверах, это не критично
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Result := False;
        AErrorMsg := E.Message;
      end;
    end;
  finally
    TestConn.Free;
  end;
end;

end.
