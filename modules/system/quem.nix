{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.quem;
in
{
  options.my.system.quem = {
    enable = lib.mkEnableOption "QEMU guest support";
  };

  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = true;
  };
}
