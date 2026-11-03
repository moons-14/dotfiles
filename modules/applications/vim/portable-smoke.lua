assert(vim.v.errmsg == "", vim.v.errmsg)
assert(vim.g.mapleader == " ", "leader key was not loaded")
assert(vim.o.number and vim.o.relativenumber, "editor options were not loaded")
assert(vim.fn.maparg("<Space>ff", "n") ~= "", "file picker keymap is missing")

for _, name in ipairs({ "conform", "blink.cmp", "neo-tree", "snacks", "flash", "ufo" }) do
  local ok, err = pcall(require, name)
  assert(ok, name .. ": " .. tostring(err))
end

for _, name in ipairs({
  "git", "rg", "fd", "node", "zellij", "vtsls", "prettier", "biome",
  "stylua", "shfmt", "nix", "nixfmt", "nixd", "lazygit", "rust-analyzer", "cargo", "rustc",
}) do
  assert(vim.fn.executable(name) == 1, "missing bundled tool: " .. name)
end

assert(vim.lsp.config.vtsls ~= nil, "TypeScript LSP configuration is missing")
assert((vim.g.colors_name or ""):match("^catppuccin"), "colorscheme was not loaded")
print("Portable Neovim configuration and tools loaded successfully")
vim.cmd("qa!")
