"""
Example 4: Multi-Agent Orchestration
=====================================
A lead agent that delegates to specialized sub-agents.

This demonstrates:
- Defining sub-agents with AgentDefinition
- The lead agent uses the "Task" tool to spawn sub-agents
- Each sub-agent has its own tools and system prompt
- Real-world pattern: research -> analyze -> report
"""

import asyncio
from claude_agent_sdk import (
    query,
    ClaudeAgentOptions,
    AgentDefinition,
    AssistantMessage,
    ResultMessage,
)


# --- Define specialized sub-agents ---

agents = {
    # Agent 1: Finds and reads relevant files
    "file-explorer": AgentDefinition(
        description=(
            "Use this agent to explore the codebase structure. "
            "It can find files, read contents, and search for patterns."
        ),
        tools=["Glob", "Read", "Grep"],
        prompt="You are a codebase explorer. Find and summarize relevant files.",
        model="haiku",  # Use a faster model for sub-agents
    ),
    # Agent 2: Analyzes code and writes findings
    "analyzer": AgentDefinition(
        description=(
            "Use AFTER the file-explorer to analyze code quality. "
            "Reads files and writes analysis reports."
        ),
        tools=["Read", "Write", "Glob"],
        prompt=(
            "You are a code analyst. Read the codebase and write a brief "
            "analysis covering: architecture, code quality, and suggestions."
        ),
        model="haiku",
    ),
}


async def main():
    print("Multi-agent system starting...\n")
    print("Lead agent will coordinate file-explorer and analyzer sub-agents.\n")

    async for message in query(
        prompt=(
            "Analyze this project's codebase. First use the file-explorer agent "
            "to understand the structure, then use the analyzer agent to write "
            "a brief analysis to 'analysis_report.md'."
        ),
        options=ClaudeAgentOptions(
            # Lead agent can only spawn sub-agents
            allowed_tools=["Task", "Read"],
            # Register our sub-agents
            agents=agents,
            # Auto-approve sub-agent actions
            permission_mode="acceptEdits",
            system_prompt=(
                "You are a lead agent coordinating a codebase analysis. "
                "Delegate tasks to your sub-agents. Do NOT do the work yourself."
            ),
        ),
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if hasattr(block, "text"):
                    print(block.text)
                elif hasattr(block, "name"):
                    print(f"  [Lead agent action: {block.name}]")

        elif isinstance(message, ResultMessage):
            print(f"\n--- All agents finished ({message.subtype}) ---")


asyncio.run(main())
