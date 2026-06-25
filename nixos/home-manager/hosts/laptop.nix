{ ... }:

{
  imports = [ ../home.nix ];

  userSettings = {
    noctalia.isPortable = true;
  };
}
