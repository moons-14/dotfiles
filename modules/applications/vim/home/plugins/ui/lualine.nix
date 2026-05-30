_: {
  programs.nixvim.plugins.lualine = {
    enable = true;
    settings.sections.lualine_x = [
      {
        __raw = ''
          function()
            local ok, conform = pcall(require, "conform")
            if not ok then return "" end
            local formatters = conform.list_formatters(0)
            for _, f in ipairs(formatters) do
              if f.available then
                return "󰛖 " .. f.name
              end
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
}
