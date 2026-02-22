local sign_icons = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
}

vim.diagnostic.config({
    -- replaces vim.fn.sign_define(...)
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = sign_icons.Error,
            [vim.diagnostic.severity.WARN] = sign_icons.Warn,
            [vim.diagnostic.severity.HINT] = sign_icons.Hint,
            [vim.diagnostic.severity.INFO] = sign_icons.Info,
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

-- Hover/Signature borders
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch", -- see `:highlight` for more options
            timeout = 200,
        })
    end,
})

-- Keep formatoptions sane
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})

-- ---------------------------
-- Format on save (LSP + Conform)
-- ---------------------------

-- NOTE: Remove to avoid double formatting with conform.nvim

local augroup = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = false })

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local bufnr = args.buf

        -- Ensure we only ever have one BufWritePre formatter per buffer
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

        -- Helper: request & apply code actions synchronously for a given "only" list
        local function apply_source_action(only)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then
                return
            end

            local params = vim.lsp.util.make_range_params(nil, client.offset_encoding or "utf-16")
            params.context = { only = only, diagnostics = {} }

            local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
            if not results then
                return
            end

            for client_id, res in pairs(results) do
                if res and res.result then
                    for _, action in ipairs(res.result) do
                        if action.edit then
                            vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                        end
                        if action.command then
                            local c = vim.lsp.get_client_by_id(client_id)
                            if c then
                                c.request_sync("workspace/executeCommand", action.command, 3000, bufnr)
                            end
                        end
                    end
                end
            end
        end

        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                -- Skip non-file buffers
                if vim.bo[bufnr].buftype ~= "" then
                    return
                end

                -- Detect attached clients
                local attached = {}
                for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    attached[c.name] = true
                end

                -- 1) fixers (only if attached)
                if attached["eslint"] then
                    apply_source_action({ "source.fixAll.eslint" })
                end
                if attached["ruff_lsp"] or attached["ruff"] then
                    apply_source_action({ "source.fixAll.ruff" })
                end

                -- 2) safe generic actions (no-op if unsupported)
                apply_source_action({ "source.fixAll" })
                apply_source_action({ "source.organizeImports" })

                -- 3) Format (only if Conform is configured OR LSP supports formatting)
                local conform = require("conform")

                -- Conform API varies slightly across versions; this is the safest check:

                -- local ft = vim.bo[bufnr].filetype
                local has_conform = false
                local ok = pcall(function()
                    local list = conform.list_formatters_for_buffer(bufnr)
                    has_conform = list and #list > 0
                end)

                -- If list_formatters_for_buffer isn't available for some reason, just attempt formatting anyway
                if not ok then
                    has_conform = true
                end

                if has_conform then
                    conform.format({
                        bufnr = bufnr,
                        lsp_format = "fallback",
                        async = false,
                        timeout_ms = 5000,
                    })
                else
                    -- No configured formatter for this filetype; fall back to LSP formatting if available
                    vim.lsp.buf.format({
                        bufnr = bufnr,
                        async = false,
                        timeout_ms = 5000,
                    })
                end
            end,
        })
    end,
})
