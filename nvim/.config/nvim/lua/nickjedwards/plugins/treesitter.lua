return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    auto_install = true,
    ensure_installed = {
      "dockerfile",
      "ini",
      "javascript",
      "json",
      "lua",
      "markdown",
      "php",
      "phpdoc",
      "rust",
      "terraform",
      "tsx",
      "typescript",
      "yaml",
    },
    highlight = { enable = true },
    indent = {
      enable = true,
      disable = { "yaml" },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)

    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.blade = {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "blade",
    }
    vim.filetype.add({
      pattern = {
        [".*%.blade%.php"] = "blade",
      },
    })
  end,
}
