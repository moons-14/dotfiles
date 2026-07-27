{
  inputs,
  lib,
  ...
}:
let
  dotfilesLib = import ../libs {
    inherit inputs lib;
    root = ../.;
  };
  hostSpecsPath = ../hosts/default.nix;
  hostSpecs =
    if builtins.pathExists hostSpecsPath then
      let
        value = import hostSpecsPath;
      in
      if builtins.isFunction value then
        value (
          builtins.intersectAttrs (builtins.functionArgs value) {
            inherit inputs lib;
          }
        )
      else
        value
    else
      { };
  configurations = dotfilesLib.hosts.mkConfigurations hostSpecs;
in
{
  flake = {
    inherit (configurations) darwinConfigurations nixosConfigurations;
    lib = dotfilesLib;
  };

  perSystem =
    { pkgs, system, ... }:
    let
      nixosChecks =
        lib.mapAttrs' (name: nixos: lib.nameValuePair "nixos-${name}" nixos.config.system.build.toplevel)
          (
            lib.filterAttrs (
              _: nixos: nixos.pkgs.stdenv.hostPlatform.system == system
            ) configurations.nixosConfigurations
          );
    in
    {
      checks = {
        registry = import ../tests/registry.nix {
          inherit inputs lib pkgs;
        };
      }
      // nixosChecks;
    };
}
