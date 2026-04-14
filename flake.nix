{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          overlays = [ inputs.rust-overlay.overlays.default ];

          buildInputs = [ ];
          nativeBuildInputs = [
            pkgs.nil # Nix LSP
            rust # Rust toolchain
            pkgs.dioxus-cli # Dioxus CLI
            pkgs.binaryen # wasm_opt for Dioxus CLI
            pkgs.wrangler # For Cloudflare Pages
          ];
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system overlays;
          };

          treefmt = {
            projectRootFile = "flake.nix";

            # Nix
            programs.nixfmt.enable = true;

            # Rust
            programs.rustfmt.enable = true;
            settings.formatter.rustfmt.command = "${rust}/bin/rustfmt";

            # Prettier
            programs.prettier.enable = true;

            # TOML
            programs.taplo.enable = true;

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # ShellScript
            programs.shellcheck.enable = true;
            programs.shfmt.enable = true;
          };

          devShells.default = pkgs.mkShell {
            inherit buildInputs nativeBuildInputs;

            shellHook = ''
              export PS1="\n[nix-shell:\w]$ "
            '';

            inputsFrom = [ config.treefmt.build.devShell ];
          };
        };
    };
}
