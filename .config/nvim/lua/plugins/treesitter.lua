return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    auto_install = false,
    ensure_installed = {
      "dockerfile",
      "ini",
      "javascript",
      "json",
      "lua",
      "markdown",
      "php",
      "phpdoc",
      "terraform",
      "tsx",
      "typescript",
      "yaml",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "php" },
    },
    indent = {
      enable = true,
      disable = { "yaml" },
    },
    sync_install = false,
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
