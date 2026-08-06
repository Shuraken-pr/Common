# Спецификация: Универсальный интерфейс настроек соединения с БД (Multi-DB Connection Manager)

## 1. Назначение и область применения
Создание единого универсального компонента для управления параметрами подключения к СУБД **PostgreSQL, MS SQL и Oracle** через FireDAC. Компонент заменяет собой разрозненные реализации (`PGSettings`, `uConnectionParams`, `frmSettings`) и предоставляет:
- Единую визуальную форму для ввода настроек.
- Единый класс-контейнер для хранения параметров.
- Механизмы сохранения/загрузки конфигурации в файл.
- Единый API для применения настроек к `TFDConnection` и `TFDManager`.

**Целевые проекты:** `Common` (библиотека), `LogDataDLL`, `PartsCatalogDLL`, `Postgre_Delphi`.

---

## 2. Архитектура решения

Решение состоит из трех ключевых элементов:
1. **`TDBConnectionSettings`** — класс-контейнер с настройками и логикой сериализации.
2. **`TfrmMultiDBSettings`** — визуальная форма редактирования настроек с асинхронным тестом соединения.
3. **`TDBType`** — перечисление поддерживаемых СУБД.

### 2.1. Перечисление типов БД
```pascal
type
  TDBType = (dbPostgreSQL, dbMSSQL, dbOracle, dbUnknown);

const
  DefaultPorts: array[TDBType] of Integer = (5432, 1433, 1521, 0);
  DriverIDs: array[TDBType] of string = ('PG', 'MSSQL', 'Ora', '');
```

---

## 3. Класс `TDBConnectionSettings`

### 3.1. Свойства
| Свойство | Тип | Описание |
|----------|-----|----------|
| `DBType` | `TDBType` | Тип СУБД |
| `Host` | `string` | Адрес сервера |
| `Port` | `Integer` | Порт подключения |
| `Database` | `string` | Имя базы данных (для Oracle — Service Name/TNS) |
| `Username` | `string` | Имя пользователя |
| `Password` | `string` | Пароль |
| `DriverID` | `string` | (readonly) Возвращает `PG`, `MSSQL` или `Ora` |
| `ShowDBTypeSelector` | `Boolean` | Флаг видимости селектора типа БД на форме настроек (по умолчанию `True`). Если `False` — пользователь не может изменить тип СУБД через UI. |

### 3.2. Методы
| Метод | Описание |
|-------|----------|
| `constructor Create` | Инициализация значениями по умолчанию (PostgreSQL) |
| `procedure Assign(ASource)` | Копирование настроек из другого экземпляра |
| `procedure SaveToFile(const AFileName: string)` | Сохранение в XML (пароль кодируется в Base64) |
| `procedure LoadFromFile(const AFileName: string)` | Загрузка из XML |
| `procedure ApplyToConnection(AConn: TFDConnection)` | Применение параметров к существующему соединению |
| `procedure RegisterInManager(AManager: TFDManager; const ADefName: string)` | Регистрация пула соединений в FDManager |
| `function IsValid(out AErrorMsg: string): Boolean` | Валидация заполненности обязательных полей |
| `function TestConnection(out AErrorMsg: string; ATimeoutMs: Integer = 5000): Boolean` | Тихая проверка соединения без UI. Создает временный `TFDConnection`, применяет текущие настройки и пытается подключиться с таймаутом `ATimeoutMs` мс. Возвращает `True` при успехе, `False` с описанием ошибки в `AErrorMsg`. Используется для фоновой валидации перед запуском приложения. |

### 3.3. Формат файла настроек (XML)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<db_connection_settings>
    <db_type>dbPostgreSQL</db_type>
    <host>localhost</host>
    <port>5432</port>
    <database>my_database</database>
    <username>admin</username>
    <password>YWRtaW4xMjM=</password> <!-- Base64 -->
    <pool_max_items>10</pool_max_items>
    <pool_timeout>5000</pool_timeout>
    <show_db_type_selector>true</show_db_type_selector>
</db_connection_settings>
```

---

## 4. Визуальная форма `TfrmMultiDBSettings`

### 4.1. Элементы интерфейса (DevExpress `TdxLayoutControl`)
- **`cbDBType: TcxComboBox`** — выбор типа СУБД (PostgreSQL, MS SQL, Oracle). Скрывается, если `Settings.ShowDBTypeSelector = False`.
- **`edHost: TcxTextEdit`** — адрес сервера.
- **`edPort: TcxSpinEdit`** — порт (авто-подстановка при смене типа БД).
- **`edDatabase: TcxTextEdit`** — имя БД / Service Name (заголовок динамически меняется для Oracle).
- **`edUsername: TcxTextEdit`** — логин.
- **`edPassword: TcxTextEdit`** — пароль (`EchoMode = eemPassword`).
- **`btnOk` / `btnCancel`** — подтверждение/отмена.
- **`btnTest`** — кнопка "Проверить соединение".

### 4.2. Поведение формы
1. **Смена типа СУБД:**
   - Порт автоматически меняется на дефолтный (5432, 1433, 1521).
   - Заголовок поля "База данных" меняется на "Service Name / TNS" для Oracle.
   - Для Oracle при выборе TNS-подключения поле `Host` может скрываться или становиться необязательным.

2. **Управление видимостью селектора типа БД:**
   - При загрузке формы проверяется значение `Settings.ShowDBTypeSelector`.
   - Если `False` — `cbDBType` и связанный с ним `TdxLayoutControlItem` скрываются, высота `TdxLayoutControl` автоматически пересчитывается.
   - Пользователь не может изменить тип СУБД, доступны только поля `Host`, `Port`, `Database`, `Username`, `Password`.
   - Значение `ShowDBTypeSelector` может быть изменено только программно (через ключ реестра, конфигурационный файл администратора или отдельное служебное окно).

3. **Асинхронная проверка соединения:**
   - Создается временный `TFDConnection` в отдельном потоке (`TTask.Run`).
   - Устанавливается `ResourceOptions.CmdExecTimeout := 5000` мс.
   - UI блокируется (`DisableFormUI`), показывается индикатор ожидания.
   - При успехе форма закрывается с `ModalResult = mrOk`, настройки применяются.
   - При ошибке выводится сообщение с текстом исключения FireDAC, форма остается открытой.

4. **Защита от закрытия:**
   - Override `DoClose` предотвращает закрытие формы во время асинхронного теста соединения.

### 4.3. Публичный API формы
```pascal
class function Execute(var ASettings: TDBConnectionSettings): Boolean;
```

---

## 5. Применение настроек к FireDAC

### 5.1. PostgreSQL (`DriverID = 'PG'`)
```pascal
AConn.Params.DriverID := 'PG';
AConn.Params.Database := Settings.Database;
AConn.Params.UserName := Settings.Username;
AConn.Params.Password := Settings.Password;
TFDPhysPGConnectionDefParams(AConn.Params).Server := Settings.Host;
TFDPhysPGConnectionDefParams(AConn.Params).Port := Settings.Port;
```

### 5.2. MS SQL (`DriverID = 'MSSQL'`)
```pascal
AConn.Params.DriverID := 'MSSQL';
AConn.Params.Database := Settings.Database;
AConn.Params.UserName := Settings.Username;
AConn.Params.Password := Settings.Password;
TFDPhysMSSQLConnectionDefParams(AConn.Params).Server := Settings.Host;
// Port передается через строку Server: 'host,port' или через TCP/IP alias
```

### 5.3. Oracle (`DriverID = 'Ora'`)
```pascal
AConn.Params.DriverID := 'Ora';
AConn.Params.Database := Settings.Database; // Service Name
AConn.Params.UserName := Settings.Username;
AConn.Params.Password := Settings.Password;
// Для Oracle NetName = Host:Port/ServiceName или TNSName
```

---

## 6. Сценарии использования

### 6.1. Инициализация приложения

**Алгоритм работы:**
1. Если файл настроек существует — загрузить его и попытаться тихо подключиться через `TestConnection`.
2. Если файл отсутствует, невалиден, либо `TestConnection` вернул `False` — показать форму настроек.
3. После успешного применения настроек — зарегистрировать пул в `FDManager`.

```pascal
var
  Settings: TDBConnectionSettings;
  NeedConfig: Boolean;
  ErrMsg: string;
begin
  Settings := TDBConnectionSettings.Create;
  try
    NeedConfig := not FileExists('db_settings.xml');

    if not NeedConfig then
    begin
      Settings.LoadFromFile('db_settings.xml');
      // Проверяем валидность И возможность фактического соединения
      NeedConfig := not Settings.IsValid(ErrMsg)
                 or not Settings.TestConnection(ErrMsg, 5000);
      // Если соединение прошло успешно — форму НЕ показываем,
      // сразу идем к регистрации пула
    end;

    if NeedConfig then
    begin
      // Форма покажется ТОЛЬКО если настройки отсутствуют, невалидны
      // или соединение с сохраненными параметрами не удалось
      if not TfrmMultiDBSettings.Execute(Settings) then
        Exit; // Пользователь отказался от настройки
      Settings.SaveToFile('db_settings.xml');
    end;

    // Регистрация пула в FDManager
    Settings.RegisterInManager(FDManager, 'MainPool');
  finally
    Settings.Free;
  end;
end;
```

### 6.2. Интеграция в DataModule (например, `dmDatabase`)
```pascal
procedure TdmDB.Connect;
var
  Settings: TDBConnectionSettings;
begin
  if not PGConn.Connected then
  begin
    Settings := TDBConnectionSettings.Create;
    try
      Settings.LoadFromFile('db_settings.xml');
      if TfrmMultiDBSettings.Execute(Settings) then
      begin
        Settings.SaveToFile('db_settings.xml');
        Settings.ApplyToConnection(PGConn);
        PGConn.Connected := True;
      end;
    finally
      Settings.Free;
    end;
  end;
end;
```

---

## 7. Требования к реализации

| Категория | Требование |
|-----------|------------|
| **UI Framework** | DevExpress VCL (`TdxLayoutControl`, `TcxTextEdit`, `TcxSpinEdit`, `TcxComboBox`) |
| **Асинхронность** | `System.Threading` (`TTask.Run`, `TThread.Queue`) |
| **Безопасность** | `System.NetEncoding` (Base64 для паролей) |
| **FireDAC модули** | `FireDAC.Phys.PG`, `FireDAC.Phys.MSSQL`, `FireDAC.Phys.Oracle`, `FireDAC.Comp.Client` |
| **Обработка ошибок** | Все операции ввода-вывода и подключения обернуты в `try..except` |
| **Потокобезопасность** | UI обновляется только через `TThread.Queue` |

---

## 8. Миграция существующего кода

| Текущий файл | Действие |
|--------------|----------|
| `Common\PGSettings.pas` | **Удалить** или пометить как deprecated |
| `Postgre_Delphi\Source\settings.pas` | **Рефакторить** `TDBSettings` → использовать `TDBConnectionSettings` |
| `Postgre_Delphi\Source\frmSettings.pas` | **Удалить**, заменить на `TfrmMultiDBSettings` |
| `LogDataDLL\uConnectionParams.pas` | **Удалить**, использовать единый API |
| `PartsCatalogDLL\dmDatabase.pas` | **Обновить** метод `Connect` на использование нового интерфейса |

---

## 9. Тест-кейсы

1. **Смена СУБД:** При выборе "MS SQL" порт автоматически становится 1433, заголовки полей корректны.
2. **Недоступный сервер:** При нажатии "Проверить" UI блокируется, через 5 секунд выводится ошибка таймаута, форма не "зависает".
3. **Сохранение/загрузка:** После закрытия и повторного открытия формы все параметры (включая пароль) восстанавливаются корректно.
4. **Oracle специфика:** Поле "База данных" принимает значение Service Name, подключение через Easy Connect работает.
5. **Валидация:** При пустом поле "Хост" или "Логин" форма не закрывается с `mrOk`, выводится сообщение об ошибке.
6. **Авто-пропуск формы:** При наличии корректного `db_settings.xml` и успешном `TestConnection` форма настроек **не отображается** — приложение стартует сразу.
7. **Скрытие селектора типа БД:** При `ShowDBTypeSelector = False` в файле настроек поле выбора СУБД на форме скрыто, пользователь не может переключиться на другую БД.
8. **Тихий тест при сбое сервера:** При недоступном сервере `TestConnection` возвращает `False` через таймаут 5 с, приложение показывает форму настроек (а не падает).

---

## 10. План реализации

1. Создать модуль `uDBConnectionSettings.pas` с классом `TDBConnectionSettings` и перечислением `TDBType`.
2. Реализовать методы сериализации (`SaveToFile`/`LoadFromFile`) с поддержкой Base64.
3. Реализовать методы применения настроек (`ApplyToConnection`, `RegisterInManager`) с учетом специфики каждого драйвера FireDAC.
4. Реализовать `TestConnection` для тихой проверки соединения при старте приложения.
5. Создать модуль `uMultiDBSettingsForm.pas` с формой `TfrmMultiDBSettings`.
6. Реализовать асинхронный тест соединения и блокировку UI.
7. Реализовать механизм скрытия `cbDBType` при `ShowDBTypeSelector = False`.
8. Обновить сценарий инициализации (раздел 6.1) — автопропуск формы при корректных настройках.
9. Интегрировать компонент в целевые проекты и удалить устаревший код.
