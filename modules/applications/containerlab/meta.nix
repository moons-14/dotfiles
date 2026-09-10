{ inputs, ... }:
{
  description = "Container-based networking labs";

  includes = [ "services.docker" ];

  imports.nixos = [ inputs.containerlab.nixosModules.default ];
}
