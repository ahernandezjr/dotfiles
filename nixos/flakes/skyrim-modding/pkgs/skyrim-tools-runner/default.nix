# Skyrim Tools Wine/Proton Runner Script
# Sets up Steam Proton compatibility sandbox, maps WINEPREFIX to Skyrim SE compatdata (App ID 489830),
# sets STEAM_COMPAT_MOUNTS, Win32 AppData environment variables, and executes Windows tools (SSEEdit, DynDOLOD, Nemesis, Synthesis).
{
  pkgs,
  writeShellScriptBin,
  ge-proton-10-34,
}:

writeShellScriptBin "skyrim-tools-runner" ''
  set -euo pipefail

  COMPAT_TOOLS_DIR="$HOME/.local/share/Steam/compatibilitytools.d"
  PROTON_NAME="''${PROTON_NAME:-UMU-Proton-10.0-4}"
  if [ ! -d "$COMPAT_TOOLS_DIR/$PROTON_NAME" ]; then
    PROTON_NAME="GE-Proton10-34"
  fi
  TOOL_DIR="$COMPAT_TOOLS_DIR/$PROTON_NAME"

  # Ensure GE-Proton10-34 is linked into Steam's compatibilitytools.d directory
  if [ ! -d "$COMPAT_TOOLS_DIR/GE-Proton10-34" ]; then
    mkdir -p "$COMPAT_TOOLS_DIR"
    ln -sfn "${ge-proton-10-34}/share/steam/compatibilitytools.d/GE-Proton10-34" "$COMPAT_TOOLS_DIR/GE-Proton10-34"
  fi

  # Default environment variables for Skyrim SE (App ID: 489830)
  export STEAM_COMPAT_CLIENT_INSTALL_PATH="''${STEAM_COMPAT_CLIENT_INSTALL_PATH:-$HOME/.local/share/Steam}"
  export STEAM_COMPAT_DATA_PATH="''${STEAM_COMPAT_DATA_PATH:-$HOME/.local/share/Steam/steamapps/compatdata/489830}"
  export WINEPREFIX="''${WINEPREFIX:-$STEAM_COMPAT_DATA_PATH/pfx}"
  export STEAM_COMPAT_MOUNTS="''${STEAM_COMPAT_MOUNTS:-/mnt/linuxgames}"

  # Fix Win32 AppData environment variables and FreeType library path for Delphi/FontAwesome UI (SSEEdit Code 203)
  export USERPROFILE="''${USERPROFILE:-Z:$WINEPREFIX/drive_c/users/steamuser}"
  export LOCALAPPDATA="''${LOCALAPPDATA:-Z:$WINEPREFIX/drive_c/users/steamuser/AppData/Local}"
  export APPDATA="''${APPDATA:-Z:$WINEPREFIX/drive_c/users/steamuser/AppData/Roaming}"
  export LD_LIBRARY_PATH="${pkgs.freetype}/lib:${pkgs.pkgsi686Linux.freetype}/lib:''${LD_LIBRARY_PATH:-}"

  mkdir -p "$WINEPREFIX"

  if [ "$#" -eq 0 ]; then
    echo "=== Skyrim Modding Tools Proton Runner ($PROTON_NAME) ==="
    echo "WINEPREFIX: $WINEPREFIX"
    echo "STEAM_COMPAT_MOUNTS: $STEAM_COMPAT_MOUNTS"
    echo "Usage: skyrim-tools-runner <executable or command> [args...]"
    echo "Examples:"
    echo "  skyrim-tools-runner /mnt/linuxgames/Modlists/Amethyst/Skyrim\\ Special\\ Edition/Applications/SSEEdit/SSEEdit.exe"
    echo "  skyrim-tools-runner /mnt/linuxgames/Modlists/Amethyst/Skyrim\\ Special\\ Edition/Applications/SSEEdit/SSEEditQuickAutoClean.exe"
    exit 0
  fi

  EXEC="$1"
  shift

  if [ -f "$TOOL_DIR/proton" ]; then
    exec "$TOOL_DIR/proton" run "$EXEC" "$@"
  elif [ -f "$TOOL_DIR/files/bin/wine" ]; then
    exec "$TOOL_DIR/files/bin/wine" "$EXEC" "$@"
  else
    echo "Error: Could not locate Proton launcher inside $TOOL_DIR" >&2
    exit 1
  fi
''

