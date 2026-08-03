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
  Data.DB,
  System.Classes,
  System.SysUtils;

type
  { Интерфейс плагина FastReport DevExpress DataSource }
  IFrxDevDS = interface(IDllIntf)
    ['{F25DFB15-2E64-48B8-A19F-68C7FAD1BB62}']

    { Открытие дизайнера с автоматической привязкой DataSource }
    procedure DesignReport(
      ADataSources: array of TVTBaseDataSource<TVTBaseRecord>;
      ATreeLists: array of TcxVirtualTreeList;
      const AReportFile: WideString = ''); safecall;

    { Открытие превью с данными }
    procedure PreviewReport(
      ADataSources: array of TVTBaseDataSource<TVTBaseRecord>;
      ATreeLists: array of TcxVirtualTreeList;
      const AReportFile: WideString = ''); safecall;

    procedure SetCustomFunction(AFunc: TFunc<WideString, WideString, variant>); safecall;

    { Открытие дизайнера с наборами данных и строкой подключения }
    procedure DesignDBReport(
      ASQLs: array of WideString;
      ADataSetNames: array of WideString;
      const AConnectionString: WideString;
      const AReportFile: WideString = ''); safecall;

    { Открытие превью с наборами данных и строкой подключения }
    procedure PreviewDBReport(
      const AConnectionString: WideString;
      const AReportFile: WideString = ''); safecall;

    function GetDSByName(ADSName: WideString): TfrxDataSet; safecall;
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
