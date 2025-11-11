local function visual_metrics()
	if not vim.fn.mode(1):find("[vV\022]") then
		return ""
	end
	local s, e  = vim.fn.getpos("v"), vim.fn.getpos(".")
	local lines = math.abs(e[2] - s[2]) + 1

	local wc    = vim.fn.wordcount()
	local words = vim.fn.get(wc, "visual_words", 0)
	local chars = vim.fn.get(wc, "visual_chars", 0)

	return string.format("%dL %dW %dC", lines, words, chars)
end
local function macro_status()
	local rec = vim.fn.reg_recording()
	if rec ~= "" then
		return ("REC @%s"):format(rec) -- e.g. "REC @q"
	end
	-- Optional: also show when a macro is playing back
	local exec = vim.fn.reg_executing()
	if exec ~= "" then
		return ("PLAY @%s"):format(exec)
	end
	return ""
end
return {
	'echasnovski/mini.nvim',
	version = '*',
	config = function()
		vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
			callback = function()
				-- schedule avoids “not allowed here” in some edge cases
				vim.schedule(function() vim.cmd("redrawstatus") end)
			end,
		})
		require("mini.splitjoin").setup({
			mappings = {
				toggle = 'g//',
				split = 'g/s',
				join = 'g/j'
			}
		})
		local hipatterns = require('mini.hipatterns')
		hipatterns.setup({
			highlighters = {
				-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
				fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
				hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
				todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
				note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		})
		local icons = require("mini.icons")
		icons.setup()
		icons.mock_nvim_web_devicons()
		local session = require("mini.sessions")
		session.setup({
			directory = vim.fn.stdpath("data") .. "/global_sessions",
			autowrite = false,
		})

		vim.keymap.set("n", "<leader>Sl", function()
			local local_file = (session.config.file ~= "" and session.config.file) or "Session.vim"
			-- `force = true` to overwrite any existing file without a prompt
			session.write(local_file, { force = true })
		end, { desc = "Save Session (local)" })

		vim.keymap.set("n", "<leader>Sa", function()
			vim.ui.input({ prompt = "Session name: " }, function(name)
				if name and #name > 0 then
					session.write(name) -- writes to `directory`
				end
			end)
		end, { desc = "Save Session As…" })

		require("mini.tabline").setup()
		require("mini.ai").setup({
			n_lines = 200
		})
		require("mini.move").setup({
			mappings = {
				left       = '<C-Left>',
				right      = '<C-Right>',
				down       = '<C-Down>',
				up         = '<C-Up>',

				line_left  = '<C-Left>',
				line_right = '<C-Right>',
				line_down  = '<C-Down>',
				line_up    = '<C-Up>',
			},
		})
		require("mini.pairs").setup()
		require("mini.operators").setup({
			exchange = {
				prefix = 'ge'
			},
			replace = {
				prefix = '<leader>r'
			},
			sort = {
				prefix = 'gS'
			}
		})
		require("mini.surround").setup({
			mappings = {
				add = 'gsa',
				delete = 'gsd',
				replace = 'gsr',
				find = 'gsf',
				find_left = 'gsF',
				highlight = 'gsh',
				update_n_lines = 'gsn',
				suffix_last = 'l',
				suff_next = 'n',
			}
		})
		require("mini.align").setup()
		require("mini.statusline").setup({
			use_icons = true,
			content = {
				active = function()
					local mode = MiniStatusline.section_mode({ trunc_width = math.huge })

					-- Build git segment from gitsigns buffer vars (no shell calls)
					local function git_segment()
						local g = vim.b.gitsigns_status_dict
						local head = (g and g.head) or vim.b.gitsigns_head
						if not head or head == "" then
							return "" -- not a repo: return empty so caller can skip the block
						end

						-- No trailing spaces: join parts with single spaces and never append a space
						local parts = { "    " .. head }
						if g then
							local diffs   = {}
							local added   = tonumber(g.added) or 0
							local changed = tonumber(g.changed) or 0
							local removed = tonumber(g.removed) or 0
							if added > 0 then diffs[#diffs + 1] = "+" .. added end
							if changed > 0 then diffs[#diffs + 1] = "~" .. changed end
							if removed > 0 then diffs[#diffs + 1] = "-" .. removed end
							if #diffs > 0 then parts[#parts + 1] = table.concat(diffs, " ") end
						end
						return table.concat(parts, " ")
					end

					local filename = MiniStatusline.section_filename({ trunc_width = 200 })
					local metrics  = visual_metrics()
					local macro    = macro_status()
					local git      = git_segment()

					local groups   = {
						{ hl = "MiniStatuslineModeNormal", strings = { mode } },
					}

					-- Only add the git block when we have content (mirrors your metrics gating)
					if git ~= "" then
						table.insert(groups, { hl = "MiniStatuslineDevinfo", strings = { git } })
					end

					table.insert(groups, { strings = { "%<" } })
					table.insert(groups, { hl = "MiniStatuslineFilename", strings = { filename } })

					-- right side
					table.insert(groups, { strings = { "%#StatusLine#" } })
					table.insert(groups, { strings = { "%=" } })

					if metrics ~= "" then
						table.insert(groups, { strings = { "%#MiniStatuslineFileinfo# " .. metrics .. " %#StatusLine#" } })
					end
					if macro ~= "" then
						table.insert(groups, { hl = "MiniStatuslineDevinfo", strings = { " " .. macro } })
					end

					return MiniStatusline.combine_groups(groups)
				end,

				inactive = function()
					local name = vim.api.nvim_buf_get_name(0)
					local tail = (name == "" and "[No Name]") or vim.fn.fnamemodify(name, ":t")
					return MiniStatusline.combine_groups({
						{ hl = "MiniStatuslineInactive", strings = { tail } },
					})
				end,
			},
		})
	end
}
