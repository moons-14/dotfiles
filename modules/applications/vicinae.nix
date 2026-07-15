{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.vicinae;
in
{
  options.my.applications.vicinae = {
    enable = lib.mkEnableOption "Vicinae application launcher";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.vicinae.homeManagerModules.default
      {
        programs.vicinae = {
          enable = true;
          systemd = {
            enable = true;
            autoStart = true;
            environment = {
              USE_LAYER_SHELL = 1;
            };
          };

          settings = {
            font.size = 11;
            close_on_focus_loss = true;
            consider_preedit = true;
            pop_to_root_on_close = true;
            favicon_service = "twenty";
            search_files_in_root = true;
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
          extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
            nix
            power-profile
            niri
            zoxide-recent-directories
            ssh
            port-killer
            noctalia-shell-wallpaper-selector
          ];
        };
      }
    ];
  };
}
