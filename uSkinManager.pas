unit uSkinManager;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.JSON, System.IOUtils,
  cxLookAndFeels, cxLookAndFeelPainters, cxDropDownEdit, dxRibbon,
  intf_skin, dxSkinsForm, dxLayoutLookAndFeels;

type
  TSkinManager = class
  private
    FCurrentSkin: string;
    FNativeStyle: Boolean;
    FOnSkinChanged: TProc<string, Boolean>;
    FSubscribers: TInterfaceList;
    FConfigFile: string;
    procedure SetCurrentSkin(const Value: string);
    procedure SetNativeStyle(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>«агрузить скин из settings.json</summary>
    procedure LoadSettings;
    /// <summary>—охранить скин в settings.json</summary>
    procedure SaveSettings;
    /// <summary>«аполнить комбобокс списком скинов</summary>
    procedure PopulateSkinList(AComboBox: TcxComboBox);
    /// <summary>ѕрименить скин к главной форме (RootLookAndFeel + Ribbon)</summary>
    procedure ApplyToMainForm(ARootLookAndFeel: TcxLookAndFeel; ARibbon: TdxRibbon = nil);

    /// <summary>–егистраци¤ подписчика (DLL с открытой формой) дл¤ live-обновлени¤</summary>
    procedure RegisterSubscriber(const ASubscriber: ISkinAware);
    procedure UnregisterSubscriber(const ASubscriber: ISkinAware);

    property CurrentSkin: string read FCurrentSkin write SetCurrentSkin;
    property NativeStyle: Boolean read FNativeStyle write SetNativeStyle;
    property OnSkinChanged: TProc<string, Boolean> read FOnSkinChanged write FOnSkinChanged;
  end;

implementation

{ TSkinManager }

constructor TSkinManager.Create;
begin
  inherited Create;
  FSubscribers := TInterfaceList.Create;
  FCurrentSkin := 'DevExpressStyle';
  FNativeStyle := False;
  // JSON-файл р¤дом с loader.exe Ч портативность, не требует прав администратора
  FConfigFile := TPath.Combine(ExtractFilePath(ParamStr(0)), 'settings.json');
end;

destructor TSkinManager.Destroy;
begin
  FSubscribers.Free;
  inherited;
end;

procedure TSkinManager.LoadSettings;
var
  JSON: TJSONObject;
begin
  if not TFile.Exists(FConfigFile) then
    Exit; // оставл¤ем дефолты

  JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(FConfigFile)) as TJSONObject;
  if JSON = nil then Exit;
  try
    FCurrentSkin := JSON.GetValue<string>('skin_name', 'DevExpressStyle');
    FNativeStyle := JSON.GetValue<Boolean>('native_style', False);
  finally
    JSON.Free;
  end;
end;

procedure TSkinManager.SaveSettings;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('skin_name', FCurrentSkin);
    JSON.AddPair('native_style', TJSONBool.Create(FNativeStyle));
    TFile.WriteAllText(FConfigFile, JSON.ToString);
  finally
    JSON.Free;
  end;
end;

procedure TSkinManager.PopulateSkinList(AComboBox: TcxComboBox);
var
  SkinNames: TStringList;
  i: Integer;
begin
  SkinNames := TStringList.Create;
  try
    cxLookAndFeelPaintersManager.PopulateSkinNames(SkinNames);
    AComboBox.Properties.Items.Clear;
    for i := 0 to SkinNames.Count - 1 do
      AComboBox.Properties.Items.Add(SkinNames[i]);
  finally
    SkinNames.Free;
  end;
end;

procedure TSkinManager.ApplyToMainForm(ARootLookAndFeel: TcxLookAndFeel; ARibbon: TdxRibbon);
begin
  ARootLookAndFeel.BeginUpdate;
  try
    ARootLookAndFeel.SkinName := FCurrentSkin;
    ARootLookAndFeel.NativeStyle := FNativeStyle;
    if Assigned(ARibbon) then
      ARibbon.ColorSchemeName := FCurrentSkin;
  finally
    ARootLookAndFeel.EndUpdate;
  end;
end;

procedure TSkinManager.SetCurrentSkin(const Value: string);
var
  sub: ISkinAware;
begin
  if FCurrentSkin = Value then Exit;
  FCurrentSkin := Value;
  //  –»“»„Ќќ: ¤вно дЄргаем колбэк Ч иначе SaveSettings и ApplyToMainForm не вызовутс¤
  if Assigned(FOnSkinChanged) then
    FOnSkinChanged(FCurrentSkin, FNativeStyle);
  // ќповещаем подписчиков (открытые немодальные формы DLL)
  for var i := 0 to FSubscribers.Count - 1 do
  begin
    if Supports(FSubscribers[i], ISkinAware, sub) then
    try
      sub.ApplySkin(FCurrentSkin, FNativeStyle);
    except
      // подписчик мог выгрузитьс¤ Ч игнорируем
    end;
  end;
end;

procedure TSkinManager.SetNativeStyle(const Value: Boolean);
var
  sub: ISkinAware;
begin
  if FNativeStyle = Value then Exit;
  FNativeStyle := Value;
  if Assigned(FOnSkinChanged) then
    FOnSkinChanged(FCurrentSkin, FNativeStyle);
  for var i := 0 to FSubscribers.Count - 1 do
  begin
    if Supports(FSubscribers[i], ISkinAware, sub) then
    try
      sub.ApplySkin(FCurrentSkin, FNativeStyle);
    except
      // подписчик мог выгрузитьс¤ Ч игнорируем
    end;
  end;
end;

procedure TSkinManager.RegisterSubscriber(const ASubscriber: ISkinAware);
begin
  if FSubscribers.IndexOf(ASubscriber) < 0 then
    FSubscribers.Add(ASubscriber);
end;

procedure TSkinManager.UnregisterSubscriber(const ASubscriber: ISkinAware);
begin
  FSubscribers.Remove(ASubscriber);
end;

end.
