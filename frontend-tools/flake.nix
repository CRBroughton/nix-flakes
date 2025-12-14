{
  description = "Frontend development tools (ni, pnpm, bun)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      frontendTools = [
        pkgs.nodePackages.pnpm
        pkgs.bun
        pkgs.ni
      ];
    in {
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.frontend-tools;
        in {
          options.programs.frontend-tools = {
            enable = mkEnableOption "Frontend development tools";
          };

          config = mkIf cfg.enable {
            home.packages = frontendTools;

            # Reuse the same message for Home Manager activation
            home.activation.packagesInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "${startupMessage}"
            '';
          };
        };

      # Optionally define the defaultPackage - used for building
      defaultPackage = pkgs.mkShell {
        buildInputs = frontendTools;
      };

      # Define the devShell for the current system - nix develop
      devShell = pkgs.mkShell {
        buildInputs = frontendTools;
      };
    });
}
