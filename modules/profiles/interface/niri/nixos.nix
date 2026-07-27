{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
    grim
    slurp
    wf-recorder
  ];
}
