local config = require "plugins.configs.lspconfig"

local lspconfig = require "lspconfig"

lspconfig.rust_analyzer.setup({
  on_attach = config.on_attach,
  capabilities = config.capabilities,
  filetypes = {"rust"},
  root_dir = lspconfig.util.root_pattern("Cargo.toml"),
})
