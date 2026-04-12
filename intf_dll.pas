unit intf_dll;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  System.Generics.Collections;

type
  TDLLInfo = record
    FileName: WideString;
    InitProc: WideString;
    intfName: WideString;
    guid: TGUID;
  end;

  IDLLIntf = interface
    ['{493BA3CD-0A0E-4F79-B6C6-C92DBADB7273}']
    function GetDescription: WideString; safecall;
    procedure Init; safecall;
    procedure Fin; safecall;
  end;

  IDllIntfRun = interface(IDLLIntf)
    ['{B3753E4F-F00D-416C-97E5-9BF72E5F251D}']
    procedure Run(ACallbackProc: TProc<WideString>; MainAppHandle: HWnd); safecall;
  end;


implementation

end.
