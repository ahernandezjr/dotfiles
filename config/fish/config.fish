source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
set -gx PATH $HOME/.npm-global/bin $PATH

# Reboot into Windows
function reboot-windows
    sudo efibootmgr -n 0 && sudo systemctl reboot
end
