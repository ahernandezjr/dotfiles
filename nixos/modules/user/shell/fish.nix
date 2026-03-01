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
        # Plugins: each entry must be { name = "..."; src = <package>; }
        plugins = with pkgs; [
          { name = "autopair"; src = fishPlugins.autopair; }
          { name = "fzf-fish"; src = fishPlugins.fzf-fish; }
        ];
        shellInit = ''
          # Add custom paths using the idiomatic fish_add_path (handles duplicates and existence checks)
          fish_add_path $HOME/.npm-global/bin
          fish_add_path /run/wrappers/bin

          set -gx fish_browser floorp

          function reboot-windows
              sudo efibootmgr -n 0 && sudo systemctl reboot
          end
        '';
        interactiveShellInit = ''
          if type -q neofetch
              neofetch --source ~/dotfiles/images/blood_ascii --ascii_colors 1 2
          end
        '';
	shellAliases = {
	  cat = "bat";
	  grep = "rg";
	  ls = "eza -lah --git --smart-group --color=always --classify=always --hyperlink --follow-symlinks --group-directories-first";
          nyx-rb = "/run/wrappers/bin/sudo nixos-rebuild switch --flake ~/dotfiles/nixos#desktop";
	};
      };
    })
  ]);
}
