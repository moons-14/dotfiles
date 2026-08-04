{
  homebrew.casks = [ "handy" ];

  launchd.agents.handy = {
    command = "/usr/bin/open -gja Handy --args --start-hidden";
    serviceConfig.RunAtLoad = true;
  };
}
