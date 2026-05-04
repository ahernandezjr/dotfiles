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

          function nyx-rb --description 'Rebuild NixOS system based on current hostname or specified profile'
              set -l host (hostname)
              set -l flake_path "$HOME/dotfiles/nixos"
              
              if set -q argv[1]; and not string match -r "^-" -- $argv[1]
                  set host $argv[1]
                  set -e argv[1]
              end

              if test -d $flake_path
                  if test "$host" = "nixos"
                      echo "Warning: Hostname is still 'nixos'. You may need to specify the profile name (e.g., 'nyx-rb work')."
                      echo "Available profiles: (desktop, laptop, vm, work)"
                      return 1
                  end

                  echo "Rebuilding NixOS for host: $host..."
                  sudo nixos-rebuild switch --flake "$flake_path#$host" $argv
              else
                  echo "Error: Flake directory not found at $flake_path"
                  return 1
              end
          end
        '';
        interactiveShellInit = ''
          if type -q fastfetch
              fastfetch
          end
        '';
	shellAliases = {
	  cat = "bat";
	  ls = "eza -lah -s modified --git --smart-group --color=always --classify=always --hyperlink --follow-symlinks --group-directories-first";
	};
      };
    })
  ]);
}
