import json
from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from app.services import book_manager, pdf_service, epub_service

router = APIRouter(prefix="/api/books", tags=["reader"])


@router.get("/{book_id}/page/{page_num}")
def get_page(book_id: str, page_num: int):
    """Render a PDF page as PNG."""
    book = book_manager.get_book(book_id)
    if not book or book.format != "pdf":
        raise HTTPException(404, "PDF book not found")

    filepath = book_manager.get_book_filepath(book_id)
    if page_num < 0 or page_num >= book.total_pages:
        raise HTTPException(400, f"Page {page_num} out of range (0-{book.total_pages - 1})")

    png_bytes = pdf_service.render_page(filepath, page_num)
    return Response(content=png_bytes, media_type="image/png")


@router.get("/{book_id}/page/{page_num}/text")
def get_page_text(book_id: str, page_num: int):
    """Get extracted text from a PDF page as formatted HTML."""
    book = book_manager.get_book(book_id)
    if not book or book.format != "pdf":
        raise HTTPException(404, "PDF book not found")

    filepath = book_manager.get_book_filepath(book_id)
    html = pdf_service.extract_page_html(filepath, page_num)
    plain = pdf_service.extract_page_text(filepath, page_num)
    return {"html": html, "text": plain}


@router.get("/{book_id}/page/{page_num}/textlayer")
def get_text_layer(book_id: str, page_num: int):
    """Get positioned text spans for a selectable overlay on the PDF image."""
    book = book_manager.get_book(book_id)
    if not book or book.format != "pdf":
        raise HTTPException(404, "PDF book not found")

    filepath = book_manager.get_book_filepath(book_id)
    return pdf_service.extract_text_layer(filepath, page_num)


@router.get("/{book_id}/chapter/{chapter_num}")
def get_chapter(book_id: str, chapter_num: int):
    """Get EPUB chapter as HTML."""
    book = book_manager.get_book(book_id)
    if not book or book.format != "epub":
        raise HTTPException(404, "EPUB book not found")

    filepath = book_manager.get_book_filepath(book_id)
    html = epub_service.get_chapter_html(filepath, chapter_num)
    return {"html": html}


@router.get("/{book_id}/toc")
def get_toc(book_id: str):
    """Get table of contents / navigation info."""
    book = book_manager.get_book(book_id)
    if not book:
        raise HTTPException(404, "Book not found")

    if book.format == "epub":
        filepath = book_manager.get_book_filepath(book_id)
        parsed = epub_service.parse_epub(filepath)
        return {"format": "epub", "chapters": parsed["chapters"], "total": parsed["chapter_count"]}
    else:
        return {"format": "pdf", "total_pages": book.total_pages}
