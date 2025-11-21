return {
	'mfussenegger/nvim-dap',
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		local dap    = require("dap")
		local dapui  = require("dapui")
		local dap_py = require("dap-python")

		-- helper: pick the current env's python
		local function get_python()
			local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
			if venv and #venv > 0 then
				return venv .. "/bin/python"
			end
			-- fallback: whatever python3/python is on PATH
			return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
					or vim.fn.exepath("python")
		end

		local python_path = get_python()

		-- adapter: "python -m debugpy.adapter"
		dap.adapters.python = {
			type = "executable",
			command = python_path,
			args = { "-m", "debugpy.adapter" },
		}

		dapui.setup()
		dap_py.setup(python_path) -- use same interpreter for dap-python
		require("nvim-dap-virtual-text").setup({})

		-- small helper to read *_LOCAL env vars
		local function getenv(name)
			local v = os.getenv(name)
			if v == nil or v == "" then return nil end
			return v
		end

		-- global Python configurations
		dap.configurations.python = {
			-- 1) generic "debug current file" (for any repo)
			{
				type = "python",
				request = "launch",
				name = "Debug current file",
				program = "${file}",
				cwd = "${workspaceFolder}",
				justMyCode = true,
			},

			-- 2) df-services Flask server (your rdfsl alias)
			{
				type = "python",
				request = "launch",
				name = "df-services: Flask local",
				module = "flask",
				env = {
					POSTGRES_URL                = getenv("POSTGRES_URL_LOCAL"),
					POSTGRES_USERNAME           = getenv("POSTGRES_USERNAME_LOCAL"),
					POSTGRES_PASSWORD           = getenv("POSTGRES_PASSWORD_LOCAL"),
					ANALYTICS_POSTGRES_URL      = getenv("ANALYTICS_POSTGRES_URL_LOCAL"),
					ANALYTICS_POSTGRES_USERNAME = getenv("ANALYTICS_POSTGRES_USERNAME_LOCAL"),
					ANALYTICS_POSTGRES_PASSWORD = getenv("ANALYTICS_POSTGRES_PASSWORD_LOCAL"),
					FLASK_ENV                   = "development",
				},
				args = { "run", "--no-debugger", "--no-reload" },
				justMyCode = true,
				jinja = true,
			},
		}

		-- Auto open/close DAP UI
		dap.listeners.before.attach.dapui_config = function() dapui.open() end
		dap.listeners.before.launch.dapui_config = function() dapui.open() end
		dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

		-- Keymaps
		vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<Leader>dc", dap.continue, {})

		-- Optional: direct key for df-services flask
		vim.keymap.set("n", "<Leader>dF", function()
			for _, cfg in ipairs(dap.configurations.python or {}) do
				if cfg.name == "df-services: Flask local" then
					dap.run(cfg)
					return
				end
			end
			print("df-services Flask config not found")
		end, { desc = "Debug df-services Flask" })
	end,
}
