{ pkgs, ... }:
{
  services.activitywatch = {
    enable = true;

    watchers.aw-awatcher = {
      package = pkgs.awatcher;
      executable = "awatcher";
    };
  };
}
