unit DllManager;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  intf_dll,
  System.Generics.Collections;

type
  TDllManager = class(TObject)
  private
    FProviders: TDictionary<string, IInterface>;    // key -> интерфейс
    FModules: TDictionary<string, THandle>; // key -> HMODULE
  public
    constructor Create;
    destructor Destroy; override;
    function Load<T: IDllIntf>(ADllInfo: TDLLInfo; ShowError: boolean = true): boolean;
    function UnLoad(ADllInfo: TDLLInfo): boolean;
    procedure UnloadAll;
    function GetIntf<T: IDllIntf>(ADllInfo: TDLLInfo): T;
  end;

implementation

type
  TCreateDllIntf = function: IInterface; safecall;

{ TDllManager }

constructor TDllManager.Create;
begin
  FProviders := TDictionary<string, IInterface>.Create;
  FModules := TDictionary<string, THandle>.Create;
end;

destructor TDllManager.Destroy;
begin
  UnloadAll;
  FreeAndNil(FProviders);
  FreeAndNil(FModules);
  inherited;
end;

function TDllManager.GetIntf<T>(ADllInfo: TDLLInfo): T;
var
  intf: IInterface;
  specific: T;
begin
  Result := nil;
  if FProviders.TryGetValue(ADllInfo.intfName, intf) then
  begin
    if Supports(intf, ADllInfo.guid, specific) then
      Result := specific;
  end;
end;

function TDllManager.Load<T>(ADllInfo: TDLLInfo; ShowError: boolean): boolean;
var
  hMod: THandle;
  funcPtr: Pointer;
  createFunc: TCreateDllIntf;
  rawIntf: IInterface;
  baseProvider: IDLLIntf;
  specific: T;
begin
  Result := false;

  if not FileExists(ADllInfo.FileName) then
  begin
    if ShowError then
      raise EArgumentException.CreateFmt('Файл %s не найден', [ADllInfo.FileName])
    else
      exit;
  end;

  if FProviders.ContainsKey(ADllInfo.intfName) then
  begin
    if ShowError then
      raise Exception.Create('Интерфейс уже загружен')
    else
      exit;
  end;

  hMod := LoadLibrary(PChar(ADllInfo.FileName));
  if hMod = 0 then
  begin
    if ShowError then
      raise Exception.CreateFmt('Не удалось загрузить %s: %d', [ADllInfo.FileName, GetLastError])
    else
      exit;
  end;

  try
    funcPtr := GetProcAddress(hMod, PChar(ADllInfo.InitProc));
    if not Assigned(funcPtr) then
    begin
      if ShowError then
        raise Exception.CreateFmt('Функция %s не найдена в %s', [ADllInfo.InitProc, ADllInfo.FileName])
      else
        exit;
    end;

    @createFunc := funcPtr;

    rawIntf := nil;
    try
      rawIntf := createFunc;
    except
      on E: Exception do
      begin
        if ShowError then
          raise Exception.CreateFmt('Ошибка при вызове %s: %s', [ADllInfo.InitProc, E.Message])
        else
          exit;
      end;
    end;

    if rawIntf = nil then
    begin
      if ShowError then
        raise Exception.CreateFmt('%s вернул nil', [ADllInfo.InitProc])
      else
        exit;
    end;

    if not Supports(rawIntf, IDllIntf, baseProvider) then
    begin
      if ShowError then
        raise Exception.Create('Интерфейс IDllIntf не поддерживается')
       else
        exit;
    end;

    if not Supports(baseProvider, ADllInfo.guid, specific) then
    begin
      if ShowError then
        raise Exception.CreateFmt('Интерфейс %s не поддерживается', [ADllInfo.intfName])
      else
        exit;
    end;

    FProviders.Add(ADllInfo.intfName, specific);
    if not FModules.ContainsKey(ADllInfo.FileName) then
      FModules.Add(ADllInfo.FileName, hMod);

    hMod := 0;
    Result := true;
  finally
    if hMod <> 0 then
    begin
      Result := false;
      FreeLibrary(hMod);
    end;
  end;
end;

function TDllManager.UnLoad(ADllInfo: TDLLInfo): boolean;
var
  hMod: THandle;
  intf: IInterface;
begin
  Result := false;
  if not FProviders.TryGetValue(ADllInfo.FileName, intf) then
    exit;

  if FModules.TryGetValue(ADllInfo.FileName, hMod) then
  begin
    FProviders.Remove(ADllInfo.FileName);
    if hMod <> 0 then
      FreeLibrary(hMod);
  end;
  intf := nil;
  Result := true;
end;

procedure TDllManager.UnloadAll;
var
  pair: TPair<string, THandle>;
begin
  FProviders.Clear;

  for pair in FModules do
  begin
    if pair.Value <> 0 then
      FreeLibrary(pair.Value);
  end;
end;

end.
