return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = {
        "lua_ls",
        "tsserver",
        --"phpactor"
      }
    }
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    keys = {
      { "K", vim.lsp.buf.hover },
      { "gd", vim.lsp.buf.definition },
      { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" } }
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.phpactor.setup({
        capabilities = capabilities,
        default_config = {
          cmd = { "phpactor", "language-server" },
          filetypes = { "php" },
          root_dir = [[root_pattern("composer.json", ".git")]]
       },
      })
    end
  }
}