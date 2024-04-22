return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<S-Tab>",   "<cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
    { "<Tab>",     "<cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
    { "<leader>x", "<cmd>bd<CR>",                  desc = "Close buffer" }
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      diagnostics_indicator = function(_, count, diagnostics_dict)
        local s = " "
        for e, n in pairs(diagnostics_dict) do
          local icon = e == "error" and " "
              or (e == "warning" and " " or "ℹ ")
          s = s .. icon .. n .. " "
        end
        return s
      end,
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" }
      },
      offsets = {
        {
          filetype = "neo-tree",
          text = "",
          highlight = "Directory",
          text_align = "left",
        }
      }
    }
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
  end
}
