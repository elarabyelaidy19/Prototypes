import sqlite3
from app.config import DB_PATH


def get_db() -> sqlite3.Connection:
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    return conn


def init_db():
    conn = get_db()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS books (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT NOT NULL DEFAULT 'Unknown',
            format TEXT NOT NULL CHECK(format IN ('pdf', 'epub')),
            filename TEXT NOT NULL,
            filepath TEXT NOT NULL,
            cover_path TEXT,
            total_pages INTEGER NOT NULL DEFAULT 0,
            metadata_json TEXT DEFAULT '{}',
            created_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS chat_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
            mode TEXT NOT NULL CHECK(mode IN ('qa', 'author')),
            role TEXT NOT NULL CHECK(role IN ('user', 'assistant', 'system')),
            content TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
    """)
    conn.execute("""
        CREATE INDEX IF NOT EXISTS idx_chat_book_mode
        ON chat_messages(book_id, mode, created_at)
    """)
    conn.execute("PRAGMA foreign_keys = ON")
    conn.commit()
    conn.close()
