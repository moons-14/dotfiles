{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.python;
in
{
  options.my.features.dev.python = {
    enable = lib.mkEnableOption "Python development environment";
  };

  config = lib.mkIf cfg.enable {
    documentation.doc.enable = false;

    environment.systemPackages = with pkgs; [
      python312 # Python 3.12
      uv # Universal Virtual Environment Manager For Python
    ];
  };
}
