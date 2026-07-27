{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;
    };
    extraPackages =
      with pkgs;
      [
        file
        ffmpeg
        _7zz-rar
        jq
        poppler
        fd
        ripgrep
        fzf
        zoxide
        resvg
        imagemagick
      ]
      ++ lib.optionals isLinux [
        wl-clipboard
        xdg-utils
      ];
    plugins = {
      "full-border" = {
        package = pkgs.yaziPlugins.full-border;
        setup = true;
      };
      "toggle-pane" = pkgs.yaziPlugins.toggle-pane;
      chmod = pkgs.yaziPlugins.chmod;
    };
    keymap.mgr.prepend_keymap = [
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore preview pane";
      }
      {
        on = [
          "c"
          "m"
        ];
        run = "plugin chmod";
        desc = "Chmod selected files";
      }
    ];
    settings = {
      mgr = {
        ratio = [
          1
          3
          4
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_dir_first = true;
        sort_reverse = false;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
        scrolloff = 8;
      };
      preview = {
        wrap = "yes";
        tab_size = 2;
      };
      opener = {
        edit = [
          {
            run = "${pkgs.neovim}/bin/nvim %s";
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = "${pkgs.xdg-utils}/bin/xdg-open %s";
            orphan = true;
            desc = "Open";
            for = "linux";
          }
          {
            run = "open %s";
            orphan = true;
            desc = "Open";
            for = "macos";
          }
        ];
      };
      open.prepend_rules = [
        {
          mime = "text/*";
          use = "edit";
        }
        {
          url = "*.nix";
          use = "edit";
        }
        {
          url = "*.json";
          use = "edit";
        }
        {
          url = "*.md";
          use = "edit";
        }
        {
          mime = "image/*";
          use = "open";
        }
        {
          mime = "video/*";
          use = "open";
        }
        {
          mime = "audio/*";
          use = "open";
        }
        {
          mime = "application/pdf";
          use = "open";
        }
      ];
    };
  };
}
