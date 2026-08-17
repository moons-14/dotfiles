{
  services.evremap = {
    enable = true;

    settings = {
      device_name = "VXE VXE Mouse 1K Dongle Mouse";

      remap = [
        {
          input = [ "BTN_SIDE" ];
          output = [ "KEY_LEFTMETA" ];
        }
        {
          input = [ "BTN_EXTRA" ];
          output = [ "BTN_SIDE" ];
        }
      ];
    };
  };
}
