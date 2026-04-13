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


def _build_author_prompt(title: str, author_name: str) -> str:
    return f"""You are {author_name}, the author of "{title}". You are having a warm, engaging conversation with a reader of your book.

Stay in character as the author at all times. Speak from your perspective as the person who wrote this book.

Guidelines:
- Draw on the book's actual content when answering questions — use the search_book tool to look up relevant passages
- Share "behind the scenes" insights about why you wrote certain passages or made certain choices
- Be warm, intellectually generous, and genuinely interested in the reader's thoughts
- If asked about something not in the book, you may speculate as the author would, but note when you're going beyond the text
- Express your passion for the subject matter
- Never break character to say you are an AI
- If the reader disagrees with something you wrote, engage thoughtfully — great authors welcome debate
- When explaining difficult or abstract ideas, reach for an analogy that makes it tangible — compare concepts to everyday things the reader already understands. A great author makes the complex feel simple. Only skip this when the idea is already clear on its own.

Remember: you ARE {author_name}. Respond as they would — with their voice, their personality, their expertise."""


def _make_tools(book_id: str):
    """Create book-specific MCP tools bound to a specific book_id."""

    @tool(
        "search_book",
        "Search for a term or phrase across your book and return matching passages. Use this to recall what you wrote.",
        {"query": str},
    )
    async def search_book_tool(args):
        results = text_extractor.search_book(book_id, args["query"], max_results=5)
        if not results:
            return {"content": [{"type": "text", "text": f"No passages found matching '{args['query']}'."}]}
        return {"content": [{"type": "text", "text": json.dumps(results, indent=2)}]}

    @tool(
        "get_book_context",
        "Get text content from a specific page or chapter of your book.",
        {"selected_text": str, "page_or_chapter": int},
    )
    async def get_book_context(args):
        context = text_extractor.get_context_around_selection(
            book_id, args["selected_text"], args["page_or_chapter"]
        )
        return {"content": [{"type": "text", "text": context or "No context found."}]}

    return [search_book_tool, get_book_context]


async def chat_with_author(book_id: str, message: str, conversation_history: list[dict]):
    """Stream author persona response using the Claude Agent SDK subprocess."""
    book = book_manager.get_book(book_id)
    if not book:
        yield json.dumps({"type": "text", "content": "I couldn't find the book you're reading."})
        yield json.dumps({"type": "done"})
        return

    system_prompt = _build_author_prompt(book.title, book.author)

    # Build the full prompt with conversation history for context
    history_text = ""
    for entry in conversation_history[-20:]:
        role = "Reader" if entry["role"] == "user" else book.author
        history_text += f"{role}: {entry['content']}\n\n"

    user_prompt = f"""Previous conversation:
{history_text}
Reader: {message}

Respond as {book.author} to the reader's latest message. Stay in character.""" if history_text else message

    tools = _make_tools(book_id)
    server = create_sdk_mcp_server("book-tools", tools=tools)

    options = ClaudeAgentOptions(
        system_prompt=system_prompt,
        mcp_servers={"book-tools": server},
        max_turns=5,
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query(user_prompt)
        async for message_obj in client.receive_response():
            if isinstance(message_obj, AssistantMessage):
                for block in message_obj.content:
                    if isinstance(block, TextBlock):
                        yield json.dumps({"type": "text", "content": block.text})
            elif isinstance(message_obj, ResultMessage):
                break

    yield json.dumps({"type": "done"})
