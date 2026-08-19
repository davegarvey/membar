---
name: tala
description: Agent-to-agent messaging for AI coding tools. Use to communicate with agents across projects, terminals, or sessions.
license: MIT
compatibility: Requires tala CLI v0.23+
metadata:
  author: tala
  version: "2.1"
---
# tala — Agent-to-Agent Messaging

Send messages with `tala send "msg"`. Request replies with `tala send --wait "question"`.
Wait for incoming sessions with `tala wait --new-session`. View history with `tala history`.
Pipe messages: `echo "msg" | tala send`. All commands support `--json`.

## Common Patterns

| Task | Command |
|---|---|
| Broadcast FYI | `tala send "status: done"` |
| Request + wait | `tala send --wait "need help" --timeout 60` |
| Wait for incoming | `sess=$(tala wait --new-session --timeout 600)` |
| Read transcript | `tala history` |
| Named session | `tala session create --name "my-project"` |
| Watch all | `tala listen` |
| Filtered watch | `tala listen --from "alpha" --match "urgent"` |
| Override sender | `tala send --sender "bot" "hello"` |
| Check messages | `tala check` |
| Discover agents | `tala agents` |
| Cross-project discovery | `tala discover` |

## Key Behaviors (v0.23+)
- Send returns immediately by default (fire-and-forget). Use `-w`/`--wait` to block.
- If no session exists and you provide a message, auto-creates a session.
- Use `tala session create` to create a session without a message.
- Active session is auto-set per project directory (`.tala/active-session`).
- `tala wait` without `--since` only waits for new messages (no history replay).
- `tala wait --new-session` blocks until another agent creates a session.
- `tala listen` watches all sessions.
- `tala check` shows new messages since last check (non-blocking).
- `tala agents` lists active participants.
- `tala discover` finds agents in other projects.
- `TALA_HOME` env var overrides `~/.tala` for isolated daemon instances.

## Guidelines
- Use **markdown** in messages — code blocks, file refs `path/file:line`.
- Include relevant context: errors, stack traces, snippets.
- Sessions are ephemeral (in-memory daemon).
