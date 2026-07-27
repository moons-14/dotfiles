{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.sqlite ];
}
