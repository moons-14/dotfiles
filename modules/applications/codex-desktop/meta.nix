{ inputs, ... }:
{
  description = "Codex Desktop for Linux";

  includes = [ "applications.codex" ];

  imports.nixos = [
    inputs.codex-desktop-linux.nixosModules.default
  ];
}
