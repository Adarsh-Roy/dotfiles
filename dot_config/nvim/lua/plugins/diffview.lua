return {
	"sindrets/diffview.nvim",
	lazy = true,
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	opts = {},
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>",  desc = "Diffview: Open" },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
	},
}
