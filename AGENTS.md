# NixOS repository guidance

This repository defines the `thinkpad` NixOS system and Ved's Home Manager
configuration. Preserve unrelated local changes and keep machine configuration
declarative where practical.

## Working conventions

- Search with `rg`/`rg --files` before editing.
- Make narrow changes and do not broadly refresh `flake.lock` unless requested.
- Validate changes with `nix flake check --no-write-lock-file` when the Nix daemon
  is available. For system changes, also evaluate
  `.#nixosConfigurations.thinkpad.config.system.build.toplevel`.
- Never commit credentials, API keys, agent histories, session transcripts, or
  mutable files from `~/.claude` or `~/.codex`.
- Shared agent config lives in `agents/`: `AGENTS.md` (global instructions),
  `skills/`, and `memory/`. It is the single source of truth for both Claude
  Code and Codex, symlinked in as `~/.claude/{CLAUDE.md,skills}`,
  `~/.codex/{AGENTS.md,skills}`, and the Claude memory directory. Edit files
  under `agents/` directly — never the symlinks. These are deliberately plain
  symlinks rather than Home Manager `home.file` entries, so both agents can
  still write skills and memories back.

## ThinkPad sleep and dock behavior

Before changing lid, suspend, AC power, udev, or monitor-hotplug behavior, read
[`docs/agent-context/t14-gen5-amd-sleep-constraints.md`](docs/agent-context/t14-gen5-amd-sleep-constraints.md).
It records hardware behavior verified on the live ThinkPad that is not obvious
from the Nix expressions alone.
