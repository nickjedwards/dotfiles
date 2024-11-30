return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<S-H>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
    { "<S-L>", "<cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
    { "<leader>q", "<cmd>bd<CR>", desc = "Close buffer" }
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
          text = function ()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end,
          highlight = "Directory",
          text_align = "center",
          separator = false,
        }
      }
    }
  },
}
