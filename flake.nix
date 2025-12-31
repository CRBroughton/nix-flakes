{
  description = "Collection of Nix flake templates for various development environments";

  outputs = { self }: {
    templates = {
      clojure = {
        path = ./clojure;
        description = "Clojure development environment with JDK 25 and VS Code integration";
        welcomeText = ''
          # Clojure Development Environment

          This template provides a Nix flake for Clojure development with:
          - Clojure CLI tools (clj)
          - JDK 25 (headless)
          - VS Code extension (Calva)

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      elixir = {
        path = ./elixir;
        description = "Elixir development environment with Erlang 28 and Elixir 1.19";
        welcomeText = ''
          # Elixir Development Environment

          This template provides a Nix flake for Elixir development with:
          - Elixir 1.19
          - Erlang 28
          - erlfmt (Erlang code formatter)

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To build the environment package:
          ```
          nix build
          ```
        '';
      };

      c = {
        path = ./c;
        description = "Modern C development environment with GCC, build tools, and debugging utilities";
        welcomeText = ''
          # Modern C Development Environment

          This template provides a Nix flake for modern C development with:
          - GCC 14 compiler and glibc
          - Build systems: Make, CMake, Meson/Ninja
          - Debugging: GDB, LLDB, Valgrind
          - Code quality: clangd LSP, clang-format, clang-tidy, cppcheck
          - VS Code integration

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      lua = {
        path = ./lua;
        description = "Lua development environment with common libraries and LSP";
        welcomeText = ''
          # Lua Development Environment

          This template provides a Nix flake for Lua development with:
          - Lua interpreter with pre-loaded libraries (cjson, luafilesystem, luasocket, etc.)
          - lua-language-server
          - VS Code integration

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      nim = {
        path = ./nim;
        description = "Nim development environment with VS Code integration";
        welcomeText = ''
          # Nim Development Environment

          This template provides a Nix flake for Nim development with:
          - Nim compiler and tools
          - VS Code extension (nimsaem.nimvscode)

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      frontend-tools = {
        path = ./frontend-tools;
        description = "Frontend development tools";
        welcomeText = ''
          # Frontend Development Tools

          This template provides a Nix flake for frontend development.

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```
        '';
      };

      commonlisp = {
        path = ./commonlisp;
        description = "Common Lisp development environment with SBCL and Quicklisp support";
        welcomeText = ''
          # Common Lisp Development Environment

          This template provides a Nix flake for Common Lisp development with:
          - SBCL (Steel Bank Common Lisp)
          - rlwrap (enhanced REPL)
          - Just command runner
          - VS Code integration

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      fish-shell = {
        path = ./fish-shell;
        description = "Fish shell environment with Starship, Zoxide, bat, eza, and btop";
        welcomeText = ''
          # Fish Shell Environment

          This template provides a Nix flake for Fish shell with modern CLI tools:
          - Fish shell
          - Starship prompt
          - Zoxide (smart cd)
          - bat (better cat)
          - eza (better ls)
          - btop (system monitor)

          ## Usage

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      love2d = {
        path = ./love2d;
        description = "LÖVE 2D game engine development environment";
        welcomeText = ''
          # LÖVE 2D Development Environment

          This template provides a Nix flake for LÖVE 2D game development with:
          - LÖVE 2D game engine
          - VS Code extension support

          ## Usage

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      luajit = {
        path = ./luajit;
        description = "LuaJIT development environment with common libraries and LSP";
        welcomeText = ''
          # LuaJIT Development Environment

          This template provides a Nix flake for LuaJIT development with:
          - LuaJIT interpreter with pre-loaded libraries (cjson, luafilesystem, luasocket, etc.)
          - lua-language-server
          - VS Code integration

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To use as a Home Manager module, add to your flake inputs and modules.
        '';
      };

      default = {
        path = ./elixir;
        description = "Elixir development environment with Erlang 28 and Elixir 1.19";
        welcomeText = ''
          # Elixir Development Environment

          This template provides a Nix flake for Elixir development with:
          - Elixir 1.19
          - Erlang 28
          - erlfmt (Erlang code formatter)

          ## Usage

          To enter the development shell:
          ```
          nix develop
          ```

          To build the environment package:
          ```
          nix build
          ```
        '';
      };
    };
  };
}
