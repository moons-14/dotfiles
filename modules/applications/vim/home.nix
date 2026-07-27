{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;

    nixpkgs = {
      source = pkgs.path;
      config.allowUnfree = true;
    };

    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      nodejs
      zellij
      vtsls
      vscode-langservers-extracted
      tailwindcss-language-server
      prettierd
      prettier
      biome
      stylua
      shfmt
      alejandra
      nixfmt
      lua-language-server
      nixd
      lazygit
    ];

    opts = {
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      termguicolors = true;
      mouse = "a";
      clipboard = "unnamedplus";
      updatetime = 200;
      timeoutlen = 300;
      undofile = true;
      wrap = false;
      scrolloff = 8;
      ignorecase = true;
      smartcase = true;
      splitright = true;
      splitbelow = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      encoding = "utf-8";
      fileencoding = "utf-8";
      fileencodings = "utf-8,sjis,euc-jp,iso-2022-jp";
      list = true;
      listchars = "tab:»-,trail:-,extends:»,precedes:«,nbsp:%";
      jumpoptions = "stack";
      switchbuf = "useopen,uselast";
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      clipboard = "osc52";
    };

    env = {
      LANG = "ja_JP.UTF-8";
      LC_MESSAGES = "ja_JP.UTF-8";
    };

    autoCmd = [
      {
        event = "TextYankPost";
        callback.__raw = "function() vim.highlight.on_yank() end";
      }
    ];

    colorschemes.catppuccin = {
      enable = true;
      settings.transparent_background = true;
    };

    diagnostic.settings = {
      virtual_text = true;
      float = {
        border = "rounded";
        source = true;
      };
    };

    plugins = {
      lsp = {
        enable = true;
        servers = {
          vtsls = {
            enable = true;
            packageFallback = true;
            rootMarkers = [
              "pnpm-workspace.yaml"
              "package.json"
              "tsconfig.json"
              "jsconfig.json"
              ".git"
            ];
            extraOptions.settings.typescript.locale = "ja";
          };
          biome = {
            enable = true;
            packageFallback = true;
            rootMarkers = [
              "biome.json"
              "biome.jsonc"
              "package.json"
              "pnpm-workspace.yaml"
              ".git"
            ];
          };
          tailwindcss.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          lua_ls.enable = true;
          nixd.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          svelte.enable = true;
          ty.enable = true;
          ruff.enable = true;
          astro.enable = true;
          gopls.enable = true;
        };
      };

      blink-cmp = {
        enable = true;
        setupLspCapabilities = true;
        settings = {
          keymap = {
            preset = "enter";
            "<C-Space>" = [ "show" ];
            "<C-d>" = [ "scroll_documentation_up" ];
            "<C-e>" = [ "hide" ];
            "<C-f>" = [ "scroll_documentation_down" ];
            "<Tab>" = [
              "accept"
              {
                __raw = ''
                  function()
                    local ok, copilot = pcall(require, "copilot.suggestion")
                    if ok and copilot.is_visible() then
                      copilot.accept()
                      return true
                    end
                  end
                '';
              }
              "fallback"
            ];
            "<S-Tab>" = [
              "select_prev"
              "fallback"
            ];
            "<C-n>" = [
              "select_next"
              "fallback"
            ];
            "<C-p>" = [
              "select_prev"
              "fallback"
            ];
          };
          completion.list.selection = {
            preselect = true;
            auto_insert = false;
          };
          sources.default = [
            "lsp"
            "path"
            "buffer"
          ];
        };
      };

      nvim-autopairs.enable = true;
      comment.enable = true;
      "conform-nvim" = {
        enable = true;
        settings = {
          formatters_by_ft = {
            javascript.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
            javascriptreact.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
            typescript.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
            typescriptreact.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
            json.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
            yaml.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
            markdown.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
            lua = [ "stylua" ];
            nix.__raw = ''{ "nix_fmt", "alejandra", stop_after_first = true }'';
            sh = [ "shfmt" ];
          };
          formatters.nix_fmt.command = "nixfmt";
          format_on_save.__raw = ''
            function(_)
              return { timeout_ms = 1000, lsp_format = "fallback" }
            end
          '';
        };
      };
      copilot-lua = {
        enable = true;
        settings.suggestion = {
          auto_trigger = true;
          keymap.enabled = false;
        };
      };
      lazygit.enable = true;
      diffview.enable = true;
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
        };
      };
      lsp-signature = {
        enable = true;
        settings = {
          hint_enable = true;
          hint_prefix = " ";
          floating_window = true;
          bind = true;
        };
      };
      nvim-surround.enable = true;
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      trouble.enable = true;
      barbar = {
        enable = true;
        settings = {
          animation = false;
          auto_hide = 1;
          tabpages = true;
          clickable = true;
          focus_on_close = "left";
          icons = {
            button = "󰅖";
            separator = {
              left = "▎";
              right = "";
            };
            separator_at_end = false;
            filetype.enabled = true;
          };
          sidebar_filetypes.neo-tree = true;
        };
      };
      indent-blankline = {
        enable = true;
        settings = {
          scope = {
            enabled = true;
            show_start = true;
            show_end = true;
          };
          exclude.filetypes = [
            "help"
            "neo-tree"
            "toggleterm"
            "lazy"
          ];
        };
      };
      colorizer = {
        enable = true;
        settings = {
          filetypes = [
            "*"
            "!markdown"
          ];
          user_commands = true;
          options = {
            parsers = {
              css = true;
              tailwind = {
                enable = true;
                lsp = true;
                update_names = true;
              };
            };
            display.mode = "background";
          };
        };
      };
      dropbar.enable = true;
      nvim-lightbulb = {
        enable = true;
        settings.autocmd.enabled = true;
      };
      lualine = {
        enable = true;
        settings.sections.lualine_x = [
          {
            __raw = ''
              function()
                local ok, conform = pcall(require, "conform")
                if not ok then return "" end
                for _, formatter in ipairs(conform.list_formatters(0)) do
                  if formatter.available then return "󰛖 " .. formatter.name end
                end
                return ""
              end
            '';
          }
          "encoding"
          "fileformat"
          "filetype"
        ];
      };
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          filesystem = {
            follow_current_file = {
              enabled = true;
              leave_dirs_open = true;
            };
            filtered_items = {
              visible = true;
              hide_dotfiles = false;
              hide_gitignored = true;
              hide_ignored = false;
              hide_hidden = false;
              never_show = [
                ".DS_Store"
                "thumbs.db"
              ];
            };
          };
        };
      };
      toggleterm.enable = true;
      "treesitter-context".enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      flash-nvim
      git-conflict-nvim
      glance-nvim
      snacks-nvim
      nvim-spectre
      todo-comments-nvim
      nvim-ts-autotag
      vim-wakatime
      markview-nvim
      nvim-scrollbar
      nvim-ufo
      promise-async
      zen-mode-nvim
    ];

    extraConfigLua = ''
      vim.cmd.language("ja_JP.utf8")
      vim.opt.helplang = { "ja", "en" }

      require("flash").setup()
      require("git-conflict").setup()
      require("glance").setup()
      require("spectre").setup()
      require("todo-comments").setup()
      require("nvim-ts-autotag").setup()
      require("markview").setup({ initial_state = false })
      require("scrollbar").setup()
      require("zen-mode").setup()
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
      require("snacks").setup({
        picker = {
          enabled = true,
          actions = require("trouble.sources.snacks").actions,
          win = { input = { keys = {
            ["<C-t>"] = { "trouble_open", mode = { "n", "i" } },
          } } },
        },
        notifier = { enabled = true },
        words = { enabled = true },
        scroll = { enabled = true },
        dim = { enabled = true },
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
        options = {
          silent = true;
          desc = "検索ハイライトを解除";
        };
      }
      {
        mode = "n";
        key = "j";
        action.__raw = "function() return vim.v.count == 0 and 'gj' or 'j' end";
        options = {
          silent = true;
          expr = true;
          desc = "下へ移動";
        };
      }
      {
        mode = "n";
        key = "k";
        action.__raw = "function() return vim.v.count == 0 and 'gk' or 'k' end";
        options = {
          silent = true;
          expr = true;
          desc = "上へ移動";
        };
      }
      {
        mode = "n";
        key = "K";
        action.__raw = "vim.lsp.buf.hover";
        options = {
          silent = true;
          desc = "シンボル情報";
        };
      }
      {
        mode = "n";
        key = "gd";
        action.__raw = "vim.lsp.buf.definition";
        options = {
          silent = true;
          desc = "定義へジャンプ";
        };
      }
      {
        mode = "n";
        key = "grr";
        action.__raw = "vim.lsp.buf.references";
        options = {
          silent = true;
          desc = "参照一覧";
        };
      }
      {
        mode = "n";
        key = "gri";
        action.__raw = "vim.lsp.buf.implementation";
        options = {
          silent = true;
          desc = "実装一覧";
        };
      }
      {
        mode = "n";
        key = "grt";
        action.__raw = "vim.lsp.buf.type_definition";
        options = {
          silent = true;
          desc = "型定義";
        };
      }
      {
        mode = "n";
        key = "grn";
        action.__raw = "vim.lsp.buf.rename";
        options = {
          silent = true;
          desc = "名前変更";
        };
      }
      {
        mode = "n";
        key = "gra";
        action.__raw = "vim.lsp.buf.code_action";
        options = {
          silent = true;
          desc = "コードアクション";
        };
      }
      {
        mode = "n";
        key = "<leader>cf";
        action.__raw = "function() require('conform').format({ timeout_ms = 1000, lsp_format = 'fallback' }) end";
        options = {
          silent = true;
          desc = "フォーマット";
        };
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle left<CR>";
        options = {
          silent = true;
          desc = "ファイルツリー";
        };
      }
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>ToggleTerm direction=float<CR>";
        options = {
          silent = true;
          desc = "ターミナル";
        };
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options = {
          silent = true;
          desc = "診断一覧";
        };
      }
      {
        mode = "n";
        key = "<leader>gl";
        action = "<cmd>LazyGit<CR>";
        options = {
          silent = true;
          desc = "LazyGit";
        };
      }
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<CR>";
        options = {
          silent = true;
          desc = "差分";
        };
      }
      {
        mode = "n";
        key = "<leader>mp";
        action = "<cmd>Markview splitToggle<CR>";
        options = {
          silent = true;
          desc = "Markdown プレビュー";
        };
      }
      {
        mode = "n";
        key = "<leader>zz";
        action = "<cmd>ZenMode<CR>";
        options = {
          silent = true;
          desc = "Zen Mode";
        };
      }
      {
        mode = "n";
        key = "zR";
        action.__raw = "require('ufo').openAllFolds";
        options = {
          silent = true;
          desc = "全て展開";
        };
      }
      {
        mode = "n";
        key = "zM";
        action.__raw = "require('ufo').closeAllFolds";
        options = {
          silent = true;
          desc = "全て折りたたむ";
        };
      }
      {
        mode = "n";
        key = "s";
        action.__raw = "function() require('flash').jump() end";
        options = {
          silent = true;
          desc = "Flash ジャンプ";
        };
      }
      {
        mode = "n";
        key = "S";
        action.__raw = "function() require('flash').treesitter() end";
        options = {
          silent = true;
          desc = "Flash 選択";
        };
      }
      {
        mode = "n";
        key = "<leader>sr";
        action.__raw = "function() require('spectre').toggle() end";
        options = {
          silent = true;
          desc = "検索・置換";
        };
      }
      {
        mode = "n";
        key = "<leader>ff";
        action.__raw = "function() Snacks.picker.files() end";
        options = {
          silent = true;
          desc = "ファイルを探す";
        };
      }
      {
        mode = "n";
        key = "<leader>fg";
        action.__raw = "function() Snacks.picker.grep() end";
        options = {
          silent = true;
          desc = "全文検索";
        };
      }
      {
        mode = "n";
        key = "<leader>fb";
        action.__raw = "function() Snacks.picker.buffers() end";
        options = {
          silent = true;
          desc = "バッファを探す";
        };
      }
      {
        mode = "n";
        key = "<leader>fh";
        action.__raw = "function() Snacks.picker.help() end";
        options = {
          silent = true;
          desc = "ヘルプを探す";
        };
      }
      {
        mode = "n";
        key = "<leader>fs";
        action.__raw = "function() Snacks.picker.lsp_symbols() end";
        options = {
          silent = true;
          desc = "シンボルを探す";
        };
      }
    ];
  };
}
