function nyx-rb --description 'Rebuild NixOS system based on current hostname'
    set -l host (hostname)
    set -l flake_path "$HOME/dotfiles/nixos"
    
    # Check if we are in the dotfiles directory or use absolute path
    if test -d $flake_path
        echo "Rebuilding NixOS for host: $host..."
        sudo nixos-rebuild switch --flake "$flake_path#$host" $argv
    else
        echo "Error: Flake directory not found at $flake_path"
        return 1
    end
end
