{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ghostty.homeManager;
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

                # Quick terminal
                "global:super+space=toggle_quick_terminal"
              ];

              # Quick terminal
              quick-terminal-position = "top";

              quick-terminal-size = "100%";

              gtk-quick-terminal-layer = "overlay";

              quick-terminal-keyboard-interactivity = "exclusive";

              quick-terminal-autohide = false;

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
