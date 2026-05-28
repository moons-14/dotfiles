{
  userName,
  inputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.moons = {
      home = {
        username = userName;
        homeDirectory = "/home/${userName}";
        stateVersion = "26.05";
      };
    };
  };
}
