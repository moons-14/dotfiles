{
  inputs,
  pkgs,
  ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    package = unstable.pipewire;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}
