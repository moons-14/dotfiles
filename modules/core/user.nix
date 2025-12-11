{ pkgs, inputs, username, host, profile, ...}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username host profile; };
    users.moons = {
      imports = [ ./../home ];
      home = {
        username = "moons";
        homeDirectory = "/home/moons";
        stateVersion = "25.11";
      };
    };
  };
  users.mutableUsers = true;
  users.users.moons = {
    isNormalUser = true;
    description = "moons-14";
    extraGroups = [
      "adbusers"
      "docker" #access to docker as non-root
      "libvirtd" #Virt manager/QEMU access
      "lp"
      "networkmanager"
      "scanner"
      "wheel" #subdo access
      "vboxusers" #Virtual Box
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = [ "moons" ];
  nix.settings.trusted-users = [ "root" "moons" ];
}
