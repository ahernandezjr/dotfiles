# Input and gestures
{ lib }: {
  input = {
    keyboard = {
      xkb.layout = "us";
      numlock = true;
    };
    touchpad = {
      tap = true;
      natural-scroll = true;
    };
    mouse.scroll-method = "on-button-down";
    focus-follows-mouse.enable = true;
    workspace-auto-back-and-forth = true;
  };

  gestures."dnd-edge-view-scroll" = {
    trigger-width = 30;
    delay-ms = 500;
    max-speed = 1500;
  };
}
