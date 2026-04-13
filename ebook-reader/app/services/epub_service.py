import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
from pathlib import Path

from app.config import UPLOAD_DIR


def parse_epub(filepath: str) -> dict:
    book = epub.read_epub(filepath, options={"ignore_ncx": True})

    title = book.get_metadata("DC", "title")
    title = title[0][0] if title else Path(filepath).stem

    author = book.get_metadata("DC", "creator")
    author = author[0][0] if author else "Unknown"

    chapters = _get_spine_items(book)

    return {
        "title": title,
        "author": author,
        "chapter_count": len(chapters),
        "chapters": [{"index": i, "title": _extract_chapter_title(ch)} for i, ch in enumerate(chapters)],
    }


def _get_spine_items(book: epub.EpubBook) -> list:
    items = []
    for spine_id, _ in book.spine:
        item = book.get_item_with_id(spine_id)
        if item and item.get_type() == ebooklib.ITEM_DOCUMENT:
            items.append(item)
    return items


def _extract_chapter_title(item) -> str:
    soup = BeautifulSoup(item.get_content().decode("utf-8", errors="replace"), "html.parser")
    heading = soup.find(["h1", "h2", "h3", "title"])
    if heading:
        return heading.get_text(strip=True)[:100]
    text = soup.get_text(strip=True)
    return text[:60] + "..." if len(text) > 60 else text or "Untitled"


def get_chapter_html(filepath: str, chapter_index: int) -> str:
    book = epub.read_epub(filepath, options={"ignore_ncx": True})
    chapters = _get_spine_items(book)
    if chapter_index < 0 or chapter_index >= len(chapters):
        return "<p>Chapter not found.</p>"

    content = chapters[chapter_index].get_content().decode("utf-8", errors="replace")
    return content


def get_chapter_text(filepath: str, chapter_index: int) -> str:
    html = get_chapter_html(filepath, chapter_index)
    soup = BeautifulSoup(html, "html.parser")
    return soup.get_text(separator="\n", strip=True)


def get_chapter_count(filepath: str) -> int:
    book = epub.read_epub(filepath, options={"ignore_ncx": True})
    return len(_get_spine_items(book))


def extract_cover(filepath: str, book_id: str) -> str | None:
    cache_dir = UPLOAD_DIR / f".cache/{book_id}"
    cache_dir.mkdir(parents=True, exist_ok=True)
    cover_path = cache_dir / "cover.png"

    if cover_path.exists():
        return str(cover_path)

    book = epub.read_epub(filepath, options={"ignore_ncx": True})

    # Try cover image
    for item in book.get_items_of_type(ebooklib.ITEM_COVER):
        cover_path.write_bytes(item.get_content())
        return str(cover_path)

    # Try first image
    for item in book.get_items_of_type(ebooklib.ITEM_IMAGE):
        cover_path.write_bytes(item.get_content())
        return str(cover_path)

    return None


def extract_all_text(filepath: str) -> list[str]:
    """Extract text from all chapters. Returns list indexed by chapter number."""
    book = epub.read_epub(filepath, options={"ignore_ncx": True})
    chapters = _get_spine_items(book)
    texts = []
    for ch in chapters:
        html = ch.get_content().decode("utf-8", errors="replace")
        soup = BeautifulSoup(html, "html.parser")
        texts.append(soup.get_text(separator="\n", strip=True))
    return texts
