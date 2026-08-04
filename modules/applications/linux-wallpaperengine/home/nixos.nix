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

  mkVicinaeScript =
    {
      name,
      title,
      description,
      command,
      mode ? "compact",
      message ? null,
    }:
    {
      name = "vicinae/scripts/wallpaper-engine/${name}";
      value = {
        executable = true;
        text = ''
          #!${lib.getExe pkgs.bash}
          # @vicinae.schemaVersion 1
          # @vicinae.title ${title}
          # @vicinae.description ${description}
          # @vicinae.mode ${mode}
          # @vicinae.icon 🖼️

          ${lib.getExe controller} ${lib.escapeShellArg command}
          ${lib.optionalString (message != null) "printf '%s\\n' ${lib.escapeShellArg message}"}
        '';
      };
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

  xdg.dataFile = builtins.listToAttrs [
    (mkVicinaeScript {
      name = "reload";
      title = "Reload Wallpaper Engine";
      description = "Restart the active Wallpaper Engine background";
      command = "restart";
      message = "Wallpaper Engine reloaded";
    })
    (mkVicinaeScript {
      name = "next";
      title = "Next Wallpaper Engine Wallpaper";
      description = "Switch to the next configured Wallpaper Engine background";
      command = "next";
      message = "Switched to the next Wallpaper Engine wallpaper";
    })
    (mkVicinaeScript {
      name = "previous";
      title = "Previous Wallpaper Engine Wallpaper";
      description = "Switch to the previous configured Wallpaper Engine background";
      command = "previous";
      message = "Switched to the previous Wallpaper Engine wallpaper";
    })
    (mkVicinaeScript {
      name = "list";
      title = "List Wallpaper Engine Wallpapers";
      description = "Show the configured Wallpaper Engine backgrounds";
      command = "list";
      mode = "fullOutput";
    })
    (mkVicinaeScript {
      name = "current";
      title = "Current Wallpaper Engine Wallpaper";
      description = "Show the active Wallpaper Engine background";
      command = "current";
    })
    (mkVicinaeScript {
      name = "stop";
      title = "Stop Wallpaper Engine";
      description = "Stop Wallpaper Engine for this session";
      command = "stop";
      message = "Wallpaper Engine stopped";
    })
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
