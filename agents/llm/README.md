# llm/

Configs for the local LLM stack. Model weights never go in git.

## Stack (Hekarch AI)

The docker stack lives in `../../docker/localai/` (compose file, templates,
docs). This directory holds per-engine configs and notes that the compose
references or that document how a server is configured.

| Engine    | Port | Image                          | Status  |
|-----------|------|--------------------------------|---------|
| llama.cpp | 3420 | ghcr.io/ggml-org/llama.cpp:server-cuda | active |
| vLLM      | 3421 | vllm/vllm-openai:latest        | profile `donotstart` |
| Open WebUI| 3430 | ghcr.io/open-webui/open-webui  | active |
| ComfyUI   | 3431 | yanwk/comfyui-boot:nightly     | active |
| n8n       | 3432 | n8nio/n8n:latest               | profile `donotstart` |
| Cognee    | 3440 | cognee/cognee:main             | profile `cognee` |

## Model storage

- GGUF models: `~/.hai/models/llm/gguf/` (mounted at `/models` in the
  llama.cpp container)
- Chat templates: `../../docker/localai/templates/` (mounted at `/templates`)
- Caches: `~/.hai/cache/`

## Consumers

Both harnesses point at the llama.cpp server:

- pi: `agents/pi/models.json` → provider `llamacpp`,
  `baseUrl: http://localhost:3420/v1`
- codex: `agents/codex/config.toml` → `[model_providers.llamacpp]`,
  `base_url = "http://localhost:3420/v1"`, `wire_api = "responses"`

The codex model catalog is generated, not hand-edited:
`python3 ../../docker/localai/codex/make-catalog.py` →
`~/.codex/model-catalog.json`.

## Adding a model

1. Download the GGUF into `~/.hai/models/llm/gguf/`.
2. If it needs a custom chat template, add it to
   `../../docker/localai/templates/`.
3. Update the llama.cpp service command in
   `../../docker/localai/docker-compose.yaml` (or set `LOCALAI_MODEL`).
4. Add the model to `agents/pi/models.json` (pi) and regenerate the codex
   catalog.
