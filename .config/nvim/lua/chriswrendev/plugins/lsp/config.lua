local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

local lang = require("chriswrendev.plugins.lsp.lang")
local opts = require("chriswrendev.plugins.lsp.opts")

local servers = {
    dockerls = {},
    buf_ls = {},
    zls = {},
    ts_ls = lang.ts,
    gopls = lang.go,
    lua_ls = lang.lua,
    yamlls = lang.yaml,
    rust_analyzer = lang.rust,
    terraformls = { filetypes = { "terraform", "tf" } },
    html = {},
    tailwindcss = { filetypes = { "typescriptreact", "javascriptreact", "css" } },
    prismals = {},
    graphql = { filetypes = { "graphql", "gql" } },
}

for name, cfg in pairs(servers) do
    vim.lsp.config(name, {
        on_attach = opts.on_attach,
        capabilities = opts.capabilities,
        settings = cfg,
        filetypes = cfg.filetypes, -- optional
    })
end

mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})
