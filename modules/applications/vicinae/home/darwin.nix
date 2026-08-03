_: {
  programs.vicinae = {
    launchd = {
      enable = true;
      autoStart = true;
    };
    settings.global_shortcuts.toggle = "alt+d";
  };
}
