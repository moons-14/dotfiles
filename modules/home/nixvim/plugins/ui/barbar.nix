{...}: {
  programs.nixvim.plugins.barbar = {
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

      sidebar_filetypes = {
        neo-tree = true;
      };
    };
  };
}
