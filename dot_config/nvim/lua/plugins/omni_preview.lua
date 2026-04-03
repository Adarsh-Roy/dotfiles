return {
	"sylvanfranklin/omni-preview.nvim",
	lazy = true,
	dependencies = {
		-- Typst
		{ 'chomosuke/typst-preview.nvim', lazy = true },
		-- CSV
		{ 'hat0uma/csvview.nvim',         lazy = true, opts = { delimiter = ",", quote_char = "" } },
	},
	opts = {},
	keys = {
		{ "<leader>po", "<cmd>OmniPreview start<CR>", desc = "Preview Open" },
		{ "<leader>pc", "<cmd>OmniPreview stop<CR>",  desc = "Preview Close" },
	}
}
