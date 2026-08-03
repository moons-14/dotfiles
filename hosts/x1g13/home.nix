{
  services.kanshi = {
    enable = true;

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
}
