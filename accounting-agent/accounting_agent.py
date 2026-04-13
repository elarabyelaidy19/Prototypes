"""
Personal Bookkeeping Agent
==========================
A simple accounting agent using Claude Agent SDK + SQLite.

Tools:
- add_account: Create accounts (asset, liability, equity, income, expense)
- record_transaction: Double-entry journal entries
- get_balances: Trial balance / account summaries
- list_transactions: Recent transaction history

Usage:
    python accounting_agent.py "I paid $50 for groceries from my bank account"
    python accounting_agent.py "Show me my balances"
    python accounting_agent.py  # interactive prompt
"""

import asyncio
import json
import sqlite3
import sys
from datetime import date
from pathlib import Path
from typing import Any

from claude_agent_sdk import (
    query,
    ClaudeAgentOptions,
    AssistantMessage,
    ResultMessage,
    TextBlock,
    ToolUseBlock,
    tool,
    create_sdk_mcp_server,
)

# --- Database setup ---

DB_PATH = Path(__file__).parent / "bookkeeping.db"

def get_db() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

def init_db():
    conn = get_db()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('asset', 'liability', 'equity', 'income', 'expense'))
        );

        CREATE TABLE IF NOT EXISTS journal_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            description TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS entry_lines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL REFERENCES journal_entries(id),
            account_id INTEGER NOT NULL REFERENCES accounts(id),
            debit REAL NOT NULL DEFAULT 0,
            credit REAL NOT NULL DEFAULT 0
        );
    """)
    conn.commit()
    conn.close()

def seed_default_accounts():
    """Seed common personal accounts if the DB is empty."""
    conn = get_db()
    count = conn.execute("SELECT COUNT(*) FROM accounts").fetchone()[0]
    if count == 0:
        defaults = [
            ("Bank", "asset"),
            ("Cash", "asset"),
            ("Credit Card", "liability"),
            ("Salary", "income"),
            ("Groceries", "expense"),
            ("Rent", "expense"),
            ("Utilities", "expense"),
            ("Transport", "expense"),
            ("Dining Out", "expense"),
            ("Entertainment", "expense"),
        ]
        conn.executemany("INSERT INTO accounts (name, type) VALUES (?, ?)", defaults)
        conn.commit()
    conn.close()


# --- Custom tools ---

@tool(
    "add_account",
    "Create a new account in the chart of accounts",
    {"name": str, "type": str},
)
async def add_account(args: dict[str, Any]) -> dict[str, Any]:
    name = args["name"]
    acct_type = args["type"].lower()
    valid_types = ("asset", "liability", "equity", "income", "expense")
    if acct_type not in valid_types:
        return _text(f"Invalid type '{acct_type}'. Must be one of: {', '.join(valid_types)}")

    conn = get_db()
    try:
        conn.execute("INSERT INTO accounts (name, type) VALUES (?, ?)", (name, acct_type))
        conn.commit()
        return _text(f"Account '{name}' ({acct_type}) created.")
    except sqlite3.IntegrityError:
        return _text(f"Account '{name}' already exists.")
    finally:
        conn.close()


@tool(
    "record_transaction",
    "Record a financial transaction. debit_account is debited and credit_account is credited. For spending: debit_account=expense (e.g. Groceries), credit_account=payment source (e.g. Bank). For income: debit_account=where money goes (e.g. Bank), credit_account=income source (e.g. Salary).",
    {
        "date": str,
        "description": str,
        "amount": float,
        "debit_account": str,
        "credit_account": str,
    },
)
async def record_transaction(args: dict[str, Any]) -> dict[str, Any]:
    conn = get_db()
    try:
        amount = args["amount"]
        if amount <= 0:
            return _text("Amount must be positive.")

        debit_acct = _find_account(conn, args["debit_account"])
        if not debit_acct:
            return _text(f"Account '{args['debit_account']}' not found.")
        credit_acct = _find_account(conn, args["credit_account"])
        if not credit_acct:
            return _text(f"Account '{args['credit_account']}' not found.")

        cur = conn.execute(
            "INSERT INTO journal_entries (date, description) VALUES (?, ?)",
            (args.get("date", date.today().isoformat()), args["description"]),
        )
        entry_id = cur.lastrowid
        conn.execute(
            "INSERT INTO entry_lines (entry_id, account_id, debit, credit) VALUES (?, ?, ?, 0)",
            (entry_id, debit_acct["id"], amount),
        )
        conn.execute(
            "INSERT INTO entry_lines (entry_id, account_id, debit, credit) VALUES (?, ?, 0, ?)",
            (entry_id, credit_acct["id"], amount),
        )
        conn.commit()
        return _text(f"Recorded: {args['description']} — ${amount:.2f} (DR {debit_acct['name']}, CR {credit_acct['name']})")
    finally:
        conn.close()


@tool(
    "get_balances",
    "Get current balances for all accounts, or filter by type",
    {"type": str},
)
async def get_balances(args: dict[str, Any]) -> dict[str, Any]:
    conn = get_db()
    try:
        type_filter = args.get("type", "").lower()
        sql = """
            SELECT a.name, a.type,
                   COALESCE(SUM(el.debit), 0) as total_debit,
                   COALESCE(SUM(el.credit), 0) as total_credit
            FROM accounts a
            LEFT JOIN entry_lines el ON a.id = el.account_id
        """
        params = []
        if type_filter and type_filter != "all":
            sql += " WHERE a.type = ?"
            params.append(type_filter)
        sql += " GROUP BY a.id ORDER BY a.type, a.name"

        rows = conn.execute(sql, params).fetchall()
        if not rows:
            return _text("No accounts found.")

        results = []
        for r in rows:
            # Normal balance: assets/expenses are debit-normal, others credit-normal
            if r["type"] in ("asset", "expense"):
                balance = r["total_debit"] - r["total_credit"]
            else:
                balance = r["total_credit"] - r["total_debit"]
            results.append(f"{r['name']} ({r['type']}): ${balance:.2f}")

        return _text("\n".join(results))
    finally:
        conn.close()


@tool(
    "list_transactions",
    "List recent journal entries, optionally filtered by account name",
    {"account": str, "limit": int},
)
async def list_transactions(args: dict[str, Any]) -> dict[str, Any]:
    conn = get_db()
    try:
        limit = args.get("limit", 20)
        account = args.get("account", "")

        if account:
            sql = """
                SELECT je.date, je.description,
                       el.debit, el.credit, a.name as account_name
                FROM journal_entries je
                JOIN entry_lines el ON je.id = el.entry_id
                JOIN accounts a ON el.account_id = a.id
                WHERE a.name LIKE ?
                ORDER BY je.date DESC, je.id DESC
                LIMIT ?
            """
            rows = conn.execute(sql, (f"%{account}%", limit)).fetchall()
        else:
            sql = """
                SELECT je.date, je.description,
                       GROUP_CONCAT(a.name || ':' ||
                           CASE WHEN el.debit > 0 THEN 'DR $' || printf('%.2f', el.debit)
                                ELSE 'CR $' || printf('%.2f', el.credit) END, ' | ') as details
                FROM journal_entries je
                JOIN entry_lines el ON je.id = el.entry_id
                JOIN accounts a ON el.account_id = a.id
                GROUP BY je.id
                ORDER BY je.date DESC, je.id DESC
                LIMIT ?
            """
            rows = conn.execute(sql, (limit,)).fetchall()

        if not rows:
            return _text("No transactions found.")

        results = []
        for r in rows:
            if account:
                dr_cr = f"DR ${r['debit']:.2f}" if r["debit"] > 0 else f"CR ${r['credit']:.2f}"
                results.append(f"{r['date']} | {r['description']} | {dr_cr}")
            else:
                results.append(f"{r['date']} | {r['description']} | {r['details']}")

        return _text("\n".join(results))
    finally:
        conn.close()


# --- Helpers ---

def _text(text: str) -> dict[str, Any]:
    return {"content": [{"type": "text", "text": text}]}

def _find_account(conn: sqlite3.Connection, name: str) -> sqlite3.Row | None:
    return conn.execute(
        "SELECT * FROM accounts WHERE name LIKE ? LIMIT 1", (f"%{name}%",)
    ).fetchone()


# --- MCP server ---

bookkeeping_server = create_sdk_mcp_server(
    name="bookkeeping",
    version="1.0.0",
    tools=[add_account, record_transaction, get_balances, list_transactions],
)

SYSTEM_PROMPT = """You are a personal bookkeeping assistant. You record and track financial transactions using double-entry bookkeeping.

IMPORTANT: Always act immediately on the user's request. If the user says they paid/spent/received money, record the transaction right away using the information provided. NEVER ask clarifying questions if the amount, account, and category can be reasonably inferred from the message.

Rules:
- Every transaction must have equal debits and credits (double-entry)
- Account types and their normal balances:
  - Asset (debit-normal): things you own (Bank, Cash)
  - Liability (credit-normal): things you owe (Credit Card, Loans)
  - Equity (credit-normal): net worth
  - Income (credit-normal): money earned (Salary, Freelance)
  - Expense (debit-normal): money spent (Groceries, Rent)
- When recording spending: debit the expense, credit the payment source
  Example: "Paid $50 for groceries from bank" → Debit Groceries $50, Credit Bank $50
- When recording income: debit the receiving account, credit income
  Example: "Got $3000 salary to bank" → Debit Bank $3000, Credit Salary $3000
- Use today's date if not specified
- If no payment source is mentioned, default to "Bank"
- Use get_balances with type "all" to show everything
- Be conversational and brief. Don't over-explain accounting unless asked.
"""


async def main():
    init_db()
    seed_default_accounts()

    # Get prompt from args or ask
    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
    else:
        prompt = input("What would you like to do? > ")

    print()

    async for message in query(
        prompt=prompt,
        options=ClaudeAgentOptions(
            system_prompt=SYSTEM_PROMPT,
            mcp_servers={"bookkeeping": bookkeeping_server},
            allowed_tools=[
                "mcp__bookkeeping__add_account",
                "mcp__bookkeeping__record_transaction",
                "mcp__bookkeeping__get_balances",
                "mcp__bookkeeping__list_transactions",
            ],
            permission_mode="bypassPermissions",
            max_turns=10,
        ),
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(block.text)
                elif isinstance(block, ToolUseBlock):
                    print(f"  [{block.name}]")

        elif isinstance(message, ResultMessage):
            print(f"\n(cost: ${message.total_cost_usd:.4f})")


asyncio.run(main())
