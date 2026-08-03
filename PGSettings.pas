unit PGSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutcxEditAdapters,
  dxLayoutControlAdapters, dxLayoutContainer, cxClasses, Vcl.StdCtrls,
  Vcl.Buttons, cxTextEdit, cxMaskEdit, cxSpinEdit, dxLayoutControl,
  Vcl.Samples.Spin, FireDAC.Comp.Client, System.Threading, dmSkins,
  dxSkinsCore, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinOffice2007Blue, dxSkinOffice2010Silver, dxSkinOffice2013LightGray,
  dxSkinVS2010;

type
  TfrSettings = class(TForm)
    lcConnectionSettings: TdxLayoutControl;
    edPort: TcxSpinEdit;
    edPassword: TcxTextEdit;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    edLogin: TcxTextEdit;
    edDatabase: TcxTextEdit;
    edServer: TcxTextEdit;
    lcConnectionSettingsGroup_Root: TdxLayoutGroup;
    liPort: TdxLayoutItem;
    liPassword: TdxLayoutItem;
    lgAction: TdxLayoutGroup;
    liOk: TdxLayoutItem;
    liCancel: TdxLayoutItem;
    liLogin: TdxLayoutItem;
    liDatabase: TdxLayoutItem;
    liServer: TdxLayoutItem;
    procedure btnOkClick(Sender: TObject);
  private
    FSourceConn: TFDConnection;
    FTestingConnection: Boolean; // Флаг состояния проверки
    function ValidateInput: Boolean;
    procedure DisableFormUI;
    procedure EnableFormUI;
    procedure TestConnectionAsync;
    procedure ApplyTestConnectionToParams(var conn: TFDConnection);
  protected
    procedure DoClose(var Action: TCloseAction); override; // Блокировка закрытия
  public
    class function Execute(var ASourceConn: TFDConnection): Boolean;
  end;

var
  frSettings: TfrSettings;

implementation

{$R *.dfm}

{ TfrSettings }

procedure TfrSettings.ApplyTestConnectionToParams(var conn: TFDConnection);
begin
  conn.Params.Values['Server'] := Trim(edServer.Text);
  conn.Params.Values['Port'] := Trunc(edPort.Value).ToString;
  conn.Params.Values['Database'] := Trim(edDatabase.Text);
  conn.Params.Values['User_Name'] := Trim(edLogin.Text);
  conn.Params.Values['Password'] := edPassword.Text;
end;

procedure TfrSettings.btnOkClick(Sender: TObject);
begin
  if not ValidateInput then
    Exit;
  TestConnectionAsync; // Запуск проверки вместо прямого сохранения
end;

procedure TfrSettings.DisableFormUI;
begin
  btnOK.Enabled := False;
  btnCancel.Enabled := False;
end;

procedure TfrSettings.DoClose(var Action: TCloseAction);
begin
  if FTestingConnection then
  begin
    Action := caNone; // Отменяем закрытие
    ShowMessage('Дождитесь завершения проверки соединения.');
  end
  else
    inherited;
end;

procedure TfrSettings.EnableFormUI;
begin
  btnOK.Enabled := True;
  btnCancel.Enabled := True;
  btnCancel.SetFocus; // Возвращаем фокус на "Отмена"
end;

class function TfrSettings.Execute(var ASourceConn: TFDConnection): Boolean;
var
  frm: TfrSettings;
begin
  frm := TfrSettings.Create(nil);
  try
    frm.FSourceConn := ASourceConn;
    // Заполняем поля текущими/дефолтными значениями
    frm.edServer.Text := ASourceConn.Params.Values['Server'];
    frm.edPort.Value := ASourceConn.Params.Values['Port'];
    frm.edDatabase.Text := ASourceConn.Params.Values['Database'];
    frm.edLogin.Text := ASourceConn.Params.Values['User_name'];
    frm.edPassword.Text := ASourceConn.Params.Values['Password'];

    Result := frm.ShowModal = mrOk;
  finally
    frm.Free;
  end;
end;

procedure TfrSettings.TestConnectionAsync;
begin
  FTestingConnection := True;
  DisableFormUI;

  TTask.Run(
    procedure
    var
      TestConn: TFDConnection;
      Success: Boolean;
      ErrMsg: string;
    begin
      TestConn := TFDConnection.Create(nil);
      try
        // 1. Копируем параметры из полей формы
        TestConn.LoginPrompt := False;
        TestConn.Params.DriverID := 'PG';
        ApplyTestConnectionToParams(TestConn);

        // 2. Жёсткий таймаут (5 сек), чтобы не ждать DNS/сеть вечно
        TestConn.ResourceOptions.CmdExecTimeout := 5000;

        // 3. Попытка подключения
        try
          TestConn.Open;
          Success := True;
        except
          on E: Exception do
          begin
            Success := False;
            ErrMsg := E.Message;
          end;
        end;
      finally
        TestConn.Free; // Закрываем и уничтожаем тестовое соединение
      end;

      // 4. Возврат в UI-поток
      TThread.Queue(nil,
        procedure
        begin
          EnableFormUI;
          FTestingConnection := False;

          if Success then
          begin
            // Сохраняем ТОЛЬКО после успешного теста
            ApplyTestConnectionToParams(FSourceConn);

            ModalResult := mrOk; // Закрываем форму с успехом
          end
          else
            ShowMessage('? Не удалось подключиться к базе:' + #13 + ErrMsg);
        end);
    end);
end;

function TfrSettings.ValidateInput: Boolean;
begin
  Result := False;

  if Trim(edServer.Text) = '' then
  begin ShowMessage('Host не может быть пустым.'); Exit; end;

  if Trim(edDatabase.Text) = '' then
  begin ShowMessage('Имя базы данных не может быть пустым.'); Exit; end;

  if Trim(edLogin.Text) = '' then
  begin ShowMessage('Логин не может быть пустым.'); Exit; end;

  if Trim(edPassword.Text) = '' then
  begin ShowMessage('Пароль не может быть пустым.'); Exit; end;

  Result := True;
end;

end.
