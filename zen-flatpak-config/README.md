# Zen Browser Flatpak Configuration for Nix

A Nix flake that provides a **simple, declarative way** to configure Zen Browser installed via Flatpak using Home Manager.

## Features

- Fully declarative browser configuration management
- Extension installation from firefox-addons NUR
- Settings and preferences via user.js
- Policy management for extensions and behaviour
- Pinned tabs configuration via SQLite

## Installation

### 1. Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    zen-flatpak-config = {
      url = "github:crbroughton/nix-flakes?dir=zen-flatpak-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 2. Import the Home Manager module

```nix
outputs = { nixpkgs, home-manager, zen-flatpak-config, firefox-addons, ... }: {
  homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
    modules = [
      zen-flatpak-config.homeManagerModules.default
      {
        _module.args = {
          inherit firefox-addons;
        };
      }
      ./home.nix
    ];
  };
};
```

### 3. Configure Zen Browser

```nix
# home.nix or modules/zen-browser.nix
{ pkgs, firefox-addons, ... }:

{
  programs.zen-flatpak = {
    enable = true;
    profile = "default";  # Profile name to configure

    # Install extensions
    extensions = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      ublock-origin
      bitwarden
    ];

    # Browser settings
    settings = {
      "browser.search.suggest.enabled" = false;
      "privacy.donottrackheader.enabled" = true;
      "browser.cache.disk.enable" = true;
    };

    # Configure pinned tabs
    pinsForce = true;  # Remove pins not declared here
    pins = {
      "GitHub" = {
        url = "https://github.com/yourusername";
        isEssential = true;  # Cannot be closed
      };
    };

    # Firefox policies
    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          toolbar_pin = "on";
        };
      };
    };
  };
}
```

### 4. Apply configuration

```bash
home-manager switch
```

## Prerequisites

This module **only configures** Zen Browser - you must install it separately via Flatpak:

```bash
flatpak install flathub app.zen_browser.zen
```

Run Zen Browser at least once to create the profile directory before applying this configuration.

## Examples

### Minimal Setup (Extensions Only)
```nix
{ pkgs, firefox-addons, ... }:

{
  programs.zen-flatpak = {
    enable = true;
    extensions = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      ublock-origin
    ];
  };
}
```

### Privacy-Focused Configuration
```nix
{ pkgs, firefox-addons, ... }:

{
  programs.zen-flatpak = {
    enable = true;

    extensions = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      ublock-origin
      privacy-badger
      https-everywhere
    ];

    settings = {
      "privacy.donottrackheader.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "browser.search.suggest.enabled" = false;
      "dom.security.https_only_mode" = true;
    };
  };
}
```

### Complete Configuration with Pinned Tabs
```nix
{ pkgs, firefox-addons, ... }:

{
  programs.zen-flatpak = {
    enable = true;
    profile = "default";

    extensions = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      ublock-origin
      bitwarden
      multi-account-containers
    ];

    settings = {
      "browser.search.suggest.enabled" = false;
      "privacy.donottrackheader.enabled" = true;
      "browser.cache.disk.enable" = true;
    };

    pinsForce = true;
    pins = {
      "GitHub" = {
        url = "https://github.com";
        isEssential = true;
      };
      "Gmail" = {
        url = "https://mail.google.com";
        isEssential = false;
      };
    };

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          toolbar_pin = "on";
        };
      };
    };
  };
}
```

### Pinned Tabs with Folders
```nix
{ pkgs, firefox-addons, ... }:

{
  programs.zen-flatpak = {
    enable = true;
    profile = "Default (release)";

    extensions = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      ublock-origin
      bitwarden
    ];

    settings = {
      "browser.search.suggest.enabled" = false;
      "privacy.donottrackheader.enabled" = true;
      "browser.cache.disk.enable" = true;
    };

    pinsForce = true;
    pins = {
      "GitHub" = {
        url = "https://github.com/crbroughton";
        isEssential = true;  # Cannot be closed
      };
      "Monkeytype" = {
        url = "https://monkeytype.com";
        isEssential = true;
      };
      # Create a folder for organising pins
      "Social" = {
        url = "";  # Empty URL for folders
        isEssential = false;
        isGroup = true;  # Makes this a folder
      };
      # Pin inside the folder
      "Reddit" = {
        url = "https://reddit.com";
        isEssential = false;
        folderParentUuid = "Social";  # Links to the "Social" folder (must match pin name exactly)
      };
    };

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          toolbar_pin = "on";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          toolbar_pin = "on";
        };
      };
    };
  };
}
```

## Troubleshooting

### Database is locked error

Close Zen Browser completely before running `home-manager switch`. The module needs to modify the SQLite database to configure pinned tabs, which cannot be done while the browser is running.

### Profile not found

1. Verify Zen Browser Flatpak is installed:
   ```bash
   flatpak list | grep zen
   ```
2. Run Zen Browser at least once to create the profile
3. Check the profile directory exists:
   ```bash
   ls ~/.var/app/app.zen_browser.zen/.zen/
   ```

### Extensions not appearing

1. Restart Zen Browser after running `home-manager switch`
2. Verify extension XPI files are in the profile directory:
   ```bash
   ls ~/.var/app/app.zen_browser.zen/.zen/*/extensions/
   ```
3. Check extension IDs match in `policies.ExtensionSettings`