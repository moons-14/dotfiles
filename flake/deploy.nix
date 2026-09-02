{
  inputs,
  self,
  ...
}:
{
  flake.deploy = {
    nodes.nix-builder = {
      hostname = "nix-builder";
      sshUser = "moons";
      user = "root";

      interactiveSudo = true;
      remoteBuild = true;
      autoRollback = true;
      magicRollback = true;

      profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nix-builder;
    };
  };

  perSystem =
    { system, ... }:
    {
      apps.deploy = inputs.deploy-rs.apps.${system}.default;
      checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
    };
}
