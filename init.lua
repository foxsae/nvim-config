-- Make Lua 5.1 rocks available to Neovim
-- Make sure to install luarocks --local --version=5.1 (packages)
package.path = package.path ..
    ";/home/foxsae/.luarocks/share/lua/5.1/?.lua;/home/foxsae/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/home/foxsae/.luarocks/lib/lua/5.1/?.so"

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic Options
vim.o.directory = vim.fn.stdpath("state") .. "/swap//"
vim.o.mouse = "a"
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath('data') .. '/undo//'
vim.o.autoread = true
vim.o.clipboard = "unnamedplus"

-- Auto Reload & Format
local group_auto_reload = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group_auto_reload,
  pattern = "*",
  command = "checktime"
})

local group_format = vim.api.nvim_create_augroup("FormatLuaOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group_format,
  pattern = "*.lua",
  callback = function()
    local ok, _ = pcall(vim.lsp.buf.format, { async = false })
  end
})

-- Bootstrap Packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim', install_path })
  vim.cmd [[packadd packer.nvim]]
end

-- Plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Git
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'

  -- UI & Helpers
  use 'folke/which-key.nvim'
  use 'kyazdani42/nvim-tree.lua'
  use 'kyazdani42/nvim-web-devicons'
  use 'nvim-lualine/lualine.nvim'
  use 'morhetz/gruvbox'
  use 'echasnovski/mini.icons'

  -- Optional Extras
  use 'windwp/nvim-autopairs'
  use 'akinsho/toggleterm.nvim'

  -- GruvBox Material Soft
  use {
    "sainnhe/gruvbox-material",
    config = function()
      -- Set the colorscheme and contrast here
      vim.g.gruvbox_material_background = 'soft' -- options: 'hard', 'medium', 'soft'
      vim.g.gruvbox_material_foreground = 'mix'  -- 'original', 'mix', 'material'
      vim.g.gruvbox_material_better_performance = 1

      vim.cmd('colorscheme gruvbox-material')
    end
  }
end)

-- Neovide Settings
vim.o.guifont = "Fira Code:h15"
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_opacity = 0.9
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0
vim.g.neovide_fullscreen = true

-- Lua LSP Setup
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if ok_lsp then
  -- Lua language server
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  lspconfig.lua_ls.setup {
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      }
    }
  }

  -- C/C++ language server (clangd)
  lspconfig.clangd.setup {
    cmd = { "clangd", "--background-index" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    capabilities = capabilities,
  }
end

-- Treesitter Setup
local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ---@type TSConfig
  local config = {
    ensure_installed = { "c", "cpp", "lua", "python", "javascript", "typescript", "html", "css" },
    highlight = { enable = true },
    incremental_selection = { enable = false },
    indent = { enable = false },
    playground = { enable = false },
    autotag = { enable = false },

    -- Required fields to satisfy TSConfig type
    modules = {},
    sync_install = false,
    ignore_install = {},
    auto_install = false,
  }
  ts_configs.setup(config)
end


-- Gitsigns Setup
local ok_gs, gitsigns = pcall(require, "gitsigns")
if ok_gs then
  gitsigns.setup {
    signs = {
      add          = { hl = 'GitGutterAdd', text = '+', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
      change       = { hl = 'GitGutterChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
      delete       = { hl = 'GitGutterDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
      topdelete    = { hl = 'GitGutterDeleteChange', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
      changedelete = { hl = 'GitGutterChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    },
    numhl = true,
    linehl = true,
    current_line_blame = true,
    current_line_blame_opts = { delay = 500 },
  }
end

-- Telescope Setup
local ok_telescope, telescope = pcall(require, "telescope")
if ok_telescope then
  telescope.setup {
    defaults = {
      cwd = vim.fn.getcwd(),
    }
  }
end

-- Autocompletion Setup
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
  local ok_snip, luasnip = pcall(require, "luasnip")
  if ok_snip and luasnip.loaders and luasnip.loaders.from_vscode then
    -- Load all VSCode-style snippets immediately
    luasnip.loaders.from_vscode.load()
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        if ok_snip then
          luasnip.lsp_expand(args.body)
        end
      end
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
    })
  })
end

-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})

-- Which-Key Setup
local ok_wk, which_key = pcall(require, "which-key")
if ok_wk then
  which_key.setup {
    plugins = { spelling = { enabled = true, suggestions = 20 } },
    icons = { separator = "→", group = "+" },
  }
end

-- Nvim-Tree Setup
local ok_tree, nvim_tree = pcall(require, "nvim-tree")
if ok_tree then
  nvim_tree.setup {
    sort_by = "case_sensitive",
    view = { width = 30, side = "left" },
    renderer = { icons = { show = { git = true, folder = true, file = true } } },
    update_cwd = true,
    hijack_directories = {
      enable = true,
      auto_open = false,
    },
  }
end

-- Lualine Setup
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup {
    options = {
      theme = 'gruvbox-material',
      section_separators = { '', '' },
      component_separators = { '', '' },
      icons_enabled = true,
    },
  }
end

-- Keymaps
local opts = { silent = true }

-- Nvim Tree Toggle
vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', opts)

-- Clear highlighting after search
vim.keymap.set('n', '<Leader><space>', ':noh<CR>', opts)

-- Telescope
vim.keymap.set('n', '<Leader>ff', "<cmd>Telescope find_files<cr>", opts)
vim.keymap.set('n', '<Leader>fg', "<cmd>Telescope live_grep<cr>", opts)
vim.keymap.set('n', '<Leader>fb', "<cmd>Telescope git_branches<cr>", opts)
vim.keymap.set('n', '<Leader>fc', "<cmd>Telescope git_commits<cr>", opts)
vim.keymap.set('n', '<Leader>gf', "<cmd>Telescope git_files<cr>", opts)

-- Ensure fugitive is loaded
vim.cmd [[packadd vim-fugitive]]

-- Git
vim.keymap.set('n', '<Leader>gs', ':G<CR>', opts)
vim.keymap.set('n', '<Leader>gc', ':Git commit<CR>', opts)
vim.keymap.set('n', '<Leader>gp', ':Git push<CR>', opts)
vim.keymap.set('n', '<Leader>gl', ':Git log<CR>', opts)

-- C++
vim.keymap.set('n', '<Leader>rc', ":w<CR>:!g++ % -o %:r && ./%:r<CR>", opts)

-- Lua
vim.keymap.set('n', '<Leader>rl', ":w<CR>:!lua %<CR>", opts)
