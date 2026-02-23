# This file configures Niri at the system level.
{ config, pkgs, ... }: # Added config to match argument list for general purpose modules
{
  programs.niri = {
    enable = true;
  };
}
