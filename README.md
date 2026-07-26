# Каталог Common: Общие компоненты и интерфейсы

Этот каталог содержит набор модулей, обеспечивающих единую архитектуру для основного приложения (`loader.exe`) и всех подключаемых плагинов (DLL). Здесь определены контракты взаимодействия, менеджеры ресурсов, утилиты многопоточности и хелперы для работы с визуальными компонентами.

---

## 📂 Структура модулей

### 1. Ядро плагинной архитектуры (Интерфейсы)
Эти модули определяют контракты, которые должны реализовывать все DLL.
- **`intf_dll.pas`**: Базовые интерфейсы (`IDLLIntf`, `IDllIntfRun`) и запись `TDLLInfo` для описания метаданных плагина (имя файла, точка входа, GUID).
- **`intf_dll_manager.pas`**: Интерфейс `IDllManager` для централизованной загрузки/выгрузки DLL и получения их интерфейсов. Включает `IUsesDllManager` для внедрения зависимостей (плагин может сам загружать другие плагины через этот менеджер).
- **`intf_common.pas`**: Агрегирующий модуль, содержащий специфичные интерфейсы для конкретных плагинов (`ISimpleNumbers`, `ICalcPrice`, `IPartsCatalog`, `IRunTasks` и др.) и функции-фабрики `TDLLInfo` (например, `DICatalogParts`).
- **`intf_tasks.pas`**: Интерфейсы для асинхронных фоновых задач (`IRunTask`, `IRunTaskFindInDir` и т.д.) с поддержкой callback-функций для уведомления о прогрессе, ошибках и завершении.

### 2. Управление плагинами (Реализация)
- **`DllManager.pas`**: Потокобезопасная реализация `IDllManager`. 
  - Хранит загруженные модули (`THandle`) и их интерфейсы в `TDictionary`.
  - Автоматически внедряет ссылку на себя (`SetDllManager`) в плагины, реализующие `IUsesDllManager`.
  - Предоставляет как `safecall` методы (для вызова из DLL), так и Generic-обёртки (`LoadGeneric<T>`, `GetIntfGeneric<T>`) для удобства использования в главном приложении.

### 3. Единое управление скинами DevExpress
Обеспечивает синхронизацию внешнего вида между главным окном и окнами внутри DLL.
- **`intf_skin.pas`**: 
  - `ISkinAware`: Интерфейс, который должен реализовать плагин, чтобы получать уведомления о смене темы.
  - `ISkinProvider`: Интерфейс для получения списка доступных скинов.
- **`uSkinManager.pas`**: Центральный класс `TSkinManager`.
  - Читает и сохраняет настройки (`skin_name`, `native_style`) в файл `settings.json` рядом с EXE.
  - Ведёт список подписчиков (`FSubscribers: TInterfaceList`) и рассылает им команду `ApplySkin` при изменении темы (Live Update).
  - Метод `PopulateSkinList` заполняет `TcxComboBox` доступными скинами DevExpress.
- **`uSkinHelper.pas`**: Утилиты `ApplySkinToForm` и `ApplySkinToDataModule` для быстрого применения скина к `TForm`, `TdxRibbon` и `TdxLayoutControl`.

### 4. Многопоточность (Thread Pools)
Абстракция над выполнением фоновых задач с возможностью выбора реализации через условную компиляцию.
- **`pool_config.inc`**: Файл конфигурации. Содержит директиву `{$define use_otl}` для переключения между реализациями.
- **`uAutonomiusThreadPool.pas`**: Базовая реализация пула потоков на стандартных `TThread` и `TThreadList`. Поддерживает запуск `TProc`, остановку конкретного потока и массовую остановку всех потоков.
- **`uOmniThreadPoolManager.pas`**: Продвинутая реализация на базе **OmniThreadLibrary (OTL)**. Использует `IOmniTaskControl`, обеспечивает более надёжное управление жизненным циклом задач и их принудительную остановку.

### 5. Хелперы для виртуальных деревьев и списков (UI)
Дженерик-фреймворки для упрощения работы с большими объемами данных в древовидных структурах.
- **`cxVirtualTreeListHelper.pas`**: Мощный фреймворк для `TcxVirtualTreeList` (DevExpress).
  - `TVTBase` / `TVTBaseRecord`: Базовые классы для узлов дерева с поддержкой иерархии и безопасного удаления.
  - `TVTBaseDataSource<T>`: Абстрактный источник данных, связывающий объекты Pascal с `TcxVirtualTreeList`.
  - `TVTSmartDataSource<T>`: Стратегия **SmartLoad** (ленивая загрузка). Дети создаются только при раскрытии узла (через метод `InitChildren` и анонимный метод).
  - `TVTLoadAllDataSource<T>`: Стратегия **LoadAll** (жадная загрузка). Всё дерево строится заранее, доступ осуществляется по индексу через внутренний `TObjectList`.
- **`vstHelper.pas`**: Class Helper для `TBaseVirtualTree` (библиотека VirtualTree). Позволяет легко привязывать типизированные объекты (`TBaseRecord`) к узлам дерева (`PVirtualNode`) и извлекать их через `CurrentObj<T>`.

### 6. Мониторинг и логирование FireDAC
Обеспечивает перехват, форматирование и отправку SQL-запросов и их параметров во внешнее окно отладки (SQL Logger) в реальном времени.
- **`FireDAC.Moni.Custom.Logger.pas`**: Базовая реализация кастомного клиента мониторинга FireDAC (`TFDMoniCustomClientLink` и `TFDMoniCustomClient`). Позволяет перехватывать события FireDAC (выполнение команд, SQL) и передавать их через кастомный обработчик вывода (`IFDMoniCustomClient`), поддерживая синхронизацию с главным потоком.
- **`FDMoniCustomLoggerHelper.pas`**: Хелпер для удобного использования кастомного логгера. 
  - Класс `TFDMoniCustomLogger` настраивает соединение (`TFDConnection`) на использование кастомного мониторинга (`mbCustom`) и фильтрует события (только `ekCmdExecute`, `ekSQL`).
  - Функция `GetFDParamsStr` форматирует параметры запроса (с учетом типов данных: строки, числа, даты, NULL, boolean) в читаемый вид SQL-переменных (блок `declare`).
  - Процедура `SendMonitorMessage` отправляет отформатированный SQL-запрос через механизм `WM_COPYDATA` в окно "SQL Logger" (`TfrmSQLLogger`) для отображения.

---

## 🚀 Руководство по использованию

### 1. Создание нового плагина (DLL)
1. Подключите в `.dpr` плагина модули `intf_common` и `DllManager` (если нужна загрузка зависимостей).
2. Реализуйте нужный интерфейс (например, `IPartsCatalog`).
3. Экспортируйте функцию инициализации, совпадающую с именем из `DICatalogParts` (например, `InitPartsCatalog`), которая возвращает созданный объект как `IInterface`.

### 2. Добавление поддержки скинов в плагин
1. В классе главной формы плагина реализуйте интерфейс `ISkinAware`:
   ```pascal
   type
     TfrmPluginMain = class(TForm, ISkinAware)
       // ...
     public
       procedure ApplySkin(const ASkinName: WideString; ANativeStyle: Boolean); safecall;
     end;

   procedure TfrmPluginMain.ApplySkin(const ASkinName: WideString; ANativeStyle: Boolean);
   begin
     uSkinHelper.ApplySkinToForm(Self, ASkinName, ANativeStyle, dxRibbon1);
   end;
   ```
2. При создании интерфейса плагина в главном приложении зарегистрируйте его в `TSkinManager`:
   ```pascal
   SkinManager.RegisterSubscriber(PluginIntf as ISkinAware);
   ```

### 3. Использование пула потоков
В зависимости от наличия OTL, используйте единый подход:
```pascal
uses
{$ifdef use_otl}
  uOmniThreadPoolManager, OtlTaskControl;
{$else}
  uAutonomiusThreadPool;
{$endif}

var
  Pool: TObject; // TOmniThreadPoolManager или TThreadPoolManager
  Task: TObject; // IOmniTaskControl или TThread
begin
  Pool := TOmniThreadPoolManager.Create; // или TThreadPoolManager.Create
  try
    Task := Pool.Start(procedure
    begin
      // Длительная операция
    end);
  finally
    Pool.Free; // Автоматически вызовет StopAllThreads
  end;
end;
```

### 4. Работа с VirtualTreeList (SmartLoad)
```pascal
type
  TMyNode = class(TVTBaseRecord)
    FTitle: string;
    function GetValue(ColIdx: Integer): Variant; override;
    procedure SetValue(ColIdx: Integer; const AValue: Variant); override;
  end;

var
  DataSource: TVTSmartDataSource<TMyNode>;
begin
  DataSource := TVTSmartDataSource<TMyNode>.Create(cxVirtualTreeList1);
  
  // Инициализация детей при раскрытии узла:
  DataSource.InitChildren(ParentNode, 
    procedure(AParent: TVTBaseRecord)
    var
      NewNode: TMyNode;
    begin
      NewNode := TMyNode(DataSource.InsertRecordHandle(AParent, True));
      NewNode.FTitle := 'Новый элемент';
    end);
end;
```

### 5. Включение мониторинга SQL-запросов (FireDAC)
Для отладки и логирования всех SQL-запросов, проходящих через `TFDConnection`, используйте кастомный монитор:
```pascal
uses
  FireDAC.Comp.Client, FireDAC.Moni.Custom.Logger, FDMoniCustomLoggerHelper;

var
  Connection: TFDConnection;
  Monitor: TFDMoniCustomLogger;
begin
  Connection := TFDConnection.Create(nil);
  // ... настройка Connection ...
  
  Monitor := TFDMoniCustomLogger.Create(Connection);
  Monitor.SetConnection(Connection); // Включает mbCustom и трассировку
  
  // Теперь все запросы (Execute/Open) с параметрами будут автоматически 
  // отправляться в окно "SQL Logger" главного приложения через WM_COPYDATA.
end;
```

---

## ⚠️ Важные правила
1. **Никакой инициализации VCL/DevExpress в DLL**: Вызовы `dxInitialize` / `dxFinalize` должны присутствовать **только** в главном `.dpr` приложении.
2. **Потокобезопасность**: Все обращения к `DllManager` и `TSkinManager` из разных потоков защищены критическими секциями (`TCriticalSection`) или `TThreadList`.
3. **Освобождение ресурсов**: При выгрузке DLL через `DllManager.UnLoad` сначала обнуляются ссылки на интерфейсы, и только затем вызывается `FreeLibrary`, что предотвращает Access Violation при деструкции объектов внутри DLL.

---
*Последнее обновление: 2026 г.*
