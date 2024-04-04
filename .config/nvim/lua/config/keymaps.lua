local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Map leader key to space
map("n", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Move to window using <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Switch Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch Window right" })

-- Clear matches
map("n", "<C-l>", "<cmd>noh<CR>", opts)

-- Reselect visual block after indent/outdent
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- YY/XX to Copy/Cut to the system clipboard
vim.cmd([[
noremap YY "+y<CR>
noremap XX "+x<CR>
]])

-- Toggle line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle Line numbers" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle Relative number" })

-- Shift + Up/Down to move line up/down
map("n", "<S-Up>", "yyddkP", { desc = "Move line up" })
map("n", "<S-Down>", "yyddp", { desc = "Move line down" })
