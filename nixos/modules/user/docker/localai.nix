# Local AI stack (llamacpp, vllm, open-webui, comfyui, n8n). Enable via userSettings.docker.containers.localai.enable.
{ config, lib, ... }:

{
  config.userSettings.docker.containers.localai.enable = lib.mkDefault true;
}
