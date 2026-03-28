{...}: {
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
        };
        filtered_items = {
          visible = true;
          hide_dotfiles = false;
          hide_gitignored = true;
          hide_ignored = false;
          hide_hidden = false;

          hide_by_name = [];
          hide_by_pattern = [];

          always_show = [];
          always_show_by_pattern = [];

          never_show = [
            ".DS_Store"
            "thumbs.db"
          ];
          never_show_by_pattern = [];
        };
      };
    };
  };
}
