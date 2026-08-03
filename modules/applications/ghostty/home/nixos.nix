{ inputs, system, ... }: {
  programs.ghostty = {
    systemd.enable = true;
    package = inputs.ghostty.packages.${system}.default;
  };
}
