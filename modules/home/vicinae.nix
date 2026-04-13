{ inputs, ... }:
{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  services.vicinae = {
    enable = true;
    # package = [ ];
    settings = {
      faviconService = "twenty"; # twenty | google | none
      font.size = 11;
      popToRootOnClose = false;
      rootSearch.searchFiles = false;
      theme.name = "dracula";
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
  };
}
