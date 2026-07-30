{ lib, pkgs, ... }:
{
  xdg.configFile = {
    "labwc/rc.xml".source = ./rc.xml;

    "labwc/environment".text = ''
      XKB_DEFAULT_LAYOUT=jp
      XKB_DEFAULT_OPTIONS=ctrl:nocaps
    '';

    "labwc/autostart".text = ''
      # Pull in graphical-session.target so Home Manager services such as
      # portals, Vicinae, and the idle manager follow the labwc session.
      ${lib.getExe' pkgs.systemd "systemctl"} --user --no-block start labwc-session.target

      # labwc does not run XDG autostart entries itself. Start the input method
      # explicitly so both native Wayland and XWayland applications can use it.
      fcitx5 -d --replace >/dev/null 2>&1 &

      NOCTALIA_CONFIG_HOME="$HOME/.config/noctalia-labwc" noctalia >/dev/null 2>&1 &
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &
    '';
  };
}
