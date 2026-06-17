{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.boot.storageCrypto;
in
{
  options.my.features.boot.storageCrypto = {
    enable = lib.mkEnableOption "LUKS decryption via TPM2";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.enable = true;

    boot.initrd.luks.devices.cryptroot = {
      crypttabExtraOpts = [
        "tpm2-device=auto"
      ];
    };

    security.tpm2.enable = true;

    environment.systemPackages = with pkgs; [
      tpm2-tools # TPM2 management tools
    ];
  };
}
