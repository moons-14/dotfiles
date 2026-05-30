{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.bun;
in
{
  options.my.features.dev.bun = {
    enable = lib.mkEnableOption "Bun JavaScript runtime";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bun # A Fast JavaScript Runtime Like Node.js And Deno
    ];
  };
}
