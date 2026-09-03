{
  config,
  pkgs,
  primaryUser,
  ...
}:

let
  homeDirectory = "/home/${primaryUser}";
  fleetDirectory = "${homeDirectory}/srv/nix-fleet";
  stateDirectory = "/var/lib/nix-fleet";
  sourceDirectory = "${stateDirectory}/source";

  git = "${pkgs.git}/bin/git";
  nix = "${config.nix.package}/bin/nix";
  rsync = "${pkgs.rsync}/bin/rsync";

  cleanCheckoutConditions = [
    "${git} -C ${fleetDirectory} diff --quiet"
    "${git} -C ${fleetDirectory} diff --cached --quiet"
  ];
in
{
  systemd.services.nix-fleet-converge = {
    description = "Update inputs, build the fleet, and deploy changed hosts";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    environment = {
      HOME = homeDirectory;
      NIX_CONFIG = ''
        accept-flake-config = true
        max-jobs = 4
        cores = 3
      '';
    };

    serviceConfig = {
      Type = "oneshot";
      User = primaryUser;
      Restart = "on-failure";
      RestartSec = "5min";
      StateDirectory = "nix-fleet";
      StateDirectoryMode = "0750";
      WorkingDirectory = stateDirectory;
      UMask = "0077";
      ExecCondition = cleanCheckoutConditions;
      EnvironmentFile = "${fleetDirectory}/.env";

      # Work in a disposable copy so updating the dotfiles lock never dirties
      # the operator's nix-fleet checkout.
      ExecStart = [
        "${git} -C ${fleetDirectory} pull --ff-only"
        "${rsync} --archive --delete --exclude=.git/ --exclude=.direnv/ --exclude=.env --exclude=result --exclude=result-* ${fleetDirectory}/ ${sourceDirectory}/"
        "${nix} flake update --flake ${sourceDirectory} dotfiles"
        "${nix} run ${sourceDirectory}#converge -- ${sourceDirectory} ${stateDirectory}"
      ];
    };
  };

  systemd.timers.nix-fleet-converge = {
    description = "Periodically converge the NixOS fleet";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitInactiveSec = "5min";
      RandomizedDelaySec = "30s";
      Persistent = true;
      Unit = "nix-fleet-converge.service";
    };
  };

  # Only an actual successful deployment touches gc-request. This starts the
  # builder's root nh-clean unit; remote host stores are never cleaned here.
  systemd.paths.nix-fleet-gc = {
    description = "Garbage-collect superseded fleet builds on nix-builder";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "${stateDirectory}/gc-request";
      Unit = "nh-clean.service";
    };
  };
}
