unit intf_dll_manager;

interface

uses
  intf_dll,
  System.SysUtils;

type
  /// <summary>
  /// Интерфейс менеджера DLL. Позволяет загружать, выгружать и получать
  /// интерфейсы из динамических библиотек без привязки к конкретной реализации.
  /// </summary>
  IDllManager = interface(IInterface)
    ['{E1A8F7C3-9B2D-4F5E-A3D6-7C8E4B1F0A92}']

    /// <summary>
    /// Загрузить DLL по описанию и зарегистрировать её интерфейс.
    /// </summary>
    /// <param name="ADllInfo">Информация о DLL (файл, proc, GUID)</param>
    /// <param name="ShowError">Показывать ли исключения при ошибке</param>
    /// <returns>True, если загрузка успешна</returns>
    function Load(const ADllInfo: TDLLInfo; ShowError: Boolean = True): Boolean; safecall;

    /// <summary>
    /// Выгрузить DLL по описанию.
    /// </summary>
    function UnLoad(const ADllInfo: TDLLInfo): Boolean; safecall;

    /// <summary>
    /// Выгрузить все загруженные DLL.
    /// </summary>
    procedure UnloadAll; safecall;

    /// <summary>
    /// Получить интерфейс из загруженной DLL.
    /// Возвращает nil, если интерфейс не найден или не поддерживает запрошенный GUID.
    /// </summary>
    function GetIntf(const AGUID: TGUID): IInterface; safecall;

    /// <summary>
    /// Проверить, загружена ли DLL с данным именем интерфейса.
    /// </summary>
    function IsLoaded(const AIntfName: WideString): Boolean; safecall;
  end;

  /// <summary>
  /// Интерфейс, который может использовать IDllManager для загрузки
  /// зависимых DLL "на лету". Любой плагин, реализующий этот интерфейс,
  /// получает ссылку на менеджер DLL и может самостоятельно подгружать
  /// нужные ему библиотеки.
  /// </summary>
  IUsesDllManager = interface(IInterface)
    ['{C5D3E8A1-4F7B-42E9-B6C0-3D9A7E2F1B84}']

    /// <summary>
    /// Внедрение менеджера DLL в плагин.
    /// Вызывается сразу после создания интерфейса из DLL.
    /// </summary>
    procedure SetDllManager(AMgr: IDllManager); safecall;
  end;

  /// <summary>
  /// Базовый интерфейс для плагинов, которые нуждаются в загрузке
  /// других плагинов-зависимостей через IDllManager.
  /// Наследует IDllIntfRun + IUsesDllManager.
  /// </summary>
  IDllIntfRunWithDeps = interface(IDllIntfRun)
    ['{7F2B9D4E-6A1C-48F3-9E5D-8B3C0A6F2D71}']
    procedure SetDllManager(AMgr: IDllManager); safecall;
  end;

implementation

end.
