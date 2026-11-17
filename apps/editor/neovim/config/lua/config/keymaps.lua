-- LazyVim-compatible keymap overrides/additions
local map = vim.keymap.set

map("n", "<leader>ut", "<cmd>IrisReload<cr>", { desc = "Reload Iris theme" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
