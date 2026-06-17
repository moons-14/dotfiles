{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.boot.uefi;
in
{
  options.my.system.boot.uefi = {
    enable = lib.mkEnableOption "UEFI boot support";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
  };
}
