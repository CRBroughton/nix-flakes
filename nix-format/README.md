# Nix Development Tooling

A Nix flake providing essential tools for Nix development: language servers, formatters, and linters.

## Features

This environment includes:

### Language Servers
- **nixd**: Full-featured Nix language server with completion, diagnostics, and navigation
- **nil**: Lightweight Nix language server

### Formatting & Linting
- **nixfmt**: Official Nix code formatter
- **statix**: Lints and suggests improvements for Nix code
- **deadnix**: Finds and removes unused code in Nix files

### Utilities
- **nix-format**: Custom script that formats and lints all Nix files in a project

## Usage

### As a Development Shell

Enter the development environment:

```bash
nix develop
```

### Format All Nix Files

Run the nix-format script to format and lint your entire project:

```bash
nix run .#format
```

This will:
1. Format all `.nix` files with nixfmt
2. Apply statix fixes
3. Remove dead code with deadnix

### As a Direct Package Install

Install the environment to your profile:

```bash
nix profile install .#
```

## Editor Integration

Both nixd and nil provide LSP support. Configure your editor to use one of them:

### VS Code

Install the "Nix IDE" extension and configure it to use nixd or nil.

### Neovim (with nvim-lspconfig)

```lua
require('lspconfig').nixd.setup{}
-- or
require('lspconfig').nil_ls.setup{}
```