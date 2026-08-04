{
  config,
  lib,
  pkgs,
  ...
}:
let
  settings = import ../settings.nix;
  inherit (settings)
    assetsDirectory
    fps
    mute
    scaling
    selectedWallpaperId
    switchIntervalSeconds
    wallpaperIds
    workshopDirectory
    ;

  resolveHomePath =
    path:
    if lib.hasPrefix "~/" path then
      "${config.home.homeDirectory}/${lib.removePrefix "~/" path}"
    else if lib.hasPrefix "/" path then
      path
    else
      "${config.home.homeDirectory}/${path}";

  hasWallpapers = wallpaperIds != [ ];
  defaultWallpaperId =
    if selectedWallpaperId != null then
      selectedWallpaperId
    else if hasWallpapers then
      lib.head wallpaperIds
    else
      "";
  configurationId = builtins.hashString "sha256" (builtins.toJSON settings);
  resolvedAssetsDirectory = resolveHomePath assetsDirectory;
  resolvedWorkshopDirectory = resolveHomePath workshopDirectory;
  playlist = pkgs.writeText "linux-wallpaperengine-playlist" (
    lib.concatMapStringsSep "\n" (id: id) wallpaperIds + "\n"
  );
  engineArguments = lib.optional mute "--silent" ++ [
    "--fps"
    (toString fps)
  ];

  controller = pkgs.writeShellApplication {
    name = "wallpaperengine-wallpaper";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.systemd
    ];
    text = ''
      exec ${lib.getExe pkgs.bash} ${./controller.sh} \
        ${lib.escapeShellArg playlist} \
        ${lib.escapeShellArg defaultWallpaperId} \
        ${lib.escapeShellArg configurationId} \
        "$@"
    '';
  };

  launcher = pkgs.writeShellApplication {
    name = "linux-wallpaperengine-launcher";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.jq
      pkgs.linux-wallpaperengine
      pkgs.wlr-randr
    ];
    text = ''
      exec ${lib.getExe pkgs.bash} ${./launcher.sh} \
        ${lib.escapeShellArg playlist} \
        ${lib.escapeShellArg defaultWallpaperId} \
        ${lib.escapeShellArg configurationId} \
        ${lib.escapeShellArg resolvedAssetsDirectory} \
        ${lib.escapeShellArg resolvedWorkshopDirectory} \
        ${lib.escapeShellArg scaling} \
        ${lib.escapeShellArgs engineArguments}
    '';
  };
in
assert lib.assertMsg (lib.all (
  id: builtins.isString id && builtins.match "[0-9]+" id != null
) wallpaperIds) "linux-wallpaperengine: wallpaperIds must contain only numeric strings";
assert lib.assertMsg (
  lib.unique wallpaperIds == wallpaperIds
) "linux-wallpaperengine: wallpaperIds must not contain duplicates";
assert lib.assertMsg (
  selectedWallpaperId == null || builtins.elem selectedWallpaperId wallpaperIds
) "linux-wallpaperengine: selectedWallpaperId must be null or a member of wallpaperIds";
assert lib.assertMsg (
  switchIntervalSeconds == null || (builtins.isInt switchIntervalSeconds && switchIntervalSeconds > 0)
) "linux-wallpaperengine: switchIntervalSeconds must be null or a positive integer";
assert lib.assertMsg (
  builtins.isInt fps && fps > 0
) "linux-wallpaperengine: fps must be a positive integer";
assert lib.assertMsg (
  builtins.isString assetsDirectory && assetsDirectory != ""
) "linux-wallpaperengine: assetsDirectory must be a non-empty string";
assert lib.assertMsg (
  builtins.isString workshopDirectory && workshopDirectory != ""
) "linux-wallpaperengine: workshopDirectory must be a non-empty string";
assert lib.assertMsg (builtins.elem scaling [
  "default"
  "fill"
  "fit"
  "stretch"
]) "linux-wallpaperengine: scaling must be default, fill, fit, or stretch";
{
  home.packages = [
    controller
    pkgs.linux-wallpaperengine
  ];

  systemd.user.services = lib.optionalAttrs hasWallpapers {
    linux-wallpaperengine = {
      Unit = {
        Description = "Linux Wallpaper Engine";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe launcher;
        Restart = "on-abnormal";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    linux-wallpaperengine-switch = {
      Unit.Description = "Switch Linux Wallpaper Engine wallpaper";
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe controller} next";
      };
    };
  };

  systemd.user.timers =
    lib.optionalAttrs
      (hasWallpapers && builtins.length wallpaperIds > 1 && switchIntervalSeconds != null)
      {
        linux-wallpaperengine-switch = {
          Unit = {
            Description = "Periodically switch Linux Wallpaper Engine wallpaper";
            PartOf = [ "graphical-session.target" ];
          };
          Timer = {
            OnActiveSec = "${toString switchIntervalSeconds}s";
            OnUnitActiveSec = "${toString switchIntervalSeconds}s";
            Unit = "linux-wallpaperengine-switch.service";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
}
