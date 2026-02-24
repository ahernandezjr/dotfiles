# Stylix: system-wide theming (colors, fonts, cursor) from a single base image.
# Uses path from ~/.cache/noctalia/wallpapers.json if present, else first image in wallpapers dir.
# See https://github.com/nix-community/stylix
{ config, lib, pkgs, ... }:

let
  home = config.users.users.alex.home;
  wallpapersDir = "${home}/Pictures/Wallpapers";
  cacheWallpapersJson = "${home}/.cache/noctalia/wallpapers.json";
  # Parse wallpapers.json: expect array of paths or { path = "..." }; take first path.
  pathFromJson = content:
    let
      data = builtins.fromJSON content;
      path = if builtins.isList data && data != [ ] then builtins.head data
        else if builtins.isAttrs data && data ? path then data.path
        else if builtins.isAttrs data && data ? current then data.current
        else null;
    in
      path;
  # Prefer path from cache wallpapers.json; else first image in wallpapers directory
  baseImage =
    if builtins.pathExists cacheWallpapersJson then
      let
        raw = builtins.readFile cacheWallpapersJson;
        wpPath = pathFromJson raw;
      in
        if wpPath != null && wpPath != "" && builtins.pathExists wpPath then
          builtins.path { path = wpPath; name = "stylix-wallpaper"; }
        else null
    else null;
  baseImageFallback =
    if baseImage != null then baseImage
    else if builtins.pathExists wallpapersDir then
      let
        wp = builtins.path { path = wallpapersDir; name = "wallpapers"; };
        names = builtins.attrNames (builtins.readDir wp);
        isImage = n: builtins.match ".*\\.(png|jpg|jpeg|webp)$" (builtins.toLower n) != null;
        images = builtins.filter isImage names;
        first = if images != [ ] then builtins.head (builtins.sort builtins.lessThan images) else null;
      in
        if first != null then wp + "/${first}" else null
    else null;
in
{
  stylix = {
    enable = true;
    polarity = "dark";
  } // lib.optionalAttrs (baseImageFallback != null) { baseImage = baseImageFallback; };
}
