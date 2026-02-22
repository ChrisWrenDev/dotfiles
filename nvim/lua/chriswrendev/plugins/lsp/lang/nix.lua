return {
    settings = {
        nixd = {
            -- Make nixd aware of flakes (nixpkgs comes from the flake)
            nixpkgs = {
                expr = "import <nixpkgs> {}",
            },
            formatting = { command = { "alejandra" } },
        },
    },
}
