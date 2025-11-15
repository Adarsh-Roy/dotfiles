return { {
	'stevearc/oil.nvim',
	lazy = true,
	---@module 'oil'
	keys = {
		{ "-", function() require("oil").toggle_float() end, desc = "Open Oil in Floating Window" }
	},
	-- Optional dependencies
	dependencies = { "echasnovski/mini.icons" },
	config = function()
		require("oil").setup({
			keymaps = {
				['<C-h>'] = false,
				['<C-s>'] = '<cmd>w<cr>',
				["<C-v>"] = { "actions.select", opts = { vertical = true } },
				["+"] = { "actions.close", mode = "n" }
			},
			float = {
				border = "rounded", -- "none" | "single" | "double" | "rounded" | "solid" | "shadow"
				padding = 2,    -- optional, looks nicer with a border
				max_width = 0,  -- 0 = auto
				max_height = 0,
				win_options = { winblend = 0 },
			},
		})
	end,
} }
