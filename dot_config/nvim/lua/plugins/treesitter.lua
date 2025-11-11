return {
	{ -- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		main = 'nvim-treesitter.configs', -- Sets main module to use for opts
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		opts = {
			ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python', 'latex', 'bibtex' },
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
				--  If you are experiencing weird indenting issues, add the language to
				--  the list of additional_vim_regex_highlighting and disabled languages for indent.
				additional_vim_regex_highlighting = { 'ruby' },
			},
			indent = { enable = true, disable = { 'ruby' } },
			textobjects = { -- Add textobjects config here
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to text object, similar to targets.vim
					keymaps = {
						['af'] = '@function.outer',
						['if'] = '@function.inner',
						['ac'] = '@class.outer',
						['ic'] = '@class.inner',
						['ab'] = '@block.outer',
						['ib'] = '@block.inner',
					},
				},
			},
		},
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		opts = {
			enable = true,
		},
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		-- No need for additional config here since it’s included in the main nvim-treesitter setup
	},
}
