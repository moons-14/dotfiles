{
  description = "TPM-backed LUKS unlock for NixOS";

  includes = [ "systems.boot.storage-crypto" ];
}
