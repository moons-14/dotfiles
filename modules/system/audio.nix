{ lib, config, ... }:
let
  cfg = config.my.system.audio;
in
{
  options.my.system.audio = {
    enable = lib.mkEnableOption "Audio support (PipeWire)";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}
