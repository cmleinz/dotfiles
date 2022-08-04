local set = vim.opt

set.expandtab = true
set.smarttab = true
set.hlsearch = true

set.shiftwidth = 4
set.tabstop = 4
set.ignorecase = true
set.smartcase = true

set.splitbelow = true
set.splitright = true
set.number = true
set.relativenumber = true
set.autoindent = true
set.scrolloff = 5
set.fileencoding = 'utf-8'

set.wrap = false

-- COLORSCHEME
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme duskfox]])
vim.g.airline_theme = "base16_gruvbox_dark_medium"
