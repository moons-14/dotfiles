_:
let
  osDisk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
in
{
  disko.enableConfig = true;

  # The VM disks already contain live filesystems. Model each existing
  # filesystem without giving Disko ownership of their partitioning or data.
  disko.devices.disk = {
    boot = {
      type = "disk";
      device = "${osDisk}-part1";
      destroy = false;

      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [ "umask=0077" ];
      };
    };

    root = {
      type = "disk";
      device = "${osDisk}-part2";
      destroy = false;

      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
    };

    nix-build = {
      type = "disk";
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
      destroy = false;

      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/var/lib/nix-build";
        mountOptions = [ "noatime" ];
      };
    };

    nix-store = {
      type = "disk";
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi2";
      destroy = false;

      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/nix/store";
        mountOptions = [ "noatime" ];
      };
    };
  };

  fileSystems."/nix/store".neededForBoot = true;
  nix.settings.build-dir = "/var/lib/nix-build";
  services.fstrim.enable = true;
}
