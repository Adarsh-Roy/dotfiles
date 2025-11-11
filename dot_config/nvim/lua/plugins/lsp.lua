return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "snacks.nvim",        words = { "Snacks" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
	},
	{
		"williamboman/mason.nvim",
		opts = {}, -- default path setup ; prepends mason/bin to $PATH
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "rust_analyzer", "lua_ls", "pyright", "tinymist", "ts_ls", "gopls" },
			automatic_enable = true,
		},
	},
}
