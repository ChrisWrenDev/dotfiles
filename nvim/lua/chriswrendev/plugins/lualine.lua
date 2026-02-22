return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
        local function lsp_name()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if not clients or vim.tbl_isempty(clients) then
                return "No LSP"
            end

            -- Prefer “main” language servers for display
            local prefer = {
                "lua_ls",
                "ts_ls",
                "gopls",
                "pyright",
                "rust_analyzer",
                "yamlls",
                "terraformls",
                "dockerls",
                "zls",
            }

            local by_name = {}
            for _, c in ipairs(clients) do
                by_name[c.name] = c
            end

            for _, name in ipairs(prefer) do
                if by_name[name] then
                    return by_name[name].name
                end
            end

            -- fallback: show first attached client
            return clients[1].name
        end

        local lspStatus = {
            lsp_name,
            icon = "",
            color = { fg = "#d3d3d3" },
        }

        local buffer = {
            "buffers",
            mode = 0,
            show_filename_only = true,
            show_modified_status = true,
            hide_filename_extension = false,
            symbols = { alternate_file = "" },
            buffers_color = {
                active = { fg = "#d3d3d3" },
                inactive = { fg = "#414141" },
            },
        }

        local diagnostic = {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            icon = "|",
        }

        local diff = {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
        }

        return {
            options = {
                icons_enabled = true,
                theme = "tokyonight", -- ensure this exists
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = { "alpha", "dashboard", "lazy" },
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = { buffer },
                lualine_x = { diff, diagnostic },
                lualine_y = { lspStatus, "filetype", "location" },
                lualine_z = { "progress" },
            },
        }
    end,
}
