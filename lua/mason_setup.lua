-- Automatically install these if missing
local default_servers = {
    "clangd",
    "python-lsp-server",
    "rust-analyzer",
    "lua-language-server",
    "docker-language-server",
}

return {
    "mason-org/mason.nvim",
    opts = {}, -- For some reason the empty opts are required?
    config = function ()
        require("mason").setup({})
        local reg = require("mason-registry")
        for _, server in ipairs(default_servers) do
            if not reg.is_installed(server) then
                vim.cmd({cmd = "MasonInstall", args = {server}})
            end
        end
    end
}
