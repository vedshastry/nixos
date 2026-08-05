---
name: shared-agent-config
description: Claude Code and Codex share one config source in ~/repos/nixos/agents/ via plain symlinks; edit the source, never the symlinks
metadata:
  type: project
---

Set up 2026-08-04. `~/repos/nixos/agents/` holds `AGENTS.md`, `skills/`, and
`memory/` as the single source of truth for both Claude Code and Codex.
Symlinked in as `~/.claude/CLAUDE.md`, `~/.claude/skills`,
`~/.claude/projects/-home-ved-ai/memory`, `~/.codex/AGENTS.md`, and
`~/.codex/skills`.

**Why:** Ved was giving OpenAI a shot and wanted the dual-boot pattern he uses
in `~/repos/nixos` — one source, two consumers. Before this, skills existed in
three drifted copies (`~/.claude/skills`, `~/.codex/skills` empty,
`~/.agents/skills` stale) and `~/.agents/AGENTS.md` mandated an OptMem system
that had never recorded a single memory. `~/.agents/` was deleted.

**How to apply:** Edit files under `agents/` directly, never through the
symlinks. These are deliberately plain `ln -s` symlinks, not Home Manager
`home.file` entries — `home.file` would make them read-only `/nix/store` paths
and neither agent could write skills or memories back. Do not "make it
declarative" without solving that. See [[openai-api-key-scoping]] and
[[claude-over-codex-for-nixos]].
