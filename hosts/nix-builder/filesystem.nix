{
  fileSystems."/nix/store" = {
    device = "/dev/disk/by-label/nix-store";
    fsType = "ext4";

    options = [
      "noatime"
    ];

    neededForBoot = true;
  };

  fileSystems."/var/lib/nix-build" = {
    device = "/dev/disk/by-label/nix-build";
    fsType = "ext4";

    options = [
      "noatime"
    ];
  };

  nix.settings.build-dir = "/var/lib/nix-build";

  services.fstrim.enable = true;
}
