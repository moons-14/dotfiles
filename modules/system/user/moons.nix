{
  pkgs,
  ...
}:
{
  users.mutableUsers = true;

  users.users.moons = {
    isNormalUser = true;
    description = "moons-14";
    extraGroups = [
      "adbusers"
      "docker"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "wheel"
      "vboxusers"
      "dialout"
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKhxDkucmeCor6CKoXAua7DgDSzuXrZOtpdkyzQxz5+aAAAABHNzaDo= moons@moons14.com"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN6hZJyng/5LgFKPjR6uZAd/00UkO0vN0uQOoIvfSELdAAAABHNzaDo= moons@moons14.com"
    ];
  };
}
