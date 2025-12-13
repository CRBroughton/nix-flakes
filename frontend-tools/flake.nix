{
  description = "Frontend development tools (ni, pnpm, bun)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.frontend-tools;
        in
        {
          options.programs.frontend-tools = {
            enable = mkEnableOption "Frontend development tools";
          };

          config = mkIf cfg.enable {
            home.packages = [
              pkgs.nodePackages.pnpm
              pkgs.bun
              pkgs.ni
            ];

            # Helpful activation message
            home.activation.frontendToolsInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "Frontend development tools installed:"
              echo "  - pnpm"
              echo "  - bun"
              echo "  - ni"
            '';
          };
        };
    };
}
