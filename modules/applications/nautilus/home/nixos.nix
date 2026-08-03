{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.nautilus
    pkgs.sushi
  ];

  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      always-use-location-entry = true;
      default-folder-viewer = "list-view";
    };

    "org/gnome/nautilus/list-view".use-tree-view = true;

    # Nautilus 50 migrates this setting from GTK 3 to GTK 4.
    "org/gtk/settings/file-chooser".show-hidden = true;
    "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
  };

  gtk.gtk3.bookmarks = [
    "file://${config.home.homeDirectory}/Desktop Desktop"
    "file://${config.home.homeDirectory}/Pictures Pictures"
    "file://${config.home.homeDirectory}/Downloads Downloads"
    "file://${config.home.homeDirectory}/projects projects"
  ];

  home.activation.createProjectsDirectory = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      $DRY_RUN_CMD mkdir -p "$HOME/projects"
    '';
  };
}
