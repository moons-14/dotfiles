{
  services.kanshi = {
    enable = true;

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
}
