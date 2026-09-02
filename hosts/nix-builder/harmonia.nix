{
  lib,
  ...
}:

{

  nix.settings = {
    build-dir = "/var/lib/nix-build";

    secret-key-files = [
      "/var/lib/secrets/nix-cache-signing-key"
    ];

    auto-optimise-store = lib.mkForce false;
    keep-outputs = false;
    keep-derivations = true;
  };

  services.harmonia.cache = {
    enable = true;

    signKeyPaths = [
      "/var/lib/secrets/nix-cache-signing-key"
    ];

    settings = {
      bind = "[::]:5000";
      priority = 30;
      workers = 4;
    };
  };

  networking.firewall.allowedTCPPorts = [
    5000
  ];
}
