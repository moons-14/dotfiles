{...}: {
  programs.zellij = {
    enable = true;

    enableZshIntegration = false;

    settings = {
      pane_frames = true;
    };

    layouts.dev = ''
      layout {
        pane split_direction="vertical" {
          pane {
            pane command="nvim"
            pane stacked=true size="30%" {
              pane expanded=true
              pane
            }
          }

          pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
          }
        }
      }
    '';
  };
}
