{...}: {
  programs.nixvim = {
    plugins.project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        detection_methods = ["pattern" "lsp"];
        patterns = [
          ".git"
          "package.json"
          "Cargo.toml"
          "flake.nix"
          "pyproject.toml"
        ];
      };
    };
  };
}
