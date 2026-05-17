# Local AI stack (llamacpp, vllm, open-webui, comfyui, n8n). Enable via userSettings.docker.containers.localai.enable.
{ config, lib, ... }:

{
  imports = [ ./llamaswap.nix ];
  config.userSettings.docker.containers.localai.enable = lib.mkDefault true;
}
