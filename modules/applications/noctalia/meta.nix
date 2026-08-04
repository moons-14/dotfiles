{ inputs, ... }:
{
  description = "Noctalia Wayland desktop shell";

  includes = [
    "applications.window-overview"
  ];

  imports = {
    nixos = [ inputs.noctalia.nixosModules.default ];
    home = [ inputs.noctalia.homeModules.default ];
  };
}
