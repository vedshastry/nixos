---
name: local-llm-setup
description: How offline local LLM inference is set up on the ThinkPad T14 (NixOS) and why iGPU is unused
metadata: 
  node_type: memory
  type: project
  originSessionId: 71a7a824-5a41-4348-a66c-44d502563fbd
---

Offline local LLM stack on ved's ThinkPad T14 Gen 5 (Ryzen 7 PRO 8840U, Radeon 780M iGPU, 61 GB RAM, no dGPU). Config in /home/ved/repos/nixos (host `thinkpad`, home-manager as a NixOS module → apply with `sudo nixos-rebuild switch --flake /home/ved/repos/nixos#thinkpad`).

**Chosen default:** OLMoE-1B-7B-0924-Instruct Q8_0 (~6.9 GB GGUF in ~/ai), served by the `llama-server` user service on :8080 (router/models-dir mode). Benchmarked **~34 tok/s generation, ~200 tok/s prompt on CPU** — fast because only ~1B params are active (MoE). Instant startup, low battery draw. Good for flights.

**Why the 780M iGPU is NOT used (deliberately):** llama.cpp was rebuilt with `vulkanSupport = true` (old build was CPU/BLAS-only, GPU never touched). Vulkan DOES detect the 780M (RADV PHOENIX, fp16 + KHR_coopmat, ~30 GB addressable), BUT:
- First-run Vulkan shader compilation takes **5+ minutes** (single-threaded RADV compile), even for a 4B model.
- Generation is memory-bandwidth-bound; iGPU shares the CPU RAM bus → ~no tok/s gain over CPU for small-active models.
So server defaults to CPU (no `-ngl`). Vulkan build kept available; add `-ngl 99` only to experiment with prompt-heavy runs on big dense models. Shader cache persisted via MESA_SHADER_CACHE_DIR.

**Other models on disk:** ollama has qwen3.5:27b (2.6 tok/s CPU — slow fallback for hard reasoning), gemma2:9b (~7 tok/s), qwen2.5-coder:7b (~10 tok/s). ~/ai also has gemma-4-12B and Qwen3.6-27B GGUFs. The prior `ollama-rocm` service never engaged the GPU either (gfx1103 ROCm override failed → 100% CPU).

Note: `llama-cli` interactive mode hangs on this setup; use `llama-bench` or the server API instead. Related: [[user-profile]].
