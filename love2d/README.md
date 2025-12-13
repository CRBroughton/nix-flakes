# LÖVE 2D Game Engine for Nix

A Nix flake that provides a **zero-config LÖVE 2D development environment** via Home Manager.

## Features

- Zero configuration required
- LÖVE 2D game engine
- VSCode extension support

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    love2d = {
      url = "github:crbroughton/nix-flakes?dir=love2d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Import the Home Manager module

```nix
outputs = { nixpkgs, home-manager, love2d, ... }: {
  homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
    modules = [
      love2d.homeManagerModules.default
      ./home.nix
    ];
  };
};
```

### 3. Enable LÖVE 2D environment

```nix
# home.nix
{
  programs.love2d.enable = true;
}
```

### 4. Apply configuration

```bash
home-manager switch
```

## What's Included

When you enable LÖVE 2D, you get:

- **LÖVE 2D game engine** - Framework for making 2D games
- **VSCode LÖVE extension** - bschulte.love

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable LÖVE 2D development environment |

## Usage

Run LÖVE games with:
```bash
love /path/to/game
```
