# Lua Development Environment for Nix

A Nix flake that provides a **zero-config Lua development environment** with essential packages and tools via Home Manager.

## Features

- Zero configuration required
- Essential Lua packages included (cjson, luafilesystem, luasocket, luasec, penlight, inspect, busted)
- LSP support via lua-language-server
- VSCode extension support (Lua language server)

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    lua-dev = {
      url = "github:crbroughton/nix-flakes?dir=lua";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Import the Home Manager module

```nix
outputs = { nixpkgs, home-manager, lua-dev, ... }: {
  homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
    modules = [
      lua-dev.homeManagerModules.default
      ./home.nix
    ];
  };
};
```

### 3. Enable Lua environment

```nix
# home.nix
{
  programs.lua.enable = true;
}
```

### 4. Apply configuration

```bash
home-manager switch
```

## What's Included

When you enable the Lua environment, you get:

### Lua Packages
- **cjson** - JSON support for Lua
- **luafilesystem** - File system operations
- **luasocket** - Network support
- **luasec** - SSL/TLS support
- **penlight** - Comprehensive Lua utilities library
- **inspect** - Human-readable representation of tables
- **busted** - Testing framework

### Tools
- **lua-language-server** - LSP for Lua
- **VSCode Lua extension** - sumneko.lua

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable Lua development environment |
