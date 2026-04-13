/**
 * Example 5: Web Researcher (TypeScript)
 * =======================================
 * An agent that searches the web and summarizes findings.
 *
 * This demonstrates:
 * - TypeScript SDK usage
 * - WebSearch and WebFetch tools
 * - Writing results to a file
 *
 * Run: npx tsx examples/05_web_researcher.ts "your topic here"
 */

import { query } from "@anthropic-ai/claude-agent-sdk";

const topic = process.argv[2] || "latest developments in AI agents 2025";

console.log(`Researching: "${topic}"\n`);

for await (const message of query({
  prompt: `Research "${topic}" by searching the web. Find 3-5 key points and write a brief summary to "research_output.md". Keep it concise and factual.`,
  options: {
    allowedTools: ["WebSearch", "WebFetch", "Write", "Read"],
    permissionMode: "acceptEdits",
    systemPrompt:
      "You are a research assistant. Search the web, verify facts across sources, and write clear summaries. Cite your sources.",
    maxTurns: 15,
  },
})) {
  if (message.type === "assistant" && message.message?.content) {
    for (const block of message.message.content) {
      if ("text" in block) {
        console.log(block.text);
      } else if ("name" in block) {
        console.log(`  [Tool: ${block.name}]`);
      }
    }
  } else if (message.type === "result") {
    console.log(`\n--- Research complete (${message.subtype}) ---`);
  }
}
