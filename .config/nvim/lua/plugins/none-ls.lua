return {
	"nvimtools/none-ls.nvim",
	keys = {
		{ "<leader>gf", vim.lsp.buf.format },
	},
	config = function()
		local null_ls = require("null-ls")
    local utils = require("null-ls.utils")

		null_ls.setup({
      root_dir = utils.root_pattern("composer.json", "package.json", ".git"),
      diagnostics_format = "#{m} (#{c}) [#{s}]",
			sources = {
        null_ls.builtins.completion.spell,
				-- lua
				null_ls.builtins.formatting.stylua,
				-- php
				null_ls.builtins.diagnostics.phpcs.with({
          prefer_local = "vendor/bin",
        }),
        null_ls.builtins.formatting.phpcbf.with({
          prefer_local = "vendor/bin",
        }),
				-- javascript
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.formatting.prettier,
			},
		})
	end,
}
