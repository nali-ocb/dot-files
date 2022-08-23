function inspect(...)
  return print(vim.inspect(...))
end

function reload_build()
  vim.cmd("make -C ~/.config/nvim build")
  return vim.cmd("luafile $MYVIMRC")
end

function reload_rebuild()
  package.loaded.init = nil
  package.loaded.lsp = nil
  package.loaded.configs = nil
  package.loaded.plugins = nil
  vim.cmd("make -C ~/.config/nvim rebuild")
  vim.cmd("luafile $MYVIMRC")
end

local function nnoremap(bind, command)
  return vim.api.nvim_set_keymap("n", bind, command, {noremap = true, silent = true})
end

vim.g.mapleader = " "
nnoremap("<leader><Leader>r", ":lua reload_build()<cr>")
nnoremap("<leader><Leader>R", ":lua reload_rebuild()<cr>")

require("plugins")
require("lsp")
require("configs")

--vim.cmd("colorscheme fennec")
vim.cmd("colorscheme codedark")
