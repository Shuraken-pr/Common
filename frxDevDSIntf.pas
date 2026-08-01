unit frxDevDSIntf;

interface

uses
  intf_dll,
  intf_dll_manager,
  frxClass,
  cxVirtualTreeListHelper,
  cxTL,
  cxTLData,
  cxCustomData,
  System.Classes,
  System.SysUtils;

type
  { Интерфейс плагина FastReport DevExpress DataSource }
  IFrxDevDS = interface(IDllIntf)
    ['{F25DFB15-2E64-48B8-A19F-68C7FAD1BB62}']

    { Открытие дизайнера с автоматической привязкой DataSource }
    procedure DesignReport(
      ADataSources: array of TVTBaseDataSource<TVTBaseRecord>;
      ATreeLists: array of TcxVirtualTreeList); safecall;

    { Открытие превью с данными }
    procedure PreviewReport(
      ADataSources: array of TVTBaseDataSource<TVTBaseRecord>;
      ATreeLists: array of TcxVirtualTreeList); safecall;

    procedure SetCustomFunction(AFunc: TFunc<WideString, WideString, variant>); safecall;
  end;

  { Информация для загрузки через DllManager }
  function DIFrxDevDS: TDLLInfo;

implementation

function DIFrxDevDS: TDLLInfo;
begin
  Result.FileName := 'frxDevDS.dll';
  Result.InitProc := 'InitFrxDevDS';
  Result.intfName := 'IFrxDevDS';
  Result.guid := IFrxDevDS;
end;

end.
