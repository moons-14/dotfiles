{ pkgs, ... }:
{
  boot.initrd = {
    systemd.enable = true;
    luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  security.tpm2.enable = true;

  environment.systemPackages = [ pkgs.tpm2-tools ];
}
