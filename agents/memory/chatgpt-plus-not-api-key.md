---
name: chatgpt-plus-not-api-key
description: ChatGPT Plus does not include an OpenAI API key; Codex CLI runs on the subscription via chatgpt auth mode, no key needed
metadata:
  node_type: memory
  type: reference
---

Ved resubscribed to ChatGPT Plus on 2026-08-04 and asked how to get his API key from it. There
isn't one. ChatGPT Plus (chatgpt.com, $20/mo subscription) and the OpenAI API
(platform.openai.com, pay-as-you-go per token) are separate products with separate billing.

Codex CLI supports both auth paths. Ved is on the subscription path — `codex login status` reports
"Logged in using ChatGPT" and `codex doctor` shows `stored auth mode: chatgpt`. Nothing to fetch or
paste.

**How to apply:** If he asks about an OpenAI API key again, check `codex login status` first rather
than sending him to platform.openai.com — creating a key there would bill him a second time, per
token, while the Plus plan sits unused. Setting `OPENAI_API_KEY` in the environment actively breaks
this: Codex switches to API-key mode and stops using the subscription. See
[[openai-api-key-scoping]] for the `sk-local` llama.cpp variable that caused exactly that.
