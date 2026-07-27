{ pkgs, ... }:
{
  home.packages = [ pkgs.gnupg ];

  services.gpg-agent = {
    enable = false;
    enableSshSupport = false;
  };
}
