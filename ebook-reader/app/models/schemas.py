from pydantic import BaseModel


class BookInfo(BaseModel):
    id: str
    title: str
    author: str
    format: str
    filename: str
    cover_path: str | None = None
    total_pages: int = 0
    created_at: str = ""


class AskRequest(BaseModel):
    book_id: str
    selected_text: str
    question: str
    page_or_chapter: int = 0


class AuthorChatRequest(BaseModel):
    book_id: str
    message: str
    conversation_history: list[dict] = []


class ChatMessage(BaseModel):
    id: int = 0
    book_id: str
    mode: str
    role: str
    content: str
    created_at: str = ""
