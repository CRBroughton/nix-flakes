# Frontend Tools

A Nix flake providing a **zero-config frontend development environment** with essential package managers via Home Manager.

## Features

- Zero configuration required
- **ni** - Use the right package manager automatically
- **pnpm** - Fast, disk space efficient package manager
- **bun** - All-in-one JavaScript runtime & toolkit

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    frontend-tools.url = "github:yourusername/nix-flakes?dir=frontend-tools";
    # or local:
    # frontend-tools.url = "path:/home/craig/code/nix-flakes/frontend-tools";
  };
}
```

### 2. Import the Home Manager module

```nix
{
  outputs = { self, nixpkgs, home-manager, frontend-tools, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      modules = [
        frontend-tools.homeManagerModules.default
        ./home.nix
      ];
    };
  };
}
```

### 3. Enable frontend tools

```nix
# home.nix
{
  programs.frontend-tools.enable = true;
}
```

## What's Included

When you enable frontend tools, you get:

- **ni** - Use the right package manager automatically
- **pnpm** - Fast, disk space efficient package manager
- **bun** - All-in-one JavaScript runtime & toolkit

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable frontend development tools |

## About ni

The `ni` tool by [@antfu](https://github.com/antfu/ni) automatically detects which package manager your project uses:

- `ni` - Install dependencies (auto-detects npm/yarn/pnpm/bun)
- `nr` - Run scripts
- `nx` - Execute binaries
- `nu` - Update dependencies
- `nun` - Uninstall dependencies
- `nci` - Clean install
- `na` - Add dependencies
