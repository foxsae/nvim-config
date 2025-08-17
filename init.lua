-- Make Lua 5.1 rocks available to Neovim
-- Make sure to install luarocks --local --version=5.1 (packages) to match current Nvim version of Lua
package.path = package.path ..
    ";/home/foxsae/.luarocks/share/lua/5.1/?.lua;/home/foxsae/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/home/foxsae/.luarocks/lib/lua/5.1/?.so"

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

----------
-- Options
----------

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

-- Neovide Options
vim.o.guifont = "Fira Code:h15"
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_opacity = 0.9
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0
vim.g.neovide_fullscreen = true


-- Bootstrap Packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim', install_path })
  vim.cmd [[packadd packer.nvim]]
end

----------
-- Plugins
----------

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
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = { "c", "cpp", "lua" }, -- add any languages you need
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = { enable = true },

        -- adding these to avoid warnings
        modules = {},
        sync_install = false,
        ignore_install = {},
        auto_install = false,
      }
    end
  }

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

  -- Auto pair brackets
  use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end
  }

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

  -- Nvim Debugger Integrations
  use 'mfussenegger/nvim-dap'

  use {
    'rcarriga/nvim-dap-ui',
    requires = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local dapui_ok, dapui = pcall(require, "dapui")
      if dapui_ok then
        dapui.setup()
      end
    end
  }

  use 'theHamsta/nvim-dap-virtual-text'

  -- Toggleterm
  use {
    "akinsho/toggleterm.nvim",
    tag = '*',
    config = function()
      ---@diagnostic disable-next-line: undefined-field
      require("toggleterm").setup {
        size = 20,
        open_mapping = [[<c-\>]],
        direction = "float",
        close_on_exit = true,
        start_in_insert = true,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = { border = "Normal", background = "Normal" },
        },
      }
    end
  }

  -- Overseer
  use {
    "stevearc/overseer.nvim",
    config = function()
      ---@diagnostic disable-next-line: undefined-field
      require("overseer").setup({
        templates = { "builtin" },
        task_list = {
          direction = "bottom",
          min_height = 15,
        },
      })
    end
  }
end)

-------------------
-- Helper Functions
-------------------

-- Auto Reload
local group_auto_reload = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group_auto_reload,
  pattern = "*",
  command = "checktime"
})

-- Persistent test terminal
local Terminal = require('toggleterm.terminal').Terminal

-- Helper function to run a command in a new floating terminal
local function run_in_float(cmd)
  local float_term = Terminal:new({
    cmd = cmd,
    direction = "float",
    close_on_exit = false,
    hidden = false,
    start_in_insert = true,
  })
  float_term:toggle()
end

-- Single terminal for tests
local test_term = Terminal:new({
  cmd = "ctest --test-dir build --output-on-failure",
  direction = "horizontal", -- or "vertical"
  close_on_exit = false,
  hidden = true,            -- start hidden, shown on first run
  start_in_insert = false,
  on_exit = function(_, exit_code, _)
    if exit_code == 0 then
      vim.notify("All tests passed ✅", vim.log.levels.INFO)
    else
      vim.notify("Tests failed ❌", vim.log.levels.ERROR)
    end
  end,
})

-- Function to run tests manually in the persistent terminal
local function run_tests()
  test_term:toggle()
  test_term:send("ctest --test-dir build --output-on-failure\n", false)
end


-- LSP Setup
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if ok_lsp then
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- C++
  lspconfig.clangd.setup {
    cmd = { "clangd", "--background-index" }, -- LSP only, not build
    filetypes = { "c", "cpp" },
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    capabilities = capabilities,
  }

  -- Lua
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

  -- Autoformt on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.lua" },
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
  })
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

----------
-- Keymaps
----------
-- Debugging Keymaps
local keymap = vim.keymap
keymap.set('n', '<F5>', function() require('dap').continue() end)
keymap.set('n', '<F10>', function() require('dap').step_over() end)
keymap.set('n', '<F11>', function() require('dap').step_into() end)
keymap.set('n', '<F12>', function() require('dap').step_out() end)
keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)

-- Other Keymaps
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

-- Git
vim.keymap.set('n', '<Leader>gs', ':G<CR>', opts)
vim.keymap.set('n', '<Leader>gc', ':Git commit<CR>', opts)
vim.keymap.set('n', '<Leader>gp', ':Git push<CR>', opts)
vim.keymap.set('n', '<Leader>gl', ':Git log<CR>', opts)

-- Run Lua File
vim.keymap.set('n', '<Leader>rl', ":w<CR>:!lua %<CR>", opts)

-- Configure
vim.keymap.set('n', '<Leader>cc', function()
  run_in_float(
    "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -sf build/compile_commands.json compile_commands.json")
end, opts)

-- Build
vim.keymap.set('n', '<Leader>cb', function() run_in_float("cmake --build build -j$(nproc)") end, opts)

-- Clean
vim.keymap.set('n', '<Leader>cl', function() run_in_float("rm -rf build out compile_commands.json") end, opts)

-- Run
vim.keymap.set('n', '<Leader>cr', function()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local exe_path = string.format("./build/%s", project_name)
  run_in_float(exe_path)
end, opts)

-- Keybindings for manual test control
vim.keymap.set('n', '<Leader>tt', run_tests, opts) -- run all tests

vim.keymap.set('n', '<Leader>tr', function()
  test_term:toggle()
end, opts) -- just show/hide the terminal

-- Move current line / selected lines up and down
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)

-- Move selected lines up/down in Visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
