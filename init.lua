-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = ","  -- forjfiletype-specific bindings

-- Always enable signcolumn so it doesn't jump when entering/exiting insert,
-- instead takes over line number
vim.opt.signcolumn = "number"

-- Disable netrw as advised by vim tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.autoindent = true
vim.opt.background = "dark"
vim.opt.showbreak = "+++ "
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.visualbell = true

-- enable mouse in all modes
vim.opt.mouse = "a"

-- Line length guideline
vim.opt.textwidth = 0
vim.opt.colorcolumn = "100"

-- Tab keypress inserts spaces instead
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1    -- just use shiftwidth
-- Note - tabstop still set at 8, in accordance with neovim suggestions

-- How does this actually work? Investigate
-- vim.opt.autocomplete = true

-- Necessary for sharing with system clipboard
vim.opt.clipboard = "unnamedplus"

-- Line/char number in statusline
vim.opt.ruler = true

-- Adjust syntax based on detected filetype (i think?)
vim.opt.syntax = "ON"

-- prevent the built-in vim.lsp.completion autotrigger from selecting the first item
vim.opt.completeopt = { "menuone", "noselect", "popup" }

-- TODO: Should bind something to `vim.opt.relativenumber = true`
-- TODO: bind j/k to gj/gk
-- TODO: disable swapfile buffer for pass?
-- TODO: have mason config automatically download my chosen servers
-- TODO: make LSPs async? I'm seeing delay with my deletes/keypresses. Could also just be because this term isn't super optimized, I should try wezterm instead.
-- Oh it's definitely the LSP servers, as soon as both the config and the serfvers are enabled the lag is very noticeable.
-- But I think they're already async, it might just be eating processor time?
-- TODO: leader commands to open diagnostics, and make sure diagnostic boxes have strong borders!
-- Skim code for lsp plugins so I can figure out how to get diagnostic when files are first opened...

function TableDebug (tab)
    TableDebug_internal(tab, 0)
end

function TableDebug_internal (tab, indent)
    for key, value in pairs(tab) do
        print(string.rep(" ", indent * 4), key)
        if type(value) == "table" then
            TableDebug_internal(value, indent + 1)
        else
            print(string.rep(" ", (indent + 1) * 4), value)
        end
    end
end

-- If lazy.nvim is not present, clone it into standard data dir (.local/share/nvim)
-- It would be nice if this could go in my config directory too, but neovim/lazy.nvim is pretty hardwired
-- around XDG directories.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- It would be nice if I could restrict runtimepath, but unfortunately lazy.nvim entirely replaces it
-- in a way that can't be avoided with metatable hacks. And since runtimepath is only really relevant
-- at the loading plugins stage, it doesn't make sense to try and restrict it after lazy.nvim's work
-- is done.
vim.opt.runtimepath:prepend(lazypath)


-- Setup lazy.nvim
require("lazy").setup({
    spec = {
	-- automatically check for plugin updates
	checker = { enabled = true },

	-- disable support for luarocks so it stops bugging me in checkhealth
	rocks = { enabled = false, hererocks = false },

        { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate" },
        { "scottmckendry/cyberdream.nvim" },
        { "rcarriga/nvim-notify" },

        -- Enable these as I learn to use them properly!
        -- { "nvim-tree/nvim-tree.lua" },
        -- { "nvim-mini/mini.animate", version = "*" },
        -- { "stevearc/oil.nvim" },
        -- Telescope

        require("mason_setup"),
        require("trouble_setup"),
        require("lspconfig_setup"),
        require("lualine_setup"),
        require("mini_clue_setup"),
        require("lean_setup"),
    },
})

vim.cmd([[
   colorscheme cyberdream
]])

vim.notify = require("notify")

-- vim.lsp.config('lua-language-server')
-- add fstar?
-- nix
-- lean4 not necessary, julian/lean.nvim should handle all that
vim.lsp.enable({"lua_ls", "docker_language_server", "rust_analyzer", "pylsp", "clangd"})

local function profile_start ()
    vim.cmd([[
        profile start ~/profile.log
        profile func *
        profile file *
    ]])
end

local function profile_end ()
    vim.cmd([[
        profile pause
    ]])
end

local function toggle_diagnostics()
    vim.diagnostic.enable(
        not vim.diagnostic.is_enabled({bufnr = 0}),
        {bufnr = 0}
    )
end

vim.keymap.set(
    {"n", "v", "o"},
    "<Leader>p",
    profile_start
)

vim.keymap.set(
    {"n", "v", "o"},
    "<Leader>e",
    profile_end
)

-- Toggle diagnostics display
vim.keymap.set(
    {"n", "v", "o"},
    "<Leader>b",
    toggle_diagnostics
)

vim.keymap.set(
    {"n", "v", "o"},
    "j",
    "gj"
)

vim.keymap.set(
    {"n", "v", "o"},
    "k",
    "gk"
)

-- EXTREMELY hacky workaround for diagnostics not showing up immediately sometimes
-- Just makes an edit and immediately reverts it, triggering the diagnostics showing up
-- Don't yet see a better way of doing this, unfortunately :(
vim.keymap.set(
    {"n", "v", "o"},
    "<Leader>r",
    "<Esc>ii<Esc>x"
)

-- Show diagnostics next to code
vim.diagnostic.config {
    virtual_text = true,
}

vim.opt.laststatus = 3
