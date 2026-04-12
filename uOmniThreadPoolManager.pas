unit uOmniThreadPoolManager;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  OtlTaskControl, OtlTask;

type
  TOmniThreadPoolManager = class
  private
    type
      TTaskEntry = record
        TaskCtrl: IOmniTaskControl;
      end;
  private
    FTaskList: TList<TTaskEntry>;
    FLock: TCriticalSection;
    procedure OnTaskTerminated(const task: IOmniTaskControl);
  public
    constructor Create;
    destructor Destroy; override;

    function Start(AProc: TProc): IOmniTaskControl;
    function Stop(const AResult: IOmniTaskControl): boolean;
    procedure StopAllThreads;
  end;


implementation

{ TOmniThreadPoolManager }

constructor TOmniThreadPoolManager.Create;
begin
  inherited Create;
  FTaskList := TList<TTaskEntry>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TOmniThreadPoolManager.Destroy;
begin
  StopAllThreads;
  FTaskList.Free;
  FLock.Free;
  inherited;
end;


procedure TOmniThreadPoolManager.OnTaskTerminated(const task: IOmniTaskControl);
var
  idx: Integer;
begin
  FLock.Enter;
  try
    for idx := FTaskList.Count - 1 downto 0 do
    begin
      if FTaskList[idx].TaskCtrl = task then
      begin
        FTaskList.Delete(idx);
        Break;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;


function TOmniThreadPoolManager.Start(AProc: TProc): IOmniTaskControl;
var
  entry: TTaskEntry;
  savedProc: TProc;
begin
  savedProc := AProc;
  entry.TaskCtrl := nil;

  Result := CreateTask(
    procedure(const task: IOmniTask)
    begin
      try
        savedProc();
      except
      end;
    end)
    .OnTerminated(OnTaskTerminated)
    .Run;

  entry.TaskCtrl := Result;

  FLock.Enter;
  try
    FTaskList.Add(entry);
  finally
    FLock.Leave;
  end;
end;

function TOmniThreadPoolManager.Stop(const AResult: IOmniTaskControl): boolean;
var
  idx: Integer;
begin
  Result := Assigned(AResult);
  if Result then
  begin
    FLock.Enter;
    try
      Result := False;
      for idx := FTaskList.Count - 1 downto 0 do
      begin
        if FTaskList[idx].TaskCtrl = AResult then
        begin
          FTaskList.Delete(idx);
          Result := True;
          Break;
        end;
      end;
    finally
      FLock.Leave;
    end;
    if Result then
      AResult.Stop;
  end;
end;

procedure TOmniThreadPoolManager.StopAllThreads;
var
  entry: TTaskEntry;
begin
  FLock.Enter;
  try
    while FTaskList.Count > 0 do
    begin
      entry := FTaskList[0];
      entry.TaskCtrl.Stop;
      entry.TaskCtrl.WaitFor(5000);
      FTaskList.Delete(0);
    end;
  finally
    FLock.Leave;
  end;
end;

end.
