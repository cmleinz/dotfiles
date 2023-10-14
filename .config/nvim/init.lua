-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable", -- latest stable release
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)

-- require("lazy").setup(plugins, opts)
require('mappings')
require('plugins')
require('settings')
require('nvim-treesitter-config')
require('nvim-tree-config')
require('nvim-autopairs-config')
require('nvim-lsp-config')
require('nvim-cmp-config')
require('nvim-null-ls')
