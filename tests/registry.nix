{
  inputs,
  lib,
  pkgs,
}:
let
  registry = import ../libs/registry.nix {
    inherit inputs lib;
    modulesRoot = ./fixtures/registry/modules;
  };

  hostLib = import ../libs/hosts.nix {
    inherit inputs lib registry;
  };

  baseModule = {
    options = {
      home = {
        username = lib.mkOption { type = lib.types.str; };
        homeDirectory = lib.mkOption { type = lib.types.str; };
        stateVersion = lib.mkOption { type = lib.types.str; };
      };
    };
  };

  eval =
    class: selected:
    lib.evalModules {
      specialArgs = {
        inherit pkgs;
        marker = "special-arg";
      };
      modules = [
        baseModule
        (registry.mkModule { inherit class; })
        (registry.mkSelectionModule selected)
      ];
    };

  nixos = eval "nixos" [ "profiles.interface.test" ];
  darwin = eval "darwin" [ "applications.alpha" ];
  home = eval "home" [ "profiles.interface.test" ];

  nixosHost = hostLib.mkNixos "registry-test" {
    system = "x86_64-linux";
    user = "test";
    path = ./fixtures/registry/hosts;
    profiles = [ "interface.test" ];
  };

  darwinHost = hostLib.mkDarwin "registry-test-darwin" {
    system = "aarch64-darwin";
    user = "test";
    path = ./fixtures/registry/hosts;
    applications = [ "alpha" ];
  };

  missingUnit = builtins.tryEval (
    builtins.deepSeq (registry.validateUnitIds [ "applications.missing" ]) true
  );

  invalidDependencyRegistry = import ../libs/registry.nix {
    inherit inputs lib;
    modulesRoot = ./fixtures/registry-invalid-dependency/modules;
  };
  missingDependency = builtins.tryEval (builtins.deepSeq invalidDependencyRegistry.unitIds true);

  invalidFragmentRegistry = import ../libs/registry.nix {
    inherit inputs lib;
    modulesRoot = ./fixtures/registry-invalid-fragment/modules;
  };
  invalidFragmentEvaluation = lib.evalModules {
    modules = [
      (invalidFragmentRegistry.mkModule { class = "home"; })
      (invalidFragmentRegistry.mkSelectionModule [ "applications.broken" ])
    ];
  };
  invalidFragment = builtins.tryEval (builtins.deepSeq invalidFragmentEvaluation.config true);

  assertions =
    assert
      registry.unitIds == [
        "applications.alpha"
        "applications.beta"
        "profiles.interface.test"
        "services.nested"
        "users.test"
      ];
    assert !(builtins.elem "namespace" registry.unitIds);
    assert nixos.config.my.profiles.interface.test.enable;
    assert nixos.config.my.applications.alpha.enable;
    assert nixos.config.my.applications.beta.enable;
    assert nixos.config.my.services.nested.enable;
    assert nixos.config.test.nested;
    assert
      nixos.config.test.systemValues == [
        "common:special-arg"
        "nixos"
      ];
    assert nixos.config.test.external == "set-by-nixos-fragment";
    assert
      darwin.config.test.systemValues == [
        "common:special-arg"
        "darwin"
      ];
    assert
      home.config.test.homeValues == [
        "home"
        "beta-home"
      ];
    assert nixosHost.config.my.profiles.interface.test.enable;
    assert nixosHost.config.home-manager.users.test.my.applications.alpha.enable;
    assert
      nixosHost.config.home-manager.users.test.test.homeValues == [
        "home"
        "beta-home"
      ];
    assert darwinHost.config.my.applications.alpha.enable;
    assert darwinHost.config.home-manager.users.test.my.applications.alpha.enable;
    assert darwinHost.config.home-manager.users.test.test.homeValues == [ "home" ];
    assert
      darwinHost.config.test.systemValues == [
        "common:host"
        "darwin"
      ];
    assert !missingUnit.success;
    assert !missingDependency.success;
    assert !invalidFragment.success;
    true;
in
assert assertions;
pkgs.runCommand "unit-registry-evaluation-tests" { } ''
  touch "$out"
''
