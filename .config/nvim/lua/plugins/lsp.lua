return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "tsserver",
        --"phpactor"
      }
    }
  },
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "K", vim.lsp.buf.hover },
      { "gd", vim.lsp.buf.definition },
      { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" } }
    },
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({})
      --lspconfig.phpactor.setup({})
    end
  }
}
