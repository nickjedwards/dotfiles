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
        --"phpactor",
        "rust_analyzer",
        "tsserver",
      }
    }
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    keys = {
      { "K",          vim.lsp.buf.hover },
      { "<leader>gd", vim.lsp.buf.definition },
      { "<leader>gr", vim.lsp.buf.references },
      { "<leader>ca", vim.lsp.buf.code_action }
    },
    config = function()
      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({
        handlers,
        capabilities,
      })
      
      lspconfig.phpactor.setup({
        handlers,
        capabilities,
        default_config = {
          cmd = { "phpactor", "language-server" },
          filetypes = { "php" },
          root_dir = [[root_pattern("composer.json", ".git")]]
        },
        init_options = {
          ["language_server_phpstan.enabled"] = false,
          ["language_server_psalm.enabled"] = false,
        },
      })

      lspconfig.rust_analyzer.setup({
        handlers,
        capabilities,
      })

      lspconfig.tsserver.setup({
        handlers,
        capabilities,
      })
    end
  }
}
