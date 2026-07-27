{
  programs.btop = {
    enable = true;

    settings.color_theme = "dracula";
    themes.dracula = builtins.readFile ./dracula.theme;
  };
}
