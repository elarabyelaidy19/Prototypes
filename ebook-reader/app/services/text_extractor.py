from app.services import book_manager, pdf_service, epub_service


def get_context_around_selection(book_id: str, selected_text: str, page_or_chapter: int) -> str:
    """Get ~2000 chars of context around the selected text from the book."""
    book = book_manager.get_book(book_id)
    if not book:
        return ""

    filepath = book_manager.get_book_filepath(book_id)
    if not filepath:
        return ""

    if book.format == "pdf":
        full_text = pdf_service.extract_page_text(filepath, page_or_chapter)
    else:
        full_text = epub_service.get_chapter_text(filepath, page_or_chapter)

    if not selected_text or selected_text not in full_text:
        return full_text[:2000]

    idx = full_text.index(selected_text)
    start = max(0, idx - 800)
    end = min(len(full_text), idx + len(selected_text) + 800)
    return full_text[start:end]


def search_book(book_id: str, query: str, max_results: int = 5) -> list[dict]:
    """Search across entire book for matching passages."""
    book = book_manager.get_book(book_id)
    if not book:
        return []

    filepath = book_manager.get_book_filepath(book_id)
    if not filepath:
        return []

    if book.format == "pdf":
        all_texts = pdf_service.extract_all_text(filepath)
        label = "page"
    else:
        all_texts = epub_service.extract_all_text(filepath)
        label = "chapter"

    query_lower = query.lower()
    results = []
    for i, text in enumerate(all_texts):
        text_lower = text.lower()
        pos = text_lower.find(query_lower)
        if pos != -1:
            start = max(0, pos - 100)
            end = min(len(text), pos + len(query) + 200)
            results.append({
                f"{label}": i,
                "snippet": text[start:end],
            })
            if len(results) >= max_results:
                break

    return results
