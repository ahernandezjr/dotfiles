{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "fish") (lib.mkMerge [
    { home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish"; }
    (lib.mkIf cfg.manageConfig {
      programs.fish = {
        enable = true;
        shellInit = ''
          if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
              source /usr/share/cachyos-fish-config/cachyos-config.fish
          end

          set -gx PATH $HOME/.npm-global/bin $PATH

          function reboot-windows
              sudo efibootmgr -n 0 && sudo systemctl reboot
          end
        '';
        interactiveShellInit = ''
          if type -q neofetch
              neofetch
          end
        '';
      };
    })
  ]);
}
