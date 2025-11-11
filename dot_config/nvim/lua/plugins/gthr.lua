return {
	-- dir = '/Users/adarsh/Developer/gthr.nvim',
	'Adarsh-Roy/gthr.nvim',
	version = 'v0.1.0',
	cmd = { 'Gthr', 'GthrBuffersInteractive', 'GthrBuffersDirect' },
	keys = {
		{ '<leader>Go',  '<cmd>Gthr<cr>',                   desc = 'Open gthr' },
		{ '<leader>Gbi', '<cmd>GthrBuffersInteractive<cr>', desc = 'Gthr with buffers' },
		{ '<leader>Gbd', '<cmd>GthrBuffersDirect<cr>',      desc = 'Gather context' },
	},
	opts = {
		window = {
			width = 0.9,     -- 80% of editor width
			height = 0.9,    -- 70% of editor height
			border = 'rounded', -- 'single', 'double', 'rounded', 'solid', 'shadow'
		}
	},
}
