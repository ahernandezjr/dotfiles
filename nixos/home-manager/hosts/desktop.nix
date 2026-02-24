{ ... }:

{
  imports = [ ../home.nix ];

  userSettings = {
    gaming.enable = true;
    cuda.enable = true;
    niri.useDesktopOutputs = true;
  };
}
