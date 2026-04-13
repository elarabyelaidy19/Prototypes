"""
Example 6: Autonomous Bug Fixer
================================
The classic use case — point the agent at a file and let it find and fix bugs.

This demonstrates:
- The full agent loop: read -> analyze -> edit -> verify
- permission_mode="acceptEdits" to auto-approve file changes
- A practical, real-world workflow
"""

import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, ResultMessage


async def fix_bugs(file_path: str):
    """Point the agent at a file and let it fix bugs autonomously."""

    async for message in query(
        prompt=(
            f"Review {file_path} for bugs that would cause crashes or incorrect behavior. "
            f"Fix any issues you find. After fixing, verify the changes are correct."
        ),
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Edit", "Glob", "Grep", "Bash"],
            permission_mode="acceptEdits",  # Auto-approve file edits
            max_turns=20,
        ),
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if hasattr(block, "text"):
                    print(block.text)
                elif hasattr(block, "name"):
                    print(f"  [{block.name}]")

        elif isinstance(message, ResultMessage):
            print(f"\n--- Bug fix complete ({message.subtype}) ---")


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python 06_bug_fixer.py <file_path>")
        print("Example: python 06_bug_fixer.py ../buggy_code.py")
        sys.exit(1)

    asyncio.run(fix_bugs(sys.argv[1]))
