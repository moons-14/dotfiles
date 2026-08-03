{ lib, ... }@args:
lib.mkMerge [
  (import ./barbar.nix args)
  (import ./blankline.nix args)
  (import ./colorizer.nix args)
  (import ./dropbar.nix args)
  (import ./lightbulb.nix args)
  (import ./lualine.nix args)
  (import ./markview.nix args)
  (import ./neo-tree.nix args)
  (import ./scrollbar.nix args)
  (import ./toggleterm.nix args)
  (import ./treesitter.nix args)
  (import ./ufo.nix args)
  (import ./web-devicons.nix args)
  (import ./which-key.nix args)
  (import ./zen-mode.nix args)
]
