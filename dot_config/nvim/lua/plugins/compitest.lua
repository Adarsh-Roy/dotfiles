return {
	"xeluxee/competitest.nvim",
	lazy = true,
	dependencies = { "MunifTanjim/nui.nvim" },
	config = function()
		require("competitest").setup({
			testcases_use_single_file = true,
			open_received_problems = true,
			open_received_contests = true,
		})
	end,
	keys = {
		{ "<leader>;",   desc = "+CompetiTest" },
		{ "<leader>;r",  "<cmd>CompetiTest run<CR>",             desc = "CompetiTest Run" },
		{ "<leader>;a",  desc = "+CompetiTest Add" },
		{ "<leader>;ap", "<cmd>CompetiTest receive problem<CR>", desc = "CompetiTest Add Problem" },
		{ "<leader>;ac", "<cmd>CompetiTest receive contest<CR>", desc = "CompetiTest Add Contest" },
		{ "<leader>;at", "<cmd>CompetiTest add_testcase<CR>",    desc = "CompetiTest Add Test Case" },
		{ "<leader>;e",  desc = "+CompetiTest Edit" },
		{ "<leader>;et", "<cmd>CompetiTest edit_testcase<CR>",   desc = "CompetiTest Edit Test Case" },
		{ "<leader>;d",  desc = "+CompetiTest Delete" },
		{ "<leader>;dt", "<cmd>CompetiTest delete_testcase<CR>", desc = "CompetiTest Delete Test Case" },
	},
}
