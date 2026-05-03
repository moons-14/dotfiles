{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };

    settings = {
      font.size = 11;
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;
      theme = {
        light = {
          name = "dracula";
          icon_theme = "default";
        };
        dark = {
          name = "vicinae-light";
          icon_theme = "default";
        };
      };
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      bluetooth
      nix
      power-profile
      # Extension names can be found in the link below, it's just the folder names
    ];
  };
}
