{ pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];
}
