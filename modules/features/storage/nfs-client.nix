{ lib, config, ... }:
let
  cfg = config.my.features.storage.nfsClient;
in
{
  options.my.features.storage.nfsClient = {
    enable = lib.mkEnableOption "NFS client support";
  };

  config = lib.mkIf cfg.enable {
    my.system.boot.nfs.enable = true;
  };
}
