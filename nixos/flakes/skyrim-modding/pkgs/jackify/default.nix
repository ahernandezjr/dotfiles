{
  lib,
  pkgs,
  fetchurl,
  appimageTools,
  buildFHSEnv,
}:

let
  pname = "jackify";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/Omni-guides/Jackify/releases/download/v${version}/Jackify.AppImage";
    hash = "sha256-NZWeoijFAl4xVoF7Gl7TRx3DTxcb6fTk4KFjFdRCt5o=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
buildFHSEnv {
  name = pname;

  multiArch = true;

  targetPkgs =
    pkgs:
    (with pkgs; [
      appimageContents
      bash
      coreutils
      protontricks

      # Python runtime
      python3

      # Tools used by Jackify & Wabbajack
      cabextract
      winetricks
      gnupg
      wget
      curl
      unzip
      p7zip
      xz
      perl
      procps
      which
      file
      findutils
      gawk
      gnused
      gnugrep
      zenity
      kdePackages.kdialog

      # C++ & Compiler runtime libraries
      stdenv.cc.cc.lib

      # Network, Kerberos, SSL & Crypto libraries
      krb5
      keyutils
      libpsl
      nghttp2
      libssh2
      glib-networking
      openssl

      # X11 libraries
      libX11
      libXext
      libXcursor
      libXi
      libXrandr
      libXrender
      libXcomposite
      libXdamage
      libXfixes
      libXtst
      libXinerama
      libXft
      libXpm
      libXv
      libXxf86vm
      libSM
      libICE

      # GUI, Wayland & PySide6 / Qt6 dependencies
      libxkbcommon
      libxkbfile
      libxcb
      xcbutil
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      xcbutilwm
      xcbutilcursor
      wayland
      libdecor
      fontconfig
      freetype
      harfbuzz
      glib
      gtk3
      pango
      cairo
      gdk-pixbuf
      at-spi2-core
      qt6.qtbase
      qt6.qtwayland

      # 64-bit Wine/Proton/AppImage runtime libraries
      icu
      zlib
      gnutls
      libGL
      libGLU
      libglvnd
      libdrm
      mesa
      libvdpau
      libva
      vulkan-loader
      alsa-lib
      libpulseaudio
      pipewire
      dbus
      udev
      libxml2
      libxslt
      ncurses
    ])
    ++ (pkgs.steam.args.targetPkgs pkgs);

  multiPkgs =
    pkgs:
    (with pkgs; [
      # 32-bit C++ & network runtime
      pkgsi686Linux.stdenv.cc.cc.lib
      pkgsi686Linux.krb5
      pkgsi686Linux.keyutils
      pkgsi686Linux.libpsl
      pkgsi686Linux.nghttp2

      # 32-bit X11 libraries
      pkgsi686Linux.libX11
      pkgsi686Linux.libXext
      pkgsi686Linux.libXcursor
      pkgsi686Linux.libXi
      pkgsi686Linux.libXrandr
      pkgsi686Linux.libXrender
      pkgsi686Linux.libXcomposite
      pkgsi686Linux.libXdamage
      pkgsi686Linux.libXfixes
      pkgsi686Linux.libXtst
      pkgsi686Linux.libXinerama
      pkgsi686Linux.libSM
      pkgsi686Linux.libICE

      # 32-bit runtime libraries for Wine/Proton
      pkgsi686Linux.glibc
      pkgsi686Linux.freetype
      pkgsi686Linux.gnutls
      pkgsi686Linux.libGL
      pkgsi686Linux.libglvnd
      pkgsi686Linux.libdrm
      pkgsi686Linux.mesa
      pkgsi686Linux.vulkan-loader
      pkgsi686Linux.alsa-lib
      pkgsi686Linux.libpulseaudio
      pkgsi686Linux.dbus
      pkgsi686Linux.udev
      pkgsi686Linux.fontconfig
      pkgsi686Linux.ncurses
      pkgsi686Linux.libxkbcommon
      pkgsi686Linux.libxcb
    ])
    ++ (pkgs.steam.args.multiPkgs pkgs);

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    if [ -f ${appimageContents}/com.jackify.app.desktop ]; then
      cp ${appimageContents}/com.jackify.app.desktop $out/share/applications/com.jackify.app.desktop
      substituteInPlace $out/share/applications/com.jackify.app.desktop \
        --replace-warn "Exec=jackify" "Exec=$out/bin/${pname}"
    fi

    mkdir -p $out/share/icons/hicolor/256x256/apps
    if [ -f ${appimageContents}/com.jackify.app.png ]; then
      cp ${appimageContents}/com.jackify.app.png $out/share/icons/hicolor/256x256/apps/com.jackify.app.png
    fi
  '';

  runScript = "${appimageContents}/AppRun";

  meta = with lib; {
    description = "Linux-native Wabbajack modlist installer";
    homepage = "https://github.com/Omni-guides/Jackify";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "jackify";
  };
}
