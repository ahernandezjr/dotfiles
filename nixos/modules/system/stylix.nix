# Stylix: system-wide theming (colors, fonts, cursor).
# Use a fixed wallpaper image for palette + background.
{ ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";
    image = ../../images/wallpaper.jpg;
  };
}
