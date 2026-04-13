import json

from claude_agent_sdk import (
    ClaudeSDKClient,
    ClaudeAgentOptions,
    AssistantMessage,
    ResultMessage,
    TextBlock,
    tool,
    create_sdk_mcp_server,
)

from app.services import text_extractor, book_manager

QA_SYSTEM_PROMPT = """You are a reading assistant helping a user understand a book they are currently reading.

You have access to tools that let you retrieve context from the book and search it. Use them when needed.

When the user selects text and asks a question:

1. Analyze the selected text carefully
2. Use get_book_context to retrieve surrounding context if the selection alone isn't enough
3. Use search_book to find related passages elsewhere in the book
4. Answer based on the book's actual content — be grounded in what the text says
5. Be concise but thorough
6. If the question goes beyond what the book covers, acknowledge that clearly
7. Quote relevant passages when helpful, using quotation marks
8. When explaining complex or abstract ideas, use a relatable analogy to make the concept click — draw from everyday life, familiar objects, or common experiences. For example, explain a feedback loop as a thermostat, or describe layered architecture as floors in a building. Only skip the analogy when the concept is already straightforward.

Always be helpful, insightful, and encourage deeper engagement with the text."""


def _make_tools(book_id: str):
    """Create book-specific MCP tools bound to a specific book_id."""

    @tool(
        "get_book_context",
        "Get the text content surrounding a specific part of the book. Use this to understand the context around text the user selected.",
        {"selected_text": str, "page_or_chapter": int},
    )
    async def get_book_context(args):
        context = text_extractor.get_context_around_selection(
            book_id, args["selected_text"], args["page_or_chapter"]
        )
        return {"content": [{"type": "text", "text": context or "No context found."}]}

    @tool(
        "search_book",
        "Search for a term or phrase across the entire book and return matching passages with their locations.",
        {"query": str},
    )
    async def search_book_tool(args):
        results = text_extractor.search_book(book_id, args["query"], max_results=5)
        if not results:
            return {"content": [{"type": "text", "text": f"No matches found for '{args['query']}'."}]}
        return {"content": [{"type": "text", "text": json.dumps(results, indent=2)}]}

    @tool(
        "get_book_metadata",
        "Get metadata about the current book including title, author, format, and page/chapter count.",
        {},
    )
    async def get_book_metadata(args):
        book = book_manager.get_book(book_id)
        if not book:
            return {"content": [{"type": "text", "text": "Book not found."}]}
        info = {"title": book.title, "author": book.author, "format": book.format, "total_pages": book.total_pages}
        return {"content": [{"type": "text", "text": json.dumps(info, indent=2)}]}

    return [get_book_context, search_book_tool, get_book_metadata]


async def ask_question(book_id: str, selected_text: str, question: str, page_or_chapter: int):
    """Stream Q&A response using the Claude Agent SDK subprocess."""
    book = book_manager.get_book(book_id)
    book_info = f'"{book.title}" by {book.author}' if book else "the current book"
    location_label = "page" if book and book.format == "pdf" else "chapter"

    user_prompt = f"""The user is reading {book_info} and is currently on {location_label} {page_or_chapter}.

They selected the following text:
\"\"\"{selected_text}\"\"\"

The user's question: {question}"""

    tools = _make_tools(book_id)
    server = create_sdk_mcp_server("book-tools", tools=tools)

    options = ClaudeAgentOptions(
        system_prompt=QA_SYSTEM_PROMPT,
        mcp_servers={"book-tools": server},
        max_turns=5,
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query(user_prompt)
        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        yield json.dumps({"type": "text", "content": block.text})
            elif isinstance(message, ResultMessage):
                break

    yield json.dumps({"type": "done"})
