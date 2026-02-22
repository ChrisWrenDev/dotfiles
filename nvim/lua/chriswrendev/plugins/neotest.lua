return {
    {
        "nvim-neotest/neotest",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neotest/nvim-nio",

            -- Adapters (pick what you use)
            "nvim-neotest/neotest-go",

            "nvim-neotest/neotest-jest",
            "marilari88/neotest-vitest",
            -- "arthur944/neotest-bun",

            "nvim-neotest/neotest-python",
            -- For Rust, many people use neotest-rust or neotest-golang-like community adapters.
            "rouge8/neotest-rust",
            -- "mrcjkb/rustaceanvim",

            -- "thenbe/neotest-playwright",

            -- "lawrence-laz/neotest-zig",

            -- OPTIONAL: fallback for projects that insist on cargo test
            -- (Run support via vim-test; not as rich as native adapters.)
            -- "vim-test/vim-test",
            -- "nvim-neotest/neotest-vim-test",
        },

        keys = {
            -- Run
            {
                "<leader>tn",
                function()
                    require("neotest").run.run()
                end,
                desc = "Test: nearest",
            },
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Test: file",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Test: summary",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open({ enter = true })
                end,
                desc = "Test: output",
            },
            {
                "<leader>tp",
                function()
                    require("neotest").output_panel.toggle()
                end,
                desc = "Test: output panel",
            },

            -- Debug via DAP (adapter must support it)
            {
                "<leader>dn",
                function()
                    require("neotest").run.run({ strategy = "dap" })
                end,
                desc = "Test: debug nearest (DAP)",
            },
            {
                "<leader>df",
                function()
                    require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
                end,
                desc = "Test: debug file (DAP)",
            },

            -- Optional: stop
            {
                "<leader>tq",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Test: stop",
            },
        },

        config = function()
            local adapters = {}

            -- Go
            table.insert(
                adapters,
                require("neotest-go")({
                    -- optional:
                    -- experimental = { test_table = true },
                })
            )

            -- Python
            table.insert(
                adapters,
                require("neotest-python")({
                    -- Optional: runner = "pytest",
                    -- Extra args for debugpy when using strategy="dap" live here in this adapter.
                })
            )

            -- Jest
            table.insert(
                adapters,
                require("neotest-jest")({
                    -- Usually auto-detected; set if you want something explicit:
                    -- jestCommand = "npm test --",
                })
            )

            -- Vitest
            table.insert(
                adapters,
                require("neotest-vitest")({
                    filter_dir = function(name, _, _)
                        return name ~= "node_modules"
                    end,
                })
            )

            -- Bun
            -- table.insert(
            --     adapters,
            --     require("neotest-bun")({
            --         -- options
            --     })
            -- )

            -- Playwright
            -- table.insert(
            --     adapters,
            --     require("neotest-playwright")({
            --         -- options
            --     })
            -- )

            -- Zig
            -- table.insert(
            --     adapters,
            --     require("neotest-zig")({
            --         -- options
            --     })
            -- )

            -- Rust: nextest + DAP test debugging
            -- If you want to only enable it when nextest is installed:
            if vim.fn.executable("cargo-nextest") == 1 then
                table.insert(
                    adapters,
                    require("neotest-rust")({
                        args = { "--no-capture" }, -- optional
                        -- dap_adapter = "codelldb", -- default; set if you want another
                    })
                )
            end

            -- table.insert(
            --     adapters,
            --     require("neotest-vim-test")({
            --         ignore_file_types = {
            --             "javascript",
            --             "typescript",
            --             "javascriptreact",
            --             "typescriptreact",
            --             "rust",
            --             "lua",
            --         },
            --     })
            -- )

            require("neotest").setup({
                adapters = adapters,
            })
        end,
    },
}
