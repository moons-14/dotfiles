{...}: {
  programs.nixvim = {
    plugins.dashboard-nvim = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          header = [
            ""
            "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
            "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║"
            "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║"
            "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║"
            "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║"
            "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝"
            ""
            "                  ✦   ·   ☽   ·   ✦"
            ""
          ];

          center = [
            {
              icon = "  ";
              icon_hl = "DashboardIconFind";
              desc = "Find File";
              desc_hl = "DashboardDesc";
              key = "f";
              key_hl = "DashboardKey";
              action.__raw = "function() require('telescope.builtin').find_files() end";
            }
            {
              icon = "  ";
              icon_hl = "DashboardIconRecent";
              desc = "Recent Files";
              desc_hl = "DashboardDesc";
              key = "r";
              key_hl = "DashboardKey";
              action.__raw = "function() require('telescope.builtin').oldfiles() end";
            }
            {
              icon = "  ";
              icon_hl = "DashboardIconProject";
              desc = "Recent Projects";
              desc_hl = "DashboardDesc";
              key = "p";
              key_hl = "DashboardKey";
              action.__raw = "function() require('telescope').extensions['projects'].projects() end";
            }
            {
              icon = "  ";
              icon_hl = "DashboardIconGrep";
              desc = "Find Word";
              desc_hl = "DashboardDesc";
              key = "g";
              key_hl = "DashboardKey";
              action.__raw = "function() require('telescope.builtin').live_grep() end";
            }
            {
              icon = "  ";
              icon_hl = "DashboardIconNew";
              desc = "New File";
              desc_hl = "DashboardDesc";
              key = "n";
              key_hl = "DashboardKey";
              action = "enew";
            }
            {
              icon = "  ";
              icon_hl = "DashboardIconDots";
              desc = "Dotfiles";
              desc_hl = "DashboardDesc";
              key = "d";
              key_hl = "DashboardKey";
              action.__raw = "function() require('telescope.builtin').find_files({ cwd = vim.fn.expand('~/dotfiles') }) end";
            }
            {
              icon = "  ";
              icon_hl = "DashboardIconQuit";
              desc = "Quit";
              desc_hl = "DashboardDesc";
              key = "q";
              key_hl = "DashboardKey";
              action = "qa";
            }
          ];

          footer = [
            ""
            "  NixOS · nixvim · Catppuccin Mocha"
          ];
        };
      };
    };

    # Catppuccin Mocha カラーに合わせたハイライト
    highlight = {
      DashboardHeader = {
        fg = "#cba6f7";
        bold = true;
      };
      DashboardIconFind = {fg = "#89b4fa";};
      DashboardIconRecent = {fg = "#fab387";};
      DashboardIconProject = {fg = "#94e2d5";};
      DashboardIconGrep = {fg = "#a6e3a1";};
      DashboardIconNew = {fg = "#89dceb";};
      DashboardIconDots = {fg = "#f5c2e7";};
      DashboardIconQuit = {fg = "#f38ba8";};
      DashboardDesc = {fg = "#cdd6f4";};
      DashboardKey = {
        fg = "#b4befe";
        bold = true;
      };
      DashboardFooter = {
        fg = "#7f849c";
        italic = true;
      };
    };
  };
}
