{ lib, ... }:
let
  hostSecrets = ../../secrets/hosts/nix-builder/system.yaml;
in
{
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  sops.secrets = lib.mkIf (builtins.pathExists hostSecrets) {
    "harmonia/signing-key" = {
      sopsFile = hostSecrets;
      restartUnits = [ "harmonia.service" ];
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5000 ];
}
