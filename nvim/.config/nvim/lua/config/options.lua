vim.cmd("set expandtab") -- expand tabs to spaces
vim.cmd("set tabstop=4") -- 4 spaces for tabs
vim.cmd("set softtabstop=4") -- 4 spaces while in insert mode
vim.cmd("set shiftwidth=4") -- 4 spaces for indent

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.opt.backupcopy = "yes"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writeany = true

vim.wo.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = false
vim.opt.wrap = false

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.backspace = "indent,eol,start"
vim.opt.clipboard:append("unnamedplus") -- system clipboard

-- split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Performance
vim.opt.updatetime = 300 -- Faster CursorHold events (default: 4000ms)
vim.opt.redrawtime = 1500 -- Prevent hangs on complex syntax (default: 2000ms)
