{
  description = "LÖVE 2D game engine development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.love2d;
        in
        {
          options.programs.love2d = {
            enable = mkEnableOption "LÖVE 2D game engine development environment";
          };

          config = mkIf cfg.enable {
            home.packages = [
              (pkgs.lua.withPackages (ps: [ ps.love ]))
            ];

            programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
              bschulte.love
            ];

            # Helpful activation message
            home.activation.love2dInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "LÖVE 2D development environment installed with:"
              echo "  - LÖVE 2D game engine"
              echo "  - VSCode extension: LÖVE"
            '';
          };
        };
    };
}
