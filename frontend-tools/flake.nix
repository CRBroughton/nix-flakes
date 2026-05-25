{
  description = "Frontend Development Flake: A hybrid package and module provider.";

  /*
    📘 NEW ENGINEER GUIDE: THE HYBRID FLAKE PATTERN
    ===============================================
    This file demonstrates a powerful Nix pattern that serves two purposes:
    1. It is a Package Provider: It builds a custom frontend environment.
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

        # [Step A] Define the Raw Packages
        # A curated set of package-manager-agnostic frontend tooling:
        #   pnpm  — fast, disk-efficient Node package manager
        #   bun   — all-in-one JS runtime, bundler, and package manager
        #   ni    — universal package manager shim (runs pnpm/npm/yarn/bun
        #           automatically based on the lockfile present in the project)
        #   unzip — needed by several toolchains to extract downloaded archives
        frontendTools = [
          pkgs.nodePackages.pnpm
          pkgs.bun
          pkgs.ni
          pkgs.unzip
        ];

        # [Step B] Create an "Installable" Environment (CRITICAL CONCEPT)
        # Home Manager requires a DIRECTORY of binaries to install.
        # `pkgs.mkShell` (used for devShells) creates a shell script, which HM cannot install.
        # `pkgs.buildEnv` creates a proper directory structure (bin/, lib/) HM can use.
        frontendEnvPackage = pkgs.buildEnv {
          name = "frontend-dev-env";
          paths = frontendTools;
        };

      in
      {
        # OUTPUT 1: The Installable Package
        # Used by: Home Manager (see Part 2) or `nix profile install`
        packages.default = frontendEnvPackage;

        # OUTPUT 2: The Development Shell
        # Used by: `nix develop` to drop you into a temporary terminal with these tools.
        devShells.default = pkgs.mkShell {
          buildInputs = frontendTools;
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
          cfg = config.programs.frontend-tools;
          startupMessage = "Frontend development environment activated!";
        in
        {
          # 1. THE INTERFACE
          # We define an option that users can toggle in their home.nix
          # Usage: programs.frontend-tools.enable = true;
          options.programs.frontend-tools = {
            enable = mkEnableOption "Frontend development tools";
          };

          # 2. THE IMPLEMENTATION
          # If the user enables the module, this config block is applied.
          config = mkIf cfg.enable {

            # A. Install the Package
            # --------------------
            # We must reference the package we built in Part 1.
            # `self` refers to this very flake.
            # `pkgs.stdenv.hostPlatform.system` automatically picks the correct
            # architecture (e.g., x86_64-linux) for the user's machine.
            home.packages = [
              self.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];

            # B. Run Activation Scripts
            # -----------------------
            # Optional: Scripts to run after the generation switches.
            home.activation.frontendInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "${startupMessage}"
            '';
          };
        };
    };
}
