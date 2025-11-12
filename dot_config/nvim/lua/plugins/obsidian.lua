return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local obsi = require("obsidian")
		obsi.setup({
			frontmatter = {
				enabled = false,
			},
			note_id_func = function(title)
				-- If no title was given, fall back to a timestamp to avoid empty names.
				if not title or title == "" then
					return tostring(os.time())
				end
				-- Slugify: collapse whitespace -> '-', strip non [A-Za-z0-9-], lowercase.
				local slug = title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
				return slug
			end,
			legacy_commands = false,
			notes_subdir = "notes",
			workspaces = {
				{ name = "dragonfruit",  path = "~/Obsidian/Dragonfruit/DragonfruitVault/" },
				{ name = "professional", path = "~/Obsidian/Professional/ObsidianProfessionalVault/" },
				{ name = "pengvim",      path = "~/Personal/Pengvim/PengvimVault/" },
			},
		})
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(ev)
				-- Create new note
				vim.keymap.set(
					"n",
					"<leader>on",
					"<cmd>Obsidian new<CR>",
					{ buffer = ev.buf, desc = "Obsidian: New note" }
				)
				-- Normal: toggle the current line
				vim.keymap.set("n", "<leader>oc", function()
					obsi.util.toggle_checkbox()
				end, { buffer = ev.buf, desc = "Toggle checkbox" })
				vim.keymap.set(
					"x",
					"<leader>oc",
					[[:<C-U>'<,'>g/^/lua pcall(require('obsidian').util.toggle_checkbox)<CR>:noh<CR>]],
					{ buffer = ev.buf, silent = true, desc = "Toggle checkbox (selection)" }
				)
				-- Follow link under cursor (same window)
				vim.keymap.set(
					"n",
					"<leader>of",
					"<cmd>Obsidian follow_link<CR>",
					{ buffer = ev.buf, desc = "Obsidian: Follow link" }
				)

				-- Follow link in vertical split (handy when you want context side-by-side)
				vim.keymap.set(
					"n",
					"<leader>oF",
					"<cmd>Obsidian follow_link vsplit<CR>",
					{ buffer = ev.buf, desc = "Obsidian: Follow link (vsplit)" }
				)

				-- Create a link to an existing note from the current visual selection
				vim.keymap.set(
					"x",
					"<leader>ol",
					"<cmd>Obsidian link<CR>",
					{ buffer = ev.buf, desc = "Obsidian: Link selection to note" }
				)

				-- Create a *new* note and link the current visual selection to it
				vim.keymap.set(
					"x",
					"<leader>on",
					"<cmd>Obsidian link_new<CR>",
					{ buffer = ev.buf, desc = "Obsidian: New note from selection + link" }
				)
			end,
		})
	end,
}
