{
  description = "Cross-platform interactive command-line environment";

  includes = [
    "profiles.interface.minimal"
    "applications.nix-index"
    "applications.vim"
    "applications.yazi"
    "applications.zoxide"
  ];
}
