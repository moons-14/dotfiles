{
  inputs,
  lib,
  modulesRoot,
}:
let
  reservedFiles = {
    common = "common.nix";
    nixos = "nixos.nix";
    darwin = "darwin.nix";
    home = "home.nix";
    meta = "meta.nix";
  };

  isFile = kind: kind == "regular" || kind == "symlink";

  ensure =
    condition: message: value:
    if condition then value else throw "unit registry: ${message}";

  callWithAvailableArgs =
    value: availableArgs:
    if builtins.isFunction value then
      value (builtins.intersectAttrs (builtins.functionArgs value) availableArgs)
    else
      value;

  pathFor =
    relativePath:
    if relativePath == [ ] then
      modulesRoot
    else
      modulesRoot + "/${lib.concatStringsSep "/" relativePath}";

  entryIsFile = entries: name: builtins.hasAttr name entries && isFile entries.${name};

  normalizeMeta =
    unit:
    let
      metaPath = unit.fragments.meta;
      importedValue =
        if metaPath == null then
          { }
        else
          callWithAvailableArgs (import metaPath) {
            inherit inputs lib unit;
          };
      imported =
        ensure (builtins.isAttrs importedValue) "${unit.id}: meta.nix must return an attribute set"
          importedValue;
      allowedKeys = [
        "description"
        "includes"
        "imports"
      ];
      unknownKeys = lib.filter (name: !(builtins.elem name allowedKeys)) (builtins.attrNames imported);
      description = imported.description or null;
      includes = imported.includes or [ ];
      imports = imported.imports or { };
      allowedImportKeys = [
        "nixos"
        "darwin"
        "home"
      ];
      unknownImportKeys =
        if builtins.isAttrs imports then
          lib.filter (name: !(builtins.elem name allowedImportKeys)) (builtins.attrNames imports)
        else
          [ ];
      normalized = {
        inherit description includes;
        imports = {
          nixos = imports.nixos or [ ];
          darwin = imports.darwin or [ ];
          home = imports.home or [ ];
        };
      };
    in
    ensure (unknownKeys == [ ])
      "${unit.id}: meta.nix has unsupported keys: ${lib.concatStringsSep ", " unknownKeys}"
      (
        ensure (description == null || builtins.isString description)
          "${unit.id}: meta.description must be a string"
          (
            ensure (builtins.isList includes && lib.all builtins.isString includes)
              "${unit.id}: meta.includes must be a list of fully qualified unit IDs"
              (
                ensure (lib.unique includes == includes) "${unit.id}: meta.includes contains duplicate unit IDs" (
                  ensure (builtins.isAttrs imports) "${unit.id}: meta.imports must be an attribute set" (
                    ensure (unknownImportKeys == [ ])
                      "${unit.id}: meta.imports has unsupported classes: ${lib.concatStringsSep ", " unknownImportKeys}"
                      (
                        ensure (lib.all builtins.isList [
                          normalized.imports.nixos
                          normalized.imports.darwin
                          normalized.imports.home
                        ]) "${unit.id}: every meta.imports.<class> value must be a list" normalized
                      )
                  )
                )
              )
          )
      );

  makeUnit =
    relativePath: entries:
    let
      directory = pathFor relativePath;
      id = lib.concatStringsSep "." relativePath;
      fragments = lib.mapAttrs (
        _class: fileName: if entryIsFile entries fileName then directory + "/${fileName}" else null
      ) reservedFiles;
      baseUnit = {
        inherit
          id
          directory
          fragments
          relativePath
          ;
        optionPath = [ "my" ] ++ relativePath ++ [ "enable" ];
        kind = builtins.head relativePath;
        name = lib.last relativePath;
      }
      //
        lib.optionalAttrs (builtins.length relativePath > 2 && builtins.head relativePath == "profiles")
          {
            group = builtins.elemAt relativePath 1;
          };
    in
    ensure (relativePath != [ ]) "the modules root cannot itself be a unit" (
      ensure (lib.all (component: component != "" && !(lib.hasInfix "." component)) relativePath)
        "${id}: path components must be non-empty and must not contain dots"
        (baseUnit // { meta = normalizeMeta baseUnit; })
    );

  walk =
    relativePath:
    let
      directory = pathFor relativePath;
      entries = builtins.readDir directory;
      hasReservedFile = lib.any (fileName: entryIsFile entries fileName) (
        builtins.attrValues reservedFiles
      );
      childDirectories = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
      current = lib.optional hasReservedFile (makeUnit relativePath entries);
      children = lib.concatMap (name: walk (relativePath ++ [ name ])) childDirectories;
    in
    current ++ children;

  discoveredUnits =
    ensure (builtins.pathExists modulesRoot) "modules root does not exist: ${toString modulesRoot}"
      (walk [ ]);
  unitsById = builtins.listToAttrs (map (unit: lib.nameValuePair unit.id unit) discoveredUnits);

  dependencyValidation = lib.foldl' (
    valid: unit:
    lib.foldl' (
      inner: includedId:
      if builtins.hasAttr includedId unitsById then
        inner
      else
        throw "unit registry: ${unit.id} includes missing unit '${includedId}'"
    ) valid unit.meta.includes
  ) true discoveredUnits;

  units = builtins.seq dependencyValidation unitsById;
  unitIds = builtins.attrNames units;

  getUnit =
    id: if builtins.hasAttr id units then units.${id} else throw "unit registry: unknown unit '${id}'";

  validateUnitIds =
    ids:
    ensure (
      builtins.isList ids && lib.all builtins.isString ids
    ) "selected units must be a list of strings" (map (id: builtins.seq (getUnit id) id) ids);

  optionDefinitions = lib.foldl' lib.recursiveUpdate { } (
    map (
      unit:
      lib.setAttrByPath unit.optionPath (
        lib.mkOption {
          type = lib.types.bool;
          default = false;
          description =
            if unit.meta.description == null then
              "Whether to enable the ${unit.id} unit."
            else
              "Whether to enable ${unit.meta.description}.";
        }
      )
    ) discoveredUnits
  );

  enabled = config: unit: lib.getAttrFromPath unit.optionPath config;

  enableUnit = id: lib.setAttrByPath (getUnit id).optionPath true;

  includeConfig =
    config: unit: lib.mkIf (enabled config unit) (lib.mkMerge (map enableUnit unit.meta.includes));

  fragmentClasses = {
    nixos = [
      "common"
      "nixos"
    ];
    darwin = [
      "common"
      "darwin"
    ];
    home = [ "home" ];
  };

  applyFragment =
    {
      config,
      fragmentPath,
      options,
      specialArgs,
      unit,
    }:
    let
      fragment = import fragmentPath;
      directArgs = specialArgs // {
        inherit
          config
          lib
          options
          specialArgs
          unit
          ;
      };
      fragmentArgSpec = builtins.functionArgs fragment;
      fragmentArgs = builtins.listToAttrs (
        lib.concatMap (
          name:
          if builtins.hasAttr name directArgs then
            [ (lib.nameValuePair name directArgs.${name}) ]
          else if fragmentArgSpec.${name} then
            [ ]
          else
            [ (lib.nameValuePair name config._module.args.${name}) ]
        ) (builtins.attrNames fragmentArgSpec)
      );
      resultValue = if builtins.isFunction fragment then fragment fragmentArgs else fragment;
      result =
        ensure (builtins.isAttrs resultValue)
          "${unit.id}: ${builtins.baseNameOf fragmentPath} must return an attribute set"
          resultValue;
      forbiddenKeys = lib.filter (name: builtins.hasAttr name result) [
        "imports"
        "options"
        "config"
      ];
    in
    ensure (forbiddenKeys == [ ])
      "${unit.id}: ${builtins.baseNameOf fragmentPath} is a configuration fragment and cannot define top-level ${lib.concatStringsSep ", " forbiddenKeys}"
      result;

  externalImports = class: lib.concatMap (unit: unit.meta.imports.${class}) discoveredUnits;

  mkModule =
    { class }:
    ensure (builtins.hasAttr class fragmentClasses) "unsupported module class '${class}'" (
      builtins.seq dependencyValidation (
        {
          config,
          lib,
          options,
          specialArgs,
          ...
        }:
        let
          fragmentConfigs = lib.concatMap (
            unit:
            lib.filter (value: value != null) (
              map (
                fragmentClass:
                let
                  fragmentPath = unit.fragments.${fragmentClass};
                in
                if fragmentPath == null then
                  null
                else
                  lib.mkIf (enabled config unit) (applyFragment {
                    inherit
                      config
                      fragmentPath
                      options
                      specialArgs
                      unit
                      ;
                  })
              ) fragmentClasses.${class}
            )
          ) discoveredUnits;
        in
        {
          imports = externalImports class;
          options = optionDefinitions;
          config = lib.mkMerge ((map (includeConfig config) discoveredUnits) ++ fragmentConfigs);
        }
      )
    );

  mkSelectionModule =
    selectedIds:
    let
      checkedIds = validateUnitIds (lib.unique selectedIds);
    in
    {
      config = lib.mkMerge (map enableUnit checkedIds);
    };
in
{
  inherit
    getUnit
    mkModule
    mkSelectionModule
    unitIds
    units
    validateUnitIds
    ;
}
