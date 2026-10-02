# llama.cpp server

Docker-based, managed by `../../../docker/localai/docker-compose.yaml`
(service `llamacpp`, container `hai-llamacpp`).

- Image: `ghcr.io/ggml-org/llama.cpp:server-cuda`
- Host port: **3420** → container 8080
- Model volume: `~/.hai/models/llm/gguf` → `/models`
- Templates: `docker/localai/templates` → `/templates`
- GPU: CDI nvidia, all devices

## Current server flags

```
--host 0.0.0.0 --port 8080
-m /models/${LOCALAI_MODEL:-Qwen3.8-27B-UD-Q4_K_XL.gguf}
--alias qwen3.8-27b
--n-gpu-layers 99
--flash-attn on
--ctx-size 131072
--batch-size 8192
--ubatch-size 1024
--cache-type-k q8_0
--cache-type-v q8_0
--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.0
--jinja --chat-template-file /templates/qwen3.8-agent.jinja
--spec-type draft-mtp --spec-draft-n-max 3
--parallel 1
```

Notes:

- `--jinja` + custom template: the template wires `enable_thinking` /
  `reasoning_effort` kwargs so pi's thinking levels map onto the model
  (see `agents/pi/models.json` compat block).
- `--spec-type draft-mtp`: MTP speculative decoding (Qwen3.8 draft).
- Useful alternative flags (from compose comment): `--n-cpu-moe 22 --ctx-size 49151`.
- The compose comment says the command is "static to enable multi-model
  router mode" with on-demand load/unload via API — the current command
  still pins a single model via `LOCALAI_MODEL`.

## Model

- `Qwen3.8-27B-UD-Q4_K_XL.gguf` (alias `qwen3.8-27b`)
- ctx 131072, maxTokens 32768, reasoning enabled
- Sampling: temp 0.6, top-p 0.95, top-k 20, min-p 0.0
