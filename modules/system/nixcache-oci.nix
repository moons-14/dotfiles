{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.nixcacheOci;
  publicKeyFile = ../../nixcache-public-key.txt;
  publicKey =
    if builtins.pathExists publicKeyFile then
      lib.strings.trim (builtins.readFile publicKeyFile)
    else
      "";
in
{
  options.my.system.nixcacheOci = {
    enable = lib.mkEnableOption "Nix binary cache backed by the public GitHub Container Registry";
  };

  config = lib.mkIf cfg.enable {
    services.nixcache-proxy = {
      enable = true;
      repo = "moons-14/dotfiles";
      inherit publicKey;
    };
  };
}
