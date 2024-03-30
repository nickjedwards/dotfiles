local map = vim.keymap.set

-- Move to window using <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Switch Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch Window right" })

-- Toggle line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle Line numbers" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle Relative number" })

-- Shift + Up/Down to move line up/down
map("n", "<S-Up>", "yyddkP", { desc = "Move line up" })
map("n", "<S-Down>", "yyddp", { desc = "Move line down" })
