> **FROZEN ARCHIVE (2026-08-04).** Authoritative memory is now OptMem (`~/.optmem/memo`).
> Everything below was imported there. Read for detail; do not add. New memories go to `memo note`.

- [Local LLM setup](local-llm-setup.md) — offline inference on the ThinkPad; OLMoE on CPU is default, 780M iGPU deliberately unused (Vulkan too slow)
- [Codex code-mode-host fix](codex-code-mode-host-fix.md) — UNPARKED 2026-08-04: code-mode helper was missing via codex-cli-nix; re-test on 0.146.0 before trusting the old diagnosis
- [Claude over Codex for NixOS](claude-over-codex-for-nixos.md) — his prior is Claude for NixOS work, but he resubscribed to Plus 2026-08-04 and is re-evaluating
- [Shared agent config](shared-agent-config.md) — one source of truth in ~/repos/nixos/agents/, symlinked into both ~/.claude and ~/.codex; plain symlinks on purpose
- [OpenAI API key scoping](openai-api-key-scoping.md) — never export OPENAI_BASE_URL/OPENAI_API_KEY globally; Codex hijacks them to the local llama server
- [ChatGPT Plus is not an API key](chatgpt-plus-not-api-key.md) — Plus includes no API key; Codex runs on the subscription via chatgpt auth mode
