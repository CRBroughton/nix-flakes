# Custom Keyboard Layouts for Nix

A Nix flake that provides a **simple, declarative way** to install custom XKB keyboard layouts on Linux with Home Manager.

## Features

- Fully declarative keyboard layout management
- Automatic evdev.xml generation (no manual XML editing)
- Bring your own layouts or use the examples
- Type-safe configuration with helpful error messages

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    keyboard-layouts = {
      url = "github:crbroughton/nix-flakes?dir=keyboard-layouts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Import the Home Manager module

```nix
outputs = { nixpkgs, home-manager, keyboard-layouts, ... }: {
  homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
    modules = [
      keyboard-layouts.homeManagerModules.default
      ./home.nix
    ];
  };
};
```

### 3. Configure your layouts

```nix
# home.nix or modules/keyboard.nix
{
  programs.keyboard-layouts = {
    enable = true;

    # Define your custom layouts
    layouts = [
      {
        symbolsFile = ./layouts/graphite;  # Path to your XKB symbols file
        name = "graphite";                  # Internal ID for XKB
        description = "English (Graphite)"; # Shows in desktop settings
        shortDescription = "Graphite";      # Short name (optional)
        languages = [ "eng" ];              # ISO 639 language codes (optional)
      }
      {
        symbolsFile = ./layouts/colemak_dh;
        name = "colemak_dh";
        description = "English (Colemak Mod-DH)";
        shortDescription = "Colemak-DH";
      }
    ];

    # Include standard layouts (optional)
    standardLayouts = [ "us" "gb" ];

    # XKB options (optional)
    xkbOptions = [
      "terminate:ctrl_alt_bksp"  # Ctrl+Alt+Backspace to kill X
      "caps:escape"              # Map Caps Lock to Escape
    ];
  };
}
```

### 4. Apply configuration

```bash
home-manager switch
```

See [examples/](examples/) for more detailed guides and XKB key code references.

## Examples

### Minimal Setup (Single Layout)
```nix
programs.keyboard-layouts = {
  enable = true;
  layouts = [
    {
      symbolsFile = ./layouts/graphite;
      name = "graphite";
      description = "English (Graphite)";
    }
  ];
};
```

### Multiple Layouts with Options
```nix
programs.keyboard-layouts = {
  enable = true;

  layouts = [
    {
      symbolsFile = ./layouts/graphite;
      name = "graphite";
      description = "English (Graphite)";
      shortDescription = "Graphite";
    }
    {
      symbolsFile = ./layouts/colemak_dh;
      name = "colemak_dh";
      description = "English (Colemak Mod-DH)";
      shortDescription = "Colemak-DH";
    }
  ];

  standardLayouts = [ "us" "gb" ];

  xkbOptions = [
    "terminate:ctrl_alt_bksp"
    "caps:escape"
    "compose:ralt"
  ];
};
```

### With Pre-made Layouts from Examples
```nix
programs.keyboard-layouts = {
  enable = true;

  # Use the example layouts included in the flake
  layouts = [
    {
      symbolsFile = "${inputs.keyboard-layouts}/xkb/graphite";
      name = "graphite";
      description = "English (Graphite)";
      shortDescription = "Graphite";
    }
    {
      symbolsFile = "${inputs.keyboard-layouts}/xkb/canary";
      name = "canary";
      description = "English (Canary)";
      shortDescription = "Canary";
    }
  ];
};
```

## Troubleshooting

### Layouts don't appear in GNOME Settings

1. Make sure you've logged out and logged back in after running `home-manager switch`
2. Check that the XKB files are installed:
   ```bash
   ls ~/.config/xkb/symbols/
   ```
3. Verify dconf settings:
   ```bash
   dconf read /org/gnome/desktop/input-sources/sources
   ```

### Layout switching not working

Try resetting GNOME Shell:
```bash
# On X11
killall -3 gnome-shell

# On Wayland
# Log out and log back in
```