{ pkgs, ... }:
{
  users.groups.nixdeploy = { };

  users.users.nixdeploy = {
    isSystemUser = true;
    group = "nixdeploy";
    home = "/var/lib/nixdeploy";
    createHome = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPg1aw0qXBmrQe6lzBwutX5t9Sxg2OeVN/homjqU6Ja moons@nix-builder"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "nixdeploy" ];

      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
