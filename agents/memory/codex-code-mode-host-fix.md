---
name: codex-code-mode-host-fix
description: "Codex \"code mode\" broke on this NixOS box (missing codex-code-mode-host helper); unparked 2026-08-04 on resubscribe — re-test before trusting the old diagnosis"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4ed37112-9776-4c9f-b9ca-9e10ebf7c94e
---

**Status (2026-08-04): UNPARKED, UNVERIFIED.** Parked 2026-07-16 when Ved cancelled the
subscription mid-debug. He resubscribed to ChatGPT Plus 2026-08-04 and Codex is in active use
again. Two things have changed since the diagnosis below, neither tested: Codex is now
`codex-cli 0.146.0`, and `codex features list` reports `code_mode_host` as **stable / true**.
Re-test the symptom before acting on any analysis below — it may already be fixed upstream.

**Symptom:** Codex CLI (from the `codex-cli-nix` flake) fails in "code mode" before running any
command: `codex-code-mode-host: No such file or directory`. Restarting never helps — Codex
misdiagnoses it as a stale workspace / permission issue.

**Corrected root cause (my first guess was wrong):** it is NOT codex re-execing itself via
`$CODEX_EXECUTABLE_PATH`. `codex-code-mode-host` is a SEPARATE helper binary that codex tries to
`exec` and can't find. The `codex-cli-nix` flake DOES fetch it — there's
`/nix/store/9plw8zbb48qn57wi1jcrjxx2d6fpykq6-codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz`
in the store — but the packaging never extracts/installs that binary onto codex's path. So it's a
**packaging gap in codex-cli-nix**, not a workspace or permission problem. The real fix would be to
extract that tarball's binary and place it where codex looks (likely alongside the codex binary or
via an env var like CODEX_CODE_MODE_HOST — never confirmed which). Not resolved.

**Debug leftovers: RESOLVED 2026-08-04.** A previous session had added a `codex-cli` let-binding
and `home.file.".local/bin/codex"` to `home.nix` based on the wrong diagnosis. Verified gone —
`home.nix` now only references Codex via the flake package, and `~/.local/bin/codex` no longer
exists. Nothing to revert.

See [[claude-over-codex-for-nixos]], [[local-llm-setup]], [[shared-agent-config]].
