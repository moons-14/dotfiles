{
  pkgs,
  inputs,
  ...
}: let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  programs = {
    xwayland.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    zsh = {
      enable = true;
    };
    java.enable = true;
    java.package = pkgs.jdk25;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
    htop
    btop # Simple Terminal Based System Monitor
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    uwsm # Universal Wayland Session Manager (optional must be enabled)
    wget # Tool For Fetching Files With Links
    curl # Tool For Fetching Files With Links
    alacritty # A GPU Accelerated Terminal Emulator
    fuzzel # A Simple And Lightweight Application Launcher
    git # Version Control System
    tailscale # Zero-Config VPN
    unstable.msedit # Microsoft Editor
    nil # Nix Language Server
    docker # Containerization Platform
    unstable._1password-cli
    unstable._1password-gui
    unstable.ghostty
    sbctl
    xwayland-satellite
    slurp
    grim
    wf-recorder
    sqlite # Vscode Raycast Extension Dependency
    oxker # Docker TUI Tool
    jdk25
    maven
    gradle
    python312
    uv
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
  ];
}
