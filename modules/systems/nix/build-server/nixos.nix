{ primaryUser, ... }:
let
  GiB = 1024 * 1024 * 1024;
in
{
  nix = {
    nrBuildUsers = 64;

    settings = {
      # Limit concurrent derivations so build scratch and memory usage remain
      # bounded. Each derivation may still use every vCPU exposed to the VM.
      max-jobs = 2;
      cores = 0;

      # Keep enough room for large desktop, browser, and CUDA closures.
      min-free = 64 * GiB;
      max-free = 128 * GiB;
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nix-fleet 0750 ${primaryUser} users - -"
    "d /var/lib/nix-fleet/roots 0750 ${primaryUser} users - -"
    "d /var/lib/nix-fleet/roots/build 0750 ${primaryUser} users - -"
    "d /var/lib/nix-fleet/roots/deploy 0750 ${primaryUser} users - -"
  ];
}
