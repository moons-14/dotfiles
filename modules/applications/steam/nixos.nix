{ pkgs, ... }:
{
  programs.steam = {
    enable = true;

    # Keep Valve's Proton available through Steam and add Proton-GE as an
    # explicitly selectable compatibility tool for games that need its extra
    # patches and codecs.
    extraCompatPackages = [ pkgs.proton-ge-bin ];

    # Install the supported helper for changing an individual Proton prefix.
    protontricks.enable = true;

    # Translate Steam's X11 input events to uinput under Wayland so Steam Input
    # and controller remapping continue to work in the desktop sessions.
    extest.enable = true;
  };
}
