return {
	"nvimtools/none-ls.nvim",
	keys = {
		{ "<leader>gf", vim.lsp.buf.format },
	},
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				-- lua
				null_ls.builtins.formatting.stylua,
				-- php
				null_ls.builtins.diagnostics.phpactor,
				null_ls.builtins.formatting.phpactor,
				-- javascript
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.formatting.prettier,
			},
		})
	end,
}
