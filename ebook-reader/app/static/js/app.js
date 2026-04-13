// ─── State ───────────────────────────────────────────────────────────────────
const state = {
    currentBook: null,
    currentPage: 0,
    selectedText: '',
    chatMode: 'qa',
    authorHistory: [],
    isStreaming: false,
    textViewActive: false,
    pageTextCache: {},
    textLayerData: null,
};

// ─── DOM ─────────────────────────────────────────────────────────────────────
const $ = (s) => document.querySelector(s);
const dom = {
    uploadZone:     $('#upload-zone'),
    fileInput:      $('#file-input'),
    bookList:       $('#book-list'),
    welcome:        $('#welcome-screen'),
    toolbar:        $('#reader-toolbar'),
    pdfReader:      $('#pdf-reader'),
    pdfTextView:    $('#pdf-text-view'),
    pdfTextContent: $('#pdf-text-content'),
    epubReader:     $('#epub-reader'),
    pdfImg:         $('#pdf-page-img'),
    pdfTextLayer:   $('#pdf-text-layer'),
    epubFrame:      $('#epub-frame'),
    pageInfo:       $('#page-info'),
    titleBar:       $('#book-title-bar'),
    btnPrev:        $('#btn-prev'),
    btnNext:        $('#btn-next'),
    btnText:        $('#btn-text-toggle'),
    btnChat:        $('#btn-chat-toggle'),
    chatSidebar:    $('#chat-sidebar'),
    chatMessages:   $('#chat-messages'),
    chatInput:      $('#chat-input'),
    btnSend:        $('#btn-send'),
    tabQa:          $('#tab-qa'),
    tabAuthor:      $('#tab-author'),
    selToolbar:     $('#selection-toolbar'),
    selAsk:         $('#sel-ask'),
    selAuthor:      $('#sel-author'),
    selPreview:     $('#selected-text-preview'),
    selContent:     $('#selected-text-content'),
    uploadOverlay:  $('#upload-overlay'),
    btnClearChat:   $('#btn-clear-chat'),
};

// ─── Markdown Renderer ───────────────────────────────────────────────────────
function renderMarkdown(raw) {
    // 1. Extract fenced code blocks first (protect from other transformations)
    const codeBlocks = [];
    let text = raw.replace(/```(\w*)\n([\s\S]*?)```/g, (_, lang, code) => {
        const idx = codeBlocks.length;
        codeBlocks.push({ lang: lang || '', code: code.replace(/\n$/, '') });
        return `\x00CODEBLOCK_${idx}\x00`;
    });

    // 2. Escape HTML in the remaining text
    text = escapeHtml(text);

    // 3. Inline transforms
    text = text
        .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
        .replace(/(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)/g, '<em>$1</em>')
        .replace(/`([^`]+)`/g, '<code>$1</code>');

    // 4. Block-level transforms (line by line)
    const lines = text.split('\n');
    let html = '';
    let inList = false;
    let listType = '';

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];

        // Code block placeholder
        const cbMatch = line.match(/\x00CODEBLOCK_(\d+)\x00/);
        if (cbMatch) {
            if (inList) { html += `</${listType}>`; inList = false; }
            const cb = codeBlocks[parseInt(cbMatch[1])];
            html += buildCodeBlock(cb.lang, cb.code);
            continue;
        }

        // Headers
        const h3 = line.match(/^### (.+)/);
        if (h3) { if (inList) { html += `</${listType}>`; inList = false; } html += `<h3>${h3[1]}</h3>`; continue; }
        const h2 = line.match(/^## (.+)/);
        if (h2) { if (inList) { html += `</${listType}>`; inList = false; } html += `<h2>${h2[1]}</h2>`; continue; }
        const h1 = line.match(/^# (.+)/);
        if (h1) { if (inList) { html += `</${listType}>`; inList = false; } html += `<h1>${h1[1]}</h1>`; continue; }

        // Blockquote
        const bq = line.match(/^&gt;\s?(.*)/);
        if (bq) { if (inList) { html += `</${listType}>`; inList = false; } html += `<blockquote>${bq[1]}</blockquote>`; continue; }

        // Unordered list
        const ul = line.match(/^[\-\*]\s+(.*)/);
        if (ul) {
            if (!inList || listType !== 'ul') { if (inList) html += `</${listType}>`; html += '<ul>'; inList = true; listType = 'ul'; }
            html += `<li>${ul[1]}</li>`;
            continue;
        }

        // Ordered list
        const ol = line.match(/^\d+\.\s+(.*)/);
        if (ol) {
            if (!inList || listType !== 'ol') { if (inList) html += `</${listType}>`; html += '<ol>'; inList = true; listType = 'ol'; }
            html += `<li>${ol[1]}</li>`;
            continue;
        }

        // Close list if needed
        if (inList && line.trim() === '') { html += `</${listType}>`; inList = false; }

        // Empty line = paragraph break
        if (line.trim() === '') {
            html += '<br>';
            continue;
        }

        // Regular text
        html += line + '\n';
    }

    if (inList) html += `</${listType}>`;

    // Collapse multiple <br> into one
    html = html.replace(/(<br>\s*){3,}/g, '<br><br>');

    return html;
}

function buildCodeBlock(lang, rawCode) {
    const highlighted = highlightSyntax(escapeHtml(rawCode), lang);
    const langLabel = lang || 'text';
    return `<div class="code-block">
        <div class="code-block-header">
            <span class="code-block-lang">${escapeHtml(langLabel)}</span>
            <button class="code-block-copy" onclick="copyCode(this)">Copy</button>
        </div>
        <code class="code-block-code">${highlighted}</code>
    </div>`;
}

function highlightSyntax(code, lang) {
    // Universal keyword-based highlighting
    const keywords = /\b(function|const|let|var|if|else|return|for|while|class|import|from|export|default|async|await|try|catch|throw|new|this|def|self|print|True|False|None|in|not|and|or|is|with|as|yield|lambda|elif|except|finally|raise|pass|break|continue|do|switch|case|struct|enum|impl|fn|pub|use|mod|mut|match|loop|type|interface|extends|implements|static|void|int|str|float|bool|null|undefined|true|false)\b/g;
    const strings = /(&quot;(?:[^&]|&(?!quot;))*?&quot;|&#x27;(?:[^&]|&(?!#x27;))*?&#x27;|&apos;.*?&apos;)/g;
    const numbers = /\b(\d+\.?\d*)\b/g;
    const comments = /(\/\/.*$|#\s.*$|\/\*[\s\S]*?\*\/)/gm;
    const functions = /\b([a-zA-Z_]\w*)\s*\(/g;

    code = code.replace(comments, '<span class="tok-cm">$1</span>');
    code = code.replace(strings, '<span class="tok-str">$1</span>');
    code = code.replace(keywords, '<span class="tok-kw">$1</span>');
    code = code.replace(numbers, '<span class="tok-num">$1</span>');
    code = code.replace(functions, '<span class="tok-fn">$1</span>(');

    return code;
}

function copyCode(btn) {
    const code = btn.closest('.code-block').querySelector('.code-block-code').textContent;
    navigator.clipboard.writeText(code).then(() => {
        btn.textContent = 'Copied!';
        setTimeout(() => btn.textContent = 'Copy', 1500);
    });
}
// Expose globally for inline onclick
window.copyCode = copyCode;

function escapeHtml(str) {
    const d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
}

// ─── Library ─────────────────────────────────────────────────────────────────
async function loadBooks() {
    const res = await fetch('/api/books');
    const books = await res.json();
    renderBookList(books);
}

function renderBookList(books) {
    if (books.length === 0) {
        dom.bookList.innerHTML = '<div class="empty-list">No books yet</div>';
        return;
    }
    dom.bookList.innerHTML = books.map(b => `
        <div class="book-item ${state.currentBook?.id === b.id ? 'active' : ''}" data-id="${b.id}">
            <div class="book-cover">
                ${b.cover_path
                    ? `<img src="/api/books/${b.id}/cover" alt="">`
                    : `<svg fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"/></svg>`
                }
            </div>
            <div class="book-meta">
                <div class="book-title-item">${escapeHtml(b.title)}</div>
                <div class="book-author-item">${escapeHtml(b.author)}</div>
            </div>
            <button class="book-delete" data-id="${b.id}" title="Remove">
                <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
        </div>
    `).join('');

    dom.bookList.querySelectorAll('.book-item').forEach(el => {
        el.addEventListener('click', (e) => {
            if (e.target.closest('.book-delete')) return;
            openBook(el.dataset.id);
        });
    });
    dom.bookList.querySelectorAll('.book-delete').forEach(el => {
        el.addEventListener('click', async (e) => {
            e.stopPropagation();
            if (!confirm('Remove this book?')) return;
            await fetch(`/api/books/${el.dataset.id}`, { method: 'DELETE' });
            if (state.currentBook?.id === el.dataset.id) closeBook();
            loadBooks();
        });
    });
}

// ─── Upload ──────────────────────────────────────────────────────────────────
async function uploadFile(file) {
    dom.uploadOverlay.classList.add('visible');
    const form = new FormData();
    form.append('file', file);
    try {
        const res = await fetch('/api/books/upload', { method: 'POST', body: form });
        if (!res.ok) { const err = await res.json(); alert(err.detail || 'Upload failed'); return; }
        const book = await res.json();
        await loadBooks();
        openBook(book.id);
    } catch (e) {
        alert('Upload failed: ' + e.message);
    } finally {
        dom.uploadOverlay.classList.remove('visible');
    }
}

dom.uploadZone.addEventListener('click', () => dom.fileInput.click());
dom.fileInput.addEventListener('change', (e) => { if (e.target.files[0]) uploadFile(e.target.files[0]); e.target.value = ''; });
dom.uploadZone.addEventListener('dragover', (e) => { e.preventDefault(); dom.uploadZone.classList.add('drop-active'); });
dom.uploadZone.addEventListener('dragleave', () => dom.uploadZone.classList.remove('drop-active'));
dom.uploadZone.addEventListener('drop', (e) => { e.preventDefault(); dom.uploadZone.classList.remove('drop-active'); if (e.dataTransfer.files[0]) uploadFile(e.dataTransfer.files[0]); });

// ─── URL State Persistence ───────────────────────────────────────────────────
function saveToHash() {
    if (state.currentBook) {
        location.hash = `${state.currentBook.id}/${state.currentPage}`;
    } else {
        location.hash = '';
    }
}

function readFromHash() {
    const h = location.hash.replace('#', '');
    if (!h) return null;
    const [bookId, pageStr] = h.split('/');
    return { bookId, page: parseInt(pageStr) || 0 };
}

// ─── Book Reader ─────────────────────────────────────────────────────────────
async function openBook(bookId, startPage = 0) {
    const res = await fetch(`/api/books/${bookId}`);
    if (!res.ok) return;
    const book = await res.json();
    state.currentBook = book;
    state.currentPage = startPage;
    state.authorHistory = [];
    state.textViewActive = false;
    state.pageTextCache = {};

    dom.welcome.classList.add('hidden');
    dom.toolbar.classList.remove('hidden');
    dom.titleBar.textContent = book.title;
    dom.btnText.classList.toggle('hidden', book.format === 'epub');

    hideAllReaderPanels();
    if (book.format === 'pdf') {
        dom.pdfReader.classList.add('visible');
        loadPdfPage(startPage);
    } else {
        dom.epubReader.classList.add('visible');
        loadEpubChapter(startPage);
    }
    updateNav();
    saveToHash();
    loadBooks();

    // Load chat history for the current mode
    if (dom.chatSidebar.classList.contains('visible')) {
        loadChatHistory(state.chatMode);
    }
}

function closeBook() {
    state.currentBook = null;
    hideAllReaderPanels();
    dom.welcome.classList.remove('hidden');
    dom.toolbar.classList.add('hidden');
    dom.chatSidebar.classList.remove('visible');
    saveToHash();
}

function hideAllReaderPanels() {
    dom.pdfReader.classList.remove('visible');
    dom.pdfTextView.classList.remove('visible');
    dom.epubReader.classList.remove('visible');
}

let pageAbort = null;

async function loadPdfPage(n) {
    if (pageAbort) pageAbort.abort();
    pageAbort = new AbortController();
    const signal = pageAbort.signal;

    state.currentPage = n;
    dom.pdfImg.src = `/api/books/${state.currentBook.id}/page/${n}`;
    dom.pdfTextLayer.innerHTML = '';
    updateNav();
    saveToHash();

    // Fetch text data and text layer in parallel
    const textPromise = state.pageTextCache[n]
        ? Promise.resolve(null)
        : fetch(`/api/books/${state.currentBook.id}/page/${n}/text`, { signal }).then(r => r.json());
    const layerPromise = fetch(`/api/books/${state.currentBook.id}/page/${n}/textlayer`, { signal }).then(r => r.json());

    try {
        const [textData, layerData] = await Promise.all([textPromise, layerPromise]);
        if (signal.aborted) return;

        if (textData) {
            state.pageTextCache[n] = { html: textData.html, text: textData.text };
        }
        if (state.textViewActive) {
            dom.pdfTextContent.innerHTML = state.pageTextCache[n].html;
        }

        renderTextLayer(layerData);
    } catch (e) {
        if (e.name === 'AbortError') return;
        throw e;
    }
}

function renderTextLayer(layerData) {
    dom.pdfTextLayer.innerHTML = '';
    if (!layerData || !layerData.spans) return;
    state.textLayerData = layerData;

    const build = () => {
        const imgW = dom.pdfImg.clientWidth;
        const imgH = dom.pdfImg.clientHeight;
        if (!imgW || !imgH) return;

        dom.pdfTextLayer.style.width = imgW + 'px';
        dom.pdfTextLayer.style.height = imgH + 'px';

        const frag = document.createDocumentFragment();
        for (const s of layerData.spans) {
            const el = document.createElement('span');
            el.textContent = s.t;
            el.style.left = (s.x * imgW) + 'px';
            el.style.top = (s.y * imgH) + 'px';
            el.style.fontSize = (s.s * imgH) + 'px';
            el.style.letterSpacing = '0px';
            frag.appendChild(el);
        }
        dom.pdfTextLayer.appendChild(frag);

        // Measure each span and adjust letter-spacing to match expected width
        const children = dom.pdfTextLayer.children;
        for (let i = 0; i < children.length; i++) {
            const expected = layerData.spans[i].w * imgW;
            const actual = children[i].offsetWidth;
            const text = layerData.spans[i].t;
            if (actual > 0 && text.length > 1) {
                const diff = expected - actual;
                children[i].style.letterSpacing = (diff / (text.length - 1)) + 'px';
            }
        }
    };

    if (dom.pdfImg.complete && dom.pdfImg.naturalWidth > 0) {
        build();
    } else {
        dom.pdfImg.addEventListener('load', build, { once: true });
    }
}

function rebuildTextLayer() {
    if (state.textLayerData) renderTextLayer(state.textLayerData);
}

new ResizeObserver(() => {
    if (state.textLayerData && dom.pdfTextLayer.children.length > 0) rebuildTextLayer();
}).observe(document.getElementById('pdf-page-img'));

async function loadEpubChapter(n) {
    if (pageAbort) pageAbort.abort();
    pageAbort = new AbortController();
    const signal = pageAbort.signal;

    state.currentPage = n;
    updateNav();
    saveToHash();

    try {
        const res = await fetch(`/api/books/${state.currentBook.id}/chapter/${n}`, { signal });
        const data = await res.json();
        if (signal.aborted) return;
        dom.epubFrame.innerHTML = data.html;
        dom.epubReader.scrollTop = 0;
    } catch (e) {
        if (e.name === 'AbortError') return;
        throw e;
    }
}

function updateNav() {
    if (!state.currentBook) return;
    const { total_pages: t, format: f } = state.currentBook;
    const c = state.currentPage;
    dom.pageInfo.textContent = `${f === 'pdf' ? 'Page' : 'Chapter'} ${c + 1} / ${t}`;
    dom.btnPrev.disabled = c <= 0;
    dom.btnNext.disabled = c >= t - 1;
}

dom.btnPrev.addEventListener('click', () => {
    if (state.currentPage > 0) {
        state.currentBook.format === 'pdf' ? loadPdfPage(state.currentPage - 1) : loadEpubChapter(state.currentPage - 1);
    }
});
dom.btnNext.addEventListener('click', () => {
    if (state.currentPage < state.currentBook.total_pages - 1) {
        state.currentBook.format === 'pdf' ? loadPdfPage(state.currentPage + 1) : loadEpubChapter(state.currentPage + 1);
    }
});
document.addEventListener('keydown', (e) => {
    if (['INPUT', 'TEXTAREA'].includes(e.target.tagName) || !state.currentBook) return;
    if (e.key === 'ArrowLeft') dom.btnPrev.click();
    if (e.key === 'ArrowRight') dom.btnNext.click();
});

// ─── Text View Toggle ────────────────────────────────────────────────────────
dom.btnText.addEventListener('click', () => {
    if (!state.currentBook || state.currentBook.format !== 'pdf') return;
    state.textViewActive = !state.textViewActive;
    dom.btnText.classList.toggle('active', state.textViewActive);

    if (state.textViewActive) {
        dom.pdfReader.classList.remove('visible');
        dom.pdfTextView.classList.add('visible');
        const cached = state.pageTextCache[state.currentPage];
        dom.pdfTextContent.innerHTML = cached ? cached.html : '<p>Loading...</p>';
        if (!cached) {
            fetch(`/api/books/${state.currentBook.id}/page/${state.currentPage}/text`)
                .then(r => r.json()).then(d => { state.pageTextCache[state.currentPage] = { html: d.html, text: d.text }; dom.pdfTextContent.innerHTML = d.html; });
        }
    } else {
        dom.pdfTextView.classList.remove('visible');
        dom.pdfReader.classList.add('visible');
    }
});

// ─── Text Selection ──────────────────────────────────────────────────────────
document.addEventListener('mouseup', (e) => {
    setTimeout(() => {
        const text = window.getSelection()?.toString().trim();
        if (text && text.length > 2 && state.currentBook) {
            state.selectedText = text;
            const tb = dom.selToolbar;
            tb.classList.add('visible');
            tb.style.left = `${Math.min(e.clientX - 60, window.innerWidth - 240)}px`;
            tb.style.top = `${Math.max(e.clientY - 50, 10)}px`;
        } else {
            dom.selToolbar.classList.remove('visible');
        }
    }, 10);
});
document.addEventListener('mousedown', (e) => {
    if (!e.target.closest('.sel-toolbar')) dom.selToolbar.classList.remove('visible');
});

dom.selAsk.addEventListener('click', () => {
    dom.selToolbar.classList.remove('visible');
    openChat('qa');
    dom.selContent.textContent = state.selectedText;
    dom.selPreview.classList.add('visible');
    dom.chatInput.placeholder = 'Ask about this text...';
    dom.chatInput.focus();
});
dom.selAuthor.addEventListener('click', () => {
    dom.selToolbar.classList.remove('visible');
    openChat('author');
    sendMessage(`I'd like to discuss this passage: "${state.selectedText.substring(0, 200)}${state.selectedText.length > 200 ? '...' : ''}"`);
});

// ─── Chat ────────────────────────────────────────────────────────────────────
function openChat(mode) {
    state.chatMode = mode || state.chatMode;
    dom.chatSidebar.classList.add('visible');
    updateTabs();
}

dom.btnChat.addEventListener('click', () => {
    const wasHidden = !dom.chatSidebar.classList.contains('visible');
    dom.chatSidebar.classList.toggle('visible');
    if (wasHidden) loadChatHistory(state.chatMode);
});
dom.tabQa.addEventListener('click', () => switchMode('qa'));
dom.tabAuthor.addEventListener('click', () => switchMode('author'));
dom.btnClearChat.addEventListener('click', () => {
    if (!confirm('Clear this chat history?')) return;
    clearChatHistory(state.chatMode);
});

async function loadChatHistory(mode) {
    if (!state.currentBook) return;
    dom.chatMessages.innerHTML = '';
    try {
        const res = await fetch(`/api/ai/history/${state.currentBook.id}/${mode}`);
        const messages = await res.json();
        if (mode === 'author') {
            state.authorHistory = messages
                .filter(m => m.role !== 'system')
                .map(m => ({ role: m.role === 'assistant' ? 'assistant' : 'user', content: m.content }));
        }
        for (const msg of messages) {
            if (msg.role === 'user') addUserMsg(msg.content);
            else if (msg.role === 'assistant') { const el = addAiMsg(); updateAiMsg(el, msg.content); }
            else addSystemMsg(msg.content);
        }
    } catch {}
}

async function clearChatHistory(mode) {
    if (!state.currentBook) return;
    await fetch(`/api/ai/history/${state.currentBook.id}/${mode}`, { method: 'DELETE' });
    if (mode === 'author') state.authorHistory = [];
    dom.chatMessages.innerHTML = '';
}

function switchMode(mode) {
    state.chatMode = mode;
    state.selectedText = '';
    dom.selPreview.classList.remove('visible');
    dom.chatMessages.innerHTML = '';
    updateTabs();
    if (mode === 'author' && state.currentBook) {
        dom.chatInput.placeholder = `Chat with ${state.currentBook.author}...`;
    } else {
        dom.chatInput.placeholder = 'Select text, then ask a question...';
    }
    loadChatHistory(mode);
    dom.chatInput.focus();
}

function updateTabs() {
    dom.tabQa.classList.toggle('active', state.chatMode === 'qa');
    dom.tabAuthor.classList.toggle('active', state.chatMode === 'author');
}

dom.chatInput.addEventListener('keydown', (e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendCurrent(); } });
dom.btnSend.addEventListener('click', sendCurrent);
dom.chatInput.addEventListener('input', () => { dom.btnSend.disabled = !dom.chatInput.value.trim(); });

function sendCurrent() {
    const t = dom.chatInput.value.trim();
    if (!t || state.isStreaming || !state.currentBook) return;
    dom.chatInput.value = '';
    dom.btnSend.disabled = true;
    sendMessage(t);
}

async function sendMessage(text) {
    if (!state.currentBook) return;
    addUserMsg(text);
    const el = addAiMsg('');
    showTyping(el);
    state.isStreaming = true;

    try {
        let url, body;
        if (state.chatMode === 'qa') {
            url = '/api/ai/ask';
            body = { book_id: state.currentBook.id, selected_text: state.selectedText || '', question: text, page_or_chapter: state.currentPage };
        } else {
            url = '/api/ai/author-chat';
            body = { book_id: state.currentBook.id, message: text, conversation_history: state.authorHistory };
            state.authorHistory.push({ role: 'user', content: text });
        }

        const res = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
        const reader = res.body.getReader();
        const decoder = new TextDecoder();
        let full = '', buffer = '';

        while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            buffer += decoder.decode(value, { stream: true });
            const lines = buffer.split('\n');
            buffer = lines.pop() || '';
            for (const line of lines) {
                if (!line.startsWith('data: ')) continue;
                try {
                    const d = JSON.parse(line.slice(6));
                    if (d.type === 'text') { full += d.content; updateAiMsg(el, full); }
                } catch {}
            }
        }

        if (state.chatMode === 'author') state.authorHistory.push({ role: 'assistant', content: full });
        if (state.chatMode === 'qa') { state.selectedText = ''; dom.selPreview.classList.remove('visible'); }
    } catch {
        updateAiMsg(el, 'Something went wrong. Please try again.');
    } finally {
        state.isStreaming = false;
    }
}

// ─── Chat UI ─────────────────────────────────────────────────────────────────
function addUserMsg(text) {
    const d = document.createElement('div');
    d.className = 'msg-row user';
    d.innerHTML = `<div class="msg-bubble msg-user">${escapeHtml(text)}</div>`;
    dom.chatMessages.appendChild(d);
    scrollChat();
}

function addAiMsg() {
    const d = document.createElement('div');
    d.className = 'msg-row ai';
    d.innerHTML = `<div class="msg-bubble msg-ai"></div>`;
    dom.chatMessages.appendChild(d);
    scrollChat();
    return d.querySelector('.msg-ai');
}

function addSystemMsg(text) {
    const d = document.createElement('div');
    d.className = 'msg-row system';
    d.innerHTML = `<div class="msg-system">${escapeHtml(text)}</div>`;
    dom.chatMessages.appendChild(d);
    scrollChat();
}

function showTyping(el) {
    el.innerHTML = '<div class="typing-indicator"><span></span><span></span><span></span></div>';
}

function updateAiMsg(el, text) {
    el.innerHTML = renderMarkdown(text);
    scrollChat();
}

function scrollChat() {
    dom.chatMessages.scrollTop = dom.chatMessages.scrollHeight;
}

// ─── Chat Sidebar Resize ─────────────────────────────────────────────────────
const resizeHandle = document.getElementById('resize-handle');
let isResizing = false;

resizeHandle.addEventListener('mousedown', (e) => {
    isResizing = true;
    resizeHandle.classList.add('dragging');
    document.body.classList.add('resizing');
    e.preventDefault();
});

document.addEventListener('mousemove', (e) => {
    if (!isResizing) return;
    const sidebar = dom.chatSidebar;
    const newWidth = window.innerWidth - e.clientX;
    const clamped = Math.max(window.innerWidth * 0.33, Math.min(window.innerWidth * 0.5, newWidth));
    sidebar.style.width = clamped + 'px';
});

document.addEventListener('mouseup', () => {
    if (isResizing) {
        isResizing = false;
        resizeHandle.classList.remove('dragging');
        document.body.classList.remove('resizing');
    }
});

// ─── Init ────────────────────────────────────────────────────────────────────
async function init() {
    await loadBooks();
    const saved = readFromHash();
    if (saved && saved.bookId) {
        openBook(saved.bookId, saved.page);
    }
}
init();
