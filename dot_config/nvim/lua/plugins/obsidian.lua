return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	event = {
		"BufReadPre **/*.md",
		"BufNewFile **/*.md",
	},
	cmd = {
		"Obsidian",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{ "<leader>od", "<cmd>Obsidian today<CR>", desc = "Obsidian: Open Today" },
		{ "<leader>on", "<cmd>Obsidian new<CR>",   desc = "Obsidian: New Note" },
	},

	opts = {
		legacy_commands = false,

		workspaces = {
			{ name = "dragonfruit",  path = "~/Obsidian/Dragonfruit/DragonfruitVault/" },
			{ name = "professional", path = "~/Obsidian/Professional/ObsidianProfessionalVault/" },
			{ name = "pengvim",      path = "~/Personal/Pengvim/PengvimVault/" },
		},

		templates = {
			subdir = "Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			tags = "",
		},

		daily_notes = {
			folder = "Daily",
			date_format = "%Y-%m-%d",
			template = "daily-template.md",
		},

		checkbox = {
			order = { " ", "x" },
		},

		note_id_func = function(title)
			if not title or title == "" then
				return tostring(os.time())
			end
			return title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
		end,
	},

	config = function(_, opts)
		local obsi = require("obsidian")
		obsi.setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(ev)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
				end

				map("n", "<leader>oc", function()
					obsi.util.toggle_checkbox()
				end, "Toggle Checkbox")

				map(
					"x",
					"<leader>oc",
					[[:<C-U>'<,'>g/^/lua require('obsidian').util.toggle_checkbox()<CR>:noh<CR>]],
					"Toggle Checkbox (Selection)"
				)

				-- Links
				map("n", "<leader>of", "<cmd>Obsidian follow_link<CR>", "Follow Link")
				map("n", "<leader>oF", "<cmd>Obsidian follow_link vsplit<CR>", "Follow Link (Split)")
				map("x", "<leader>ol", "<cmd>Obsidian link_new<CR>", "Link Note from Selection")
			end,
		})
	end,
}
