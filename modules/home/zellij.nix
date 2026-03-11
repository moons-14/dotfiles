{...}: {
  programs.zellij = {
    enable = true;

    enableZshIntegration = false;

    settings = {
      pane_frames = true;
      default_mode = "locked";
    };

    extraConfig = ''
      keybinds {
        locked {
          bind "Ctrl g" { SwitchToMode "normal"; }
          bind "Alt h" "Alt Left"  { MoveFocusOrTab "Left"; }
          bind "Alt j" "Alt Down"  { MoveFocus "Down"; }
          bind "Alt k" "Alt Up"    { MoveFocus "Up"; }
          bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
          bind "Alt n"             { NewPane; }
        }
        normal {
          bind "Alt h" "Alt Left"  { MoveFocusOrTab "Left"; }
          bind "Alt j" "Alt Down"  { MoveFocus "Down"; }
          bind "Alt k" "Alt Up"    { MoveFocus "Up"; }
          bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
          bind "Alt n"             { NewPane; }
        }
      }
    '';

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
