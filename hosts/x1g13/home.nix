{

  services.kanshi = {
    enable = true;
    systemdTarget = "labwc-session.target";
    settings = [
      {
        profile = {
          name = "x1g13";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
              scale = 1.5;
            }
          ];
        };
      }
    ];
  };

  programs.niri.settings.outputs."eDP-1" = {
    scale = 1.5;
    position = {
      x = 0;
      y = 0;
    };
  };
}
