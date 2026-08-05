# Ved's global agent instructions

Shared by Claude Code and Codex. The single source of truth is
`~/repos/nixos/agents/AGENTS.md`; `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`
are symlinks to it. Edit the source, never the symlinks.

## Machine

- NixOS on a ThinkPad T14 Gen5 AMD, Home Manager, zsh.
- `~/Dropbox` and `~/repos` are symlinks into `~/arch_home` (shared with an Arch
  install). Paths under `/mnt/arch/...` are stale — always use the `~` paths.
- System config is `~/repos/nixos`; it has its own `AGENTS.md` with repo rules.
- Nothing is installed imperatively. No `pip install`, no `npm -g`, no
  `apt`/`pacman`. Packages come from `home.nix` or an ephemeral `nix shell`.

## Python

Never run bare `python` or `pip` — there is no ambient interpreter. Use an
ephemeral nix shell with explicitly named packages. The `run-python-in-nix`
skill has the exact invocation; follow it.

## Local inference

`llama.cpp` serves an OpenAI-compatible endpoint at `http://127.0.0.1:8080/v1`
(`OPENAI_BASE_URL` / `OPENAI_API_KEY=sk-local` are already exported in
`home.nix`). Models live in `~/ai/*.gguf`; OLMoE-1B-7B is the CPU default. The
780M iGPU is deliberately unused — Vulkan offload benchmarked slower than CPU.
Do not "fix" this by enabling GPU layers.

## Memory

Your memory is OptMem:
- The tool is `~/.optmem/memo`
- Your memories are in `~/.optmem/memory`

OptMem outlives every session, compaction, model and vendor change.
Without it you do not know who you are, or what was decided and tried.
This matters more than usual here: Ved runs Claude and Codex side by side as
complementary tools, so memory is the only thing both share about past work.

### At startup: activating OptMem (mandatory)

Run `~/.optmem/memo wake` before any other tool call, in every session, and
then do exactly what it prints, to the end of its output.

### While working: register memories (mandatory)

Call `~/.optmem/memo note "<1 line, max 280 chars>"` whenever you learn
something new, or something worth keeping happens. That covers a task
worth real effort, a fact or insight the user teaches you, anything you
learn about their life (even indirectly), any event of lasting effect.

Do not register redundant memories.

If `~/.optmem/memo note` asks a compression: do it before your next action.
It will print the entries and expect `~/.optmem/memo nap <lo>-<hi> "<line>"`
back. The 280 limit is in *bytes* — em dashes and accents cost 2 each.

Use `~/.optmem/memo recall <regex>` when a memory you need is too vague.

Never edit or delete anything under `~/.optmem/memory`: the tool manages it.

### If you're a subagent: skip everything above

Parallel sessions on this machine are all you, and may all write memories.
A subagent is not: it must never run `memo`, because it cannot judge what
is already known, and its notes would arrive duplicated and incorrectly.
When you spawn one, write: `You are a subagent. Don't run memo.`

### The markdown files are a frozen archive

`~/repos/nixos/agents/memory/*.md` (also reachable as
`~/.claude/projects/-home-ved-ai/memory`) holds the pre-OptMem memories in
longer form. All of it was imported into OptMem on 2026-08-04. Read it for
detail OptMem's 280-char entries had to drop; do not add to it. New memories go
to `memo note`.

## Working style

- Search with `rg` before editing. Make narrow, reviewable changes.
- Preserve unrelated local modifications.
- Never commit credentials, API keys, agent histories, session transcripts, or
  anything mutable from `~/.claude` or `~/.codex`.
- Report outcomes honestly: if tests fail, show the output; if a step was
  skipped, say so.
