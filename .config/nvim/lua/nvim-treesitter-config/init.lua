require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = "all",

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    disable = { "" },
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  autopairs = {
    enable = true,
  },
}
