local config = require "plugins.configs.lspconfig"

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

lspconfig.rust_analyzer.setup({
  on_attach = config.on_attach,
  capabilities = config.capabilities,
  filetypes = {"rust"},
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
})
