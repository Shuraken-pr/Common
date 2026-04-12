unit uAutonomiusThreadPool;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types;

type
  TThreadPoolManager = class(TObject)
  private
    FThreadList: TThreadList;
    procedure Remove(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    function Start(AProc: TProc): TThread;
    function Stop(AThread: TThread): boolean;
    procedure StopAllThreads;
  end;

implementation

{ TThreadPoolManager }

procedure TThreadPoolManager.StopAllThreads;
var
  l: TList;
  t: TThread;
begin
  if not Assigned(FThreadList) then
    Exit;
  l := FThreadList.LockList;
  try
    while l.Count > 0 do
    begin
      T := TThread(l[0]);
      l.Remove(T);
      t.OnTerminate := nil;
      if not t.Finished then
      begin
        t.Terminate;
      end;
    end;
  finally
    FThreadList.UnlockList;
  end;
end;

constructor TThreadPoolManager.Create;
begin
  FThreadList := TThreadList.Create;
end;

destructor TThreadPoolManager.Destroy;
begin
  StopAllThreads;
  FreeAndNil(FThreadList);
  inherited;
end;

procedure TThreadPoolManager.Remove(Sender: TObject);
begin
  FThreadList.LockList;
  try
    FThreadList.Remove(Sender);
  finally
    FThreadList.UnlockList;
  end;
end;

function TThreadPoolManager.Start(AProc: TProc): TThread;
begin
  Result := TThread.CreateAnonymousThread(AProc);
  Result.OnTerminate := Remove;
  Result.FreeOnTerminate := true;
  FThreadList.LockList;
  try
    FThreadList.Add(result);
  finally
    FThreadList.UnlockList;
  end;
  Result.Start;
end;

function TThreadPoolManager.Stop(AThread: TThread): boolean;
begin
  Result := Assigned(AThread) and (AThread.ThreadID <> 0);
  if Result then
  begin
    Remove(AThread);
    AThread.Terminate;  // <- ключевое: сигнализировать потоку о завершении
  end;
end;

end.
