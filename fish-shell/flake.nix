{
  description = "Fish shell environment with Starship, Zoxide, bat, eza, and btop";

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
            enable = mkEnableOption "Fish shell environment with modern CLI tools";
          };

          config = mkIf cfg.enable {
            # Fish shell
            programs.fish.enable = true;

            # Starship prompt
            programs.starship = {
              enable = true;
              enableFishIntegration = true;
            };

            # Zoxide (smarter cd)
            programs.zoxide = {
              enable = true;
              enableFishIntegration = true;
            };

            # CLI tools
            home.packages = [
              pkgs.bat    # Better cat
              pkgs.eza    # Better ls
              pkgs.btop   # System monitor
            ];

            # Helpful activation message
            home.activation.fishShellInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "Fish shell environment installed with:"
              echo "  - Fish shell"
              echo "  - Starship prompt"
              echo "  - Zoxide (smart cd)"
              echo "  - bat (better cat)"
              echo "  - eza (better ls)"
              echo "  - btop (system monitor)"
              echo ""
              echo "To set Fish as your default shell, run:"
              echo "  chsh -s \$(which fish)"
            '';
          };
        };
    };
}