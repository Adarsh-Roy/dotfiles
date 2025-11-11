return {
	settings = {
		python = {
			analysis = {
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
				extraPaths = { "./src/app" }
			},
		},
	},
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git")(fname)
	end,
}
