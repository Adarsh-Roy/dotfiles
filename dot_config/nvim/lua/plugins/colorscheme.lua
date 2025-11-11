-- Keep all commented except for 1
return {
	{
		"catppuccin/nvim",
		enabled = true,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				float = {
					transparent = true,
				},
			})

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
