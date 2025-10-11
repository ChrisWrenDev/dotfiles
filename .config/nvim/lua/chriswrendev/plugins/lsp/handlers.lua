local sign_icons = {
    Error = " ",
    Warn  = " ",
    Hint  = " ",
    Info  = " ",
}

vim.diagnostic.config({
    -- replaces vim.fn.sign_define(...)
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = sign_icons.Error,
            [vim.diagnostic.severity.WARN]  = sign_icons.Warn,
            [vim.diagnostic.severity.HINT]  = sign_icons.Hint,
            [vim.diagnostic.severity.INFO]  = sign_icons.Info,
        },
        -- if you were relying on texthl=numhl before, link hi groups instead (below)
    },

    virtual_text = true,
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
    },
})


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    signs = true,
    underline = true,
    virtual_text = {
        spacing = 5,
        min = vim.diagnostic.severity.HINT,
    },
    update_in_insert = true,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch", -- see `:highlight` for more options
            timeout = 200,
        })
    end,
})

-- format on save
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        local bufnr = args.buf

        -- Helper: request & apply code actions synchronously for a given "only" list
        local function apply_source_action(only)
            local params = vim.lsp.util.make_range_params(nil, client.offset_encoding or "utf-16")
            params.context = { only = only, diagnostics = {} }

            local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
            if not results then return end

            for client_id, res in pairs(results) do
                if res and res.result then
                    for _, action in ipairs(res.result) do
                        if action.edit then
                            vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                        end
                        if action.command then
                            local c = vim.lsp.get_client_by_id(client_id)
                            if c then c.request_sync("workspace/executeCommand", action.command, 3000, bufnr) end
                        end
                    end
                end
            end
        end

        -- Detect attached clients on this buffer
        local attached = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            attached[c.name] = true
        end

        -- Some servers already organize imports during format (e.g. gopls)
        local skip_explicit_organize = attached["gopls"] == true

        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                -- 1) fixAll (only runs if that server is attached)
                if attached["eslint"] then
                    apply_source_action({ "source.fixAll.eslint" })
                end

                if attached["ruff_lsp"] or attached["ruff"] then
                    apply_source_action({ "source.fixAll.ruff" })
                end

                -- Generic fixAll fallback if a server provides it (safe no-op otherwise)
                apply_source_action({ "source.fixAll" })

                -- 2) Organize imports (skip if the formatter already does it)
                if not skip_explicit_organize then
                    apply_source_action({ "source.organizeImports" })
                end

                -- 3) Format (blocking to keep versions in sync)
                -- vim.lsp.buf.format({
                --     bufnr = bufnr,
                --     async = false,
                --     timeout_ms = 5000,
                -- })

                require("conform").format({
                    bufnr = bufnr,
                    lsp_fallback = true, -- avoid tsserver/gopls formatting
                    async = false,       -- keep it synchronous to avoid races
                    timeout_ms = 5000,
                })

                -- if client:supports_method("textDocument/formatting") then
                --     vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                -- end

                -- if client:supports_method("textDocument/codeAction") then
                --     local function apply_code_action(only)
                --         local actions = vim.lsp.buf.code_action({
                --             ---@diagnostic disable-next-line
                --             context = { only = only },
                --             apply = true,
                --             return_actions = true,
                --         })
                --         -- only apply if code action is available
                --         if actions and #actions > 0 then
                --             ---@diagnostic disable-next-line
                --             vim.lsp.buf.code_action({ context = { only = only }, apply = true })
                --         end
                --     end
                --     apply_code_action({ "source.fixAll" })
                --     apply_code_action({ "source.organizeImports" })
                -- end
            end,
        })
    end,
})

vim.cmd([[autocmd FileType * set formatoptions-=ro]])
