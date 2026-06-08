# История разработки Stylee (репозиторий verrronikka/stylee_upprpo_24943)
---

## Содержание

1. [Глоссарий технических терминов](#0-глоссарий-технических-терминов)
2. [Краткий курс Dart для знающих C/Python](#1-краткий-курс-dart-для-знающих-cpython)
3. [Основы Flutter](#2-основы-flutter)
4. [Общая архитектура проекта](#3-общая-архитектура-проекта)
5. [Хронология коммитов](#4-хронология-коммитов)
6. [Ключевые функции и их реализация](#5-ключевые-функции-и-их-реализация)
7. [Схема архитектуры](#6-схема-архитектуры)

---

## 0. Глоссарий технических терминов

### A

**API (Application Programming Interface)** — интерфейс программирования приложений. Набор правил и протоколов для взаимодействия между программами. В нашем случае Flutter-приложение общается с Python-бэкендом через REST API: отправляет HTTP-запросы и получает ответы в формате JSON.

**async/await** — механизм асинхронного программирования. Позволяет выполнять длительные операции (сетевые запросы, чтение файлов) без блокировки основного потока. `async` помечает функцию как асинхронную, `await` приостанавливает выполнение до получения результата.

### B

**Backend (бэкенд)** — серверная часть приложения, которая работает "за кулисами": обрабатывает данные, общается с базой данных, выполняет бизнес-логику. В нашем проекте это Python-приложение на FastAPI.

**Bearer Token** — способ авторизации API-запросов. Ключ (токен) передаётся в заголовке `Authorization: Bearer <token>`. Стандартный формат для HTTP API.

### C

**cURL** — инструмент командной строки для выполнения HTTP-запросов. `curl_cffi` — библиотека Python, которая имитирует браузер (impersonate Chrome) для обхода защиты от ботов.

### D

**Dart** — язык программирования, созданный Google. Используется во Flutter для разработки кроссплатформенных приложений (iOS, Android, Web, Desktop).

**Deployment (деплой)** — развёртывание приложения на сервере или в облаке, чтобы оно было доступно пользователям.

**Docker** — платформа для контейнеризации приложений. Позволяет упаковать приложение со всеми зависимостями в "контейнер", который можно запустить где угодно.

### F

**FastAPI** — современный Python-фреймворк для создания веб-сервисов и REST API. Автоматически генерирует документацию, валидирует данные, поддерживает асинхронность.

**Firestore** — облачная NoSQL база данных от Firebase. Хранит данные в виде коллекций документов (документ = запись, коллекция = таблица). Поддерживает real-time обновления.

**Flask** — лёгкий Python-фреймворк для веб-приложений (в отличие от FastAPI, более простой, но меньше возможностей "из коробки").

**Frontend (фронтенд)** — пользовательский интерфейс приложения. В нашем проекте это Flutter-приложение, которое видит пользователь.

### G

**Generic (дженерики)** — механизм параметризации типов в языках программирования. `List<String>` означает "список строк", `Map<String, int>` — "словарь со строковыми ключами и целыми значениями".

**Git** — система контроля версий. Позволяет отслеживать изменения в коде, создавать ветки, сливать изменения.

**GitHub** — платформа для хостинга Git-репозиториев и совместной разработки.

**gRPC** — высокопроизводительный протокол удалённого вызова процедур. Быстрее REST, но сложнее в настройке.

### H

**HTML (HyperText Markup Language)** — язык разметки веб-страниц. Парсеры маркетплейсов загружают HTML-страницы и извлекают из них информацию о товарах.

**HTTP (HyperText Transfer Protocol)** — протокол передачи данных в интернете. Клиент (приложение) отправляет запрос, сервер возвращает ответ.

**HTTPS** — защищённая версия HTTP с шифрованием (SSL/TLS).

### I

**Impersonate (имитация браузера)** — техника, при которой HTTP-клиент представляется браузером (Chrome, Firefox), чтобы обойти защиту сайтов от ботов.

### J

**JSON (JavaScript Object Notation)** — текстовый формат для хранения и обмена данными. Легко читается человеком и машинами. Пример: `{"name": "Alice", "age": 30}`.

### L

**Lambda (лямбда-функция)** — анонимная функция, которую можно передать как аргумент. В Dart: `(x) => x * 2`. В Python: `lambda x: x * 2`.

**Linter** — инструмент для статического анализа кода. Проверяет стиль, ошибки, потенциальные проблемы без выполнения кода.

### M

**Middleware (мидлвар)** — промежуточное ПО, которое обрабатывает запросы до того, как они дойдут до обработчика. В FastAPI используется для CORS, аутентификации, логирования.

**Mixin** — механизм повторного использования кода в классах. Позволяет "вмешать" методы из одного класса в другой без наследования.

### N

**Null safety** — система типов, которая защищает от ошибок null reference (обращение к несуществующему объекту). В Dart: `String?` может быть null, `String` — не может.

**NoSQL** — тип баз данных, которые не используют традиционные таблицы SQL. Firestore — документо-ориентированная NoSQL база данных.

### O

**OAuth** — протокол авторизации, позволяющий пользователям предоставлять доступ к своим данным сторонним приложениям без передачи пароля.

**Ozon** — крупнейший российский маркетплейс. Имеет свой API для партнёров и парсит HTML-страницы поиска.

### P

**Parse/Parsing (парсинг)** — извлечение структурированных данных из неструктурированных источников (HTML-страниц, JSON, текста).

**pHash (Perceptual Hash)** — перцептивный хэш — алгоритм, который создаёт "отпечаток" изображения на основе его визуального содержания. Похожие изображения дают похожие хэши, что позволяет сравнивать их.

**Playwright** — инструмент для автоматизации браузера. Может загружать страницы с JavaScript, заполнять формы, кликать. Используется как запасной вариант для парсинга сложных сайтов.

**Prometheus** — система мониторинга и алертинга.

**Proxy (прокси)** — промежуточный сервер, который перенаправляет запросы. Используется для обхода блокировок или скрытия реального IP-адреса.

**pubspec.yaml** — файл конфигурации Flutter-проекта. Содержит зависимости (библиотеки), метаданные, версии.

### Q

**Query (запрос)** — запрос к базе данных. В Firestore: `collection('Users').where('age', isGreaterThan: 18)` — найти пользователей старше 18.

### R

**REST API** — архитектурный стиль для создания веб-сервисов. Использует стандартные HTTP-методы: GET (получение), POST (создание), PUT (обновление), DELETE (удаление).

**Runtime** — время выполнения программы. В отличие от "compile time" (время компиляции).

### S

**Scrapping/Scraping** — автоматическое извлечение данных с веб-сайтов. "Скрапинг погоды" = извлечение данных о погоде с сайта.

**SDK (Software Development Kit)** — набор инструментов для разработки. Flutter SDK включает компилятор, отладчик, библиотеки.

**Singleton (синглтон)** — паттерн проектирования, при котором существует только один экземпляр класса. `FirebaseFirestore.instance` — единственный экземпляр Firestore.

**SQL (Structured Query Language)** — язык запросов к реляционным базам данных. SQLite — лёгкая SQL-база данных, работающая в одном файле.

**State (состояние)** — данные, которые могут изменяться во время работы приложения. При изменении состояния UI перерисовывается.

**Stateless/Stateful** — StatelessWidget не имеет состояния (не меняется), StatefulWidget имеет состояние (может меняться).

**Stealth (антидетекция)** — техники сокрытия признаков автоматизации (бот-детекции), чтобы сайт не мог определить, что запросы делает бот, а не человек.

### T

**Token** — специальная строка, используемая для аутентификации. Может истекать, быть отозван.

**TypeScript** — надмножество JavaScript с статической типизацией.

### U

**UI (User Interface)** — пользовательский интерфейс. Всё то, что видит пользователь: кнопки, экраны, формы.

**URI (Uniform Resource Identifier)** — универсальный идентификатор ресурса. URL — частный случай URI.

### W

**Webhook** — механизм уведомления о событиях. Когда происходит действие, сервер отправляет HTTP-запрос на указанный URL.

**Widget** — базовый строительный блок UI в Flutter. Всё на экране — виджет: кнопки, текст, изображения, даже целые экраны.

**Wildberries (WB)** — крупнейший российский маркетплейс. Имеет API для партнёров и открытое API поиска.

### Y

**YAML (YAML Ain't Markup Language)** — формат данных, читаемый человеком. Используется в конфигурационных файлах (`pubspec.yaml`, GitHub Actions).

---

### Быстрый справочник: REST API vs GraphQL

| Аспект | REST API | GraphQL |
|--------|----------|---------|
| Формат | JSON, XML | JSON |
| Запрос данных | Разные эндпоинты | Один эндпоинт, гибкие запросы |
| Пример | `GET /users/1`, `GET /posts` | `query { user(id: 1) { name posts { title } } }` |
| Кэширование | Простое (по URL) | Сложнее |

### Быстрый справочник: SQL vs NoSQL

| Аспект | SQL (PostgreSQL, MySQL) | NoSQL (Firestore, MongoDB) |
|--------|--------------------------|----------------------------|
| Структура | Таблицы со строгой схемой | Документы с гибкой схемой |
| Запросы | Сложные JOIN, агрегации | Простые запросы, фильтрация |
| Масштабирование | Вертикальное | Горизонтальное |
| Транзакции | Полные ACID | Ограниченные |

---

## 1. Краткий курс Dart для знающих C/Python

### 1.1 Основные отличия от C и Python

| Концепция | C | Python | Dart |
|-----------|---|--------|------|
| Типизация | Статическая, ручная | Динамическая | Статическая, но с `var` и `dynamic` |
| Объявление переменных | `int x = 5;` | `x = 5` | `int x = 5;` или `var x = 5;` |
| Функции | `int add(int a, int b) { return a + b; }` | `def add(a, b): return a + b` | `int add(int a, int b) => a + b;` |
| Классы | `struct Point { int x; int y; };` | `class Point: pass` | `class Point { int x; int y; }` |
| Наследование | `#include`, struct inheritance | `class Child(Parent):` | `class Child extends Parent {}` |
| Интерфейсы | separate concept | duck typing | explicit interfaces via `implements` |
| Null safety | указатели, NULL | `None` | `?` nullable types (`String?`) |

### 1.2 Базовый синтаксис

#### Переменные

```dart
// Явная типизация (как в C)
int age = 25;
double price = 19.99;
String name = "Alice";
bool isActive = true;

// Неявная типизация (компилятор сам определяет тип)
var age2 = 25;           // int
var name2 = "Bob";       // String
var price2 = 19.99;      // double

// Nullable типы (может быть null) — специфика Dart
String? nullableName;    // может быть String или null
int? maybeNumber;        // может быть int или null

// Константы времени компиляции
const int maxItems = 100;
final DateTime now = DateTime.now();  // вычисляется один раз при запуске
```

**Пояснение:**
- `var` — компилятор сам выводит тип из присваиваемого значения
- `const` — значение должно быть известно на этапе компиляции
- `final` — значение присваивается один раз, но может быть вычислено в runtime
- `?` после типа — nullable (может быть null), как `Optional<T>` в Java/C++ или `Maybe` в Haskell

#### Функции

```dart
// Обычная функция (синтаксис похож на C)
int add(int a, int b) {
  return a + b;
}

// Стрелочная функция (однострочная) — как lambda в Python
int multiply(int a, int b) => a * b;

// Функция с необязательными параметрами
String greet(String name, [String? suffix]) {
  if (suffix != null) {
    return "Hello, $name $suffix";
  }
  return "Hello, $name";
}

// Именованные параметры с значениями по умолчанию
String createUrl(String host, {int port = 80, bool ssl = false}) {
  final protocol = ssl ? "https" : "http";
  return "$protocol://$host:$port";
}

// Использование:
greet("Alice");                      // позиционный
greet("Bob", "Jr.");                  // позиционный + опциональный
createUrl("example.com");             // именованные параметры
createUrl("example.com", port: 443, ssl: true);  // явные имена

// Callback/функция как параметр
void fetchData(void Function(String) onComplete) {
  // ... загрузка данных ...
  onComplete("данные получены");
}
```

**Пояснение:**
- `[Type?]` в квадратных скобках — опциональный параметр (может быть опущен)
- `{Type param = default}` в фигурных скобках — именованный параметр с дефолтом
- `=>` (стрелка) — сокращённая запись для функций, возвращающих одно выражение
- `$variable` или `${expression}` в строках — интерполяция строк (как f-strings в Python)

#### Классы

```dart
// Определение класса
class User {
  // Поля ( fields) — как структуры в C
  String name;
  int age;
  String? email;  // nullable — может быть null
  
  // Конструктор — специальный метод, вызывается при создании объекта
  User(this.name, this.age, [this.email]);
  
  // Именованный конструктор — несколько способов создания
  User.anonymous() : this("Anonymous", 0);
  
  // Конструктор с именованными параметрами
  User.guest({String? name}) : this(name ?? "Guest", 18);
  
  // Метод — функция внутри класса
  void sayHello() {
    print("Привет, я $name!");
  }
  
  // Геттер — вычисляемое свойство (как property в C#)
  bool get isAdult => age >= 18;
  
  // Сеттер — можно добавить валидацию
  set age(int newAge) {
    if (newAge >= 0) {
      age = newAge;
    }
  }
}

// Создание объекта
final user = User("Alice", 30, "alice@example.com");
user.sayHello();  // "Привет, я Alice!"

// Конструктор по умолчанию без параметров
class EmptyClass {
  EmptyClass();
}
```

**Пояснение:**
- `this.name` в конструкторе — сокращение для присваивания поля
- `: this(...)` в конструкторе — вызов другого конструктора (delegation)
- `get` и `set` — геттеры и сеттеры, используются как свойства
- `final` перед полем — поле нельзя изменить после создания объекта

#### Коллекции

```dart
// Списки (массивы) — динамические, как list в Python
List<int> numbers = [1, 2, 3, 4, 5];
var names = ["Alice", "Bob", "Charlie"];

// Доступ по индексу — как в C/Python
print(numbers[0]);  // 1
print(names[1]);    // "Bob"

// Методы списков
numbers.add(6);           // добавить в конец
numbers.remove(3);         // удалить элемент
numbers.contains(4);      // проверка наличия (True/False)
numbers.length;           // длина списка
numbers.map((n) => n * 2);  // трансформация (как list comprehension)
numbers.where((n) => n > 2);  // фильтрация

// Цикл for-each — как в Python
for (var number in numbers) {
  print(number);
}

// Множества (set) — уникальные элементы, без порядка
Set<String> uniqueNames = {"Alice", "Bob", "Alice"};  // {"Alice", "Bob"}

// Словари (map) — как dict в Python
Map<String, int> ages = {
  "Alice": 30,
  "Bob": 25,
};
print(ages["Alice"]);  // 30
ages["Charlie"] = 35;  // добавление
```

**Пояснение:**
- `List<Type>` — generic (обобщённый) тип, как `std::vector<Type>` в C++
- `Map<KeyType, ValueType>` — как словарь в Python, но с явной типизацией
- `=>` в `map()` и `where()` — стрелочная функция для трансформации/фильтрации
- `.` (точка) — доступ к методам и полям объекта

#### Null safety (система безопасности от null)

```dart
// Non-nullable — НЕ может быть null (по умолчанию)
String name = "Alice";  // OK
// name = null;         // ОШИБКА компиляции!

// Nullable — МОЖЕТ быть null
String? nullableName;  // пока null
nullableName = "Bob";  // OK
nullableName = null;   // OK

// Оператор ? (conditional access) — безопасный доступ
// Если nullableName не null — вернёт его length, иначе null
int? length = nullableName?.length;

// Оператор ?? (null coalescing) — значение по умолчанию
// Если nullableName не null — используем его, иначе "Unknown"
String displayName = nullableName ?? "Unknown";

// Оператор ! (bang) — утверждение что значение не null
// Используйте ТОЛЬКО если уверены что значение не null!
int definitelyLength = nullableName!.length;  // может вызвать ошибку если null!

// Проверка на null через if — компилятор понимает
if (nullableName != null) {
  // Здесь компилятор знает что nullableName не null
  print(nullableName.length);  // ! не нужен
}
```

**Пояснение:**
- Dart 2.12+ ввёл null safety по умолчанию — это защита от ошибок null pointer
- `?` после типа — "этот тип может быть null"
- `?.` — безопасный вызов метода (если объект null, вернёт null)
- `??` — если первый операнд null, использовать второй
- `!` — утверждение программиста "здесь точно не null"

#### Async/await (асинхронное программирование)

```dart
// Future<T> — объект, который будет иметь значение типа T в будущем
// Похоже на Promise в JavaScript, asyncio в Python

Future<String> fetchUserData() async {
  // await приостанавливает выполнение до получения результата
  // другие операции в это время могут выполняться
  final response = await http.get('https://api.example.com/user');
  return response.body;
}

// async функция всегда возвращает Future
Future<int> calculateSum(int a, int b) async {
  await Future.delayed(Duration(seconds: 1));  // имитация задержки
  return a + b;
}

// Обработка результата
void main() async {
  print("Начало");
  
  // Вариант 1: await (как синхронный код)
  String data = await fetchUserData();
  print("Получено: $data");
  
  // Вариант 2: then (цепочка callbacks)
  fetchUserData().then((data) {
    print("Получено через then: $data");
  });
  
  // Вариант 3: try-catch для ошибок
  try {
    String data = await fetchUserData();
    print("Успех: $data");
  } catch (error) {
    print("Ошибка: $error");
  }
  
  print("Конец");
}
```

**Пояснение:**
- `async` — функция асинхронная (выполняется параллельно с другим кодом)
- `await` — ждёт результат Future, не блокируя другие операции
- `Future<T>` — обещание вернуть значение типа T когда-нибудь
- `catchError` или `try-catch` — обработка ошибок в async коде

#### Расширения и миксины

```dart
// Extension — добавление методов к существующему классу
extension StringExtensions on String {
  bool get isEmail => this.contains('@') && this.contains('.');
  
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// Использование
"alice@example.com".isEmail;    // true
"hello".capitalize();          // "Hello"

// Mixin — повторно используемый код, который можно "вмешать" в класс
mixin Logger {
  void log(String message) {
    print('[LOG] $message');
  }
}

// with — включение миксина в класс
class User with Logger {
  String name;
  User(this.name);
  
  void doSomething() {
    log("Пользователь $name что-то сделал");
  }
}
```

---

## 2. Основы Flutter

### 2.1 Что такое Flutter и Widget

**Flutter** — это SDK от Google для создания кроссплатформенных приложений (iOS, Android, Web, Desktop).

**Widget** — это базовый строительный блок UI в Flutter. Всё на экране — виджет:
- Текст (`Text`)
- Кнопка (`ElevatedButton`)
- Изображение (`Image`)
- Список (`ListView`)
- Экран приложения (`Scaffold`)

### 2.2 StatelessWidget — виджет без состояния

```dart
// StatelessWidget — виджет который НЕ меняется после создания
class MyText extends StatelessWidget {
  final String message;  // final — нельзя изменить после создания
  
  // Конструктор с именованным параметром
  const MyText({super.key, required this.message});
  
  // build — главный метод, возвращает UI виджета
  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(fontSize: 24, color: Colors.blue),
    );
  }
}

// Использование
MyText(message: "Привет!")
```

**Пояснение:**
- `super.key` — передаёт key родительскому виджету (для идентификации)
- `required` — обязательный именованный параметр
- `@override` — аннотация что метод переопределяет родительский
- `build(BuildContext context)` — вызывается Flutter для отрисовки виджета
- `context` — содержит информацию о теме, навигации, размере экрана

### 2.3 StatefulWidget — виджет с состоянием

```dart
// StatefulWidget — виджет который МОЖЕТ менять состояние
class Counter extends StatefulWidget {
  const Counter({super.key});  // super.key — стандартный параметр Flutter
  
  @override
  // createState — создаёт объект состояния
  State<Counter> createState() => _CounterState();
}

// State — класс содержащий данные виджета
class _CounterState extends State<Counter> {
  int _count = 0;  // _ в начале — private ( приватное поле)
  
  // setState — сообщает Flutter что данные изменились, нужно перерисовать
  void _increment() {
    setState(() {
      _count++;  // изменяем данные
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Счётчик: $_count'),
        ElevatedButton(
          onPressed: _increment,  // передаём функцию как callback
          child: Text('+1'),
        ),
      ],
    );
  }
}
```

**Пояснение:**
- `_` перед именем — приватный модификатор (как `private` в C++)
- `State` — generic тип: `State<Counter>` означает "состояние виджета Counter"
- `setState()` — вызывается когда данные изменились, триггерит перерисовку
- `children: [...]` — список дочерних виджетов (как children в React)

### 2.4 Основные виджеты

```dart
// Scaffold — базовый каркас экрана (AppBar + Body + FAB и т.д.)
Scaffold(
  appBar: AppBar(
    title: Text("Мой экран"),
    actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
  ),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,  // центрирование по вертикали
      children: [
        Text("Привет!"),
        ElevatedButton(
          onPressed: () => print("Нажата!"),
          child: Text("Нажми меня"),
        ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
);

// Column — вертикальный контейнер (как VBox в Tkinter)
// Row — горизонтальный контейнер (как HBox)

// Padding — отступы
Padding(
  padding: EdgeInsets.all(16),  // 16 пикселей со всех сторон
  child: Text("Текст с отступами"),
);

// Container — универсальный контейнер (как div в CSS)
Container(
  width: 200,
  height: 100,
  margin: EdgeInsets.symmetric(horizontal: 20),  // отступы
  padding: EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),  // скруглённые углы
  ),
  child: Text("Styled Container"),
);
```

### 2.5 Навигация между экранами

```dart
// Переход на новый экран
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(itemId: 123),
  ),
);

// Возврат на предыдущий экран
Navigator.pop(context);

// Переход с заменой текущего экрана (без возврата)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
);

// Получение данных при возврате
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => SelectScreen()),
);
// result содержит данные возвращённые из SelectScreen
```

### 2.6 Работа с Firestore

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Получение документа
Future<Map<String, dynamic>?> getUser(String email) async {
  final doc = await FirebaseFirestore.instance
      .collection('Users')           // коллекция (таблица)
      .doc(email)                    // документ по ID
      .get();
  
  return doc.data();  // вернёт Map или null если документа нет
}

// Сохранение/обновление документа
Future<void> saveUser(String email, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(email)
      .set(data, SetOptions(merge: true));  // merge — не перезаписывать существующие поля
}

// Добавление в массив
Future<void> addToFavorites(String email, String imageUrl) async {
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(email)
      .update({
    'favorites': FieldValue.arrayUnion([imageUrl]),  // добавить элемент
    // FieldValue.arrayRemove([imageUrl]) — удалить элемент
  });
}

// Запрос к коллекции
Future<List<Map<String, dynamic>>> getPosts() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('Posts')
      .where('author', isEqualTo: 'alice@example.com')  // фильтр
      .orderBy('createdAt', descending: true)           // сортировка
      .limit(20)                                        // лимит
      .get();
  
  return snapshot.docs.map((doc) => doc.data()).toList();
}
```

**Пояснение:**
- `Collection` — коллекция документов (аналог таблицы в SQL)
- `Document` — отдельная запись (аналог строки в SQL)
- `.doc(id)` — получение/создание документа по ID
- `FieldValue.arrayUnion()` — добавить элемент в массив если его там нет
- `.where()` — фильтрация (аналог WHERE в SQL)
- `.orderBy()` — сортировка (аналог ORDER BY)

---

## 3. Общая архитектура проекта

Проект **Stylee** — это мобильное приложение для подбора одежды и стиля с ИИ-помощником.

### Структура проекта

```
stylee_upprpo_24943/
├── stylee_app/           # Flutter-приложение
│   ├── lib/
│   │   ├── auth/         # Аутентификация и профиль
│   │   ├── components/   # Переиспользуемые виджеты
│   │   ├── models/       # Модели данных
│   │   ├── screens/      # Экраны приложения
│   │   │   ├── quiz/     # Квиз для определения стиля
│   │   │   └── wardrobe/ # Компоненты гардероба
│   │   └── services/     # API-сервисы
│   └── pubspec.yaml
│
├── backend/              # Python-бэкенд (FastAPI)
│   ├── app.py            # Основное приложение
│   ├── marketplace_real.py # Парсеры маркетплейсов
│   └── requirements.txt
│
└── ai_model/             # AI/ML модули
    ├── scrapping_weather/ # Парсинг погоды
    └── quiz_functions/   # Функции для квиза
```

### Технологический стек

| Компонент | Технологии |
|-----------|------------|
| **Frontend** | Flutter, Dart, Firebase Auth, Firestore |
| **Backend** | Python, FastAPI, SQLite |
| **AI** | OpenRouter API (Qwen VL Plus) |
| **Images** | Firebase Storage, imagehash |
| **Marketplaces** | Wildberries, Ozon, Яндекс.Маркет |

---

## 4. Хронология коммитов

### Февраль 2026 — Инициализация проекта

#### 🔹 `0d447ca` — add flutter (17.02.2026, verrronikka)

**Описание**: Создание базовой Flutter-структуры проекта.

Создан полноценный Flutter-проект с настройками для Android, iOS, Linux, macOS, Windows и Web платформ.

**Затронутые файлы**:
- `flutter_app_stylee/` — полная структура Flutter-приложения
- `lib/main.dart` — точка входа
- `pubspec.yaml` — зависимости

**pubspec.yaml** (ключевые зависимости):
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.1
```

---

### Апрель 2026 — Основная функциональность

#### 🔹 `d9987ed` — игнор (03.04.2026, Naskok)

**Описание**: Добавление `.env` файла в `.gitignore`.

**Изменения**:
```gitignore
# Added
.env
```

**Зачем**: Защита конфиденциальных данных (API-ключи, токены).

---

#### 🔹 `8a81662` — уязвимость с ключем (07.04.2026, Naskok)

**Описание**: Исправление уязвимости с API-ключами.

**Изменения**:
```dart
// stylee_app/lib/services/openrouter_service.dart
// ПЕРЕД: API-ключ захардкожен
const String _apiKey = 'sk-or-xxx';

// ПОСЛЕ: Загрузка из .env файла
final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
```

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0  # Добавлена новая зависимость
```

---

#### 🔹 `538c523` — Удаление "лишней" папки, опрос пользователя при первом входе (10.04.2026, Naskok)

**Описание**: Рефакторинг — удаление старой Flutter-папки и добавление онбординга.

**Изменения** (133 файла изменено):
```
УДАЛЕНО: flutter_app_stylee/ (весь проект)
ДОБАВЛЕНО:
  - stylee_app/lib/auth/auth.dart (обновлён)
  - stylee_app/lib/models/test_result.dart (новый)
  - stylee_app/lib/screens/onboarding_test_screen.dart (новый)
```

**Ключевой код** — `onboarding_test_screen.dart`:
```dart
class OnboardingTestScreen extends StatelessWidget {
  // Опрос при первом входе
  // Собирает данные о стиле пользователя:
  // - Цвета
  // - Размеры
  // - Предпочтения
  // - Сезонность
}
```

---

#### 🔹 `f22b8c7` — быстрый подбор образа по фильтрам (10.04.2026, Naskok)

**Описание**: Добавление системы фильтрации образов.

**Новые файлы**:
```dart
// stylee_app/lib/models/outfit.dart
class Outfit {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> tags; // ['работа', 'лето', 'casual']
  final String weather;    // 'жарко', 'прохладно', 'дождь'
  final String event;       // 'работа', 'вечеринка', 'прогулка'
}
```

```dart
// stylee_app/lib/screens/outfit_picker_screen.dart
// Экран быстрого подбора образа с фильтрами:
// - По погоде
// - По мероприятию
// - По цвету
// - По сезону
```

**Пример использования фильтров**:
```dart
List<Outfit> filterOutfits(List<Outfit> outfits, OutfitFilters filters) {
  return outfits.where((outfit) {
    if (filters.weather != null && outfit.weather != filters.weather) {
      return false;
    }
    if (filters.event != null && !outfit.tags.contains(filters.event)) {
      return false;
    }
    return true;
  }).toList();
}
```

---

#### 🔹 `6ab9c2a` — избранное (16.04.2026, Naskok)

**Описание**: Система избранных образов и изображений.

**Новые файлы**:
```dart
// stylee_app/lib/components/favorite_post_button.dart
class FavoritePostButton extends StatefulWidget {
  final String postId;
  final String userId;
  // Кнопка для добавления/удаления поста из избранного
}

// stylee_app/lib/screens/favorite_images_screen.dart
class FavoriteImagesScreen extends StatelessWidget {
  // Экран отображения избранных изображений пользователя
  // Интеграция с Firebase Storage для сохранения изображений
}
```

**Интеграция с Firestore**:
```dart
// Добавление в избранное
await _firestore
    .collection('Users')
    .doc(userEmail)
    .update({
  'favorites': FieldValue.arrayUnion([imageUrl])
});

// Удаление из избранного
await _firestore
    .collection('Users')
    .doc(userEmail)
    .update({
  'favorites': FieldValue.arrayRemove([imageUrl])
});
```

---

#### 🔹 `9ffd424` — add wardrobe (03.05.2026, verrronikka)

**Описание**: Полноценная система гардероба с разделами.

**Новые файлы** (29 файлов изменено, ~5000 строк):
```dart
// stylee_app/lib/models/wardrobe_item.dart
class WardrobeItem {
  final String id;
  final String name;
  final String category;    // 'верх', 'низ', 'обувь', 'аксессуары'
  final String color;
  final String season;      // 'лето', 'зима', 'весна', 'осень'
  final String? imageUrl;
  final String sectionId;   // К какому разделу относится
}

// stylee_app/lib/models/wardrobe_section.dart
class WardrobeSection {
  final String id;
  final String name;
  final String emoji;
  final List<WardrobeItem> items;
}

// stylee_app/lib/services/wardrobe_service.dart
class WardrobeService {
  // Сервис для управления гардеробом
  // CRUD операции для секций и элементов
}
```

**Новые компоненты UI**:
```dart
// wardrobe_section_card.dart — карточка раздела гардероба
// create_section_dialog.dart — диалог создания раздела
// section_picker_dialog.dart — выбор раздела при добавлении
```

---

#### 🔹 `cbe56d8` — модель для дизлайков (22.04.2026, OhButWhy)

**Описание**: Создание модели данных для хранения дизлайков пользователя.

**Новые файлы**:

```dart
// stylee_app/lib/models/dislike.dart
// ============================================================================
// ЧТО ТАКОЕ МОДЕЛЬ ДАННЫХ?
// Модель (model) — это класс, описывающий структуру данных в приложении.
// В данном случае мы создаём модель Dislike для хранения информации о дизлайках.
// 
// АНАЛОГИЯ:
// В C: struct Dislike { char* id; char* description; ... }
// В Python: dataclass с полями
// В SQL: таблица с колонками
// ============================================================================

/// Модель для хранения информации о дизлайке
/// 
/// Ключевые концепции Dart здесь:
/// - class — объявление класса (как struct в C, но с методами)
/// - final — поле можно задать один раз при создании, нельзя изменить после
/// - required — параметр обязателен при создании объекта
/// - Map<String, dynamic> — словарь с ключами-строками и значениями любого типа
/// - factory — фабричный конструктор (создаёт объект особым способом)
class Dislike {
  // ==========================================================================
  // ПОЛЯ КЛАССА — переменные принадлежащие объекту (как поля структуры в C)
  // ==========================================================================
  
  /// Уникальный идентификатор дизлайка
  /// final = нельзя изменить после создания объекта
  /// String = тип данных (строка)
  final String id;
  
  /// Описание: что именно дизлайкнули ("розовые брюки", "клетчатые рубашки")
  final String description;
  
  /// Категория дизлайка: 
  ///   'clothing' — тип одежды
  ///   'color' — цвет
  ///   'style' — стиль
  ///   'pattern' — узор
  ///   'brand' — бренд
  final String category;
  
  /// Дата и время когда был добавлен дизлайк
  /// DateTime — класс для работы с датой и временем (как datetime в Python)
  final DateTime createdAt;

  // ==========================================================================
  // КОНСТРУКТОР — метод для создания объекта Dislike
  // ==========================================================================
  // В Dart конструктор имеет то же имя что и класс
  // this.<field> — сокращение для присваивания параметра полю
  //
  // Пример: Dislike(id: '...', description: '...', ...)
  // Автоматически присвоит: this.id = '...', this.description = '...'
  
  Dislike({
    required this.id,           // required = обязательный параметр
    required this.description,  // Ошибка компиляции если не передать
    required this.category,     // Все 4 поля обязательны
    required this.createdAt,
  });
  
  // ==========================================================================
  // МЕТОД toMap() — преобразование объекта в словарь (для сохранения в БД)
  // ==========================================================================
  // Firestore хранит данные как Map (словарь/JSON объект)
  // Этот метод конвертирует объект Dislike в формат для хранения
  //
  // АНАЛОГИЯ В PYTHON:
  // def to_dict(self):
  //     return {'id': self.id, 'description': self.description, ...}
  
  Map<String, dynamic> toMap() {
    // Возвращаем словарь {ключ: значение}
    return {
      'id': id,                 // строка
      'description': description,  // строка
      'category': category,    // строка
      'createdAt': createdAt,  // DateTime — Firebase сохранит как timestamp
    };
    // Результат: {'id': 'pink_trousers', 'description': 'розовые брюки', ...}
  }
  
  // ==========================================================================
  // ФАБРИЧНЫЙ КОНСТРУКТОР fromMap() — создание объекта из словаря
  // ==========================================================================
  // factory = особый тип конструктора
  // Может вернуть существующий объект или создать новый особым способом
  // Этот метод создаёт Dislike из данных полученных из Firestore
  //
  // АНАЛОГИЯ В PYTHON:
  // @classmethod
  // def from_dict(cls, data):
  //     return cls(id=data['id'], description=data['description'], ...)
  
  factory Dislike.fromMap(Map<String, dynamic> map) {
    // map — словарь полученный из Firestore
    // map['field'] — доступ к значению по ключу (как dict['field'] в Python)
    
    return Dislike(
      // ?? — оператор "если левое значение null, использовать правое"
      // АНАЛОГ В PYTHON: data.get('id') or ''
      id: map['id'] ?? '',  // Если id нет в данных — пустая строка
      
      description: map['description'] ?? '',  // Если нет — пустая строка
      
      category: map['category'] ?? 'general',  // Если нет — 'general'
      
      // Firebase хранит даты как Timestamp, нужно конвертировать в DateTime
      // (map['createdAt'] as dynamic) — приводим к dynamic чтобы вызвать toDate()
      // ?.toDate() — безопасный вызов (если null, вернёт null, не ошибку)
      // ?? DateTime.now() — если toDate() вернул null, берём текущее время
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
  
  // ==========================================================================
  // ПЕРЕОПРЕДЕЛЕНИЕ toString() — для удобного вывода при отладке
  // ==========================================================================
  // @override = аннотация что мы переопределяем метод родительского класса (Object)
  // => — стрелочная функция (однострочный return)
  
  @override
  String toString() => 'Dislike(id: $id, description: $description, category: $category)';
  // $variable = интерполяция строк (вставляет значение переменной)
  // АНАЛОГ В PYTHON: f"Dislike(id={id}, description={description}, ...)"
}
```

**Подробный разбор синтаксиса Dart:**

| Синтаксис Dart | Аналог в C | Аналог в Python | Пояснение |
|----------------|-----------|-----------------|-----------|
| `class Dislike { }` | `struct Dislike { };` | `class Dislike:` | Объявление класса |
| `final String id;` | `const char* id;` | `self.id = ...` (в `__init__`) | Неизменяемое поле |
| `required this.id` | параметр struct | параметр `__init__` | Обязательный параметр |
| `Map<String, dynamic>` | `json_object*` | `dict` | Словарь с типизацией |
| `?? 'default'` | тернарный `?:` | `or 'default'` | Null coalescing |
| `?.toDate()` | `->toDate()` | `.to_date()` с проверкой | Безопасный вызов |
| `factory Dislike.fromMap(...)` | статическая функция | `@classmethod from_dict(...)` | Фабричный конструктор |
| `$variable` | `printf("%s", var)` | `f"{variable}"` | Интерполяция строк |
| `@override` | virtual override | `@override` | Аннотация переопределения |
| `=> expression` | inline return | lambda | Стрелочная функция |

---

**Как это работает в приложении:**

```dart
// === СОЗДАНИЕ ДИЗЛАЙКА ===
// Создаём новый объект Dislike с данными
final dislike = Dislike(
  id: 'pink_trousers',           // уникальный ID
  description: 'розовые брюки',  // что не понравилось
  category: 'clothing',          // категория
  createdAt: DateTime.now(),     // текущее время
);

// === СОХРАНЕНИЕ В FIREBASE ===
// Firebase не понимает объекты Dart, только словари (Map)
// Поэтому конвертируем: Dislike -> Map
final dislikeMap = dislike.toMap();
// Результат: {'id': 'pink_trousers', 'description': 'розовые брюки', 
//             'category': 'clothing', 'createdAt': Timestamp(...)}

// Сохраняем в коллекцию Users, в документ пользователя
// arrayUnion — добавляет элемент в массив (если его там нет)
await FirebaseFirestore.instance
    .collection('Users')
    .doc('user@example.com')
    .update({
  'dislikes': FieldValue.arrayUnion([dislikeMap]),
});

// === ЗАГРУЗКА ИЗ FIREBASE ===
// Получаем документ пользователя
final doc = await FirebaseFirestore.instance
    .collection('Users')
    .doc('user@example.com')
    .get();

// Берём поле 'dislikes' — это массив словарей
final dislikesData = doc.data()?['dislikes'] as List? ?? [];

// Конвертируем каждый словарь обратно в объект Dislike
// Map -> Dislike с помощью фабричного конструктора
final dislikes = dislikesData
    .map((data) => Dislike.fromMap(data as Map<String, dynamic>))
    .toList();

// Теперь у нас есть список объектов Dislike для работы
for (final d in dislikes) {
  print('${d.description} (${d.category})');  
  // Вывод: "розовые брюки (clothing)"
}
```

---

**Сервис для работы с дизлайками:**

```dart
// stylee_app/lib/services/dislike_service.dart
// ============================================================================
// СЕРВИС — класс содержащий бизнес-логику для работы с дизлайками
// ============================================================================
// Сервисы в Flutter используются для отделения логики от UI
// Это следует паттерну "Service Layer" (сервисный слой)
// ============================================================================

class DislikeService {
  // --------------------------------------------------------------------------
  // ПОЛЕ КЛАССА — экземпляр Firestore для работы с базой данных
  // --------------------------------------------------------------------------
  // FirebaseFirestore — класс для взаимодействия с Firebase Firestore
  // .instance — статический метод, возвращает единственный экземпляр
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // _firestore — приватное поле ( underscore в начале = private)

  // --------------------------------------------------------------------------
  // МЕТОД saveDisilike() — сохранение нового дизлайка
  // --------------------------------------------------------------------------
  // async = асинхронная функция (не блокирует UI пока выполняется)
  // void = функция ничего не возвращает
  // required — обязательные параметры
  // Future<void> — "когда-нибудь завершится, ничего не возвращая"
  
  Future<void> saveDisilike({
    required String userEmail,     // email пользователя (ID документа)
    required String description,   // описание дизлайка
    required String category,      // категория
  }) async {
    // Создаём объект Dislike с переданными параметрами
    final dislike = Dislike(
      id: description.toLowerCase().replaceAll(' ', '_'),
      // 'Розовые Брюки' -> 'розовые_брюки'
      // Простой способ генерации ID на основе описания
      
      description: description,  // сохраняем оригинальное описание
      category: category,
      createdAt: DateTime.now(),  // текущее время
    );

    try {
      // Обращаемся к коллекции 'Users', к документу с email
      // .update() — обновляет документ (не перезаписывает весь!)
      // Если документа нет — создаст новый
      
      await _firestore
          .collection('Users')           // коллекция (аналог таблицы)
          .doc(userEmail)                // документ по email (аналог строки)
          .update({
        // Поле 'dislikes' — массив дизлайков
        // FieldValue.arrayUnion — добавить элемент в массив
        // Элемент добавится только если его там нет (дубликаты не создаются)
        'dislikes': FieldValue.arrayUnion([dislike.toMap()]),
      });
      // dislike.toMap() — конвертируем объект в словарь для Firebase
      
      print('Дизлайк сохранён: $description');
      // $description — интерполяция строки (вставляет значение)
      
    } catch (e) {
      // catch — перехват исключений (как в Python)
      print('Ошибка сохранения дизлайка: $e');
      rethrow;  // пробросить ошибку дальше (вызвавший код получит её)
    }
  }

  // --------------------------------------------------------------------------
  // МЕТОД getDislikes() — получение всех дизлайков пользователя
  // --------------------------------------------------------------------------
  // Future<List<Dislike>> — асинхронно вернёт список объектов Dislike
  
  Future<List<Dislike>> getDislikes(String userEmail) async {
    try {
      // Получаем документ пользователя
      final doc = await _firestore
          .collection('Users')
          .doc(userEmail)
          .get();
      // .get() — асинхронное получение документа из Firebase

      // doc.exists — проверяет существует ли документ
      if (!doc.exists) {
        return [];  // если нет — возвращаем пустой список
      }

      // doc.data() — получение данных документа как словаря
      final data = doc.data();
      
      // data?['dislikes'] — безопасный доступ (если data null, вернёт null)
      // ?? [] — если null, используем пустой список
      // as List — приведение типа к List
      // <dynamic> — generic параметр (список может содержать любые типы)
      final dislikesList = data?['dislikes'] as List<dynamic>? ?? [];

      // .map() — трансформация списка (аналог list comprehension)
      // Для каждого элемента вызываем Dislike.fromMap()
      // .toList() — конвертируем результат map в List
      return dislikesList
          .map((d) => Dislike.fromMap(d as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      print('Ошибка загрузки дизлайков: $e');
      return [];  // при ошибке возвращаем пустой список
    }
  }

  // --------------------------------------------------------------------------
  // МЕТОД buildExcludeSection() — построение текста для ИИ-промпта
  // --------------------------------------------------------------------------
  // Этот метод создаёт текстовый блок, который добавляется в промпт ИИ
  // чтобы ИИ знал что пользователю НЕ предлагать
  
  String buildExcludeSection(List<Dislike> dislikes) {
    // Проверяем пустой ли список
    if (dislikes.isEmpty) {  // .isEmpty — проверка на пустоту списка
      return '';  // возвращаем пустую строку (не добавляем блок в промпт)
    }
    
    // Если есть дизлайки — создаём текстовый блок
    String section = '\n\nВАЖНО: Пользователь НЕ любит:\n';
    
    // Цикл for-each — аналог for item in list в Python
    for (final d in dislikes) {
      // section += — конкатенация строк (добавление к существующей)
      section += '- ${d.description} (категория: ${d.category})\n';
      // ${d.description} — интерполяция с доступом к полю объекта
    }
    
    section += 'Не предлагайте товары или образы содержащие перечисленное.';
    
    return section;
    // Результат:
    // "
    //
    // ВАЖНО: Пользователь НЕ любит:
    // - розовые брюки (категория: clothing)
    // - клетка (категория: pattern)
    // Не предлагайте товары или образы содержащие перечисленное."
  }
}
```

---

**Ключевые концепции сервиса:**

| Концепция | Пояснение |
|-----------|-----------|
| `FirebaseFirestore.instance` | Единственный экземпляр Firestore (singleton pattern) |
| `_firestore` | Приватное поле ( underscore = private в Dart) |
| `async/await` | Асинхронное программирование (как asyncio в Python) |
| `Future<T>` | Обещание вернуть T в будущем (как Promise в JS) |
| `try/catch` | Обработка исключений (как в Python) |
| `FieldValue.arrayUnion()` | Операция Firestore — добавить в массив |
| `.map().toList()` | Трансформация списка (как list comprehension) |
| `rethrow` | Пробросить перехваченную ошибку выше |

---

#### 🔹 `9cc93ca` — инициализация дизлайков для пользователей (22.04.2026, OhButWhy)

**Описание**: Автоматическая инициализация коллекции дизлайков при регистрации.

**Изменения** в `auth.dart`:
```dart
// При создании нового пользователя
Future<UserCredential> signUp(...) async {
  // ... регистрация ...
  
  // Инициализация дизлайков
  await _firestore.collection('Users').doc(email).set({
    'dislikes': [],  // Пустой массив для дизлайков
  });
}
```

---

#### 🔹 `8eaaca0` — ИИ теперь учитывает дизлайки (22.04.2026, OhButWhy)

**Описание**: Интеграция дизлайков в системный промпт ИИ-стилиста.

**Изменения** в `openrouter_service.dart`:

```dart
// stylee_app/lib/services/openrouter_service.dart
// ============================================================================
// СЕРВИС OpenRouter — взаимодействие с ИИ-стилистом через OpenRouter API
// ============================================================================
// OpenRouter — это сервис-агрегатор различных ИИ-моделей
// (Qwen, GPT, Claude и др.). Мы используем Qwen VL (Vision Language)
// для анализа изображений и текстовых запросов
// ============================================================================

class OpenRouterService {
  // --------------------------------------------------------------------------
  // API ключ — загружается из .env файла
  // --------------------------------------------------------------------------
  // dotenv.env — словарь переменных окружения из .env файла
  // dotenv.env['KEY'] ?? 'default' — получить значение или использовать дефолт
  // final — константа (нельзя изменить после присвоения)
  final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  // --------------------------------------------------------------------------
  // Поздняя инициализация сервиса дизлайков
  // --------------------------------------------------------------------------
  // late — "будет инициализировано позже, до первого использования"
  // Это позволяет избежать циклических зависимостей при создании объектов
  late DislikeService _dislikeService;
  
  // Конструктор — инициализируем _dislikeService
  OpenRouterService() {
    _dislikeService = DislikeService();
  }

  // ==========================================================================
  // МЕТОД getStyleAdvice() — текстовый запрос к ИИ
  // ==========================================================================
  // Future<String> — асинхронная функция, вернёт строку когда-нибудь
  // async — функция может приостанавливать выполнение (await)
  
  Future<String> getStyleAdvice(
    String userMessage, {
    // Позиционные параметры идут без скобок
    // {...} — именованные параметры (передаются по имени)
    
    // List<Dislike> — список объектов Dislike
    // = const [] — значение по умолчанию (пустой список)
    List<Dislike> dislikes = const [],
    // const — создаёт неизменяемый объект (как кортеж в Python)
  }) async {
    // Проверка наличия API ключа
    if (_apiKey.isEmpty) {
      // return — возврат значения из функции
      return '❌ Ошибка: API ключ не настроен.';
    }

    // --------------------------------------------------------------------------
    // ПОСТРОЕНИЕ СИСТЕМНОГО ПРОМПТА С УЧЁТОМ ДИЗЛАЙКОВ
    // --------------------------------------------------------------------------
    // _buildSystemPrompt — приватный метод ( underscore = private)
    final systemPrompt = _buildSystemPrompt(dislikes);

    // --------------------------------------------------------------------------
    // ФОРМИРОВАНИЕ ТЕЛА ЗАПРОСА К API
    // --------------------------------------------------------------------------
    // jsonEncode — сериализация объекта в JSON строку
    // аналог json.dumps() в Python
    final body = jsonEncode({
      'model': 'qwen/qwen-vl-plus',  // Модель ИИ
      'messages': [
        // messages — история диалога
        // role: 'system' — системные инструкции для ИИ
        {
          'role': 'system',
          'content': systemPrompt,  // Промпт с дизлайками
        },
        // role: 'user' — сообщение пользователя
        {'role': 'user', 'content': userMessage},
      ],
    });

    // --------------------------------------------------------------------------
    // ОТПРАВКА HTTP POST ЗАПРОСА
    // --------------------------------------------------------------------------
    
    try {
      // await — ждём завершения асинхронной операции
      // http.post — POST запрос (как requests.post() в Python)
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        // Uri.parse — преобразование строки в объект Uri
        // (аналог urllib.parse.urlparse() в Python)
        
        headers: {
          // Authorization — заголовок авторизации
          // Bearer — тип аутентификации (стандарт для API)
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',  // Тип контента
        },
        body: body,  // Тело запроса (наш JSON)
      );

      // Проверка кода ответа HTTP
      // 200 = успех, 401 = нет доступа, 500 = ошибка сервера и т.д.
      if (response.statusCode == 200) {
        // jsonDecode — парсинг JSON строки в Dart объект
        // аналог json.loads() в Python
        final data = jsonDecode(response.body);
        
        // Доступ к вложенным данным JSON
        // data['choices'][0]['message']['content']
        // Аналог в Python: data['choices'][0]['message']['content']
        return data['choices'][0]['message']['content'];
      } else {
        return '❌ Ошибка API: код ${response.statusCode}';
      }
    } catch (e) {
      // catch — перехват исключений (как в Python try/except)
      return '❌ Ошибка: $e';
    }
  }

  // ==========================================================================
  // PRIVATE МЕТОД _buildSystemPrompt() — построение промпта
  // ==========================================================================
  // _ в начале имени = приватный метод (не виден снаружи класса)
  
  String _buildSystemPrompt(List<Dislike> dislikes) {
    // Базовый промпт — инструкции для ИИ-стилиста
    // '''текст''' — многострочная строка (аналог """текст""" в Python)
    String prompt = '''Ты ИИ-стилист для приложения Stylee. 
Отвечай ТОЛЬКО на русском языке.
Ты помогаешь пользователям подбирать одежду и стиль.
Будь дружелюбным и давай практичные советы.''';

    // --------------------------------------------------------------------------
    // ДОБАВЛЕНИЕ БЛОКА С ДИЗЛАЙКАМИ
    // --------------------------------------------------------------------------
    // if (условие) — условный оператор (как в C/Python)
    // isNotEmpty — метод проверки на непустоту (противоположность isEmpty)
    
    if (dislikes.isNotEmpty) {
      // prompt += — конкатенация строк (добавление к существующей)
      prompt += '\n\n⚠️ ВАЖНО: Пользователь НЕ любит:\n';
      
      // Цикл for-each — аналог for item in list в Python
      // final d — объявление переменной цикла
      for (final d in dislikes) {
        // d.description — доступ к полю объекта (точка как в C/Python)
        prompt += '• ${d.description}';
        prompt += ' (категория: ${d.category})\n';
        // ${переменная} — интерполяция строк (вставка значения)
        // Аналог f"{переменная}" в Python
      }
      
      prompt += '\nУчитывай это при рекомендациях!';
    }

    return prompt;
  }
}
```

**Ключевые концепции Dart в этом коде:**

| Синтаксис | Аналог в Python | Пояснение |
|-----------|----------------|-----------|
| `final String _apiKey` | `self._api_key` | Неизменяемое поле |
| `late DislikeService` | (поздняя инициализация) | Специфика Dart |
| `async/await` | `async/await` | Асинхронность |
| `Future<String>` | `Coroutine[str]` | Тип возврата async функции |
| `jsonEncode({})` | `json.dumps({})` | Сериализация JSON |
| `jsonDecode(string)` | `json.loads(string)` | Парсинг JSON |
| `Uri.parse(url)` | `urllib.parse` | Парсинг URL |
| `'''многострочный'''` | `"""многострочный"""` | Строковый литерал |
| `prompt += text` | `prompt += text` | Конкатенация |
| `for (final d in list)` | `for d in list:` | Цикл for-each |
| `${d.field}` | `f"{d.field}"` | Интерполяция строк |

**Как работает интеграция дизлайков:**

```
┌──────────────────────────────────────────────────────────────┐
│  1. Пользователь нажимает "💔 Не нравится" на товаре         │
│                          ↓                                    │
│  2. Открывается диалог выбора категории                      │
│                          ↓                                    │
│  3. DislikeService.saveDislike()                              │
│     └── Сохраняет в Firestore: Users/{email}/dislikes        │
│                          ↓                                    │
│  4. При следующем запросе к ИИ:                               │
│     dislikes = await DislikeService.getDislikes(email)        │
│                          ↓                                    │
│  5. _buildSystemPrompt(dislikes) формирует блок:             │
│     "⚠️ ВАЖНО: Пользователь НЕ любит:                        │
│      • розовые брюки (категория: clothing)"                  │
│                          ↓                                    │
│  6. Этот блок добавляется в system prompt ИИ                 │
│                          ↓                                    │
│  7. ИИ учитывает дизлайки и НЕ предлагает такие товары       │
└──────────────────────────────────────────────────────────────┘
```

---

#### 🔹 `c0b0bcd` — дизлайк фронт (22.04.2026, OhButWhy)

**Описание**: UI для добавления дизлайков в приложении.

**Новый компонент** в `like_button.dart`:
```dart
class DislikeButton extends StatefulWidget {
  final String itemId;
  final String description;
  final String category;
  // Длинное нажатие на кнопку "не нравится"
  // открывает диалог выбора категории дизлайка
}
```

---

### Май 2026 — Интеграция и улучшения

#### 🔹 `a4fec67` — перенос бэка на питон (30.04.2026, OhButWhy)

**Описание**: Миграция с Firebase Cloud Functions на Python FastAPI бэкенд.

Это один из ключевых коммитов проекта. До этого момента backend работал через Firebase Cloud Functions (серверные функции в облаке Google). Этот коммит заменяет их на собственный Python-сервер на FastAPI.

**Почему миграция?**

| Аспект | Firebase Cloud Functions | FastAPI |
|--------|--------------------------|---------|
| Стоимость | Платно за каждый вызов | Оплачивается только сервер |
| Гибкость | Ограничена Firebase | Полная свобода |
| Сложность | Нужно знать Firebase SDK | Стандартный Python |
| SQLite | Нет | Есть |
| WebSocket | Ограничен | Полная поддержка |

---

**Новые файлы**:

```python
# backend/app.py (682 строки)
# ============================================================================
# ЧТО ТАКОЕ FastAPI?
# ============================================================================
# FastAPI — это современный Python-фреймворк для создания веб-приложений
# и REST API. Он автоматически:
# - Генерирует документацию (Swagger UI) по адресу /docs
# - Валидирует входные данные
# - Поддерживает асинхронность (async/await)
# - Возвращает JSON ответы
#
# АНАЛОГИЯ:
# - Flask/Django — другие Python-фреймворки, но без автодокументации
# - Express.js — аналог в JavaScript/Node.js
# ============================================================================

from fastapi import FastAPI, HTTPException, Query
# Импортируем FastAPI и инструменты для работы с HTTP
# FastAPI — класс приложения
# HTTPException — для возврата ошибок HTTP (400, 404, 500)
# Query — для параметров запроса в URL (?page=1)

from fastapi.middleware.cors import CORSMiddleware
# CORS — Cross-Origin Resource Sharing
# Позволяет браузеру запрашивать данные с другого домена
# Без этого Flutter-приложение не сможет обращаться к бэкенду!

# ============================================================================
# СОЗДАНИЕ ПРИЛОЖЕНИЯ
# ============================================================================
# app = FastAPI(...) — создаём экземпляр веб-приложения
# title= — название для документации
# lifespan= — функция выполняется при старте/остановке сервера

app = FastAPI(title="Stylee Python Backend")

# ============================================================================
# CORS MIDDLEWARE — разрешаем запросы с любых доменов
# ============================================================================
# Это КРИТИЧЕСКИ важно для Flutter!
# Без этого браузер заблокирует запросы от приложения к серверу
# because 'Access-Control-Allow-Origin' header is missing

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # Разрешить запросы с ЛЮБОГО домена
    allow_credentials=True,   # Разрешить cookies/авторизацию
    allow_methods=["*"],     # Разрешить все HTTP-методы (GET, POST...)
    allow_headers=["*"],      # Разрешить все заголовки
)
```

---

**Основные эндпоинты API:**

```
HTTP Метод + URL                    → Что делает
─────────────────────────────────────────────────────────────
GET  /api/profile/{email}           → Получить профиль пользователя
POST /api/profile/upsert           → Создать или обновить профиль
POST /api/test-result               → Сохранить результаты квиза
GET  /api/test-result/{email}      → Получить результаты квиза
POST /api/favorites                 → Добавить в избранное
GET  /api/favorites/{email}        → Получить избранное
POST /api/dislikes                  → Добавить дизлайк
GET  /api/dislikes/{email}         → Получить дизлайки
POST /api/ai/chat                   → Отправить сообщение ИИ
GET  /api/marketplace/search        → Поиск товаров на маркетплейсах
GET  /health                        → Проверка работоспособности
```

**Примеры запросов:**

```bash
# Получить профиль пользователя
GET http://localhost:8000/api/profile/alice@example.com

# Ответ:
{
  "email": "alice@example.com",
  "username": "Alice",
  "bio": "Люблю минимализм",
  "profile_image_path": "/images/alice.jpg",
  "created_at": "2026-04-01T10:00:00Z",
  "test_result_json": "{\"height\": 170, \"favoriteColors\": [\"чёрный\", \"белый\"]}"
}

# Создать/обновить профиль
POST http://localhost:8000/api/profile/upsert
Content-Type: application/json

{
  "username": "Alice",
  "bio": "Обновлённая биография"
}
```

---

**Модели данных (Pydantic):**

```python
# ============================================================================
# ЧТО ТАКОЕ Pydantic?
# ============================================================================
# Pydantic — библиотека для валидации данных
# Модель (класс с типами) автоматически:
# - Проверяет входные данные
# - Преобразует JSON в объекты Python
# - Генерирует документацию
#
# ПРИМЕР:
# Если придёт {"username": 123}, Pydantic выдаст ошибку
# (число вместо строки)
# ============================================================================

from pydantic import BaseModel, Field
# BaseModel — базовый класс для всех моделей
# Field — для дополнительных настроек полей (описание, дефолт)

class ProfileUpsert(BaseModel):
    """Модель для создания/обновления профиля пользователя"""
    
    # Поля без значения по умолчанию — ОБЯЗАТЕЛЬНЫЕ
    # (required в терминах Pydantic)
    username: str           # Строка, обязательно
    
    # Поля с = значение — необязательные
    # Если клиент не передаст, будет использоваться значение по умолчанию
    bio: str = ""                    # Пустая строка по умолчанию
    profile_image_path: str | None = None  # Может быть None (nullable)

class TestResultPayload(BaseModel):
    """Результаты квиза по определению стиля пользователя"""
    
    # Optional[float] = может быть числом или None
    # (аналог float? в Dart)
    height: Optional[float] = None    # Рост в см
    bust: Optional[float] = None     # Обхват груди
    waist: Optional[float] = None     # Обхват талии
    hips: Optional[float] = None      # Обхват бёдер
    city: Optional[str] = None         # Город (для погоды)
    
    # list[str] = список строк (аналог List<String> в Dart)
    # Field(default_factory=list) = создавать пустой список если не передан
    preferredStyles: list[str] = Field(default_factory=list)
    favoriteColors: list[str] = Field(default_factory=list)
    avoidedColors: list[str] = Field(default_factory=list)
    
    fitPreference: Optional[str] = None  # Предпочтение по посадке
    specialNotes: Optional[str] = None    # Особые пожелания

class DislikePayload(BaseModel):
    """Модель дизлайка для отправки на сервер"""
    description: str                  # Описание (обязательно)
    category: str = "recommendation"  # Категория (дефолт = general)

class FavoritePayload(BaseModel):
    """Модель избранного изображения"""
    imageUrl: str                      # URL изображения (обязательно)

class ChatMessagePayload(BaseModel):
    """Сообщение в чате"""
    text: str = ""                    # Текст сообщения
    imageBase64: Optional[str] = None  # Изображение в base64 (опционально)
    imageMimeType: Optional[str] = None  # MIME тип изображения

class AiChatPayload(BaseModel):
    """Запрос к ИИ-стилисту"""
    email: str                         # Email пользователя
    chatId: Optional[str] = None       # ID чата (для контекста)
    message: str = ""                  # Сообщение пользователя
    imageBase64: Optional[str] = None  # Изображение (опционально)
    imagePath: Optional[str] = None   # Путь к файлу изображения
```

---

**База данных SQLite:**

```python
# ============================================================================
# ЧТО ТАКОЕ SQLite?
# ============================================================================
# SQLite — лёгкая база данных, работающая в ОДНОМ ФАЙЛЕ
# Не нужно запускать отдельный сервер (как для MySQL/PostgreSQL)
# Идеально для небольших приложений
#
# ПЛЮСЫ:
# - Простота (один файл)
# - Быстрая работа
# - Не требует настройки
#
# МИНУСЫ:
# - Не подходит для высоких нагрузок
# - Нет сложных JOIN (как в PostgreSQL)
# - Один файл = одна точка отказа
# ============================================================================

import sqlite3
# sqlite3 — встроенный модуль Python для работы с SQLite

DB_PATH = "backend/data/stylee.sqlite3"
# Путь к файлу базы данных (относительно расположения app.py)

def db_connection() -> sqlite3.Connection:
    """Создать подключение к базе данных"""
    # sqlite3.connect() — открывает файл базы данных
    # Если файла нет — создаст новый
    conn = sqlite3.connect(DB_PATH)
    
    # conn.row_factory = sqlite3.Row
    # Делает результаты запросов похожими на словари
    # Вместо row[0], row[1] можно писать row['column_name']
    conn.row_factory = sqlite3.Row
    
    # PRAGMA foreign_keys = ON
    # Включает проверку внешних ключей
    # (аналог ON DELETE CASCADE в SQL)
    conn.execute("PRAGMA foreign_keys = ON")
    
    return conn

def init_db() -> None:
    """Инициализация таблиц базы данных"""
    # Вызывается при первом запуске сервера
    # CREATE TABLE IF NOT EXISTS — создаёт таблицу если её нет
    
    with db_connection() as conn:
        conn.executescript("""
            -- Таблица пользователей
            CREATE TABLE IF NOT EXISTS users (
                email TEXT PRIMARY KEY,           -- Email = ключ (уникальный)
                username TEXT,                    -- Имя пользователя
                bio TEXT DEFAULT '',              -- Биография (по умолчанию пусто)
                profile_image_path TEXT,          -- Путь к фото профиля
                created_at TEXT NOT NULL,         -- Дата создания (обязательно)
                test_result_json TEXT             -- Результаты квиза в JSON
            );
            
            -- Таблица избранных изображений
            CREATE TABLE IF NOT EXISTS favorite_images (
                user_email TEXT NOT NULL,         -- Email пользователя
                image_url TEXT NOT NULL,          -- URL изображения
                created_at TEXT NOT NULL,         -- Дата добавления
                PRIMARY KEY (user_email, image_url)  -- Составной ключ
            );
            
            -- Таблица дизлайков
            CREATE TABLE IF NOT EXISTS dislikes (
                user_email TEXT NOT NULL,
                description TEXT NOT NULL,
                category TEXT NOT NULL,
                created_at TEXT NOT NULL,
                PRIMARY KEY (user_email, description)  -- Один дизлайк на описание
            );
            
            -- Таблица чатов
            CREATE TABLE IF NOT EXISTS chats (
                id TEXT PRIMARY KEY,
                user_email TEXT NOT NULL,
                title TEXT,
                created_at TEXT NOT NULL
            );
            
            -- Таблица сообщений в чатах
            CREATE TABLE IF NOT EXISTS chat_messages (
                id TEXT PRIMARY KEY,
                chat_id TEXT NOT NULL,
                role TEXT NOT NULL,              -- 'user' или 'assistant'
                content TEXT NOT NULL,           -- Текст сообщения
                image_url TEXT,                  -- URL изображения (если было)
                created_at TEXT NOT NULL
            );
        """)
        # executescript() — выполняет несколько SQL-команд за раз
```

---

**Примеры SQL запросов в коде:**

```python
# ============================================================================
# ПОЛУЧИТЬ ПОЛЬЗОВАТЕЛЯ
# ============================================================================
def get_user(email: str) -> dict | None:
    with db_connection() as conn:
        cursor = conn.execute(
            "SELECT * FROM users WHERE email = ?",
            (email,)  # Параметры запроса (защита от SQL injection!)
        )
        row = cursor.fetchone()
        
        if row is None:
            return None  # Пользователь не найден
        
        # row — объект sqlite3.Row (похож на dict)
        return dict(row)  # Конвертируем в обычный dict

# ============================================================================
# СОЗДАТЬ/ОБНОВИТЬ ПОЛЬЗОВАТЕЛЯ (UPSERT)
# ============================================================================
def upsert_user(email: str, username: str, bio: str = "") -> None:
    # INSERT OR REPLACE — вставить или заменить если уже есть
    # Это "UPSERT" — combine INSERT и UPDATE
    with db_connection() as conn:
        conn.execute("""
            INSERT OR REPLACE INTO users (email, username, bio, created_at)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(email) DO UPDATE SET
                username = excluded.username,
                bio = excluded.bio
        """, (email, username, bio, datetime.utcnow().isoformat()))
        # datetime.utcnow() — текущее время в формате ISO
        # '2026-05-01T12:00:00'

# ============================================================================
# ПОЛУЧИТЬ ИЗБРАННОЕ
# ============================================================================
def get_favorites(email: str) -> list[dict]:
    with db_connection() as conn:
        cursor = conn.execute(
            "SELECT image_url, created_at FROM favorite_images WHERE user_email = ?",
            (email,)
        )
        # fetchall() — получить все строки
        return [dict(row) for row in cursor.fetchall()]

# ============================================================================
# ДОБАВИТЬ В ИЗБРАННОЕ
# ============================================================================
def add_favorite(email: str, image_url: str) -> None:
    try:
        with db_connection() as conn:
            conn.execute("""
                INSERT INTO favorite_images (user_email, image_url, created_at)
                VALUES (?, ?, ?)
            """, (email, image_url, datetime.utcnow().isoformat()))
            # Если уже есть — SQLite выдаст ошибку (дубликат PRIMARY KEY)
    except sqlite3.IntegrityError:
        # Игнорируем ошибку "уже существует"
        pass
```

---

**Эндпоинты FastAPI (маршруты):**

```python
# ============================================================================
# ЧТО ТАКОЕ ЭНДПОИНТ (ENDPOINT)?
# ============================================================================
# Эндпоинт = URL + HTTP-метод + обработчик
# Это точка входа для API-запросов
#
# @app.get("/path") — декоратор, регистрирующий функцию как обработчик
# GET-запросов на адрес /path
# ============================================================================

from fastapi import FastAPI, HTTPException, Query
from typing import Optional

# Создаём приложение (уже было выше)
app = FastAPI(title="Stylee Python Backend")

# --------------------------------------------------------------------------
# ЭНДПОИНТ: Получить профиль пользователя
# --------------------------------------------------------------------------
# @app.get() — декоратор для GET запросов
# /api/profile/{email} — {email} это параметр пути (path parameter)

@app.get("/api/profile/{email}")
async def get_profile(email: str):
    """
    Получить профиль пользователя по email
    
    Параметры:
        - email: Email пользователя (из URL)
    
    Возвращает:
        - JSON с данными профиля
        - 404 если пользователь не найден
    """
    user = get_user(email)  # Функция из предыдущего раздела
    
    if user is None:
        # HTTPException — выбросить HTTP-ошибку
        # status_code=404 — "Not Found"
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    
    return user  # FastAPI автоматически конвертирует в JSON

# --------------------------------------------------------------------------
# ЭНДПОИНТ: Создать/обновить профиль
# --------------------------------------------------------------------------
# @app.post() — декоратор для POST запросов
# Тело запроса автоматически парсится в модель ProfileUpsert

@app.post("/api/profile/upsert")
async def upsert_profile(profile: ProfileUpsert):
    """
    Создать или обновить профиль пользователя
    
    Тело запроса (JSON):
        {
            "username": "Alice",
            "bio": "Моя биография"
        }
    """
    # ProfileUpsert — модель Pydantic (проверена и валидирована)
    upsert_user(
        email=profile.username,  # Используем username как email (упрощение)
        username=profile.username,
        bio=profile.bio
    )
    
    return {"status": "ok", "message": "Профиль сохранён"}

# --------------------------------------------------------------------------
# ЭНДПОИНТ: Получить избранное
# --------------------------------------------------------------------------
# {email} — параметр пути
# response_model=list[dict] — указываем тип возвращаемого значения

@app.get("/api/favorites/{email}", response_model=list[dict])
async def get_favorites_endpoint(email: str):
    """
    Получить список избранных изображений пользователя
    """
    return get_favorites(email)

# --------------------------------------------------------------------------
# ЭНДПОИНТ: Поиск на маркетплейсах
# --------------------------------------------------------------------------
# Query parameters — параметры после ? в URL
# ?query=платье&imageUrl=...

@app.get("/api/marketplace/search")
async def marketplace_search(
    imageUrl: Optional[str] = None,
    imagePath: Optional[str] = None,
    query: Optional[str] = Query(None, description="Поисковый запрос")
):
    """
    Поиск товаров на Wildberries и Ozon
    
    Параметры (Query string):
        - imageUrl: URL изображения для визуального поиска
        - imagePath: Путь к файлу изображения
        - query: Текстовый поисковый запрос
    
    Пример запроса:
        GET /api/marketplace/search?query=красное+платье
    
    Пример с изображением:
        GET /api/marketplace/search?imageUrl=https://example.com/image.jpg
    """
    # Вызываем функцию поиска с pHash
    results = real_search_by_image(
        imageUrl=imageUrl,
        imagePath=imagePath,
        query=query
    )
    
    return {"results": results}

# --------------------------------------------------------------------------
# ЭНДПОИНТ: Проверка работоспособности
# --------------------------------------------------------------------------
# Используется для мониторинга (health check)

@app.get("/health")
async def health_check():
    """Проверка что сервер запущен"""
    return {"status": "healthy", "service": "stylee-backend"}
```

---

**Изменения во Flutter (новый сервис):**

```dart
// stylee_app/lib/services/backend_api_service.dart
// ============================================================================
// СЕРВИС ДЛЯ ОБЩЕНИЯ С PYTHON БЭКЕНДОМ
// ============================================================================
// Этот сервис заменил прямое обращение к Firebase для сложных операций
// Теперь Flutter отправляет HTTP-запросы к Python FastAPI серверу
// ============================================================================

import 'dart:convert';      // JSON кодирование/декодирование
import 'package:http/http.dart' as http;  // HTTP клиент

class BackendApiService {
  // --------------------------------------------------------------------------
  // SINGLETON PATTERN — один экземпляр на всё приложение
  // --------------------------------------------------------------------------
  // static final — статическое поле (существует в классе, не в объекте)
  // late — будет инициализировано при первом использовании
  static final BackendApiService instance = BackendApiService._internal();
  
  // Приватный конструктор — нельзя вызвать BackendApiService()
  BackendApiService._internal();
  
  // --------------------------------------------------------------------------
  // КОНФИГУРАЦИЯ
  // --------------------------------------------------------------------------
  // Базовый URL сервера (из .env)
  final String _baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  // --------------------------------------------------------------------------
  // МЕТОД: Получить профиль
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getProfile(String email) async {
    try {
      // http.get — GET запрос (аналог requests.get() в Python)
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile/$email'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        // jsonDecode — парсинг JSON строки в Map
        // аналог json.loads() в Python
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null;  // Пользователь не найден
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения профиля: $e');
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // МЕТОД: Сохранить профиль
  // --------------------------------------------------------------------------
  Future<bool> upsertProfile({
    required String email,
    required String username,
    String bio = '',
  }) async {
    try {
      // http.post — POST запрос (аналог requests.post())
      final response = await http.post(
        Uri.parse('$_baseUrl/api/profile/upsert'),
        headers: {'Content-Type': 'application/json'},
        // body — тело запроса в виде строки
        // jsonEncode — сериализация объекта в JSON
        body: jsonEncode({
          'username': username,
          'bio': bio,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка сохранения профиля: $e');
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // МЕТОД: Поиск на маркетплейсах
  // --------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> searchMarketplace({
    String? query,
    String? imageUrl,
  }) async {
    try {
      // Строим URL с query parameters
      final params = <String, String>{};
      if (query != null) params['query'] = query;
      if (imageUrl != null) params['imageUrl'] = imageUrl;
      
      final uri = Uri.parse('$_baseUrl/api/marketplace/search')
          .replace(queryParameters: params.isNotEmpty ? params : null);
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Ошибка поиска маркетплейсов: $e');
      return [];
    }
  }
}
```

---

**Ключевые концепции Python в этом коде:**

| Синтаксис | Пояснение |
|-----------|-----------|
| `from typing import Optional` | Импорт типа Optional (может быть None) |
| `str \| None` | Union type — строка или None (Python 3.10+) |
| `Optional[str]` | То же что str \| None, но для старых версий |
| `with db_connection() as conn` | Контекстный менеджер — автоматически закрывает соединение |
| `conn.execute(sql, params)` | Выполнить SQL с параметрами (защита от injection) |
| `cursor.fetchone()` | Получить одну строку результата |
| `cursor.fetchall()` | Получить все строки результата |
| `@app.get("/path")` | Декоратор — регистрация эндпоинта |
| `async def func()` | Асинхронная функция |
| `raise HTTPException(...)` | Выбросить HTTP ошибку |
| `response_model=list[dict]` | Указание типа возврата для документации |

---

#### 🔹 `93ecec2` — add dataset of diffrent styles (05.05.2026, verrronikka)

**Описание**: Добавление набора данных для обучения/рекомендаций стилей.

**Файл**: `ai_model/scrapping_pinterest`
```bash
# Скрипт для сбора изображений с Pinterest
# по различным стилям одежды
```

---

#### 🔹 `2f0a1bd` — scrape weather (05.05.2026, verrronikka)

**Описание**: Парсинг данных о погоде для рекомендаций.

**Файл**: `ai_model/scrapping_weather/parser.py`
```python
def get_weather(city: str) -> dict:
    """Получает текущую погоду для города"""
    # Использует публичные API погоды
    # Возвращает: температуру, описание, иконку
    return {
        'temperature': 22,
        'description': 'солнечно',
        'icon': '☀️',
        'recommendation': 'Лёгкая одежда, солнечные очки'
    }
```

---

#### 🔹 `a83c536` — Merge branch 'main' of github.com:verrronikka/stylee_upprpo_24943 (05.05.2026, verrronikka)

**Описание**: Синхронизация с основной веткой (merge).

---

#### 🔹 `c60e747` — add colortype test (10.05.2026, verrronikka)

**Описание**: Тест для определения цветотипа пользователя.

**Файл**: `ai_model/quiz_functions/colortype.py` (513 строк)
```python
def determine_colortype(answers: dict) -> str:
    """
    Определение цветотипа по ответам на вопросы
    
    Цветотипы:
    - Весна (Spring) — тёплые, светлые
    - Лето (Summer) — холодные, светлые  
    - Осень (Autumn) — тёплые, тёмные
    - Зима (Winter) — холодные, тёмные
    
    Returns: 'spring' | 'summer' | 'autumn' | 'winter'
    """
```

---

#### 🔹 `de71e45` — Восстановление пароля (11.05.2026, OhButWhy)

**Описание**: Добавление функционала сброса пароля через email.

**Новый файл**: `stylee_app/lib/screens/forgot_password_page.dart`
```dart
class ForgotPasswordPage extends StatefulWidget {
  // Экран восстановления пароля
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailTextController = TextEditingController();
  
  Future<void> resetPassword() async {
    final email = emailTextController.text.trim();
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Показываем сообщение об отправке письма
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Пользователь не найден
      } else if (e.code == 'too-many-requests') {
        // Слишком много попыток
      }
    }
  }
}
```

---

#### 🔹 `de1ebcc` — 2FA (11.05.2026, OhButWhy)

**Описание**: Внедрение двухфакторной аутентификации через SMS.

**Изменения** в `login_page.dart`:
```dart
class _LoginPageState extends State<LoginPage> {
  Future<void> _signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(...);
    } on FirebaseAuthMultiFactorException catch (e) {
      // Обработка 2FA
      final resolved = await _resolveMultiFactorSignIn(e);
      if (!resolved) {
        _showError('Не удалось подтвердить второй фактор');
      }
    }
  }
  
  Future<bool> _resolveMultiFactorSignIn(
    FirebaseAuthMultiFactorException error
  ) async {
    final resolver = error.resolver;
    final phoneHints = resolver.hints
        .whereType<PhoneMultiFactorInfo>()
        .toList();
    
    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorInfo: phoneHints.first,
      multiFactorSession: resolver.session,
      verificationCompleted: (credential) async {
        final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
        await resolver.resolveSignIn(assertion);
      },
      codeSent: (verificationId, resendToken) async {
        final smsCode = await _promptForSmsCode(
          title: 'Подтверждение',
          message: 'Введите код из SMS'
        );
        // Завершение верификации
      },
    );
  }
}
```

---

#### 🔹 `99af548` — фильтрация ленты (12.05.2026, OhButWhy)

**Описание**: Фильтрация ленты постов по погоде, мероприятию и цвету.

**Изменения** в `home_page.dart`:
```dart
class _HomePageState extends State<HomePage> {
  String? _feedEventFilter;
  String? _feedWeatherFilter;
  String? _feedColorFilter;
  
  final List<String> _eventOptions = ['работа', 'вечеринка', 'прогулка'];
  final List<String> _weatherOptions = ['жарко', 'прохладно', 'дождь'];
  final List<String> _colorOptions = ['чёрный', 'белый', 'красный', 'синий'];
  
  bool _postMatchesFeedFilters(QueryDocumentSnapshot post) {
    final data = post.data() as Map<String, dynamic>;
    
    final events = (data['events'] is List) 
        ? (data['events'] as List).whereType<String>().toList() 
        : [];
    final weathers = (data['weathers'] is List) 
        ? (data['weathers'] as List).whereType<String>().toList() 
        : [];
    final colors = (data['colors'] is List) 
        ? (data['colors'] as List).whereType<String>().toList() 
        : [];
    
    final matchesEvent = _feedEventFilter == null || 
        events.contains(_feedEventFilter);
    final matchesWeather = _feedWeatherFilter == null || 
        weathers.contains(_feedWeatherFilter);
    final matchesColor = _feedColorFilter == null || 
        colors.contains(_feedColorFilter);
    
    return matchesEvent && matchesWeather && matchesColor;
  }
}
```

**UI**: Модальное окно с dropdown-фильтрами.

---

#### 🔹 `5d05974` — М-кнопка + заглушки для маркетплейсов (12.05.2026, OhButWhy)

**Описание**: Добавление кнопки "М" для поиска товаров на маркетплейсах.

**Новые файлы**:
```dart
// stylee_app/lib/components/marketplace_search_button.dart
class MarketplaceSearchButton extends StatelessWidget {
  // Кнопка "🔍 М" на экране редактора
}

// stylee_app/lib/models/marketplace_result.dart
class MarketplaceResult {
  final String title;
  final String url;
  final String? thumbnail;
  final String marketplace; // 'Wildberries', 'Ozon', 'Яндекс.Маркет'
}

// stylee_app/lib/screens/marketplace_search_screen.dart
class MarketplaceSearchScreen extends StatefulWidget {
  // Экран поиска товаров на маркетплейсах
  // Заглушка — вызывает backend API
}
```

**Backend API**:
```python
@app.get("/api/marketplace/search")
async def marketplace_search(
    imageUrl: str = None,
    query: str = None,
):
    # Заглушка — возвращает пустой результат
    # Позже заменена на реальные парсеры
    return {"results": []}
```

---

#### 🔹 `562b7ad` — add publish post in profile (12.05.2026, verrronikka)

**Описание**: Публикация постов из профиля.

**Изменения** (31 файл, ~2200 строк):
```dart
// stylee_app/lib/screens/profile_page.dart
// Полностью переработан:
// - Публикация постов
// - Галерея пользователя
// - Редактирование профиля

// stylee_app/lib/screens/post_detail_page.dart (новый)
// Детальный просмотр поста с комментариями
```

---

#### 🔹 `76a5590` — add feed on TikTok + date in profile (12.05.2026, verrronikka)

**Описание**: TikTok-подобная лента и отображение даты в профиле.

**Изменения** в `home_page.dart`:
```dart
// TikTok-style вертикальная лента
// Свайп вверх — следующий пост
// Свайп вниз — предыдущий пост

// В профиле:
// Добавлена дата регистрации
// Отформатированная дата: "На платформе с мая 2026"
```

---

#### 🔹 `9e0ab99` — Fix: merge editor navigation + marketplace features (12.05.2026, verrronikka)

**Описание**: Исправление навигации и интеграция маркетплейсов.

**Изменения**:
- Исправлена навигация между экранами
- Добавлен `post_preview_page.dart` для предпросмотра перед публикацией
- Интеграция маркетплейсов в редактор

---

### Май 2026 — Бэкенд и маркетплейсы

#### 🔹 `311d4fa` — уточнение парсеров для Ozon/WB (21.05.2026, OhButWhy)

**Описание**: Добавление специализированных парсеров для Wildberries и Ozon.

**Изменения** в `marketplace_real.py`:
```python
def parse_wildberries(html: str, domain_hint: str) -> list[dict]:
    """Парсер Wildberries.ru"""
    soup = BeautifulSoup(html, 'lxml')
    items = []
    
    # Ищем ссылки с /catalog/
    for a in soup.find_all('a', href=True):
        href = a['href']
        if '/catalog/' not in href:
            continue
        
        title = a.get('aria-label') or (a.get_text() or '').strip()
        img = a.find('img')
        thumb = img.get('data-src') or img.get('src')
        
        items.append({
            'title': title.strip(),
            'url': f'https://www.wildberries.ru{href}',
            'marketplace': 'Wildberries',
            'thumbnail': thumb
        })
        if len(items) >= 30:
            break
    return items


def parse_ozon(html: str, domain_hint: str) -> list[dict]:
    """Парсер Ozon.ru"""
    soup = BeautifulSoup(html, 'lxml')
    items = []
    
    for a in soup.find_all('a', href=True):
        href = a['href']
        if not any(k in href for k in ['/product/', '/context/detail']):
            continue
        
        title = (a.get_text() or '').strip()
        img = a.find('img')
        thumb = img.get('src')
        
        items.append({
            'title': title,
            'url': f'https://www.ozon.ru{href}',
            'marketplace': 'Ozon',
            'thumbnail': thumb
        })
    return items
```

---

#### 🔹 `4b18965` — добавлены pHash-ранжирование и загрузка миниатюр (21.05.2026, OhButWhy)

**Описание**: Визуальное сравнение изображений с помощью перцептивного хэширования.

---

**Что такое pHash и зачем он нужен?**

Представьте ситуацию:
1. Пользователь видит красивое платье в Instagram
2. Хочет найти похожее на Wildberries
3. Загружает скриншот в приложение
4. Приложение должно найти ВИЗУАЛЬНО похожие товары

**Как это работает без pHash?**
- Обычный поиск по тексту: "скриншот платья" → не найдёт ничего
- Теги/описания: работает плохо, субъективно

**Как это работает с pHash?**
1. Изображение преобразуется в числовой "отпечаток" (хеш)
2. Похожие изображения дают похожие хеши
3. Можно сравнить хеш пользовательского фото с хешами товаров
4. Найти наиболее похожие

```
┌─────────────────────────────────────────────────────────────────────────┐
│  КАК РАБОТАЕТ pHash (Perceptual Hash)                                   │
│                                                                         │
│  Оригинальное изображение        Платье на Wildberries                 │
│       ┌─────────┐                    ┌─────────┐                        │
│       │  🖼️    │                    │  🖼️    │                        │
│       │ платье  │                    │ платье  │                        │
│       └────┬────┘                    └────┬────┘                        │
│            │                              │                             │
│            ▼                              ▼                             │
│     Вычисление                   Вычисление                            │
│     pHash                        pHash                                 │
│            │                              │                             │
│            ▼                              ▼                             │
│     Хеш: 101010111100...          Хеш: 101010111011...                  │
│            │                              │                             │
│            │         Сравнение            │                             │
│            │◄─────────────────────────────►│                            │
│            │                              │                             │
│            ▼                              ▼                             │
│     Сходство: 94%                         Сходство: 94%                  │
│            │                              │                             │
│            │         РЕЗУЛЬТАТ            │                             │
│            └──────────────────────────────►│                             │
│                                          Найдено!                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

**Ключевые функции:**

```python
# backend/marketplace_real.py
# ============================================================================
# ЗАВИСИМОСТИ
# ============================================================================
# imagehash — библиотека для вычисления перцептивных хэшей
# PIL (Pillow) — библиотека для работы с изображениями
# BeautifulSoup — парсер HTML

import imagehash
from PIL import Image
from io import BytesIO

# ============================================================================
# ФУНКЦИЯ: Вычисление pHash изображения
# ============================================================================
# image_bytes — бинарные данные изображения (jpg, png, webp)
# Возвращает — объект ImageHash

def compute_phash_from_bytes(image_bytes: bytes) -> imagehash.ImageHash:
    """
    Вычисление перцептивного хэша изображения
    
    Параметры:
        image_bytes: Бинарные данные изображения
    
    Возвращает:
        ImageHash — объект представляющий "отпечаток" изображения
        Можно сравнивать два ImageHash оператором '-' (разница хэшей)
    
    Пример:
        hash1 = compute_phash_from_bytes(bytes1)  # Фото пользователя
        hash2 = compute_phash_from_bytes(bytes2)  # Фото товара
        distance = hash1 - hash2  # 0-64, где 0 = идентичные
    """
    # BytesIO — превращает байты в "файл" в памяти
    # Image.open() — открывает изображение
    # .convert('RGB') — конвертирует в RGB (убирает альфа-канал)
    img = Image.open(BytesIO(image_bytes)).convert('RGB')
    
    # imagehash.phash() — вычисляет pHash (по умолчанию 8x8 = 64 бита)
    # Можно: imagehash.phash(img, hash_size=16) для 16x16 = 256 бит
    return imagehash.phash(img)


# ============================================================================
# ФУНКЦИЯ: Сравнение двух хэшей
# ============================================================================

def visual_similarity_score(phash_a, phash_b) -> float:
    """
    Вычисление сходства двух изображений
    
    Параметры:
        phash_a: Хэш первого изображения
        phash_b: Хэш второго изображения
    
    Возвращает:
        float от 0.0 до 1.0
        1.0 = идентичные изображения
        0.0 = абсолютно разные
    
    Как это работает:
        - distance = phash_a - phash_b — разница в битах (0-64)
        - max_bits = 64 (размер хэша)
        - similarity = 1.0 - (distance / max_bits)
        - distance=0  → similarity=1.0 (100%)
        - distance=32 → similarity=0.5 (50%)
        - distance=64 → similarity=0.0 (0%)
    """
    # Оператор '-' между ImageHash возвращает количество
    # отличающихся бит (Hamming distance)
    dist = phash_a - phash_b
    
    # Размер хэша (8x8 = 64 бита)
    max_bits = phash_a.hash.size
    
    # Формула сходства
    return max(0.0, 1.0 - (dist / float(max_bits)))


# ============================================================================
# ФУНКЦИЯ: Загрузка миниатюры товара
# ============================================================================

def fetch_candidate_thumbnail_bytes(url: str, timeout: int = 3):
    """
    Загрузка миниатюры товара с веб-страницы
    
    Стратегия поиска изображения:
        1. og:image — OpenGraph мета-тег (часто главное изображение)
        2. Первое <img> на странице
        3. Если не нашли — возвращаем None
    
    og:image — это мета-тег для соцсетей:
        <meta property="og:image" content="https://example.com/image.jpg">
        Социальные сети используют его для превью ссылок
    """
    try:
        # GET запрос к странице товара
        ua = os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0')
        headers = {'User-Agent': ua}
        r = requests.get(url, headers=headers, timeout=timeout)
        r.raise_for_status()  # Выбросить ошибку если статус != 200
        
        # Парсим HTML
        soup = BeautifulSoup(r.text, 'lxml')
        
        # Ищем og:image
        meta = soup.find('meta', property='og:image')
        if meta and meta.get('content'):
            img_url = meta.get('content')
            # Рекурсивно вызываем download_image_to_bytes
            return download_image_to_bytes(img_url, timeout=timeout)
        
        # Fallback: первое <img>
        img = soup.find('img')
        if img and img.get('src'):
            img_url = img.get('src')
            # Исправляем относительные URL
            if img_url.startswith('//'):
                img_url = 'https:' + img_url
            elif img_url.startswith('/'):
                # Извлекаем домен из URL
                from urllib.parse import urljoin
                img_url = urljoin(url, img_url)
            return download_image_to_bytes(img_url, timeout=timeout)
        
        return None  # Изображение не найдено
        
    except Exception:
        return None  # Ошибка загрузки
```

---

**Основная функция поиска:**

```python
# ============================================================================
# ГЛАВНАЯ ФУНКЦИЯ: Поиск товаров по изображению
# ============================================================================

def real_search_by_image(
    imageUrl: str | None,      # URL изображения пользователя
    imagePath: str | None,     # Или путь к файлу
    query: str | None,         # Дополнительный текстовый запрос
    max_results: int = 10,     # Максимум результатов
) -> list[dict]:
    """
    Поиск визуально похожих товаров на маркетплейсах
    
    Алгоритм:
        1. Загрузить изображение пользователя
        2. Вычислить его pHash
        3. Получить кандидатов с Wildberries/Ozon (по текстовому запросу)
        4. Для каждого кандидата:
           - Загрузить миниатюру
           - Вычислить pHash миниатюры
           - Сравнить с оригинальным
        5. Отсортировать по сходству
        6. Вернуть top-N результатов
    
    Возвращает:
        Список словарей с товарами:
        [{'title': '...', 'url': '...', 'thumbnail': '...', 'similarity': 0.94}, ...]
    """
    
    # ─────────────────────────────────────────────────────────────────────
    # ШАГ 1: Загружаем изображение пользователя
    # ─────────────────────────────────────────────────────────────────────
    
    image_bytes = None
    
    if imageUrl:
        # download_image_to_bytes — функция загрузки по URL
        image_bytes = download_image_to_bytes(imageUrl)
    
    # Если не получилось по URL, пробуем локальный файл
    if not image_bytes and imagePath:
        try:
            with open(imagePath, 'rb') as f:
                image_bytes = f.read()
        except Exception:
            pass
    
    if not image_bytes:
        return []  # Не удалось загрузить изображение
    
    # ─────────────────────────────────────────────────────────────────────
    # ШАГ 2: Вычисляем pHash оригинала
    # ─────────────────────────────────────────────────────────────────────
    
    try:
        source_hash = compute_phash_from_bytes(image_bytes)
    except Exception:
        return []  # Не удалось вычислить хэш
    
    # ─────────────────────────────────────────────────────────────────────
    # ШАГ 3: Получаем кандидатов с маркетплейсов
    # ─────────────────────────────────────────────────────────────────────
    
    # fetch_marketplace_candidates — функция парсинга маркетплейсов
    # Возвращает список товаров: [{'title': '...', 'url': '...', 'marketplace': '...'}, ...]
    candidates = fetch_marketplace_candidates(query or "")
    
    if not candidates:
        return []
    
    # ─────────────────────────────────────────────────────────────────────
    # ШАГ 4: Для каждого кандидата вычисляем сходство
    # ─────────────────────────────────────────────────────────────────────
    
    scored_candidates = []
    
    for candidate in candidates:
        try:
            # Загружаем миниатюру товара
            thumb_bytes = fetch_candidate_thumbnail_bytes(candidate['url'])
            
            if not thumb_bytes:
                continue  # Пропускаем если не загрузилась миниатюра
            
            # Вычисляем pHash миниатюры
            cand_hash = compute_phash_from_bytes(thumb_bytes)
            
            # Вычисляем сходство
            similarity = visual_similarity_score(source_hash, cand_hash)
            
            # Добавляем в список с оценкой
            scored_candidates.append({
                'title': candidate['title'],
                'url': candidate['url'],
                'thumbnail': candidate.get('thumbnail'),
                'marketplace': candidate.get('marketplace', 'Unknown'),
                'similarity': similarity,  # 0.0 - 1.0
            })
            
        except Exception as e:
            # Пропускаем товар при ошибке
            print(f"Ошибка обработки {candidate['url']}: {e}")
            continue
    
    # ─────────────────────────────────────────────────────────────────────
    # ШАГ 5: Сортируем по сходству и возвращаем top-N
    # ─────────────────────────────────────────────────────────────────────
    
    # sorted() с reverse=True — по убыванию сходства
    scored_candidates.sort(key=lambda x: x['similarity'], reverse=True)
    
    # Берём только max_results лучших
    return scored_candidates[:max_results]
```

---

**Пример результата:**

```python
# Результат работы real_search_by_image
results = [
    {
        'title': 'Платье женское летнее миди с v-образным вырезом',
        'url': 'https://www.wildberries.ru/catalog/12345678/detail.aspx',
        'thumbnail': 'https://cdn.wildberries.ru/photos/12345678.jpg',
        'marketplace': 'Wildberries',
        'similarity': 0.94,  # Очень похоже!
    },
    {
        'title': 'Платье-миди трикотажное с коротким рукавом',
        'url': 'https://www.ozon.ru/product/87654321',
        'thumbnail': 'https://cdn.ozon.ru/photos/87654321.jpg',
        'marketplace': 'Ozon',
        'similarity': 0.87,  # Похоже
    },
    {
        'title': 'Юбка женская плиссе',
        'url': 'https://www.wildberries.ru/catalog/11111111/detail.aspx',
        'thumbnail': 'https://cdn.wildberries.ru/photos/11111111.jpg',
        'marketplace': 'Wildberries',
        'similarity': 0.45,  # Не очень похоже
    },
]
```

---

**Ключевые концепции:**

| Термин | Пояснение |
|--------|-----------|
| **pHash** | Перцептивный хэш — "отпечаток" изображения на основе визуального восприятия |
| **Hamming distance** | Количество отличающихся бит между хэшами. pHash размером 64 бита, distance 0-64 |
| **similarity score** | Сходство от 0 до 1. Формула: `1 - (distance / max_bits)` |
| **og:image** | OpenGraph мета-тег для соцсетей. Часто содержит главное фото товара |
| **thumbnail** | Уменьшенная копия изображения для быстрой загрузки |

**Сравнение типов хэширования:**

| Тип | Описание | Использование |
|-----|----------|--------------|
| **MD5/SHA** | Криптографические хэши | Проверка целостности файла |
| **pHash** | Перцептивный хэш | Визуальное сравнение изображений |
| **dHash** | Difference хэш | Быстрое сравнение, устойчив кresize |
| **aHash** | Average хэш | Простейший, быстрый |

---

#### 🔹 `2073e62` — логирование при парсинге маркетплейсов (21.05.2026, OhButWhy)

**Описание**: Добавление детального логирования для отладки парсеров.

**Изменения**:
```python
import logging

logger = logging.getLogger("marketplace_real")
logger.setLevel(logging.DEBUG)

def fetch_wildberries_api_candidates(query: str) -> list[dict]:
    logger.debug(f"Начало поиска WB для запроса: {query}")
    
    try:
        response = session.get(url, headers=headers, timeout=15)
        logger.debug(f"WB API статус: {response.status_code}")
        
        if response.status_code != 200:
            logger.warning(f"WB API вернул {response.status_code}")
            return []
        
        # ... парсинг ...
        logger.info(f"Найдено {len(items)} товаров WB")
        
    except Exception as e:
        logger.error(f"Ошибка парсинга WB: {e}")
```

---

#### 🔹 `db4d1bd` — фолбэк при неполучении результата запроса (21.05.2026, OhButWhy)

**Описание**: Резервный поиск при неудаче основного.

**Изменения** в `backend/app.py`:
```python
@app.get("/api/marketplace/search")
async def marketplace_search(imageUrl: str = None, query: str = None):
    try:
        # Основной поиск с pHash
        results = real_search_by_image(imageUrl, query)
        
        if results:
            return {"results": results, "source": "phash"}
        
    except Exception as e:
        logger.error(f"pHash поиск не удался: {e}")
    
    # ФОЛЛБЭК: простой поиск по тексту
    try:
        fallback_results = fetch_marketplace_candidates(query or "")
        return {
            "results": fallback_results[:10],
            "source": "fallback"
        }
    except Exception as e:
        logger.error(f"Fallback поиск не удался: {e}")
        return {"results": [], "source": "none"}
```

---

#### 🔹 `bbcd9fe` — прокси (22.05.2026, OhButWhy)

**Описание**: Добавление поддержки прокси для обхода блокировок.

---

**Зачем нужен прокси?**

Маркетплейсы (Wildberries, Ozon) активно борются с автоматизированным парсингом:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ПРОБЛЕМА: Блокировка парсинга                                        │
│                                                                         │
│  ┌──────────────┐         Запросы         ┌───────────────────────┐    │
│  │              │ ───────────────────►   │                       │    │
│  │  Наш сервер  │    100+ запросов       │   Wildberries         │    │
│  │              │ ◄───────────────────   │                       │    │
│  └──────────────┘         │               └───────────────────────┘    │
│                           │                                              │
│                           ▼                                              │
│                   403 Forbidden                                         │
│                   "Доступ запрещён"                                     │
│                   или CAPTCHA                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

**Как прокси помогает:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│  РЕШЕНИЕ: Использование прокси                                          │
│                                                                         │
│  ┌──────────────┐         Запрос          ┌────────────┐             │
│  │              │ ──────────────────────►  │            │             │
│  │  Наш сервер  │                         │  Прокси    │             │
│  │              │ ◄──────────────────────  │  сервер    │             │
│  └──────────────┘                         └─────┬──────┘             │
│                                                 │                    │
│                           Запрос с нового IP     │                    │
│                                                 ▼                    │
│                                          ┌───────────────────────┐   │
│                                          │     Wildberries       │   │
│                                          │   Видит "нового"      │   │
│                                          │   пользователя        │   │
│                                          └───────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

**Новые зависимости:**

```python
# requirements.txt — файл с зависимостями Python
# ============================================================================
# КАЖДЫЙ пакет — это готовая библиотека с открытым кодом
# ============================================================================

curl_cffi>=0.5.0  
# ──────────────────────────────────────────────────────────────────────────
# ЧТО ЭТО: Библиотека для HTTP запросов с имитацией браузера
# ЗАЧЕМ: Обычный requests легко детектируется как бот
#       curl_cffi имитирует реальный браузер Chrome
# КАК РАБОТАЕТ:
#   - requests: "Python/3.9" в заголовке User-Agent
#   - curl_cffi: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit..."
# ============================================================================

playwright>=1.40.0
# ──────────────────────────────────────────────────────────────────────────
# ЧТО ЭТО: Инструмент для автоматизации браузера
# ЗАЧЕМ: Для сайтов с JavaScript которые не работают через simple requests
# ИСПОЛЬЗОВАНИЕ: Можно "прокрутить" страницу, кликнуть, заполнить форму
# ============================================================================

playwright-stealth>=1.1.0
# ──────────────────────────────────────────────────────────────────────────
# ЧТО ЭТО: "Антидетекция" для Playwright
# ЗАЧЕМ: Сайты могут определять автоматизацию по:
#         - navigator.webdriver = True
#         - отсутствию движения мыши
#         - другим признакам
#       playwright-stealth скрывает эти признаки
# ============================================================================
```

---

**Код прокси:**

```python
# backend/marketplace_real.py
# ============================================================================
# ИМПОРТЫ БИБЛИОТЕК ДЛЯ РАБОТЫ С ПРОКСИ
# ============================================================================

# Попытка импортировать curl_cffi
# try/except — защита от ошибки если библиотека не установлена
try:
    from curl_cffi import requests as curl_requests
except Exception:
    curl_requests = None  # Если не установлена — используем обычный requests

# Аналогично для Playwright
try:
    from playwright.sync_api import sync_playwright
except Exception:
    sync_playwright = None

try:
    from playwright_stealth import Stealth
except Exception:
    Stealth = None

# ============================================================================
# КОНФИГУРАЦИЯ ПРОКСИ
# ============================================================================

# WB_PROXY_URL — URL прокси-сервера для Wildberries
# os.environ.get() — читает переменную окружения
# Если переменная не найдена — используется следующая (MARKETPLACE_PROXY)
# Если и её нет — используется HTTPS_PROXY или HTTP_PROXY

WB_PROXY_URL = (
    os.environ.get('WB_PROXY')           # Приоритет 1: явная переменная WB
    or os.environ.get('MARKETPLACE_PROXY')  # Приоритет 2: общая для маркетплейсов
    or os.environ.get('HTTPS_PROXY')       # Приоритет 3: стандартная переменная
    or os.environ.get('HTTP_PROXY')        # Приоритет 4: fallback
)

# ============================================================================
# ФУНКЦИЯ: Получение конфигурации прокси
# ============================================================================

def get_proxy_config() -> dict[str, str] | None:
    """
    Возвращает конфигурацию прокси для HTTP запросов
    
    Возвращает:
        None — если прокси не настроен (запросы идут напрямую)
        {'http': 'http://proxy:port', 'https': 'http://proxy:port'} — настройка
    
    Пример URL прокси:
        http://username:password@proxy.example.com:8080
        socks5://proxy.example.com:1080
    """
    if not WB_PROXY_URL:
        return None  # Прокси не настроен
    
    # Возвращаем словарь с HTTP и HTTPS прокси
    # Обычно они одинаковые
    return {'http': WB_PROXY_URL, 'https': WB_PROXY_URL}


# ============================================================================
# ФУНКЦИЯ: Создание HTTP сессии с прокси
# ============================================================================

def create_http_session():
    """
    Создаёт HTTP сессию с настроенным прокси и имитацией браузера
    
    Приоритет библиотек:
        1. curl_cffi — если установлена (лучшая имитация Chrome)
        2. requests — fallback (легче детектируется)
    
    Возвращает:
        Объект сессии с методами .get(), .post() и настроенным прокси
    """
    
    # ─── ВАРИАНТ 1: curl_cffi (приоритет) ───
    if curl_requests is not None:
        try:
            # Создаём сессию с имитацией Chrome 120
            # impersonate — какую версию Chrome имитировать
            session = curl_requests.Session(impersonate='chrome120')
            
            # Настраиваем прокси
            proxy_config = get_proxy_config()
            if proxy_config:
                try:
                    session.proxies = proxy_config
                except Exception:
                    pass  # Игнорируем ошибку настройки прокси
            
            return session  # Возвращаем настроенную сессию
            
        except Exception:
            pass  # Если не получилось — пробуем другой вариант
    
    # ─── ВАРИАНТ 2: requests (fallback) ───
    # Создаём обычную сессию requests
    session = requests.Session()
    
    # Настраиваем прокси
    proxy_config = get_proxy_config()
    if proxy_config:
        # .update() — добавляем прокси к существующим настройкам
        session.proxies.update(proxy_config)
    
    return session


# ============================================================================
# ФУНКЦИЯ: "Прогрев" сессии Wildberries
# ============================================================================

def warm_wildberries_session(session, headers: dict[str, str]) -> None:
    """
    "Прогревает" сессию — делает начальный запрос к главной странице
    
    ЗАЧЕМ: Wildberries может блокировать первый запрос с поисковым параметром
           Но пропускает запрос к главной странице
    """
    try:
        # GET запрос к главной странице WB
        session.get('https://www.wildberries.ru/', headers=headers, timeout=10)
    except Exception:
        # Игнорируем ошибки — прогрев не критичен
        pass
```

---

**Как это работает вместе:**

```python
# Пример использования

# 1. Создаём сессию (с прокси если настроен)
session = create_http_session()

# 2. Заголовки для имитации браузера
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
}

# 3. "Прогреваем" сессию
warm_wildberries_session(session, headers)

# 4. Делаем запрос как настоящий браузер
response = session.get(
    'https://search.wb.ru/exactmatch/ru/common/v5/search',
    params={'query': 'платье', 'sort': 'popular'},
    headers=headers,
    timeout=15,
)

# 5. Обрабатываем ответ
if response.status_code == 200:
    data = response.json()
    print(f"Найдено {len(data['data']['products'])} товаров")
```

---

**Типы прокси:**

| Тип | Пример URL | Пояснение |
|-----|------------|-----------|
| **HTTP** | `http://proxy:8080` | Работает только для HTTP сайтов |
| **HTTPS** | `https://proxy:8080` | Зашифрованное соединение |
| **SOCKS4** | `socks4://proxy:1080` | Универсальный, быстрый |
| **SOCKS5** | `socks5://proxy:1080` | Поддерживает UDP, аутентификация |
| **Анонимный** | `http://user:pass@proxy:8080` | Скрывает ваш IP |
| **Резидентский** | Special service | IP похожи на реальные устройства |

**Где взять прокси:**
- Платные сервисы: Bright Data, Oxylabs, SmartProxy
- Бесплатные: (не рекомендуется для продакшена) publicproxy

---

**Ключевые концепции:**

| Термин | Пояснение |
|--------|-----------|
| **Имитация браузера (impersonate)** | HTTP клиент представляется браузером чтобы обойти бот-детекцию |
| **curl_cffi** | Библиотека с поддержкой TLS fingerprinting Chrome |
| **Playwright** | Инструмент автоматизации реального браузера (Chrome, Firefox) |
| **Stealth** | Техники сокрытия признаков автоматизации |
| **Прогрев сессии** | Начальный запрос для установления "доверия" |
| **Proxy chaining** | Несколько прокси последовательно (редко нужно) |

---

#### 🔹 `66815e8` — Обновление парсера для использования Wildberries (24.05.2026, OhButWhy)

**Описание**: Интеграция официального API Wildberries.

**Новый эндпоинт API**:
```python
WB_SEARCH_API_URL = 'https://search.wb.ru/exactmatch/ru/common/v5/search'

def fetch_wildberries_api_candidates(query: str) -> list[dict]:
    """Запрос к API Wildberries"""
    params = {
        'ab_testing': 'false',
        'appType': 1,
        'curr': 'rub',
        'dest': '-1257786',
        'query': query,
        'resultset': 'catalog',
        'sort': 'popular',
        'spp': 24,
    }
    
    response = session.get(WB_SEARCH_API_URL, params=params, headers=headers)
    payload = response.json()
    
    products = payload.get('data', {}).get('products', [])
    
    items = []
    for product in products:
        items.append({
            'title': f"{product.get('brand')} {product.get('name')}",
            'url': f"https://www.wildberries.ru/catalog/{product['id']}/detail.aspx",
            'marketplace': 'Wildberries',
            'price': product.get('salePrice', 0) / 100,  # В рублях
            'rating': product.get('rating', 0),
        })
    
    return items
```

**Кэширование**:
```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=1000)
def cached_search(query: str) -> list[dict]:
    """Кэширование результатов поиска на 1 час"""
    return fetch_marketplace_candidates(query)

def get_cache_key(query: str, imageHash: str = None) -> str:
    key = f"{query}:{imageHash or ''}"
    return hashlib.md5(key.encode()).hexdigest()
```

---

## 5. Ключевые функции и их реализация

### 3.1 Система дизлайков

**Цель**: Исключение нежелательных рекомендаций из выдачи ИИ.

**Архитектура**:
```
Пользователь нажимает "Не нравится"
        ↓
DislikeButton → DislikeService.saveDislike()
        ↓
Firestore: Users/{email}/dislikes[]
        ↓
При запросе к ИИ:
  OpenRouterService._buildSystemPrompt(dislikes)
        ↓
Системный промпт включает блок "Пользователь НЕ любит:"
```

### 3.2 Поиск по маркетплейсам с pHash

**Цель**: Найти визуально похожие товары на Wildberries/Ozon.

**Алгоритм**:
```
1. Пользователь выбирает товар/образ
        ↓
2. Скачивается изображение → вычисляется pHash
        ↓
3. Формируются поисковые запросы:
   - Исходный текст
   - + каждый доминирующий цвет
   - "стильная одежда"
        ↓
4. Запросы отправляются на маркетплейсы:
   - Wildberries API
   - Ozon HTML parsing
   - Яндекс.Маркет
        ↓
5. Для каждого кандидата:
   - Скачать og:image
   - Вычислить pHash
   - Сравнить с оригиналом
        ↓
6. Сортировка по сходству
        ↓
7. Возврат top-10 результатов
```

### 3.3 Фильтрация ленты

**Цель**: Показывать релевантные посты по контексту.

**Фильтры**:
- **Мероприятие**: работа, вечеринка, прогулка
- **Погода**: жарко, прохладно, дождь
- **Цвет**: чёрный, белый, красный, синий...

**Реализация на Firestore**:
```dart
// Пост содержит метаданные:
{
  'imageUrl': '...',
  'events': ['работа', 'вечеринка'],
  'weathers': ['жарко'],
  'colors': ['чёрный', 'белый'],
  'author': 'user@example.com',
  'createdAt': Timestamp
}

// Запрос с фильтрами:
Query query = _firestore.collection('posts');
if (selectedWeather != null) {
  query = query.where('weathers', arrayContains: selectedWeather);
}
if (selectedEvent != null) {
  query = query.where('events', arrayContains: selectedEvent);
}
```

---

## 6. Схема архитектуры

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FRONTEND (Flutter)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Auth Flow  │  │  Home Page   │  │   Wardrobe    │  │   Editor      │  │
│  │  ┌─────────┐ │  │  ┌────────┐  │  │  ┌─────────┐ │  │  ┌─────────┐ │  │
│  │  │  Login  │ │  │  │ Feed   │  │  │  │ Sections│ │  │  │ Image   │ │  │
│  │  │Register │ │  │  │Filters │  │  │  │ Items  │ │  │  │ Upload  │ │  │
│  │  │  2FA    │ │  │  │Swipe   │  │  │  │Filters │ │  │  │Publish  │ │  │
│  │  │Password │ │  │  │TikTok  │  │  │  │Search  │ │  │  │ Market  │ │  │
│  │  └─────────┘ │  │  └────────┘  │  │  └─────────┘ │  │  └─────────┘ │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        SERVICES LAYER                                 │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ BackendAPI  │  │ OpenRouter  │  │ Dislike     │  │ Wardrobe    │ │   │
│  │  │ Service     │  │ Service     │  │ Service     │  │ Service     │ │   │
│  │  │ (REST)      │  │ (AI Chat)   │  │ (Filters)   │  │ (CRUD)      │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        DATA LAYER                                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Firebase    │  │ Firebase    │  │ Firebase    │  │ Local       │ │   │
│  │  │ Auth        │  │ Firestore   │  │ Storage     │  │ Storage     │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS/REST
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND (Python/FastAPI)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         API ENDPOINTS                                 │   │
│  │                                                                       │   │
│  │  POST /api/profile/upsert          - Создать/обновить профиль        │   │
│  │  GET  /api/profile/{email}         - Получить профиль                │   │
│  │  POST /api/test-result             - Сохранить результаты квиза       │   │
│  │  GET  /api/test-result/{email}     - Получить результаты квиза        │   │
│  │  POST /api/dislikes                - Добавить дизлайк                 │   │
│  │  GET  /api/dislikes/{email}        - Получить дизлайки               │   │
│  │  POST /api/favorites               - Добавить в избранное             │   │
│  │  GET  /api/favorites/{email}       - Получить избранное              │   │
│  │  POST /api/ai/chat                 - ИИ-чат с контекстом              │   │
│  │  GET  /api/marketplace/search      - Поиск товаров на маркетплейсах  │   │
│  │                                                                       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────┐         ┌─────────────────────┐                  │
│  │   SQLite Database   │         │  Marketplace Parser  │                  │
│  │  ┌───────────────┐  │         │  ┌───────────────┐  │                  │
│  │  │    users      │  │         │  │  Wildberries  │  │                  │
│  │  │  favorites    │  │         │  │  API + HTML   │  │                  │
│  │  │  dislikes     │  │         │  │  + Proxy      │  │                  │
│  │  │  test_results │  │         │  ├───────────────┤  │                  │
│  │  │  chats        │  │         │  │    Ozon       │  │                  │
│  │  └───────────────┘  │         │  │  HTML Parser  │  │                  │
│  └─────────────────────┘         │  ├───────────────┤  │                  │
│                                   │  │  Yandex      │  │                  │
│                                   │  │  HTML Parser  │  │                  │
│                                   │  ├───────────────┤  │                  │
│                                   │  │  pHash        │  │                  │
│                                   │  │  Ranking     │  │                  │
│                                   │  └───────────────┘  │                  │
│                                   └─────────────────────┘                  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                     AI INTEGRATION                                     │   │
│  │                                                                       │   │
│  │            ┌─────────────────────────────┐                           │   │
│  │            │   OpenRouter API (Qwen VL)   │                           │   │
│  │            │                             │                           │   │
│  │            │  - Стилист-консультант      │                           │   │
│  │            │  - Генерация описаний       │                           │   │
│  │            │  - Учёт дизлайков           │                           │   │
│  │            │  - Контекст гардероба       │                           │   │
│  │            └─────────────────────────────┘                           │   │
│  │                                                                       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTP Requests
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL SERVICES                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐               │
│   │  Wildberries │    │     Ozon     │    │   Yandex     │               │
│   │     API      │    │   Website    │    │    Market    │               │
│   └──────────────┘    └──────────────┘    └──────────────┘               │
│                                                                              │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐               │
│   │  Firebase    │    │   OpenRouter │    │  Weather API │               │
│   │   Auth       │    │     API      │    │              │               │
│   └──────────────┘    └──────────────┘    └──────────────┘               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Временная шкала коммитов

```
ФЕВРАЛЬ 2026
├── 17.02 ──► add flutter (verrronikka)
│              Базовый Flutter-проект

АПРЕЛЬ 2026
├── 03.04 ──► игнор (Naskok)
│              Добавление .env в gitignore
├── 07.04 ──► уязвимость с ключем (Naskok)
│              Исправление безопасности API-ключей
├── 10.04 ──► удаление flutter_app + опрос (Naskok)
│              Рефакторинг + онбординг
├── 10.04 ──► быстрый подбор по фильтрам (Naskok)
│              Система фильтрации образов
├── 16.04 ──► избранное (Naskok)
│              Система избранных постов
├── 22.04 ──► модель дизлайков (OhButWhy)
│              Создание модели Dislike
├── 22.04 ──► инициализация дизлайков (OhButWhy)
│              Автоматическая инициализация
├── 22.04 ──► ИИ учитывает дизлайки (OhButWhy)
│              Интеграция в промпт
├── 22.04 ──► дизлайк фронт (OhButWhy)
│              UI для дизлайков
├── 30.04 ──► перенос бэка на питон (OhButWhy)
│              Миграция на FastAPI + SQLite

МАЙ 2026
├── 03.05 ──► add wardrobe (verrronikka)
│              Полноценный гардероб
├── 05.05 ──► dataset of styles (verrronikka)
│              Набор данных для стилей
├── 05.05 ──► scrape weather (verrronikka)
│              Парсинг погоды
├── 05.05 ──► merge с веткой вероники (verrronikka)
│              Синхронизация
├── 10.05 ──► colortype test (verrronikka)
│              Определение цветотипа
├── 11.05 ──► восстановление пароля (OhButWhy)
│              Password reset через Firebase
├── 11.05 ──► 2FA (OhButWhy)
│              SMS двухфакторная аутентификация
├── 12.05 ──► фильтрация ленты (OhButWhy)
│              Фильтры по погоде/цвету/событию
├── 12.05 ──► М-кнопка + маркетплейсы (OhButWhy)
│              Интеграция маркетплейсов
├── 12.05 ──► publish post (verrronikka)
│              Публикация постов
├── 12.05 ──► TikTok feed (verrronikka)
│              Вертикальная лента
├── 12.05 ──► fix editor navigation (verrronikka)
│              Исправления навигации
├── 21.05 ──► парсеры Ozon/WB (OhButWhy)
│              Специализированные парсеры
├── 21.05 ──► pHash ранжирование (OhButWhy)
│              Визуальное сравнение
├── 21.05 ──► логирование парсеров (OhButWhy)
│              Debug-логирование
├── 21.05 ──► фоллбэк (OhButWhy)
│              Резервный поиск
├── 22.05 ──► прокси (OhButWhy)
│              Поддержка прокси
└── 24.05 ──► Wildberries API (OhButWhy)
               Официальный API WB
```
