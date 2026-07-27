{
  inputs,
  lib,
  registry,
}:
let
  ensure =
    condition: message: value:
    if condition then value else throw "host registry: ${message}";

  isLinux = system: lib.hasSuffix "-linux" system;
  isDarwin = system: lib.hasSuffix "-darwin" system;

  hostFile =
    spec: name:
    let
      path = spec.path + "/${name}";
    in
    if builtins.pathExists path then path else null;

  selectedUnits =
    spec:
    [ "users.${spec.user}" ]
    ++ map (name: "profiles.${name}") (spec.profiles or [ ])
    ++ map (name: "applications.${name}") (spec.applications or [ ])
    ++ (spec.units or [ ]);

  validateSpec =
    name: spec:
    ensure (builtins.isAttrs spec) "${name}: host specification must be an attribute set" (
      ensure (spec ? system && builtins.isString spec.system) "${name}: system is required" (
        ensure (isLinux spec.system || isDarwin spec.system)
          "${name}: unsupported system '${spec.system}'; expected a Linux NixOS or Darwin system"
          (
            ensure (spec ? user && builtins.isString spec.user && spec.user != "") "${name}: user is required" (
              ensure (spec ? path && builtins.pathExists spec.path)
                "${name}: path must name an existing host directory"
                (
                  ensure
                    (
                      spec ? stateVersion
                      && builtins.isString spec.stateVersion
                      && builtins.match "[0-9][0-9]\\.[0-9][0-9]" spec.stateVersion != null
                    )
                    "${name}: stateVersion is required and must have the form YY.MM"
                    (
                      ensure
                        (lib.all
                          (field: builtins.isList (spec.${field} or [ ]) && lib.all builtins.isString (spec.${field} or [ ]))
                          [
                            "profiles"
                            "applications"
                            "units"
                          ]
                        )
                        "${name}: profiles, applications, and units must be lists of strings"
                        (ensure (builtins.isBool (spec.homeManager or true)) "${name}: homeManager must be a boolean" spec)
                    )
                )
            )
          )
      )
    );

  mkSpecialArgs = name: spec: {
    inherit inputs registry;
    inherit (spec) system;
    hostName = name;
    primaryUser = spec.user;
  };

  mkHomeManagerModule =
    name: spec: selected:
    let
      homePath = hostFile spec "home.nix";
      homeModules = [
        (registry.mkModule { class = "home"; })
        (registry.mkSelectionModule selected)
        { home.stateVersion = spec.stateVersion; }
      ]
      ++ lib.optional (homePath != null) homePath;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs name spec;
        users.${spec.user}.imports = homeModules;
      };
    };

  mkDarwinHomeManagerModule =
    name: spec: selected:
    let
      homePath = hostFile spec "home.nix";
      homeModules = [
        (registry.mkModule { class = "home"; })
        (registry.mkSelectionModule selected)
        { home.stateVersion = spec.stateVersion; }
      ]
      ++ lib.optional (homePath != null) homePath;
    in
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = mkSpecialArgs name spec;
        users.${spec.user}.imports = homeModules;
      };
    };

  mkNixos =
    name: rawSpec:
    let
      spec = validateSpec name rawSpec;
      selected = registry.validateUnitIds (selectedUnits spec);
      nixosPath = hostFile spec "nixos.nix";
      modules = [
        (registry.mkModule { class = "nixos"; })
        (registry.mkSelectionModule selected)
        {
          networking.hostName = lib.mkDefault name;
          system.stateVersion = spec.stateVersion;
        }
      ]
      ++ lib.optional (spec.homeManager or true) (mkHomeManagerModule name spec selected)
      ++ lib.optional (nixosPath != null) nixosPath;
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit (spec) system;
      specialArgs = mkSpecialArgs name spec;
      inherit modules;
    };

  mkDarwin =
    name: rawSpec:
    let
      spec = validateSpec name rawSpec;
      selected = registry.validateUnitIds (selectedUnits spec);
      darwinPath = hostFile spec "darwin.nix";
      modules = [
        (registry.mkModule { class = "darwin"; })
        (registry.mkSelectionModule selected)
        {
          networking.hostName = lib.mkDefault name;
          system.primaryUser = lib.mkDefault spec.user;
        }
      ]
      ++ lib.optional (spec.homeManager or true) (mkDarwinHomeManagerModule name spec selected)
      ++ lib.optional (darwinPath != null) darwinPath;
    in
    ensure (inputs ? nix-darwin) "${name}: the nix-darwin input is required" (
      inputs.nix-darwin.lib.darwinSystem {
        inherit (spec) system;
        specialArgs = mkSpecialArgs name spec;
        inherit modules;
      }
    );

  mkConfigurations =
    hostSpecs:
    let
      validated = lib.mapAttrs validateSpec hostSpecs;
    in
    {
      nixosConfigurations = lib.mapAttrs mkNixos (
        lib.filterAttrs (_: spec: isLinux spec.system) validated
      );
      darwinConfigurations = lib.mapAttrs mkDarwin (
        lib.filterAttrs (_: spec: isDarwin spec.system) validated
      );
    };
in
{
  inherit
    mkConfigurations
    mkDarwin
    mkNixos
    selectedUnits
    ;
}
