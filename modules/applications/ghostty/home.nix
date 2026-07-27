{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  package =
    if isLinux then
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.ghostty-releasefast
    else
      null;
in
{
  programs.ghostty = {
    enable = true;
    inherit package;
    systemd.enable = isLinux;

    settings = {
      theme = "dracula";
      background-blur-radius = 20;
      background-opacity = 0.9;
      font-family = "BlexMono Nerd Font Mono";
      mouse-hide-while-typing = true;
      window-decoration = "auto";

      keybind = [
        "performable:ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+t=new_tab"
        "ctrl+alt+left_bracket=previous_tab"
        "ctrl+alt+right_bracket=next_tab"
        "alt+q=close_window"
        "global:alt+space=toggle_quick_terminal"
        "global:alt+t=new_window"
        "ctrl+shift+semicolon=increase_font_size:1"
        "ctrl+shift+minus=decrease_font_size:1"
      ];

      quick-terminal-position = "top";
      quick-terminal-size = "98%,100%";
      quick-terminal-autohide = false;
      quick-terminal-keyboard-interactivity = "on-demand";
      gtk-quick-terminal-layer = "top";
      quit-after-last-window-closed = false;
      shell-integration-features = "no-ssh-env,no-ssh-terminfo";
    };
  };

  # Global Ghostty keybindings are handled by the running app. Start it hidden
  # at login so Option+T and Option+Space work before opening a terminal.
  launchd.agents.ghostty-global-keybindings = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-gja"
        "Ghostty"
      ];
      RunAtLoad = true;
    };
  };

  xdg.configFile."ghostty/themes/dracula".source = ./dracula.theme;
}
