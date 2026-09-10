# GloriousEggroll GE-Proton10-34 Compatibility Tool Derivation
# Downloads and extracts GE-Proton10-34 tarball into $out/share/steam/compatibilitytools.d/GE-Proton10-34.
{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "ge-proton-bin";
  version = "10-34";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${version}/GE-Proton${version}.tar.gz";
    sha256 = "0gbpipk3x7hqslp2y2h4aiv1jmxcxqbhf3z0iycp6g43dav81iai";
  };

  buildCommand = ''
    mkdir -p $out/share/steam/compatibilitytools.d/GE-Proton${version}
    tar -xf $src -C $out/share/steam/compatibilitytools.d/GE-Proton${version} --strip-components=1
  '';

  meta = with lib; {
    description = "GloriousEggroll's custom Proton build GE-Proton10-34";
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
