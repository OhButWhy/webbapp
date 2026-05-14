from __future__ import annotations

import json
import os
import sqlite3
import urllib.error
import urllib.parse
import urllib.request
import uuid
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from dotenv import load_dotenv

ROOT_DIR = Path(__file__).resolve().parent
DATA_DIR = ROOT_DIR / "data"
DB_PATH = DATA_DIR / "stylee.sqlite3"
# Load .env with priority: stylee_app/.env -> backend/.env -> repo root .env
try:
    # Prefer the app-level .env inside the Flutter project
    load_dotenv(dotenv_path=ROOT_DIR.parent / "stylee_app" / ".env", override=False)
except Exception:
    pass
try:
    # Then backend-local .env
    load_dotenv(dotenv_path=ROOT_DIR / ".env", override=False)
except Exception:
    pass
try:
    # Finally fallback to repo root .env
    load_dotenv(dotenv_path=ROOT_DIR.parent / ".env", override=False)
except Exception:
    pass

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
OPENROUTER_MODEL = os.getenv("OPENROUTER_MODEL", "qwen/qwen-vl-plus")
BACKEND_NAME = os.getenv("STYLEE_BACKEND_NAME", "Stylee Python Backend")


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
    preferredStyles: list[str] = Field(default_factory=list)
    favoriteColors: list[str] = Field(default_factory=list)
    avoidedColors: list[str] = Field(default_factory=list)
    fitPreference: Optional[str] = None
    specialNotes: Optional[str] = None


class DislikePayload(BaseModel):
    description: str
    category: str = "recommendation"


class FavoritePayload(BaseModel):
    imageUrl: str


class ChatCreatePayload(BaseModel):
    title: Optional[str] = None


class ChatMessagePayload(BaseModel):
    text: str = ""
    imageBase64: Optional[str] = None
    imageMimeType: Optional[str] = None


class AiChatPayload(BaseModel):
    email: str
    chatId: Optional[str] = None
    message: str = ""
    imageBase64: Optional[str] = None
    imageMimeType: Optional[str] = None
    imagePath: Optional[str] = None


class MarketplaceSearchPayload(BaseModel):
    imageUrl: Optional[str] = None
    imagePath: Optional[str] = None
    query: Optional[str] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    init_db()
    yield


app = FastAPI(title="Stylee Python Backend", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def db_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db() -> None:
    with db_connection() as conn:
        conn.executescript(
            """
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
                PRIMARY KEY (user_email, image_url),
                FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS dislikes (
                id TEXT PRIMARY KEY,
                user_email TEXT NOT NULL,
                description TEXT NOT NULL,
                category TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS chats (
                id TEXT PRIMARY KEY,
                user_email TEXT NOT NULL,
                title TEXT NOT NULL,
                last_message TEXT DEFAULT '',
                created_at TEXT NOT NULL,
                last_message_at TEXT,
                FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS messages (
                id TEXT PRIMARY KEY,
                chat_id TEXT NOT NULL,
                user_email TEXT NOT NULL,
                role TEXT NOT NULL,
                title TEXT,
                description TEXT,
                text TEXT,
                image_path TEXT,
                created_at TEXT NOT NULL,
                FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
                FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE
            );
            """
        )


def ensure_user(conn: sqlite3.Connection, email: str) -> None:
    conn.execute(
        """
        INSERT INTO users (email, username, bio, profile_image_path, created_at, test_result_json)
        VALUES (?, NULL, '', NULL, ?, NULL)
        ON CONFLICT(email) DO NOTHING
        """,
        (email, now_iso()),
    )


def fetch_user(conn: sqlite3.Connection, email: str) -> Optional[sqlite3.Row]:
    return conn.execute("SELECT * FROM users WHERE email = ?", (email,)).fetchone()


def fetch_dislikes(conn: sqlite3.Connection, email: str) -> list[dict[str, Any]]:
    rows = conn.execute(
        "SELECT id, description, category, created_at FROM dislikes WHERE user_email = ? ORDER BY created_at DESC",
        (email,),
    ).fetchall()
    return [dict(row) for row in rows]


def fetch_favorites(conn: sqlite3.Connection, email: str) -> list[str]:
    rows = conn.execute(
        "SELECT image_url FROM favorite_images WHERE user_email = ? ORDER BY created_at DESC",
        (email,),
    ).fetchall()
    return [row["image_url"] for row in rows]


def get_profile_payload(conn: sqlite3.Connection, email: str) -> dict[str, Any]:
    user = fetch_user(conn, email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    test_result = None
    if user["test_result_json"]:
        test_result = json.loads(user["test_result_json"])

    return {
        "email": user["email"],
        "username": user["username"],
        "bio": user["bio"] or "",
        "profileImagePath": user["profile_image_path"],
        "createdAt": user["created_at"],
        "testResult": test_result,
        "favoriteImages": fetch_favorites(conn, email),
        "dislikes": fetch_dislikes(conn, email),
    }


def build_test_result_summary(test_result: Optional[dict[str, Any]]) -> str:
    if not test_result:
        return ""

    parts: list[str] = []
    if test_result.get("preferredStyles"):
        parts.append(f"предпочтения по стилям: {', '.join(test_result['preferredStyles'])}")
    if test_result.get("favoriteColors"):
        parts.append(f"любимые цвета: {', '.join(test_result['favoriteColors'])}")
    if test_result.get("avoidedColors"):
        parts.append(f"избегаемые цвета: {', '.join(test_result['avoidedColors'])}")
    if test_result.get("fitPreference"):
        parts.append(f"посадка: {test_result['fitPreference']}")
    if test_result.get("city"):
        parts.append(f"город: {test_result['city']}")
    if test_result.get("specialNotes"):
        parts.append(f"особые пожелания: {test_result['specialNotes']}")

    return "; ".join(parts)


def build_dislike_section(dislikes: list[dict[str, Any]]) -> str:
    if not dislikes:
        return ""

    lines = [f"• {item['description']} ({item['category']})" for item in dislikes]
    return "\n\nИСКЛЮЧЕНИЯ (пользователь отметил как неподходящее):\n" + "\n".join(lines) + "\nИзбегай рекомендовать похожие варианты."


def build_system_prompt(profile: dict[str, Any], dislikes: list[dict[str, Any]]) -> str:
    test_result = profile.get("testResult") or {}
    summary = build_test_result_summary(test_result)

    prompt = [
        "Ты ИИ-стилист для приложения Stylee. Отвечай ТОЛЬКО на русском языке.",
        "Твоя задача — анализировать одежду на фото и помогать подбирать образы.",
        "ПРАВИЛА:",
        "1. Если получено фото — опиши что видишь (цвет, фасон, стиль, тип одежды)",
        "2. Давай конкретные рекомендации по сочетанию",
        "3. Учитывай occasion (мероприятие), сезон, погоду",
        "4. Предлагай дополнительные элементы гардероба",
        "5. Будь дружелюбной и стильной 😊",
        "6. Используй эмодзи для наглядности",
    ]

    if summary:
        prompt.append(f"\nПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ: {summary}")

    dislike_section = build_dislike_section(dislikes)
    if dislike_section:
        prompt.append(dislike_section)

    prompt.append(
        "\nВажно: если возможно, формируй ответ как полезную, структурированную стилистическую рекомендацию без воды."
    )
    return "\n".join(prompt)


def call_openrouter(system_prompt: str, user_message: str, image_base64: Optional[str] = None, image_mime_type: Optional[str] = None) -> str:
    if not OPENROUTER_API_KEY:
        raise HTTPException(status_code=500, detail="OPENROUTER_API_KEY is not configured")

    user_content: Any
    if image_base64:
        mime_type = image_mime_type or "image/jpeg"
        user_content = [
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:{mime_type};base64,{image_base64}",
                },
            },
            {
                "type": "text",
                "text": user_message or "Опиши эту одежду и дай стилистические рекомендации. Что подойдёт к этому образу?",
            },
        ]
    else:
        user_content = user_message or "Опиши этот образ и дай стилистические рекомендации."

    payload = {
        "model": OPENROUTER_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_content},
        ],
        "temperature": 0.7,
        "max_tokens": 1000,
    }

    request = urllib.request.Request(
        OPENROUTER_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "HTTP-Referer": "https://stylee-app.com",
            "X-Title": BACKEND_NAME,
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=90) as response:
            body = response.read().decode("utf-8")
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="ignore")
        raise HTTPException(status_code=error.code, detail=detail or str(error)) from error
    except urllib.error.URLError as error:
        raise HTTPException(status_code=502, detail=str(error)) from error

    data = json.loads(body)
    try:
        return data["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as error:
        raise HTTPException(status_code=502, detail="Unexpected OpenRouter response shape") from error


def build_marketplace_stub_results(seed_query: str) -> list[dict[str, str]]:
    encoded = urllib.parse.quote_plus(seed_query or "стильная одежда")
    return [
        {
            "title": "Платье миди, базовое",
            "marketplace": "Wildberries",
            "url": (
                "https://www.wildberries.ru/catalog/0/search.aspx?search="
                f"{encoded}"
            ),
        },
        {
            "title": "Блейзер прямого кроя",
            "marketplace": "Ozon",
            "url": f"https://www.ozon.ru/search/?text={encoded}",
        },
        {
            "title": "Джинсы wide-leg",
            "marketplace": "Lamoda",
            "url": f"https://www.lamoda.ru/catalogsearch/result/?q={encoded}",
        },
        {
            "title": "Рубашка oversize",
            "marketplace": "Яндекс Маркет",
            "url": f"https://market.yandex.ru/search?text={encoded}",
        },
        {
            "title": "Тренч классический",
            "marketplace": "Wildberries",
            "url": (
                "https://www.wildberries.ru/catalog/0/search.aspx?search="
                f"{encoded}+тренч"
            ),
        },
        {
            "title": "Юбка плиссе",
            "marketplace": "Ozon",
            "url": f"https://www.ozon.ru/search/?text={encoded}+юбка",
        },
        {
            "title": "Кроссовки минималистичные",
            "marketplace": "Lamoda",
            "url": (
                "https://www.lamoda.ru/catalogsearch/result/?q="
                f"{encoded}+кроссовки"
            ),
        },
        {
            "title": "Сумка через плечо",
            "marketplace": "Яндекс Маркет",
            "url": f"https://market.yandex.ru/search?text={encoded}+сумка",
        },
        {
            "title": "Пальто демисезонное",
            "marketplace": "Wildberries",
            "url": (
                "https://www.wildberries.ru/catalog/0/search.aspx?search="
                f"{encoded}+пальто"
            ),
        },
        {
            "title": "Аксессуары к образу",
            "marketplace": "Ozon",
            "url": f"https://www.ozon.ru/search/?text={encoded}+аксессуары",
        },
    ]


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/marketplace/search-by-image")
def marketplace_search_by_image(
    payload: MarketplaceSearchPayload,
) -> dict[str, Any]:
    seed_parts: list[str] = []
    if payload.query:
        seed_parts.append(payload.query.strip())
    if payload.imageUrl:
        seed_parts.append("изображение")
    if payload.imagePath:
        seed_parts.append("фото")

    seed_query = (
        " ".join(part for part in seed_parts if part).strip() or "стильная одежда"
    )
    results = build_marketplace_stub_results(seed_query)[:10]
    return {
        "results": results,
        "source": "stub",
        "count": len(results),
    }


@app.post("/users/{email}/bootstrap")
def bootstrap_user(email: str) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.commit()
        return get_profile_payload(conn, email)


@app.get("/users/{email}/profile")
def get_profile(email: str) -> dict[str, Any]:
    with db_connection() as conn:
        return get_profile_payload(conn, email)


@app.get("/users/{email}/profile/username-available")
def username_available(email: str, username: str = Query(..., min_length=1)) -> dict[str, bool]:
    with db_connection() as conn:
        ensure_user(conn, email)
        row = conn.execute(
            "SELECT email FROM users WHERE username = ? AND email != ? LIMIT 1",
            (username, email),
        ).fetchone()
        return {"available": row is None}


@app.put("/users/{email}/profile")
def upsert_profile(email: str, payload: ProfileUpsert) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute(
            """
            UPDATE users
            SET username = ?, bio = ?, profile_image_path = ?
            WHERE email = ?
            """,
            (payload.username, payload.bio, payload.profile_image_path, email),
        )
        conn.commit()
        return get_profile_payload(conn, email)


@app.post("/users/{email}/test-result")
def save_test_result(email: str, payload: TestResultPayload) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute(
            "UPDATE users SET test_result_json = ? WHERE email = ?",
            (json.dumps(payload.model_dump(), ensure_ascii=False), email),
        )
        conn.commit()
        return get_profile_payload(conn, email)


@app.get("/users/{email}/test-result")
def get_test_result(email: str) -> dict[str, Any]:
    with db_connection() as conn:
        user = fetch_user(conn, email)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return {"testResult": json.loads(user["test_result_json"]) if user["test_result_json"] else None}


@app.get("/users/{email}/favorites")
def list_favorites(email: str) -> dict[str, list[str]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.commit()
        return {"favoriteImages": fetch_favorites(conn, email)}


@app.post("/users/{email}/favorites")
def add_favorite(email: str, payload: FavoritePayload) -> dict[str, list[str]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute(
            """
            INSERT OR IGNORE INTO favorite_images (user_email, image_url, created_at)
            VALUES (?, ?, ?)
            """,
            (email, payload.imageUrl, now_iso()),
        )
        conn.commit()
        return {"favoriteImages": fetch_favorites(conn, email)}


@app.delete("/users/{email}/favorites")
def remove_favorite(email: str, payload: FavoritePayload) -> dict[str, list[str]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute(
            "DELETE FROM favorite_images WHERE user_email = ? AND image_url = ?",
            (email, payload.imageUrl),
        )
        conn.commit()
        return {"favoriteImages": fetch_favorites(conn, email)}


@app.get("/users/{email}/dislikes")
def list_dislikes(email: str) -> dict[str, list[dict[str, Any]]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.commit()
        return {"dislikes": fetch_dislikes(conn, email)}


@app.post("/users/{email}/dislikes")
def add_dislike(email: str, payload: DislikePayload) -> dict[str, list[dict[str, Any]]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        dislike_id = f"{payload.description.lower().strip().replace(' ', '_')}_{uuid.uuid4().hex[:8]}"
        conn.execute(
            """
            INSERT INTO dislikes (id, user_email, description, category, created_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (dislike_id, email, payload.description, payload.category, now_iso()),
        )
        conn.commit()
        return {"dislikes": fetch_dislikes(conn, email)}


@app.delete("/users/{email}/dislikes/{dislike_id}")
def remove_dislike(email: str, dislike_id: str) -> dict[str, list[dict[str, Any]]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute("DELETE FROM dislikes WHERE user_email = ? AND id = ?", (email, dislike_id))
        conn.commit()
        return {"dislikes": fetch_dislikes(conn, email)}


@app.delete("/users/{email}/dislikes")
def clear_dislikes(email: str) -> dict[str, list[dict[str, Any]]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute("DELETE FROM dislikes WHERE user_email = ?", (email,))
        conn.commit()
        return {"dislikes": []}


@app.get("/users/{email}/chats")
def list_chats(email: str) -> dict[str, list[dict[str, Any]]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        rows = conn.execute(
            """
            SELECT id, title, last_message, created_at, last_message_at
            FROM chats
            WHERE user_email = ?
            ORDER BY COALESCE(last_message_at, created_at) DESC
            """,
            (email,),
        ).fetchall()
        return {"chats": [dict(row) for row in rows]}


@app.post("/users/{email}/chats")
def create_chat(email: str, payload: ChatCreatePayload) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, email)
        chat_id = uuid.uuid4().hex
        title = payload.title or "Новый чат"
        created_at = now_iso()
        conn.execute(
            """
            INSERT INTO chats (id, user_email, title, last_message, created_at, last_message_at)
            VALUES (?, ?, ?, '', ?, ?)
            """,
            (chat_id, email, title, created_at, created_at),
        )
        conn.commit()
        return {"chatId": chat_id, "title": title, "createdAt": created_at}


@app.delete("/users/{email}/chats/{chat_id}")
def delete_chat(email: str, chat_id: str) -> dict[str, str]:
    with db_connection() as conn:
        ensure_user(conn, email)
        conn.execute("DELETE FROM chats WHERE id = ? AND user_email = ?", (chat_id, email))
        conn.commit()
        return {"status": "deleted"}


@app.get("/users/{email}/chats/{chat_id}/messages")
def list_messages(email: str, chat_id: str) -> dict[str, list[dict[str, Any]]]:
    with db_connection() as conn:
        ensure_user(conn, email)
        rows = conn.execute(
            """
            SELECT id, role, title, description, text, image_path, created_at
            FROM messages
            WHERE chat_id = ? AND user_email = ?
            ORDER BY created_at ASC
            """,
            (chat_id, email),
        ).fetchall()
        return {"messages": [dict(row) for row in rows]}


@app.post("/users/{email}/chats/{chat_id}/messages")
def add_message(email: str, chat_id: str, payload: ChatMessagePayload) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, email)
        created_at = now_iso()
        message_id = uuid.uuid4().hex
        message_type = "user_image" if payload.imageBase64 else "user"
        conn.execute(
            """
            INSERT INTO messages (id, chat_id, user_email, role, title, description, text, image_path, created_at)
            VALUES (?, ?, ?, ?, NULL, NULL, ?, ?, ?)
            """,
            (message_id, chat_id, email, message_type, payload.text, None, created_at),
        )
        conn.execute(
            "UPDATE chats SET title = COALESCE(NULLIF(?, ''), title), last_message = ?, last_message_at = ? WHERE id = ? AND user_email = ?",
            (
                (payload.text[:30] + "...") if len(payload.text) > 30 else (payload.text or "Фото"),
                "📷 Фото" if payload.imageBase64 else payload.text,
                created_at,
                chat_id,
                email,
            ),
        )
        conn.commit()
        return {"messageId": message_id, "createdAt": created_at}


@app.post("/ai/chat")
def ai_chat(payload: AiChatPayload) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, payload.email)
        profile = get_profile_payload(conn, payload.email)
        if payload.chatId:
            chat_id = payload.chatId
            chat = conn.execute(
                "SELECT id FROM chats WHERE id = ? AND user_email = ?",
                (chat_id, payload.email),
            ).fetchone()
            if chat is None:
                raise HTTPException(status_code=404, detail="Chat not found")
        else:
            chat_id = uuid.uuid4().hex
            created_at = now_iso()
            title = payload.message[:30] + "..." if len(payload.message) > 30 else (payload.message or "Фото")
            conn.execute(
                """
                INSERT INTO chats (id, user_email, title, last_message, created_at, last_message_at)
                VALUES (?, ?, ?, '', ?, ?)
                """,
                (chat_id, payload.email, title, created_at, created_at),
            )

        dislikes = profile.get("dislikes") or []
        system_prompt = build_system_prompt(profile, dislikes)

        response_text = call_openrouter(
            system_prompt=system_prompt,
            user_message=payload.message,
            image_base64=payload.imageBase64,
            image_mime_type=payload.imageMimeType,
        )

        user_created_at = now_iso()
        user_message_id = uuid.uuid4().hex
        ai_message_id = uuid.uuid4().hex
        conn.execute(
            """
            INSERT INTO messages (id, chat_id, user_email, role, title, description, text, image_path, created_at)
            VALUES (?, ?, ?, ?, NULL, NULL, ?, NULL, ?)
            """,
            (
                user_message_id,
                chat_id,
                payload.email,
                "user_image" if payload.imageBase64 else "user",
                payload.message,
                user_created_at,
            ),
        )
        conn.execute(
            """
            INSERT INTO messages (id, chat_id, user_email, role, title, description, text, image_path, created_at)
            VALUES (?, ?, ?, ?, ?, ?, NULL, NULL, ?)
            """,
            (
                ai_message_id,
                chat_id,
                payload.email,
                "ai",
                "AI Recommendation",
                response_text,
                user_created_at,
            ),
        )
        conn.execute(
            """
            UPDATE chats
            SET last_message = ?, last_message_at = ?, title = COALESCE(NULLIF(title, ''), ?)
            WHERE id = ? AND user_email = ?
            """,
            (
                payload.message if payload.message else "📷 Фото",
                user_created_at,
                payload.message[:30] + "..." if payload.message and len(payload.message) > 30 else (payload.message or "Фото"),
                chat_id,
                payload.email,
            ),
        )
        conn.commit()

    return {
        "chatId": chat_id,
        "answer": response_text,
        "userMessageId": user_message_id,
        "aiMessageId": ai_message_id,
    }


@app.get("/ai/prompt-preview")
def prompt_preview(email: str) -> dict[str, Any]:
    with db_connection() as conn:
        ensure_user(conn, email)
        profile = get_profile_payload(conn, email)
        prompt = build_system_prompt(profile, profile.get("dislikes") or [])
        return {"systemPrompt": prompt}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app:app", host="0.0.0.0", port=int(os.getenv("PORT", "8000")), reload=True)
