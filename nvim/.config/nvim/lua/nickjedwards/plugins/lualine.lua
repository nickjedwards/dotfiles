return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "catppuccin",
      sections = {
        lua_a = {
          file = 1
        }
      }
    }
  }
}
