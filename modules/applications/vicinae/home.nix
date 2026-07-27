{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  extensions = inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.vicinae = {
    enable = true;
    systemd = lib.mkIf isLinux {
      enable = true;
      autoStart = true;
      environment.USE_LAYER_SHELL = 1;
    };
    launchd = lib.mkIf isDarwin {
      enable = true;
      autoStart = true;
    };
    settings = {
      font.size = 11;
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;
      global_shortcuts.toggle = "alt+d";
      providers.clipboard.entrypoints.history.shortcut = "alt+v";
      theme = {
        light = {
          name = "dracula";
          icon_theme = "default";
        };
        dark = {
          name = "vicinae-light";
          icon_theme = "default";
        };
      };
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
    extensions =
      with extensions;
      [
        nix
        zoxide-recent-directories
        ssh
        port-killer
      ]
      ++ lib.optionals isLinux [
        power-profile
        niri
        noctalia-shell-wallpaper-selector
      ];
  };
}
