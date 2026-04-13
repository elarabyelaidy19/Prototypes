from fastapi import APIRouter
from fastapi.responses import StreamingResponse

from app.models.database import get_db
from app.models.schemas import AskRequest, AuthorChatRequest
from app.agents import qa_agent, author_agent

router = APIRouter(prefix="/api/ai", tags=["ai"])


def _save_message(book_id: str, mode: str, role: str, content: str):
    db = get_db()
    db.execute(
        "INSERT INTO chat_messages (book_id, mode, role, content) VALUES (?, ?, ?, ?)",
        (book_id, mode, role, content),
    )
    db.commit()
    db.close()


@router.post("/ask")
async def ask_question(request: AskRequest):
    _save_message(request.book_id, "qa", "user", request.question)

    async def event_stream():
        import json
        full_response = []
        async for data in qa_agent.ask_question(
            request.book_id, request.selected_text,
            request.question, request.page_or_chapter,
        ):
            parsed = json.loads(data)
            if parsed.get("type") == "text":
                full_response.append(parsed["content"])
            yield f"data: {data}\n\n"
        _save_message(request.book_id, "qa", "assistant", "".join(full_response))

    return StreamingResponse(event_stream(), media_type="text/event-stream")


@router.post("/author-chat")
async def author_chat(request: AuthorChatRequest):
    _save_message(request.book_id, "author", "user", request.message)

    async def event_stream():
        import json
        full_response = []
        async for data in author_agent.chat_with_author(
            request.book_id, request.message,
            request.conversation_history,
        ):
            parsed = json.loads(data)
            if parsed.get("type") == "text":
                full_response.append(parsed["content"])
            yield f"data: {data}\n\n"
        _save_message(request.book_id, "author", "assistant", "".join(full_response))

    return StreamingResponse(event_stream(), media_type="text/event-stream")


@router.get("/history/{book_id}/{mode}")
async def get_chat_history(book_id: str, mode: str):
    db = get_db()
    rows = db.execute(
        "SELECT id, role, content, created_at FROM chat_messages WHERE book_id = ? AND mode = ? ORDER BY created_at",
        (book_id, mode),
    ).fetchall()
    db.close()
    return [{"id": r["id"], "role": r["role"], "content": r["content"], "created_at": r["created_at"]} for r in rows]


@router.delete("/history/{book_id}/{mode}")
async def clear_chat_history(book_id: str, mode: str):
    db = get_db()
    db.execute("DELETE FROM chat_messages WHERE book_id = ? AND mode = ?", (book_id, mode))
    db.commit()
    db.close()
    return {"ok": True}


@router.delete("/history/{book_id}")
async def clear_all_chat_history(book_id: str):
    db = get_db()
    db.execute("DELETE FROM chat_messages WHERE book_id = ?", (book_id,))
    db.commit()
    db.close()
    return {"ok": True}
