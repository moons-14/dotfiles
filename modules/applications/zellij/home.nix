{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zellij.homeManager;
in
{
  options.my.applications.zellij.homeManager = {
    enable = lib.mkEnableOption "Zellij home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        programs.zellij = {
          enable = true;

          enableZshIntegration = false;

          settings = {
            pane_frames = true;
            copy_clipboard = "system";
            copy_on_select = false;
            default_mode = "locked";
            default_shell = "/run/current-system/sw/bin/zsh";
          };

          extraConfig = ''
            keybinds {
              locked {
                bind "Ctrl g" { SwitchToMode "normal"; }
                bind "Alt h" "Alt Left"       { MoveFocusOrTab "Left"; }
                bind "Alt j" "Alt Down"       { MoveFocus "Down"; }
                bind "Alt k" "Alt Up"         { MoveFocus "Up"; }
                bind "Alt l" "Alt Right"      { MoveFocusOrTab "Right"; }
                bind "Alt n"                  { NewPane; }
                bind "Alt t"                  { NewTab; }
                bind "Alt H" { Resize "Increase Left"; }
                bind "Alt J" { Resize "Increase Down"; }
                bind "Alt K" { Resize "Increase Up"; }
                bind "Alt L" { Resize "Increase Right"; }
                bind "Alt c" "Ctrl Shift c" { Copy; }
              }
              normal {
                bind "Alt h" "Alt Left"  { MoveFocusOrTab "Left"; }
                bind "Alt j" "Alt Down"  { MoveFocus "Down"; }
                bind "Alt k" "Alt Up"    { MoveFocus "Up"; }
                bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt n"             { NewPane; }
                bind "Alt t"             { NewTab; }
                bind "Ctrl Shift c"      { Copy; }
                bind "Alt H" { Resize "Increase Left"; }
                bind "Alt J" { Resize "Increase Down"; }
                bind "Alt K" { Resize "Increase Up"; }
                bind "Alt L" { Resize "Increase Right"; }
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
      };
    }
  ];
}
