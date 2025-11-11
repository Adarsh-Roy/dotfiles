-- core/lsp.lua
local Methods = vim.lsp.protocol.Methods

local function on_attach(client, buf)
	local function map_if(method, lhs, rhs, desc, opts)
		if client and client.supports_method and client:supports_method(method) then
			vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", { buffer = buf, desc = "LSP: " .. desc }, opts or {}))
		end
	end

	map_if(Methods.textDocument_definition, "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
	map_if(Methods.textDocument_declaration, "gD", function() Snacks.picker.lsp_declarations() end, "Goto Declaration")
	map_if(Methods.textDocument_references, "gr", function() Snacks.picker.lsp_references() end, "References",
		{ nowait = true })
	map_if(Methods.textDocument_implementation, "gI", function() Snacks.picker.lsp_implementations() end,
		"Goto Implementation")
	map_if(Methods.textDocument_typeDefinition, "gy", function() Snacks.picker.lsp_type_definitions() end,
		"Goto T[y]pe Definition")
	map_if(Methods.textDocument_documentSymbol, "<leader>ss", function()
		Snacks.picker.lsp_symbols()
	end, "LSP Symbols")
	map_if(Methods.workspace_symbol, "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,
		"LSP Workspace Symbols")

	if client:supports_method(Methods.textDocument_hover) then
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "LSP: Hover" })
	end
	if client:supports_method(Methods.textDocument_rename) then
		vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = buf, desc = "LSP: Rename symbol" })
	end
	if client:supports_method(Methods.textDocument_codeAction) then
		vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { buffer = buf, desc = "LSP: Code action" })
	end
end

-- Attach hook for all servers
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		on_attach(client, ev.buf)
	end,
})
