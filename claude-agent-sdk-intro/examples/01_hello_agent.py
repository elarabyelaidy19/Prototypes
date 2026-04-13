"""
Example 1: Hello Agent
======================
The simplest possible agent — ask Claude to list files in the current directory.

This demonstrates:
- The query() function (main entry point)
- Streaming messages from the agent loop
- Using built-in tools (Glob)
"""

import asyncio
import os
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, ResultMessage


async def main():
    cwd = os.getcwd()
    print(f"Agent starting... asking Claude to list files in {cwd}\n")

    async for message in query(
        prompt=f"List all files in {cwd} and give me a brief summary of what this project contains.",
        options=ClaudeAgentOptions(
            allowed_tools=["Bash", "Glob", "Read"],  # Allow Bash as fallback
        ),
    ):
        # AssistantMessage = Claude's thinking/reasoning text
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if hasattr(block, "text"):
                    print(block.text)
                elif hasattr(block, "name"):
                    print(f"  [Using tool: {block.name}]")

        # ResultMessage = agent is done
        elif isinstance(message, ResultMessage):
            print(f"\n--- Agent finished ({message.subtype}) ---")


asyncio.run(main())
