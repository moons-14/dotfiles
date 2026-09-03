{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      bat
      duf
      dust
      eza
      fd
      fzf
      jq
      lsof
      nurl
      ripgrep
      tio
      unrar
    ]
    ++ lib.optionals stdenv.isLinux [
      lm_sensors
      psmisc
      strace
    ];
}
