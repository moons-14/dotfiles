{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.boot.nfs;
in
{
  options.my.system.boot.nfs = {
    enable = lib.mkEnableOption "NFS boot support";
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "nfs" ];
    programs.fuse.userAllowOther = true;
    services.rpcbind.enable = true;
  };
}
