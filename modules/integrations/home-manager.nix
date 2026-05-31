{
  username,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";

    users.${username} = {
      nixpkgs.config.allowUnfree = true;

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = config.my.stateVersions.homeManager;
      };
    };
  };
}
