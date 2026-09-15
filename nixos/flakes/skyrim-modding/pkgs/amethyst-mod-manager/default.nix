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
  version = "2.4.0";

  src = fetchurl {
    url = "https://github.com/ChrisDKN/Amethyst-Mod-Manager/releases/download/v${version}/AmethystModManager-${version}-x86_64.AppImage";
    sha256 = "11pmy9gj93fqahbl4vmxyhn0r6zi9hpp7rzdj089b0k482gb5x99";
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
      find $out -xtype l -delete
    '';
  };

  fhs = buildFHSEnv {
    name = "amethyst-mod-manager-fhs";
    targetPkgs = pkgs: with pkgs; [
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
      fuse
      zenity
      xdg-utils
      coreutils
      bash
      python3
      pkgsi686Linux.glibc
      pkgsi686Linux.freetype
      pkgsi686Linux.vulkan-loader
    ];
    extraBinds = [
      "/mnt"
      "/media"
      "/run/user"
      "/run/opengl-driver"
      "/run/opengl-driver-32"
      "/etc/profiles/per-user"
    ];
    runScript = writeScript "amethyst-runner" ''
      #!/usr/bin/env bash
      export QT_QPA_PLATFORM=xcb
      export APPDIR="${extracted}/opt/AppDir"
      export PYTHONPATH="${extracted}/opt/AppDir/share/amethyst-mod-manager:${extracted}/opt/AppDir/share/amethyst-mod-manager/_vendor:$PYTHONPATH"
      export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH"
      export APPIMAGE="amethyst-mod-manager"
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




