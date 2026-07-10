{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  cfg = config.my.applications.fcitx5.system;
in
{
  options.my.applications.fcitx5.system = {
    enable = lib.mkEnableOption "fcitx5 system configuration";
  };

  imports = [
    inputs.nix-hazkey.nixosModules.hazkey
  ];

  config = lib.mkIf cfg.enable {

    services.hazkey = {
      enable = true;
      server.package = inputs.nix-hazkey.packages.${system}.hazkey-server.override {
        enableVulkan = true;
      };
      installHazkeySettings = false;
      installFcitx5Addon = false;
    };

    environment.systemPackages = [ inputs.nix-hazkey.packages.${system}.hazkey-settings ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          inputs.nix-hazkey.packages.${system}.fcitx5-hazkey
          fcitx5-mozc-ut
          fcitx5-gtk
          kdePackages.fcitx5-qt
          qt6Packages.fcitx5-configtool
        ];
        settings.inputMethod = {
          GroupOrder = {
            "0" = "Default";
          };
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "jp";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-jp";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
        };
      };
    };
  };
}
