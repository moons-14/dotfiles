{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  boot.zfs.forceImportRoot = false;

  networking = {
    hostName = "nixos-installer";

    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = "yes";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKhxDkucmeCor6CKoXAua7DgDSzuXrZOtpdkyzQxz5+aAAAABHNzaDo= moons@moons14.com"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN6hZJyng/5LgFKPjR6uZAd/00UkO0vN0uQOoIvfSELdAAAABHNzaDo= moons@moons14.com"
  ];

  environment.systemPackages = with pkgs; [
    git
    disko
    sops
    age
    ssh-to-age
    age-plugin-yubikey
    yubikey-manager
    pcsc-tools
    mkpasswd
    rsync
    vim
    wget
    curl
    jq
    parted
    cryptsetup
    btrfs-progs
    efibootmgr
    pciutils
    sbctl
    tpm2-tools
    util-linux
  ];

  services.pcscd.enable = true;

  environment.etc."installer-help.txt".text = ''

    ╔══════════════════════════════════════════════════════════════╗
    ║                    NixOS Installer ISO                       ║
    ╠══════════════════════════════════════════════════════════════╣
    ║                                                              ║
    ║  SSH Access:                                                 ║
    ║    ssh root@<ip-address>                                     ║
    ║                                                              ║
    ║  Network Setup:                                              ║
    ║    Wired:   Auto-configured via DHCP                         ║
    ║    WiFi:    nmcli device wifi connect <SSID> --ask           ║
    ║                                                              ║
    ║  Installation Workflow:                                      ║
    ║                                                              ║
    ║  1. Clone dotfiles:                                          ║
    ║     git clone git@github.com:moons-14/dotfiles.git ~/dotfiles║
    ║                                                              ║
    ║  2. Generate SSH host key for new host:                      ║
    ║     ssh-keygen -t ed25519 -f /tmp/ssh_host_ed25519_key -N "" ║
    ║                                                              ║
    ║  3. Get age public key from SSH host key:                    ║
    ║     ssh-to-age -i /tmp/ssh_host_ed25519_key.pub              ║
    ║                                                              ║
    ║  4. Add age key to .sops.yaml:                               ║
    ║     cd ~/dotfiles                                            ║
    ║     # Edit .sops.yaml and add the age key                    ║
    ║     # Add new host entry to creation_rules                   ║
    ║                                                              ║
    ║  5. Re-encrypt secrets:                                      ║
    ║     sops updatekeys secrets/common/system.yaml               ║
    ║     sops updatekeys secrets/hosts/<host>/*.yaml              ║
    ║                                                              ║
    ║  6. Create disko.nix for new host:                           ║
    ║     # Check disk devices                                     ║
    ║     lsblk -f                                                 ║
    ║                                                              ║
    ║     # Create hosts/<host>/disko.nix                          ║
    ║     # Example: LUKS + btrfs                                  ║
    ║     # See hosts/x1g13/disko.nix for reference                ║
    ║                                                              ║
    ║  7. Partition disk with disko:                               ║
    ║     nix run github:nix-community/disko -- \                  ║
    ║       --mode disko hosts/<host>/disko.nix                    ║
    ║                                                              ║
    ║  8. Copy host key to installed system:                       ║
    ║     mkdir -p /mnt/etc/ssh                                    ║
    ║     cp /tmp/ssh_host_ed25519_key* /mnt/etc/ssh/              ║
    ║     chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key              ║
    ║                                                              ║
    ║  9. Install NixOS:                                           ║
    ║     nixos-install --flake ~/dotfiles#<host>                  ║
    ║                                                              ║
    ║  Disko Configuration Examples:                               ║
    ║                                                              ║
    ║  Simple (no encryption):                                     ║
    ║    disko.devices.disk.main = {                               ║
    ║      type = "disk";                                          ║
    ║      device = "/dev/sda";                                    ║
    ║      content = {                                             ║
    ║        type = "gpt";                                         ║
    ║        partitions = {                                        ║
    ║          ESP = { size = "512M"; type = "EF00";              ║
    ║            content = { type = "filesystem";                  ║
    ║              format = "vfat"; mountpoint = "/boot"; }; };   ║
    ║          root = { size = "100%";                             ║
    ║            content = { type = "filesystem";                  ║
    ║              format = "ext4"; mountpoint = "/"; }; };       ║
    ║        };                                                    ║
    ║      };                                                      ║
    ║    };                                                        ║
    ║                                                              ║
    ║  LUKS + btrfs (see hosts/x1g13/disko.nix):                  ║
    ║    - Use partuuid for device path                            ║
    ║    - Set askPassword = true for LUKS                         ║
    ║    - Configure btrfs subvolumes                              ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝

  '';

  systemd.services.installer-banner = {
    description = "Display installer help on console";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/cat /etc/installer-help.txt";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
    };
  };

  systemd.services.display-ip = {
    description = "Display IP address on console";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "display-ip" ''
        sleep 2
        echo ""
        echo "=== Network Interfaces ==="
        ${pkgs.iproute2}/bin/ip -4 addr show | ${pkgs.gnugrep}/bin/grep inet
        echo ""
        echo "=== SSH Access ==="
        for ip in $(${pkgs.iproute2}/bin/ip -4 addr show | ${pkgs.gnugrep}/bin/grep -oP 'inet \K[\d.]+' | ${pkgs.gnugrep}/bin/grep -v '127.0.0.1'); do
          echo "  ssh root@$ip"
        done
        echo ""
      '';
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "root" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
