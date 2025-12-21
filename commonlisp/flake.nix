{
  description = "Common Lisp Development Flake: A hybrid package and module provider.";

  /*
    📘 NEW ENGINEER GUIDE: THE HYBRID FLAKE PATTERN
    ===============================================
    This file demonstrates a powerful Nix pattern that serves two purposes:
    1. It is a Package Provider: It builds a custom Common Lisp environment.
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
        # We construct a Common Lisp development environment.
        devPackages = [
          pkgs.sbcl # Steel Bank Common Lisp compiler
          pkgs.lispPackages.quicklisp # Package manager for Common Lisp
          pkgs.rlwrap # Readline wrapper for better REPL experience
          pkgs.just # Command runner for project-specific tasks
        ];

        # [Step B] Create an "Installable" Environment (CRITICAL CONCEPT)
        # Home Manager requires a DIRECTORY of binaries to install.
        # `pkgs.mkShell` (used for devShells) creates a shell script, which HM cannot install.
        # `pkgs.buildEnv` creates a proper directory structure (bin/, lib/) HM can use.
        commonlispEnvPackage = pkgs.buildEnv {
          name = "commonlisp-dev-env";
          paths = devPackages;
        };

      in
      {
        # OUTPUT 1: The Installable Package
        # Used by: Home Manager (see Part 2) or `nix profile install`
        packages.default = commonlispEnvPackage;

        # OUTPUT 2: The Development Shell
        # Used by: `nix develop` to drop you into a temporary terminal with these tools.
        devShell = pkgs.mkShell {
          buildInputs = devPackages;

          shellHook = ''
            echo "=========================================="
            echo "Common Lisp Development Environment"
            echo "=========================================="
            echo ""
            echo "Included tools:"
            echo "  • SBCL (sbcl) - Steel Bank Common Lisp"
            echo "  • Quicklisp - Common Lisp package manager"
            echo "  • rlwrap - Enhanced REPL with readline support"
            echo "  • Just (just) - Command runner"
            echo ""
            echo "Getting Started:"
            echo ""
            echo "Start an enhanced REPL:"
            echo "  rlwrap sbcl"
            echo ""
            echo "Load Quicklisp (if already installed):"
            echo "  sbcl --load ~/quicklisp/setup.lisp"
            echo ""
            echo "Install Quicklisp (first time):"
            echo "  just install-quicklisp"
            echo ""
            echo "Create a new project with Quicklisp:"
            echo "  sbcl --eval '(ql:quickload :quickproject)' \\"
            echo "       --eval '(quickproject:make-project \"~/my-project/\")' \\"
            echo "       --quit"
            echo ""
            echo "Compile and load a file:"
            echo "  sbcl --load myfile.lisp"
            echo ""
            echo "Project Commands:"
            echo "  just          - List all available commands"
            echo "  just <recipe> - Run a specific command"
            echo ""
            echo "Add your custom commands to the justfile!"
            echo "=========================================="
          '';
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
          cfg = config.programs.commonlisp;
          startupMessage = "Common Lisp development environment activated!";
        in
        {
          # 1. THE INTERFACE
          # We define an option that users can toggle in their home.nix
          # Usage: programs.commonlisp.enable = true;
          options.programs.commonlisp = {
            enable = mkEnableOption "Common Lisp development environment";
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

            # B. Configure the Editor
            # ---------------------
            # We can also configure other tools, like VS Code extensions.
            programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
              yhiraki.lisp-syntax # Common Lisp syntax highlighting
            ];

            # C. Run Activation Scripts
            # -----------------------
            # Optional: Scripts to run after the generation switches.
            home.activation.commonlispInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "${startupMessage}"
            '';
          };
        };
    };
}