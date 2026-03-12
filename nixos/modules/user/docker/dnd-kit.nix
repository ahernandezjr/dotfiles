# dnd-kit stack (Foundry VTT, STT, optional summarizer/image-api). Enable via
# userSettings.docker.containers.dnd-kit.enable. For summarization and image gen,
# also enable localai so hai-network and hai-llamacpp/hai-comfyui exist.
{ config, lib, ... }:

{
  config.userSettings.docker.containers.dnd-kit.enable = lib.mkDefault false;
}
