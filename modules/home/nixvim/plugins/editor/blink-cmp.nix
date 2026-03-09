{...}: {
  programs.nixvim.plugins.blink-cmp = {
    enable = true;
    setupLspCapabilities = true;

    settings = {
      keymap = {
        preset = "enter";

        "<C-Space>" = ["show"];
        "<C-d>" = ["scroll_documentation_up"];
        "<C-e>" = ["hide"];
        "<C-f>" = ["scroll_documentation_down"];

        "<Tab>" = ["select_next" "fallback"];
        "<S-Tab>" = ["select_prev" "fallback"];
      };

      sources.default = [
        "lsp"
        "path"
        "buffer"
      ];
    };
  };
}
