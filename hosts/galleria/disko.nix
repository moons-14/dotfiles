_:
let
  espPart = "/dev/disk/by-partuuid/008b04ef-9c06-4049-bffb-3906f5c3a9c1";
  nixosPart = "/dev/disk/by-partuuid/04295552-cbb8-4511-ac1e-1171ec20f8d1";

  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
    "ssd"
    "space_cache=v2"
  ];
in
{
  disko.enableConfig = true;

  # These are deliberately partition paths, not the whole Windows disk. Disko
  # must never own or destroy the disk's GPT or any Windows partition.
  disko.devices.disk = {
    esp = {
      type = "disk";
      device = espPart;
      destroy = false;

      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [ "umask=0077" ];
      };
    };

    nixos = {
      type = "disk";
      device = nixosPart;
      destroy = false;

      content = {
        type = "luks";
        name = "cryptroot";
        askPassword = true;
        settings.allowDiscards = true;

        extraFormatArgs = [
          "--type"
          "luks2"
          "--pbkdf"
          "argon2id"
          "--label"
          "NixOS-LUKS"
        ];

        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            "NixOS"
          ];

          subvolumes = {
            "@root" = {
              mountpoint = "/";
              mountOptions = btrfsMountOptions;
            };

            "@home" = {
              mountpoint = "/home";
              mountOptions = btrfsMountOptions;
            };

            "@nix" = {
              mountpoint = "/nix";
              mountOptions = btrfsMountOptions;
            };

            "@log" = {
              mountpoint = "/var/log";
              mountOptions = btrfsMountOptions;
            };

            "@swap" = {
              mountpoint = "/.swapvol";
              mountOptions = [ "noatime" ];
              swap.swapfile.size = "32G";
            };
          };
        };
      };
    };
  };
}
