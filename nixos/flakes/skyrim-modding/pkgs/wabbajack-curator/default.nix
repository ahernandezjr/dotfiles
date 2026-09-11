{ lib, pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "wabbajack-curator";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ pkgs.python3 ];

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    cp wabbajack_curator.py $out/bin/wabbajack-curator
    chmod +x $out/bin/wabbajack-curator

    wrapProgram $out/bin/wabbajack-curator \
      --prefix PATH : ${lib.makeBinPath [ pkgs.python3 pkgs.xdg-utils ]}

    cat <<EOF > $out/share/applications/wabbajack-curator.desktop
[Desktop Entry]
Name=Wabbajack Modlist Curator
Comment=Terminal TUI tool to parse, compare, and curate mods from Wabbajack modlist files
Exec=$out/bin/wabbajack-curator
Icon=terminal
Terminal=true
Type=Application
Categories=Game;Utility;
EOF
  '';

  meta = with lib; {
    description = "Wabbajack Modlist Curator & Mod Comparison Suite (Terminal TUI)";
    homepage = "https://github.com/wabbajack-tools/wabbajack";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "wabbajack-curator";
  };
}
