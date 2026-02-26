# Window rules, layer rules, overview, debug
{ lib }: {
  window-rules = [
    { matches = [ { app-id = "floorp$"; title = "^Picture-in-Picture$"; } ]; open-floating = true; }
    { matches = [ ]; geometry-corner-radius = { top-left = 20.0; top-right = 20.0; bottom-right = 20.0; bottom-left = 20.0; }; clip-to-geometry = true; }
    { matches = [ { app-id = "vesktop"; } ]; open-on-output = "PNP(BNQ) BenQ XL2420TE 3CD00511SL0"; }
  ];
  layer-rules = [
    { matches = [ { namespace = "^noctalia-overview*"; } ]; place-within-backdrop = true; }
  ];
  overview.workspace-shadow.enable = false;
  debug.honor-xdg-activation-with-invalid-serial = true;
}
