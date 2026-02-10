-- Keep all commented except for 1
return {
	{
		"catppuccin/nvim",
		enabled = true,
		priority = 1000,
		config = function()
			local catppuccin = require("catppuccin")
			catppuccin.setup({
				flavour = "mocha",
				transparent_background = true,
				float = {
					transparent = true,
				},
			})

			vim.keymap.set("n", "<leader>ut", function()
				local catppuccin = require("catppuccin")
				-- Toggle the internal transparency option
				catppuccin.options.transparent_background = not catppuccin.options.transparent_background
				-- Recompile and reload the colorscheme to apply changes
				catppuccin.compile()
				vim.cmd.colorscheme(vim.g.colors_name)
			end, { desc = "Toggle Catppuccin transparency" })

			-- setup must be called before loading
			vim.cmd.colorscheme "catppuccin"
		end
	},
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("tokyonight").setup({
	-- 			transparent = true,
	-- 			styles = {
	-- 				sidebars = "transparent",
	-- 				floats = "transparent",
	-- 			},
	-- 		})
	-- 		vim.cmd("colorscheme tokyonight")
	-- 		vim.cmd("hi Normal guibg=none")
	-- 		vim.cmd("hi NormalFloat guibg=none")
	-- 	end,
	-- }
}
