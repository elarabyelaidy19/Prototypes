"""
Example 2: Code Reviewer Agent
===============================
An agent that reviews code for bugs, security issues, and best practices.

This demonstrates:
- Using multiple tools together (Read, Glob, Grep)
- Custom system prompts to shape agent behavior
- A read-only agent (no edit/write permissions)
"""

import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, ResultMessage


async def review_code(target_path: str):
    """Review code at the given path for issues."""

    async for message in query(
        prompt=f"Review the code in {target_path} for bugs, security issues, and best practices. Be concise.",
        options=ClaudeAgentOptions(
            # Read-only tools — agent can analyze but NOT modify code
            allowed_tools=["Read", "Glob", "Grep"],
            # Shape the agent's behavior
            system_prompt=(
                "You are a senior code reviewer. Focus on:\n"
                "1. Bugs that would cause crashes or incorrect behavior\n"
                "2. Security vulnerabilities (injection, auth issues, etc.)\n"
                "3. Performance problems\n"
                "Keep feedback actionable and concise."
            ),
        ),
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if hasattr(block, "text"):
                    print(block.text)
                elif hasattr(block, "name"):
                    print(f"  [Reviewing with: {block.name}]")

        elif isinstance(message, ResultMessage):
            print(f"\n--- Review complete ({message.subtype}) ---")


if __name__ == "__main__":
    import sys

    path = sys.argv[1] if len(sys.argv) > 1 else "."
    print(f"Reviewing code at: {path}\n")
    asyncio.run(review_code(path))
