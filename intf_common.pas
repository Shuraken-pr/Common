unit intf_common;

interface

uses
  intf_dll,
  intf_tasks,
  intf_dll_manager,
  System.SysUtils,
  Winapi.Windows,
  System.Generics.Collections;

type
  IDllIntfRun = interface(IDLLIntf)
    ['{B3753E4F-F00D-416C-97E5-9BF72E5F251D}']
    procedure Run(ACallbackProc: TProc<WideString>; MainAppHandle: HWnd); safecall;
  end;

  ISimpleNumbers = interface(IDllIntfRun)
    ['{D6A333A4-585C-4494-9105-661CFE4B8503}']
    procedure SilentRun(AMaxNum: integer; ACallbackProc: TProc<WideString>); safecall;
  end;

  ICalcPrice = interface(IDllIntfRun)
    ['{74C97DEE-0026-437E-8B8E-EDED082A8323}']
    procedure CalcPrices(InputPriceWithNDS: double; ProcNDS: Integer;
    out CorrectedPriceWithNDS, CorrectedPriceWithoutNDS: double); safecall;
  end;

  IExplorer = interface(IDllIntfRunWithDeps)
    ['{EAB34C53-B919-40D1-866F-F832E644ECCD}']
    procedure initFindIntf(AIntf: IRunTaskFindInDir); safecall;
  end;

  IRunTasks = interface(IDllIntfRunWithDeps)
    ['{D144885F-E776-42BC-B4CB-6B90F699F87D}']
    procedure initRunTasks(AFindInDir: IRunTaskFindInDir;
                           AFindInExeFile: IRunTaskFindInExeFile;
                           AShellExecute: IRunTaskShellExecute); safecall;

    /// <summary>
    /// Альтернативный метод инициализации через IDllManager.
    /// Плагин сам загрузит нужные DLL через переданный менеджер.
    /// </summary>
    procedure InitViaDllManager; safecall;
  end;

  /// <summary>
  /// Интерфейс плагина работы с логгированием изменений в БД.
  /// Поддерживает PostgreSQL, MS SQL Server, Oracle.
  /// </summary>
  ILogData = interface(IDllIntfRun)
    ['{18F44553-FE95-4DDE-8C36-BA9B09519B11}']
  end;

  IPartsCatalog = interface(IDllIntfRun)
    ['{28C155B1-41A8-4101-90AA-B211C13FE093}']
  end;

  function DISimpleNumbers: TDLLInfo;
  function DICalcPrice: TDLLInfo;
  function DIExplorer: TDLLInfo;
  function DIRunTaskFindInDir: TDLLInfo;
  function DIRunTaskFindInExeFile: TDLLInfo;
  function DIRunTaskShellExecute: TDLLInfo;
  function DIRunTasks: TDLLInfo;
  function DILogData: TDLLInfo;
  function DICatalogParts: TDLLInfo;

implementation

function DISimpleNumbers:  TDLLInfo;
begin
  Result.FileName := 'SimpleNumbers.dll';
  Result.InitProc := 'InitSimpleNumbers';
  Result.intfName := 'ISimpleNumbers';
  Result.guid := ISimpleNumbers;
end;

function DICalcPrice:  TDLLInfo;
begin
  Result.FileName := 'CalcPrice.dll';
  Result.InitProc := 'InitCalcPrice';
  Result.intfName := 'ICalcPrice';
  Result.guid := ICalcPrice;
end;

function DIExplorer:  TDLLInfo;
begin
  Result.FileName := 'Explorer.dll';
  Result.InitProc := 'InitExplorer';
  Result.intfName := 'IExplorer';
  Result.guid := IExplorer;
end;

function DIRunTaskFindInDir:  TDLLInfo;
begin
  Result.FileName := 'RunTaskFind.dll';
  Result.InitProc := 'InitRunTaskFindInDir';
  Result.intfName := 'IRunTaskFindInDir';
  Result.guid := IRunTaskFindInDir;
end;

function DIRunTaskFindInExeFile: TDLLInfo;
begin
  Result.FileName := 'RunTaskFind.dll';
  Result.InitProc := 'InitRunTaskFindInExeFile';
  Result.intfName := 'IRunTaskFindInExeFile';
  Result.guid := IRunTaskFindInExeFile;
end;

function DIRunTaskShellExecute: TDLLInfo;
begin
  Result.FileName := 'RunTaskShellExecute.dll';
  Result.InitProc := 'InitRunTaskShellExecute';
  Result.intfName := 'IRunTaskShellExecute';
  Result.guid := IRunTaskShellExecute;
end;

function DIRunTasks: TDLLInfo;
begin
  Result.FileName := 'RunTasks.dll';
  Result.InitProc := 'InitRunTasks';
  Result.intfName := 'IRunTasks';
  Result.guid := IRunTasks;
end;

function DILogData: TDLLInfo;
begin
  Result.FileName := 'LogData.dll';
  Result.InitProc := 'InitLogData';
  Result.intfName := 'ILogData';
  Result.guid := ILogData;
end;

function DICatalogParts: TDLLInfo;
begin
  Result.FileName := 'PartsCatalog.dll';
  Result.InitProc := 'InitPartsCatalog';
  Result.intfName := 'IPartsCatalog';
  Result.guid := IPartsCatalog;
end;

end.
