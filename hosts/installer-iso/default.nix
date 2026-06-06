{
  lib,
  pkgs,
  username,
  ...
}:
{
  isoImage = {
    isoName = lib.mkDefault "moons-nixos-installer.iso";
    appendToMenuLabel = " moons installer";
  };

  networking = {
    hostName = "nixos-installer";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      wifi.powersave = false;
    };
    wireless.iwd.enable = false;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = "yes";
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    age # File encryption tool used with sops-nix age keys
    disko # Declarative disk partitioning helper
    git # Version control client for fetching dotfiles
    neovim # Text editor for fallback console installation
    networkmanager # Network management CLI and daemon for Ethernet and WiFi
    openssh # Standard SSH client, server, and ssh-keygen tools
    sops # Editor and CLI for SOPS encrypted secrets
    ssh-to-age # Convert SSH public keys to age recipients
    tmux # Terminal multiplexer for resilient SSH sessions
  ];

  programs.zsh.enable = true;

  documentation = {
    enable = true;
    nixos.enable = true;
  };

  system.stateVersion = "26.05";
}
