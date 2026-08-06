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

  validationMetadata = {
    schemaVersion = 1;

    hosts = lib.mapAttrs (
      name: spec:
      let
        isDarwin = lib.hasSuffix "-darwin" spec.system;
      in
      {
        inherit (spec) system user;
        kind = if isDarwin then "darwin" else "nixos";
        homeManager = spec.homeManager or true;
        selectedUnits = dotfilesLib.hosts.selectedUnits spec;
        buildAttr =
          if isDarwin then
            "darwinConfigurations.${name}.system"
          else
            "nixosConfigurations.${name}.config.system.build.toplevel";
      }
    ) hostSpecs;

    units = lib.mapAttrs (_id: unit: {
      inherit (unit) id relativePath;
      directory = "modules/${lib.concatStringsSep "/" unit.relativePath}";
      includes = unit.meta.includes;
      fragments = builtins.attrNames (lib.filterAttrs (_: value: value != null) unit.fragments);
    }) dotfilesLib.registry.units;
  };
in
{
  flake = {
    inherit (configurations) darwinConfigurations nixosConfigurations;
    lib = dotfilesLib // {
      inherit validationMetadata;
    };
  };

  perSystem =
    { pkgs, system, ... }:
    let
      nixosChecks =
        lib.mapAttrs' (name: nixos: lib.nameValuePair "nixos-${name}" nixos.config.system.build.toplevel)
          (lib.filterAttrs (name: _: hostSpecs.${name}.system == system) configurations.nixosConfigurations);
      darwinChecks = lib.mapAttrs' (name: darwin: lib.nameValuePair "darwin-${name}" darwin.system) (
        lib.filterAttrs (name: _: hostSpecs.${name}.system == system) configurations.darwinConfigurations
      );
    in
    {
      checks = {
        registry = import ../tests/registry.nix {
          inherit inputs lib pkgs;
        };
      }
      // nixosChecks
      // darwinChecks;
    };
}
