# Layout (gaps, focus-ring, shadow, struts)
{ lib }: {
  layout = {
    gaps = 16;
    center-focused-column = "never";
    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];
    focus-ring = {
      width = 3;
      active.gradient = { from = "#6b0c05"; to = "#ffffff"; angle = 135; };
    };
    shadow = {
      softness = 30;
      spread = 5;
      offset = { x = 0; y = 5; };
      color = "#0007";
    };
    struts = { left = -13; right = -13; };
    background-color = "transparent";
  };
}
