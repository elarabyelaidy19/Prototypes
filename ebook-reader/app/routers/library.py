from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse

from app.services import book_manager

router = APIRouter(prefix="/api/books", tags=["library"])


@router.post("/upload")
async def upload_book(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(400, "No filename provided")

    ext = file.filename.rsplit(".", 1)[-1].lower() if "." in file.filename else ""
    if ext not in ("pdf", "epub"):
        raise HTTPException(400, f"Unsupported format: .{ext}. Only PDF and EPUB are supported.")

    try:
        book = await book_manager.upload_book(file)
        return book.model_dump()
    except ValueError as e:
        raise HTTPException(400, str(e))


@router.get("")
def list_books():
    return [b.model_dump() for b in book_manager.list_books()]


@router.get("/{book_id}")
def get_book(book_id: str):
    book = book_manager.get_book(book_id)
    if not book:
        raise HTTPException(404, "Book not found")
    return book.model_dump()


@router.delete("/{book_id}")
def delete_book(book_id: str):
    if not book_manager.delete_book(book_id):
        raise HTTPException(404, "Book not found")
    return {"ok": True}


@router.get("/{book_id}/cover")
def get_cover(book_id: str):
    book = book_manager.get_book(book_id)
    if not book or not book.cover_path:
        raise HTTPException(404, "Cover not found")
    return FileResponse(book.cover_path, media_type="image/png")
