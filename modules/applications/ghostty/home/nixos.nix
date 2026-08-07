{ inputs, system, ... }: {
  programs.ghostty = {
    # Labwc's Close action correctly targets one xdg-toplevel, but Ghostty's
    # systemd service runs every window in one GTK single-instance process.
    # If that process exits while handling the request, every Ghostty window
    # disappears together. Keep each launcher invocation independent instead.
    systemd.enable = false;
    package = inputs.ghostty.packages.${system}.default;

    settings.gtk-single-instance = false;
  };
}
