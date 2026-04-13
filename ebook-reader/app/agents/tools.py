import json

from claude_agent_sdk import tool

from app.services import text_extractor, book_manager


@tool(
    "get_book_context",
    "Get the text content surrounding a specific part of the book. Use this to understand the context around text the user selected.",
    {"book_id": str, "selected_text": str, "page_or_chapter": int},
)
async def get_book_context(args):
    context = text_extractor.get_context_around_selection(
        args["book_id"], args["selected_text"], args["page_or_chapter"]
    )
    return {"content": [{"type": "text", "text": context or "No context found."}]}


@tool(
    "get_book_metadata",
    "Get metadata about the current book including title, author, format, and page/chapter count.",
    {"book_id": str},
)
async def get_book_metadata(args):
    book = book_manager.get_book(args["book_id"])
    if not book:
        return {"content": [{"type": "text", "text": "Book not found."}]}

    info = {
        "title": book.title,
        "author": book.author,
        "format": book.format,
        "total_pages": book.total_pages,
    }
    extra = book_manager.get_book_metadata_json(args["book_id"])
    info.update(extra)
    return {"content": [{"type": "text", "text": json.dumps(info, indent=2)}]}


@tool(
    "search_book",
    "Search for a term or phrase across the entire book and return matching passages with their locations.",
    {"book_id": str, "query": str, "max_results": int},
)
async def search_book(args):
    results = text_extractor.search_book(
        args["book_id"], args["query"], args.get("max_results", 5)
    )
    if not results:
        return {"content": [{"type": "text", "text": f"No matches found for '{args['query']}'."}]}

    return {"content": [{"type": "text", "text": json.dumps(results, indent=2)}]}
