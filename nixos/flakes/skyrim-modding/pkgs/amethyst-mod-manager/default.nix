{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  writeScript,
  makeWrapper,
}:

let
  pname = "amethyst-mod-manager";
  version = "2.5.2";

  src = fetchurl {
    url = "https://github.com/ChrisDKN/Amethyst-Mod-Manager/releases/download/v${version}/AmethystModManager-${version}-x86_64.AppImage";
    sha256 = "1dsf3xb44rsbihd4dmq9di3czibsqkp5h42mvwggnnyd6slgzwir";
  };

  amethystLogo = fetchurl {
    url = "https://raw.githubusercontent.com/ChrisDKN/Amethyst-Mod-Manager/main/src/icons/Logo.png";
    sha256 = "0idzvxq4mrqla402anip2p72h3ymzc0n5bryhgcqkhxchcbym2a6";
  };

  extracted = stdenv.mkDerivation {
    name = "${pname}-extracted-${version}";
    inherit src;
    dontUnpack = true;
    dontPatchELF = true;
    installPhase = ''
      mkdir -p $out/opt
      cp $src $out/opt/amethyst.AppImage
      chmod +x $out/opt/amethyst.AppImage
      cd $out/opt
      $out/opt/amethyst.AppImage --appimage-extract >/dev/null
      rm $out/opt/amethyst.AppImage
      mv squashfs-root $out/opt/AppDir
      substituteInPlace $out/opt/AppDir/share/amethyst-mod-manager/Utils/launchers/steam.py \
        --replace-warn $'        for descriptor in Path(f"/proc/{pid}/fd").iterdir():\n            try:\n                descriptor_stat = descriptor.stat()\n            except OSError:' $'        for descriptor in Path(f"/proc/{pid}/fd").iterdir():\n            try:\n                descriptor_stat = descriptor.stat()\n            except PermissionError:\n                return True\n            except OSError:'
      find $out -xtype l -delete
    '';
  };

  fhs = buildFHSEnv {
    name = "amethyst-mod-manager-fhs";
    extraBwrapArgs = [
      "--bind"
      "/proc"
      "/proc"
    ];
    targetPkgs = pkgs: with pkgs; [
      bubblewrap
      fuse-overlayfs
      icu
      openssl
      vulkan-loader
      libxkbcommon
      wayland
      glib
      gtk3
      dbus
      libglvnd
      freetype
      fontconfig
      fuse
      zenity
      xdg-utils
      coreutils
      bash
      python3
      sqlite
      mesa
      alsa-lib
      gnutls
      libx11
      libxext
      libxcursor
      libxrandr
      libxinerama
      libxi
      libxxf86vm
      libxrender
      libxcomposite
      libxdamage
      libxcb

      pkgsi686Linux.glibc
      pkgsi686Linux.freetype
      pkgsi686Linux.fontconfig
      pkgsi686Linux.vulkan-loader
      pkgsi686Linux.sqlite
      pkgsi686Linux.libglvnd
      pkgsi686Linux.mesa
      pkgsi686Linux.alsa-lib
      pkgsi686Linux.gnutls
      pkgsi686Linux.libx11
      pkgsi686Linux.libxext
      pkgsi686Linux.libxcursor
      pkgsi686Linux.libxrandr
      pkgsi686Linux.libxinerama
      pkgsi686Linux.libxi
      pkgsi686Linux.libxxf86vm
      pkgsi686Linux.libxrender
      pkgsi686Linux.libxcomposite
      pkgsi686Linux.libxdamage
      pkgsi686Linux.libxcb
    ];
    extraOutputsToInstall = [ "lib" "out" ];
    extraBinds = [
      "/tmp"
      "/mnt"
      "/media"
      "/run/user"
      "/run/opengl-driver"
      "/run/opengl-driver-32"
      "/etc/profiles/per-user"
    ];
    runScript = writeScript "amethyst-runner" ''
      #!/usr/bin/env bash
      export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-wayland;xcb}"
      export APPDIR="${extracted}/opt/AppDir"
      export PYTHONPATH="${extracted}/opt/AppDir/share/amethyst-mod-manager:${extracted}/opt/AppDir/share/amethyst-mod-manager/_vendor:$PYTHONPATH"
      export LD_LIBRARY_PATH="/lib:/lib64:/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH"
      export APPIMAGE="amethyst-mod-manager"

      # Export default Win32 AppData environment variables for SSEEdit / Delphi / Proton tools launched INSIDE Amethyst
      export USERPROFILE="C:\\users\\steamuser"
      export LOCALAPPDATA="C:\\users\\steamuser\\AppData\\Local"
      export APPDATA="C:\\users\\steamuser\\AppData\\Roaming"

      cd "${extracted}/opt/AppDir/share/amethyst-mod-manager"
      exec "${extracted}/opt/AppDir/AppRun" "$@"
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/icons/hicolor/256x256/apps
    makeWrapper ${fhs}/bin/amethyst-mod-manager-fhs $out/bin/amethyst-mod-manager
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




