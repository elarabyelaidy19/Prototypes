import json
import uuid
from pathlib import Path

from fastapi import UploadFile

from app.config import UPLOAD_DIR
from app.models.database import get_db
from app.models.schemas import BookInfo
from app.services import pdf_service, epub_service


async def upload_book(file: UploadFile) -> BookInfo:
    book_id = str(uuid.uuid4())
    ext = Path(file.filename).suffix.lower()

    if ext not in (".pdf", ".epub"):
        raise ValueError(f"Unsupported format: {ext}")

    fmt = ext.lstrip(".")
    save_path = UPLOAD_DIR / f"{book_id}{ext}"

    content = await file.read()
    save_path.write_bytes(content)

    if fmt == "pdf":
        meta = pdf_service.extract_metadata(str(save_path))
        title = meta.get("title") or Path(file.filename).stem
        author = meta.get("author") or "Unknown"
        total_pages = pdf_service.get_page_count(str(save_path))
        cover = pdf_service.extract_cover(str(save_path), book_id)
    else:
        parsed = epub_service.parse_epub(str(save_path))
        title = parsed["title"]
        author = parsed["author"]
        total_pages = parsed["chapter_count"]
        cover = epub_service.extract_cover(str(save_path), book_id)
        meta = {"chapters": parsed["chapters"]}

    db = get_db()
    db.execute(
        """INSERT INTO books (id, title, author, format, filename, filepath, cover_path, total_pages, metadata_json)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (book_id, title, author, fmt, file.filename, str(save_path), cover, total_pages, json.dumps(meta)),
    )
    db.commit()
    db.close()

    return BookInfo(
        id=book_id, title=title, author=author, format=fmt,
        filename=file.filename, cover_path=cover, total_pages=total_pages,
    )


def get_book(book_id: str) -> BookInfo | None:
    db = get_db()
    row = db.execute("SELECT * FROM books WHERE id = ?", (book_id,)).fetchone()
    db.close()
    if not row:
        return None
    return BookInfo(
        id=row["id"], title=row["title"], author=row["author"],
        format=row["format"], filename=row["filename"],
        cover_path=row["cover_path"], total_pages=row["total_pages"],
        created_at=row["created_at"],
    )


def get_book_filepath(book_id: str) -> str | None:
    db = get_db()
    row = db.execute("SELECT filepath FROM books WHERE id = ?", (book_id,)).fetchone()
    db.close()
    return row["filepath"] if row else None


def get_book_metadata_json(book_id: str) -> dict:
    db = get_db()
    row = db.execute("SELECT metadata_json FROM books WHERE id = ?", (book_id,)).fetchone()
    db.close()
    return json.loads(row["metadata_json"]) if row else {}


def list_books() -> list[BookInfo]:
    db = get_db()
    rows = db.execute("SELECT * FROM books ORDER BY created_at DESC").fetchall()
    db.close()
    return [
        BookInfo(
            id=r["id"], title=r["title"], author=r["author"],
            format=r["format"], filename=r["filename"],
            cover_path=r["cover_path"], total_pages=r["total_pages"],
            created_at=r["created_at"],
        )
        for r in rows
    ]


def delete_book(book_id: str) -> bool:
    db = get_db()
    row = db.execute("SELECT filepath FROM books WHERE id = ?", (book_id,)).fetchone()
    if not row:
        db.close()
        return False

    filepath = Path(row["filepath"])
    if filepath.exists():
        filepath.unlink()

    cache_dir = UPLOAD_DIR / f".cache/{book_id}"
    if cache_dir.exists():
        import shutil
        shutil.rmtree(cache_dir)

    db.execute("DELETE FROM chat_messages WHERE book_id = ?", (book_id,))
    db.execute("DELETE FROM books WHERE id = ?", (book_id,))
    db.commit()
    db.close()
    return True
