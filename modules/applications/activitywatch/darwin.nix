{
  homebrew.casks = [ "activitywatch" ];

  launchd.agents.activitywatch = {
    command = "/usr/bin/open -gja ActivityWatch";
    serviceConfig.RunAtLoad = true;
  };
}
