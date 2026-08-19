{
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  desktopPackage = inputs.codex-desktop-linux.packages.${system}.codex-desktop.override {
    enableComputerUseUi = false;
    linuxFeatureIds = [
      "appshots"
      "open-target-discovery"
      "remote-mobile-control"
    ];
  };
  bundledCodex = pkgs.writeShellScriptBin "codex" ''
    exec ${desktopPackage}/opt/codex-desktop/resources/codex "$@"
  '';
in
{
  environment.systemPackages = [
    pkgs.bubblewrap
  ];

  programs.codexDesktopLinux = {
    enable = true;
    package = desktopPackage;
    cliPackage = bundledCodex;
    remoteControl = {
      enable = true;
      package = bundledCodex;
    };
    remoteMobileControl.enable = true;
    computerUseUi.enable = false;
    linuxFeatures = [
      "appshots"
      "open-target-discovery"
    ];
  };
}
