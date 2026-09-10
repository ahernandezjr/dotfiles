# Amethyst Mod Manager Derivation
# Copies the Linux-native Amethyst Mod Manager (v2.4.0) AppImage directly into $out/bin,
# and installs the official Amethyst Logo icon into $out/share/icons/hicolor/256x256/apps/amethyst-mod-manager.png.
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:

let
  amethystLogo = fetchurl {
    url = "https://raw.githubusercontent.com/ChrisDKN/Amethyst-Mod-Manager/main/src/icons/Logo.png";
    sha256 = "0idzvxq4mrqla402anip2p72h3ymzc0n5bryhgcqkhxchcbym2a6";
  };
in
stdenv.mkDerivation rec {
  pname = "amethyst-mod-manager";
  version = "2.4.0";

  src = fetchurl {
    url = "https://github.com/ChrisDKN/Amethyst-Mod-Manager/releases/download/v${version}/AmethystModManager-${version}-x86_64.AppImage";
    sha256 = "11pmy9gj93fqahbl4vmxyhn0r6zi9hpp7rzdj089b0k482gb5x99";
  };

  dontUnpack = true;
  dontStrip = true;
  dontPatchELF = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/icons/hicolor/256x256/apps
    cp $src $out/bin/amethyst-mod-manager
    chmod +x $out/bin/amethyst-mod-manager
    cp ${amethystLogo} $out/share/icons/hicolor/256x256/apps/amethyst-mod-manager.png
  '';

  meta = with lib; {
    description = "Linux-native mod manager inspired by Mod Organizer 2 and Vortex";
    homepage = "https://github.com/ChrisDKN/Amethyst-Mod-Manager";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "amethyst-mod-manager";
  };
}
