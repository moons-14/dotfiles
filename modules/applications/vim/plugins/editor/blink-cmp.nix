_: {
  programs.nixvim.plugins.blink-cmp = {
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
}
