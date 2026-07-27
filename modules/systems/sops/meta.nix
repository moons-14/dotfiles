{ inputs, ... }:
{
  description = "sops-nix system integration";

  includes = [ "services.openssh" ];

  imports = {
    nixos = [ inputs.sops-nix.nixosModules.sops ];
    darwin = [ inputs.sops-nix.darwinModules.sops ];
  };
}
