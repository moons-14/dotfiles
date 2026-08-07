[
  {
    context = "Editor && vim_mode == normal";
    bindings = {
      # This selected native-equivalent subset preserves Zed's Vim defaults for
      # K, gd, grr, gri, gra, gO, ]d, [d, zM, zR, [b, and ]b.
      "g r t" = "editor::GoToTypeDefinition";
      "space space" = "pane::AlternateFile";
      "space r n" = "editor::Rename";
      "space c a" = "editor::ToggleCodeActions";
      "space c f" = "editor::Format";
      "space d l" = "editor::Hover";
      "space e" = "project_panel::Toggle";
      "space t t" = "terminal_panel::Toggle";
      "space b c" = "pane::CloseActiveItem";
      "space f f" = "file_finder::Toggle";
      "space f g" = "pane::DeploySearch";
      "space f b" = "tab_switcher::ToggleAll";
      "space f s" = "outline::Toggle";
      "space f shift-s" = "project_symbols::Toggle";
      "space x x" = "diagnostics::Deploy";
    };
  }
  {
    # Keep normal-mode editor navigation out of terminals and other panels.
    context = "Editor && vim_mode == normal && !menu";
    bindings = {
      "ctrl-h" = "workspace::ActivatePaneLeft";
      "ctrl-j" = "workspace::ActivatePaneDown";
      "ctrl-k" = "workspace::ActivatePaneUp";
      "ctrl-l" = "workspace::ActivatePaneRight";
      "ctrl-left" = "workspace::ActivatePaneLeft";
      "ctrl-down" = "workspace::ActivatePaneDown";
      "ctrl-up" = "workspace::ActivatePaneUp";
      "ctrl-right" = "workspace::ActivatePaneRight";
    };
  }
]
