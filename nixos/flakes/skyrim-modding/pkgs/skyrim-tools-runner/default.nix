# Skyrim Tools Wine/Proton Runner Script
# Sets up Steam GE-Proton10-34 compatibility sandbox, maps WINEPREFIX to Skyrim SE compatdata (App ID 489830),
# sets STEAM_COMPAT_MOUNTS, and runs Windows tools (xEdit, DynDOLOD, Nemesis, Synthesis) using steam-run.
{ pkgs, writeShellScriptBin, ge-proton-10-34 }:

writeShellScriptBin "skyrim-tools-runner" ''
  set -euo pipefail

  COMPAT_TOOLS_DIR="$HOME/.local/share/Steam/compatibilitytools.d"
  GE_DIR="$COMPAT_TOOLS_DIR/GE-Proton10-34"

  # Ensure GE-Proton10-34 is linked into Steam's compatibilitytools.d directory
  if [ ! -d "$GE_DIR" ]; then
    echo "Linking GE-Proton10-34 to Steam compatibilitytools.d..."
    mkdir -p "$COMPAT_TOOLS_DIR"
    ln -sfn "${ge-proton-10-34}/share/steam/compatibilitytools.d/GE-Proton10-34" "$GE_DIR"
  fi

  # Default environment variables for Skyrim SE (App ID: 489830)
  export STEAM_COMPAT_CLIENT_INSTALL_PATH="''${STEAM_COMPAT_CLIENT_INSTALL_PATH:-$HOME/.local/share/Steam}"
  export STEAM_COMPAT_DATA_PATH="''${STEAM_COMPAT_DATA_PATH:-$HOME/.local/share/Steam/steamapps/compatdata/489830}"
  export WINEPREFIX="''${WINEPREFIX:-$STEAM_COMPAT_DATA_PATH/pfx}"
  export STEAM_COMPAT_MOUNTS="''${STEAM_COMPAT_MOUNTS:-/mnt/linuxgames}"

  mkdir -p "$WINEPREFIX"

  echo "=== Skyrim Modding Tools Proton Runner (GE-Proton10-34) ==="
  echo "WINEPREFIX: $WINEPREFIX"
  echo "STEAM_COMPAT_MOUNTS: $STEAM_COMPAT_MOUNTS"

  if [ "$#" -eq 0 ]; then
    echo "Usage: skyrim-tools-runner <executable or command> [args...]"
    echo "Examples:"
    echo "  skyrim-tools-runner /mnt/linuxgames/Modlists/skyrim/ModOrganizer.exe"
    echo "  skyrim-tools-runner /path/to/SSEEdit.exe -sse"
    echo "  skyrim-tools-runner /path/to/DynDOLOD.exe"
    echo "  skyrim-tools-runner /path/to/Nemesis.exe"
    exit 0
  fi

  EXEC="$1"
  shift

  # Run via steam-run using GE-Proton10-34's proton executable for complete DXVK/VKD3D/Wine library loading
  if [ -f "$GE_DIR/proton" ]; then
    exec ${pkgs.steam-run}/bin/steam-run "$GE_DIR/proton" run "$EXEC" "$@"
  elif [ -f "$GE_DIR/files/bin/wine" ]; then
    exec ${pkgs.steam-run}/bin/steam-run "$GE_DIR/files/bin/wine" "$EXEC" "$@"
  else
    echo "Error: Could not locate Proton launcher inside GE-Proton10-34 at $GE_DIR" >&2
    exit 1
  fi
''
