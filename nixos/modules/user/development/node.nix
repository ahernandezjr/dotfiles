{ config, lib, pkgs, ... }:

let
  dev = config.userSettings.development;
in
{
  # Node / JS tooling that hangs off the main development toggle.
  config = lib.mkIf dev.enable {
    home.packages = with pkgs; [
      nodejs
      pnpm
      claude-code
      cursor-cli
      gemini-cli
    ];
  };
}


