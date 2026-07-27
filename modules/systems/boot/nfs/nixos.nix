{
  boot.supportedFilesystems = [ "nfs" ];
  programs.fuse.userAllowOther = true;
  services.rpcbind.enable = true;
}
