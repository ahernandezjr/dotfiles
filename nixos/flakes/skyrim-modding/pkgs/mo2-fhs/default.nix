# Mod Organizer 2 FHS Runner Script
# Automatically discovers ModOrganizer.exe under /mnt/linuxgames (or custom MO2_EXE_PATH)
# and launches it inside the GE-Proton10-34 Skyrim SE Wine prefix using skyrim-tools-runner.
# Installs official Mod Organizer 2 icon into $out/share/icons/hicolor/256x256/apps/modorganizer2.png.
{ stdenv, fetchurl, writeShellScriptBin, skyrim-tools-runner }:

let
  mo2Icon = fetchurl {
    url = "https://avatars.githubusercontent.com/u/37225415?s=280&v=4";
    sha256 = "1r4qvvihgig35rprsvfmfcr7m7yb4w0w5mzz1j1k6dsxzv1s9axv";
  };

  runnerScript = writeShellScriptBin "mo2-fhs" ''
    set -euo pipefail

    MO2_PATH="''${MO2_EXE_PATH:-/mnt/linuxgames/Modlists/skyrim/ModOrganizer.exe}"

    if [ ! -f "$MO2_PATH" ]; then
      if [ "$#" -gt 0 ] && [ -f "$1" ]; then
        MO2_PATH="$1"
        shift
      else
        echo "Searching for ModOrganizer.exe under /mnt/linuxgames..."
        MO2_FOUND=$(find /mnt/linuxgames -name "ModOrganizer.exe" 2>/dev/null | head -n 1 || true)
        if [ -n "$MO2_FOUND" ]; then
          MO2_PATH="$MO2_FOUND"
        else
          echo "Error: ModOrganizer.exe not found at $MO2_PATH or in /mnt/linuxgames." >&2
          echo "Please set MO2_EXE_PATH environment variable or pass the path as an argument." >&2
          exit 1
        fi
      fi
    fi

    echo "Launching Mod Organizer 2 via GE-Proton10-34: $MO2_PATH"
    exec ${skyrim-tools-runner}/bin/skyrim-tools-runner "$MO2_PATH" "$@"
  '';
in
stdenv.mkDerivation {
  pname = "mo2-fhs";
  version = "1.0.0";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/icons/hicolor/256x256/apps
    cp ${runnerScript}/bin/mo2-fhs $out/bin/mo2-fhs
    chmod +x $out/bin/mo2-fhs
    cp ${mo2Icon} $out/share/icons/hicolor/256x256/apps/modorganizer2.png
  '';
}
