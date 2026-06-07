{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.creativity;
  excalidraw = pkgs.writeShellScriptBin "excalidraw" ''
    exec ${pkgs.brave}/bin/brave --app=https://excalidraw.com "$@"
  '';
in
{
  options = {
    userSettings.creativity = {
      enable = lib.mkEnableOption "Creativity tools (OrcaSlicer, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      orca-slicer
      excalidraw
    ];

    xdg.desktopEntries.excalidraw = {
      name = "Excalidraw";
      exec = "excalidraw";
      icon = "draw-freehand";
      comment = "Collaborative digital whiteboard";
      terminal = false;
      categories = [ "Utility" "Graphics" ];
    };
  };
}
