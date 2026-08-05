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
- Shared agent config lives OUTSIDE this repo, at `~/agents/` (`AGENTS.md`,
  `skills/`, `memory/`), plain-symlinked into `~/.claude/{CLAUDE.md,skills}`
  and `~/.codex/{AGENTS.md,skills}`. It is deliberately not version-controlled
  here: both agents write into it at runtime (Codex installs its own `.system`
  skills there), so it is mutable state, not configuration. Never re-add an
  `agents/` directory to this repo.
- Durable memory is OptMem (`~/.optmem/memo`), also outside this repo.

## ThinkPad sleep and dock behavior

Before changing lid, suspend, AC power, udev, or monitor-hotplug behavior, read
[`docs/agent-context/t14-gen5-amd-sleep-constraints.md`](docs/agent-context/t14-gen5-amd-sleep-constraints.md).
It records hardware behavior verified on the live ThinkPad that is not obvious
from the Nix expressions alone.
