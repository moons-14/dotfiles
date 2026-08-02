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
    class: systemClass: selected:
    lib.evalModules {
      specialArgs = {
        inherit pkgs;
        marker = "special-arg";
      };
      modules = [
        baseModule
        (registry.mkModule { inherit class systemClass; })
        (registry.mkSelectionModule selected)
      ];
    };

  nixos = eval "nixos" null [ "profiles.interface.test" ];
  darwin = eval "darwin" null [ "applications.alpha" ];
  nixosHome = eval "home" "nixos" [ "profiles.interface.test" ];
  darwinHome = eval "home" "darwin" [ "applications.alpha" ];
  nixosOnlyHome = eval "home" "nixos" [ "applications.gamma" ];
  darwinWithoutNixosHome = eval "home" "darwin" [ "applications.gamma" ];

  nixosHost = hostLib.mkNixos "registry-test" {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "test";
    path = ./fixtures/registry/hosts;
    profiles = [ "interface.test" ];
  };

  darwinHost = hostLib.mkDarwin "registry-test-darwin" {
    system = "aarch64-darwin";
    stateVersion = "26.05";
    user = "test";
    path = ./fixtures/registry/hosts;
    applications = [ "alpha" ];
  };

  missingUnit = builtins.tryEval (
    builtins.deepSeq (registry.validateUnitIds [ "applications.missing" ]) true
  );
  homeWithoutSystemClass = builtins.tryEval (registry.mkModule { class = "home"; });
  homeWithInvalidSystemClass = builtins.tryEval (
    registry.mkModule {
      class = "home";
      systemClass = "linux";
    }
  );
  systemWithHomeSystemClass = builtins.tryEval (
    registry.mkModule {
      class = "nixos";
      systemClass = "nixos";
    }
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
      (invalidFragmentRegistry.mkModule {
        class = "home";
        systemClass = "nixos";
      })
      (invalidFragmentRegistry.mkSelectionModule [ "applications.broken" ])
    ];
  };
  invalidFragment = builtins.tryEval (builtins.deepSeq invalidFragmentEvaluation.config true);

  assertions =
    assert
      registry.unitIds == [
        "applications.alpha"
        "applications.beta"
        "applications.gamma"
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
      nixosHome.config.test.homeValues == [
        "home"
        "home-common"
        "home-nixos"
        "beta-home"
      ];
    assert
      darwinHome.config.test.homeValues == [
        "home"
        "home-common"
        "home-darwin"
      ];
    assert nixosOnlyHome.config.test.homeValues == [ "gamma-home-nixos" ];
    assert darwinWithoutNixosHome.config.test.homeValues == [ ];
    assert nixosHost.config.my.profiles.interface.test.enable;
    assert nixosHost.config.system.stateVersion == "26.05";
    assert nixosHost.config.home-manager.users.test.home.stateVersion == "26.05";
    assert nixosHost.config.home-manager.users.test.my.applications.alpha.enable;
    assert
      nixosHost.config.home-manager.users.test.test.homeValues == [
        "home"
        "home-common"
        "home-nixos"
        "beta-home"
      ];
    assert darwinHost.config.my.applications.alpha.enable;
    assert darwinHost.config.home-manager.users.test.home.stateVersion == "26.05";
    assert darwinHost.config.home-manager.users.test.my.applications.alpha.enable;
    assert
      darwinHost.config.home-manager.users.test.test.homeValues == [
        "home"
        "home-common"
        "home-darwin"
      ];
    assert
      darwinHost.config.test.systemValues == [
        "common:host"
        "darwin"
      ];
    assert !missingUnit.success;
    assert !homeWithoutSystemClass.success;
    assert !homeWithInvalidSystemClass.success;
    assert !systemWithHomeSystemClass.success;
    assert !missingDependency.success;
    assert !invalidFragment.success;
    true;
in
assert assertions;
pkgs.runCommand "unit-registry-evaluation-tests" { } ''
  touch "$out"
''
