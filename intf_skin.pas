unit intf_skin;

interface

uses
  System.SysUtils;

type
  /// <summary>
  /// интерфейс дл¤ плагинов, которые поддерживают внешнее управление скином.
  /// вызывается главным приложением перед Show/ShowModal.
  /// </summary>
  ISkinAware = interface(IInterface)
    ['{8A3E7B12-C4D5-4F6A-9E8B-2D1C5F7A3B90}']
    /// <summary>
    /// Установить скин DevExpress дл¤ всех форм плагина.
    /// </summary>
    /// <param name="ASkinName">имя скина (например, 'DevExpressStyle', 'Office2016Dark')</param>
    /// <param name="ANativeStyle">True - нативный стиль Windows, False - скин</param>
    procedure ApplySkin(const ASkinName: WideString; ANativeStyle: Boolean = False); safecall;
  end;

  /// <summary>
  /// Интерфейс для получени¤ списка доступных скинов от плагина.
  /// Необязательный. Главное приложение может само собрать список.
  /// </summary>
  ISkinProvider = interface(IInterface)
    ['{B1A87B07-3EA5-4277-8D99-BB4A28FE1222}']
    procedure GetAvailableSkins(out ASkinNames: TArray<WideString>); safecall;
  end;

implementation

end.
