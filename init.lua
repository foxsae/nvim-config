-------------------
-- Leader Keys
-------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-------------------
-- LuaRocks Paths
-------------------
local luarocks_path = "/home/foxsae/.luarocks/share/lua/5.1/?.lua;/home/foxsae/.luarocks/share/lua/5.1/?/init.lua"
local luarocks_cpath = "/home/foxsae/.luarocks/lib/lua/5.1/?.so"

if not package.path:find(luarocks_path, 1, true) then
  package.path = package.path .. ";" .. luarocks_path
end

if not package.cpath:find(luarocks_cpath, 1, true) then
  package.cpath = package.cpath .. ";" .. luarocks_cpath
end

-------------------
-- Core Options
-------------------
local o = vim.opt

-- General
o.mouse = "a"
o.termguicolors = true
o.cursorline = true
o.number = true
o.relativenumber = true

-- Search
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

-- Undo / Swap / Auto-read
o.undofile = true
o.undodir = vim.fn.stdpath("state") .. "/undo"
o.directory = vim.fn.stdpath("state") .. "/swap"
o.autoread = true

-- Clipboard
o.clipboard = "unnamedplus"

-------------------
-- Neovide Options
-------------------
if vim.g.neovide then
  o.guifont = "Fira Code:h14"
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_opacity = 0.9
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_fullscreen = true
end

-------------------
-- Bootstrap Packer
-------------------
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  print("Installing packer.nvim...")
  fn.system({
    "git", "clone", "--depth", "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  vim.cmd([[packadd packer.nvim]])
  print("Packer installed!")
end

-------------------
-- Plugins
-------------------
require("packer").startup(function(use)
  use("wbthomason/packer.nvim") -- Packer manages itself

  -------------------
  -- LSP
  -------------------
  use("neovim/nvim-lspconfig")

  -------------------
  -- Autocompletion & Snippets
  -------------------
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp_ok, cmp = pcall(require, "cmp")
      if not cmp_ok then return end


      local luasnip_ok, luasnip = pcall(require, "luasnip")
      if luasnip_ok and luasnip.loaders and luasnip.loaders.from_vscode then
        pcall(luasnip.loaders.from_vscode.lazy_load)
      end

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            if luasnip_ok then luasnip.lsp_expand(args.body) end
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip_ok and luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip_ok and luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        experimental = { ghost_text = true },
      })
    end,
  }

  -------------------
  -- Treesitter
  -------------------
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua" },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = { enable = true },
        modules = {},
        sync_install = false,
        ignore_install = {},
        auto_install = false,
      })
    end,
  }

  -------------------
  -- Telescope
  -------------------
  use { "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }

  -------------------
  -- Git
  -------------------
  use("tpope/vim-fugitive")
  use {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = { delay = 500 },
        numhl = false,
        linehl = true,
      })
    end
  }

  -------------------
  -- UI & Helpers
  -------------------
  use("folke/which-key.nvim")
  use("nvim-tree/nvim-web-devicons")
  use {
    "kyazdani42/nvim-tree.lua",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = { width = 30, side = "left" },
        update_cwd = true,
        hijack_directories = { enable = true, auto_open = false },
        renderer = { icons = { show = { git = true, folder = true, file = true } } },
      })
    end
  }
  use {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox-material", section_separators = "", component_separators = "", icons_enabled = true },
      })
    end
  }

  -------------------
  -- Auto pairs
  -------------------
  use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end
  }

  -------------------
  -- Colorscheme
  -------------------
  use {
    "sainnhe/gruvbox-material",
    config = function()
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_foreground = "mix"
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd("colorscheme gruvbox-material")
    end
  }

  -------------------
  -- Debugging
  -------------------
  use("mfussenegger/nvim-dap")
  use {
    "rcarriga/nvim-dap-ui",
    requires = { "mfussenegger/nvim-dap" },
    config = function()
      local ok, dapui = pcall(require, "dapui")
      if ok then dapui.setup() end
    end
  }
  use({
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup({})
    end,
  })

  -------------------
  -- Terminal
  -------------------
  use {
    "akinsho/toggleterm.nvim",
    tag = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        direction = "float",
        close_on_exit = true,
        start_in_insert = true,
        float_opts = { border = "curved", winblend = 0, highlights = { border = "Normal", background = "Normal" } },
      })
    end
  }

  -------------------
  -- Task Runner
  -------------------
  use {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup({
        templates = { "builtin" },
        task_list = { direction = "bottom", min_height = 15 },
      })
    end
  }
end)

-------------------
-- Helper Functions
-------------------

-- Auto reload file if changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  pattern = "*",
  command = "checktime",
})

-- Persistent test terminal
local Terminal = require("toggleterm.terminal").Terminal
local test_term = Terminal:new({
  cmd = "ctest --test-dir build --output-on-failure",
  direction = "horizontal",
  hidden = true,
  start_in_insert = false,
  close_on_exit = false,
  on_exit = function(_, exit_code)
    if exit_code == 0 then
      vim.notify("All tests passed ✅", vim.log.levels.INFO)
    else
      vim.notify("Tests failed ❌", vim.log.levels.ERROR)
    end
  end,
})

local function run_tests()
  test_term:toggle()
  test_term:send("ctest --test-dir build --output-on-failure\n", false)
end

local function run_in_float(cmd)
  Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false, start_in_insert = true }):toggle()
end

-------------------
-- LSP Setup
-------------------
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if ok_lsp then
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  -- C++ LSP
  lspconfig.clangd.setup({
    cmd = { "clangd", "--background-index" },
    filetypes = { "c", "cpp" },
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    capabilities = capabilities,
  })

  -- Lua LSP
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      }
    }
  })

  -- Autoformat on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("AutoFormatOnSave", { clear = true }),
    pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.lua" },
    callback = function() vim.lsp.buf.format({ async = false }) end,
  })
end

-------------------
-- Treesitter
-------------------
local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok_ts and ts_configs then
  ts_configs.setup({
    ensure_installed = { "c", "cpp", "lua", "python", "javascript", "typescript", "html", "css" },
    highlight = { enable = true },
    incremental_selection = { enable = false },
    indent = { enable = false },
    playground = { enable = false },
    autotag = { enable = false },
    sync_install = false,
    auto_install = false,
    modules = {},
    ignore_install = {},
  })
end

-------------------
-- Gitsigns
-------------------
local ok_gs, gitsigns = pcall(require, "gitsigns")
if ok_gs and gitsigns then
  gitsigns.setup({
    current_line_blame = true,
    current_line_blame_opts = { delay = 500 },
    numhl = false,
    linehl = true,
  })
end

-------------------
-- Telescope
-------------------
local ok_telescope, telescope = pcall(require, "telescope")
if ok_telescope then
  local actions = require("telescope.actions")
  telescope.setup({
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      path_display = { "smart" },
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = { prompt_position = "top", preview_width = 0.55, results_width = 0.8 },
        width = 0.87,
        height = 0.80,
      },
      file_ignore_patterns = { "node_modules", ".git/" },
      mappings = {
        i = { ["<C-n>"] = actions.cycle_history_next, ["<C-p>"] = actions.cycle_history_prev },
        n = { ["q"] = actions.close },
      },
    },
    pickers = {
      find_files = { theme = "dropdown", previewer = true },
      live_grep = { theme = "ivy" },
    },
    extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" } },
  })
  pcall(telescope.load_extension, "fzf")
end

-------------------
-- Autocompletion (nvim-cmp)
-------------------
local ok_cmp, cmp = pcall(require, "cmp")
local ok_snip, luasnip = pcall(require, "luasnip")
if ok_snip and luasnip.loaders and luasnip.loaders.from_vscode then
  pcall(luasnip.loaders.from_vscode.lazy_load)
end

if ok_cmp then
  cmp.setup({
    snippet = { expand = function(args) if ok_snip then luasnip.lsp_expand(args.body) end end },
    mapping = cmp.mapping.preset.insert({
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif ok_snip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif ok_snip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" } }),
    completion = { completeopt = "menu,menuone,noinsert" },

    formatting = {
      format = function(entry, vim_item)
        if type(vim_item) == "table" and entry.source then
          local menu_icons = {
            buffer = "[Buffer]",
            path = "[Path]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
          }
          vim_item.menu = menu_icons[entry.source.name] or ""
        end
        return vim_item
      end,
    },
  })
end

-------------------
-- Diagnostics
-------------------
vim.diagnostic.config({ virtual_text = true, signs = true, update_in_insert = false })

-------------------
-- Which-Key
-------------------
local ok_wk, which_key = pcall(require, "which-key")
if ok_wk and which_key then
  which_key.setup({
    plugins = { spelling = { enabled = true, suggestions = 20 } },
    icons = { separator = "→", group = "+" },
  })
end

-------------------
-- Nvim-Tree
-------------------
local ok_tree, nvim_tree = pcall(require, "nvim-tree")
if ok_tree and nvim_tree then
  nvim_tree.setup({
    sort_by = "case_sensitive",
    view = { width = 30, side = "left" },
    renderer = { icons = { show = { git = true, folder = true, file = true } } },
    update_cwd = true,
    hijack_directories = { enable = true, auto_open = false },
    git = { enable = true, ignore = false },
    diagnostics = { enable = true, show_on_dirs = true },
  })
end


-------------------
-- Lualine
-------------------
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup({
    options = {
      theme = "gruvbox-material",
      section_separators = { "▶", "◀" },
      component_separators = { "▸", "◂" },
      icons_enabled = true,
    },
  })
end

-------------------
-- Keymaps
-------------------

local keymap = vim.keymap
local opts = { silent = true }

--------------------------
-- Debugging Keymaps (DAP)
--------------------------
local dap = require("dap")
keymap.set('n', '<F5>', dap.continue, opts)
keymap.set('n', '<F10>', dap.step_over, opts)
keymap.set('n', '<F11>', dap.step_into, opts)
keymap.set('n', '<F12>', dap.step_out, opts)
keymap.set('n', '<Leader>b', dap.toggle_breakpoint, opts)
keymap.set('n', '<Leader>B', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, opts)

----------------------
-- File Explorer
----------------------
keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', opts)

---------------------
-- Search & Telescope
---------------------
keymap.set('n', '<Leader><space>', ':noh<CR>', opts) -- clear search highlight
keymap.set('n', '<Leader>ff', '<cmd>Telescope find_files<CR>', opts)
keymap.set('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', opts)
keymap.set('n', '<Leader>fb', '<cmd>Telescope git_branches<CR>', opts)
keymap.set('n', '<Leader>fc', '<cmd>Telescope git_commits<CR>', opts)
keymap.set('n', '<Leader>gf', '<cmd>Telescope git_files<CR>', opts)

-----------------------
-- Git Commands
-----------------------
keymap.set('n', '<Leader>gs', ':G<CR>', opts)
keymap.set('n', '<Leader>gc', ':Git commit<CR>', opts)
keymap.set('n', '<Leader>gp', ':Git push<CR>', opts)
keymap.set('n', '<Leader>gl', ':Git log<CR>', opts)

-----------------------
-- Lua / Build Commands
-----------------------
-- Run the current file in Lua
keymap.set('n', '<Leader>rl', ':w<CR>:!lua %<CR>', opts)

-- CMake Configure
keymap.set('n', '<Leader>cc', function()
  run_in_float(
    "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -sf build/compile_commands.json compile_commands.json")
end, opts)

-- CMake Build Debug
keymap.set('n', '<Leader>cbd', function()
  run_in_float(
  "cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j$(nproc) && ln -sf build/compile_commands.json compile_commands.json")
end, opts)

-- CMake Build Release
keymap.set('n', '<Leader>cbr', function()
  run_in_float(
  "cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j$(nproc) && ln -sf build/compile_commands.json compile_commands.json")
end, opts)

-- Cmake Clean
keymap.set('n', '<Leader>cl', function()
  run_in_float("rm -rf build out compile_commands.json")
end, opts)

-- Cmake Run
keymap.set('n', '<Leader>cr', function()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  run_in_float(string.format("./build/%s", project_name))
end, opts)

-----------------------
-- Tests (DAP / CTest)
-----------------------
keymap.set('n', '<Leader>tt', run_tests, opts)                         -- run all tests
keymap.set('n', '<Leader>tr', function() test_term:toggle() end, opts) -- show/hide terminal

-----------------------
-- Move Lines
-----------------------
-- Normal mode
keymap.set('n', '<A-k>', ':m .-2<CR>==', opts)
keymap.set('n', '<A-j>', ':m .+1<CR>==', opts)

-- Visual mode
keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)
keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
keymap.set('v', 'J', ":m '>+1<CR>gv=gv", opts)
keymap.set('v', 'K', ":m '<-2<CR>gv=gv", opts)
