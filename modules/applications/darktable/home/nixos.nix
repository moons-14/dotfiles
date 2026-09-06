{
  inputs,
  osConfig,
  pkgs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    # Keep default CUDA targets so dependencies match the CUDA binary cache.
    config = pkgs.config // {
      cudaSupport = osConfig.my.hardwares.nvidia.enable;
    };
  };
in
{
  home.packages = [
    (unstable.darktable.override {
      withAi = true;
    })
  ];
}
