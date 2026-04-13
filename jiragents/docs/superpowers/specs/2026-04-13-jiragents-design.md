# JirAgents -- Task Board for AI Agents

## Overview

A local Rails application that mimics Jira but for AI agents. Humans create tasks and assign them to named agents. Assignment triggers autonomous execution via Claude Code CLI. Each agent works in an isolated git worktree.

## Data Model

### Agent

| Column      | Type   | Notes                        |
|-------------|--------|------------------------------|
| id          | integer| PK                           |
| name        | string | Required, unique (e.g. "Sara", "Omar") |
| description | text   | What this agent is about     |
| created_at  | datetime |                            |
| updated_at  | datetime |                            |

All agents have full Claude Code capabilities. They are identity containers -- like employees on a team.

### Task

| Column            | Type     | Notes                                      |
|-------------------|----------|--------------------------------------------|
| id                | integer  | PK                                         |
| agent_id          | integer  | FK to Agent, required                      |
| title             | string   | Required                                   |
| description       | text     | The full task prompt sent to Claude         |
| status            | string   | enum: pending, running, completed, failed  |
| result            | text     | Final output from the agent                |
| branch_name       | string   | Git branch created for worktree            |
| working_directory | string   | The repo path the agent works in           |
| started_at        | datetime | When execution began                       |
| completed_at      | datetime | When execution finished                    |
| created_at        | datetime |                                            |
| updated_at        | datetime |                                            |

## Architecture

```
Rails App (local)
├── Web UI (Turbo/Stimulus + Tailwind)
├── Controllers (standard RESTful)
├── Models (Agent, Task)
├── Solid Queue (async background jobs)
└── SQLite (local database)
```

### Tech Stack

- Rails 8.0 with SQLite
- Solid Queue for background jobs (in-process, no Redis)
- Hotwire (Turbo Streams for live status updates)
- Tailwind CSS for styling
- Claude Code CLI for agent execution

### Agent Execution Flow

1. User creates a task and assigns it to an agent
2. Task saved with status `pending`
3. `AgentExecutionJob` enqueued automatically (via `after_create` callback)
4. Job runs:
   a. Update task status to `running`, set `started_at`
   b. Create git worktree: `git worktree add <path> -b agent/<agent-name>/<task-id>`
   c. Execute: `claude --print -p "<task description>" --output-format stream-json` in the worktree directory
   d. Capture final result text
   e. Update task: set `result`, `status` to `completed`, `completed_at`
   f. On error: set `status` to `failed`, store error in `result`
5. Turbo Stream broadcasts task update to the UI

### Branch Naming

Pattern: `agent/<agent-name-parameterized>/<task-id>`

Example: `agent/sara/42`

### Worktree Management

- Worktrees created under a temporary path derived from the working directory
- Worktrees are NOT auto-removed after completion so the user can review the branch
- The user merges/deletes branches manually

## UI Pages

### Dashboard (`/`)
- Quick stats: total agents, tasks by status
- Recent task activity

### Agents (`/agents`)
- `/agents` -- list of agent cards (name, description, task count)
- `/agents/new` -- create agent form (name, description)
- `/agents/:id` -- agent detail with their task history

### Tasks (`/tasks`)
- `/tasks` -- all tasks list, filterable by status and agent
- `/tasks/new` -- create task form (title, description, select agent, working directory)
- `/tasks/:id` -- task detail (status badge, assigned agent, result output, branch name)

### UI Style
- Clean, minimal Tailwind
- Simple lists and cards (no kanban board)
- Status badges: gray (pending), blue (running), green (completed), red (failed)
- Turbo Stream broadcasts for live status updates (no polling)

## Scope

This is the MVP. Explicitly out of scope for now:
- Kanban board view
- Task dependencies
- Agent-to-agent handoffs
- Comments/collaboration
- Streaming agent output
- Custom tool configuration per agent
- Agent cancellation mid-execution
