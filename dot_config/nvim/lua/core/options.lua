vim.o.relativenumber = true
vim.o.splitright = true
vim.o.number = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.clipboard = "unnamedplus"
vim.o.colorcolumn = "80"
vim.o.shiftwidth = 4
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.confirm = true

-- Fold
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true


-- Icons per severity
local diag_icons = {
	[vim.diagnostic.severity.ERROR] = "",
	[vim.diagnostic.severity.WARN]  = "",
	[vim.diagnostic.severity.INFO]  = "",
	[vim.diagnostic.severity.HINT]  = "",
}

vim.diagnostic.config({
	signs = {
		text = diag_icons,
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
			[vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
			[vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
		},
	},
	virtual_text = { prefix = "●", spacing = 2 },
	underline = true,
	update_in_insert = false,
})

-- Persistent Undo
vim.opt.undofile = true
