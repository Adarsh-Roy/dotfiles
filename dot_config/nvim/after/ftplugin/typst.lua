vim.keymap.set("n", "<space>lb", "i \\ <esc>", { buffer = true, desc = "Add line break." })
vim.keymap.set("n", "<space>mdi", "F$adisplay(<esc>f$i)<esc>",
	{ buffer = true, desc = "Make the math block display mode inline" })
