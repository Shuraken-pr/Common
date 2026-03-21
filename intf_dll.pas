unit intf_dll;

interface

uses
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

implementation

end.
