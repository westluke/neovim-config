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

return {}
