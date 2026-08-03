_: {
  programs.vicinae = {
    package = null;

    launchd = {
      enable = true;
      autoStart = true;
    };
    settings.global_shortcuts.toggle = "alt+d";
  };
}
