{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.userSettings.streaming;
in
{
  options = {
    userSettings.streaming = {
      enable = lib.mkEnableOption "Streaming tools (OBS Studio, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chatterino7
      streamcontroller

      # Video Creation
      # davinci-resolve-studio
      kdePackages.kdenlive
    ];

    programs.obs-studio = {
      enable = true;

      # optional Nvidia hardware acceleration
      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vkcapture
        obs-multi-rtmp
        obs-vaapi
        obs-gstreamer
        obs-vkcapture
      ];
    };
  };
}
