# Fish Shell Environment

A Nix flake providing a Fish shell environment with Starship, Zoxide, and modern CLI tools via Home Manager.

## Features

- **Fish shell** - Friendly interactive shell with great defaults
- **Starship** - Fast, customisable prompt
- **Zoxide** - Smarter cd command that learns your habits
- **bat** - Better cat with syntax highlighting
- **eza** - Better ls with colours and git integration
- **btop** - System monitor
- Custom Fish functions and completions support

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    fish-shell.url = "github:yourusername/nix-flakes?dir=fish-shell";
    # or local:
    # fish-shell.url = "path:/home/craig/code/nix-flakes/fish-shell";
  };
}
```

### 2. Import the Home Manager module

```nix
{
  outputs = { self, nixpkgs, home-manager, fish-shell, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      modules = [
        fish-shell.homeManagerModules.default
        ./home.nix
      ];
    };
  };
}
```

### 3. Configure Fish shell

```nix
programs.fish-shell = {
  enable = true;
};
```

### 4. Set Fish as your default shell (optional)

```bash
chsh -s $(which fish)
```

## Examples

### Minimal Setup

```nix
programs.fish-shell = {
  enable = true;
};
```

### Custom Aliases

```nix
programs.fish-shell = {
  enable = true;
  shellAliases = {
    cat = "bat";
    ls = "eza";
    g = "git";
    vim = "nvim";
  };
};
```

### Custom Fish Init

```nix
programs.fish-shell = {
  enable = true;
  fishInitExtra = ''
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx PATH "$HOME/.local/bin" $PATH
  '';
};
```

### Custom Starship Config

```nix
programs.fish-shell = {
  enable = true;
  starshipConfig = {
    add_newline = false;
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold red)";
    };
  };
};
```

### Custom Fish Functions

```nix
programs.fish-shell = {
  enable = true;
  fishFunctions = {
    mkcd = {
      description = "Create directory and cd into it";
      body = ''
        mkdir -p $argv[1]
        cd $argv[1]
      '';
    };
  };
};
```

### Custom Completions

```nix
programs.fish-shell = {
  enable = true;
  fishFiles = {
    "completions/myapp.fish" = ''
      complete -c myapp -f -a "(myapp --list-commands)"
    '';
  };
};
```

### Disable Specific Tools

```nix
programs.fish-shell = {
  enable = true;
  enableBat = false;  # Don't install bat
  enableBtop = false; # Don't install btop
};
```

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable Fish shell environment |
| `enableFish` | boolean | `true` | Enable Fish shell |
| `enableStarship` | boolean | `true` | Enable Starship prompt |
| `enableZoxide` | boolean | `true` | Enable Zoxide (smarter cd) |
| `enableBat` | boolean | `true` | Enable bat (better cat) |
| `enableEza` | boolean | `true` | Enable eza (better ls) |
| `enableBtop` | boolean | `true` | Enable btop (system monitor) |
| `shellAliases` | attribute set | `{ cat = "bat"; ls = "eza"; }` | Shell aliases to set |
| `fishInitExtra` | lines | `""` | Extra Fish shell initialisation code |
| `fishFunctions` | attribute set | `{}` | Custom Fish functions |
| `fishFiles` | attribute set | `{}` | Additional Fish configuration files |
| `starshipConfig` | attribute set | `{}` | Starship configuration |
| `extraPackages` | list of packages | `[]` | Additional packages to include |

## Tool Quick Reference

| Old Tool | Modern Alternative | What it does |
|----------|-------------------|--------------|
| `cat`    | `bat`            | View files with syntax highlighting |
| `ls`     | `eza`            | List files with colours and icons |
| `cd`     | `z`              | Jump to directories intelligently |
| `top`    | `btop`           | Monitor system resources |

## Tips

- **zoxide**: After visiting directories, use `z partial-name` to jump to them
- **bat**: Use `bat --style=plain` for plain output (good for pipes)
- **eza**: Try `eza -l --git` to see git status in file listings

## Version

Current version: 0.0.1

## Licence

This flake follows the same licence as your nix-flakes repository.
