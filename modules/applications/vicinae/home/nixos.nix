{
  inputs,
  pkgs,
  ...
}:
let
  extensions = inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.vicinae = {

    package = pkgs.vicinae;

    systemd = {
      enable = true;
      autoStart = true;
      environment.USE_LAYER_SHELL = 1;
    };

    extensions = with extensions; [
      power-profile
      niri
      noctalia-shell-wallpaper-selector
    ];
  };
}
