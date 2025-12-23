{
  description = "Modern C Development Flake: A hybrid package and module provider.";

  /*
    📘 NEW ENGINEER GUIDE: THE HYBRID FLAKE PATTERN
    ===============================================
    This file demonstrates a powerful Nix pattern that serves two purposes:
    1. It is a Package Provider: It builds a custom C development environment.
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

        # [Step A] Define the Core Toolchain
        # Modern C development requires a compiler, build tools, and debugging utilities.
        coreTools = [
          # Compiler and standard library
          pkgs.gcc14          # Latest GCC compiler
          pkgs.glibc          # GNU C Library

          # Build systems
          pkgs.gnumake        # GNU Make
          pkgs.cmake          # CMake build system
          pkgs.meson          # Meson build system
          pkgs.ninja          # Ninja build tool (for Meson)
          pkgs.pkg-config     # Package configuration helper

          # Debugging and profiling
          pkgs.gdb            # GNU Debugger
          pkgs.valgrind       # Memory debugging and profiling
          pkgs.lldb           # LLVM debugger (alternative to gdb)

          # Code quality and analysis
          pkgs.clang-tools    # clangd LSP, clang-format, clang-tidy
          pkgs.cppcheck       # Static analysis tool
          pkgs.ccache         # Compiler cache for faster rebuilds

          # Additional utilities
          pkgs.bear           # Generate compile_commands.json
          pkgs.ctags          # Code navigation
        ];

        # [Step B] Create an "Installable" Environment (CRITICAL CONCEPT)
        # Home Manager requires a DIRECTORY of binaries to install.
        # `pkgs.mkShell` (used for devShells) creates a shell script, which HM cannot install.
        # `pkgs.buildEnv` creates a proper directory structure (bin/, lib/) HM can use.
        cEnvPackage = pkgs.buildEnv {
          name = "c-dev-env";
          paths = coreTools;
        };

      in
      {
        # OUTPUT 1: The Installable Package
        # Used by: Home Manager (see Part 2) or `nix profile install`
        packages.default = cEnvPackage;

        # OUTPUT 2: The Development Shell
        # Used by: `nix develop` to drop you into a temporary terminal with these tools.
        devShell = pkgs.mkShell {
          buildInputs = coreTools;

          # Set up useful environment variables
          shellHook = ''
            echo "Modern C Development Environment"
            echo "================================"
            echo "Compiler:  $(gcc --version | head -n1)"
            echo "CMake:     $(cmake --version | head -n1)"
            echo "GDB:       $(gdb --version | head -n1)"
            echo ""
            echo "Type 'clangd --version' to verify LSP is available"
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
          cfg = config.programs.c-dev;
          startupMessage = "Modern C development environment activated!";
        in
        {
          # 1. THE INTERFACE
          # We define an option that users can toggle in their home.nix
          # Usage: programs.c-dev.enable = true;
          options.programs.c-dev = {
            enable = mkEnableOption "Modern C development environment";
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
              llvm-vs-code-extensions.vscode-clangd  # clangd LSP support
              ms-vscode.cpptools                      # C/C++ IntelliSense
              ms-vscode.cmake-tools                   # CMake integration
            ];

            # C. Run Activation Scripts
            # -----------------------
            # Optional: Scripts to run after the generation switches.
            home.activation.cDevInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "${startupMessage}"
            '';
          };
        };
    };
}
