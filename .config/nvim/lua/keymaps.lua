local map = vim.keymap.set

-- Move to window using <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Switch Window left", noremap = true, silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Switch Window down", noremap = true, silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Switch Window up", noremap = true, silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Switch Window right", noremap = true, silent = true })

-- Toggle line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle Line numbers" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle Relative number" })

-- Todo: Next buffer, prev. buffer and close buffer

-- Shift + Up/Down to move line up/down
map("n", "<S-Up>", "yyddkP", { desc = "Move line up", noremap = true, silent = true })
map("n", "<S-Down>", "yyddp", { desc = "Move line down", noremap = true, silent = true })

