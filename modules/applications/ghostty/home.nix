{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.my.applications.ghostty.homeManager;

  system = pkgs.stdenv.hostPlatform.system;

  ghosttyPkg = inputs.ghostty.packages.${system}.ghostty-releasefast;
in
{
  options.my.applications.ghostty.homeManager = {
    enable = lib.mkEnableOption "ghostty home-manager configuration";
  };

  config.home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        config = lib.mkIf cfg.enable {
          programs.ghostty = {
            enable = true;

            package = ghosttyPkg;

            systemd.enable = true;

            settings = {
              theme = "dracula";

              background-blur-radius = 20;
              background-opacity = 0.9;

              font-family = "BlexMono Nerd Font Mono";

              mouse-hide-while-typing = true;

              window-decoration = "auto";

              keybind = [
                # Copy/Paste
                "performable:ctrl+shift+c=copy_to_clipboard"
                "ctrl+shift+v=paste_from_clipboard"

                # Create new tab
                "ctrl+shift+t=new_tab"

                # Move tabs
                "ctrl+alt+left_bracket=previous_tab"
                "ctrl+alt+right_bracket=next_tab"

                # Close window
                "ctrl+alt+q=close_window"

                # Font size
                "ctrl+shift+semicolon=increase_font_size:1"
                "ctrl+shift+minus=decrease_font_size:1"
              ];

              # Quick terminal
              quick-terminal-position = "top";
              quick-terminal-size = "98%,100%";

              quick-terminal-autohide = false;
              quick-terminal-keyboard-interactivity = "on-demand";
              gtk-quick-terminal-layer = "top";

              quit-after-last-window-closed = false;

              shell-integration-features = "no-ssh-env,no-ssh-terminfo";
            };
          };

          xdg.configFile."ghostty/themes/dracula".source = ./dracula.theme;
        };
      }
    )
  ];
}
