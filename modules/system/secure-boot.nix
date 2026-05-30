{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.secure-boot;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.my.system.secure-boot = {
    enable = lib.mkEnableOption "secure boot (lanzaboote)";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
