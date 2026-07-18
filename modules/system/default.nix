{ inputs, ... }:
{
  imports = [
    ./audio.nix
    ./boot
    ./camera.nix
    ./disko.nix
    ./fingerprint.nix
    ./fonts.nix
    ./gc.nix
    ./hardware
    ./locale.nix
    ./network
    ./nix.nix
    ./nixcache-oci.nix
    ./power.nix
    ./quem.nix
    ./secure-boot.nix
    ./sops.nix
    ./user
    ./version.nix
    ./secret.nix
    inputs.nixcache-oci.nixosModules.default
  ];
}
