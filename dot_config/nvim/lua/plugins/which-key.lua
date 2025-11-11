return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function()
		local wk = require("which-key")
		wk.setup({
			preset = "helix",
		})
		wk.add({
			{
				"<leader>b",
				group = "Buffer",
				expand = function()
					return require("which-key.extras").expand.buf()
				end,
			},
			{
				"<leader>w",
				group = "Windows",
				proxy = "<c-w>",
				expand = function()
					return require("which-key.extras").expand.win()
				end,
			},
			{ "<leader>s",  group = "Search" },
			{ "<leader>S",  group = "Session" },
			{ "<leader>c",  group = "Code/LSP" },
			{ "<leader>f",  group = "Files/Find" },
			{ "<leader>fy", group = "Yank File Path/Name" },
			{ "<leader>g",  group = "Git" },
			{ "<leader>u",  group = "UI" },
			{ "<leader>x",  group = "Trouble" },
			{ "<leader>p",  group = "Preview" },
			{ "<leader>;",  group = "CompetiTest" },
			{ "<leader>m",  group = "Move" },
			{ "<leader>.",  group = "Scratch" },
			{ "g/",         group = "Split/Join" },
			{ "gs",         group = "Surround" },
		})
	end
}
