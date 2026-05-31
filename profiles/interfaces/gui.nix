{
  imports = [
    ./cli-interactive.nix
  ];

  my.features = {
    gui = {
      desktop.enable = true;
      terminal.enable = true;
      audio.enable = true;
      jpInput.enable = true;
      graphic.enable = true;
      capture.enable = true;
      fileManager.enable = true;
    };
    services.kde.enable = true;
  };
}
