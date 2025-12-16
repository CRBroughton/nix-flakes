# nix-flakes

Personal Nix flakes monorepo.

## Using Templates

This repository provides Nix flake templates for quick project initialization.

### List Available Templates

```bash
nix flake show github:crbroughton/nix-flakes
```

### Initialize from a Template

Use a specific template in your current directory:

```bash
nix flake init -t github:crbroughton/nix-flakes#elixir
```

Use the default template (elixir):

```bash
nix flake init -t github:crbroughton/nix-flakes
```

### Available Templates

- `elixir` - Elixir development environment with Erlang 28 and Elixir 1.19
- `lua` - Lua development environment with common libraries and LSP
- `fish-shell` - Fish shell configuration
- `frontend-tools` - Frontend development tools
- `keyboard-layouts` - Custom keyboard layouts configuration
- `podman-flake` - Podman container development environment
- `zen-flatpak-config` - Zen Browser Flatpak configuration

## Flakes

- [elixir](elixir/) - Elixir development environment with Erlang 28 and Elixir 1.19
- [lua](lua/) - Lua development environment with essential packages and testing tools via Home Manager
- [frontend-tools](frontend-tools/) - Frontend development tools including package managers (ni, pnpm, bun) via Home Manager
