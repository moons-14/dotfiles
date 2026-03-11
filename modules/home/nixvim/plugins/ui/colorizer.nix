{...}: {
  programs.nixvim.plugins.colorizer = {
    enable = true;

    settings = {
      filetypes = ["*" "!markdown"];
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
}
