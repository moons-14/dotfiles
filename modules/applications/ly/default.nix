{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.applications.ly;
  indyzLinuxfire = pkgs.fetchurl {
    url = "https://codeberg.org/attachments/f336d6ac-8331-4323-91fc-0e4619803401";
    hash = "sha256-fRm0wlkq9/GdLrVBOzMEnQG/i2ng+uGIzq0u9hu3m9g=";
  };
in
{
  options.my.applications.ly = {
    enable = lib.mkEnableOption "ly TUI display manager";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.defaultSession = lib.mkDefault "niri";

    services.displayManager.ly = {
      enable = true;
      settings = {
        default_session = "niri";

        animate = true;
        animation = "dur_file";
        dur_file_path = "${indyzLinuxfire}";
        dur_offset_alignment = "center";

        full_color = true;
      };
    };
  };
}
