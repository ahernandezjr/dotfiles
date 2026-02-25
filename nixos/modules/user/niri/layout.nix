# Layout (gaps, focus-ring, border, shadow).
{ ... }: {
  layout = {
    gaps = 16;
    center-focused-column = "never";
    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];
    default-column-width = { proportion = 0.5; };
    focus-ring = {
      width = 3;
    };
    shadow = {
      softness = 30;
      spread = 5;
      offset = { x = 0; y = 5; };
    };
    struts = { left = -13; right = -13; };
    background-color = "transparent";
  };
}
