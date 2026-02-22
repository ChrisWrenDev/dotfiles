return {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            hint = { enable = true },
            telemetry = { enable = false },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
        },
    },
}
