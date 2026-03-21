unit intf_tasks;

interface

uses
  intf_dll,
  System.SysUtils,
  System.Classes,
  Windows,
  System.Generics.Collections;

type
  IRunTask = interface(IDLLIntf)
    ['{2BBD4EC7-15FC-4C6F-B38C-76D1B4B58B0D}']
    function Start(ACommand: WideString; AParams: WideString): TThread; safecall;
    procedure Stop(AThread: TThread); safecall;
    function Info: WideString; safecall;
  end;

  IRunTaskFindInDir = interface(IRunTask)
    ['{470626A3-A651-4AA9-BE8B-D4083B4C6542}']
    procedure SetCallbacks(StartCallback,  //уведомляем о запуске
                           RunCallback,    //отображаем ход выполнения
                           BreakCallback,  //уведомляем о прерывании
                           FinishCallback, //уведомляем о завершении
                           SyncCallback:   //выполняем синхронизацию
                           TProc<WideString>); safecall;
    function ResultList: TArray<WideString>; safecall;
  end;

  IRunTaskFindInExeFile = interface(IRunTask)
    ['{6118EE7A-0E8D-4783-8B74-275729D73BFC}']
    procedure SetCallbacks(StartCallback,  //уведомляем о запуске
                           BreakCallback,  //уведомляем о прерывании
                           ErrorCallback,  //уведомляем об ошибке
                           FinishCallback:   //выполняем синхронизацию
                           TProc<WideString>); safecall;
    function ResultList: TArray<WideString>; safecall;
  end;

  IRunTaskShellExecute = interface(IRunTask)
    ['{E244A2B3-5C66-4BD6-A9D1-BD74AE1A0A6E}']
    procedure SetCallbacks(StartCallback,  //уведомляем о запуске
                           BreakCallback,  //уведомляем о прерывании
                           ErrorCallback,  //уведомляем об ошибке
                           FinishCallback:   //выполняем синхронизацию
                           TProc<WideString>); safecall;
  end;

implementation

end.
