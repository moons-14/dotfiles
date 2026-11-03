{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.nixvim = {
    enable = true;
    imports = [ ./config.nix ];

    nixpkgs = {
      source = pkgs.path;
      config.allowUnfree = true;
    };
  };
}
