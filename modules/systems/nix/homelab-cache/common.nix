{ lib, ... }:
let
  publicKeyFile = ./public-key;
  hasPublicKey = builtins.pathExists publicKeyFile;
  publicKey = if hasPublicKey then lib.removeSuffix "\n" (builtins.readFile publicKeyFile) else "";
in
{
  assertions = [
    {
      assertion = hasPublicKey;
      message = ''
        systems.nix.homelab-cache requires
        modules/systems/nix/homelab-cache/public-key
      '';
    }
  ];

  nix.settings = lib.mkIf hasPublicKey {
    extra-substituters = [ "http://nix-builder:5000" ];
    extra-trusted-public-keys = [ publicKey ];
  };
}
