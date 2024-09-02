-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.g.mapleader = ","

vim.api.nvim_set_keymap("n", "<leader>ve", ":e $MYVIMRC<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ls", ":so $MYVIMRC<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ze", ":e ~/.zshrc<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>te", ":e ~/.tmux.conf<CR>", { noremap = true, silent = true })

-- vim.api.nvim_set_keymap("n", "<leader>r", ":.,$s///gc\\|1,''-&&<C-b><Right><Right><Right><Right>", { noremap = true })
