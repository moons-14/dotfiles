{
  services.kanshi = {
    enable = true;
    systemdTarget = "labwc-session.target";
    settings = [
      {
        profile = {
          name = "galleria";
          outputs = [
            {
              criteria = "HDMI-A-1";
              status = "enable";
              position = "0,0";
              scale = 1.5;
            }
            {
              criteria = "DP-1";
              status = "enable";
              position = "2560,0";
            }
            {
              criteria = "DP-2";
              status = "enable";
              position = "5120,0";
              scale = 1.5;
            }
          ];
        };
      }
    ];
  };

  programs.niri.settings.outputs = {
    "HDMI-A-1" = {
      scale = 1.5;
      position = {
        x = 0;
        y = 0;
      };
    };

    "DP-1".position = {
      x = 2560;
      y = 0;
    };

    "DP-2" = {
      scale = 1.5;
      position = {
        x = 5120;
        y = 0;
      };
    };
  };
}
