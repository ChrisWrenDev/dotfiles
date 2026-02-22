local lspconfig = require("lspconfig")

-- Fast profile (snappy editing, no proc-macros/build.rs)
local FAST = {
    ["rust-analyzer"] = {
        procMacro = { enable = false },
        cargo = {
            buildScripts = { enable = false },
            features = { "default" },
            autoreload = false,
            extraEnv = { RUSTC_WRAPPER = "sccache" },
        },
        checkOnSave = false,
        check = {
            command = "check",
            extraArgs = { "--no-deps" },
            allTargets = false,
        },
        files = { watcher = "client" },
        diagnostics = { disabled = { "inactive-code" } },
    },
}

-- Full profile (accurate but heavy; enables macros & build.rs)
local FULL = {
    ["rust-analyzer"] = {
        procMacro = { enable = true },
        cargo = {
            buildScripts = { enable = true },
            autoreload = true,
        },
        checkOnSave = { enable = true, command = "check" },
    },
}

local M = {}

M.set_profile = function(profile)
    lspconfig.rust_analyzer.setup({ settings = profile })
    vim.cmd("LspRestart") -- restart RA with new settings
end

M.fast = function() M.set_profile(FAST) end
M.full = function() M.set_profile(FULL) end

return M
