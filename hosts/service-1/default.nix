# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  fileSystems."/mnt/immich-nfs" = {
    device = "unas.moons14.com:/var/nfs/shared/immich/mnt";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"          # 可能なら NFSv4 系を推奨
      "hard"
      "timeo=600"
      "retrans=2"
      "noatime"
      "_netdev"
      "nofail"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
    ];
  };
}
