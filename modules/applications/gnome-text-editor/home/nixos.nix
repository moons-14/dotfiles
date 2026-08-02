{ pkgs, ... }:
{
  home.packages = [ pkgs.gnome-text-editor ];

  dconf.settings."org/gnome/TextEditor" = {
    style-variant = "follow";
    wrap-text = true;
    spellcheck = true;
    restore-session = true;
    show-line-numbers = false;
    show-right-margin = false;
    show-map = false;
    highlight-current-line = false;
    auto-indent = false;
    discover-settings = false;
    enable-snippets = false;
    keybindings = "default";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [ pkgs.gnome-text-editor ];
  };
}
