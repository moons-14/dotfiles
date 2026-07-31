{ pkgs, ... }:
{
  services.gvfs.enable = true;

  environment.systemPackages = [ pkgs.glib ];
}
