{ inputs, ... }:
{
  description = "Noctalia Wayland desktop shell";

  imports = {
    nixos = [ inputs.noctalia.nixosModules.default ];
    home = [ inputs.noctalia.homeModules.default ];
  };
}
