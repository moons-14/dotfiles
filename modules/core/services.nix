{ pkgs, ... }: {
  services = {

    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview

    fwupd.enable = true;

    gnome.gnome-keyring.enable = true;

    upower.enable = true;
    tlp = {
      enable = true;
      settings = {
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "off";
      };
    };

    tailscale.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    logind = {
      lidSwitch = "suspend";          # Lock when lid is closed
      lidSwitchDocked = "ignore";  # Ignore when docked
      extraConfig = ''
        HandleLidSwitchExternalPower=lock
        LidSwitchIgnoreInhibited=no
      '';
    };
  };

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    daemon.settings = {
      ipv6 = true;
      "fixed-cidr-v6" = "fd00:30::/64";
      ip6tables = true;
    };
  };

  programs.nix-ld.enable = true;
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "wlr" "gtk" ];
      niri.default   = [ "wlr" "gtk" ];
    };
  };
}