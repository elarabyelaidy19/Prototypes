import fitz  # PyMuPDF
from pathlib import Path

from app.config import UPLOAD_DIR


def _cache_dir(book_id: str) -> Path:
    d = UPLOAD_DIR / f".cache/{book_id}"
    d.mkdir(parents=True, exist_ok=True)
    return d


def render_page(filepath: str, page_num: int, dpi: int = 150) -> bytes:
    cache = _cache_dir(Path(filepath).stem) / f"page_{page_num}.png"
    if cache.exists():
        return cache.read_bytes()

    doc = fitz.open(filepath)
    page = doc[page_num]
    pix = page.get_pixmap(dpi=dpi)
    png_bytes = pix.tobytes("png")
    doc.close()

    cache.write_bytes(png_bytes)
    return png_bytes


def extract_page_text(filepath: str, page_num: int) -> str:
    doc = fitz.open(filepath)
    page = doc[page_num]
    text = page.get_text(sort=True)
    doc.close()
    return _clean(text)


def get_page_count(filepath: str) -> int:
    doc = fitz.open(filepath)
    count = len(doc)
    doc.close()
    return count


def extract_metadata(filepath: str) -> dict:
    doc = fitz.open(filepath)
    meta = doc.metadata or {}
    doc.close()
    return meta


def extract_cover(filepath: str, book_id: str) -> str | None:
    cache = _cache_dir(book_id) / "cover.png"
    if cache.exists():
        return str(cache)

    doc = fitz.open(filepath)
    if len(doc) == 0:
        doc.close()
        return None

    page = doc[0]
    pix = page.get_pixmap(dpi=72)
    pix.save(str(cache))
    doc.close()
    return str(cache)


def extract_text_layer(filepath: str, page_num: int) -> dict:
    """Extract text spans with bounding boxes for a selectable text overlay."""
    doc = fitz.open(filepath)
    page = doc[page_num]
    page_width = page.rect.width
    page_height = page.rect.height
    data = page.get_text("dict", sort=True)
    doc.close()

    spans = []
    for block in data.get("blocks", []):
        if block.get("type") != 0:
            continue
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                text = _clean(span["text"])
                if not text.strip():
                    continue
                bbox = span["bbox"]
                spans.append({
                    "t": text,
                    "x": bbox[0] / page_width,
                    "y": bbox[1] / page_height,
                    "w": (bbox[2] - bbox[0]) / page_width,
                    "h": (bbox[3] - bbox[1]) / page_height,
                    "s": round(span["size"] / page_height, 5),
                })

    return {"width": page_width, "height": page_height, "spans": spans}


def extract_all_text(filepath: str) -> list[str]:
    """Extract text from all pages. Returns list indexed by page number."""
    doc = fitz.open(filepath)
    texts = []
    for page in doc:
        texts.append(_clean(page.get_text(sort=True)))
    doc.close()
    return texts


def extract_page_html(filepath: str, page_num: int) -> str:
    """Extract structured HTML from a PDF page using font analysis."""
    doc = fitz.open(filepath)
    page = doc[page_num]
    data = page.get_text("dict", sort=True)
    doc.close()

    # Collect all font sizes to determine what's body vs heading
    all_sizes = []
    for block in data.get("blocks", []):
        if block.get("type") != 0:  # text blocks only
            continue
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                if span["text"].strip():
                    all_sizes.append(round(span["size"], 1))

    if not all_sizes:
        return ""

    # The most common font size is body text
    size_counts = {}
    for s in all_sizes:
        size_counts[s] = size_counts.get(s, 0) + 1
    body_size = max(size_counts, key=size_counts.get)

    html_parts = []
    prev_block_bottom = 0

    for block in data.get("blocks", []):
        if block.get("type") != 0:
            continue

        block_top = block["bbox"][1]
        # Detect paragraph gaps (vertical spacing > 1.5x body font size)
        if prev_block_bottom > 0 and (block_top - prev_block_bottom) > body_size * 1.5:
            html_parts.append('<div class="text-gap"></div>')
        prev_block_bottom = block["bbox"][3]

        block_spans = []
        for line in block.get("lines", []):
            line_spans = []
            for span in line.get("spans", []):
                text = span["text"]
                if not text:
                    continue

                size = round(span["size"], 1)
                flags = span.get("flags", 0)
                is_bold = bool(flags & 2**4)  # bit 4 = bold
                is_italic = bool(flags & 2**1)  # bit 1 = italic
                is_mono = "mono" in span.get("font", "").lower() or "courier" in span.get("font", "").lower() or "code" in span.get("font", "").lower()

                escaped = _escape(text)

                if is_mono and text.strip():
                    escaped = f'<code>{escaped}</code>'
                if is_bold:
                    escaped = f'<strong>{escaped}</strong>'
                if is_italic:
                    escaped = f'<em>{escaped}</em>'

                line_spans.append((escaped, size))

            if line_spans:
                block_spans.append(line_spans)

        if not block_spans:
            continue

        # Determine block-level tag by dominant font size
        dominant_size = max(
            (s for spans in block_spans for _, s in spans),
            default=body_size
        )

        # Build the text content for this block
        lines_html = []
        for line_spans in block_spans:
            lines_html.append("".join(text for text, _ in line_spans))
        content = " ".join(lines_html)

        if not content.strip():
            continue

        # Choose tag based on size ratio to body
        ratio = dominant_size / body_size if body_size else 1
        if ratio >= 1.8:
            html_parts.append(f'<h1>{content}</h1>')
        elif ratio >= 1.4:
            html_parts.append(f'<h2>{content}</h2>')
        elif ratio >= 1.15:
            html_parts.append(f'<h3>{content}</h3>')
        else:
            html_parts.append(f'<p>{content}</p>')

    return "\n".join(html_parts)


import re


def _clean(text: str) -> str:
    """Remove non-renderable characters that show as squares."""
    out = []
    for ch in text:
        cp = ord(ch)
        # Keep normal printable ASCII, tab, newline, carriage return
        if cp == 0x09 or cp == 0x0A or cp == 0x0D:
            out.append(ch)
            continue
        # Drop C0/C1 control characters
        if cp < 0x20 or (0x7F <= cp <= 0x9F):
            continue
        # Drop soft hyphen
        if cp == 0xAD:
            continue
        # Drop Private Use Area (PDF custom glyphs)
        if 0xE000 <= cp <= 0xF8FF:
            continue
        # Drop Unicode noncharacters and specials
        if cp >= 0xFFF0:
            continue
        # Drop supplementary PUA
        if 0xF0000 <= cp <= 0xFFFFF or 0x100000 <= cp <= 0x10FFFF:
            continue
        # Drop replacement character
        if cp == 0xFFFD:
            continue
        # Drop zero-width chars
        if cp in (0x200B, 0x200C, 0x200D, 0x2060, 0xFEFF):
            continue
        out.append(ch)
    return ''.join(out)


def _escape(text: str) -> str:
    text = _clean(text)
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
