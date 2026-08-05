---
name: claude-over-codex-for-nixos
description: Ved found Claude notably better than Codex at his non-standard NixOS setup; resubscribed to ChatGPT Plus 2026-08-04 to retry Codex
metadata:
  node_type: memory
  type: user
  originSessionId: 4ed37112-9776-4c9f-b9ca-9e10ebf7c94e
---

Ved cancelled and refunded his Codex subscription on 2026-07-16. His view then: the quality gap
between Claude and Codex is real — Codex is "built for cookie-cutter macOS devs" and struggled
with his setup, while Claude (even Opus 4.8) is "remarkably good at debugging my NixOS setup."

**Update 2026-08-04:** he resubscribed to ChatGPT Plus to give OpenAI another shot, and had both
agents set up to share one config source. Treat the preference above as his prior, not a settled
verdict — he is actively re-evaluating. Don't assume Codex is uninstalled or unwanted.

**How to apply:** He runs a non-standard, declarative NixOS/Home Manager environment (flakes, dwm,
ThinkPad T14 Gen5 AMD) and values tooling that reasons about it from first principles rather than
assuming a conventional macOS/Linux install. Lean into careful, environment-specific debugging;
don't assume standard install paths or `~/.local/bin` installers — his binaries come from the Nix
store. See [[codex-code-mode-host-fix]], [[shared-agent-config]], [[chatgpt-plus-not-api-key]].
