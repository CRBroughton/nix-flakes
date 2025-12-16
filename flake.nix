{
  description = "Collection of Nix flake templates for various development environments";

  outputs = { self }: {
    templates = {
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
