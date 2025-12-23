# nix-flakes

Personal Nix flakes monorepo.

## Using Templates

This repository provides Nix flake templates for quick project initialization.

### List Available Templates

```bash
nix flake show github:crbroughton/nix-flakes
```

**Note:** If you encounter errors about missing paths, refresh the flake cache:
```bash
nix flake metadata github:crbroughton/nix-flakes --refresh
```

### Initialise from a Template

Use a specific template in your current directory:

```bash
nix flake init -t github:crbroughton/nix-flakes#elixir
```

Use the default template (elixir):

```bash
nix flake init -t github:crbroughton/nix-flakes
```

### Use a Template Without Initialising

You can enter a development shell directly from a remote template without copying files:

```bash
# Using the path to the subdirectory flake
nix develop github:crbroughton/nix-flakes?dir=elixir

# Or for other templates
nix develop github:crbroughton/nix-flakes?dir=clojure
nix develop github:crbroughton/nix-flakes?dir=nim
nix develop github:crbroughton/nix-flakes?dir=lua
```

This is useful for:
- Testing a template before initialising it
- Quick one-off development sessions
- Trying out different environments without cluttering your project

### Available Templates

- `c` - Modern C development environment with GCC, build tools, and debugging utilities
- `clojure` - Clojure development environment with JDK 25 and VS Code integration
- `elixir` - Elixir development environment with Erlang 28 and Elixir 1.19
- `lua` - Lua development environment with common libraries and LSP
- `nim` - Nim development environment with VS Code integration
- `fish-shell` - Fish shell configuration
- `frontend-tools` - Frontend development tools
- `keyboard-layouts` - Custom keyboard layouts configuration
- `podman-flake` - Podman container development environment
- `zen-flatpak-config` - Zen Browser Flatpak configuration

## Flakes

- [c](c/) - Modern C development environment with GCC 14, build systems (Make, CMake, Meson), debugging tools (GDB, LLDB, Valgrind), and LSP support via Home Manager
- [clojure](clojure/) - Clojure development environment with JDK 25 and VS Code integration via Home Manager
- [elixir](elixir/) - Elixir development environment with Erlang 28 and Elixir 1.19
- [lua](lua/) - Lua development environment with essential packages and testing tools via Home Manager
- [nim](nim/) - Nim development environment with VS Code integration via Home Manager
- [frontend-tools](frontend-tools/) - Frontend development tools including package managers (ni, pnpm, bun) via Home Manager
