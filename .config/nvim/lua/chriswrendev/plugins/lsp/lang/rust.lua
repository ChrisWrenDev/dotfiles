return {
    ["rust-analyzer"] = {
        procMacro = { enable = true },
        cargo = { allFeatures = true },
        checkOnSave = true,
        check = {
            command = "clippy", --TODO: `rustup component add clippy` to install clippy
            extraArgs = { "--no-deps" },
        },
    }
}


-- return {
--     ["rust-analyzer"] = {
--         procMacro = {
--             enable = false,  -- huge win on RAM/CPU
--         },
--         cargo = {
--             buildScripts = {
--                 enable = false,
--         },
--                 features = { "default" }, -- pick a minimal real set
--         autoreload = false, -- avoid frequent Cargo re-resolve
--         extraEnv = { RUSTC_WRAPPER = "sccache" },
--         },
--         checkOnSave = false, -- stop kicking cargo on every save
--         check = {
--             command = "check", --lighter than clippy
--             extraArgs = { "--no-deps" },
--             allTargets = false, -- dont build tests/benches/examples
--         },
--         files = { watcher = "client" },
--         diagnostics = {
--             disabled = { "inactive-code" }, -- cuts a lot of churn in big repos
--         },
--     },
-- }
