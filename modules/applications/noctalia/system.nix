{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.noctalia.system;
in
{
  options.my.applications.noctalia.system = {
    enable = lib.mkEnableOption "noctalia system package";
  };

  imports = [
    inputs.noctalia.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
      systemd.enable = true;
    };
  };
}
