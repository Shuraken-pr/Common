unit DllManager;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  System.SyncObjs,
  intf_dll,
  intf_dll_manager,
  System.Generics.Collections;

type
  TDllManager = class(TInterfacedObject, IDllManager)
  private
    FProviders: TDictionary<string, IInterface>;
    FModules: TDictionary<string, THandle>;
    FLock: TCriticalSection;
    procedure FreeLibraryAll;
  public
    constructor Create;
    destructor Destroy; override;

    // IDllManager interface (non-generic, safecall — for use from DLLs)
    function Load(const ADllInfo: TDLLInfo; ShowError: Boolean = True): Boolean; safecall;
    function InternalLoad(const ADllInfo: TDLLInfo; ShowError: Boolean = True): Boolean;
    function UnLoad(const ADllInfo: TDLLInfo): Boolean; safecall;
    procedure UnloadAll; safecall;
    function GetIntf(const AGUID: TGUID): IInterface; safecall;
    function IsLoaded(const AIntfName: WideString): Boolean; safecall;

    // Generic wrappers for convenience in the main application
    function LoadGeneric<T: IDllIntf>(ADllInfo: TDLLInfo; ShowError: Boolean = True): Boolean;
    function GetIntfGeneric<T: IDllIntf>(ADllInfo: TDLLInfo): T;
  end;

implementation

type
  TCreateDllIntf = function: IInterface; safecall;

{ TDllManager }

constructor TDllManager.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FProviders := TDictionary<string, IInterface>.Create;
  FModules := TDictionary<string, THandle>.Create;
end;

destructor TDllManager.Destroy;
begin
  // UnloadAll уже делает FProviders.Clear + FreeLibraryAll
  // Но контейнеры ещё не уничтожены — освобождаем их здесь
  FProviders.Free;
  FModules.Free;
  FLock.Free;
  inherited;
end;

procedure TDllManager.FreeLibraryAll;
var
  pair: TPair<string, THandle>;
begin
  for pair in FModules do
  begin
    if pair.Value <> 0 then
      FreeLibrary(pair.Value);
  end;
end;

{ === IDllManager (non-generic, safecall — for use from DLLs) === }

function TDllManager.InternalLoad(const ADllInfo: TDLLInfo;
  ShowError: Boolean): Boolean;
var
  hMod: THandle;
  funcPtr: Pointer;
  createFunc: TCreateDllIntf;
  rawIntf: IInterface;
  baseProvider: IDLLIntf;
  usesDllMgr: IUsesDllManager;
begin
  Result := False;

  FLock.Enter;
  try
    if not FileExists(ADllInfo.FileName) then
    begin
      if ShowError then
        raise EArgumentException.CreateFmt('File %s not found', [ADllInfo.FileName]);
      Exit;
    end;

    if FProviders.ContainsKey(ADllInfo.intfName) then
    begin
      if ShowError then
        raise Exception.Create('Interface already loaded');
      Exit;
    end;
  finally
    FLock.Leave;
  end;

  hMod := LoadLibrary(PChar(ADllInfo.FileName));
  if hMod = 0 then
  begin
    if ShowError then
      raise Exception.CreateFmt('Failed to load %s: %d', [ADllInfo.FileName, GetLastError]);
    Exit;
  end;

  try
    funcPtr := GetProcAddress(hMod, PChar(ADllInfo.InitProc));
    if not Assigned(funcPtr) then
    begin
      if ShowError then
        raise Exception.CreateFmt('Function %s not found in %s', [ADllInfo.InitProc, ADllInfo.FileName]);
      Exit;
    end;

    @createFunc := funcPtr;

    try
      rawIntf := createFunc;
    except
      on E: Exception do
      begin
        if ShowError then
          raise Exception.CreateFmt('Error calling %s: %s', [ADllInfo.InitProc, E.Message]);
        Exit;
      end;
    end;

    if rawIntf = nil then
    begin
      if ShowError then
        raise Exception.CreateFmt('%s returned nil', [ADllInfo.InitProc]);
      Exit;
    end;

    if not Supports(rawIntf, IDllIntf, baseProvider) then
    begin
      if ShowError then
        raise Exception.Create('IDllIntf interface not supported');
      Exit;
    end;

    // Inject IDllManager if the plugin supports IUsesDllManager
    if Supports(rawIntf, IUsesDllManager, usesDllMgr) then
      usesDllMgr.SetDllManager(Self);

    FLock.Enter;
    try
      FProviders.Add(ADllInfo.intfName, rawIntf);
      if not FModules.ContainsKey(ADllInfo.FileName) then
        FModules.Add(ADllInfo.FileName, hMod);
    finally
      FLock.Leave;
    end;

    hMod := 0; // ownership transferred
    Result := True;
  finally
    if hMod <> 0 then
      FreeLibrary(hMod);
  end;
end;

function TDllManager.Load(const ADllInfo: TDLLInfo; ShowError: Boolean): Boolean;
begin
  Result := InternalLoad(ADllInfo, ShowError);
end;

function TDllManager.UnLoad(const ADllInfo: TDLLInfo): Boolean;
var
  hMod: THandle;
  intf: IInterface;
begin
  Result := False;
  FLock.Enter;
  try
    if not FProviders.TryGetValue(ADllInfo.intfName, intf) then
      Exit;

    FProviders.Remove(ADllInfo.intfName);
    if FModules.TryGetValue(ADllInfo.FileName, hMod) then
    begin
      FModules.Remove(ADllInfo.FileName);
      if hMod <> 0 then
        FreeLibrary(hMod);
    end;
  finally
    FLock.Leave;
  end;
  // Освобождаем ссылку на интерфейс ПОСЛЕ снятия блокировки
  // (избегаем потенциального deadlock при освобождении объекта из DLL)
  Pointer(intf) := nil;
  Result := True;
end;

procedure TDllManager.UnloadAll;
begin
  FLock.Enter;
  try
    // 1. Сначала освобождаем интерфейсы (из DLL)
    FProviders.Clear;
    // 2. Только потом выгружаем DLL
    FreeLibraryAll;
    FModules.Clear;
  finally
    FLock.Leave;
  end;
end;

function TDllManager.GetIntf(const AGUID: TGUID): IInterface;
var
  pair: TPair<string, IInterface>;
  intf: IInterface;
begin
  Result := nil;
  FLock.Enter;
  try
    for pair in FProviders do
    begin
      if Supports(pair.Value, AGUID, intf) then
      begin
        Result := intf;
        Exit;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function TDllManager.IsLoaded(const AIntfName: WideString): Boolean;
begin
  FLock.Enter;
  try
    Result := FProviders.ContainsKey(AIntfName);
  finally
    FLock.Leave;
  end;
end;

{ === Generic wrappers (for convenience in the main application) === }

function TDllManager.LoadGeneric<T>(ADllInfo: TDLLInfo; ShowError: Boolean): Boolean;
var
  rawIntf: IInterface;
  specific: T;
begin
  Result := Load(ADllInfo, ShowError);
  if Result then
  begin
    FLock.Enter;
    try
      if FProviders.TryGetValue(ADllInfo.intfName, rawIntf) then
      begin
        if not Supports(rawIntf, ADllInfo.guid, specific) then
        begin
          if ShowError then
            raise Exception.CreateFmt('Interface %s not supported', [ADllInfo.intfName]);
          Result := False;
        end;
      end;
    finally
      FLock.Leave;
    end;
  end;
end;

function TDllManager.GetIntfGeneric<T>(ADllInfo: TDLLInfo): T;
var
  intf: IInterface;
  specific: T;
begin
  Result := nil;
  FLock.Enter;
  try
    if FProviders.TryGetValue(ADllInfo.intfName, intf) then
    begin
      if Supports(intf, ADllInfo.guid, specific) then
        Result := specific;
    end;
  finally
    FLock.Leave;
  end;
end;

end.
