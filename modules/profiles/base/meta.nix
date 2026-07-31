{
  description = "Host-independent Nix foundation and command-line tools required everywhere";

  includes = [
    "applications.atuin"
    "applications.tealdeer"
    "applications.trippy"
    "applications.xh"
    "systems.nix"
  ];
}
