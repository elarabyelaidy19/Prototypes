# Claude Agent SDK - Intro Guide

Build autonomous AI agents that can read files, run commands, search the web, and edit code — using the same engine that powers Claude Code.

## What is the Claude Agent SDK?

The Claude Agent SDK lets you **programmatically** spawn Claude as an autonomous agent. Instead of simple prompt-in/response-out, the agent enters a **loop** where it:

1. Reads your prompt
2. Decides which **tools** to use (file read, bash, web search, etc.)
3. Executes the tool
4. Reads the result
5. Decides what to do next
6. Repeats until the task is done

Think of it as embedding Claude Code into your own applications.

```
Your Code ──> query(prompt, options) ──> Claude Agent Loop
                                              │
                                    ┌─────────┼─────────┐
                                    │         │         │
                                  Read     Bash      Edit    ... (tools)
                                    │         │         │
                                    └─────────┼─────────┘
                                              │
                                        Stream back messages
                                              │
                                    ◄── AssistantMessage (reasoning)
                                    ◄── ToolUseMessage (tool calls)
                                    ◄── ResultMessage (done!)
```

## How It Works Under the Hood

The SDK spawns a **Claude Code subprocess** and communicates via stdin/stdout. This means:

- The agent has access to the same powerful tools as Claude Code
- It runs in your local environment (can access your files, run commands, etc.)
- You control which tools are available and what permissions the agent has

## Setup

### Quick Setup (Python + TypeScript)
```bash
# Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install Python deps
pip install -r requirements.txt

# Install TypeScript deps (for TS examples)
npm install
```

### Or manually
```bash
# Python only
python3 -m venv .venv && source .venv/bin/activate
pip install claude-agent-sdk aiohttp

# TypeScript only
npm install @anthropic-ai/claude-agent-sdk
```

**Prerequisite**: You need Claude Code installed (`npm install -g @anthropic-ai/claude-code`) and authenticated.

## Key Concepts

### 1. The `query()` Function
The main entry point. It creates the agent loop and returns an async iterator of messages.

### 2. Tools
Built-in tools the agent can use:
- **Read** - Read files
- **Edit** - Edit files
- **Write** - Create files
- **Bash** - Run shell commands
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **WebSearch** - Search the web
- **WebFetch** - Fetch web pages
- **Agent** - Spawn sub-agents

### 3. Permission Modes
Control what the agent can do:
- `"default"` - Ask permission for everything
- `"acceptEdits"` - Auto-approve file edits
- `"bypassPermissions"` - Auto-approve everything (use carefully!)

### 4. MCP Servers
Add **custom tools** by defining MCP (Model Context Protocol) servers — give the agent domain-specific capabilities like calling your APIs, querying databases, etc.

## Examples

Each example is a standalone, runnable file. See the `examples/` directory:

| # | File | What It Does |
|---|------|-------------|
| 1 | `01_hello_agent.py` | Simplest possible agent - lists files |
| 2 | `02_code_reviewer.py` | Reviews code for bugs and best practices |
| 3 | `03_custom_tools.py` | Adds custom tools via MCP server |
| 4 | `04_multi_agent.py` | Orchestrates multiple specialized agents |
| 5 | `05_web_researcher.ts` | TypeScript agent that searches the web |

Run any example:
```bash
# Python
python examples/01_hello_agent.py

# TypeScript
npx tsx examples/05_web_researcher.ts
```

## Quick Reference

```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Your task here",
    options=ClaudeAgentOptions(
        allowed_tools=["Read", "Edit", "Bash"],  # Which tools to allow
        permission_mode="acceptEdits",             # Auto-approve edits
        system_prompt="You are a ...",             # Custom system prompt
        mcp_servers={...},                         # Custom tool servers
        max_turns=10,                              # Limit agent iterations
        model="sonnet",                            # Model to use
    ),
):
    # Handle streamed messages
    pass
```
