"""
Example 3: Custom Tools via MCP Server
=======================================
Give the agent your own tools — here we create a weather lookup tool.

This demonstrates:
- Defining custom tools with @tool decorator
- Creating an MCP server (in-process, no external server needed)
- Combining custom tools with built-in tools
- Tool name format: mcp__{server_name}__{tool_name}
"""

import asyncio
import aiohttp
from claude_agent_sdk import (
    query,
    ClaudeAgentOptions,
    AssistantMessage,
    ResultMessage,
    tool,
    create_sdk_mcp_server,
)
from typing import Any


# --- Define custom tools ---


@tool(
    "get_weather",
    "Get current temperature for a city using coordinates",
    {"latitude": float, "longitude": float},
)
async def get_weather(args: dict[str, Any]) -> dict[str, Any]:
    """Fetches real weather data from Open-Meteo (free, no API key needed)."""
    async with aiohttp.ClientSession() as session:
        url = (
            f"https://api.open-meteo.com/v1/forecast"
            f"?latitude={args['latitude']}"
            f"&longitude={args['longitude']}"
            f"&current=temperature_2m,wind_speed_10m"
            f"&temperature_unit=celsius"
        )
        async with session.get(url) as response:
            data = await response.json()

    current = data["current"]
    return {
        "content": [
            {
                "type": "text",
                "text": (
                    f"Temperature: {current['temperature_2m']}C, "
                    f"Wind: {current['wind_speed_10m']} km/h"
                ),
            }
        ]
    }


@tool(
    "get_coordinates",
    "Look up latitude/longitude for a city name",
    {"city": str},
)
async def get_coordinates(args: dict[str, Any]) -> dict[str, Any]:
    """Uses Open-Meteo's geocoding API to find city coordinates."""
    async with aiohttp.ClientSession() as session:
        url = f"https://geocoding-api.open-meteo.com/v1/search?name={args['city']}&count=1"
        async with session.get(url) as response:
            data = await response.json()

    if not data.get("results"):
        return {"content": [{"type": "text", "text": f"City '{args['city']}' not found."}]}

    result = data["results"][0]
    return {
        "content": [
            {
                "type": "text",
                "text": (
                    f"{result['name']}, {result.get('country', 'Unknown')}: "
                    f"lat={result['latitude']}, lon={result['longitude']}"
                ),
            }
        ]
    }


# --- Create MCP server from our tools ---

weather_server = create_sdk_mcp_server(
    name="weather",
    version="1.0.0",
    tools=[get_weather, get_coordinates],
)


async def main():
    print("Agent starting... asking about weather.\n")

    async for message in query(
        prompt="What's the weather like in Tokyo and Cairo right now? Compare them.",
        options=ClaudeAgentOptions(
            # Register our custom MCP server
            mcp_servers={"weather": weather_server},
            # Allow our custom tools (format: mcp__{server}__{tool})
            allowed_tools=[
                "mcp__weather__get_weather",
                "mcp__weather__get_coordinates",
            ],
            max_turns=10,
        ),
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if hasattr(block, "text"):
                    print(block.text)
                elif hasattr(block, "name"):
                    print(f"  [Calling: {block.name}]")

        elif isinstance(message, ResultMessage):
            print(f"\n--- Done ({message.subtype}) ---")


asyncio.run(main())
