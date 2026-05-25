{
  description = "Zig Development Flake: A hybrid package and module provider.";

  /*
    📘 NEW ENGINEER GUIDE: THE HYBRID FLAKE PATTERN
    ===============================================
    This file demonstrates a powerful Nix pattern that serves two purposes:
    1. It is a Package Provider: It builds a custom Zig environment.
    2. It is a Module Provider: It exports a Home Manager module to install that environment.

    The file is split into two halves, combined by the `//` merge operator.
    - PART 1: Builds the software (system-specific).
    - PART 2: Configures the software (system-agnostic).
  */

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:

    # =========================================================================
    # PART 1: SYSTEM-SPECIFIC OUTPUTS (The Builder)
    # =========================================================================
    # We use `flake-utils` to loop over every standard architecture (Linux, Mac).
    # Everything inside this block is calculated separately for "x86_64-linux", etc.
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # [Step A] Version map — compiler + matching ZLS for each supported release.
        # ZLS must match the compiler version; mismatches cause hard errors at startup.
        versions = {
          "latest" = { compiler = pkgs.zig;      lsp = pkgs.zls;      };
          "0.14"   = { compiler = pkgs.zig_0_14; lsp = pkgs.zls_0_14; };
          "0.13"   = { compiler = pkgs.zig_0_13; lsp = pkgs.zls_0_14; };
        };

        # Helper: build a mkShell for a given version entry.
        mkZigShell = v: pkgs.mkShell { buildInputs = [ v.compiler v.lsp ]; };

        # [Step B] Create an "Installable" Environment (CRITICAL CONCEPT)
        # Home Manager requires a DIRECTORY of binaries to install.
        # `pkgs.mkShell` (used for devShells) creates a shell script, which HM cannot install.
        # `pkgs.buildEnv` creates a proper directory structure (bin/, lib/) HM can use.
        zigEnvPackage = pkgs.buildEnv {
          name = "zig-dev-env";
          paths = [ versions."latest".compiler versions."latest".lsp ];
        };

      in
      {
        # OUTPUT 1: The Installable Package
        # Used by: Home Manager (see Part 2) or `nix profile install`
        packages.default = zigEnvPackage;

        # OUTPUT 2: Named Development Shells — one per supported version.
        # Usage:
        #   nix develop            → latest (0.15)
        #   nix develop .#"0.14"   → zig 0.14 + zls 0.14
        #   nix develop .#"0.13"   → zig 0.13 + zls 0.14
        devShells = builtins.mapAttrs (_: v: mkZigShell v) versions // {
          default = mkZigShell versions."latest";
        };
      }
    )

    # =========================================================================
    # PART 2: TOP-LEVEL OUTPUTS (The Configurator)
    # =========================================================================
    # The `//` operator merges the system-specific map (above) with the global map (below).
    # Modules are system-agnostic code, so they live here, outside the system loop.
    // {
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        with lib;
        let
          cfg = config.programs.zig;
          startupMessage = "Zig development environment activated!";

          # Map the user's chosen version string to the matching compiler + ZLS packages.
          # ZLS must match the compiler version — mismatches cause hard errors at startup.
          versionMap = {
            "latest" = { compiler = pkgs.zig;      lsp = pkgs.zls;      };
            "0.14"   = { compiler = pkgs.zig_0_14; lsp = pkgs.zls_0_14; };
            "0.13"   = { compiler = pkgs.zig_0_13; lsp = pkgs.zls_0_14; };
          };

          selected = versionMap.${cfg.version};

        in
        {
          # 1. THE INTERFACE
          # We define options that users can toggle in their home.nix
          # Usage:
          #   programs.zig.enable = true;
          #   programs.zig.version = "0.14";
          options.programs.zig = {
            enable = mkEnableOption "Zig development environment";

            version = mkOption {
              type = types.enum [ "latest" "0.14" "0.13" ];
              default = "latest";
              description = ''
                Zig version to install. The matching ZLS (Zig Language Server)
                is selected automatically.

                  latest  →  zig 0.15.x  +  zls 0.15.x
                  0.14    →  zig 0.14.x  +  zls 0.14.x
                  0.13    →  zig 0.13.x  +  zls 0.14.x (closest available)
              '';
            };
          };

          # 2. THE IMPLEMENTATION
          # If the user enables the module, this config block is applied.
          config = mkIf cfg.enable {

            # A. Install the Package
            # --------------------
            # We install the version-matched compiler and language server directly
            # from pkgs rather than from the Part 1 package, so the version option
            # is honoured without rebuilding the flake.
            home.packages = [
              selected.compiler
              selected.lsp
            ];

            # B. Configure the Editor
            # ---------------------
            # We can also configure other tools, like VS Code extensions.
            programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
              ziglang.vscode-zig
            ];

            # Point the extension at the Nix-provided binaries.
            # Without this, the extension tries to download its own zig/zls binaries
            # which are generic Linux ELFs that NixOS cannot execute.
            programs.vscode.profiles.default.userSettings = {
              "zig.path" = "${selected.compiler}/bin/zig";
              "zig.zls.path" = "${selected.lsp}/bin/zls";
            };

            # C. Run Activation Scripts
            # -----------------------
            # Optional: Scripts to run after the generation switches.
            home.activation.zigInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "${startupMessage}"
            '';
          };
        };
    };
}
