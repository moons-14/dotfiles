{ lib, ... }:
{
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 8;
}
