_: {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "dracula";
      background-blur-radius = 20;
      background-opacity = 0.9;
      background-opacity-cells = true;
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

      quick-terminal-screen = "mouse";
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
}
