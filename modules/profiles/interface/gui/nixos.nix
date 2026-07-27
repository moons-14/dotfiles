{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    grim
    slurp
    wf-recorder
  ];
}
