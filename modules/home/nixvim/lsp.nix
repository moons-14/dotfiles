{...}: {
  programs.nixvim = {
    plugins.lsp = {
      enable = true;

      servers = {
        # TypeScript / JavaScript
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

        # Biome for lint / format
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

        # Frontend / config languages
        tailwindcss.enable = true;
        cssls.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        lua_ls.enable = true;
        nixd.enable = true;

        # Other languages
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

    # Diagnostic UI
    diagnostic.settings = {
      virtual_text = true;
      float = {
        border = "rounded";
        source = true;
      };
    };
  };
}
