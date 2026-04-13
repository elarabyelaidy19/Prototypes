# Learn Claude Code -- Complete Reference

> **Description:** All 37 English-language documents from the Learn Claude Code teaching repository, combined into a single file in curriculum order.
>
> **Source:** [github.com/shareAI-lab/learn-claude-code](https://github.com/shareAI-lab/learn-claude-code)

## Table of Contents

### Frontmatter & Overview

- [Learn Claude Code](#learn-claude-code)
- [s00: Architecture Overview](#s00-architecture-overview)
- [s00d: Chapter Order Rationale](#s00d-chapter-order-rationale)
- [s00f: Code Reading Order](#s00f-code-reading-order)
- [Teaching Scope](#teaching-scope)

### Reference Material

- [Glossary](#glossary)
- [Core Data Structures](#core-data-structures)
- [Entity Map](#entity-map)
- [s00e: Reference Module Map](#s00e-reference-module-map)

### Phase 1: Core Loop (s01-s06)

- [s00a: Query Control Plane](#s00a-query-control-plane) *(Bridge Document)*
- [s00b: One Request Lifecycle](#s00b-one-request-lifecycle) *(Bridge Document)*
- [s00c: Query Transition Model](#s00c-query-transition-model) *(Bridge Document)*
- [s01: The Agent Loop](#s01-the-agent-loop)
- [s02: Tool Use](#s02-tool-use)
- [s02a: Tool Control Plane](#s02a-tool-control-plane) *(Bridge Document)*
- [s02b: Tool Execution Runtime](#s02b-tool-execution-runtime) *(Bridge Document)*
- [s03: TodoWrite](#s03-todowrite)
- [s04: Subagents](#s04-subagents)
- [s05: Skills](#s05-skills)
- [s06: Context Compact](#s06-context-compact)

### Phase 2: System Hardening (s07-s11)

- [s07: Permission System](#s07-permission-system)
- [s08: Hook System](#s08-hook-system)
- [s09: Memory System](#s09-memory-system)
- [s10: System Prompt](#s10-system-prompt)
- [s10a: Message & Prompt Pipeline](#s10a-message-prompt-pipeline) *(Bridge Document)*
- [s11: Error Recovery](#s11-error-recovery)

### Phase 3: Task Runtime (s12-s14)

- [s12: Task System](#s12-task-system)
- [s13: Background Tasks](#s13-background-tasks)
- [s13a: Runtime Task Model](#s13a-runtime-task-model) *(Bridge Document)*
- [s14: Cron Scheduler](#s14-cron-scheduler)
- [Team Task Lane Model](#team-task-lane-model) *(Bridge Document)*

### Phase 4: Multi-Agent Platform (s15-s19)

- [s15: Agent Teams](#s15-agent-teams)
- [s16: Team Protocols](#s16-team-protocols)
- [s17: Autonomous Agents](#s17-autonomous-agents)
- [s18: Worktree + Task Isolation](#s18-worktree-task-isolation)
- [s19: MCP & Plugin](#s19-mcp-plugin)
- [s19a: MCP Capability Layers](#s19a-mcp-capability-layers) *(Bridge Document)*

[English](./README.md) | [中文](./README-zh.md) | [日本語](./README-ja.md)

# Learn Claude Code

A teaching repository for implementers who want to build a high-completion coding-agent harness from scratch.

This repo does not try to mirror every product detail from a production codebase. It focuses on the mechanisms that actually decide whether an agent can work well:

- the loop
- tools
- planning
- delegation
- context control
- permissions
- hooks
- memory
- prompt assembly
- tasks
- teams
- isolated execution lanes
- external capability routing

The goal is simple:

**understand the real design backbone well enough that you can rebuild it yourself.**

## What This Repo Is Really Teaching

One sentence first:

**The model does the reasoning. The harness gives the model a working environment.**

That working environment is made of a few cooperating parts:

- `Agent Loop`: ask the model, run tools, append results, continue
- `Tools`: the agent's hands
- `Planning`: a small structure that keeps multi-step work from drifting
- `Context Management`: keep the active context small and coherent
- `Permissions`: do not let model intent turn into unsafe execution directly
- `Hooks`: extend behavior around the loop without rewriting the loop
- `Memory`: keep only durable facts that should survive sessions
- `Prompt Construction`: assemble the model input from stable rules and runtime state
- `Tasks / Teams / Worktree / MCP`: grow the single-agent core into a larger working platform

This is the teaching promise of the repo:

- teach the mainline in a clean order
- explain unfamiliar concepts before relying on them
- stay close to real system structure
- avoid drowning the learner in irrelevant product details

## What This Repo Deliberately Does Not Teach

This repo is not trying to preserve every detail that may exist in a real production system.

If a detail is not central to the agent's core operating model, it should not dominate the teaching line. That includes things like:

- packaging and release mechanics
- cross-platform compatibility layers
- enterprise policy glue
- telemetry and account wiring
- historical compatibility branches
- product-specific naming accidents

Those details may matter in production. They do not belong at the center of a 0-to-1 teaching path.

## Who This Is For

The assumed reader:

- knows basic Python
- understands functions, classes, lists, and dictionaries
- may be completely new to agent systems

So the repo tries to keep a few strong teaching rules:

- explain a concept before using it
- keep one concept fully explained in one main place
- start from "what it is", then "why it exists", then "how to implement it"
- avoid forcing beginners to assemble the system from scattered fragments

## Recommended Reading Order

The English docs are intended to stand on their own. The chapter order, bridge docs, and mechanism map are aligned across locales, so you can stay inside one language while following the main learning path.

- Overview: [`docs/en/s00-architecture-overview.md`](./docs/en/s00-architecture-overview.md)
- Code Reading Order: [`docs/en/s00f-code-reading-order.md`](./docs/en/s00f-code-reading-order.md)
- Glossary: [`docs/en/glossary.md`](./docs/en/glossary.md)
- Teaching Scope: [`docs/en/teaching-scope.md`](./docs/en/teaching-scope.md)
- Data Structures: [`docs/en/data-structures.md`](./docs/en/data-structures.md)

## If This Is Your First Visit, Start Here

Do not open random chapters first.

The safest path is:

1. Read [`docs/en/s00-architecture-overview.md`](./docs/en/s00-architecture-overview.md) for the full system map.
2. Read [`docs/en/s00d-chapter-order-rationale.md`](./docs/en/s00d-chapter-order-rationale.md) so the chapter order makes sense before you dive into mechanism detail.
3. Read [`docs/en/s00f-code-reading-order.md`](./docs/en/s00f-code-reading-order.md) so you know which local files to open first.
4. Follow the four stages in order: `s01-s06 -> s07-s11 -> s12-s14 -> s15-s19`.
5. After each stage, stop and rebuild the smallest version yourself before continuing.

If the middle and late chapters start to blur together, reset in this order:

1. [`docs/en/data-structures.md`](./docs/en/data-structures.md)
2. [`docs/en/entity-map.md`](./docs/en/entity-map.md)
3. the bridge docs closest to the chapter you are stuck on
4. then return to the chapter body

## Web Learning Interface

If you want a more visual way to understand the chapter order, stage boundaries, and chapter-to-chapter upgrades, run the built-in teaching site:

```sh
cd web
npm install
npm run dev
```

Then use these routes:

- `/en`: the English entry page for choosing a reading path
- `/en/timeline`: the cleanest view of the full mainline
- `/en/layers`: the four-stage boundary map
- `/en/compare`: adjacent-step comparison and jump diagnosis

For a first pass, start with `timeline`.  
If you are already in the middle and chapter boundaries are getting fuzzy, use `layers` and `compare` before you go deeper into source code.

### Bridge Docs

These are not extra main chapters. They are bridge documents that make the middle and late system easier to understand:

- Chapter order rationale: [`docs/en/s00d-chapter-order-rationale.md`](./docs/en/s00d-chapter-order-rationale.md)
- Code reading order: [`docs/en/s00f-code-reading-order.md`](./docs/en/s00f-code-reading-order.md)
- Reference module map: [`docs/en/s00e-reference-module-map.md`](./docs/en/s00e-reference-module-map.md)
- Query control plane: [`docs/en/s00a-query-control-plane.md`](./docs/en/s00a-query-control-plane.md)
- One request lifecycle: [`docs/en/s00b-one-request-lifecycle.md`](./docs/en/s00b-one-request-lifecycle.md)
- Query transition model: [`docs/en/s00c-query-transition-model.md`](./docs/en/s00c-query-transition-model.md)
- Tool control plane: [`docs/en/s02a-tool-control-plane.md`](./docs/en/s02a-tool-control-plane.md)
- Tool execution runtime: [`docs/en/s02b-tool-execution-runtime.md`](./docs/en/s02b-tool-execution-runtime.md)
- Message and prompt pipeline: [`docs/en/s10a-message-prompt-pipeline.md`](./docs/en/s10a-message-prompt-pipeline.md)
- Runtime task model: [`docs/en/s13a-runtime-task-model.md`](./docs/en/s13a-runtime-task-model.md)
- MCP capability layers: [`docs/en/s19a-mcp-capability-layers.md`](./docs/en/s19a-mcp-capability-layers.md)
- Team-task-lane model: [`docs/en/team-task-lane-model.md`](./docs/en/team-task-lane-model.md)
- Entity map: [`docs/en/entity-map.md`](./docs/en/entity-map.md)

### Four Stages

1. `s01-s06`: build a useful single-agent core
2. `s07-s11`: add safety, extension points, memory, prompt assembly, and recovery
3. `s12-s14`: turn temporary session planning into durable runtime work
4. `s15-s19`: move into teams, protocols, autonomy, isolated execution, and external capability routing

### Main Chapters

| Chapter | Topic | What you get |
|---|---|---|
| `s00` | Architecture Overview | the global map, key terms, and learning order |
| `s01` | Agent Loop | the smallest working agent loop |
| `s02` | Tool Use | a stable tool dispatch layer |
| `s03` | Todo / Planning | a visible session plan |
| `s04` | Subagent | fresh context per delegated subtask |
| `s05` | Skills | load specialized knowledge only when needed |
| `s06` | Context Compact | keep the active window small |
| `s07` | Permission System | a safety gate before execution |
| `s08` | Hook System | extension points around the loop |
| `s09` | Memory System | durable cross-session knowledge |
| `s10` | System Prompt | section-based prompt assembly |
| `s11` | Error Recovery | continuation and retry branches |
| `s12` | Task System | persistent task graph |
| `s13` | Background Tasks | non-blocking execution |
| `s14` | Cron Scheduler | time-based triggers |
| `s15` | Agent Teams | persistent teammates |
| `s16` | Team Protocols | shared coordination rules |
| `s17` | Autonomous Agents | self-claiming and self-resume |
| `s18` | Worktree Isolation | isolated execution lanes |
| `s19` | MCP & Plugin | external capability routing |

## Quick Start

```sh
git clone https://github.com/shareAI-lab/learn-claude-code
cd learn-claude-code
pip install -r requirements.txt
cp .env.example .env
```

Then configure `ANTHROPIC_API_KEY` or a compatible endpoint in `.env`, and run:

```sh
python agents/s01_agent_loop.py
python agents/s18_worktree_task_isolation.py
python agents/s19_mcp_plugin.py
python agents/s_full.py
```

Suggested order:

1. Run `s01` and make sure the minimal loop really works.
2. Read `s00`, then move through `s01 -> s11` in order.
3. Only after the single-agent core plus its control plane feel stable, continue into `s12 -> s19`.
4. Read `s_full.py` last, after the mechanisms already make sense separately.

## How To Read Each Chapter

Each chapter is easier to absorb if you keep the same reading rhythm:

1. what problem appears without this mechanism
2. what the new concept means
3. what the smallest correct implementation looks like
4. where the state actually lives
5. how it plugs back into the loop
6. where to stop first, and what can wait until later

If you keep asking:

- "Is this core mainline or just a side detail?"
- "Where does this state actually live?"

go back to:

- [`docs/en/teaching-scope.md`](./docs/en/teaching-scope.md)
- [`docs/en/data-structures.md`](./docs/en/data-structures.md)
- [`docs/en/entity-map.md`](./docs/en/entity-map.md)

## Repository Structure

```text
learn-claude-code/
├── agents/              # runnable Python reference implementations per chapter
├── docs/zh/             # Chinese mainline docs
├── docs/en/             # English docs
├── docs/ja/             # Japanese docs
├── skills/              # skill files used in s05
├── web/                 # web teaching platform
└── requirements.txt
```

## Language Status

Chinese is still the canonical teaching line and the fastest-moving version.

- `zh`: most reviewed and most complete
- `en`: main chapters plus the major bridge docs are available
- `ja`: main chapters plus the major bridge docs are available

If you want the fullest and most frequently refined explanation path, use the Chinese docs first.

## End Goal

By the end of the repo, you should be able to answer these questions clearly:

- what is the minimum state a coding agent needs?
- why is `tool_result` the center of the loop?
- when should you use a subagent instead of stuffing more into one context?
- what problem do permissions, hooks, memory, prompt assembly, and tasks each solve?
- when should a single-agent system grow into tasks, teams, worktrees, and MCP?

If you can answer those questions clearly and build a similar system yourself, this repo has done its job.


---

# s00: Architecture Overview

Welcome to the map. Before diving into building piece by piece, it helps to see the whole picture from above. This document shows you what the full system contains, why the chapters are ordered this way, and what you will actually learn.

## The Big Picture

The mainline of this repo is reasonable because it grows the system in four dependency-driven stages:

1. build a real single-agent loop
2. harden that loop with safety, memory, and recovery
3. turn temporary session work into durable runtime work
4. grow the single executor into a multi-agent platform with isolated lanes and external capability routing

This order follows **mechanism dependencies**, not file order and not product glamour.

If the learner does not already understand:

`user input -> model -> tools -> write-back -> next turn`

then permissions, hooks, memory, tasks, teams, worktrees, and MCP all become disconnected vocabulary.

## What This Repo Is Trying To Reconstruct

This repository is not trying to mirror a production codebase line by line.

It is trying to reconstruct the parts that determine whether an agent system actually works:

- what the main modules are
- how those modules cooperate
- what each module is responsible for
- where the important state lives
- how one request flows through the system

That means the goal is:

**high fidelity to the design backbone, not 1:1 fidelity to every outer implementation detail.**

## Three Tips Before You Start

### Tip 1: Learn the smallest correct version first

For example, a subagent does not need every advanced capability on day one.

The smallest correct version already teaches the core lesson:

- the parent defines the subtask
- the child gets a separate `messages[]`
- the child returns a summary

Only after that is stable should you add:

- inherited context
- separate permissions
- background runtime
- worktree isolation

### Tip 2: New terms should be explained before they are used

This repo uses terms such as:

- state machine
- dispatch map
- dependency graph
- worktree
- protocol envelope
- MCP

If a term is unfamiliar, pause and check the reference docs rather than pushing forward blindly.

Recommended companions:

- [`glossary.md`](./glossary.md)
- [`entity-map.md`](./entity-map.md)
- [`data-structures.md`](./data-structures.md)
- [`teaching-scope.md`](./teaching-scope.md)

### Tip 3: Do not let peripheral complexity pretend to be core mechanism

Good teaching does not try to include everything.

It explains the important parts completely and keeps low-value complexity out of your way:

- packaging and release flow
- enterprise integration glue
- telemetry
- product-specific compatibility branches
- file-name / line-number reverse-engineering trivia

## Bridge Docs That Matter

Treat these as cross-chapter maps:

| Doc | What It Clarifies |
|---|---|
| [`s00d-chapter-order-rationale.md`](./s00d-chapter-order-rationale.md) (Deep Dive) | why the curriculum order is what it is |
| [`s00e-reference-module-map.md`](./s00e-reference-module-map.md) (Deep Dive) | how the reference repo's real module clusters map onto the current curriculum |
| [`s00a-query-control-plane.md`](./s00a-query-control-plane.md) (Deep Dive) | why a high-completion agent needs more than `messages[] + while True` |
| [`s00b-one-request-lifecycle.md`](./s00b-one-request-lifecycle.md) (Deep Dive) | how one request moves through the full system |
| [`s02a-tool-control-plane.md`](./s02a-tool-control-plane.md) (Deep Dive) | why tools become a control plane, not just a function table |
| [`s10a-message-prompt-pipeline.md`](./s10a-message-prompt-pipeline.md) (Deep Dive) | why system prompt is only one input surface |
| [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) (Deep Dive) | why durable tasks and live runtime slots must split |
| [`s19a-mcp-capability-layers.md`](./s19a-mcp-capability-layers.md) (Deep Dive) | why MCP is more than a remote tool list |

## The Four Learning Stages

### Stage 1: Core Single-Agent (`s01-s06`)

Goal: build a single agent that can actually do work.

| Chapter | New Layer |
|---|---|
| `s01` | loop and write-back |
| `s02` | tools and dispatch |
| `s03` | session planning |
| `s04` | delegated subtask isolation |
| `s05` | skill discovery and loading |
| `s06` | context compaction |

### Stage 2: Hardening (`s07-s11`)

Goal: make the loop safer, more stable, and easier to extend.

| Chapter | New Layer |
|---|---|
| `s07` | permission gate |
| `s08` | hooks and side effects |
| `s09` | durable memory |
| `s10` | prompt assembly |
| `s11` | recovery and continuation |

### Stage 3: Runtime Work (`s12-s14`)

Goal: upgrade session work into durable, background, and scheduled runtime work.

| Chapter | New Layer |
|---|---|
| `s12` | persistent task graph |
| `s13` | runtime execution slots |
| `s14` | time-based triggers |

### Stage 4: Platform (`s15-s19`)

Goal: grow from one executor into a larger platform.

| Chapter | New Layer |
|---|---|
| `s15` | persistent teammates |
| `s16` | structured team protocols |
| `s17` | autonomous claiming and resuming |
| `s18` | isolated execution lanes |
| `s19` | external capability routing |

## Quick Reference: What Each Chapter Adds

| Chapter | Core Structure | What You Should Be Able To Build |
|---|---|---|
| `s01` | `LoopState`, `tool_result` write-back | a minimal working agent loop |
| `s02` | `ToolSpec`, dispatch map | stable tool routing |
| `s03` | `TodoItem`, `PlanState` | visible session planning |
| `s04` | isolated child context | delegated subtasks without polluting the parent |
| `s05` | `SkillRegistry` | cheap discovery and deep on-demand loading |
| `s06` | compaction records | long sessions that stay usable |
| `s07` | permission decisions | execution behind a gate |
| `s08` | lifecycle events | extension without rewriting the loop |
| `s09` | memory records | selective long-term memory |
| `s10` | prompt parts | staged input assembly |
| `s11` | continuation reasons | recovery branches that stay legible |
| `s12` | `TaskRecord` | durable work graphs |
| `s13` | `RuntimeTaskState` | background execution with later write-back |
| `s14` | `ScheduleRecord` | time-triggered work |
| `s15` | `TeamMember`, inboxes | persistent teammates |
| `s16` | protocol envelopes | structured request / response coordination |
| `s17` | claim policy | self-claim and self-resume |
| `s18` | `WorktreeRecord` | isolated execution lanes |
| `s19` | capability routing | unified native + plugin + MCP routing |

## Key Takeaway

**A good chapter order is not a list of features. It is a path where each mechanism grows naturally out of the last one.**


---

# s00d: Chapter Order Rationale

> **Deep Dive** -- Read this after completing Stage 1 (s01-s06) or whenever you wonder "why is the course ordered this way?"

This note is not about one mechanism. It answers a more basic teaching question: why does this curriculum teach the system in the current order instead of following source-file order, feature hype, or raw implementation complexity?

## Conclusion First

The current `s01 -> s19` order is structurally sound.

Its strength is not just breadth. Its strength is that it grows the system in the same order you should understand it:

1. Build the smallest working agent loop.
2. Add the control-plane and hardening layers around that loop.
3. Upgrade session planning into durable work and runtime state.
4. Only then expand into persistent teams, isolated execution lanes, and external capability buses.

That is the right teaching order because it follows:

**dependency order between mechanisms**

not file order or product packaging order.

## The Four Dependency Lines

This curriculum is really organized by four dependency lines:

1. `core loop dependency`
2. `control-plane dependency`
3. `work-state dependency`
4. `platform-boundary dependency`

In plain English:

```text
first make the agent run
  -> then make it run safely
  -> then make it run durably
  -> then make it run as a platform
```

## The Real Shape of the Sequence

```text
s01-s06
  build one working single-agent system

s07-s11
  harden and control that system

s12-s14
  turn temporary planning into durable work + runtime

s15-s19
  expand into teammates, protocols, autonomy, isolated lanes, and external capability
```

After each stage, you should be able to say:

- after `s06`: "I can build one real single-agent harness"
- after `s11`: "I can make that harness safer, steadier, and easier to extend"
- after `s14`: "I can manage durable work, background execution, and time-triggered starts"
- after `s19`: "I understand the platform boundary of a high-completion agent system"

## Why The Early Chapters Must Stay In Their Current Order

### `s01` must stay first

Because it establishes:

- the minimal entry point
- the turn-by-turn loop
- why tool results must flow back into the next model call

Without this, everything later becomes disconnected feature talk.

### `s02` must immediately follow `s01`

Because an agent that cannot route intent into tools is still only talking, not acting.

`s02` is where learners first see the harness become real:

- model emits `tool_use`
- the system dispatches to a handler
- the tool executes
- `tool_result` flows back into the loop

### `s03` should stay before `s04`

This is an important guardrail.

You should first understand:

- how the current agent organizes its own work

before learning:

- when to delegate work into a separate sub-context

If `s04` comes too early, subagents become an escape hatch instead of a clear isolation mechanism.

### `s05` should stay before `s06`

These two chapters solve two halves of the same problem:

- `s05`: prevent unnecessary knowledge from entering the context
- `s06`: manage the context that still must remain active

That order matters. A good system first avoids bloat, then compacts what is still necessary.

## Why `s07-s11` Form One Hardening Block

These chapters all answer the same larger question:

**the loop already works, so how does it become stable, safe, and legible as a real system?**

### `s07` should stay before `s08`

Permission comes first because the system must first answer:

- may this action happen at all
- should it be denied
- should it ask the user first

Only after that should you teach hooks, which answer:

- what extra behavior attaches around the loop

So the correct teaching order is:

**gate first, extend second**

### `s09` should stay before `s10`

This is another very important ordering decision.

`s09` teaches:

- what durable information exists
- which facts deserve long-term storage

`s10` teaches:

- how multiple information sources are assembled into model input

That means:

- memory defines one content source
- prompt assembly explains how all content sources are combined

If you reverse them, prompt construction starts to feel arbitrary and mysterious.

### `s11` is the right closing chapter for this block

Error recovery is not an isolated feature.

It is where the system finally needs to explain:

- why it is continuing
- why it is retrying
- why it is stopping

That only becomes legible after the input path, tool path, state path, and control path already exist.

## Why `s12-s14` Must Stay Goal -> Runtime -> Schedule

This is the easiest part of the curriculum to teach badly if the order is wrong.

### `s12` must stay before `s13`

`s12` teaches:

- what work exists
- dependency relations between work nodes
- when downstream work unlocks

`s13` teaches:

- what live execution is currently running
- where background results go
- how runtime state writes back

That is the crucial distinction:

- `task` is the durable work goal
- `runtime task` is the live execution slot

If `s13` comes first, you will almost certainly collapse those two into one concept.

### `s14` must stay after `s13`

Cron does not add another kind of task.

It adds a new start condition:

**time becomes one more way to launch work into the runtime**

So the right order is:

`durable task graph -> runtime slot -> schedule trigger`

## Why `s15-s19` Should Stay Team -> Protocol -> Autonomy -> Worktree -> Capability Bus

### `s15` defines who persists in the system

Before protocols or autonomy make sense, the system needs durable actors:

- who teammates are
- what identity they carry
- how they persist across work

### `s16` then defines how those actors coordinate

Protocols should not come before actors.

Protocols exist to structure:

- who requests
- who approves
- who responds
- how requests remain traceable

### `s17` only makes sense after both

Autonomy is easy to teach vaguely.

But in a real system it only becomes clear after:

- persistent teammates exist
- structured coordination already exists

Otherwise "autonomous claiming" sounds like magic instead of the bounded mechanism it really is.

### `s18` should stay before `s19`

Worktree isolation is a local execution-boundary problem:

- where parallel work actually runs
- how one work lane stays isolated from another

That should become clear before moving outward into:

- plugins
- MCP servers
- external capability routing

Otherwise you risk over-focusing on external capability and under-learning the local platform boundary.

### `s19` is correctly last

It is the outer platform boundary.

It only becomes clean once you already understand:

- local actors
- local work lanes
- local durable work
- local runtime execution
- then external capability providers

## Five Reorders That Would Make The Course Worse

1. Moving `s04` before `s03`
   This teaches delegation before local planning.

2. Moving `s10` before `s09`
   This teaches prompt assembly before the learner understands one of its core inputs.

3. Moving `s13` before `s12`
   This collapses durable goals and live runtime slots into one confused idea.

4. Moving `s17` before `s15` or `s16`
   This turns autonomy into vague polling magic.

5. Moving `s19` before `s18`
   This makes the external platform look more important than the local execution boundary.

## A Good Maintainer Check Before Reordering

Before moving chapters around, ask:

1. Does the learner already understand the prerequisite concept?
2. Will this reorder blur two concepts that should stay separate?
3. Is this chapter mainly about goals, runtime state, actors, or capability boundaries?
4. If I move it earlier, will the reader still be able to build the minimal correct version?
5. Am I optimizing for understanding, or merely copying source-file order?

If the honest answer to the last question is "source-file order", the reorder is probably a mistake.

## Key Takeaway

**A good chapter order is not just a list of mechanisms. It is a sequence where each chapter feels like the next natural layer grown from the previous one.**


---

# s00f: Code Reading Order

> **Deep Dive** -- Read this when you're about to open the Python agent files and want a strategy for reading them.

This page is not about reading more code. It answers a narrower question: once the chapter order is stable, what is the cleanest order for reading this repository's code without scrambling your mental model again?

## Conclusion First

Do not read the code like this:

- do not start with the longest file
- do not jump straight into the most "advanced" chapter
- do not open `web/` first and then guess the mainline
- do not treat all `agents/*.py` files like one flat source pool

The stable rule is simple:

**read the code in the same order as the curriculum.**

Inside each chapter file, keep the same reading order:

1. state structures
2. tool definitions or registries
3. the function that advances one turn
4. the CLI entry last

## Why This Page Exists

You will probably not get lost in the prose first. You will get lost when you finally open the code and immediately start scanning the wrong things.

Typical mistakes:

- staring at the bottom half of a long file first
- reading a pile of `run_*` helpers before knowing where they connect
- jumping into late platform chapters and treating early chapters as "too simple"
- collapsing `task`, `runtime task`, `teammate`, and `worktree` back into one vague idea

## Use The Same Reading Template For Every Agent File

For any `agents/sXX_*.py`, read in this order:

### 1. File header

Answer two questions before anything else:

- what is this chapter teaching
- what is it intentionally not teaching yet

### 2. State structures or manager classes

Look for things like:

- `LoopState`
- `PlanningState`
- `CompactState`
- `TaskManager`
- `BackgroundManager`
- `TeammateManager`
- `WorktreeManager`

### 3. Tool list or registry

Look for:

- `TOOLS`
- `TOOL_HANDLERS`
- `build_tool_pool()`
- the important `run_*` entrypoints

### 4. The turn-advancing function

Usually this is one of:

- `run_one_turn(...)`
- `agent_loop(...)`
- a chapter-specific `handle_*`

### 5. CLI entry last

`if __name__ == "__main__"` matters, but it should not be the first thing you study.

## Stage 1: `s01-s06`

This stage is the single-agent backbone taking shape.

| Chapter | File | Read First | Then Read | Confirm Before Moving On |
|---|---|---|---|---|
| `s01` | `agents/s01_agent_loop.py` | `LoopState` | `TOOLS` -> `execute_tool_calls()` -> `run_one_turn()` -> `agent_loop()` | You can trace `messages -> model -> tool_result -> next turn` |
| `s02` | `agents/s02_tool_use.py` | `safe_path()` | tool handlers -> `TOOL_HANDLERS` -> `agent_loop()` | You understand how tools grow without rewriting the loop |
| `s03` | `agents/s03_todo_write.py` | planning state types | todo handler path -> reminder injection -> `agent_loop()` | You understand visible session planning state |
| `s04` | `agents/s04_subagent.py` | `AgentTemplate` | `run_subagent()` -> parent `agent_loop()` | You understand that subagents are mainly context isolation |
| `s05` | `agents/s05_skill_loading.py` | skill registry types | registry methods -> `agent_loop()` | You understand discover light, load deep |
| `s06` | `agents/s06_context_compact.py` | `CompactState` | persist / micro compact / history compact -> `agent_loop()` | You understand that compaction relocates detail instead of deleting continuity |

## Stage 2: `s07-s11`

This stage hardens the control plane around a working single agent.

| Chapter | File | Read First | Then Read | Confirm Before Moving On |
|---|---|---|---|---|
| `s07` | `agents/s07_permission_system.py` | validator / manager | permission path -> `run_bash()` -> `agent_loop()` | You understand gate before execute |
| `s08` | `agents/s08_hook_system.py` | `HookManager` | hook registration and dispatch -> `agent_loop()` | You understand fixed extension points |
| `s09` | `agents/s09_memory_system.py` | memory managers | save path -> prompt build -> `agent_loop()` | You understand memory as a long-term information layer |
| `s10` | `agents/s10_system_prompt.py` | `SystemPromptBuilder` | reminder builder -> `agent_loop()` | You understand input assembly as a pipeline |
| `s11` | `agents/s11_error_recovery.py` | compact / backoff helpers | recovery branches -> `agent_loop()` | You understand continuation after failure |

## Stage 3: `s12-s14`

This stage turns the harness into a work runtime.

| Chapter | File | Read First | Then Read | Confirm Before Moving On |
|---|---|---|---|---|
| `s12` | `agents/s12_task_system.py` | `TaskManager` | task create / dependency / unlock -> `agent_loop()` | You understand durable work goals |
| `s13` | `agents/s13_background_tasks.py` | `NotificationQueue` / `BackgroundManager` | background registration -> notification drain -> `agent_loop()` | You understand runtime slots |
| `s14` | `agents/s14_cron_scheduler.py` | `CronLock` / `CronScheduler` | cron match -> trigger -> `agent_loop()` | You understand future start conditions |

## Stage 4: `s15-s19`

This stage is about platform boundaries.

| Chapter | File | Read First | Then Read | Confirm Before Moving On |
|---|---|---|---|---|
| `s15` | `agents/s15_agent_teams.py` | `MessageBus` / `TeammateManager` | roster / inbox / loop -> `agent_loop()` | You understand persistent teammates |
| `s16` | `agents/s16_team_protocols.py` | `RequestStore` / `TeammateManager` | request handlers -> `agent_loop()` | You understand request-response plus `request_id` |
| `s17` | `agents/s17_autonomous_agents.py` | claim and identity helpers | claim path -> resume path -> `agent_loop()` | You understand idle check -> safe claim -> resume work |
| `s18` | `agents/s18_worktree_task_isolation.py` | `TaskManager` / `WorktreeManager` / `EventBus` | worktree lifecycle -> `agent_loop()` | You understand goals versus execution lanes |
| `s19` | `agents/s19_mcp_plugin.py` | capability gate / MCP client / plugin loader / router | tool pool build -> route -> normalize -> `agent_loop()` | You understand how external capability enters the same control plane |

## Best Doc + Code Loop

For each chapter:

1. read the chapter prose
2. read the bridge note for that chapter
3. open the matching `agents/sXX_*.py`
4. follow the order: state -> tools -> turn driver -> CLI entry
5. run the demo once
6. rewrite the smallest version from scratch

## Key Takeaway

**Code reading order must obey teaching order: read boundaries first, then state, then the path that advances the loop.**


---

# Teaching Scope

This document explains what you will learn in this repo, what is deliberately left out, and how each chapter stays aligned with your mental model as it grows.

## The Goal Of This Repo

This is not a line-by-line commentary on some upstream production codebase.

The real goal is:

**teach you how to build a high-completion coding-agent harness from scratch.**

That implies three obligations:

1. you can actually rebuild it
2. you keep the mainline clear instead of drowning in side detail
3. you do not absorb mechanisms that do not really exist

## What Every Chapter Should Cover

Every mainline chapter should make these things explicit:

- what problem the mechanism solves
- which module or layer it belongs to
- what state it owns
- what data structures it introduces
- how it plugs back into the loop
- what changes in the runtime flow after it appears

If you finish a chapter and still cannot say where the mechanism lives or what state it owns, the chapter is not done yet.

## What We Deliberately Keep Simple

These topics are not forbidden, but they should not dominate your learning path:

- packaging, build, and release flow
- cross-platform compatibility glue
- telemetry and enterprise policy wiring
- historical compatibility branches
- product-specific naming accidents
- line-by-line upstream code matching

Those belong in appendices, maintainer notes, or later productization notes, not at the center of the beginner path.

## What "High Fidelity" Really Means Here

High fidelity in a teaching repo does not mean reproducing every edge detail 1:1.

It means staying close to the true system backbone:

- core runtime model
- module boundaries
- key records
- state transitions
- cooperation between major subsystems

In short:

**be highly faithful to the trunk, and deliberate about teaching simplifications at the edges.**

## Who This Is For

You do not need to be an expert in agent platforms.

A better assumption about you:

- basic Python is familiar
- functions, classes, lists, and dictionaries are familiar
- agent systems may be completely new

That means the chapters should:

- explain new concepts before using them
- keep one concept complete in one main place
- move from "what it is" to "why it exists" to "how to build it"

## Recommended Chapter Structure

Mainline chapters should roughly follow this order:

1. what problem appears without this mechanism
2. first explain the new terms
3. give the smallest useful mental model
4. show the core records / data structures
5. show the smallest correct implementation
6. show how it plugs into the main loop
7. show common beginner mistakes
8. show what a higher-completion version would add later

## Terminology Guideline

If a chapter introduces a term from these categories, it should explain it:

- design pattern
- data structure
- concurrency term
- protocol / networking term
- uncommon engineering vocabulary

Examples:

- state machine
- scheduler
- queue
- worktree
- DAG
- protocol envelope

Do not drop the name without the explanation.

## Minimal Correct Version Principle

Real mechanisms are often complex, but teaching works best when it does not start with every branch at once.

Prefer this sequence:

1. show the smallest correct version
2. explain what core problem it already solves
3. show what later iterations would add

Examples:

- permission system: first `deny -> mode -> allow -> ask`
- error recovery: first three major recovery branches
- task system: first task records, dependencies, and unlocks
- team protocols: first request / response plus `request_id`

## Checklist For Rewriting A Chapter

- Does the first screen explain why the mechanism exists?
- Are new terms explained before they are used?
- Is there a small mental model or flow picture?
- Are key records listed explicitly?
- Is the plug-in point back into the loop explained?
- Are core mechanisms separated from peripheral product detail?
- Are the easiest confusion points called out?
- Does the chapter avoid inventing mechanisms not supported by the repo?

## How To Use Reverse-Engineered Source Material

Reverse-engineered source should be used as:

**maintainer calibration material**

Use it to:

- verify the mainline mechanism is described correctly
- verify important boundaries and records are not missing
- verify the teaching implementation did not drift into fiction

It should never become a prerequisite for understanding the teaching docs.

## Key Takeaway

**The quality of a teaching repo is decided less by how many details it mentions and more by whether the important details are fully explained and the unimportant details are safely omitted.**


---

# Glossary

> **Reference** -- Bookmark this page. Come back whenever you hit an unfamiliar term.

This glossary collects the terms that matter most to the teaching mainline -- the ones that most often trip up beginners. If you find yourself staring at a word mid-chapter and thinking "wait, what does that mean again?", this is the page to return to.

## Recommended Companion Docs

- [`entity-map.md`](./entity-map.md) for layer boundaries
- [`data-structures.md`](./data-structures.md) for record shapes
- [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) if you keep mixing up different kinds of "task"

## Agent

A model that can reason over input and call tools to complete work. (Think of it as the "brain" that decides what to do next.)

## Harness

The working environment prepared around the model -- everything the model needs but cannot provide for itself:

- tools
- filesystem
- permissions
- prompt assembly
- memory
- task runtime

## Agent Loop

The repeating core cycle that drives every agent session. Each iteration looks like this:

1. send current input to the model
2. inspect whether it answered or asked for tools
3. execute tools if needed
4. write results back
5. continue or stop

## Message / `messages[]`

The visible conversation and tool-result history used as working context. (This is the rolling transcript the model sees on every turn.)

## Tool

An action the model may request, such as reading a file, writing a file, editing content, or running a shell command.

## Tool Schema

The description shown to the model:

- name
- purpose
- input parameters
- input types

## Dispatch Map

A routing table from tool names to handlers. (Like a phone switchboard: the name comes in, and the map connects it to the right function.)

## Stop Reason

Why the current model turn ended. Common values:

- `end_turn`
- `tool_use`
- `max_tokens`

## Context

The total information currently visible to the model. (Everything inside the model's "window" on a given turn.)

## Compaction

The process of shrinking active context while preserving the important storyline and next-step information. (Like summarizing meeting notes so you keep the action items but drop the small talk.)

## Subagent

A one-shot delegated worker that runs in a separate context and usually returns a summary. (A temporary helper spun up for one job, then discarded.)

## Permission

The decision layer that determines whether a requested action may execute.

## Hook

An extension point that lets the system observe or add side effects around the loop without rewriting the loop itself. (Like event listeners -- the loop fires a signal, and hooks respond.)

## Memory

Cross-session information worth keeping because it remains valuable later and is not cheap to re-derive.

## System Prompt

The stable system-level instruction surface that defines identity, rules, and long-lived constraints.

## Query

The full multi-turn process used to complete one user request. (One query may span many loop turns before the answer is ready.)

## Transition Reason

The reason the system continues into another turn.

## Task

A durable work goal node in the work graph. (Unlike a todo item that disappears when the session ends, a task persists.)

## Runtime Task / Runtime Slot

A live execution slot representing something currently running. (The task says "what should happen"; the runtime slot says "it is happening right now.")

## Teammate

A persistent collaborator inside a multi-agent system. (Unlike a subagent that is fire-and-forget, a teammate sticks around.)

## Protocol Request

A structured request with explicit identity, status, and tracking, usually backed by a `request_id`. (A formal envelope rather than a casual message.)

## Worktree

An isolated execution directory lane used so parallel work does not collide. (Each lane gets its own copy of the workspace, like separate desks for separate tasks.)

## MCP

Model Context Protocol. In this repo it represents an external capability integration surface, not only a tool list. (The bridge that lets your agent talk to outside services.)

## DAG

Directed Acyclic Graph. A set of nodes connected by one-way edges with no cycles. (If you draw arrows between tasks showing "A must finish before B", and no arrow path ever loops back to where it started, you have a DAG.) Used in this repo for task dependency graphs.

## FSM / State Machine

Finite State Machine. A system that is always in exactly one state from a known set, and transitions between states based on defined events. (Think of a traffic light cycling through red, green, and yellow.) The agent loop's turn logic is modeled as a state machine.

## Control Plane

The layer that decides what should happen next, as opposed to the layer that actually does the work. (Air traffic control versus the airplane.) In this repo, the query engine and tool dispatch act as control planes.

## Tokens

The atomic units a language model reads and writes. One token is roughly 3/4 of an English word. Context limits and compaction thresholds are measured in tokens.


---

# Core Data Structures

> **Reference** -- Use this when you lose track of where state lives. Each record has one clear job.

The easiest way to get lost in an agent system is not feature count -- it is losing track of where the state actually lives. This document collects the core records that appear again and again across the mainline and bridge docs so you always have one place to look them up.

## Recommended Reading Together

- [`glossary.md`](./glossary.md) for term meanings
- [`entity-map.md`](./entity-map.md) for layer boundaries
- [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) for task vs runtime-slot separation
- [`s19a-mcp-capability-layers.md`](./s19a-mcp-capability-layers.md) for MCP beyond tools

## Two Principles To Keep In Mind

### Principle 1: separate content state from process-control state

- `messages`, `tool_result`, and memory text are content state
- `turn_count`, `transition`, and retry flags are process-control state

### Principle 2: separate durable state from runtime-only state

- tasks, memory, and schedules are usually durable
- runtime slots, permission decisions, and live MCP connections are usually runtime state

## Query And Conversation State

### `Message`

Stores conversation and tool round-trip history.

### `NormalizedMessage`

Stable message shape ready for the model API.

### `QueryParams`

External input used to start one query process.

### `QueryState`

Mutable state that changes across turns.

### `TransitionReason`

Explains why the next turn exists.

### `CompactSummary`

Compressed carry-forward summary when old context leaves the hot window.

## Prompt And Input State

### `SystemPromptBlock`

One stable prompt fragment.

### `PromptParts`

Separated prompt fragments before final assembly.

### `ReminderMessage`

Temporary one-turn or one-mode injection.

## Tool And Control-Plane State

### `ToolSpec`

What the model knows about one tool.

### `ToolDispatchMap`

Name-to-handler routing table.

### `ToolUseContext`

Shared execution environment visible to tools.

### `ToolResultEnvelope`

Normalized result returned into the main loop.

### `PermissionRule`

Policy that decides allow / deny / ask.

### `PermissionDecision`

Structured output of the permission gate.

### `HookEvent`

Normalized lifecycle event emitted around the loop.

## Durable Work State

### `TaskRecord`

Durable work-graph node with goal, status, and dependency edges.

### `ScheduleRecord`

Rule describing when work should trigger.

### `MemoryEntry`

Cross-session fact worth keeping.

## Runtime Execution State

### `RuntimeTaskState`

Live execution-slot record for background or long-running work.

### `Notification`

Small result bridge that carries runtime outcomes back into the main loop.

### `RecoveryState`

State used to continue coherently after failures.

## Team And Platform State

### `TeamMember`

Persistent teammate identity.

### `MessageEnvelope`

Structured message between teammates.

### `RequestRecord`

Durable record for approvals, shutdowns, handoffs, or other protocol workflows.

### `WorktreeRecord`

Record for one isolated execution lane.

### `MCPServerConfig`

Configuration for one external capability provider.

### `CapabilityRoute`

Routing decision for native, plugin, or MCP-backed capability.

## A Useful Quick Map

| Record | Main Job | Usually Lives In |
|---|---|---|
| `Message` | conversation history | `messages[]` |
| `QueryState` | turn-by-turn control | query engine |
| `ToolUseContext` | tool execution environment | tool control plane |
| `PermissionDecision` | execution gate outcome | permission layer |
| `TaskRecord` | durable work goal | task board |
| `RuntimeTaskState` | live execution slot | runtime manager |
| `TeamMember` | persistent teammate | team config |
| `RequestRecord` | protocol state | request tracker |
| `WorktreeRecord` | isolated execution lane | worktree index |
| `MCPServerConfig` | external capability config | settings / plugin config |

## Key Takeaway

**High-completion systems become much easier to understand when every important record has one clear job and one clear layer.**


---

# Entity Map

> **Reference** -- Use this when concepts start to blur together. It tells you which layer each thing belongs to.

As you move into the second half of the repo, you will notice that the main source of confusion is often not code. It is the fact that many entities look similar while living on different layers. This map helps you keep them straight.

## How This Map Differs From Other Docs

- this map answers: **which layer does this thing belong to?**
- [`glossary.md`](./glossary.md) answers: **what does the word mean?**
- [`data-structures.md`](./data-structures.md) answers: **what does the state shape look like?**

## A Fast Layered Picture

```text
conversation layer
  - message
  - prompt block
  - reminder

action layer
  - tool call
  - tool result
  - hook event

work layer
  - work-graph task
  - runtime task
  - protocol request

execution layer
  - subagent
  - teammate
  - worktree lane

platform layer
  - MCP server
  - memory record
  - capability router
```

## The Most Commonly Confused Pairs

### `Message` vs `PromptBlock`

| Entity | What It Is | What It Is Not |
|---|---|---|
| `Message` | conversational content in history | not a stable system rule |
| `PromptBlock` | stable prompt instruction fragment | not one turn's latest event |

### `Todo / Plan` vs `Task`

| Entity | What It Is | What It Is Not |
|---|---|---|
| `todo / plan` | temporary session guidance | not a durable work graph |
| `task` | durable work node | not one turn's local thought |

### `Work-Graph Task` vs `RuntimeTaskState`

| Entity | What It Is | What It Is Not |
|---|---|---|
| work-graph task | durable goal and dependency node | not the live executor |
| runtime task | currently running execution slot | not the durable dependency node |

### `Subagent` vs `Teammate`

| Entity | What It Is | What It Is Not |
|---|---|---|
| subagent | one-shot delegated worker | not a long-lived team member |
| teammate | persistent collaborator with identity and inbox | not a disposable summary tool |

### `ProtocolRequest` vs normal message

| Entity | What It Is | What It Is Not |
|---|---|---|
| normal message | free-form communication | not a traceable approval workflow |
| protocol request | structured request with `request_id` | not casual chat text |

### `Task` vs `Worktree`

| Entity | What It Is | What It Is Not |
|---|---|---|
| task | what should be done | not a directory |
| worktree | where isolated execution happens | not the goal itself |

### `Memory` vs `CLAUDE.md`

| Entity | What It Is | What It Is Not |
|---|---|---|
| memory | durable cross-session facts | not the project rule file |
| `CLAUDE.md` | stable local rule / instruction surface | not user-specific long-term fact storage |

### `MCPServer` vs `MCPTool`

| Entity | What It Is | What It Is Not |
|---|---|---|
| MCP server | external capability provider | not one specific tool |
| MCP tool | one exposed capability | not the whole connection surface |

## Quick "What / Where" Table

| Entity | Main Job | Typical Place |
|---|---|---|
| `Message` | visible conversation context | `messages[]` |
| `PromptParts` | input assembly fragments | prompt builder |
| `PermissionRule` | execution decision rules | settings / session state |
| `HookEvent` | lifecycle extension point | hook system |
| `MemoryEntry` | durable fact | memory store |
| `TaskRecord` | work goal node | task board |
| `RuntimeTaskState` | live execution slot | runtime manager |
| `TeamMember` | persistent worker identity | team config |
| `MessageEnvelope` | structured teammate message | inbox |
| `RequestRecord` | protocol workflow state | request tracker |
| `WorktreeRecord` | isolated execution lane | worktree index |
| `MCPServerConfig` | external capability provider config | plugin / settings |

## Key Takeaway

**The more capable the system becomes, the more important clear entity boundaries become.**


---

# s00e: Reference Module Map

> **Deep Dive** -- Read this when you want to verify how the teaching chapters map to the real production codebase.

This is a calibration note for maintainers and serious learners. It does not turn the reverse-engineered source into required reading. Instead, it answers one narrow but important question: if you compare the high-signal module clusters in the reference repo with this teaching repo, is the current chapter order actually rational?

## Verdict First

Yes.

The current `s01 -> s19` order is broadly correct, and it is closer to the real design backbone than any naive "follow the source tree" order would be.

The reason is simple:

- the reference repo contains many surface-level directories
- but the real design weight is concentrated in a smaller set of control, state, task, team, worktree, and capability modules
- those modules line up with the current four-stage teaching path

So the right move is **not** to flatten the teaching repo into source-tree order.

The right move is:

- keep the current dependency-driven order
- make the mapping to the reference repo explicit
- keep removing low-value product detail from the mainline

## How This Comparison Was Done

The comparison was based on the reference repo's higher-signal clusters, especially modules around:

- `Tool.ts`
- `state/AppStateStore.ts`
- `coordinator/coordinatorMode.ts`
- `memdir/*`
- `services/SessionMemory/*`
- `services/toolUseSummary/*`
- `constants/prompts.ts`
- `tasks/*`
- `tools/TodoWriteTool/*`
- `tools/AgentTool/*`
- `tools/ScheduleCronTool/*`
- `tools/EnterWorktreeTool/*`
- `tools/ExitWorktreeTool/*`
- `tools/MCPTool/*`
- `services/mcp/*`
- `plugins/*`
- `hooks/toolPermission/*`

This is enough to judge the backbone without dragging you through every product-facing command, compatibility branch, or UI detail.

## The Real Mapping

| Reference repo cluster | Typical examples | Teaching chapter(s) | Why this placement is right |
|---|---|---|---|
| Query loop + control state | `Tool.ts`, `AppStateStore.ts`, query/coordinator state | `s00`, `s00a`, `s00b`, `s01`, `s11` | The real system is not just `messages[] + while True`. The teaching repo is right to start with the tiny loop first, then add the control plane later. |
| Tool routing and execution plane | `Tool.ts`, native tools, tool context, execution helpers | `s02`, `s02a`, `s02b` | The source clearly treats tools as a shared execution surface, not a toy dispatch table. The teaching split is correct. |
| Session planning | `TodoWriteTool` | `s03` | Session planning is a small but central layer. It belongs early, before durable tasks. |
| One-shot delegation | `AgentTool` in its simplest form | `s04` | The reference repo's agent spawning machinery is large, but the teaching repo is right to teach the smallest clean subagent first: fresh context, bounded task, summary return. |
| Skill discovery and loading | `DiscoverSkillsTool`, `skills/*`, prompt sections | `s05` | Skills are not random extras. They are a selective knowledge-loading layer, so they belong before prompt and context pressure become severe. |
| Context pressure and collapse | `services/toolUseSummary/*`, `services/contextCollapse/*`, compact logic | `s06` | The reference repo clearly has explicit compaction machinery. Teaching this before later platform features is correct. |
| Permission gate | `types/permissions.ts`, `hooks/toolPermission/*`, approval handlers | `s07` | Execution safety is a distinct gate, not "just another hook". Keeping it before hooks is the right teaching choice. |
| Hooks and side effects | `types/hooks.ts`, hook runners, lifecycle integrations | `s08` | The source separates extension points from the primary gate. Teaching them after permissions preserves that boundary. |
| Durable memory selection | `memdir/*`, `services/SessionMemory/*`, extract/select memory helpers | `s09` | The source makes memory a selective cross-session layer, not a generic notebook. Teaching this before prompt assembly is correct. |
| Prompt assembly | `constants/prompts.ts`, prompt sections, memory prompt loading | `s10`, `s10a` | The source builds inputs from many sections. The teaching repo is right to present prompt assembly as a pipeline instead of one giant string. |
| Recovery and continuation | query transition reasons, retry branches, compaction retry, token recovery | `s11`, `s00c` | The reference repo has explicit continuation logic. This belongs after loop, tools, compaction, permissions, memory, and prompt assembly already exist. |
| Durable work graph | task records, task board concepts, dependency unlocks | `s12` | The teaching repo correctly separates durable work goals from temporary session planning. |
| Live runtime tasks | `tasks/types.ts`, `LocalShellTask`, `LocalAgentTask`, `RemoteAgentTask`, `MonitorMcpTask` | `s13`, `s13a` | The source has a clear runtime-task union. This strongly validates the teaching split between `TaskRecord` and `RuntimeTaskState`. |
| Scheduled triggers | `ScheduleCronTool/*`, `useScheduledTasks` | `s14` | Scheduling appears after runtime work exists, which is exactly the correct dependency order. |
| Persistent teammates | `InProcessTeammateTask`, team tools, agent registries | `s15` | The source clearly grows from one-shot subagents into durable actors. Teaching teammates later is correct. |
| Structured team coordination | message envelopes, send-message flows, request tracking, coordinator mode | `s16` | Protocols make sense only after durable actors exist. The current order matches the real dependency. |
| Autonomous claiming and resuming | coordinator mode, task claiming, async worker lifecycle, resume logic | `s17` | Autonomy in the source is not magic. It is layered on top of actors, tasks, and coordination rules. The current placement is correct. |
| Worktree execution lanes | `EnterWorktreeTool`, `ExitWorktreeTool`, agent worktree helpers | `s18` | The reference repo treats worktree as an execution-lane boundary with closeout logic. Teaching it after tasks and teammates prevents concept collapse. |
| External capability bus | `MCPTool`, `services/mcp/*`, `plugins/*`, MCP resources/prompts/tools | `s19`, `s19a` | The source clearly places MCP and plugins at the outer platform boundary. Keeping this last is the right teaching choice. |

## The Most Important Validation Points

The reference repo strongly confirms five teaching choices.

### 1. `s03` should stay before `s12`

The source contains both:

- small session planning
- larger durable task/runtime machinery

Those are not the same thing.

The teaching repo is correct to teach:

`session planning first -> durable tasks later`

### 2. `s09` should stay before `s10`

The source builds the model input from multiple sources, including memory.

That means:

- memory is one input source
- prompt assembly is the pipeline that combines sources

So memory should be explained before prompt assembly.

### 3. `s12` must stay before `s13`

The runtime-task union in the reference repo is one of the strongest pieces of evidence in the whole comparison.

It shows that:

- durable work definitions
- live running executions

must stay conceptually separate.

If `s13` came first, you would almost certainly merge those two layers.

### 4. `s15 -> s16 -> s17` is the right order

The source has:

- durable actors
- structured coordination
- autonomous resume / claiming behavior

Autonomy depends on the first two. So the current order is correct.

### 5. `s18` should stay before `s19`

The reference repo treats worktree isolation as a local execution-boundary mechanism.

That should be understood before you are asked to reason about:

- external capability providers
- MCP servers
- plugin-installed surfaces

Otherwise external capability looks more central than it really is.

## What This Teaching Repo Should Still Avoid Copying

The reference repo contains many things that are real, but should still not dominate the teaching mainline:

- CLI command surface area
- UI rendering details
- telemetry and analytics branches
- product integration glue
- remote and enterprise wiring
- platform-specific compatibility code
- line-by-line naming trivia

These are valid implementation details.

They are not the right center of a 0-to-1 teaching path.

## Where The Teaching Repo Must Be Extra Careful

The mapping also reveals several places where things can easily drift into confusion.

### 1. Do not merge subagents and teammates into one vague concept

The reference repo's `AgentTool` spans:

- one-shot delegation
- async/background workers
- teammate-like persistent workers
- worktree-isolated workers

That is exactly why the teaching repo should split the story across:

- `s04`
- `s15`
- `s17`
- `s18`

### 2. Do not teach worktree as "just a git trick"

The source shows closeout, resume, cleanup, and isolation state around worktrees.

So `s18` should keep teaching:

- lane identity
- task binding
- keep/remove closeout
- resume and cleanup concerns

not just `git worktree add`.

### 3. Do not reduce MCP to "remote tools"

The source includes:

- tools
- resources
- prompts
- elicitation / connection state
- plugin mediation

So `s19` should keep a tools-first teaching path, but still explain the wider capability-bus boundary.

## Final Judgment

Compared against the high-signal module clusters in the reference repo, the current chapter order is sound.

The biggest remaining quality gains do **not** come from another major reorder.

They come from:

- cleaner bridge docs
- stronger entity-boundary explanations
- tighter multilingual consistency
- web pages that expose the same learning map clearly

## Key Takeaway

**The best teaching order is not the order files appear in a repo. It is the order in which dependencies become understandable to a learner who wants to rebuild the system.**


---

# s00a: Query Control Plane

> **Deep Dive** -- Best read after completing Stage 1 (s01-s06). It explains why the simple loop needs a coordination layer as the system grows.

### When to Read This

After you've built the basic loop and tools, and before you start Stage 2's hardening chapters.

---

> This bridge document answers one foundational question:
>
> **Why is `messages[] + while True` not enough for a high-completion agent?**

## Why This Document Exists

`s01` correctly teaches the smallest working loop:

```text
user input
  ->
model response
  ->
if tool_use then execute
  ->
append result
  ->
continue
```

That is the right starting point.

But once the system grows, the harness needs a separate layer that manages the **query process itself**. A "control plane" (the part of a system that coordinates behavior rather than performing the work directly) sits above the data path and decides when, why, and how the loop should keep running:

- current turn
- continuation reason
- recovery state
- compaction state
- budget changes
- hook-driven continuation

That layer is the **query control plane**.

## Terms First

### What is a query?

Here, a query is not a database lookup.

It means:

> the full multi-turn process the system runs in order to finish one user request

### What is a control plane?

A control plane does not perform the business action itself.

It coordinates:

- when execution continues
- why it continues
- what state is patched before the next turn

If you have worked with networking or infrastructure, the term is familiar -- the control plane decides where traffic goes, while the data plane carries the actual packets. The same idea applies here: the control plane decides whether the loop should keep running and why, while the execution layer does the actual model calls and tool work.

### What is a transition?

A transition explains:

> why the previous turn did not end and why the next turn exists

Common reasons:

- tool result write-back
- truncated output recovery
- retry after compaction
- retry after transport failure

## The Smallest Useful Mental Model

Think of the query path in three layers:

```text
1. Input layer
   - messages
   - system prompt
   - user/system context

2. Control layer
   - query state
   - turn count
   - transition reason
   - recovery / compaction / budget flags

3. Execution layer
   - model call
   - tool execution
   - write-back
```

The control plane does not replace the loop.

It makes the loop capable of handling more than one happy-path branch.

## Why `messages[]` Alone Stops Being Enough

At demo scale, many learners put everything into `messages[]`.

That breaks down once the system needs to know:

- whether reactive compaction already ran
- how many continuation attempts happened
- whether this turn is a retry or a normal write-back
- whether a temporary output budget is active

Those are not conversation contents.

They are **process-control state**.

## Core Structures

### `QueryParams`

External input passed into the query engine:

```python
params = {
    "messages": [...],
    "system_prompt": "...",
    "tool_use_context": {...},
    "max_output_tokens_override": None,
    "max_turns": None,
}
```

### `QueryState`

Mutable state that changes across turns:

```python
state = {
    "messages": [...],
    "tool_use_context": {...},
    "turn_count": 1,
    "continuation_count": 0,
    "has_attempted_compact": False,
    "max_output_tokens_override": None,
    "transition": None,
}
```

### `TransitionReason`

An explicit reason for continuing:

```python
TRANSITIONS = (
    "tool_result_continuation",
    "max_tokens_recovery",
    "compact_retry",
    "transport_retry",
)
```

This is not ceremony. It makes logs, testing, debugging, and teaching much clearer.

## Minimal Implementation Pattern

### 1. Split entry params from live state

```python
def query(params):
    state = {
        "messages": params["messages"],
        "tool_use_context": params["tool_use_context"],
        "turn_count": 1,
        "transition": None,
    }
```

### 2. Let every continue-site patch state explicitly

```python
state["transition"] = "tool_result_continuation"
state["turn_count"] += 1
```

### 3. Make the next turn enter with a reason

The next loop iteration should know whether it exists because of:

- normal write-back
- retry
- compaction
- continuation after truncated output

## What This Changes For You

Once you see the query control plane clearly, later chapters stop feeling like random features.

- `s06` compaction becomes a state patch, not a magic jump
- `s11` recovery becomes structured continuation, not just `try/except`
- `s17` autonomy becomes another controlled continuation path, not a separate mystery loop

## Key Takeaway

**A query is not just messages flowing through a loop. It is a controlled process with explicit continuation state.**


---

# s00b: One Request Lifecycle

> **Deep Dive** -- Best read after Stage 2 (s07-s11) when you want to see how all the pieces connect end-to-end.

### When to Read This

When you've learned several subsystems and want to see the full vertical flow of a single request.

---

> This bridge document connects the whole system into one continuous execution chain.
>
> It answers:
>
> **What really happens after one user message enters the system?**

## Why This Document Exists

When you read chapter by chapter, you can understand each mechanism in isolation:

- `s01` loop
- `s02` tools
- `s07` permissions
- `s09` memory
- `s12-s19` tasks, teams, worktrees, MCP

But implementation gets difficult when you cannot answer:

- what comes first?
- when do memory and prompt assembly happen?
- where do permissions sit relative to tools?
- when do tasks, runtime slots, teammates, worktrees, and MCP enter?

This document gives you the vertical flow.

## The Most Important Full Picture

```text
user request
  |
  v
initialize query state
  |
  v
assemble system prompt / messages / reminders
  |
  v
call model
  |
  +-- normal answer --------------------------> finish request
  |
  +-- tool_use
        |
        v
    tool router
        |
        +-- permission gate
        +-- hooks
        +-- native tool / MCP / agent / task / team
        |
        v
    execution result
        |
        +-- may update task / runtime / memory / worktree state
        |
        v
    write tool_result back to messages
        |
        v
    patch query state
        |
        v
    continue next turn
```

## Segment 1: A User Request Becomes Query State

The system does not treat one user request as one API call.

It first creates a query state for a process that may span many turns:

```python
query_state = {
    "messages": [{"role": "user", "content": user_text}],
    "turn_count": 1,
    "transition": None,
    "tool_use_context": {...},
}
```

The key mental shift:

**a request is a multi-turn runtime process, not a single model response.**

Related reading:

- [`s01-the-agent-loop.md`](./s01-the-agent-loop.md)
- [`s00a-query-control-plane.md`](./s00a-query-control-plane.md)

## Segment 2: The Real Model Input Is Assembled

The harness usually does not send raw `messages` directly.

It assembles:

- system prompt blocks
- normalized messages
- memory attachments
- reminders
- tool definitions

So the actual payload is closer to:

```text
system prompt
+ normalized messages
+ tools
+ optional reminders and attachments
```

Related chapters:

- `s09`
- `s10`
- [`s10a-message-prompt-pipeline.md`](./s10a-message-prompt-pipeline.md)

## Segment 3: The Model Produces Either an Answer or an Action Intent

There are two important output classes.

### Normal answer

The request may end here.

### Action intent

This usually means a tool call, for example:

- `read_file(...)`
- `bash(...)`
- `task_create(...)`
- `mcp__server__tool(...)`

The system is no longer receiving only text.

It is receiving an instruction that should affect the real world.

## Segment 4: The Tool Control Plane Takes Over

Once `tool_use` appears, the system enters the tool control plane (the layer that decides how a tool call gets routed, checked, and executed).

It answers:

1. which tool is this?
2. where should it route?
3. should it pass a permission gate?
4. do hooks observe or modify the action?
5. what shared runtime context can it access?

Minimal picture:

```text
tool_use
  |
  v
tool router
  |
  +-- native handler
  +-- MCP client
  +-- agent / team / task runtime
```

Related reading:

- [`s02-tool-use.md`](./s02-tool-use.md)
- [`s02a-tool-control-plane.md`](./s02a-tool-control-plane.md)

## Segment 5: Execution May Update More Than Messages

A tool result does not only return text.

Execution may also update:

- task board state
- runtime task state
- memory records
- request records
- worktree records

That is why middle and late chapters are not optional side features. They become part of the request lifecycle.

## Segment 6: Results Rejoin the Main Loop

The crucial step is always the same:

```text
real execution result
  ->
tool_result or structured write-back
  ->
messages / query state updated
  ->
next turn
```

If the result never re-enters the loop, the model cannot reason over reality.

## A Useful Compression

When you get lost, compress the whole lifecycle into three layers:

### Query loop

Owns the multi-turn request process.

### Tool control plane

Owns routing, permissions, hooks, and execution context.

### Platform state

Owns durable records such as tasks, runtime slots, teammates, worktrees, and external capability configuration.

## Key Takeaway

**A user request enters as query state, moves through assembled input, becomes action intent, crosses the tool control plane, touches platform state, and then returns to the loop as new visible context.**


---

# s00c: Query Transition Model

> **Deep Dive** -- Best read alongside s11 (Error Recovery). It deepens the transition model introduced in s00a.

### When to Read This

When you're working on error recovery and want to understand why each continuation needs an explicit reason.

---

> This bridge note answers one narrow but important question:
>
> **Why does a high-completion agent need to know _why_ a query continues into the next turn, instead of treating every `continue` as the same thing?**

## Why This Note Exists

The mainline already teaches:

- `s01`: the smallest loop
- `s06`: compaction and context control
- `s11`: error recovery

That sequence is correct.

The problem is what you often carry in your head after reading those chapters separately:

> "The loop continues because it continues."

That is enough for a toy demo, but it breaks down quickly in a larger system.

A query can continue for very different reasons:

- a tool just finished and the model needs the result
- the output hit a token limit and the model should continue
- compaction changed the active context and the system should retry
- the transport layer failed and backoff says "try again"
- a stop hook said the turn should not fully end yet
- a budget policy still allows the system to keep going

If all of those collapse into one vague `continue`, three things get worse fast:

- logs stop being readable
- tests stop being precise
- the teaching mental model becomes blurry

## Terms First

### What is a transition

Here, a transition means:

> the reason the previous turn became the next turn

It is not the message content itself. It is the control-flow cause.

### What is a continuation

A continuation means:

> this query is still alive and should keep advancing

But continuation is not one thing. It is a family of reasons.

### What is a query boundary

A query boundary is the edge between one turn and the next.

Whenever the system crosses that boundary, it should know:

- why it is crossing
- what state was changed before the crossing
- how the next turn should interpret that change

## The Minimum Mental Model

Do not picture a query as a single straight line.

A better mental model is:

```text
one query
  = a chain of state transitions
    with explicit continuation reasons
```

For example:

```text
user input
  ->
model emits tool_use
  ->
tool finishes
  ->
tool_result_continuation
  ->
model output is truncated
  ->
max_tokens_recovery
  ->
compaction happens
  ->
compact_retry
  ->
final completion
```

That is why the real lesson is not:

> "the loop keeps spinning"

The real lesson is:

> "the system is advancing through typed transition reasons"

## Core Records

### 1. `transition` inside query state

Even a teaching implementation should carry an explicit transition field:

```python
state = {
    "messages": [...],
    "turn_count": 3,
    "continuation_count": 1,
    "has_attempted_compact": False,
    "transition": None,
}
```

This field is not decoration.

It tells you:

- why this turn exists
- how the log should explain it
- what path a test should assert

### 2. `TransitionReason`

A minimal teaching set can look like this:

```python
TRANSITIONS = (
    "tool_result_continuation",
    "max_tokens_recovery",
    "compact_retry",
    "transport_retry",
    "stop_hook_continuation",
    "budget_continuation",
)
```

These reasons are not equivalent:

- `tool_result_continuation`
  is normal loop progress
- `max_tokens_recovery`
  is continuation after truncated output
- `compact_retry`
  is continuation after context reshaping
- `transport_retry`
  is continuation after infrastructure failure
- `stop_hook_continuation`
  is continuation forced by external control logic
- `budget_continuation`
  is continuation allowed by policy and remaining budget

### 3. Continuation budget

High-completion systems do not just continue. They limit continuation.

Typical fields look like:

```python
state = {
    "max_output_tokens_recovery_count": 2,
    "has_attempted_reactive_compact": True,
}
```

The principle is:

> continuation is a controlled resource, not an infinite escape hatch

## Minimum Implementation Steps

### Step 1: make every continue site explicit

Many beginner loops still look like this:

```python
continue
```

Move one step forward:

```python
state["transition"] = "tool_result_continuation"
continue
```

### Step 2: pair each continuation with its state patch

```python
if response.stop_reason == "tool_use":
    state["messages"] = append_tool_results(...)
    state["turn_count"] += 1
    state["transition"] = "tool_result_continuation"
    continue

if response.stop_reason == "max_tokens":
    state["messages"].append({
        "role": "user",
        "content": CONTINUE_MESSAGE,
    })
    state["max_output_tokens_recovery_count"] += 1
    state["transition"] = "max_tokens_recovery"
    continue
```

The important part is not "one more line of code."

The important part is:

> before every continuation, the system knows both the reason and the state mutation

### Step 3: separate normal progress from recovery

```python
if should_retry_transport(error):
    time.sleep(backoff(...))
    state["transition"] = "transport_retry"
    continue

if should_recompact(error):
    state["messages"] = compact_messages(state["messages"])
    state["transition"] = "compact_retry"
    continue
```

Once you do this, "continue" stops being a vague action and becomes a typed control transition.

## What to Test

Your teaching repo should make these assertions straightforward:

- a tool result writes `tool_result_continuation`
- a truncated model output writes `max_tokens_recovery`
- compaction retry does not silently reuse the old reason
- transport retry increments retry state and does not look like a normal turn

If those paths are not easy to test, the model is probably still too implicit.

## What Not to Over-Teach

You do not need to bury yourself in vendor-specific transport details or every corner-case enum.

For a teaching repo, the core lesson is narrower:

> one query is a sequence of explicit transitions, and each transition should carry a reason, a state patch, and a budget rule

That is the part you actually need if you want to rebuild a high-completion agent from zero.

## Key Takeaway

**Every continuation needs a typed reason. Without one, logs blur, tests weaken, and the mental model collapses into "the loop keeps spinning."**


---

# s01: The Agent Loop

`[ s01 ] > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How the core agent loop works: send messages, run tools, feed results back
- Why the "write-back" step is the single most important idea in agent design
- How to build a working agent in under 30 lines of Python

Imagine you have a brilliant assistant who can reason about code, plan solutions, and write great answers -- but cannot touch anything. Every time it suggests running a command, you have to copy it, run it yourself, paste the output back, and wait for the next suggestion. You are the loop. This chapter removes you from that loop.

## The Problem

Without a loop, every tool call requires a human in the middle. The model says "run this test." You run it. You paste the output. The model says "now fix line 12." You fix it. You tell the model what happened. This manual back-and-forth might work for a single question, but it falls apart completely when a task requires 10, 20, or 50 tool calls in a row.

The solution is simple: let the code do the looping.

## The Solution

Here's the entire system in one picture:

```
+--------+      +-------+      +---------+
|  User  | ---> |  LLM  | ---> |  Tool   |
| prompt |      |       |      | execute |
+--------+      +---+---+      +----+----+
                    ^                |
                    |   tool_result  |
                    +----------------+
                    (loop until the model stops calling tools)
```

The model talks, the harness (the code wrapping the model) executes tools, and the results go right back into the conversation. The loop keeps spinning until the model decides it's done.

## How It Works

**Step 1.** The user's prompt becomes the first message.

```python
messages.append({"role": "user", "content": query})
```

**Step 2.** Send the conversation to the model, along with tool definitions.

```python
response = client.messages.create(
    model=MODEL, system=SYSTEM, messages=messages,
    tools=TOOLS, max_tokens=8000,
)
```

**Step 3.** Add the model's response to the conversation. Then check: did it call a tool, or is it done?

```python
messages.append({"role": "assistant", "content": response.content})

# If the model didn't call a tool, the task is finished
if response.stop_reason != "tool_use":
    return
```

**Step 4.** Execute each tool call, collect the results, and put them back into the conversation as a new message. Then loop back to Step 2.

```python
results = []
for block in response.content:
    if block.type == "tool_use":
        output = run_bash(block.input["command"])
        results.append({
            "type": "tool_result",
            "tool_use_id": block.id,  # links result to the tool call
            "content": output,
        })
# This is the "write-back" -- the model can now see the real-world result
messages.append({"role": "user", "content": results})
```

Put it all together, and the entire agent fits in one function:

```python
def agent_loop(query):
    messages = [{"role": "user", "content": query}]
    while True:
        response = client.messages.create(
            model=MODEL, system=SYSTEM, messages=messages,
            tools=TOOLS, max_tokens=8000,
        )
        messages.append({"role": "assistant", "content": response.content})

        if response.stop_reason != "tool_use":
            return  # model is done

        results = []
        for block in response.content:
            if block.type == "tool_use":
                output = run_bash(block.input["command"])
                results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": output,
                })
        messages.append({"role": "user", "content": results})
```

That's the entire agent in under 30 lines. Everything else in this course layers on top of this loop -- without changing its core shape.

> **A note about real systems:** Production agents typically use streaming responses, where the model's output arrives token by token instead of all at once. That changes the user experience (you see text appearing in real time), but the fundamental loop -- send, execute, write back -- stays exactly the same. We skip streaming here to keep the core idea crystal clear.

## What Changed

| Component     | Before     | After                          |
|---------------|------------|--------------------------------|
| Agent loop    | (none)     | `while True` + stop_reason     |
| Tools         | (none)     | `bash` (one tool)              |
| Messages      | (none)     | Accumulating list              |
| Control flow  | (none)     | `stop_reason != "tool_use"`    |

## Try It

```sh
cd learn-claude-code
python agents/s01_agent_loop.py
```

1. `Create a file called hello.py that prints "Hello, World!"`
2. `List all Python files in this directory`
3. `What is the current git branch?`
4. `Create a directory called test_output and write 3 files in it`

## What You've Mastered

At this point, you can:

- Build a working agent loop from scratch
- Explain why tool results must flow back into the conversation (the "write-back")
- Redraw the loop from memory: messages -> model -> tool execution -> write-back -> next turn

## What's Next

Right now, the agent can only run bash commands. That means every file read uses `cat`, every edit uses `sed`, and there's no safety boundary at all. In the next chapter, you'll add dedicated tools with a clean routing system -- and the loop itself won't need to change at all.

## Key Takeaway

> An agent is just a loop: send messages to the model, execute the tools it asks for, feed the results back, and repeat until it's done.


---

# s02: Tool Use

`s01 > [ s02 ] > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How to build a dispatch map (a routing table that maps tool names to handler functions)
- How path sandboxing prevents the model from escaping its workspace
- How to add new tools without touching the agent loop

If you ran the s01 agent for more than a few minutes, you probably noticed the cracks. `cat` silently truncates long files. `sed` chokes on special characters. Every bash command is an open door -- nothing stops the model from running `rm -rf /` or reading your SSH keys. You need dedicated tools with guardrails, and you need a clean way to add them.

## The Problem

With only `bash`, the agent shells out for everything. There is no way to limit what it reads, where it writes, or how much output it returns. A single bad command can corrupt files, leak secrets, or blow past your token budget with a massive stdout dump. What you really want is a small set of purpose-built tools -- `read_file`, `write_file`, `edit_file` -- each with its own safety checks. The question is: how do you wire them in without rewriting the loop every time?

## The Solution

The answer is a dispatch map -- one dictionary that routes tool names to handler functions. Adding a tool means adding one entry. The loop itself never changes.

```
+--------+      +-------+      +------------------+
|  User  | ---> |  LLM  | ---> | Tool Dispatch    |
| prompt |      |       |      | {                |
+--------+      +---+---+      |   bash: run_bash |
                    ^           |   read: run_read |
                    |           |   write: run_wr  |
                    +-----------+   edit: run_edit |
                    tool_result | }                |
                                +------------------+

The dispatch map is a dict: {tool_name: handler_function}.
One lookup replaces any if/elif chain.
```

## How It Works

**Step 1.** Each tool gets a handler function. Path sandboxing prevents the model from escaping the workspace -- every requested path is resolved and checked against the working directory before any I/O happens.

```python
def safe_path(p: str) -> Path:
    path = (WORKDIR / p).resolve()
    if not path.is_relative_to(WORKDIR):
        raise ValueError(f"Path escapes workspace: {p}")
    return path

def run_read(path: str, limit: int = None) -> str:
    text = safe_path(path).read_text()
    lines = text.splitlines()
    if limit and limit < len(lines):
        lines = lines[:limit]
    return "\n".join(lines)[:50000]  # hard cap to avoid blowing up the context
```

**Step 2.** The dispatch map links tool names to handlers. This is the entire routing layer -- no if/elif chain, no class hierarchy, just a dictionary.

```python
TOOL_HANDLERS = {
    "bash":       lambda **kw: run_bash(kw["command"]),
    "read_file":  lambda **kw: run_read(kw["path"], kw.get("limit")),
    "write_file": lambda **kw: run_write(kw["path"], kw["content"]),
    "edit_file":  lambda **kw: run_edit(kw["path"], kw["old_text"],
                                        kw["new_text"]),
}
```

**Step 3.** In the loop, look up the handler by name. The loop body itself is unchanged from s01 -- only the dispatch line is new.

```python
for block in response.content:
    if block.type == "tool_use":
        handler = TOOL_HANDLERS.get(block.name)
        output = handler(**block.input) if handler \
            else f"Unknown tool: {block.name}"
        results.append({
            "type": "tool_result",
            "tool_use_id": block.id,
            "content": output,
        })
```

Add a tool = add a handler + add a schema entry. The loop never changes.

## What Changed From s01

| Component      | Before (s01)       | After (s02)                |
|----------------|--------------------|----------------------------|
| Tools          | 1 (bash only)      | 4 (bash, read, write, edit)|
| Dispatch       | Hardcoded bash call | `TOOL_HANDLERS` dict       |
| Path safety    | None               | `safe_path()` sandbox      |
| Agent loop     | Unchanged          | Unchanged                  |

## Try It

```sh
cd learn-claude-code
python agents/s02_tool_use.py
```

1. `Read the file requirements.txt`
2. `Create a file called greet.py with a greet(name) function`
3. `Edit greet.py to add a docstring to the function`
4. `Read greet.py to verify the edit worked`

## What You've Mastered

At this point, you can:

- Wire any new tool into the agent by adding one handler and one schema entry -- without touching the loop.
- Enforce path sandboxing so the model cannot read or write outside its workspace.
- Explain why a dispatch map scales better than an if/elif chain.

Keep the boundary clean: a tool schema is enough for now. You do not need policy layers, approval UIs, or plugin ecosystems yet. If you can add one new tool without rewriting the loop, you have the core pattern down.

## What's Next

Your agent can now read, write, and edit files safely. But what happens when you ask it to do a 10-step refactoring? It finishes steps 1 through 3 and then starts improvising because it forgot the rest. In s03, you will give the agent a session plan -- a structured todo list that keeps it on track through complex, multi-step tasks.

## Key Takeaway

> The loop should not care how a tool works internally. It only needs a reliable route from tool name to handler.


---

# s02a: Tool Control Plane

> **Deep Dive** -- Best read after s02 and before s07. It shows why tools become more than a simple lookup table.

### When to Read This

After you understand basic tool dispatch and before you add permissions.

---

> This bridge document answers another key question:
>
> **Why is a tool system more than a `tool_name -> handler` table?**

## Why This Document Exists

`s02` correctly teaches tool registration and dispatch first.

That is the right teaching move because you should first understand how the model turns intent into action.

But later the tool layer starts carrying much more responsibility:

- permission checks
- MCP routing
- notifications
- shared runtime state
- message access
- app state
- capability-specific restrictions

At that point, the tool layer is no longer just a function table.

It becomes a control plane (the coordination layer that decides *how* each tool call gets routed and executed, rather than performing the tool work itself).

## Terms First

### Tool control plane

The part of the system that decides **how** a tool call executes:

- where it runs
- whether it is allowed
- what state it can access
- whether it is native or external

### Execution context

The runtime environment visible to the tool:

- current working directory
- current permission mode
- current messages
- available MCP clients
- app state and notification channels

### Capability source

Not every tool comes from the same place. Common sources:

- native local tools
- MCP tools
- agent/team/task/worktree platform tools

## The Smallest Useful Mental Model

Think of the tool system as four layers:

```text
1. ToolSpec
   what the model sees

2. Tool Router
   where the request gets sent

3. ToolUseContext
   what environment the tool can access

4. Tool Result Envelope
   how the output returns to the main loop
```

The biggest step up is layer 3:

**high-completion systems are defined less by the dispatch table and more by the shared execution context.**

## Core Structures

### `ToolSpec`

```python
tool = {
    "name": "read_file",
    "description": "Read file contents.",
    "input_schema": {...},
}
```

### `ToolDispatchMap`

```python
handlers = {
    "read_file": read_file,
    "write_file": write_file,
    "bash": run_bash,
}
```

Necessary, but not sufficient.

### `ToolUseContext`

```python
tool_use_context = {
    "tools": handlers,
    "permission_context": {...},
    "mcp_clients": {},
    "messages": [...],
    "app_state": {...},
    "notifications": [],
    "cwd": "...",
}
```

The key point:

Tools stop receiving only input parameters.
They start receiving a shared runtime environment.

### `ToolResultEnvelope`

```python
result = {
    "ok": True,
    "content": "...",
    "is_error": False,
    "attachments": [],
}
```

This makes it easier to support:

- plain text output
- structured output
- error output
- attachment-like results

## Why `ToolUseContext` Eventually Becomes Necessary

Compare two systems.

### System A: dispatch map only

```python
output = handlers[tool_name](**tool_input)
```

Fine for a demo.

### System B: dispatch map plus execution context

```python
output = handlers[tool_name](tool_input, tool_use_context)
```

Closer to a real platform.

Why?

Because now:

- `bash` needs permissions
- `mcp__...` needs a client
- `agent` tools need execution environment setup
- `task_output` may need file writes plus notification write-back

## Minimal Implementation Path

### 1. Keep `ToolSpec` and handlers

Do not throw away the simple model.

### 2. Introduce one shared context object

```python
class ToolUseContext:
    def __init__(self):
        self.handlers = {}
        self.permission_context = {}
        self.mcp_clients = {}
        self.messages = []
        self.app_state = {}
        self.notifications = []
```

### 3. Let all handlers receive the context

```python
def run_tool(tool_name: str, tool_input: dict, ctx: ToolUseContext):
    handler = ctx.handlers[tool_name]
    return handler(tool_input, ctx)
```

### 4. Route by capability source

```python
def route_tool(tool_name: str, tool_input: dict, ctx: ToolUseContext):
    if tool_name.startswith("mcp__"):
        return run_mcp_tool(tool_name, tool_input, ctx)
    return run_native_tool(tool_name, tool_input, ctx)
```

## Key Takeaway

**A mature tool system is not just a name-to-function map. It is a shared execution plane that decides how model action intent becomes real work.**


---

# s02b: Tool Execution Runtime

> **Deep Dive** -- Best read after s02, when you want to understand concurrent tool execution.

### When to Read This

When you start wondering how multiple tool calls in one turn get executed safely.

---

> This bridge note is not about how tools are registered.
>
> It is about a deeper question:
>
> **When the model emits multiple tool calls, what rules decide concurrency, progress updates, result ordering, and context merging?**

## Why This Note Exists

`s02` correctly teaches:

- tool schema
- dispatch map
- `tool_result` flowing back into the loop

That is the right starting point.

But once the system grows, the hard questions move one layer deeper:

- which tools can run in parallel
- which tools should stay serial
- whether long-running tools should emit progress first
- whether concurrent results should write back in completion order or original order
- whether tool execution mutates shared context
- how concurrent mutations should merge safely

Those questions are not about registration anymore.

They belong to the **tool execution runtime** -- the set of rules the system follows once tool calls actually start executing, including scheduling, tracking, yielding progress, and merging results.

## Terms First

### What "tool execution runtime" means here

This is not the programming language runtime.

Here it means:

> the rules the system uses once tool calls actually start executing

Those rules include scheduling, tracking, yielding progress, and merging results.

### What "concurrency safe" means

A tool is concurrency safe when:

> it can run alongside similar work without corrupting shared state

Typical read-only tools are often safe:

- `read_file`
- some search tools
- query-only MCP tools

Many write tools are not:

- `write_file`
- `edit_file`
- tools that modify shared application state

### What a progress message is

A progress message means:

> the tool is not done yet, but the system already surfaces what it is doing

This keeps the user informed during long-running operations rather than leaving them staring at silence.

### What a context modifier is

Some tools do more than return text.

They also modify shared runtime context, for example:

- update a notification queue
- record active tools
- mutate app state

That shared-state mutation is called a context modifier.

## The Minimum Mental Model

Do not flatten tool execution into:

```text
tool_use -> handler -> result
```

A better mental model is:

```text
tool_use blocks
  ->
partition by concurrency safety
  ->
choose concurrent or serial execution
  ->
emit progress if needed
  ->
write results back in stable order
  ->
merge queued context modifiers
```

Two upgrades matter most:

- concurrency is not "all tools run together"
- shared context should not be mutated in random completion order

## Core Records

### 1. `ToolExecutionBatch`

A minimal teaching batch can look like:

```python
batch = {
    "is_concurrency_safe": True,
    "blocks": [tool_use_1, tool_use_2, tool_use_3],
}
```

The point is simple:

- tools are not always handled one by one
- the runtime groups them into execution batches first

### 2. `TrackedTool`

If you want a higher-completion execution layer, track each tool explicitly:

```python
tracked_tool = {
    "id": "toolu_01",
    "name": "read_file",
    "status": "queued",   # queued / executing / completed / yielded
    "is_concurrency_safe": True,
    "pending_progress": [],
    "results": [],
    "context_modifiers": [],
}
```

This makes the runtime able to answer:

- what is still waiting
- what is already running
- what has completed
- what has already yielded progress

### 3. `MessageUpdate`

Tool execution may produce more than one final result.

A minimal update can be treated as:

```python
update = {
    "message": maybe_message,
    "new_context": current_context,
}
```

In a larger runtime, updates usually split into two channels:

- messages that should surface upstream immediately
- context changes that should stay internal until merge time

### 4. Queued context modifiers

This is easy to skip, but it is one of the most important ideas.

In a concurrent batch, the safer strategy is not:

> "whichever tool finishes first mutates shared context first"

The safer strategy is:

> queue context modifiers first, then merge them later in the original tool order

For example:

```python
queued_context_modifiers = {
    "toolu_01": [modify_ctx_a],
    "toolu_02": [modify_ctx_b],
}
```

## Minimum Implementation Steps

### Step 1: classify concurrency safety

```python
def is_concurrency_safe(tool_name: str, tool_input: dict) -> bool:
    return tool_name in {"read_file", "search_files"}
```

### Step 2: partition before execution

```python
batches = partition_tool_calls(tool_uses)

for batch in batches:
    if batch["is_concurrency_safe"]:
        run_concurrently(batch["blocks"])
    else:
        run_serially(batch["blocks"])
```

### Step 3: let concurrent batches emit progress

```python
for update in run_concurrently(...):
    if update.get("message"):
        yield update["message"]
```

### Step 4: merge context in stable order

```python
queued_modifiers = {}

for update in concurrent_updates:
    if update.get("context_modifier"):
        queued_modifiers[update["tool_id"]].append(update["context_modifier"])

for tool in original_batch_order:
    for modifier in queued_modifiers.get(tool["id"], []):
        context = modifier(context)
```

This is one of the places where a teaching repo can still stay simple while remaining honest about the real system shape.

## The Picture You Should Hold

```text
tool_use blocks
  |
  v
partition by concurrency safety
  |
  +-- safe batch ----------> concurrent execution
  |                            |
  |                            +-- progress updates
  |                            +-- final results
  |                            +-- queued context modifiers
  |
  +-- exclusive batch -----> serial execution
                               |
                               +-- direct result
                               +-- direct context update
```

## Why This Matters More Than the Dispatch Map

In a tiny demo:

```python
handlers[tool_name](tool_input)
```

is enough.

But in a higher-completion agent, the hard part is no longer calling the right handler.

The hard part is:

- scheduling multiple tools safely
- keeping progress visible
- making result ordering stable
- preventing shared context from becoming nondeterministic

That is why tool execution runtime deserves its own deep dive.

## Key Takeaway

**Once the model emits multiple tool calls per turn, the hard problem shifts from dispatch to safe concurrent execution with stable result ordering.**


---

# s03: TodoWrite

`s01 > s02 > [ s03 ] > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How session planning keeps the model on track during multi-step tasks
- How a structured todo list with status tracking replaces fragile free-form plans
- How gentle reminders (nag injection) pull the model back when it drifts

Have you ever asked an AI to do a complex task and watched it lose track halfway through? You say "refactor this module: add type hints, docstrings, tests, and a main guard" and it nails the first two steps, then wanders off into something you never asked for. This is not a model intelligence problem -- it is a working memory problem. As tool results pile up in the conversation, the original plan fades. By step 4, the model has effectively forgotten steps 5 through 10. You need a way to keep the plan visible.

## The Problem

On multi-step tasks, the model drifts. It repeats work, skips steps, or improvises once the system prompt fades behind pages of tool output. The context window (the total amount of text the model can hold in working memory at once) is finite, and earlier instructions get pushed further away with every tool call. A 10-step refactoring might complete steps 1-3, then the model starts making things up because it simply cannot "see" steps 4-10 anymore.

## The Solution

Give the model a `todo` tool that maintains a structured checklist. Then inject gentle reminders when the model goes too long without updating its plan.

```
+--------+      +-------+      +---------+
|  User  | ---> |  LLM  | ---> | Tools   |
| prompt |      |       |      | + todo  |
+--------+      +---+---+      +----+----+
                    ^                |
                    |   tool_result  |
                    +----------------+
                          |
              +-----------+-----------+
              | TodoManager state     |
              | [ ] task A            |
              | [>] task B  <- doing  |
              | [x] task C            |
              +-----------------------+
                          |
              if rounds_since_todo >= 3:
                inject <reminder> into tool_result
```

## How It Works

**Step 1.** TodoManager stores items with statuses. The "one `in_progress` at a time" constraint forces the model to finish what it started before moving on.

```python
class TodoManager:
    def update(self, items: list) -> str:
        validated, in_progress_count = [], 0
        for item in items:
            status = item.get("status", "pending")
            if status == "in_progress":
                in_progress_count += 1
            validated.append({"id": item["id"], "text": item["text"],
                              "status": status})
        if in_progress_count > 1:
            raise ValueError("Only one task can be in_progress")
        self.items = validated
        return self.render()  # returns the checklist as formatted text
```

**Step 2.** The `todo` tool goes into the dispatch map like any other tool -- no special wiring needed, just one more entry in the dictionary you built in s02.

```python
TOOL_HANDLERS = {
    # ...base tools...
    "todo": lambda **kw: TODO.update(kw["items"]),
}
```

**Step 3.** A nag reminder injects a nudge if the model goes 3+ rounds without calling `todo`. This is the write-back trick (feeding tool results back into the conversation) used for a new purpose: the harness (the code wrapping around the model) quietly inserts a reminder into the results payload before it is appended to messages.

```python
if rounds_since_todo >= 3:
    results.insert(0, {
        "type": "text",
        "text": "<reminder>Update your todos.</reminder>",
    })
messages.append({"role": "user", "content": results})
```

The "one in_progress at a time" constraint forces sequential focus. The nag reminder creates accountability. Together, they keep the model working through its plan instead of drifting.

## What Changed From s02

| Component      | Before (s02)     | After (s03)                |
|----------------|------------------|----------------------------|
| Tools          | 4                | 5 (+todo)                  |
| Planning       | None             | TodoManager with statuses  |
| Nag injection  | None             | `<reminder>` after 3 rounds|
| Agent loop     | Simple dispatch  | + rounds_since_todo counter|

## Try It

```sh
cd learn-claude-code
python agents/s03_todo_write.py
```

1. `Refactor the file hello.py: add type hints, docstrings, and a main guard`
2. `Create a Python package with __init__.py, utils.py, and tests/test_utils.py`
3. `Review all Python files and fix any style issues`

Watch the model create a plan, work through it step by step, and check off items as it goes. If it forgets to update the plan for a few rounds, you will see the `<reminder>` nudge appear in the conversation.

## What You've Mastered

At this point, you can:

- Add session planning to any agent by dropping a `todo` tool into the dispatch map.
- Enforce sequential focus with the "one in_progress at a time" constraint.
- Use nag injection to pull the model back on track when it drifts.
- Explain why structured state beats free-form prose for multi-step plans.

Keep three boundaries in mind: `todo` here means "plan for the current conversation", not a durable task database. The tiny schema `{id, text, status}` is enough. A direct reminder is enough -- you do not need a sophisticated planning UI yet.

## What's Next

Your agent can now plan its work and stay on track. But every file it reads, every bash output it produces -- all of it stays in the conversation forever, eating into the context window. A five-file investigation might burn thousands of tokens (roughly word-sized pieces -- a 1000-line file uses about 4000 tokens) that the parent conversation never needs again. In s04, you will learn how to spin up subagents with fresh, isolated context -- so the parent stays clean and the model stays sharp.

## Key Takeaway

> Once the plan lives in structured state instead of free-form prose, the agent drifts much less.


---

# s04: Subagents

`s01 > s02 > s03 > [ s04 ] > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn
- Why exploring a side question can pollute the parent agent's context
- How a subagent gets a fresh, empty message history
- How only a short summary travels back to the parent
- Why the child's full message history is discarded after use

Imagine you ask your agent "What testing framework does this project use?" To answer, it reads five files, parses config blocks, and compares import statements. All of that exploration is useful for a moment -- but once the answer is "pytest," you really don't want those five file dumps sitting in the conversation forever. Every future API call now carries that dead weight, burning tokens and distracting the model. You need a way to ask a side question in a clean room and bring back only the answer.

## The Problem

As the agent works, its `messages` array grows. Every file read, every bash output stays in context permanently. A simple question like "what testing framework is this?" might require reading five files, but the parent only needs one word back: "pytest." Without isolation, those intermediate artifacts stay in context for the rest of the session, wasting tokens on every subsequent API call and muddying the model's attention. The longer a session runs, the worse this gets -- context fills with exploration debris that has nothing to do with the current task.

## The Solution

The parent agent delegates side tasks to a child agent that starts with an empty `messages=[]`. The child does all the messy exploration, then only its final text summary travels back. The child's full history is discarded.

```
Parent agent                     Subagent
+------------------+             +------------------+
| messages=[...]   |             | messages=[]      | <-- fresh
|                  |  dispatch   |                  |
| tool: task       | ----------> | while tool_use:  |
|   prompt="..."   |             |   call tools     |
|                  |  summary    |   append results |
|   result = "..." | <---------- | return last text |
+------------------+             +------------------+

Parent context stays clean. Subagent context is discarded.
```

## How It Works

**Step 1.** The parent gets a `task` tool that the child does not. This prevents recursive spawning -- a child cannot create its own children.

```python
PARENT_TOOLS = CHILD_TOOLS + [
    {"name": "task",
     "description": "Spawn a subagent with fresh context.",
     "input_schema": {
         "type": "object",
         "properties": {"prompt": {"type": "string"}},
         "required": ["prompt"],
     }},
]
```

**Step 2.** The subagent starts with `messages=[]` and runs its own agent loop. Only the final text block returns to the parent as a `tool_result`.

```python
def run_subagent(prompt: str) -> str:
    sub_messages = [{"role": "user", "content": prompt}]
    for _ in range(30):  # safety limit
        response = client.messages.create(
            model=MODEL, system=SUBAGENT_SYSTEM,
            messages=sub_messages,
            tools=CHILD_TOOLS, max_tokens=8000,
        )
        sub_messages.append({"role": "assistant",
                             "content": response.content})
        if response.stop_reason != "tool_use":
            break
        results = []
        for block in response.content:
            if block.type == "tool_use":
                handler = TOOL_HANDLERS.get(block.name)
                output = handler(**block.input)
                results.append({"type": "tool_result",
                    "tool_use_id": block.id,
                    "content": str(output)[:50000]})
        sub_messages.append({"role": "user", "content": results})
    # Extract only the final text -- everything else is thrown away
    return "".join(
        b.text for b in response.content if hasattr(b, "text")
    ) or "(no summary)"
```

The child's entire message history (possibly 30+ tool calls worth of file reads and bash outputs) is discarded the moment `run_subagent` returns. The parent receives a one-paragraph summary as a normal `tool_result`, keeping its own context clean.

## What Changed From s03

| Component      | Before (s03)     | After (s04)               |
|----------------|------------------|---------------------------|
| Tools          | 5                | 5 (base) + task (parent)  |
| Context        | Single shared    | Parent + child isolation  |
| Subagent       | None             | `run_subagent()` function |
| Return value   | N/A              | Summary text only         |

## Try It

```sh
cd learn-claude-code
python agents/s04_subagent.py
```

1. `Use a subtask to find what testing framework this project uses`
2. `Delegate: read all .py files and summarize what each one does`
3. `Use a task to create a new module, then verify it from here`

## What You've Mastered

At this point, you can:

- Explain why a subagent is primarily a **context boundary**, not a process trick
- Spawn a one-shot child agent with a fresh `messages=[]`
- Return only a summary to the parent, discarding all intermediate exploration
- Decide which tools the child should and should not have access to

You don't need long-lived workers, resumable sessions, or worktree isolation yet. The core idea is simple: give the subtask a clean workspace in memory, then bring back only the answer the parent still needs.

## What's Next

So far you've learned to keep context clean by isolating side tasks. But what about the knowledge the agent carries in the first place? In s05, you'll see how to avoid bloating the system prompt with domain expertise the model might never use -- loading skills on demand instead of upfront.

## Key Takeaway

> A subagent is a disposable scratch pad: fresh context in, short summary out, everything else discarded.


---

# s05: Skills

`s01 > s02 > s03 > s04 > [ s05 ] > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn
- Why stuffing all domain knowledge into the system prompt wastes tokens
- The two-layer loading pattern: cheap names up front, expensive bodies on demand
- How frontmatter (YAML metadata at the top of a file) gives each skill a name and description
- How the model decides for itself which skill to load and when

You don't memorize every recipe in every cookbook you own. You know which shelf each cookbook sits on, and you pull one down only when you're actually cooking that dish. An agent's domain knowledge works the same way. You might have expertise files for git workflows, testing patterns, code review checklists, PDF processing -- dozens of topics. Loading all of them into the system prompt on every request is like reading every cookbook cover to cover before cracking a single egg. Most of that knowledge is irrelevant to any given task.

## The Problem

You want your agent to follow domain-specific workflows: git conventions, testing best practices, code review checklists. The naive approach is to put everything in the system prompt. But 10 skills at 2,000 tokens each means 20,000 tokens of instructions on every API call -- most of which have nothing to do with the current question. You pay for those tokens every turn, and worse, all that irrelevant text competes for the model's attention with the content that actually matters.

## The Solution

Split knowledge into two layers. Layer 1 lives in the system prompt and is cheap: just skill names and one-line descriptions (~100 tokens per skill). Layer 2 is the full skill body, loaded on demand through a tool call only when the model decides it needs that knowledge.

```
System prompt (Layer 1 -- always present):
+--------------------------------------+
| You are a coding agent.              |
| Skills available:                    |
|   - git: Git workflow helpers        |  ~100 tokens/skill
|   - test: Testing best practices     |
+--------------------------------------+

When model calls load_skill("git"):
+--------------------------------------+
| tool_result (Layer 2 -- on demand):  |
| <skill name="git">                   |
|   Full git workflow instructions...  |  ~2000 tokens
|   Step 1: ...                        |
| </skill>                             |
+--------------------------------------+
```

## How It Works

**Step 1.** Each skill is a directory containing a `SKILL.md` file. The file starts with YAML frontmatter (a metadata block delimited by `---` lines) that declares the skill's name and description, followed by the full instruction body.

```
skills/
  pdf/
    SKILL.md       # ---\n name: pdf\n description: Process PDF files\n ---\n ...
  code-review/
    SKILL.md       # ---\n name: code-review\n description: Review code\n ---\n ...
```

**Step 2.** `SkillLoader` scans for all `SKILL.md` files at startup. It parses the frontmatter to extract names and descriptions, and stores the full body for later retrieval.

```python
class SkillLoader:
    def __init__(self, skills_dir: Path):
        self.skills = {}
        for f in sorted(skills_dir.rglob("SKILL.md")):
            text = f.read_text()
            meta, body = self._parse_frontmatter(text)
            # Use the frontmatter name, or fall back to the directory name
            name = meta.get("name", f.parent.name)
            self.skills[name] = {"meta": meta, "body": body}

    def get_descriptions(self) -> str:
        """Layer 1: cheap one-liners for the system prompt."""
        lines = []
        for name, skill in self.skills.items():
            desc = skill["meta"].get("description", "")
            lines.append(f"  - {name}: {desc}")
        return "\n".join(lines)

    def get_content(self, name: str) -> str:
        """Layer 2: full body, returned as a tool_result."""
        skill = self.skills.get(name)
        if not skill:
            return f"Error: Unknown skill '{name}'."
        return f"<skill name=\"{name}\">\n{skill['body']}\n</skill>"
```

**Step 3.** Layer 1 goes into the system prompt so the model always knows what skills exist. Layer 2 is wired up as a normal tool handler -- the model calls `load_skill` when it decides it needs the full instructions.

```python
SYSTEM = f"""You are a coding agent at {WORKDIR}.
Skills available:
{SKILL_LOADER.get_descriptions()}"""

TOOL_HANDLERS = {
    # ...base tools...
    "load_skill": lambda **kw: SKILL_LOADER.get_content(kw["name"]),
}
```

The model learns what skills exist (cheap, ~100 tokens each) and loads them only when relevant (expensive, ~2000 tokens each). On a typical turn, only one skill is loaded instead of all ten.

## What Changed From s04

| Component      | Before (s04)     | After (s05)                |
|----------------|------------------|----------------------------|
| Tools          | 5 (base + task)  | 5 (base + load_skill)      |
| System prompt  | Static string    | + skill descriptions       |
| Knowledge      | None             | skills/\*/SKILL.md files   |
| Injection      | None             | Two-layer (system + result)|

## Try It

```sh
cd learn-claude-code
python agents/s05_skill_loading.py
```

1. `What skills are available?`
2. `Load the agent-builder skill and follow its instructions`
3. `I need to do a code review -- load the relevant skill first`
4. `Build an MCP server using the mcp-builder skill`

## What You've Mastered

At this point, you can:

- Explain why "list first, load later" beats stuffing everything into the system prompt
- Write a `SKILL.md` with YAML frontmatter that a `SkillLoader` can discover
- Wire up two-layer loading: cheap descriptions in the system prompt, full bodies via `tool_result`
- Let the model decide for itself when domain knowledge is worth loading

You don't need skill ranking systems, multi-provider merging, parameterized templates, or recovery-time restoration rules. The core pattern is simple: advertise cheaply, load on demand.

## What's Next

You now know how to keep knowledge out of context until it's needed. But what happens when context grows large anyway -- after dozens of turns of real work? In s06, you'll learn how to compress a long conversation down to its essentials so the agent can keep working without hitting token limits.

## Key Takeaway

> Advertise skill names cheaply in the system prompt; load the full body through a tool call only when the model actually needs it.


---

# s06: Context Compact

`s01 > s02 > s03 > s04 > s05 > [ s06 ] > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- Why long sessions inevitably run out of context space, and what happens when they do
- A four-lever compression strategy: persisted output, micro-compact, auto-compact, and manual compact
- How to move detail out of active memory without losing it
- How to keep a session alive indefinitely by summarizing and continuing

Your agent from s05 is capable. It reads files, runs commands, edits code, and delegates subtasks. But try something ambitious -- ask it to refactor a module that touches 30 files. After reading all of them and running 20 shell commands, you will notice the responses get worse. The model starts forgetting what it already read. It repeats work. Eventually the API rejects your request entirely. You have hit the context window limit, and without a plan for that, your agent is stuck.

## The Problem

Every API call to the model includes the entire conversation so far: every user message, every assistant response, every tool call and its result. The model's context window (the total amount of text it can hold in working memory at once) is finite. A single `read_file` on a 1000-line source file costs roughly 4,000 tokens (roughly word-sized pieces -- a 1,000-line file uses about 4,000 tokens). Read 30 files and run 20 bash commands, and you have burned through 100,000+ tokens. The context is full, but the work is only half done.

The naive fix -- just truncating old messages -- throws away information the agent might need later. A smarter approach compresses strategically: keep the important bits, move the bulky details to disk, and summarize when the conversation gets too long. That is what this chapter builds.

## The Solution

We use four levers, each working at a different stage of the pipeline, from output-time filtering to full conversation summarization.

```
Every tool call:
+------------------+
| Tool call result |
+------------------+
        |
        v
[Lever 0: persisted-output]     (at tool execution time)
  Large outputs (>50KB, bash >30KB) are written to disk
  and replaced with a <persisted-output> preview marker.
        |
        v
[Lever 1: micro_compact]        (silent, every turn)
  Replace tool_result > 3 turns old
  with "[Previous: used {tool_name}]"
  (preserves read_file results as reference material)
        |
        v
[Check: tokens > 50000?]
   |               |
   no              yes
   |               |
   v               v
continue    [Lever 2: auto_compact]
              Save transcript to .transcripts/
              LLM summarizes conversation.
              Replace all messages with [summary].
                    |
                    v
            [Lever 3: compact tool]
              Model calls compact explicitly.
              Same summarization as auto_compact.
```

## How It Works

### Step 1: Lever 0 -- Persisted Output

The first line of defense runs at tool execution time, before a result even enters the conversation. When a tool result exceeds a size threshold, we write the full output to disk and replace it with a short preview. This prevents a single giant command output from consuming half the context window.

```python
PERSIST_OUTPUT_TRIGGER_CHARS_DEFAULT = 50000
PERSIST_OUTPUT_TRIGGER_CHARS_BASH = 30000   # bash uses a lower threshold

def maybe_persist_output(tool_use_id, output, trigger_chars=None):
    if len(output) <= trigger:
        return output                                    # small enough -- keep inline
    stored_path = _persist_tool_result(tool_use_id, output)
    return _build_persisted_marker(stored_path, output)  # swap in a compact preview
    # Returns: <persisted-output>
    #   Output too large (48.8KB). Full output saved to: .task_outputs/tool-results/abc123.txt
    #   Preview (first 2.0KB):
    #   ... first 2000 chars ...
    # </persisted-output>
```

The model can later `read_file` the stored path to access the full content if needed. Nothing is lost -- the detail just lives on disk instead of in the conversation.

### Step 2: Lever 1 -- Micro-Compact

Before each LLM call, we scan for old tool results and replace them with one-line placeholders. This is invisible to the user and runs every turn. The key subtlety: we preserve `read_file` results because those serve as reference material the model often needs to look back at.

```python
PRESERVE_RESULT_TOOLS = {"read_file"}

def micro_compact(messages: list) -> list:
    tool_results = [...]  # collect all tool_result entries
    if len(tool_results) <= KEEP_RECENT:
        return messages                                  # not enough results to compact yet
    for part in tool_results[:-KEEP_RECENT]:
        if tool_name in PRESERVE_RESULT_TOOLS:
            continue   # keep reference material
        part["content"] = f"[Previous: used {tool_name}]"  # replace with short placeholder
    return messages
```

### Step 3: Lever 2 -- Auto-Compact

When micro-compaction is not enough and the token count crosses a threshold, the harness takes a bigger step: it saves the full transcript to disk for recovery, asks the LLM to summarize the entire conversation, and then replaces all messages with that summary. The agent continues from the summary as if nothing happened.

```python
def auto_compact(messages: list) -> list:
    # Save transcript for recovery
    transcript_path = TRANSCRIPT_DIR / f"transcript_{int(time.time())}.jsonl"
    with open(transcript_path, "w") as f:
        for msg in messages:
            f.write(json.dumps(msg, default=str) + "\n")
    # LLM summarizes
    response = client.messages.create(
        model=MODEL,
        messages=[{"role": "user", "content":
            "Summarize this conversation for continuity..."
            + json.dumps(messages, default=str)[:80000]}],  # cap at 80K chars for the summary call
        max_tokens=2000,
    )
    return [
        {"role": "user", "content": f"[Compressed]\n\n{response.content[0].text}"},
    ]
```

### Step 4: Lever 3 -- Manual Compact

The `compact` tool lets the model itself trigger summarization on demand. It uses exactly the same mechanism as auto-compact. The difference is who decides: auto-compact fires on a threshold, manual compact fires when the agent judges it is the right time to compress.

### Step 5: Integration in the Agent Loop

All four levers compose naturally inside the main loop:

```python
def agent_loop(messages: list):
    while True:
        micro_compact(messages)                        # Lever 1
        if estimate_tokens(messages) > THRESHOLD:
            messages[:] = auto_compact(messages)       # Lever 2
        response = client.messages.create(...)
        # ... tool execution with persisted-output ... # Lever 0
        if manual_compact:
            messages[:] = auto_compact(messages)       # Lever 3
```

Transcripts preserve full history on disk. Large outputs are saved to `.task_outputs/tool-results/`. Nothing is truly lost -- just moved out of active context.

## What Changed From s05

| Component         | Before (s05)     | After (s06)                |
|-------------------|------------------|----------------------------|
| Tools             | 5                | 5 (base + compact)         |
| Context mgmt      | None             | Four-lever compression     |
| Persisted-output  | None             | Large outputs -> disk + preview |
| Micro-compact     | None             | Old results -> placeholders|
| Auto-compact      | None             | Token threshold trigger    |
| Transcripts       | None             | Saved to .transcripts/     |

## Try It

```sh
cd learn-claude-code
python agents/s06_context_compact.py
```

1. `Read every Python file in the agents/ directory one by one` (watch micro-compact replace old results)
2. `Keep reading files until compression triggers automatically`
3. `Use the compact tool to manually compress the conversation`

## What You've Mastered

At this point, you can:

- Explain why a long agent session degrades and eventually fails without compression
- Intercept oversized tool outputs before they enter the context window
- Silently replace stale tool results with lightweight placeholders each turn
- Trigger a full conversation summarization -- automatically on a threshold or manually via a tool call
- Preserve full transcripts on disk so nothing is permanently lost

## Stage 1 Complete

You now have a complete single-agent system. Starting from a bare API call in s01, you have built up tool use, structured planning, sub-agent delegation, dynamic skill loading, and context compression. Your agent can read, write, execute, plan, delegate, and work indefinitely without running out of memory. That is a real coding agent.

Before moving on, consider going back to s01 and rebuilding the whole stack from scratch without looking at the code. If you can write all six layers from memory, you truly own the ideas -- not just the implementation.

Stage 2 begins with s07 and hardens this foundation. You will add permission controls, hook systems, persistent memory, error recovery, and more. The single agent you built here becomes the kernel that everything else wraps around.

## Key Takeaway

> Compaction is not deleting history -- it is relocating detail so the agent can keep working.


---

# s07: Permission System

`s01 > s02 > s03 > s04 > s05 > s06 > [ s07 ] > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- A four-stage permission pipeline that every tool call must pass through before execution
- Three permission modes that control how aggressively the agent auto-approves actions
- How deny and allow rules use pattern matching to create a first-match-wins policy
- Interactive approval with an "always" option that writes permanent allow rules at runtime

Your agent from s06 is capable and long-lived. It reads files, writes code, runs shell commands, delegates subtasks, and compresses its own context to keep going. But there is no safety catch. Every tool call the model proposes goes straight to execution. Ask it to delete a directory and it will -- no questions asked. Before you give this agent access to anything that matters, you need a gate between "the model wants to do X" and "the system actually does X."

## The Problem

Imagine your agent is helping refactor a codebase. It reads a few files, proposes some edits, and then decides to run `rm -rf /tmp/old_build` to clean up. Except the model hallucinated the path -- the real directory is your home folder. Or it decides to `sudo` something because the model has seen that pattern in training data. Without a permission layer, intent becomes execution instantly. There is no moment where the system can say "wait, that looks dangerous" or where you can say "no, do not do that." The agent needs a checkpoint -- a pipeline (a sequence of stages that every request passes through) between what the model asks for and what actually happens.

## The Solution

Every tool call now passes through a four-stage permission pipeline before execution. The stages run in order, and the first one that produces a definitive answer wins.

```
tool_call from LLM
     |
     v
[1. Deny rules]     -- blocklist: always block these
     |
     v
[2. Mode check]     -- plan mode? auto mode? default?
     |
     v
[3. Allow rules]    -- allowlist: always allow these
     |
     v
[4. Ask user]       -- interactive y/n/always prompt
     |
     v
execute (or reject)
```

## Read Together

- If you start blurring "the model proposed an action" with "the system actually executed an action," you might find it helpful to revisit [`s00a-query-control-plane.md`](./s00a-query-control-plane.md).
- If you are not yet clear on why tool requests should not drop straight into handlers, keeping [`s02a-tool-control-plane.md`](./s02a-tool-control-plane.md) open beside this chapter may help.
- If `PermissionRule`, `PermissionDecision`, and `tool_result` start to collapse into one vague idea, [`data-structures.md`](./data-structures.md) can reset them.

## How It Works

**Step 1.** Define three permission modes. Each mode changes how the pipeline treats tool calls that do not match any explicit rule. "Default" mode is the safest -- it asks you about everything. "Plan" mode blocks all writes outright, useful when you want the agent to explore without touching anything. "Auto" mode lets reads through silently and only asks about writes, good for fast exploration.

| Mode | Behavior | Use Case |
|------|----------|----------|
| `default` | Ask user for every unmatched tool call | Normal interactive use |
| `plan` | Block all writes, allow reads | Planning/review mode |
| `auto` | Auto-allow reads, ask for writes | Fast exploration mode |

**Step 2.** Set up deny and allow rules with pattern matching. Rules are checked in order -- first match wins. Deny rules catch dangerous patterns that should never execute, regardless of mode. Allow rules let known-safe operations pass without asking.

```python
rules = [
    # Always deny dangerous patterns
    {"tool": "bash", "content": "rm -rf /", "behavior": "deny"},
    {"tool": "bash", "content": "sudo *",   "behavior": "deny"},
    # Allow reading anything
    {"tool": "read_file", "path": "*", "behavior": "allow"},
]
```

When the user answers "always" at the interactive prompt, a permanent allow rule is added at runtime.

**Step 3.** Implement the four-stage check. This is the core of the permission system. Notice that deny rules run first and cannot be bypassed -- this is intentional. No matter what mode you are in or what allow rules exist, a deny rule always wins.

```python
def check(self, tool_name, tool_input):
    # Step 1: Deny rules (bypass-immune, always checked first)
    for rule in self.rules:
        if rule["behavior"] == "deny" and self._matches(rule, ...):
            return {"behavior": "deny", "reason": "..."}

    # Step 2: Mode-based decisions
    if self.mode == "plan" and tool_name in WRITE_TOOLS:
        return {"behavior": "deny", "reason": "Plan mode: writes blocked"}
    if self.mode == "auto" and tool_name in READ_ONLY_TOOLS:
        return {"behavior": "allow", "reason": "Auto: read-only approved"}

    # Step 3: Allow rules
    for rule in self.rules:
        if rule["behavior"] == "allow" and self._matches(rule, ...):
            return {"behavior": "allow", "reason": "..."}

    # Step 4: Fall through to ask user
    return {"behavior": "ask", "reason": "..."}
```

**Step 4.** Integrate the permission check into the agent loop. Every tool call now goes through the pipeline before execution. The result is one of three outcomes: denied (with a reason), allowed (silently), or asked (interactively).

```python
for block in response.content:
    if block.type == "tool_use":
        decision = perms.check(block.name, block.input)

        if decision["behavior"] == "deny":
            output = f"Permission denied: {decision['reason']}"
        elif decision["behavior"] == "ask":
            if perms.ask_user(block.name, block.input):
                output = handler(**block.input)
            else:
                output = "Permission denied by user"
        else:  # allow
            output = handler(**block.input)

        results.append({"type": "tool_result", ...})
```

**Step 5.** Add denial tracking as a simple circuit breaker. The `PermissionManager` tracks consecutive denials. After 3 in a row, it suggests switching to plan mode -- this prevents the agent from repeatedly hitting the same wall and wasting turns.

## What Changed From s06

| Component | Before (s06) | After (s07) |
|-----------|-------------|-------------|
| Safety | None | 4-stage permission pipeline |
| Modes | None | 3 modes: default, plan, auto |
| Rules | None | Deny/allow rules with pattern matching |
| User control | None | Interactive approval with "always" option |
| Denial tracking | None | Circuit breaker after 3 consecutive denials |

## Try It

```sh
cd learn-claude-code
python agents/s07_permission_system.py
```

1. Start in `default` mode -- every write tool asks for approval
2. Try `plan` mode -- all writes are blocked, reads pass through
3. Try `auto` mode -- reads auto-approved, writes still ask
4. Answer "always" to permanently allow a tool
5. Type `/mode plan` to switch modes at runtime
6. Type `/rules` to inspect current rule set

## What You've Mastered

At this point, you can:

- Explain why model intent must pass through a decision pipeline before it becomes execution
- Build a four-stage permission check: deny, mode, allow, ask
- Configure three permission modes that give you different safety/speed tradeoffs
- Add rules dynamically at runtime when a user answers "always"
- Implement a simple circuit breaker that catches repeated denial loops

## What's Next

Your permission system controls what the agent is allowed to do, but it lives entirely inside the agent's own code. What if you want to extend behavior -- add logging, auditing, or custom validation -- without modifying the agent loop at all? That is what s08 introduces: a hook system that lets external shell scripts observe and influence every tool call.

## Key Takeaway

> Safety is a pipeline, not a boolean -- deny first, then consider mode, then check allow rules, then ask the user.


---

# s08: Hook System

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > [ s08 ] > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- Three lifecycle events that let external code observe and influence the agent loop
- How shell-based hooks run as subprocesses with full context about the current tool call
- The exit code protocol: 0 means continue, 1 means block, 2 means inject a message
- How to configure hooks in an external JSON file so you never touch the main loop code

Your agent from s07 has a permission system that controls what it is allowed to do. But permissions are a yes/no gate -- they do not let you add new behavior. Suppose you want every bash command to be logged to an audit file, or you want a linter to run automatically after every file write, or you want a custom security scanner to inspect tool inputs before they execute. You could add if/else branches inside the main loop for each of these, but that turns your clean loop into a tangle of special cases. What you really want is a way to extend the agent's behavior from the outside, without modifying the loop itself.

## The Problem

You are running your agent in a team environment. Different teams want different behaviors: the security team wants to scan every bash command, the QA team wants to auto-run tests after file edits, and the ops team wants an audit trail of every tool call. If each of these requires code changes to the agent loop, you end up with a mess of conditionals that nobody can maintain. Worse, every new requirement means redeploying the agent. You need a way for teams to plug in their own logic at well-defined moments -- without touching the core code.

## The Solution

The agent loop exposes three fixed extension points (lifecycle events). At each point, it runs external shell commands called hooks. Each hook communicates its intent through its exit code: continue silently, block the operation, or inject a message into the conversation.

```
tool_call from LLM
     |
     v
[PreToolUse hooks]
     |  exit 0 -> continue
     |  exit 1 -> block tool, return stderr as error
     |  exit 2 -> inject stderr into conversation, continue
     |
     v
[execute tool]
     |
     v
[PostToolUse hooks]
     |  exit 0 -> continue
     |  exit 2 -> append stderr to result
     |
     v
return result
```

## Read Together

- If you still picture hooks as "more if/else branches inside the main loop," you might find it helpful to revisit [`s02a-tool-control-plane.md`](./s02a-tool-control-plane.md) first.
- If the main loop, the tool handler, and hook side effects start to blur together, [`entity-map.md`](./entity-map.md) can help you separate who advances core state and who only watches from the side.
- If you plan to continue into prompt assembly, recovery, or teams, keeping [`s00e-reference-module-map.md`](./s00e-reference-module-map.md) nearby is useful because this "core loop plus sidecar extension" pattern returns repeatedly.

## How It Works

**Step 1.** Define three lifecycle events. `SessionStart` fires once when the agent starts up -- useful for initialization, logging, or environment checks. `PreToolUse` fires before every tool call and is the only event that can block execution. `PostToolUse` fires after every tool call and can annotate the result but cannot undo it.

| Event | When | Can Block? |
|-------|------|-----------|
| `SessionStart` | Once at session start | No |
| `PreToolUse` | Before each tool call | Yes (exit 1) |
| `PostToolUse` | After each tool call | No |

**Step 2.** Configure hooks in an external `.hooks.json` file at the workspace root. Each hook specifies a shell command to run. An optional `matcher` field filters by tool name -- without a matcher, the hook fires for every tool.

```json
{
  "hooks": {
    "PreToolUse": [
      {"matcher": "bash", "command": "echo 'Checking bash command...'"},
      {"matcher": "write_file", "command": "/path/to/lint-check.sh"}
    ],
    "PostToolUse": [
      {"command": "echo 'Tool finished'"}
    ],
    "SessionStart": [
      {"command": "echo 'Session started at $(date)'"}
    ]
  }
}
```

**Step 3.** Implement the exit code protocol. This is the heart of the hook system -- three exit codes, three meanings. The protocol is deliberately simple so that any language or script can participate. Write your hook in bash, Python, Ruby, whatever -- as long as it exits with the right code.

| Exit Code | Meaning | PreToolUse | PostToolUse |
|-----------|---------|-----------|------------|
| 0 | Success | Continue to execute tool | Continue normally |
| 1 | Block | Tool NOT executed, stderr returned as error | Warning logged |
| 2 | Inject | stderr injected as message, tool still executes | stderr appended to result |

**Step 4.** Pass context to hooks via environment variables. Hooks need to know what is happening -- which event triggered them, which tool is being called, and what the input looks like. For `PostToolUse` hooks, the tool output is also available.

```
HOOK_EVENT=PreToolUse
HOOK_TOOL_NAME=bash
HOOK_TOOL_INPUT={"command": "npm test"}
HOOK_TOOL_OUTPUT=...  (PostToolUse only)
```

**Step 5.** Integrate hooks into the agent loop. The integration is clean: run pre-hooks before execution, check if any blocked, execute the tool, run post-hooks, and collect any injected messages. The loop still owns control flow -- hooks only observe, block, or annotate at named moments.

```python
# Before tool execution
pre_result = hooks.run_hooks("PreToolUse", ctx)
if pre_result["blocked"]:
    output = f"Blocked by hook: {pre_result['block_reason']}"
    continue

# Execute tool
output = handler(**tool_input)

# After tool execution
post_result = hooks.run_hooks("PostToolUse", ctx)
for msg in post_result["messages"]:
    output += f"\n[Hook note]: {msg}"
```

## What Changed From s07

| Component | Before (s07) | After (s08) |
|-----------|-------------|-------------|
| Extensibility | None | Shell-based hook system |
| Events | None | PreToolUse, PostToolUse, SessionStart |
| Control flow | Permission pipeline only | Permission + hooks |
| Configuration | In-code rules | External `.hooks.json` file |

## Try It

```sh
cd learn-claude-code
# Create a hook config
cat > .hooks.json << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {"matcher": "bash", "command": "echo 'Auditing bash command' >&2; exit 0"}
    ],
    "SessionStart": [
      {"command": "echo 'Agent session started'"}
    ]
  }
}
EOF
python agents/s08_hook_system.py
```

1. Watch SessionStart hook fire at startup
2. Ask the agent to run a bash command -- see PreToolUse hook fire
3. Create a blocking hook (exit 1) and watch it prevent tool execution
4. Create an injecting hook (exit 2) and watch it add messages to the conversation

## What You've Mastered

At this point, you can:

- Explain why extension points are better than in-loop conditionals for adding new behavior
- Define lifecycle events at the right moments in the agent loop
- Write shell hooks that communicate intent through a three-code exit protocol
- Configure hooks externally so different teams can customize behavior without touching the agent code
- Maintain the boundary: the loop owns control flow, the handler owns execution, hooks only observe, block, or annotate

## What's Next

Your agent can now execute tools safely (s07) and be extended without code changes (s08). But it still has amnesia -- every new session starts from zero. The user's preferences, corrections, and project context are forgotten the moment the session ends. In s09, you will build a memory system that lets the agent carry durable facts across sessions.

## Key Takeaway

> The main loop can expose fixed extension points without giving up ownership of control flow -- hooks observe, block, or annotate, but the loop still decides what happens next.


---

# s09: Memory System

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > [ s09 ] > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- Four memory categories that cover what is worth remembering: user preferences, feedback, project facts, and references
- How YAML frontmatter files give each memory record a name, type, and description
- What should NOT go into memory -- and why getting this boundary wrong is the most common mistake
- The difference between memory, tasks, plans, and CLAUDE.md

Your agent from s08 is powerful and extensible. It can execute tools safely, be extended through hooks, and work for long sessions thanks to context compression. But it has amnesia. Every time you start a new session, the agent meets you for the first time. It does not remember that you prefer pnpm over npm, that you told it three times to stop modifying test snapshots, or that the legacy directory cannot be deleted because deployment depends on it. You end up repeating yourself every session. The fix is a small, durable memory store -- not a dump of everything the agent has seen, but a curated set of facts that should still matter next time.

## The Problem

Without memory, a new session starts from zero. The agent keeps forgetting things like long-term user preferences, corrections you have repeated multiple times, project constraints that are not obvious from the code itself, and external references the project depends on. The result is an agent that always feels like it is meeting you for the first time. You waste time re-establishing context that should have been saved once and loaded automatically.

## The Solution

A small file-based memory store saves durable facts as individual markdown files with YAML frontmatter (a metadata block at the top of each file, delimited by `---` lines). At the start of each session, relevant memories are loaded and injected into the model's context.

```text
conversation
   |
   | durable fact appears
   v
save_memory
   |
   v
.memory/
  ├── MEMORY.md
  ├── prefer_pnpm.md
  ├── ask_before_codegen.md
  └── incident_dashboard.md
   |
   v
next session loads relevant entries
```

## Read Together

- If you still think memory is just "a longer context window," you might find it helpful to revisit [`s06-context-compact.md`](./s06-context-compact.md) and re-separate compaction from durable memory.
- If `messages[]`, summary blocks, and the memory store start to blend together, keeping [`data-structures.md`](./data-structures.md) open while reading can help.
- If you are about to continue into s10, reading [`s10a-message-prompt-pipeline.md`](./s10a-message-prompt-pipeline.md) alongside this chapter is useful because memory matters most when it re-enters the next model input.

## How It Works

**Step 1.** Define four memory categories. These are the types of facts worth keeping across sessions. Each category has a clear purpose -- if a fact does not fit one of these, it probably should not be in memory.

### 1. `user` -- Stable user preferences

Examples: prefers `pnpm`, wants concise answers, dislikes large refactors without a plan.

### 2. `feedback` -- Corrections the user wants enforced

Examples: "do not change test snapshots unless I ask", "ask before modifying generated files."

### 3. `project` -- Durable project facts not obvious from the repo

Examples: "this old directory still cannot be deleted because deployment depends on it", "this service exists because of a compliance requirement, not technical preference."

### 4. `reference` -- Pointers to external resources

Examples: incident board URL, monitoring dashboard location, spec document location.

```python
MEMORY_TYPES = ("user", "feedback", "project", "reference")
```

**Step 2.** Save one record per file using frontmatter. Each memory is a markdown file with YAML frontmatter that tells the system what the memory is called, what kind it is, and what it is roughly about.

```md
---
name: prefer_pnpm
description: User prefers pnpm over npm
type: user
---
The user explicitly prefers pnpm for package management commands.
```

```python
def save_memory(name, description, mem_type, content):
    path = memory_dir / f"{slugify(name)}.md"
    path.write_text(render_frontmatter(name, description, mem_type) + content)
    rebuild_index()
```

**Step 3.** Build a small index so the system knows what memories exist without reading every file.

```md
# Memory Index

- prefer_pnpm [user]
- ask_before_codegen [feedback]
- incident_dashboard [reference]
```

The index is not the memory itself -- it is a quick map of what exists.

**Step 4.** Load relevant memory at session start and turn it into a prompt section. Memory becomes useful only when it is fed back into the model input. This is why s09 naturally connects into s10.

```python
memories = memory_store.load_all()
```

**Step 5.** Know what should NOT go into memory. This boundary is the most important part of the chapter, and the place where most beginners go wrong.

| Do not store | Why |
|---|---|
| file tree layout | can be re-read from the repo |
| function names and signatures | code is the source of truth |
| current task status | belongs to task / plan, not memory |
| temporary branch names or PR numbers | gets stale quickly |
| secrets or credentials | security risk |

The right rule is: only keep information that still matters across sessions and cannot be cheaply re-derived from the current workspace.

**Step 6.** Understand the boundaries against neighbor concepts. These four things sound similar but serve different purposes.

| Concept | Purpose | Lifetime |
|---------|---------|----------|
| Memory | Facts that should survive across sessions | Persistent |
| Task | What the system is trying to finish right now | One task |
| Plan | How this turn or session intends to proceed | One session |
| CLAUDE.md | Stable instruction documents and project-level standing rules | Persistent |

Short rule of thumb: only useful for this task -- use `task` or `plan`. Useful next session too -- use `memory`. Long-lived instruction text -- use `CLAUDE.md`.

## Common Mistakes

**Mistake 1: Storing things the repo can tell you.** If the code can answer it, memory should not duplicate it. You will just end up with stale copies that conflict with reality.

**Mistake 2: Storing live task progress.** "Currently fixing auth" is not memory. That belongs to plan or task state. When the task is done, the memory is meaningless.

**Mistake 3: Treating memory as absolute truth.** Memory can be stale. The safer rule is: memory gives direction, current observation gives truth.

## What Changed From s08

| Component | Before (s08) | After (s09) |
|-----------|-------------|-------------|
| Cross-session state | None | File-based memory store |
| Memory types | None | user, feedback, project, reference |
| Storage format | None | YAML frontmatter markdown files |
| Session start | Cold start | Loads relevant memories |
| Durability | Everything forgotten | Key facts persist |

## Try It

```sh
cd learn-claude-code
python agents/s09_memory_system.py
```

Try asking it to remember:

- a user preference
- a correction you want enforced later
- a project fact that is not obvious from the repository

## What You've Mastered

At this point, you can:

- Explain why memory is a curated store of durable facts, not a dump of everything the agent has seen
- Categorize facts into four types: user preferences, feedback, project knowledge, and references
- Store and retrieve memories using frontmatter-based markdown files
- Draw a clear line between what belongs in memory and what belongs in task state, plans, or CLAUDE.md
- Avoid the three most common mistakes: duplicating the repo, storing transient state, and treating memories as ground truth

## What's Next

Your agent now remembers things across sessions, but those memories just sit in a file until session start. In s10, you will build the system prompt assembly pipeline -- the mechanism that takes memories, skills, permissions, and other context and weaves them into the prompt that the model actually sees on every turn.

## Key Takeaway

> Memory is not a dump of everything the agent has seen -- it is a small store of durable facts that should still matter next session.


---

# s10: System Prompt

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > [ s10 ] > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How to assemble the system prompt from independent sections instead of one hardcoded string
- The boundary between stable content (role, rules) and dynamic content (date, cwd, per-turn reminders)
- How CLAUDE.md files layer instructions without overwriting each other
- Why memory must be re-injected through the prompt pipeline to actually guide the agent

When your agent had one tool and one job, a single hardcoded prompt string worked fine. But look at everything your harness has accumulated by now: a role description, tool definitions, loaded skills, saved memory, CLAUDE.md instruction files, and per-turn runtime context. If you keep cramming all of that into one big string, nobody -- including you -- can tell where each piece came from, why it is there, or how to change it safely. The fix is to stop treating the prompt as a blob and start treating it as an assembly pipeline.

## The Problem

Imagine you want to add a new tool to your agent. You open the system prompt, scroll past the role paragraph, past the safety rules, past the three skill descriptions, past the memory block, and paste a tool description somewhere in the middle. Next week someone else adds a CLAUDE.md loader and appends its output to the same string. A month later the prompt is 6,000 characters long, half of it is stale, and nobody remembers which lines are supposed to change per turn and which should stay fixed across the entire session.

This is not a hypothetical scenario -- it is the natural trajectory of every agent that keeps its prompt in a single variable.

## The Solution

Turn prompt construction into a pipeline. Each section has one source and one responsibility. A builder object assembles them in a fixed order, with a clear boundary between parts that stay stable and parts that change every turn.

```text
1. core identity and rules
2. tool catalog
3. skills
4. memory
5. CLAUDE.md instruction chain
6. dynamic runtime context
```

Then assemble:

```text
core
+ tools
+ skills
+ memory
+ claude_md
+ dynamic_context
= final model input
```

## How It Works

**Step 1. Define the builder.** Each method owns exactly one source of content.

```python
class SystemPromptBuilder:
    def build(self) -> str:
        parts = []
        parts.append(self._build_core())
        parts.append(self._build_tools())
        parts.append(self._build_skills())
        parts.append(self._build_memory())
        parts.append(self._build_claude_md())
        parts.append(self._build_dynamic())
        return "\n\n".join(p for p in parts if p)
```

That is the central idea of the chapter. Each `_build_*` method pulls from one source only: `_build_tools()` reads the tool list, `_build_memory()` reads the memory store, and so on. If you want to know where a line in the prompt came from, you check the one method responsible for it.

**Step 2. Separate stable content from dynamic content.** This is the most important boundary in the entire pipeline.

Stable content changes rarely or never during a session:

- role description
- tool contract (the list of tools and their schemas)
- long-lived safety rules
- project instruction chain (CLAUDE.md files)

Dynamic content changes every turn or every few turns:

- current date
- current working directory
- current mode (plan mode, code mode, etc.)
- per-turn warnings or reminders

Mixing these together means the model re-reads thousands of tokens of stable text that have not changed, while the few tokens that did change are buried somewhere in the middle. A real system separates them with a boundary marker so the stable prefix can be cached across turns to save prompt tokens.

**Step 3. Layer CLAUDE.md instructions.** `CLAUDE.md` is not the same as memory and not the same as a skill. It is a layered instruction source -- meaning multiple files contribute, and later layers add to earlier ones rather than replacing them:

1. user-level instruction file (`~/.claude/CLAUDE.md`)
2. project-root instruction file (`<project>/CLAUDE.md`)
3. deeper subdirectory instruction files

The important point is not the filename itself. The important point is that instruction sources can be layered instead of overwritten.

**Step 4. Re-inject memory.** Saving memory (in s09) is only half the mechanism. If memory never re-enters the model input, it is not actually guiding the agent. So memory naturally belongs in the prompt pipeline:

- save durable facts in `s09`
- re-inject them through the prompt builder in `s10`

**Step 5. Attach per-turn reminders separately.** Some information is even more short-lived than "dynamic context" -- it only matters for this one turn and should not pollute the stable system prompt. A `system-reminder` user message keeps these transient signals outside the builder entirely:

- this-turn-only instructions
- temporary notices
- transient recovery guidance

## What Changed from s09

| Aspect | s09: Memory System | s10: System Prompt |
|--------|--------------------|--------------------|
| Core concern | Persist durable facts across sessions | Assemble all sources into model input |
| Memory's role | Write and store | Read and inject |
| Prompt structure | Assumed but not managed | Explicit pipeline with sections |
| Instruction files | Not addressed | CLAUDE.md layering introduced |
| Dynamic context | Not addressed | Separated from stable content |

## Read Together

- If you still treat the prompt as one mysterious blob of text, revisit [`s00a-query-control-plane.md`](./s00a-query-control-plane.md) to see what reaches the model and through which control layers.
- If you want to stabilize the order of assembly, keep [`s10a-message-prompt-pipeline.md`](./s10a-message-prompt-pipeline.md) beside this chapter -- it is the key bridge note for `s10`.
- If system rules, tool docs, memory, and runtime state start to collapse into one big input lump, reset with [`data-structures.md`](./data-structures.md).

## Common Beginner Mistakes

**Mistake 1: teaching the prompt as one fixed string.** That hides how the system really grows. A fixed string is fine for a demo; it stops being fine the moment you add a second capability.

**Mistake 2: putting every changing detail into the same prompt block.** That mixes durable rules with per-turn noise. When you update one, you risk breaking the other.

**Mistake 3: treating skills, memory, and CLAUDE.md as the same thing.** They may all become prompt sections, but their source and purpose are different:

- `skills`: optional capability packages loaded on demand
- `memory`: durable cross-session facts about the user or project
- `CLAUDE.md`: standing instruction documents that layer without overwriting

## Try It

```sh
cd learn-claude-code
python agents/s10_system_prompt.py
```

Look for these three things:

1. where each section comes from
2. which parts are stable
3. which parts are generated dynamically each turn

## What You've Mastered

At this point, you can:

- Build a system prompt from independent, testable sections instead of one opaque string
- Draw a clear line between stable content and dynamic content
- Layer instruction files so that project-level and directory-level rules coexist without overwriting
- Re-inject memory into the prompt pipeline so saved facts actually influence the model
- Attach per-turn reminders separately from the main system prompt

## What's Next

The prompt assembly pipeline means your agent now enters each turn with the right instructions, the right tools, and the right context. But real work produces real failures -- output gets cut off, the prompt grows too large, the API times out. In [s11: Error Recovery](./s11-error-recovery.md), you will teach the harness to classify those failures and choose a recovery path instead of crashing.

## Key Takeaway

> The system prompt is an assembly pipeline with clear sections and clear boundaries, not one big mysterious string.


---

# s10a: Message & Prompt Pipeline

> **Deep Dive** -- Best read alongside s10. It shows why the system prompt is only one piece of the model's full input.

### When to Read This

When you're working on prompt assembly and want to see the complete input pipeline.

---

> This bridge document extends `s10`.
>
> It exists to make one crucial idea explicit:
>
> **the system prompt matters, but it is not the whole model input.**

## Why This Document Exists

`s10` already upgrades the system prompt from one giant string into a maintainable assembly process.

That is important.

But a higher-completion system goes one step further and treats the whole model input as a pipeline made from multiple sources:

- system prompt blocks
- normalized messages
- memory attachments
- reminder injections
- dynamic runtime context

So the true structure is:

**a prompt pipeline, not only a prompt builder.**

## Terms First

### Prompt block

A structured piece inside the system prompt, such as:

- core identity
- tool instructions
- memory section
- CLAUDE.md section

### Normalized message

A message that has already been converted into a stable shape suitable for the model API.

This is necessary because the raw system may contain:

- user messages
- assistant replies
- tool results
- reminder injections
- attachment-like content

Normalization ensures all of these fit the same structural contract before they reach the API.

### System reminder

A small temporary instruction injected for the current turn or current mode.

Unlike a long-lived prompt block, a reminder is usually short-lived and situational -- for example, telling the model it is currently in "plan mode" or that a certain tool is temporarily unavailable.

## The Smallest Useful Mental Model

Think of the full input as a pipeline:

```text
multiple sources
  |
  +-- system prompt blocks
  +-- messages
  +-- attachments
  +-- reminders
  |
  v
normalize
  |
  v
final API payload
```

The key teaching point is:

**separate the sources first, then normalize them into one stable input.**

## Why System Prompt Is Not Everything

The system prompt is the right place for:

- identity
- stable rules
- long-lived constraints
- tool capability descriptions

But it is usually the wrong place for:

- the latest `tool_result`
- one-turn hook injections
- temporary reminders
- dynamic memory attachments

Those belong in the message stream or in adjacent input surfaces.

## Core Structures

### `SystemPromptBlock`

```python
block = {
    "text": "...",
    "cache_scope": None,
}
```

### `PromptParts`

```python
parts = {
    "core": "...",
    "tools": "...",
    "skills": "...",
    "memory": "...",
    "claude_md": "...",
    "dynamic": "...",
}
```

### `NormalizedMessage`

```python
message = {
    "role": "user" | "assistant",
    "content": [...],
}
```

Treat `content` as a list of blocks, not just one string.

### `ReminderMessage`

```python
reminder = {
    "role": "system",
    "content": "Current mode: plan",
}
```

Even if your teaching implementation does not literally use `role="system"` here, you should still keep the mental split:

- long-lived prompt block
- short-lived reminder

## Minimal Implementation Path

### 1. Keep a `SystemPromptBuilder`

Do not throw away the prompt-builder step.

### 2. Make messages a separate pipeline

```python
def build_messages(raw_messages, attachments, reminders):
    messages = normalize_messages(raw_messages)
    messages = attach_memory(messages, attachments)
    messages = append_reminders(messages, reminders)
    return messages
```

### 3. Assemble the final payload only at the end

```python
payload = {
    "system": build_system_prompt(),
    "messages": build_messages(...),
    "tools": build_tools(...),
}
```

This is the important mental upgrade:

**system prompt, messages, and tools are parallel input surfaces, not replacements for one another.**

## Key Takeaway

**The model input is a pipeline of sources that are normalized late, not one mystical prompt blob. System prompt, messages, and tools are parallel surfaces that converge only at send time.**


---

# s11: Error Recovery

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > [ s11 ] > s12 > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- Three categories of recoverable failure: truncation, context overflow, and transient transport errors
- How to route each failure to the right recovery branch (continuation, compaction, or backoff)
- Why retry budgets prevent infinite loops
- How recovery state keeps the "why" visible instead of burying it in a catch block

Your agent is doing real work now -- reading files, writing code, calling tools across multiple turns. And real work produces real failures. Output gets cut off mid-sentence. The prompt grows past the model's context window. The API times out or hits a rate limit. If every one of these failures ends the run immediately, your system feels brittle and your users learn not to trust it. But here is the key insight: most of these failures are not true task failure. They are signals that the next step needs a different continuation path.

## The Problem

Your user asks the agent to refactor a large file. The model starts writing the new version, but the output hits `max_tokens` and stops mid-function. Without recovery, the agent just halts with a half-written file. The user has to notice, re-prompt, and hope the model picks up where it left off.

Or: the conversation has been running for 40 turns. The accumulated messages push the prompt past the model's context limit. The API returns an error. Without recovery, the entire session is lost.

Or: a momentary network hiccup drops the connection. Without recovery, the agent crashes even though the same request would succeed one second later.

Each of these is a different kind of failure, and each needs a different recovery action. A single catch-all retry cannot handle all three correctly.

## The Solution

Classify the failure first, choose the recovery branch second, and enforce a retry budget so the system cannot loop forever.

```text
LLM call
  |
  +-- stop_reason == "max_tokens"
  |      -> append continuation reminder
  |      -> retry
  |
  +-- prompt too long
  |      -> compact context
  |      -> retry
  |
  +-- timeout / rate limit / connection error
         -> back off
         -> retry
```

## How It Works

**Step 1. Track recovery state.** Before you can recover, you need to know how many times you have already tried. A simple counter per category prevents infinite loops:

```python
recovery_state = {
    "continuation_attempts": 0,
    "compact_attempts": 0,
    "transport_attempts": 0,
}
```

**Step 2. Classify the failure.** Each failure maps to exactly one recovery kind. The classifier examines the stop reason and error text, then returns a structured decision:

```python
def choose_recovery(stop_reason: str | None, error_text: str | None) -> dict:
    if stop_reason == "max_tokens":
        return {"kind": "continue", "reason": "output truncated"}

    if error_text and "prompt" in error_text and "long" in error_text:
        return {"kind": "compact", "reason": "context too large"}

    if error_text and any(word in error_text for word in [
        "timeout", "rate", "unavailable", "connection"
    ]):
        return {"kind": "backoff", "reason": "transient transport failure"}

    return {"kind": "fail", "reason": "unknown or non-recoverable error"}
```

The separation matters: classify first, act second. That way the recovery reason stays visible in state instead of disappearing inside a catch block.

**Step 3. Handle continuation (truncated output).** When the model runs out of output space, the task did not fail -- the turn just ended too early. You inject a continuation reminder and retry:

```python
CONTINUE_MESSAGE = (
    "Output limit hit. Continue directly from where you stopped. "
    "Do not restart or repeat."
)
```

Without this reminder, models tend to restart from the beginning or repeat what they already wrote. The explicit instruction to "continue directly" keeps the output flowing forward.

**Step 4. Handle compaction (context overflow).** When the prompt becomes too large, the problem is not the task itself -- the accumulated context needs to shrink before the next turn can proceed. You call the same `auto_compact` mechanism from s06 to summarize history, then retry:

```python
if decision["kind"] == "compact":
    messages = auto_compact(messages)
    continue
```

**Step 5. Handle backoff (transient errors).** When the error is probably temporary -- a timeout, a rate limit, a brief outage -- you wait and try again. Exponential backoff (doubling the delay each attempt, plus random jitter to avoid thundering-herd problems where many clients retry at the same instant) keeps the system from hammering a struggling server:

```python
def backoff_delay(attempt: int) -> float:
    delay = min(BACKOFF_BASE_DELAY * (2 ** attempt), BACKOFF_MAX_DELAY)
    jitter = random.uniform(0, 1)
    return delay + jitter
```

**Step 6. Wire it into the loop.** The recovery logic sits right inside the agent loop. Each branch either adjusts the messages and continues, or gives up:

```python
while True:
    try:
        response = client.messages.create(...)
        decision = choose_recovery(response.stop_reason, None)
    except Exception as e:
        response = None
        decision = choose_recovery(None, str(e).lower())

    if decision["kind"] == "continue":
        messages.append({"role": "user", "content": CONTINUE_MESSAGE})
        continue

    if decision["kind"] == "compact":
        messages = auto_compact(messages)
        continue

    if decision["kind"] == "backoff":
        time.sleep(backoff_delay(...))
        continue

    if decision["kind"] == "fail":
        break
```

The point is not clever code. The point is: classify, choose, retry with a budget.

## What Changed from s10

| Aspect | s10: System Prompt | s11: Error Recovery |
|--------|--------------------|--------------------|
| Core concern | Assemble model input from sections | Handle failures without crashing |
| Loop behavior | Runs until end_turn or tool_use | Adds recovery branches before giving up |
| Compaction | Not addressed | Triggered reactively on context overflow |
| Retry logic | Not addressed | Budgeted per failure category |
| State tracking | Prompt sections | Recovery counters |

## A Note on Real Systems

Real agent systems also persist session state to disk, so that a crash does not destroy a long-running conversation. Session persistence, checkpointing, and resumption are separate concerns from error recovery -- but they complement it. Recovery handles the failures you can retry in-process; persistence handles the failures you cannot. This teaching harness focuses on the in-process recovery paths, but keep in mind that production systems need both layers.

## Read Together

- If you start losing track of why the current query is still continuing, go back to [`s00c-query-transition-model.md`](./s00c-query-transition-model.md).
- If context compaction and error recovery are starting to look like the same mechanism, reread [`s06-context-compact.md`](./s06-context-compact.md) to separate "shrink context" from "recover after failure."
- If you are about to move into `s12`, keep [`data-structures.md`](./data-structures.md) nearby because the task system adds a new durable work layer on top of recovery state.

## Common Beginner Mistakes

**Mistake 1: using one retry rule for every error.** Different failures need different recovery actions. Retrying a context-overflow error without compacting first will just produce the same error again.

**Mistake 2: no retry budget.** Without budgets, the system can loop forever. Each recovery category needs its own counter and its own maximum.

**Mistake 3: hiding the recovery reason.** The system should know *why* it is retrying. That reason should stay visible in state -- as a structured decision object -- not disappear inside a catch block.

## Try It

```sh
cd learn-claude-code
python agents/s11_error_recovery.py
```

Try forcing:

- a long response (to trigger max_tokens continuation)
- a large context (to trigger compaction)
- a temporary timeout (to trigger backoff)

Then observe which recovery branch the system chooses and how the retry counter increments.

## What You've Mastered

At this point, you can:

- Classify agent failures into three recoverable categories and one terminal category
- Route each failure to the correct recovery branch: continuation, compaction, or backoff
- Enforce retry budgets so the system never loops forever
- Keep recovery decisions visible as structured state instead of burying them in exception handlers
- Explain why different failure types need different recovery actions

## Stage 2 Complete

You have finished Stage 2 of the harness. Look at what you have built since Stage 1:

- **s07 Permission System** -- the harness asks before acting, and the user controls what gets auto-approved
- **s08 Hook System** -- external scripts run at lifecycle points without touching the agent loop
- **s09 Memory System** -- durable facts survive across sessions
- **s10 System Prompt** -- the prompt is an assembly pipeline with clear sections, not one big string
- **s11 Error Recovery** -- failures route to the right recovery path instead of crashing

Your agent started Stage 2 as a working loop that could call tools and manage context. It finishes Stage 2 as a system that governs itself: it checks permissions, runs hooks, remembers what matters, assembles its own instructions, and recovers from failures without human intervention.

That is a real agent harness. If you stopped here and built a product on top of it, you would have something genuinely useful.

But there is more to build. Stage 3 introduces structured work management -- task lists, background execution, and scheduled jobs. The agent stops being purely reactive and starts organizing its own work across time. See you in [s12: Task System](./s12-task-system.md).

## Key Takeaway

> Most agent failures are not true task failure -- they are signals to try a different continuation path, and the harness should classify them and recover automatically.


---

# s12: Task System

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > [ s12 ] > s13 > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How to promote a flat checklist into a task graph with explicit dependencies
- How `blockedBy` and `blocks` edges express ordering and parallelism
- How status transitions (`pending` -> `in_progress` -> `completed`) drive automatic unblocking
- How persisting tasks to disk makes them survive compression and restarts

Back in s03 you gave the agent a TodoWrite tool -- a flat checklist that tracks what is done and what is not. That works well for a single focused session. But real work has structure. Task B depends on task A. Tasks C and D can run in parallel. Task E waits for both C and D. A flat list cannot express any of that. And because the checklist lives only in memory, context compression (s06) wipes it clean. In this chapter you will replace the checklist with a proper task graph that understands dependencies, persists to disk, and becomes the coordination backbone for everything that follows.

## The Problem

Imagine you ask your agent to refactor a codebase: parse the AST, transform the nodes, emit the new code, and run the tests. The parse step must finish before transform and emit can begin. Transform and emit can run in parallel. Tests must wait for both. With s03's flat TodoWrite, the agent has no way to express these relationships. It might attempt the transform before the parse is done, or run the tests before anything is ready. There is no ordering, no dependency tracking, and no status beyond "done or not." Worse, if the context window fills up and compression kicks in, the entire plan vanishes.

## The Solution

Promote the checklist into a task graph persisted to disk. Each task is a JSON file with status, dependencies (`blockedBy`), and dependents (`blocks`). The graph answers three questions at any moment: what is ready, what is blocked, and what is done.

```
.tasks/
  task_1.json  {"id":1, "status":"completed"}
  task_2.json  {"id":2, "blockedBy":[1], "status":"pending"}
  task_3.json  {"id":3, "blockedBy":[1], "status":"pending"}
  task_4.json  {"id":4, "blockedBy":[2,3], "status":"pending"}

Task graph (DAG):
                 +----------+
            +--> | task 2   | --+
            |    | pending  |   |
+----------+     +----------+    +--> +----------+
| task 1   |                          | task 4   |
| completed| --> +----------+    +--> | blocked  |
+----------+     | task 3   | --+     +----------+
                 | pending  |
                 +----------+

Ordering:     task 1 must finish before 2 and 3
Parallelism:  tasks 2 and 3 can run at the same time
Dependencies: task 4 waits for both 2 and 3
Status:       pending -> in_progress -> completed
```

The structure above is a DAG -- a directed acyclic graph, meaning tasks flow forward and never loop back. This task graph becomes the coordination backbone for the later chapters: background execution (s13), agent teams (s15+), and worktree isolation (s18) all build on the same durable task structure.

## How It Works

**Step 1.** Create a `TaskManager` that stores one JSON file per task, with CRUD operations and a dependency graph.

```python
class TaskManager:
    def __init__(self, tasks_dir: Path):
        self.dir = tasks_dir
        self.dir.mkdir(exist_ok=True)
        self._next_id = self._max_id() + 1

    def create(self, subject, description=""):
        task = {"id": self._next_id, "subject": subject,
                "status": "pending", "blockedBy": [],
                "blocks": [], "owner": ""}
        self._save(task)
        self._next_id += 1
        return json.dumps(task, indent=2)
```

**Step 2.** Implement dependency resolution. When a task completes, clear its ID from every other task's `blockedBy` list, automatically unblocking dependents.

```python
def _clear_dependency(self, completed_id):
    for f in self.dir.glob("task_*.json"):
        task = json.loads(f.read_text())
        if completed_id in task.get("blockedBy", []):
            task["blockedBy"].remove(completed_id)
            self._save(task)
```

**Step 3.** Wire up status transitions and dependency edges in the `update` method. When a task's status changes to `completed`, the dependency-clearing logic from Step 2 fires automatically.

```python
def update(self, task_id, status=None,
           add_blocked_by=None, add_blocks=None):
    task = self._load(task_id)
    if status:
        task["status"] = status
        if status == "completed":
            self._clear_dependency(task_id)
    self._save(task)
```

**Step 4.** Register four task tools in the dispatch map, giving the agent full control over creating, updating, listing, and inspecting tasks.

```python
TOOL_HANDLERS = {
    # ...base tools...
    "task_create": lambda **kw: TASKS.create(kw["subject"]),
    "task_update": lambda **kw: TASKS.update(kw["task_id"], kw.get("status")),
    "task_list":   lambda **kw: TASKS.list_all(),
    "task_get":    lambda **kw: TASKS.get(kw["task_id"]),
}
```

From s12 onward, the task graph becomes the default for durable multi-step work. s03's Todo remains useful for quick single-session checklists, but anything that needs ordering, parallelism, or persistence belongs here.

## Read Together

- If you are coming straight from s03, revisit [`data-structures.md`](./data-structures.md) to separate `TodoItem` / `PlanState` from `TaskRecord` -- they look similar but serve different purposes.
- If object boundaries start to blur, reset with [`entity-map.md`](./entity-map.md) before you mix messages, tasks, runtime tasks, and teammates into one layer.
- If you plan to continue into s13, keep [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) beside this chapter because durable tasks and runtime tasks are the easiest pair to confuse next.

## What Changed

| Component | Before (s06) | After (s12) |
|---|---|---|
| Tools | 5 | 8 (`task_create/update/list/get`) |
| Planning model | Flat checklist (in-memory) | Task graph with dependencies (on disk) |
| Relationships | None | `blockedBy` + `blocks` edges |
| Status tracking | Done or not | `pending` -> `in_progress` -> `completed` |
| Persistence | Lost on compression | Survives compression and restarts |

## Try It

```sh
cd learn-claude-code
python agents/s12_task_system.py
```

1. `Create 3 tasks: "Setup project", "Write code", "Write tests". Make them depend on each other in order.`
2. `List all tasks and show the dependency graph`
3. `Complete task 1 and then list tasks to see task 2 unblocked`
4. `Create a task board for refactoring: parse -> transform -> emit -> test, where transform and emit can run in parallel after parse`

## What You've Mastered

At this point, you can:

- Build a file-based task graph where each task is a self-contained JSON record
- Express ordering and parallelism through `blockedBy` and `blocks` dependency edges
- Implement automatic unblocking when upstream tasks complete
- Persist planning state so it survives context compression and process restarts

## What's Next

Tasks now have structure and live on disk. But every tool call still blocks the main loop -- if a task involves a slow subprocess like `npm install` or `pytest`, the agent sits idle waiting. In s13 you will add background execution so slow work runs in parallel while the agent keeps thinking.

## Key Takeaway

> A task graph with explicit dependencies turns a flat checklist into a coordination structure that knows what is ready, what is blocked, and what can run in parallel.


---

# s13: Background Tasks

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > [ s13 ] > s14 > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How to run slow commands in background threads while the main loop stays responsive
- How a thread-safe notification queue delivers results back to the agent
- How daemon threads keep the process clean on exit
- How the drain-before-call pattern injects background results at exactly the right moment

You have a task graph now, and every task can express what it depends on. But there is a practical problem: some tasks involve commands that take minutes. `npm install`, `pytest`, `docker build` -- these block the main loop, and while the agent waits, the user waits too. If the user says "install dependencies and while that runs, create the config file," your agent from s12 does them sequentially because it has no way to start something and come back to it later. This chapter fixes that by adding background execution.

## The Problem

Consider a realistic workflow: the user asks the agent to run a full test suite (which takes 90 seconds) and then set up a configuration file. With a blocking loop, the agent submits the test command, stares at a spinning subprocess for 90 seconds, gets the result, and only then starts the config file. The user watches all of this happen serially. Worse, if there are three slow commands, total wall-clock time is the sum of all three -- even though they could have run in parallel. The agent needs a way to start slow work, give control back to the main loop immediately, and pick up the results later.

## The Solution

Keep the main loop single-threaded, but run slow subprocesses on background daemon threads. When a background command finishes, its result goes into a thread-safe notification queue. Before each LLM call, the main loop drains that queue and injects any completed results into the conversation.

```
Main thread                Background thread
+-----------------+        +-----------------+
| agent loop      |        | subprocess runs |
| ...             |        | ...             |
| [LLM call] <---+------- | enqueue(result) |
|  ^drain queue   |        +-----------------+
+-----------------+

Timeline:
Agent --[spawn A]--[spawn B]--[other work]----
             |          |
             v          v
          [A runs]   [B runs]      (parallel)
             |          |
             +-- results injected before next LLM call --+
```

## How It Works

**Step 1.** Create a `BackgroundManager` that tracks running tasks with a thread-safe notification queue. The lock ensures that the main thread and background threads never corrupt the queue simultaneously.

```python
class BackgroundManager:
    def __init__(self):
        self.tasks = {}
        self._notification_queue = []
        self._lock = threading.Lock()
```

**Step 2.** The `run()` method starts a daemon thread and returns immediately. A daemon thread is one that the Python runtime kills automatically when the main program exits -- you do not need to join it or clean it up.

```python
def run(self, command: str) -> str:
    task_id = str(uuid.uuid4())[:8]
    self.tasks[task_id] = {"status": "running", "command": command}
    thread = threading.Thread(
        target=self._execute, args=(task_id, command), daemon=True)
    thread.start()
    return f"Background task {task_id} started"
```

**Step 3.** When the subprocess finishes, the background thread puts its result into the notification queue. The lock makes this safe even if the main thread is draining the queue at the same time.

```python
def _execute(self, task_id, command):
    try:
        r = subprocess.run(command, shell=True, cwd=WORKDIR,
            capture_output=True, text=True, timeout=300)
        output = (r.stdout + r.stderr).strip()[:50000]
    except subprocess.TimeoutExpired:
        output = "Error: Timeout (300s)"
    with self._lock:
        self._notification_queue.append({
            "task_id": task_id, "result": output[:500]})
```

**Step 4.** The agent loop drains notifications before each LLM call. This is the drain-before-call pattern: right before you ask the model to think, sweep up any background results and add them to the conversation so the model sees them in its next turn.

```python
def agent_loop(messages: list):
    while True:
        notifs = BG.drain_notifications()
        if notifs:
            notif_text = "\n".join(
                f"[bg:{n['task_id']}] {n['result']}" for n in notifs)
            messages.append({"role": "user",
                "content": f"<background-results>\n{notif_text}\n"
                           f"</background-results>"})
            messages.append({"role": "assistant",
                "content": "Noted background results."})
        response = client.messages.create(...)
```

This teaching demo keeps the core loop single-threaded; only subprocess waiting is parallelized. A production system would typically split background work into several runtime lanes, but starting with one clean pattern makes the mechanics easy to follow.

## Read Together

- If you have not fully separated "task goal" from "running execution slot," read [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) first -- it clarifies why a task record and a runtime record are different objects.
- If you are unsure which state belongs in `RuntimeTaskRecord` and which still belongs on the task board, keep [`data-structures.md`](./data-structures.md) nearby.
- If background execution starts to feel like "another main loop," go back to [`s02b-tool-execution-runtime.md`](./s02b-tool-execution-runtime.md) and reset the boundary: execution and waiting can run in parallel, but the main loop is still one mainline.

## What Changed

| Component      | Before (s12)     | After (s13)                |
|----------------|------------------|----------------------------|
| Tools          | 8                | 6 (base + background_run + check)|
| Execution      | Blocking only    | Blocking + background threads|
| Notification   | None             | Queue drained per loop     |
| Concurrency    | None             | Daemon threads             |

## Try It

```sh
cd learn-claude-code
python agents/s13_background_tasks.py
```

1. `Run "sleep 5 && echo done" in the background, then create a file while it runs`
2. `Start 3 background tasks: "sleep 2", "sleep 4", "sleep 6". Check their status.`
3. `Run pytest in the background and keep working on other things`

## What You've Mastered

At this point, you can:

- Run slow subprocesses on daemon threads without blocking the main agent loop
- Collect results through a thread-safe notification queue
- Inject background results into the conversation using the drain-before-call pattern
- Let the agent work on other things while long-running commands finish in parallel

## What's Next

Background tasks solve the problem of slow work that starts now. But what about work that should start later -- "run this every night" or "remind me in 30 minutes"? In s14 you will add a cron scheduler that stores future intent and triggers it when the time comes.

## Key Takeaway

> Background execution is a runtime lane, not a second main loop -- slow work runs on daemon threads and feeds results back through a single notification queue.


---

# s13a: Runtime Task Model

> **Deep Dive** -- Best read between s12 and s13. It prevents the most common confusion in Stage 3.

### When to Read This

Right after s12 (Task System), before you start s13 (Background Tasks). This note separates two meanings of "task" that beginners frequently collapse into one.

---

> This bridge note resolves one confusion that becomes expensive very quickly:
>
> **the task in the work graph is not the same thing as the task that is currently running**

## How to Read This with the Mainline

This note works best between these documents:

- read [`s12-task-system.md`](./s12-task-system.md) first to lock in the durable work graph
- then read [`s13-background-tasks.md`](./s13-background-tasks.md) to see background execution
- if the terms begin to blur, you might find it helpful to revisit [`glossary.md`](./glossary.md)
- if you want the fields to line up exactly, you might find it helpful to revisit [`data-structures.md`](./data-structures.md) and [`entity-map.md`](./entity-map.md)

## Why This Deserves Its Own Bridge Note

The mainline is still correct:

- `s12` teaches the task system
- `s13` teaches background tasks

But without one more bridge layer, you can easily start collapsing two different meanings of "task" into one bucket.

For example:

- a work-graph task such as "implement auth module"
- a background execution such as "run pytest"
- a teammate execution such as "alice is editing files"

All three can be casually called tasks, but they do not live on the same layer.

## Two Very Different Kinds of Task

### 1. Work-graph task

This is the durable node introduced in `s12`.

It answers:

- what should be done
- which work depends on which other work
- who owns it
- what the progress status is

It is best understood as:

> a durable unit of planned work

### 2. Runtime task

This layer answers:

- what execution unit is alive right now
- what kind of execution it is
- whether it is running, completed, failed, or killed
- where its output lives

It is best understood as:

> a live execution slot inside the runtime

## The Minimum Mental Model

Treat these as two separate tables:

```text
work-graph task
  - durable
  - goal and dependency oriented
  - longer lifecycle

runtime task
  - execution oriented
  - output and status oriented
  - shorter lifecycle
```

Their relationship is not "pick one."

It is:

```text
one work-graph task
  can spawn
one or more runtime tasks
```

For example:

```text
work-graph task:
  "Implement auth module"

runtime tasks:
  1. run tests in the background
  2. launch a coder teammate
  3. monitor an external service
```

## Why the Distinction Matters

If you do not keep these layers separate, the later chapters start tangling together:

- `s13` background execution blurs into the `s12` task board
- `s15-s17` teammate work has nowhere clean to attach
- `s18` worktrees become unclear because you no longer know what layer they belong to

The shortest correct summary is:

**work-graph tasks manage goals; runtime tasks manage execution**

## Core Records

### 1. `WorkGraphTaskRecord`

This is the durable task from `s12`.

```python
task = {
    "id": 12,
    "subject": "Implement auth module",
    "status": "in_progress",
    "blockedBy": [],
    "blocks": [13],
    "owner": "alice",
    "worktree": "auth-refactor",
}
```

### 2. `RuntimeTaskState`

A minimal teaching shape can look like this:

```python
runtime_task = {
    "id": "b8k2m1qz",
    "type": "local_bash",
    "status": "running",
    "description": "Run pytest",
    "start_time": 1710000000.0,
    "end_time": None,
    "output_file": ".task_outputs/b8k2m1qz.txt",
    "notified": False,
}
```

The key fields are:

- `type`: what execution unit this is
- `status`: whether it is active or terminal
- `output_file`: where the result is stored
- `notified`: whether the system already surfaced the result

### 3. `RuntimeTaskType`

You do not need to implement every type in the teaching repo immediately.

But you should still know that runtime task is a family, not just one shell command type.

A minimal table:

```text
local_bash
local_agent
remote_agent
in_process_teammate
monitor
workflow
```

## Minimum Implementation Steps

### Step 1: keep the `s12` task board intact

Do not overload it.

### Step 2: add a separate runtime task manager

```python
class RuntimeTaskManager:
    def __init__(self):
        self.tasks = {}
```

### Step 3: create runtime tasks when background work starts

```python
def spawn_bash_task(command: str):
    task_id = new_runtime_id()
    runtime_tasks[task_id] = {
        "id": task_id,
        "type": "local_bash",
        "status": "running",
        "description": command,
    }
```

### Step 4: optionally link runtime execution back to the work graph

```python
runtime_tasks[task_id]["work_graph_task_id"] = 12
```

You do not need that field on day one, but it becomes increasingly important once the system reaches teams and worktrees.

## The Picture You Should Hold

```text
Work Graph
  task #12: Implement auth module
        |
        +-- runtime task A: local_bash (pytest)
        +-- runtime task B: local_agent (coder worker)
        +-- runtime task C: monitor (watch service status)

Runtime Task Layer
  A/B/C each have:
  - their own runtime ID
  - their own status
  - their own output
  - their own lifecycle
```

## How This Connects to Later Chapters

Once this layer is clear, the rest of the runtime and platform chapters become much easier:

- `s13` background commands are runtime tasks
- `s15-s17` teammates can also be understood as runtime task variants
- `s18` worktrees mostly bind to durable work, but still affect runtime execution
- `s19` some monitoring or async external work can also land in the runtime layer

Whenever you see "something is alive in the background and advancing work," ask two questions:

- is this a durable goal from the work graph?
- or is this a live execution slot in the runtime?

## Common Beginner Mistakes

### 1. Putting background shell state directly into the task board

That mixes durable task state and runtime execution state.

### 2. Assuming one work-graph task can only have one runtime task

In real systems, one goal often spawns multiple execution units.

### 3. Reusing the same status vocabulary for both layers

For example:

- durable tasks: `pending / in_progress / completed`
- runtime tasks: `running / completed / failed / killed`

Those should stay distinct when possible.

### 4. Ignoring runtime-only fields such as `output_file` and `notified`

The durable task board does not care much about them.
The runtime layer cares a lot.

## Key Takeaway

**"Task" means two different things: a durable goal in the work graph (what should be done) and a live execution slot in the runtime (what is running right now). Keep them on separate layers.**


---

# s14: Cron Scheduler

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > [ s14 ] > s15 > s16 > s17 > s18 > s19`

## What You'll Learn

- How schedule records store future intent as durable data
- How a time-based checker turns cron expressions into triggered notifications
- The difference between durable jobs (survive restarts) and session-only jobs (die with the process)
- How scheduled work re-enters the agent system through the same notification queue from s13

In s13 you learned to run slow work in the background so the agent does not block. But that work still starts immediately -- the user says "run this" and it runs now. Real workflows often need work that starts later: "run this every night," "generate the report every Monday morning," "remind me to check this again in 30 minutes." Without scheduling, the user has to re-issue the same request every time. This chapter adds one new idea: store future intent now, trigger it later. And it closes out Stage 3 by completing the progression from durable tasks (s12) to background execution (s13) to time-based triggers (s14).

## The Problem

Your agent can now manage a task graph and run commands in the background. But every piece of work begins with the user explicitly asking for it. If the user wants a nightly test run, they have to remember to type "run the tests" every evening. If they want a weekly status report, they have to open a session every Monday morning. The agent has no concept of future time -- it reacts to what you say right now, and it cannot act on something you want to happen tomorrow. You need a way to record "do X at time Y" and have the system trigger it automatically.

## The Solution

Add three moving parts: schedule records that describe when and what, a time checker that runs in the background and tests whether any schedule matches the current time, and the same notification queue from s13 to feed triggered work back into the main loop.

```text
schedule_create(...)
  ->
write a durable schedule record
  ->
time checker wakes up and tests "does this rule match now?"
  ->
if yes, enqueue a scheduled notification
  ->
main loop injects that notification as new work
```

The key insight is that the scheduler is not a second agent loop. It feeds triggered prompts into the same system the agent already uses. The main loop does not know or care whether a piece of work came from the user typing it or from a cron trigger -- it processes both the same way.

## How It Works

**Step 1.** Define the schedule record. Each job stores a cron expression (a compact time-matching syntax like `0 9 * * 1` meaning "9:00 AM every Monday"), the prompt to execute, whether it recurs or fires once, and a `last_fired_at` timestamp to prevent double-firing.

```python
schedule = {
    "id": "job_001",
    "cron": "0 9 * * 1",
    "prompt": "Run the weekly status report.",
    "recurring": True,
    "durable": True,
    "created_at": 1710000000.0,
    "last_fired_at": None,
}
```

A durable job is written to disk and survives process restarts. A session-only job lives in memory and dies when the agent exits. One-shot jobs (`recurring: False`) fire once and then delete themselves.

**Step 2.** Create a schedule through a tool call. The method stores the record and returns it so the model can confirm what was scheduled.

```python
def create(self, cron_expr: str, prompt: str, recurring: bool = True):
    job = {
        "id": new_id(),
        "cron": cron_expr,
        "prompt": prompt,
        "recurring": recurring,
        "created_at": time.time(),
        "last_fired_at": None,
    }
    self.jobs.append(job)
    return job
```

**Step 3.** Run a background checker loop that wakes up every 60 seconds and tests each schedule against the current time.

```python
def check_loop(self):
    while True:
        now = datetime.now()
        self.check_jobs(now)
        time.sleep(60)
```

**Step 4.** When a schedule matches, enqueue a notification. The `last_fired_at` field is updated to prevent the same minute from triggering the job twice.

```python
def check_jobs(self, now):
    for job in self.jobs:
        if cron_matches(job["cron"], now):
            self.queue.put({
                "type": "scheduled_prompt",
                "schedule_id": job["id"],
                "prompt": job["prompt"],
            })
            job["last_fired_at"] = now.timestamp()
```

**Step 5.** Feed scheduled notifications back into the main loop using the same drain pattern from s13. From the agent's perspective, a scheduled prompt looks just like a user message.

```python
notifications = scheduler.drain()
for item in notifications:
    messages.append({
        "role": "user",
        "content": f"[scheduled:{item['schedule_id']}] {item['prompt']}",
    })
```

## Read Together

- If `schedule`, `task`, and `runtime task` still feel like the same object, reread [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) -- it draws the boundary between planning records, execution records, and schedule records.
- If you want to see how one trigger eventually returns to the mainline, pair this chapter with [`s00b-one-request-lifecycle.md`](./s00b-one-request-lifecycle.md).
- If future triggers start to feel like a whole second execution system, reset with [`data-structures.md`](./data-structures.md) and separate schedule records from runtime records.

## What Changed

| Mechanism | Main question |
|---|---|
| Background tasks (s13) | "How does slow work continue without blocking?" |
| Scheduling (s14) | "When should future work begin?" |

| Component | Before (s13) | After (s14) |
|---|---|---|
| Tools | 6 (base + background) | 8 (+ schedule_create, schedule_list, schedule_delete) |
| Time awareness | None | Cron-based future triggers |
| Persistence | Background tasks in memory | Durable schedules survive restarts |
| Trigger model | User-initiated only | User-initiated + time-triggered |

## Try It

```sh
cd learn-claude-code
python agents/s14_cron_scheduler.py
```

1. Create a repeating schedule: `Schedule "echo hello" to run every 2 minutes`
2. Create a one-shot reminder: `Remind me in 1 minute to check the build`
3. Create a delayed follow-up: `In 5 minutes, run the test suite and report results`

## What You've Mastered

At this point, you can:

- Define schedule records that store future intent as durable data
- Run a background time checker that matches cron expressions to the current clock
- Distinguish durable jobs (persist to disk) from session-only jobs (in-memory)
- Feed scheduled triggers back into the main loop through the same notification queue used by background tasks
- Prevent double-firing with `last_fired_at` tracking

## Stage 3 Complete

You have finished Stage 3: the execution and scheduling layer. Looking back at the three chapters together:

- **s12** gave the agent a task graph with dependencies and persistence -- it can plan structured work that survives restarts.
- **s13** added background execution -- slow work runs in parallel instead of blocking the loop.
- **s14** added time-based triggers -- the agent can schedule future work without the user having to remember.

Together, these three chapters transform the agent from something that only reacts to what you type right now into something that can plan ahead, work in parallel, and act on its own schedule. In Stage 4 (s15-s18), you will use this foundation to coordinate multiple agents working as a team.

## Key Takeaway

> A scheduler stores future intent as a record, checks it against the clock in a background loop, and feeds triggered work back into the same agent system -- no second loop needed.


---

# Team Task Lane Model

> **Deep Dive** -- Best read at the start of Stage 4 (s15-s18). It separates five concepts that look similar but live on different layers.

### When to Read This

Before you start the team chapters. Keep it open as a reference during s15-s18.

---

> By the time you reach `s15-s18`, the easiest thing to blur is not a function name.
>
> It is this:
>
> **Who is working, who is coordinating, what records the goal, and what provides the execution lane.**

## What This Bridge Doc Fixes

Across `s15-s18`, you will encounter these words that can easily blur into one vague idea:

- teammate
- protocol request
- task
- runtime task
- worktree

They all relate to work getting done, but they do **not** live on the same layer.

If you do not separate them, the later chapters start to feel tangled:

- Is a teammate the same thing as a task?
- What is the difference between `request_id` and `task_id`?
- Is a worktree just another runtime task?
- Why can a task be complete while a worktree is still kept?

This document exists to separate those layers cleanly.

## Recommended Reading Order

1. Read [`s15-agent-teams.md`](./s15-agent-teams.md) for long-lived teammates.
2. Read [`s16-team-protocols.md`](./s16-team-protocols.md) for tracked request-response coordination.
3. Read [`s17-autonomous-agents.md`](./s17-autonomous-agents.md) for self-claiming teammates.
4. Read [`s18-worktree-task-isolation.md`](./s18-worktree-task-isolation.md) for isolated execution lanes.

If the vocabulary starts to blur, you might find it helpful to revisit:

- [`entity-map.md`](./entity-map.md)
- [`data-structures.md`](./data-structures.md)
- [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md)

## The Core Separation

```text
teammate
  = who participates over time

protocol request
  = one tracked coordination request inside the team

task
  = what should be done

runtime task / execution slot
  = what is actively running right now

worktree
  = where the work executes without colliding with other lanes
```

The most common confusion is between the last three:

- `task`
- `runtime task`
- `worktree`

Ask three separate questions every time:

- Is this the goal?
- Is this the running execution unit?
- Is this the isolated execution directory?

## The Smallest Clean Diagram

```text
Team Layer
  teammate: alice (frontend)

Protocol Layer
  request_id=req_01
  kind=plan_approval
  status=pending

Work Graph Layer
  task_id=12
  subject="Implement login page"
  owner="alice"
  status="in_progress"

Runtime Layer
  runtime_id=rt_01
  type=in_process_teammate
  status=running

Execution Lane Layer
  worktree=login-page
  path=.worktrees/login-page
  status=active
```

Only one of those records the work goal itself:

> `task_id=12`

The others support coordination, execution, or isolation around that goal.

## 1. Teammate: Who Is Collaborating

Introduced in `s15`.

This layer answers:

- what the long-lived worker is called
- what role it has
- whether it is `working`, `idle`, or `shutdown`
- whether it has its own inbox

Example:

```python
member = {
    "name": "alice",
    "role": "frontend",
    "status": "idle",
}
```

The point is not "another agent instance."

The point is:

> a persistent identity that can repeatedly receive work.

## 2. Protocol Request: What Is Being Coordinated

Introduced in `s16`.

This layer answers:

- who asked whom
- what kind of request this is
- whether it is still pending or already resolved

Example:

```python
request = {
    "request_id": "a1b2c3d4",
    "kind": "plan_approval",
    "from": "alice",
    "to": "lead",
    "status": "pending",
}
```

This is not ordinary chat.

It is:

> a coordination record whose state can continue to evolve.

## 3. Task: What Should Be Done

This is the durable work-graph task from `s12`, and it is what `s17` teammates claim.

It answers:

- what the goal is
- who owns it
- what blocks it
- what progress state it is in

Example:

```python
task = {
    "id": 12,
    "subject": "Implement login page",
    "status": "in_progress",
    "owner": "alice",
    "blockedBy": [],
}
```

Keyword:

**goal**

Not directory. Not protocol. Not process.

## 4. Runtime Task / Execution Slot: What Is Running

This layer was already clarified in the `s13a` bridge doc, but it matters even more in `s15-s18`.

Examples:

- a background shell command
- a long-lived teammate currently working
- a monitor process watching an external state

These are best understood as:

> active execution slots

Example:

```python
runtime = {
    "id": "rt_01",
    "type": "in_process_teammate",
    "status": "running",
    "work_graph_task_id": 12,
}
```

Important boundary:

- one work-graph task may spawn multiple runtime tasks
- a runtime task is an execution instance, not the durable goal itself

## 5. Worktree: Where the Work Happens

Introduced in `s18`.

This layer answers:

- which isolated directory is used
- which task it is bound to
- whether that lane is `active`, `kept`, or `removed`

Example:

```python
worktree = {
    "name": "login-page",
    "path": ".worktrees/login-page",
    "task_id": 12,
    "status": "active",
}
```

Keyword:

**execution boundary**

It is not the task goal itself. It is the isolated lane where that goal is executed.

## How The Layers Connect

```text
teammate
  coordinates through protocol requests
  claims a task
  runs as an execution slot
  works inside a worktree lane
```

In a more concrete sentence:

> `alice` claims `task #12` and progresses it inside the `login-page` worktree lane.

That sentence is much cleaner than saying:

> "alice is doing the login-page worktree task"

because the shorter sentence incorrectly merges:

- the teammate
- the task
- the worktree

## Common Mistakes

### 1. Treating teammate and task as the same object

The teammate executes. The task expresses the goal.

### 2. Treating `request_id` and `task_id` as interchangeable

One tracks coordination. The other tracks work goals.

### 3. Treating the runtime slot as the durable task

The running execution may end while the durable task still exists.

### 4. Treating the worktree as the task itself

The worktree is only the execution lane.

### 5. Saying "the system works in parallel" without naming the layers

Good teaching does not stop at "there are many agents."

It can say clearly:

> teammates provide long-lived collaboration, requests track coordination, tasks record goals, runtime slots carry execution, and worktrees isolate the execution directory.

## What You Should Be Able to Say After Reading This

1. `s17` autonomy claims `s12` work-graph tasks, not `s13` runtime slots.
2. `s18` worktrees bind execution lanes to tasks; they do not turn tasks into directories.
3. A teammate can be idle while the task still exists and while the worktree is still kept.
4. A protocol request tracks a coordination exchange, not a work goal.

## Key Takeaway

**Five things that sound alike -- teammate, protocol request, task, runtime slot, worktree -- live on five separate layers. Naming which layer you mean is how you keep the team chapters from collapsing into confusion.**


---

# s15: Agent Teams

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > [ s15 ] > s16 > s17 > s18 > s19`

## What You'll Learn
- How persistent teammates differ from disposable subagents
- How JSONL-based inboxes give agents a durable communication channel
- How the team lifecycle moves through spawn, working, idle, and shutdown
- How file-based coordination lets multiple agent loops run side by side

Sometimes one agent is not enough. A complex project -- say, building a feature that involves frontend, backend, and tests -- needs multiple workers running in parallel, each with its own identity and memory. In this chapter you will build a team system where agents persist beyond a single prompt, communicate through file-based mailboxes, and coordinate without sharing a single conversation thread.

## The Problem

Subagents from s04 are disposable: you spawn one, it works, it returns a summary, and it dies. It has no identity and no memory between invocations. Background tasks from s13 can keep work running in the background, but they are not persistent teammates making their own LLM-guided decisions.

Real teamwork needs three things: (1) persistent agents that outlive a single prompt, (2) identity and lifecycle management so you know who is doing what, and (3) a communication channel between agents so they can exchange information without the lead manually relaying every message.

## The Solution

The harness maintains a team roster in a shared config file and gives each teammate an append-only JSONL inbox. When one agent sends a message to another, it simply appends a JSON line to the recipient's inbox file. The recipient drains that file before every LLM call.

```
Teammate lifecycle:
  spawn -> WORKING -> IDLE -> WORKING -> ... -> SHUTDOWN

Communication:
  .team/
    config.json           <- team roster + statuses
    inbox/
      alice.jsonl         <- append-only, drain-on-read
      bob.jsonl
      lead.jsonl

              +--------+    send("alice","bob","...")    +--------+
              | alice  | -----------------------------> |  bob   |
              | loop   |    bob.jsonl << {json_line}    |  loop  |
              +--------+                                +--------+
                   ^                                         |
                   |        BUS.read_inbox("alice")          |
                   +---- alice.jsonl -> read + drain ---------+
```

## How It Works

**Step 1.** `TeammateManager` maintains `config.json` with the team roster. It tracks every teammate's name, role, and current status.

```python
class TeammateManager:
    def __init__(self, team_dir: Path):
        self.dir = team_dir
        self.dir.mkdir(exist_ok=True)
        self.config_path = self.dir / "config.json"
        self.config = self._load_config()
        self.threads = {}
```

**Step 2.** `spawn()` creates a teammate entry in the roster and starts its agent loop in a separate thread. From this point on, the teammate runs independently -- it has its own conversation history, its own tool calls, and its own LLM interactions.

```python
def spawn(self, name: str, role: str, prompt: str) -> str:
    member = {"name": name, "role": role, "status": "working"}
    self.config["members"].append(member)
    self._save_config()
    thread = threading.Thread(
        target=self._teammate_loop,
        args=(name, role, prompt), daemon=True)
    thread.start()
    return f"Spawned teammate '{name}' (role: {role})"
```

**Step 3.** `MessageBus` provides append-only JSONL inboxes. `send()` appends a single JSON line to the recipient's file; `read_inbox()` reads all accumulated messages and then empties the file ("drains" it). The storage format is intentionally simple -- the teaching focus here is the mailbox boundary, not storage cleverness.

```python
class MessageBus:
    def send(self, sender, to, content, msg_type="message", extra=None):
        msg = {"type": msg_type, "from": sender,
               "content": content, "timestamp": time.time()}
        if extra:
            msg.update(extra)
        with open(self.dir / f"{to}.jsonl", "a") as f:
            f.write(json.dumps(msg) + "\n")

    def read_inbox(self, name):
        path = self.dir / f"{name}.jsonl"
        if not path.exists(): return "[]"
        msgs = [json.loads(l) for l in path.read_text().strip().splitlines() if l]
        path.write_text("")  # drain
        return json.dumps(msgs, indent=2)
```

**Step 4.** Each teammate checks its inbox before every LLM call. Any received messages get injected into the conversation context so the model can see and respond to them.

```python
def _teammate_loop(self, name, role, prompt):
    messages = [{"role": "user", "content": prompt}]
    for _ in range(50):
        inbox = BUS.read_inbox(name)
        if inbox != "[]":
            messages.append({"role": "user",
                "content": f"<inbox>{inbox}</inbox>"})
            messages.append({"role": "assistant",
                "content": "Noted inbox messages."})
        response = client.messages.create(...)
        if response.stop_reason != "tool_use":
            break
        # execute tools, append results...
    self._find_member(name)["status"] = "idle"
```

## Read Together

- If you still treat a teammate like s04's disposable subagent, revisit [`entity-map.md`](./entity-map.md) to see how they differ.
- If you plan to continue into s16-s18, keep [`team-task-lane-model.md`](./team-task-lane-model.md) open -- it separates teammate, protocol request, task, runtime slot, and worktree lane into distinct concepts.
- If you are unsure how a long-lived teammate differs from a live runtime slot, pair this chapter with [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md).

## How It Plugs Into The Earlier System

This chapter is not just "more model calls." It adds durable executors on top of work structures you already built in s12-s14.

```text
lead identifies work that needs a long-lived worker
  ->
spawn teammate
  ->
write roster entry in .team/config.json
  ->
send inbox message / task hint
  ->
teammate drains inbox before its next loop
  ->
teammate runs its own agent loop and tools
  ->
result returns through team messages or task updates
```

Keep the boundary straight:

- s12-s14 gave you tasks, runtime slots, and schedules
- s15 adds durable named workers
- s15 is still mostly lead-assigned work
- structured protocols arrive in s16
- autonomous claiming arrives in s17

## Teammate vs Subagent vs Runtime Slot

| Mechanism | Think of it as | Lifecycle | Main boundary |
|---|---|---|---|
| subagent | a disposable helper | spawn -> work -> summary -> gone | isolates one exploratory branch |
| runtime slot | a live execution slot | exists while background work is running | tracks long-running execution, not identity |
| teammate | a durable worker | can go idle, resume, and keep receiving work | has a name, inbox, and independent loop |

## What Changed From s14

| Component      | Before (s14)     | After (s15)                |
|----------------|------------------|----------------------------|
| Tools          | 6                | 9 (+spawn/send/read_inbox) |
| Agents         | Single           | Lead + N teammates         |
| Persistence    | None             | config.json + JSONL inboxes|
| Threads        | Background cmds  | Full agent loops per thread|
| Lifecycle      | Fire-and-forget  | idle -> working -> idle    |
| Communication  | None             | message + broadcast        |

## Try It

```sh
cd learn-claude-code
python agents/s15_agent_teams.py
```

1. `Spawn alice (coder) and bob (tester). Have alice send bob a message.`
2. `Broadcast "status update: phase 1 complete" to all teammates`
3. `Check the lead inbox for any messages`
4. Type `/team` to see the team roster with statuses
5. Type `/inbox` to manually check the lead's inbox

## What You've Mastered

At this point, you can:

- Spawn persistent teammates that each run their own independent agent loop
- Send messages between agents through durable JSONL inboxes
- Track teammate status through a shared config file
- Coordinate multiple agents without funneling everything through a single conversation

## What's Next

Your teammates can now communicate freely, but they lack coordination rules. What happens when you need to shut a teammate down cleanly, or review a risky plan before it executes? In s16, you will add structured protocols -- request-response handshakes that bring order to multi-agent negotiation.

## Key Takeaway

> Teammates persist beyond one prompt, each with identity, lifecycle, and a durable mailbox -- coordination is no longer limited to a single parent loop.


---

# s16: Team Protocols

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > [ s16 ] > s17 > s18 > s19`

## What You'll Learn
- How a request-response pattern with a tracking ID structures multi-agent negotiation
- How the shutdown protocol lets a lead gracefully stop a teammate
- How plan approval gates risky work behind a review step
- How one reusable FSM (a simple status tracker with defined transitions) covers both protocols

In s15 your teammates can send messages freely, but that freedom comes with chaos. One agent tells another "please stop," and the other ignores it. A teammate starts a risky database migration without asking first. The problem is not communication itself -- you solved that with inboxes -- but the lack of coordination rules. In this chapter you will add structured protocols: a standardized message wrapper with a tracking ID that turns loose messages into reliable handshakes.

## The Problem

Two coordination gaps become obvious once your team grows past toy examples:

**Shutdown.** Killing a teammate's thread leaves files half-written and the config roster stale. You need a handshake: the lead requests shutdown, and the teammate approves (finishes current work and exits cleanly) or rejects (keeps working because it has unfinished obligations).

**Plan approval.** When the lead says "refactor the auth module," the teammate starts immediately. But for high-risk changes, the lead should review the plan before any code gets written.

Both scenarios share an identical structure: one side sends a request carrying a unique ID, the other side responds referencing that same ID. That single pattern is enough to build any coordination protocol you need.

## The Solution

Both shutdown and plan approval follow one shape: send a request with a `request_id`, receive a response referencing that same `request_id`, and track the outcome through a simple status machine (`pending -> approved` or `pending -> rejected`).

```
Shutdown Protocol            Plan Approval Protocol
==================           ======================

Lead             Teammate    Teammate           Lead
  |                 |           |                 |
  |--shutdown_req-->|           |--plan_req------>|
  | {req_id:"abc"}  |           | {req_id:"xyz"}  |
  |                 |           |                 |
  |<--shutdown_resp-|           |<--plan_resp-----|
  | {req_id:"abc",  |           | {req_id:"xyz",  |
  |  approve:true}  |           |  approve:true}  |

Shared FSM:
  [pending] --approve--> [approved]
  [pending] --reject---> [rejected]

Trackers:
  shutdown_requests = {req_id: {target, status}}
  plan_requests     = {req_id: {from, plan, status}}
```

## How It Works

**Step 1.** The lead initiates shutdown by generating a unique `request_id` and sending the request through the teammate's inbox. The request is tracked in a dictionary so the lead can check its status later.

```python
shutdown_requests = {}

def handle_shutdown_request(teammate: str) -> str:
    req_id = str(uuid.uuid4())[:8]
    shutdown_requests[req_id] = {"target": teammate, "status": "pending"}
    BUS.send("lead", teammate, "Please shut down gracefully.",
             "shutdown_request", {"request_id": req_id})
    return f"Shutdown request {req_id} sent (status: pending)"
```

**Step 2.** The teammate receives the request in its inbox and responds with approve or reject. The response carries the same `request_id` so the lead can match it to the original request -- this is the correlation that makes the protocol reliable.

```python
if tool_name == "shutdown_response":
    req_id = args["request_id"]
    approve = args["approve"]
    shutdown_requests[req_id]["status"] = "approved" if approve else "rejected"
    BUS.send(sender, "lead", args.get("reason", ""),
             "shutdown_response",
             {"request_id": req_id, "approve": approve})
```

**Step 3.** Plan approval follows the identical pattern but in the opposite direction. The teammate submits a plan (generating a `request_id`), and the lead reviews it (referencing the same `request_id` to approve or reject).

```python
plan_requests = {}

def handle_plan_review(request_id, approve, feedback=""):
    req = plan_requests[request_id]
    req["status"] = "approved" if approve else "rejected"
    BUS.send("lead", req["from"], feedback,
             "plan_approval_response",
             {"request_id": request_id, "approve": approve})
```

In this teaching demo, one FSM shape covers both protocols. A production system might treat different protocol families differently, but the teaching version intentionally keeps one reusable template so you can see the shared structure clearly.

## Read Together

- If plain messages and protocol requests are starting to blur together, revisit [`glossary.md`](./glossary.md) and [`entity-map.md`](./entity-map.md) to see how they differ.
- If you plan to continue into s17 and s18, read [`team-task-lane-model.md`](./team-task-lane-model.md) first so autonomy and worktree lanes do not collapse into one idea.
- If you want to trace how a protocol request returns to the main system, pair this chapter with [`s00b-one-request-lifecycle.md`](./s00b-one-request-lifecycle.md).

## How It Plugs Into The Team System

The real upgrade in s16 is not "two new message types." It is a durable coordination path:

```text
requester starts a protocol action
  ->
write RequestRecord
  ->
send ProtocolEnvelope through inbox
  ->
receiver drains inbox on its next loop
  ->
update request status by request_id
  ->
send structured response
  ->
requester continues based on approved / rejected
```

That is the missing layer between "agents can chat" and "agents can coordinate reliably."

## Message vs Protocol vs Request vs Task

| Object | What question it answers | Typical fields |
|---|---|---|
| `MessageEnvelope` | who said what to whom | `from`, `to`, `content` |
| `ProtocolEnvelope` | is this a structured request / response | `type`, `request_id`, `payload` |
| `RequestRecord` | where is this coordination flow now | `kind`, `status`, `from`, `to` |
| `TaskRecord` | what actual work item is being advanced | `subject`, `status`, `blockedBy`, `owner` |

Do not collapse them:

- a protocol request is not the task itself
- the request store is not the task board
- protocols track coordination flow
- tasks track work progression

## What Changed From s15

| Component      | Before (s15)     | After (s16)                  |
|----------------|------------------|------------------------------|
| Tools          | 9                | 12 (+shutdown_req/resp +plan)|
| Shutdown       | Natural exit only| Request-response handshake   |
| Plan gating    | None             | Submit/review with approval  |
| Correlation    | None             | request_id per request       |
| FSM            | None             | pending -> approved/rejected |

## Try It

```sh
cd learn-claude-code
python agents/s16_team_protocols.py
```

1. `Spawn alice as a coder. Then request her shutdown.`
2. `List teammates to see alice's status after shutdown approval`
3. `Spawn bob with a risky refactoring task. Review and reject his plan.`
4. `Spawn charlie, have him submit a plan, then approve it.`
5. Type `/team` to monitor statuses

## What You've Mastered

At this point, you can:

- Build request-response protocols that use a unique ID for correlation
- Implement graceful shutdown through a two-step handshake
- Gate risky work behind a plan approval step
- Reuse a single FSM pattern (`pending -> approved/rejected`) for any new protocol you invent

## What's Next

Your team now has structure and rules, but the lead still has to babysit every teammate -- assigning tasks one by one, nudging idle workers. In s17, you will make teammates autonomous: they scan the task board themselves, claim unclaimed work, and resume after context compression without losing their identity.

## Key Takeaway

> A protocol request is a structured message with a tracking ID, and the response must reference that same ID -- that single pattern is enough to build any coordination handshake.


---

# s17: Autonomous Agents

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > [ s17 ] > s18 > s19`

## What You'll Learn
- How idle polling lets a teammate find new work without being told
- How auto-claim turns the task board into a self-service work queue
- How identity re-injection restores a teammate's sense of self after context compression
- How a timeout-based shutdown prevents idle agents from running forever

Manual assignment does not scale. With ten unclaimed tasks on the board, the lead has to pick one, find an idle teammate, craft a prompt, and hand it off -- ten times. The lead becomes a bottleneck, spending more time dispatching than thinking. In this chapter you will remove that bottleneck by making teammates autonomous: they scan the task board themselves, claim unclaimed work, and shut down gracefully when there is nothing left to do.

## The Problem

In s15-s16, teammates only work when explicitly told to. The lead must spawn each one with a specific prompt. If ten tasks sit unclaimed on the board, the lead assigns each one manually. This creates a coordination bottleneck that gets worse as the team grows.

True autonomy means teammates scan the task board themselves, claim unclaimed tasks, work on them, then look for more -- all without the lead lifting a finger.

One subtlety makes this harder than it sounds: after context compression (which you built in s06), an agent's conversation history gets truncated. The agent might forget who it is. Identity re-injection fixes this by restoring the agent's name and role when its context gets too short.

## The Solution

Each teammate alternates between two phases: WORK (calling the LLM and executing tools) and IDLE (polling for new messages or unclaimed tasks). If the idle phase times out with nothing to do, the teammate shuts itself down.

```
Teammate lifecycle with idle cycle:

+-------+
| spawn |
+---+---+
    |
    v
+-------+   tool_use     +-------+
| WORK  | <------------- |  LLM  |
+---+---+                +-------+
    |
    | stop_reason != tool_use (or idle tool called)
    v
+--------+
|  IDLE  |  poll every 5s for up to 60s
+---+----+
    |
    +---> check inbox --> message? ----------> WORK
    |
    +---> scan .tasks/ --> unclaimed? -------> claim -> WORK
    |
    +---> 60s timeout ----------------------> SHUTDOWN

Identity re-injection after compression:
  if len(messages) <= 3:
    messages.insert(0, identity_block)
```

## How It Works

**Step 1.** The teammate loop has two phases: WORK and IDLE. During the work phase, the teammate calls the LLM repeatedly and executes tools. When the LLM stops calling tools (or the teammate explicitly calls the `idle` tool), it transitions to the idle phase.

```python
def _loop(self, name, role, prompt):
    while True:
        # -- WORK PHASE --
        messages = [{"role": "user", "content": prompt}]
        for _ in range(50):
            response = client.messages.create(...)
            if response.stop_reason != "tool_use":
                break
            # execute tools...
            if idle_requested:
                break

        # -- IDLE PHASE --
        self._set_status(name, "idle")
        resume = self._idle_poll(name, messages)
        if not resume:
            self._set_status(name, "shutdown")
            return
        self._set_status(name, "working")
```

**Step 2.** The idle phase polls for two things in a loop: inbox messages and unclaimed tasks. It checks every 5 seconds for up to 60 seconds. If a message arrives, the teammate wakes up. If an unclaimed task appears on the board, the teammate claims it and gets back to work. If neither happens within the timeout window, the teammate shuts itself down.

```python
def _idle_poll(self, name, messages):
    for _ in range(IDLE_TIMEOUT // POLL_INTERVAL):  # 60s / 5s = 12
        time.sleep(POLL_INTERVAL)
        inbox = BUS.read_inbox(name)
        if inbox:
            messages.append({"role": "user",
                "content": f"<inbox>{inbox}</inbox>"})
            return True
        unclaimed = scan_unclaimed_tasks()
        if unclaimed:
            claim_task(unclaimed[0]["id"], name)
            messages.append({"role": "user",
                "content": f"<auto-claimed>Task #{unclaimed[0]['id']}: "
                           f"{unclaimed[0]['subject']}</auto-claimed>"})
            return True
    return False  # timeout -> shutdown
```

**Step 3.** Task board scanning finds pending, unowned, unblocked tasks. The scan reads task files from disk and filters for tasks that are available to claim -- no owner, no blocking dependencies, and still in `pending` status.

```python
def scan_unclaimed_tasks() -> list:
    unclaimed = []
    for f in sorted(TASKS_DIR.glob("task_*.json")):
        task = json.loads(f.read_text())
        if (task.get("status") == "pending"
                and not task.get("owner")
                and not task.get("blockedBy")):
            unclaimed.append(task)
    return unclaimed
```

**Step 4.** Identity re-injection handles a subtle problem. After context compression (s06), the conversation history might shrink to just a few messages -- and the agent forgets who it is. When the message list is suspiciously short (3 or fewer messages), the harness inserts an identity block at the beginning so the agent knows its name, role, and team.

```python
if len(messages) <= 3:
    messages.insert(0, {"role": "user",
        "content": f"<identity>You are '{name}', role: {role}, "
                   f"team: {team_name}. Continue your work.</identity>"})
    messages.insert(1, {"role": "assistant",
        "content": f"I am {name}. Continuing."})
```

## Read Together

- If teammate, task, and runtime slot are starting to blur into one layer, revisit [`team-task-lane-model.md`](./team-task-lane-model.md) to separate them clearly.
- If auto-claim makes you wonder where the live execution slot actually lives, keep [`s13a-runtime-task-model.md`](./s13a-runtime-task-model.md) nearby.
- If you are starting to forget the core difference between a persistent teammate and a one-shot subagent, revisit [`entity-map.md`](./entity-map.md).

## What Changed From s16

| Component      | Before (s16)     | After (s17)                |
|----------------|------------------|----------------------------|
| Tools          | 12               | 14 (+idle, +claim_task)    |
| Autonomy       | Lead-directed    | Self-organizing            |
| Idle phase     | None             | Poll inbox + task board    |
| Task claiming  | Manual only      | Auto-claim unclaimed tasks |
| Identity       | System prompt    | + re-injection after compress|
| Timeout        | None             | 60s idle -> auto shutdown  |

## Try It

```sh
cd learn-claude-code
python agents/s17_autonomous_agents.py
```

1. `Create 3 tasks on the board, then spawn alice and bob. Watch them auto-claim.`
2. `Spawn a coder teammate and let it find work from the task board itself`
3. `Create tasks with dependencies. Watch teammates respect the blocked order.`
4. Type `/tasks` to see the task board with owners
5. Type `/team` to monitor who is working vs idle

## What You've Mastered

At this point, you can:

- Build teammates that find and claim work from a shared task board without lead intervention
- Implement an idle polling loop that balances responsiveness with resource efficiency
- Restore agent identity after context compression so long-running teammates stay coherent
- Use timeout-based shutdown to prevent abandoned agents from running indefinitely

## What's Next

Your teammates now organize themselves, but they all share the same working directory. When two agents edit the same file at the same time, things break. In s18, you will give each teammate its own isolated worktree -- a separate copy of the codebase where it can work without stepping on anyone else's changes.

## Key Takeaway

> Autonomous teammates scan the task board, claim unclaimed work, and shut down when idle -- removing the lead as a coordination bottleneck.


---

# s18: Worktree + Task Isolation

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > [ s18 ] > s19`

## What You'll Learn
- How git worktrees (isolated copies of your project directory, managed by git) prevent file conflicts between parallel agents
- How to bind a task to a dedicated worktree so that "what to do" and "where to do it" stay cleanly separated
- How lifecycle events give you an observable record of every create, keep, and remove action
- How parallel execution lanes let multiple agents work on different tasks without ever stepping on each other's files

When two agents both need to edit the same codebase at the same time, you have a problem. Everything you have built so far -- task boards, autonomous agents, team protocols -- assumes that agents work in a single shared directory. That works fine until it does not. This chapter gives every task its own directory, so parallel work stays parallel.

## The Problem

By s17, your agents can claim tasks, coordinate through team protocols, and complete work autonomously. But all of them run in the same project directory. Imagine agent A is refactoring the authentication module, and agent B is building a new login page. Both need to touch `config.py`. Agent A stages its changes, agent B stages different changes to the same file, and now you have a tangled mess of unstaged edits that neither agent can roll back cleanly.

The task board tracks *what to do* but has no opinion about *where to do it*. You need a way to give each task its own isolated working directory, so that file-level operations never collide. The fix is straightforward: pair each task with a git worktree -- a separate checkout of the same repository on its own branch. Tasks manage goals; worktrees manage execution context. Bind them by task ID.

## Read Together

- If task, runtime slot, and worktree lane are blurring together in your head, [`team-task-lane-model.md`](./team-task-lane-model.md) separates them clearly.
- If you want to confirm which fields belong on task records versus worktree records, [`data-structures.md`](./data-structures.md) has the full schema.
- If you want to see why this chapter comes after tasks and teams in the overall curriculum, [`s00e-reference-module-map.md`](./s00e-reference-module-map.md) has the ordering rationale.

## The Solution

The system splits into two planes: a control plane (`.tasks/`) that tracks goals, and an execution plane (`.worktrees/`) that manages isolated directories. Each task points to its worktree by name, and each worktree points back to its task by ID.

```
Control plane (.tasks/)             Execution plane (.worktrees/)
+------------------+                +------------------------+
| task_1.json      |                | auth-refactor/         |
|   status: in_progress  <------>   branch: wt/auth-refactor
|   worktree: "auth-refactor"   |   task_id: 1             |
+------------------+                +------------------------+
| task_2.json      |                | ui-login/              |
|   status: pending    <------>     branch: wt/ui-login
|   worktree: "ui-login"       |   task_id: 2             |
+------------------+                +------------------------+
                                    |
                          index.json (worktree registry)
                          events.jsonl (lifecycle log)

State machines:
  Task:     pending -> in_progress -> completed
  Worktree: absent  -> active      -> removed | kept
```

## How It Works

**Step 1.** Create a task. The goal is recorded first, before any directory exists.

```python
TASKS.create("Implement auth refactor")
# -> .tasks/task_1.json  status=pending  worktree=""
```

**Step 2.** Create a worktree and bind it to the task. Passing `task_id` automatically advances the task to `in_progress` -- you do not need to update the status separately.

```python
WORKTREES.create("auth-refactor", task_id=1)
# -> git worktree add -b wt/auth-refactor .worktrees/auth-refactor HEAD
# -> index.json gets new entry, task_1.json gets worktree="auth-refactor"
```

The binding writes state to both sides so you can traverse the relationship from either direction:

```python
def bind_worktree(self, task_id, worktree):
    task = self._load(task_id)
    task["worktree"] = worktree
    if task["status"] == "pending":
        task["status"] = "in_progress"
    self._save(task)
```

**Step 3.** Run commands in the worktree. The key detail: `cwd` points to the isolated directory, not your main project root. Every file operation happens in a sandbox that cannot collide with other worktrees.

```python
subprocess.run(command, shell=True, cwd=worktree_path,
               capture_output=True, text=True, timeout=300)
```

**Step 4.** Close out the worktree. You have two choices, depending on whether the work is done:

- `worktree_keep(name)` -- preserve the directory for later (useful when a task is paused or needs review).
- `worktree_remove(name, complete_task=True)` -- remove the directory, mark the bound task as completed, and emit an event. One call handles teardown and completion together.

```python
def remove(self, name, force=False, complete_task=False):
    self._run_git(["worktree", "remove", wt["path"]])
    if complete_task and wt.get("task_id") is not None:
        self.tasks.update(wt["task_id"], status="completed")
        self.tasks.unbind_worktree(wt["task_id"])
        self.events.emit("task.completed", ...)
```

**Step 5.** Observe the event stream. Every lifecycle step emits a structured event to `.worktrees/events.jsonl`, giving you a complete audit trail of what happened and when:

```json
{
  "event": "worktree.remove.after",
  "task": {"id": 1, "status": "completed"},
  "worktree": {"name": "auth-refactor", "status": "removed"},
  "ts": 1730000000
}
```

Events emitted: `worktree.create.before/after/failed`, `worktree.remove.before/after/failed`, `worktree.keep`, `task.completed`.

In the teaching version, `.tasks/` plus `.worktrees/index.json` are enough to reconstruct the visible control-plane state after a crash. The important lesson is not every production edge case. The important lesson is that goal state and execution-lane state must both stay legible on disk.

## What Changed From s17

| Component          | Before (s17)               | After (s18)                                  |
|--------------------|----------------------------|----------------------------------------------|
| Coordination       | Task board (owner/status)  | Task board + explicit worktree binding       |
| Execution scope    | Shared directory           | Task-scoped isolated directory               |
| Recoverability     | Task status only           | Task status + worktree index                 |
| Teardown           | Task completion            | Task completion + explicit keep/remove       |
| Lifecycle visibility | Implicit in logs         | Explicit events in `.worktrees/events.jsonl` |

## Try It

```sh
cd learn-claude-code
python agents/s18_worktree_task_isolation.py
```

1. `Create tasks for backend auth and frontend login page, then list tasks.`
2. `Create worktree "auth-refactor" for task 1, then bind task 2 to a new worktree "ui-login".`
3. `Run "git status --short" in worktree "auth-refactor".`
4. `Keep worktree "ui-login", then list worktrees and inspect events.`
5. `Remove worktree "auth-refactor" with complete_task=true, then list tasks/worktrees/events.`

## What You've Mastered

At this point, you can:

- Create isolated git worktrees so that parallel agents never produce file conflicts
- Bind tasks to worktrees with a two-way reference (task points to worktree name, worktree points to task ID)
- Choose between keeping and removing a worktree at closeout, with automatic task status updates
- Read the event stream in `events.jsonl` to understand the full lifecycle of every worktree

## What's Next

You now have agents that can work in complete isolation, each in its own directory with its own branch. But every capability they use -- bash, read, write, edit -- is hard-coded into your Python harness. In s19, you will learn how external programs can provide new capabilities through MCP (Model Context Protocol), so your agent can grow without changing its core code.

## Key Takeaway

> Tasks answer *what work is being done*; worktrees answer *where that work runs*; keeping them separate makes parallel systems far easier to reason about and recover from.


---

# s19: MCP & Plugin

`s01 > s02 > s03 > s04 > s05 > s06 > s07 > s08 > s09 > s10 > s11 > s12 > s13 > s14 > s15 > s16 > s17 > s18 > [ s19 ]`

## What You'll Learn
- How MCP (Model Context Protocol -- a standard way for the agent to talk to external capability servers) lets your agent gain new tools without changing its core code
- How tool name normalization with a `mcp__{server}__{tool}` prefix keeps external tools from colliding with native ones
- How a unified router dispatches tool calls to local handlers or remote servers through the same path
- How plugin manifests let external capability servers be discovered and launched automatically

Up to this point, every tool your agent uses -- bash, read, write, edit, tasks, worktrees -- lives inside your Python harness. You wrote each one by hand. That works well for a teaching codebase, but a real agent needs to talk to databases, browsers, cloud services, and tools that do not exist yet. Hard-coding every possible capability is not sustainable. This chapter shows how external programs can join your agent through the same tool-routing plane you already built.

## The Problem

Your agent is powerful, but its capabilities are frozen at build time. If you want it to query a Postgres database, you write a new Python handler. If you want it to control a browser, you write another handler. Every new capability means changing the core harness, re-testing the tool router, and redeploying. Meanwhile, other teams are building specialized servers that already know how to talk to these systems. You need a standard protocol so those external servers can expose their tools to your agent, and your agent can call them as naturally as it calls its own native tools -- without rewriting the core loop every time.

## The Solution

MCP gives your agent a standard way to connect to external capability servers over stdio. The agent starts a server process, asks what tools it provides, normalizes their names with a prefix, and routes calls to that server -- all through the same tool pipeline that handles native tools.

```text
LLM
  |
  | asks to call a tool
  v
Agent tool router
  |
  +-- native tool  -> local Python handler
  |
  +-- MCP tool     -> external MCP server
                        |
                        v
                    return result
```

## Read Together

- If you want to understand how MCP fits into the broader capability surface beyond just tools (resources, prompts, plugin discovery), [`s19a-mcp-capability-layers.md`](./s19a-mcp-capability-layers.md) covers the full platform boundary.
- If you want to confirm that external capabilities still return through the same execution surface as native tools, pair this chapter with [`s02b-tool-execution-runtime.md`](./s02b-tool-execution-runtime.md).
- If query control and external capability routing are drifting apart in your mental model, [`s00a-query-control-plane.md`](./s00a-query-control-plane.md) ties them together.

## How It Works

There are three essential pieces. Once you understand them, MCP stops being mysterious.

**Step 1.** Build an `MCPClient` that manages the connection to one external server. It starts the server process over stdio, sends a handshake, and caches the list of available tools.

```python
class MCPClient:
    def __init__(self, server_name, command, args=None, env=None):
        self.server_name = server_name
        self.command = command
        self.args = args or []
        self.process = None
        self._tools = []

    def connect(self):
        self.process = subprocess.Popen(
            [self.command] + self.args,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, text=True,
        )
        self._send({"method": "initialize", "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "teaching-agent", "version": "1.0"},
        }})
        response = self._recv()
        if response and "result" in response:
            self._send({"method": "notifications/initialized"})
            return True
        return False

    def list_tools(self):
        self._send({"method": "tools/list", "params": {}})
        response = self._recv()
        if response and "result" in response:
            self._tools = response["result"].get("tools", [])
        return self._tools

    def call_tool(self, tool_name, arguments):
        self._send({"method": "tools/call", "params": {
            "name": tool_name, "arguments": arguments,
        }})
        response = self._recv()
        if response and "result" in response:
            content = response["result"].get("content", [])
            return "\n".join(c.get("text", str(c)) for c in content)
        return "MCP Error: no response"
```

**Step 2.** Normalize external tool names with a prefix so they never collide with native tools. The convention is simple: `mcp__{server}__{tool}`.

```text
mcp__postgres__query
mcp__browser__open_tab
```

This prefix serves double duty: it prevents name collisions, and it tells the router exactly which server should handle the call.

```python
def get_agent_tools(self):
    agent_tools = []
    for tool in self._tools:
        prefixed_name = f"mcp__{self.server_name}__{tool['name']}"
        agent_tools.append({
            "name": prefixed_name,
            "description": tool.get("description", ""),
            "input_schema": tool.get("inputSchema", {
                "type": "object", "properties": {}
            }),
        })
    return agent_tools
```

**Step 3.** Build one unified router. The router does not care whether a tool is native or external beyond the dispatch decision. If the name starts with `mcp__`, route to the MCP server; otherwise, call the local handler. This keeps the agent loop untouched -- it just sees a flat list of tools.

```python
if tool_name.startswith("mcp__"):
    return mcp_router.call(tool_name, arguments)
else:
    return native_handler(arguments)
```

**Step 4.** Add plugin discovery. If MCP answers "how does the agent talk to an external capability server," plugins answer "how are those servers discovered and configured?" A minimal plugin is a manifest file that tells the harness which servers to launch:

```json
{
  "name": "my-db-tools",
  "version": "1.0.0",
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"]
    }
  }
}
```

This lives in `.claude-plugin/plugin.json`. The `PluginLoader` scans for these manifests, extracts the server configs, and hands them to the `MCPToolRouter` for connection.

**Step 5.** Enforce the safety boundary. This is the most important rule of the entire chapter: external tools must still pass through the same permission gate as native tools. If MCP tools bypass permission checks, you have created a security backdoor at the edge of your system.

```python
decision = permission_gate.check(block.name, block.input or {})
# Same check for "bash", "read_file", and "mcp__postgres__query"
```

## How It Plugs Into The Full Harness

MCP gets confusing when it is treated like a separate universe. The cleaner model is:

```text
startup
  ->
plugin loader finds manifests
  ->
server configs are extracted
  ->
MCP clients connect and list tools
  ->
external tools are normalized into the same tool pool

runtime
  ->
LLM emits tool_use
  ->
shared permission gate
  ->
native route or MCP route
  ->
result normalization
  ->
tool_result returns to the same loop
```

Different entry point, same control plane and execution plane.

## Plugin vs Server vs Tool

| Layer | What it is | What it is for |
|---|---|---|
| plugin manifest | a config declaration | tells the harness which servers to discover and launch |
| MCP server | an external process / connection | exposes a set of capabilities |
| MCP tool | one callable capability from that server | the concrete thing the model invokes |

Shortest memory aid:

- plugin = discovery
- server = connection
- tool = invocation

## Key Data Structures

### Server config

```python
{
    "command": "npx",
    "args": ["-y", "..."],
    "env": {}
}
```

### Normalized external tool definition

```python
{
    "name": "mcp__postgres__query",
    "description": "Run a SQL query",
    "input_schema": {...}
}
```

### Client registry

```python
clients = {
    "postgres": mcp_client_instance
}
```

## What Changed From s18

| Component          | Before (s18)                      | After (s19)                                      |
|--------------------|-----------------------------------|--------------------------------------------------|
| Tool sources       | All native (local Python)         | Native + external MCP servers                    |
| Tool naming        | Flat names (`bash`, `read_file`)  | Prefixed for externals (`mcp__postgres__query`)  |
| Routing            | Single handler map                | Unified router: native dispatch + MCP dispatch   |
| Capability growth  | Edit harness code for each tool   | Add a plugin manifest or connect a server        |
| Permission scope   | Native tools only                 | Native + external tools through same gate        |

## Try It

```sh
cd learn-claude-code
python agents/s19_mcp_plugin.py
```

1. Watch how external tools are discovered from plugin manifests at startup.
2. Type `/tools` to see native and MCP tools listed side by side in one flat pool.
3. Type `/mcp` to see which MCP servers are connected and how many tools each provides.
4. Ask the agent to use a tool and notice how results return through the same loop as local tools.

## What You've Mastered

At this point, you can:

- Connect to external capability servers using the MCP stdio protocol
- Normalize external tool names with a `mcp__{server}__{tool}` prefix to prevent collisions
- Route tool calls through a unified dispatcher that handles both native and MCP tools
- Discover and launch MCP servers automatically through plugin manifests
- Enforce the same permission checks on external tools as on native ones

## The Full Picture

You have now walked through the complete design backbone of a production coding agent, from s01 to s19.

You started with a bare agent loop that calls an LLM and appends tool results. You added tool use, then a persistent task list, then subagents, skill loading, and context compaction. You built a permission system, a hook system, and a memory system. You constructed the system prompt pipeline, added error recovery, and gave agents a full task board with background execution and cron scheduling. You organized agents into teams with coordination protocols, made them autonomous, gave each task its own isolated worktree, and finally opened the door to external capabilities through MCP.

Each chapter added exactly one idea to the system. None of them required you to throw away what came before. The agent you have now is not a toy -- it is a working model of the same architectural decisions that shape real production agents.

If you want to test your understanding, try rebuilding the complete system from scratch. Start with the agent loop. Add tools. Add tasks. Keep going until you reach MCP. If you can do that without looking back at the chapters, you understand the design. And if you get stuck somewhere in the middle, the chapter that covers that idea will be waiting for you.

## Key Takeaway

> External capabilities should enter the same tool pipeline as native ones -- same naming, same routing, same permissions -- so the agent loop never needs to know the difference.


---

# s19a: MCP Capability Layers

> **Deep Dive** -- Best read alongside s19. It shows that MCP is more than just external tools.

### When to Read This

After reading s19's tools-first approach, when you're ready to see the full MCP capability stack.

---

> `s19` should still keep a tools-first mainline.
> This bridge note adds the second mental model:
>
> **MCP is not only external tool access. It is a stack of capability layers.**

## How to Read This with the Mainline

If you want to study MCP without drifting away from the teaching goal:

- read [`s19-mcp-plugin.md`](./s19-mcp-plugin.md) first and keep the tools-first path clear
- then you might find it helpful to revisit [`s02a-tool-control-plane.md`](./s02a-tool-control-plane.md) to see how external capability routes back into the unified tool bus
- if state records begin to blur, you might find it helpful to revisit [`data-structures.md`](./data-structures.md)
- if concept boundaries blur, you might find it helpful to revisit [`glossary.md`](./glossary.md) and [`entity-map.md`](./entity-map.md)

## Why This Deserves a Separate Bridge Note

For a teaching repo, keeping the mainline focused on external tools first is correct.

That is the easiest entry:

- connect an external server
- receive tool definitions
- call a tool
- bring the result back into the agent

But if you want the system shape to approach real high-completion behavior, you quickly meet deeper questions:

- is the server connected through stdio, HTTP, SSE, or WebSocket
- why are some servers `connected`, while others are `pending` or `needs-auth`
- where do resources and prompts fit relative to tools
- why does elicitation become a special kind of interaction
- where should OAuth or other auth flows be placed conceptually

Without a capability-layer map, MCP starts to feel scattered.

## Terms First

### What capability layers means

A capability layer is simply:

> one responsibility slice in a larger system

The point is to avoid mixing every MCP concern into one bag.

### What transport means

Transport is the connection channel between your agent and an MCP server:

- stdio (standard input/output, good for local processes)
- HTTP
- SSE (Server-Sent Events, a one-way streaming protocol over HTTP)
- WebSocket

### What elicitation means

This is one of the less familiar terms.

A simple teaching definition is:

> an interaction where the MCP server asks the user for more input before it can continue

So the system is no longer only:

> agent calls tool -> tool returns result

The server can also say:

> I need more information before I can finish

This turns a simple call-and-return into a multi-step conversation between the agent and the server.

## The Minimum Mental Model

A clear six-layer picture:

```text
1. Config Layer
   what the server configuration looks like

2. Transport Layer
   how the server connection is carried

3. Connection State Layer
   connected / pending / failed / needs-auth

4. Capability Layer
   tools / resources / prompts / elicitation

5. Auth Layer
   whether authentication is required and what state it is in

6. Router Integration Layer
   how MCP routes back into tool routing, permissions, and notifications
```

The key lesson is:

**tools are one layer, not the whole MCP story**

## Why the Mainline Should Still Stay Tools-First

This matters a lot for teaching.

Even though MCP contains multiple layers, the chapter mainline should still teach:

### Step 1: external tools first

Because that connects most naturally to everything you already learned:

- local tools
- external tools
- one shared router

### Step 2: show that more capability layers exist

For example:

- resources
- prompts
- elicitation
- auth

### Step 3: decide which advanced layers the repo should actually implement

That matches the teaching goal:

**build the similar system first, then add the heavier platform layers**

## Core Records

### 1. `ScopedMcpServerConfig`

Even a minimal teaching version should expose this idea:

```python
config = {
    "name": "postgres",
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "..."],
    "scope": "project",
}
```

`scope` matters because server configuration may come from different places (global user settings, project-level settings, or even per-workspace overrides).

### 2. MCP connection state

```python
server_state = {
    "name": "postgres",
    "status": "connected",   # pending / failed / needs-auth / disabled
    "config": {...},
}
```

### 3. `MCPToolSpec`

```python
tool = {
    "name": "mcp__postgres__query",
    "description": "...",
    "input_schema": {...},
}
```

### 4. `ElicitationRequest`

```python
request = {
    "server_name": "some-server",
    "message": "Please provide additional input",
    "requested_schema": {...},
}
```

The teaching point is not that you need to implement elicitation immediately.

The point is:

**MCP is not guaranteed to stay a one-way tool invocation forever**

## The Cleaner Platform Picture

```text
MCP Config
  |
  v
Transport
  |
  v
Connection State
  |
  +-- connected
  +-- pending
  +-- needs-auth
  +-- failed
  |
  v
Capabilities
  +-- tools
  +-- resources
  +-- prompts
  +-- elicitation
  |
  v
Router / Permission / Notification Integration
```

## Why Auth Should Not Dominate the Chapter Mainline

Auth is a real layer in the full platform.

But if the mainline falls into OAuth or vendor-specific auth flow details too early, beginners lose the actual system shape.

A better teaching order is:

- first explain that an auth layer exists
- then explain that `connected` and `needs-auth` are different connection states
- only later, in advanced platform work, expand the full auth state machine

That keeps the repo honest without derailing your learning path.

## How This Relates to `s19` and `s02a`

- the `s19` chapter keeps teaching the tools-first external capability path
- this note supplies the broader platform map
- `s02a` explains how MCP capability eventually reconnects to the unified tool control plane

Together, they teach the actual idea:

**MCP is an external capability platform, and tools are only the first face of it that enters the mainline**

## Common Beginner Mistakes

### 1. Treating MCP as only an external tool catalog

That makes resources, prompts, auth, and elicitation feel surprising later.

### 2. Diving into transport or OAuth details too early

That breaks the teaching mainline.

### 3. Letting MCP tools bypass permission checks

That opens a dangerous side door in the system boundary.

### 4. Mixing server config, connection state, and exposed capabilities into one blob

Those layers should stay conceptually separate.

## Key Takeaway

**MCP is a six-layer capability platform. Tools are the first layer you build, but resources, prompts, elicitation, auth, and router integration are all part of the full picture.**
