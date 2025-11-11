vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Buffer
vim.keymap.set("n", "<leader>by", "mq<cmd>%y<cr><cmd>delm q<cr>", { desc = "Yank Buffer" })
vim.keymap.set("n", "<leader>bv", "ggVG", { desc = "Select Buffer" })
vim.keymap.set("n", "<leader>bsr", ":%s///gc<left><left><left><left>", { desc = "Buffer Search Replace" })
vim.keymap.set("n", "<leader>bnn", "<cmd>enew<cr>", { desc = "New Buffer" })
vim.keymap.set("n", "<leader>bnv", "<cmd>vnew<cr>", { desc = "New Buffer (Veritcal)" })
vim.keymap.set("n", "H", "<cmd>bprev<cr>", { desc = "Previous Buffer" })
vim.keymap.set("n", "L", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Yank file path/name
local function buf_abs()
	return vim.api.nvim_buf_get_name(0)
end
vim.keymap.set("n", "<leader>fyr", function()
	local rel = vim.fn.fnamemodify(buf_abs(), ":.")
	vim.fn.setreg("+", rel)
	vim.notify("Yanked (relative): " .. rel)
end, { desc = "Yank relative file path" })
vim.keymap.set("n", "<leader>fya", function()
	local abs = vim.fn.fnamemodify(buf_abs(), ":p")
	vim.fn.setreg("+", abs)
	vim.notify("Yanked (absolute): " .. abs)
end, { desc = "Yank absolute file path" })
vim.keymap.set("n", "<leader>fyd", function()
	local dir = vim.fn.fnamemodify(buf_abs(), ":p:h")
	vim.fn.setreg("+", dir)
	vim.notify("Yanked (dir): " .. dir)
end, { desc = "Yank directory path" })
vim.keymap.set("n", "<leader>fyf", function()
	local name = vim.fn.fnamemodify(buf_abs(), ":t")
	vim.fn.setreg("+", name)
	vim.notify("Yanked (filename): " .. name)
end, { desc = "Yank filename only" })

-- reselect after increment or decrement in visual mode
vim.keymap.set("x", "<C-a>", "<C-a>gv")
vim.keymap.set("x", "<C-x>", "<C-x>gv")

-- Block insert and append
vim.keymap.set("x", "I", function()
	return vim.fn.mode() == "V" and "^<C-v>I" or "I"
end, { expr = true })
vim.keymap.set("x", "A", function()
	return vim.fn.mode() == "V" and "$<C-v>A" or "A"
end, { expr = true })

-- Diagnostics
vim.keymap.set("n", "<leader>xf", function()
	vim.diagnostic.open_float(nil, {
		scope = "line",
		border = "rounded",
		source = "if_many",
		focusable = true,
	})
end, { desc = "Trouble Float" })

vim.keymap.set("n", "<leader>xy", function()
	local line_num = vim.fn.line(".")
	local line_content = vim.fn.getline(".")
	local diagnostics = vim.diagnostic.get(0, { lnum = line_num - 1 })
	if not diagnostics or #diagnostics == 0 then
		vim.notify("No diagnostics on the current line.", vim.log.levels.WARN)
		return
	end
	local messages = {}
	for i, d in ipairs(diagnostics) do
		table.insert(messages, i .. ". " .. d.message)
	end
	local formatted_diagnostics = table.concat(messages, "\n")
	local full_message = string.format("Line Content: %s\nDiagnostic:\n%s", line_content, formatted_diagnostics)
	vim.fn.setreg("+", full_message)
	vim.notify("Copied diagnostic to clipboard:\n" .. full_message)
end, { desc = "Copy Diagnostic" })

-- Navigation
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Insert mode navigation for slight movements
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")

-- Move (line/selection) to {dest}, keep cursor/view here,
-- and record a jumplist entry so <C-o> jumps to the moved text.
local function move_and_record_jump(dest, is_visual)
	local view = vim.fn.winsaveview()
	local ok, err
	if is_visual then
		-- 1) Capture the selected *line* range while still in Visual
		local vpos = vim.fn.getpos("v")
		local cpos = vim.fn.getpos(".")
		local s = math.min(vpos[2], cpos[2])
		local e = math.max(vpos[2], cpos[2])
		-- 2) Exit Visual with real input so the highlight is definitely cleared
		local ESC = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		vim.api.nvim_feedkeys(ESC, "nx", false)
		vim.cmd("redraw") -- ensure the UI refreshes and drops the selection highlight
		-- 3) Move that numeric range
		ok, err = pcall(vim.cmd, ("%d,%dmove %s"):format(s, e, dest))
	else
		ok, err = pcall(vim.cmd, ("move %s"):format(dest))
	end
	if not ok then
		vim.notify("move error: " .. err, vim.log.levels.ERROR)
		return
	end
	-- 4) Create jumplist entries: jump to dest (`[), then back to original line
	local prev_lazy = vim.go.lazyredraw
	vim.go.lazyredraw = true
	pcall(vim.cmd, "normal! `[") -- start of changed text (destination)
	pcall(vim.cmd, ("normal! %dG"):format(view.lnum)) -- back to original line (records a jump)
	vim.go.lazyredraw = prev_lazy
	-- 5) Restore exact column/scroll (doesn't touch the jumplist)
	vim.fn.winrestview(view)
end
-- <leader>mm → prompt; <leader>mt → top (0); <leader>mb → bottom ($)
vim.keymap.set("n", "<leader>mm", function()
	local dest = vim.fn.input("Move line to (0,$,42,'a,/pat/): ")
	if dest ~= "" then
		move_and_record_jump(dest, false)
	end
end, { silent = true, desc = "Move line" })
vim.keymap.set("x", "<leader>mm", function()
	local dest = vim.fn.input("Move selected line to (0,$,42,'a,/pat/): ")
	if dest ~= "" then
		move_and_record_jump(dest, true)
	end
end, { silent = true, desc = "Move selected line" })
vim.keymap.set("n", "<leader>mt", function()
	move_and_record_jump("0", false)
end, { silent = true, desc = "Move line to TOP" })
vim.keymap.set("n", "<leader>mb", function()
	move_and_record_jump("$", false)
end, { silent = true, desc = "Move line to BOTTOM" })
vim.keymap.set("x", "<leader>mt", function()
	move_and_record_jump("0", true)
end, { silent = true, desc = "Move selected line to TOP" })
vim.keymap.set("x", "<leader>mb", function()
	move_and_record_jump("$", true)
end, { silent = true, desc = "Move selected line to BOTTOM" })

-- General
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>")

-- Exit terminal mode with Esc twice
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Quit guard for terminal buffers (handles qa/qall/wqa with/without bang)
if not vim.g._quit_guard_loaded then
	vim.g._quit_guard_loaded = true
	local function any_terminals_open()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
				return true
			end
		end
		return false
	end
	local function quit_all_guarded(force)
		-- force == true when user typed :qa! / :qall!
		if not force and any_terminals_open() then
			local choice = vim.fn.confirm("Terminal buffers are open. Quit all and kill them?", "&Quit all\n&Cancel", 2)
			if choice ~= 1 then
				vim.notify("Cancelled quit: terminal buffers are open.", vim.log.levels.INFO)
				return
			end
		end
		vim.cmd(force and "qa!" or "qa")
	end
	local function write_quit_all_guarded(force)
		if not force and any_terminals_open() then
			local choice =
				vim.fn.confirm("Terminal buffers are open. Write all and quit?", "&Write & Quit all\n&Cancel", 2)
			if choice ~= 1 then
				vim.notify("Cancelled write-quit: terminal buffers are open.", vim.log.levels.INFO)
				return
			end
		end
		vim.cmd(force and "wqa!" or "wqa")
	end
	-- Define commands that accept a bang
	vim.api.nvim_create_user_command("QallCheckTerm", function(opts)
		quit_all_guarded(opts.bang)
	end, { bang = true })
	vim.api.nvim_create_user_command("WqallCheckTerm", function(opts)
		write_quit_all_guarded(opts.bang)
	end, { bang = true })
	-- Abbreviations: case-insensitive, allow optional spaces, preserve trailing "!"
	-- Also clear any older conflicting abbrevs first
	vim.cmd([[
    silent! cunabbrev qa
    silent! cunabbrev qall
    silent! cunabbrev wqa
    " qa / qa! → QallCheckTerm / QallCheckTerm!
    cnoreabbrev <expr> qa
          \ getcmdtype() ==# ':' && getcmdline() =~? '^\s*qa\%(\s*!\)\=\s*$'
          \ ? 'QallCheckTerm' . (getcmdline() =~? '!\s*$' ? '!' : '')
          \ : 'qa'
    " qall / qall! → QallCheckTerm / QallCheckTerm!
    cnoreabbrev <expr> qall
          \ getcmdtype() ==# ':' && getcmdline() =~? '^\s*qall\%(\s*!\)\=\s*$'
          \ ? 'QallCheckTerm' . (getcmdline() =~? '!\s*$' ? '!' : '')
          \ : 'qall'
    " wqa / wqa! → WqallCheckTerm / WqallCheckTerm!
    cnoreabbrev <expr> wqa
          \ getcmdtype() ==# ':' && getcmdline() =~? '^\s*wqa\%(\s*!\)\=\s*$'
          \ ? 'WqallCheckTerm' . (getcmdline() =~? '!\s*$' ? '!' : '')
          \ : 'wqa'
  ]])
	vim.keymap.set("n", "<leader>w ", function()
		quit_all_guarded(false)
	end, { desc = "Quit all (guarded)" })
end
