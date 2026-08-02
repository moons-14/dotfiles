{ inputs, pkgs, ... }: {
  programs.ghostty = {
    systemd.enable = true;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.ghostty-releasefast;
  };
}
