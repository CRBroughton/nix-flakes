# LuaJIT Development Environment for Nix

A Nix flake that provides a **zero-config LuaJIT development environment** with essential packages and tools via Home Manager.

## Features

- Zero configuration required
- Essential LuaJIT packages included (cjson, luafilesystem, luasocket, penlight, inspect, busted)
- LSP support via lua-language-server
- VSCode extension support (Lua language server)

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    luajit-dev = {
      url = "github:crbroughton/nix-flakes?dir=luajit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Import the Home Manager module

```nix
outputs = { nixpkgs, home-manager, luajit-dev, ... }: {
  homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
    modules = [
      luajit-dev.homeManagerModules.default
      ./home.nix
    ];
  };
};
```

### 3. Enable LuaJIT environment

```nix
# home.nix
{
  programs.luajit.enable = true;
}
```

### 4. Apply configuration

```bash
home-manager switch
```

## What's Included

When you enable the LuaJIT environment, you get:

### LuaJIT Packages
- **cjson** - JSON support for LuaJIT
- **luafilesystem** - File system operations
- **luasocket** - Network support
- **penlight** - Comprehensive Lua utilities library
- **inspect** - Human-readable representation of tables
- **busted** - Testing framework

### Tools
- **lua-language-server** - LSP for Lua/LuaJIT
- **VSCode Lua extension** - sumneko.lua

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable LuaJIT development environment |
