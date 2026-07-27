{
  fileSystems."/" = {
    device = "/dev/null";
    fsType = "ext4";
  };

  boot.loader.grub.enable = false;
  system.stateVersion = "26.05";
}
