---
name: openai-api-key-scoping
description: OPENAI_BASE_URL/OPENAI_API_KEY must never be exported globally — Codex CLI honours them and routes a real ChatGPT session at local llama.cpp
metadata:
  type: project
---

`home.nix` used to export `OPENAI_BASE_URL=http://127.0.0.1:8080/v1` and
`OPENAI_API_KEY=sk-local` in `programs.zsh.sessionVariables` for llama.cpp.
Removed 2026-08-04; replaced by a `local-ai` zsh function that scopes them to
one command (`local-ai <cmd ...>`).

**Why:** Codex CLI reads both variables. With them exported globally,
`codex doctor` reported "mixed auth signals: ChatGPT login plus API key env
var; HTTP reachability uses API-key mode" — a real subscription session would
have been silently pointed at the local OLMoE server instead of OpenAI.

**How to apply:** Never reinstate these as global session variables. Anything
needing the local endpoint gets `local-ai` or an explicit per-command prefix.
The doctor warning persists in already-open shells until a rebuild and a fresh
shell. See [[local-llm-setup]] and [[shared-agent-config]].
