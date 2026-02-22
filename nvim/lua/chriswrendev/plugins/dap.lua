return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- Go debugger
            {
                "leoluz/nvim-dap-go",
                ft = "go",
                config = function()
                    require("dap-go").setup()
                end,
            },
            -- UI
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
                config = function()
                    local dap, dapui = require("dap"), require("dapui")
                    dapui.setup()

                    dap.listeners.after.event_initialized["dapui"] = function()
                        dapui.open()
                    end
                    dap.listeners.before.event_terminated["dapui"] = function()
                        dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui"] = function()
                        dapui.close()
                    end
                end,
            },

            -- Virtual text
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },

            -- Mason integration
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = { "williamboman/mason.nvim" },
                opts = {
                    automatic_installation = true,
                    ensure_installed = {
                        "delve", -- Go
                        "codelldb", -- Rust / C / C++
                        "debugpy", -- Python
                        "js-debug-adapter", -- JS / TS
                    },
                },
            },
        },

        keys = {
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "DAP: Toggle breakpoint",
            },
            {
                "<leader>dB",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "DAP Conditional Breakpoint",
            },

            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "DAP: Continue",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_over()
                end,
                desc = "DAP: Step over",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "DAP: Step into",
            },
            {
                "<leader>dO",
                function()
                    require("dap").step_out()
                end,
                desc = "DAP: Step out",
            },
            {
                "<leader>dr",
                function()
                    require("dap").repl.open()
                end,
                desc = "DAP: REPL",
            },

            {
                "<leader>dl",
                function()
                    require("dap").run_last()
                end,
                desc = "DAP Run Last",
            },

            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "DAP UI Toggle",
            },
        },

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()

            -- Auto open/close UI
            dap.listeners.after.event_initialized["dapui"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui"] = function()
                dapui.close()
            end

            ----------------------------------------------------------------------
            -- GO (delve)
            ----------------------------------------------------------------------
            dap.configurations.go = {
                {
                    type = "go",
                    name = "Debug",
                    request = "launch",
                    program = "${file}",
                },
                {
                    type = "go",
                    name = "Debug test",
                    request = "launch",
                    mode = "test",
                    program = "${file}",
                },
            }

            ----------------------------------------------------------------------
            -- JAVASCRIPT / TYPESCRIPT (node)
            ----------------------------------------------------------------------
            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = {
                        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
                        "${port}",
                    },
                },
            }

            for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
                dap.configurations[lang] = {
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        cwd = "${workspaceFolder}",
                        sourceMaps = true,
                        protocol = "inspector",
                        console = "integratedTerminal",
                    },
                }
            end

            ----------------------------------------------------------------------
            -- PYTHON
            ----------------------------------------------------------------------
            dap.adapters.python = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
                args = { "-m", "debugpy.adapter" },
            }

            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    pythonPath = function()
                        return "python"
                    end,
                },
            }

            ----------------------------------------------------------------------
            -- RUST (codelldb)
            ----------------------------------------------------------------------
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                    args = { "--port", "${port}" },
                },
            }

            dap.configurations.rust = {
                {
                    name = "Debug",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }
        end,
    },
}
