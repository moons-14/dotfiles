{
  description = "secure boot and TPM-backed storage";

  includes = [
    "systems.boot.secure-boot"
    "systems.boot.storage-crypto"
  ];
}
