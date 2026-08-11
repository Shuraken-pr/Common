unit uMultiDBSettingsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, cxTextEdit, cxMaskEdit, cxSpinEdit, cxDropDownEdit,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, dxLayoutContainer,
  dxLayoutControl, FireDAC.Comp.Client, System.Threading,
  uDBConnectionSettings, dmSkins, dxSkinsCore, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinOffice2007Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013LightGray, dxSkinVS2010, cxClasses;

type
  TfrmMultiDBSettings = class(TForm)
    lcSettings: TdxLayoutControl;
    cbDBType: TcxComboBox;
    edHost: TcxTextEdit;
    edPort: TcxSpinEdit;
    edDatabase: TcxTextEdit;
    edUsername: TcxTextEdit;
    edPassword: TcxTextEdit;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnTest: TBitBtn;
    lcSettingsGroup_Root: TdxLayoutGroup;
    liDBType: TdxLayoutItem;
    liHost: TdxLayoutItem;
    liPort: TdxLayoutItem;
    liDatabase: TdxLayoutItem;
    liUsername: TdxLayoutItem;
    liPassword: TdxLayoutItem;
    lgActions: TdxLayoutGroup;
    liOk: TdxLayoutItem;
    liCancel: TdxLayoutItem;
    liTest: TdxLayoutItem;
    edMaxPoolItems: TcxSpinEdit;
    liMaxPoolItems: TdxLayoutItem;
    edPoolTimeout: TcxSpinEdit;
    liPoolTimeout: TdxLayoutItem;
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure cbDBTypePropertiesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FSettings: TDBConnectionSettings;
    FTestingConnection: Boolean;
    FShowDBTypeSelector: Boolean;
    FShowPoolMaxItems: Boolean;
    FShowPoolTimeout: Boolean;
    procedure LoadSettingsToForm;
    procedure SaveFormToSettings;
    function ValidateInput: Boolean;
    procedure DisableFormUI;
    procedure EnableFormUI;
    procedure TestConnectionAsync(ACloseOnSuccess: Boolean);
    procedure ApplyDBTypeChange;
    procedure UpdateVisibility;
  protected
    procedure DoClose(var Action: TCloseAction); override;
  public
    class function Execute(var ASettings: TDBConnectionSettings): Boolean;
  end;

implementation

{$R *.dfm}

{ ============================================================================ }
{                               Публичный API                                  }
{ ============================================================================ }

class function TfrmMultiDBSettings.Execute(var ASettings: TDBConnectionSettings): Boolean;
var
  frm: TfrmMultiDBSettings;
begin
  frm := TfrmMultiDBSettings.Create(nil);
  try
    frm.FSettings := ASettings;
    Result := frm.ShowModal = mrOk;
    if Result then
      frm.SaveFormToSettings;
  finally
    frm.Free;
  end;
end;

{ ============================================================================ }
{                              События формы                                   }
{ ============================================================================ }

procedure TfrmMultiDBSettings.FormCreate(Sender: TObject);
begin
  FShowDBTypeSelector := True;
  FShowPoolMaxItems := False;
  FShowPoolTimeout := False;
end;

procedure TfrmMultiDBSettings.FormShow(Sender: TObject);
begin
  // Инициализация комбобокса (items могут быть потеряны в DFM на некоторых версиях IDE)
  if cbDBType.Properties.Items.Count = 0 then
  begin
    cbDBType.Properties.Items.BeginUpdate;
    try
      cbDBType.Properties.Items.Clear;
      cbDBType.Properties.Items.Add('PostgreSQL');
      cbDBType.Properties.Items.Add('MS SQL');
      cbDBType.Properties.Items.Add('Oracle');
    finally
      cbDBType.Properties.Items.EndUpdate;
    end;
  end;

  LoadSettingsToForm;
  UpdateVisibility;
end;

procedure TfrmMultiDBSettings.btnOkClick(Sender: TObject);
begin
  if not ValidateInput then
    Exit;
  TestConnectionAsync(True); // Закрываем форму при успехе
end;

procedure TfrmMultiDBSettings.btnTestClick(Sender: TObject);
begin
  if not ValidateInput then
    Exit;
  TestConnectionAsync(False); // Только тест, без закрытия формы
end;

procedure TfrmMultiDBSettings.cbDBTypePropertiesChange(Sender: TObject);
begin
  ApplyDBTypeChange;
end;

{ ============================================================================ }
{                         Внутренняя логика                                    }
{ ============================================================================ }

procedure TfrmMultiDBSettings.ApplyDBTypeChange;
var
  DBTypeIdx: Integer;
begin
  DBTypeIdx := cbDBType.ItemIndex;
  if DBTypeIdx < 0 then
    Exit;

  case DBTypeIdx of
    0: edPort.Value := DefaultPorts[dbPostgreSQL];
    1: edPort.Value := DefaultPorts[dbMSSQL];
    2: edPort.Value := DefaultPorts[dbOracle];
  end;

  // Обновляем заголовок поля "База данных" для Oracle
  if DBTypeIdx = 2 then
    liDatabase.CaptionOptions.Text := 'Service Name / TNS'
  else
    liDatabase.CaptionOptions.Text := 'База данных';
end;

procedure TfrmMultiDBSettings.LoadSettingsToForm;
begin
  if FSettings = nil then
    Exit;

  case FSettings.DBType of
    dbPostgreSQL: cbDBType.ItemIndex := 0;
    dbMSSQL: cbDBType.ItemIndex := 1;
    dbOracle: cbDBType.ItemIndex := 2;
  else
    cbDBType.ItemIndex := 0;
  end;

  edHost.Text := FSettings.Host;
  edPort.Value := FSettings.Port;
  edDatabase.Text := FSettings.Database;
  edUsername.Text := FSettings.Username;
  edPassword.Text := FSettings.Password;

  ApplyDBTypeChange;
end;

procedure TfrmMultiDBSettings.SaveFormToSettings;
var
  DBTypeIdx: Integer;
begin
  if FSettings = nil then
    Exit;

  DBTypeIdx := cbDBType.ItemIndex;
  case DBTypeIdx of
    0: FSettings.DBType := dbPostgreSQL;
    1: FSettings.DBType := dbMSSQL;
    2: FSettings.DBType := dbOracle;
  else
    FSettings.DBType := dbPostgreSQL;
  end;

  FSettings.Host := Trim(edHost.Text);
  FSettings.Port := Trunc(edPort.Value);
  FSettings.Database := Trim(edDatabase.Text);
  FSettings.Username := Trim(edUsername.Text);
  FSettings.Password := edPassword.Text;
end;

function TfrmMultiDBSettings.ValidateInput: Boolean;
begin
  Result := False;

  if not FShowDBTypeSelector then
  begin
    // Если селектор скрыт — тип БД берём из FSettings без проверки комбобокса
  end
  else if cbDBType.ItemIndex < 0 then
  begin
    ShowMessage('Не выбран тип базы данных.');
    Exit;
  end;

  if Trim(edHost.Text) = '' then
  begin
    ShowMessage('Адрес сервера не может быть пустым.');
    Exit;
  end;

  if Trim(edDatabase.Text) = '' then
  begin
    ShowMessage('Имя базы данных не может быть пустым.');
    Exit;
  end;

  if Trim(edUsername.Text) = '' then
  begin
    ShowMessage('Логин не может быть пустым.');
    Exit;
  end;

  if Trim(edPassword.Text) = '' then
  begin
    ShowMessage('Пароль не может быть пустым.');
    Exit;
  end;

  Result := True;
end;

{ ============================================================================ }
{                        Блокировка/разблокировка UI                           }
{ ============================================================================ }

procedure TfrmMultiDBSettings.DisableFormUI;
begin
  btnOk.Enabled := False;
  btnCancel.Enabled := False;
  btnTest.Enabled := False;
  cbDBType.Enabled := False;
  edHost.Enabled := False;
  edPort.Enabled := False;
  edDatabase.Enabled := False;
  edUsername.Enabled := False;
  edPassword.Enabled := False;
end;

procedure TfrmMultiDBSettings.EnableFormUI;
begin
  btnOk.Enabled := True;
  btnCancel.Enabled := True;
  btnTest.Enabled := True;
  cbDBType.Enabled := FShowDBTypeSelector;
  edHost.Enabled := True;
  edPort.Enabled := True;
  edDatabase.Enabled := True;
  edUsername.Enabled := True;
  edPassword.Enabled := True;
  btnCancel.SetFocus;
end;

{ ============================================================================ }
{                         Асинхронная проверка соединения                      }
{ ============================================================================ }

procedure TfrmMultiDBSettings.TestConnectionAsync(ACloseOnSuccess: Boolean);
var
  // Захватываем значения для передачи в фоновый поток
  CapturedDBType: TDBType;
  CapturedHost: string;
  CapturedPort: Integer;
  CapturedDatabase: string;
  CapturedUsername: string;
  CapturedPassword: string;
  CapturedTimeout: Integer;
  CapturedCloseOnSuccess: Boolean;
begin
  FTestingConnection := True;
  DisableFormUI;

  // Сначала сохраняем текущее состояние формы в FSettings
  SaveFormToSettings;

  // Захватываем значения в локальные переменные (потокобезопасно)
  CapturedDBType := FSettings.DBType;
  CapturedHost := FSettings.Host;
  CapturedPort := FSettings.Port;
  CapturedDatabase := FSettings.Database;
  CapturedUsername := FSettings.Username;
  CapturedPassword := FSettings.Password;
  CapturedTimeout := FSettings.ConnectionTimeout;
  CapturedCloseOnSuccess := ACloseOnSuccess;

  TTask.Run(
    procedure
    var
      LocalSettings: TDBConnectionSettings;
      TestConn: TFDConnection;
      Success: Boolean;
      ErrMsg: string;
    begin
      LocalSettings := TDBConnectionSettings.Create;
      TestConn := TFDConnection.Create(nil);
      try
        // Устанавливаем захваченные значения (безопасно, работаем с локальным объектом)
        LocalSettings.DBType := CapturedDBType;
        LocalSettings.Host := CapturedHost;
        LocalSettings.Port := CapturedPort;
        LocalSettings.Database := CapturedDatabase;
        LocalSettings.Username := CapturedUsername;
        LocalSettings.Password := CapturedPassword;

        TestConn.LoginPrompt := False;
        TestConn.ResourceOptions.CmdExecTimeout := CapturedTimeout;
        TestConn.ResourceOptions.AutoConnect := False;
        LocalSettings.ApplyToConnection(TestConn);

        try
          TestConn.Open;
          try
            TestConn.Close;
          except
            // Закрытие может упасть на некоторых драйверах, это не критично
          end;
          Success := True;
          ErrMsg := '';
        except
          on E: Exception do
          begin
            Success := False;
            ErrMsg := E.Message;
          end;
        end;
      finally
        TestConn.Free;
        LocalSettings.Free;
      end;

      // Возвращаемся в UI-поток с захваченными результатами
      TThread.Queue(nil,
        procedure
        begin
          EnableFormUI;
          FTestingConnection := False;

          if Success then
          begin
            if CapturedCloseOnSuccess then
            begin
              // OK-кнопка: сохраняем настройки и закрываем форму
              SaveFormToSettings;
              ModalResult := mrOk;
            end
            else
            begin
              // Test-кнопка: просто информируем
              ShowMessage('Соединение успешно установлено.');
            end;
          end
          else
            ShowMessage('Ошибка подключения к базе:' + #13#10 + ErrMsg);
        end);
    end);
end;

{ ============================================================================ }
{                               Видимость селектора                            }
{ ============================================================================ }

procedure TfrmMultiDBSettings.UpdateVisibility;
begin
  if Assigned(FSettings) then
  begin
    FShowDBTypeSelector := FSettings.ShowDBTypeSelector;
    FShowPoolMaxItems := FSettings.ShowPoolMaxItems;
    FShowPoolTimeout := FSettings.ShowPoolTimeout;
  end;

  liDBType.Visible := FShowDBTypeSelector;
  liMaxPoolItems.Visible := FShowPoolMaxItems;
  liPoolTimeout.Visible := FShowPoolTimeout;
end;

{ ============================================================================ }
{                                  Закрытие                                    }
{ ============================================================================ }

procedure TfrmMultiDBSettings.DoClose(var Action: TCloseAction);
begin
  if FTestingConnection then
  begin
    Action := caNone;
    ShowMessage('Дождитесь завершения проверки соединения.');
  end
  else
    inherited;
end;

end.
