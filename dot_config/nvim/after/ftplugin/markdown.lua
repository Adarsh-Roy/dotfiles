-- Auto-continue bullet points and numbered lists
-- 'r': Insert the bullet/number when pressing Enter in Insert mode
-- 'o': Insert the bullet/number when pressing 'o' or 'O' in Normal mode
vim.opt_local.formatoptions:append("ro")

-- Ensure the file type knows what "comments" (bullets) look like
-- Most Neovim setups have this by default, but this enforces it for *, -, +, and >
vim.opt_local.comments = "b:*,b:-,b:+,n:>"


-- Disable Color Columns (40/80) for Markdown only
vim.opt_local.colorcolumn = ""

-- Map Shift+Enter to: New line -> delete auto-bullet -> insert 2 spaces for alignment
vim.keymap.set('i', '<S-CR>', '<CR><C-w>  ', { buffer = true, remap = false })

-- Only run if presenterm is installed
if vim.fn.executable("presenterm") == 1 then
	vim.keymap.set("i", "<C-p>", function()
		local commands = {
			{ name = "pause",              needs_value = false },
			{ name = "font_size",          needs_value = true },
			{ name = "end_slide",          needs_value = false },
			{ name = "jump_to_middle",     needs_value = false },
			{ name = "new_lines",          needs_value = true },
			{ name = "incremental_lists",  needs_value = true },
			{ name = "list_item_newlines", needs_value = true },
			{ name = "include",            needs_value = true },
			{ name = "no_footer",          needs_value = false },
			{ name = "skip_slide",         needs_value = false },
			{ name = "alignment",          needs_value = false },
			{ name = "column_layout",      needs_value = true },
			{ name = "column",             needs_value = false },
			{ name = "reset_layout",       needs_value = false },
		}

		local snacks_ok, snacks = pcall(require, "snacks")

		if snacks_ok then
			local items = {}
			for i, c in ipairs(commands) do
				items[i] = { idx = i, text = c.name, needs_value = c.needs_value }
			end

			snacks.picker.pick({
				source = "presenterm", -- Give it a name so history works
				title = "Presenterm Commands",
				items = items,
				format = "text",

				layout = {
					preview = false,
					preset = "vscode",
				},

				confirm = function(picker, item)
					picker:close()
					if item then
						vim.schedule(function()
							if item.needs_value then
								-- Commands that need a value: leave cursor after colon
								local text = "<!-- " .. item.text .. ":  -->"
								vim.api.nvim_put({ text }, "c", true, true)
								-- Move cursor back 4 characters (before " -->")
								vim.cmd("norm 4h")
								vim.cmd("startinsert")
							else
								-- Commands that don't need a value: go to next line
								local text = "<!-- " .. item.text .. " -->"
								vim.api.nvim_put({ text }, "c", true, true)
								vim.cmd("norm o")
								vim.cmd("startinsert")
							end
						end)
					end
				end,
			})
		else
			-- Fallback if Snacks isn't loaded
			local command_names = vim.tbl_map(function(c) return c.name end, commands)
			vim.ui.select(command_names, { prompt = "Presenterm Commands" }, function(choice)
				if choice then
					vim.schedule(function()
						-- Find the command to check if it needs a value
						local cmd = vim.tbl_filter(function(c) return c.name == choice end, commands)[1]
						if cmd and cmd.needs_value then
							local text = "<!-- " .. choice .. ":  -->"
							vim.api.nvim_put({ text }, "c", true, true)
							vim.cmd("norm 4h")
							vim.cmd("startinsert")
						else
							local text = "<!-- " .. choice .. " -->"
							vim.api.nvim_put({ text }, "c", true, true)
							vim.cmd("norm o")
							vim.cmd("startinsert")
						end
					end)
				end
			end)
		end
	end, { buffer = true, desc = "[P]resenterm [C]ommand" })
end

-- autosave for markdown files in Obsidian
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
	pattern = "*.md",
	callback = function()
		-- 1. Get the absolute path of the current file
		local filepath = vim.fn.expand("%:p")

		-- 2. Set your target directory (You can now use '~')
		-- Make sure to leave off the trailing slash
		local target_dir = vim.fn.expand("/Users/adarsh/Obsidian")

		-- 3. Check if the filepath strictly STARTS with the target_dir
		if vim.startswith(filepath, target_dir) and vim.bo.modified then
			vim.cmd("silent! write")
		end
	end,
})
