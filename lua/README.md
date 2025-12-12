# Lua Development Environment for Nix

A Nix flake that provides a **simple, declarative way** to manage Lua development environments with packages and tools via Home Manager.

## Features

- Fully declarative Lua package management
- Pre-configured essential Lua packages (cjson, luafilesystem, luasocket, luasec, penlight, inspect)
- Optional LÖVE 2D game engine support
- Optional testing tools (busted, luasec)
- LSP support via lua-language-server
- Easy addition of extra Lua packages

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

### 3. Configure Lua environment

```nix
# home.nix or modules/lua.nix
{
  programs.lua = {
    enable = true;
    enableLove = true;      # Enable LÖVE 2D game engine
    enableTesting = true;   # Enable busted and luasec for testing
    enableLanguageServer = true;  # Enable lua-language-server (default: true)

    # Add extra Lua packages
    extraPackages = [ "lpeg" "lgi" ];
  };
}
```

### 4. Apply configuration

```bash
home-manager switch
```

## Default Packages

When Lua is enabled, the following packages are included by default:

- **cjson** - JSON support for Lua
- **luafilesystem** - File system operations
- **luasocket** - Network support
- **luasec** - SSL/TLS support
- **penlight** - Comprehensive Lua utilities library
- **inspect** - Human-readable representation of tables

## Examples

### Minimal Setup (Default Packages Only)
```nix
{
  programs.lua = {
    enable = true;
  };
}
```

### Game Development with LÖVE
```nix
{
  programs.lua = {
    enable = true;
    enableLove = true;  # Includes LÖVE 2D game engine
  };
}
```

### Testing and Development
```nix
{
  programs.lua = {
    enable = true;
    enableTesting = true;  # Includes busted for testing
    enableLanguageServer = true;  # LSP support
  };
}
```

### Complete Configuration
```nix
{
  programs.lua = {
    enable = true;
    enableLove = true;
    enableTesting = true;
    enableLanguageServer = true;

    # Additional packages for specific needs
    extraPackages = [
      "lpeg"      # Pattern matching
      "lgi"       # GObject introspection
      "luaposix"  # POSIX bindings
    ];
  };
}
```

### Without Language Server
```nix
{
  programs.lua = {
    enable = true;
    enableLanguageServer = false;  # Disable LSP if not needed
    extraPackages = [ "lpeg" ];
  };
}
```

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable Lua development environment |
| `enableLove` | boolean | `false` | Enable LÖVE 2D game engine |
| `enableTesting` | boolean | `false` | Enable testing tools (busted, luasec) |
| `enableLanguageServer` | boolean | `true` | Enable lua-language-server for LSP |
| `extraPackages` | list of strings | `[]` | Additional Lua package names to include |

## Troubleshooting

### Package not found

If you get an error about a package not being found in `extraPackages`, verify the package name exists in nixpkgs:

```bash
nix-env -qaP -A nixpkgs.luaPackages | grep <package-name>
```

### LSP not working

1. Ensure your editor is configured to use lua-language-server
2. Verify the language server is installed:
   ```bash
   which lua-language-server
   ```
3. Check your editor's LSP configuration points to the correct binary

### LÖVE games not running

Make sure you've enabled LÖVE support:
```nix
programs.lua.enableLove = true;
```

Then run LÖVE games with:
```bash
love /path/to/game
```
