{
  description = "Fish shell environment (Fish, Starship, Zoxide, bat, eza, btop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.fish-shell;
        in
        {
          options.programs.fish-shell = {
            enable = mkEnableOption "Fish shell environment";

            fishInitExtra = mkOption {
              type = types.lines;
              default = "";
              description = "Extra Fish shell initialisation code";
            };

            fishFunctions = mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  description = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Function description";
                  };
                  wraps = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Command this function wraps";
                  };
                  body = mkOption {
                    type = types.lines;
                    description = "Function body";
                  };
                };
              });
              default = { };
              description = "Custom Fish functions";
            };

            fishFiles = mkOption {
              type = types.attrsOf types.lines;
              default = { };
              description = "Additional Fish configuration files (relative to ~/.config/fish/)";
            };
          };

          config = mkIf cfg.enable {
            # Fish shell
            programs.fish = mkIf cfg.enableFish {
              enable = true;
              shellAliases = cfg.shellAliases // optionalAttrs cfg.enableZoxide {
                cd = "z";
              };
              shellInit = cfg.fishInitExtra;
              functions = cfg.fishFunctions;
            };

            # Additional Fish configuration files
            home.file = mkIf cfg.enableFish (
              mapAttrs' (name: value: {
                name = ".config/fish/${name}";
                value = { text = value; };
              }) cfg.fishFiles
            );

            # Starship prompt
            programs.starship = mkIf cfg.enableStarship {
              enable = true;
              enableFishIntegration = cfg.enableFish;
              settings = cfg.starshipConfig;
            };

            # Zoxide (smarter cd)
            programs.zoxide = mkIf cfg.enableZoxide {
              enable = true;
              enableFishIntegration = cfg.enableFish;
            };

            # CLI tools
            home.packages = [ ]
              ++ optionals cfg.enableBat [ pkgs.bat ]
              ++ optionals cfg.enableEza [ pkgs.eza ]
              ++ optionals cfg.enableBtop [ pkgs.btop ]
              ++ cfg.extraPackages;

            # Helpful activation message
            home.activation.fishShellInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "Fish shell environment installed:"
              ${optionalString cfg.enableFish ''echo "  - Fish shell"''}
              ${optionalString cfg.enableStarship ''echo "  - Starship prompt"''}
              ${optionalString cfg.enableZoxide ''echo "  - Zoxide (smart cd)"''}
              ${optionalString cfg.enableBat ''echo "  - bat (better cat)"''}
              ${optionalString cfg.enableEza ''echo "  - eza (better ls)"''}
              ${optionalString cfg.enableBtop ''echo "  - btop (system monitor)"''}
              ${optionalString (cfg.extraPackages != []) ''echo "  - ${toString (length cfg.extraPackages)} extra package(s)"''}
              ${optionalString cfg.enableFish ''
                echo ""
                echo "To set Fish as your default shell, run:"
                echo "  chsh -s $(which fish)"
              ''}
            '';
          };
        };
    };
}
