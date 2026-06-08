# История разработки Stylee (репозиторий verrronikka/stylee_upprpo_24943)
---

## Содержание

1. [Общая архитектура проекта](#1-общая-архитектура-проекта)
2. [Хронология коммитов](#2-хронология-коммитов)
3. [Ключевые функции и их реализация](#3-ключевые-функции-и-их-реализация)
4. [Схема архитектуры](#4-схема-архитектуры)

---

## 1. Общая архитектура проекта

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

## 2. Хронология коммитов

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
class Dislike {
  final String id;
  final String description;  // что именно дизлайкнули
  final String category;     // 'clothing', 'color', 'style'
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {...}
  factory Dislike.fromMap(Map<String, dynamic> map) => {...}
}
```

**Сервис**:
```dart
// stylee_app/lib/services/dislike_service.dart
class DislikeService {
  // Сохранение дизлайков в Firestore
  Future<void> saveDisilike({
    required String userEmail,
    required String description,
    required String category,
  }) async {...}

  // Загрузка дизлайков
  Future<List<Dislike>> getDislikes(String userEmail) async {...}

  // Построение фильтра для ИИ-промпта
  String buildExcludeSection(List<Dislike> dislikes) {...}
}
```

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
Future<String> getStyleAdvice(
  String userMessage, {
  List<Dislike> dislikes = const [],  // НОВЫЙ параметр
}) async {
  // Запрос к OpenRouter API с учетом дизлайков
  final systemPrompt = _buildSystemPrompt(dislikes);
  // ...
}

String _buildSystemPrompt(List<Dislike> dislikes) {
  String prompt = _baseSystemPrompt;
  
  if (dislikes.isNotEmpty) {
    prompt += '\n\nВАЖНО: Пользователь НЕ любит:\n';
    for (final d in dislikes) {
      prompt += '- ${d.description} (категория: ${d.category})\n';
    }
    prompt += 'НЕ предлагайте товары или образы, содержащие перечисленное.';
  }
  
  return prompt;
}
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

**Новые файлы**:
```python
# backend/app.py (682 строки)
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Stylee Python Backend")

# Основные эндпоинты:
# - /api/profile/upsert - создание/обновление профиля
# - /api/profile/{email} - получение профиля
# - /api/test-result - сохранение результатов квиза
# - /api/ai/chat - ИИ-чат
# - /api/favorites - избранное
# - /api/dislikes - дизлайки
```

**Модели данных**:
```python
class ProfileUpsert(BaseModel):
    username: str
    bio: str = ""
    profile_image_path: Optional[str] = None

class TestResultPayload(BaseModel):
    height: Optional[float] = None
    bust: Optional[float] = None
    waist: Optional[float] = None
    hips: Optional[float] = None
    city: Optional[str] = None
    preferredStyles: list[str] = []
    favoriteColors: list[str] = []
    avoidedColors: list[str] = []
    fitPreference: Optional[str] = None
    specialNotes: Optional[str] = None
```

**База данных SQLite**:
```python
def init_db() -> None:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            email TEXT PRIMARY KEY,
            username TEXT,
            bio TEXT DEFAULT '',
            profile_image_path TEXT,
            created_at TEXT NOT NULL,
            test_result_json TEXT
        );
        
        CREATE TABLE IF NOT EXISTS favorite_images (
            user_email TEXT NOT NULL,
            image_url TEXT NOT NULL,
            created_at TEXT NOT NULL,
            PRIMARY KEY (user_email, image_url)
        );
    """)
```

**Изменения во Flutter**:
```dart
// stylee_app/lib/services/backend_api_service.dart (новый)
class BackendApiService {
  static final instance = BackendApiService();
  
  Future<void> upsertProfile(...) async {...}
  Future<TestResult?> getTestResult(...) async {...}
  Future<void> saveDislike(...) async {...}
}
```

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

**Ключевые функции**:
```python
import imagehash
from PIL import Image
from io import BytesIO

def compute_phash_from_bytes(image_bytes: bytes) -> imagehash.ImageHash:
    """Вычисление pHash изображения"""
    img = Image.open(BytesIO(image_bytes)).convert('RGB')
    return imagehash.phash(img)


def visual_similarity_score(phash_a, phash_b) -> float:
    """Сходство двух изображений (0.0 - 1.0)"""
    dist = phash_a - phash_b
    max_bits = phash_a.hash.size
    return max(0.0, 1.0 - (dist / float(max_bits)))


def fetch_candidate_thumbnail_bytes(url: str, timeout: int = 3):
    """Загрузка миниатюры товара с мета-тегов og:image"""
    r = requests.get(url, headers=headers)
    soup = BeautifulSoup(r.text, 'lxml')
    
    # Приоритет: og:image > первое img
    meta = soup.find('meta', property='og:image')
    if meta and meta.get('content'):
        return download_image_to_bytes(meta.get('content'))
```

**Логика ранжирования**:
```python
def real_search_by_image(imageUrl, query, max_results=10):
    # 1. Скачиваем исходное изображение
    source_bytes = download_image_to_bytes(imageUrl)
    source_hash = compute_phash_from_bytes(source_bytes)
    
    # 2. Получаем кандидатов с маркетплейсов
    candidates = fetch_marketplace_candidates(query)
    
    # 3. Для каждого кандидата:
    #    - Скачать миниатюру
    #    - Вычислить pHash
    #    - Сравнить с исходным
    
    scored = []
    for candidate in candidates:
        thumb = fetch_candidate_thumbnail_bytes(candidate['url'])
        if thumb:
            cand_hash = compute_phash_from_bytes(thumb)
            score = visual_similarity_score(source_hash, cand_hash)
            scored.append((score, candidate))
    
    # 4. Сортируем по сходству и возвращаем top-N
    scored.sort(reverse=True)
    return [c for _, c in scored[:max_results]]
```

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

**Новые зависимости**:
```python
# requirements.txt
curl_cffi>=0.5.0  # Имитация браузера
playwright>=1.40.0  # Для сложных страниц
playwright-stealth>=1.1.0  # Антидетекция
```

**Код прокси**:
```python
WB_PROXY_URL = os.environ.get('WB_PROXY') or os.environ.get('MARKETPLACE_PROXY')

def get_proxy_config() -> dict:
    if not WB_PROXY_URL:
        return None
    return {'http': WB_PROXY_URL, 'https': WB_PROXY_URL}

def create_http_session():
    if curl_requests is not None:
        session = curl_requests.Session(impersonate='chrome120')
        proxy_config = get_proxy_config()
        if proxy_config:
            session.proxies = proxy_config
        return session
    
    session = requests.Session()
    session.proxies.update(get_proxy_config() or {})
    return session
```

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

## 3. Ключевые функции и их реализация

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

## 4. Схема архитектуры

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
