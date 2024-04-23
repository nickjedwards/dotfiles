return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<C-n>", "<cmd>Neotree toggle<CR>", desc = "NeoTree" },
  },
  opts = {
    filesystem = {
      filtered_items = {
	      visible = false,
	      hide_dotfiles = false,
	      hide_gitignored = false,
        never_show = { ".git" },
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
    },
    window = {
      mappings = {
        ["<Tab>"] = {
          "toggle_preview",
          config = { use_float = false, use_image_nvim = false }
        },
      }
    },
    buffers = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)
  end
}
