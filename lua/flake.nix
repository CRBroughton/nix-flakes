{
  description = "Lua development environment with packages and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Define Lua packages to be included in the environment
      luaPackages = pkgs.lua.withPackages (ps: [
        ps.cjson
        ps.luafilesystem
        ps.luasocket
        ps.luasec
        ps.penlight
        ps.inspect
        ps.busted
      ]);
      
    in {
      # Home Manager module for Lua setup
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.lua;
        in {
          options.programs.lua = {
            enable = mkEnableOption "Lua development environment";
          };

          config = mkIf cfg.enable {
            home.packages = [
              luaPackages
              pkgs.lua-language-server
            ];

            programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
              sumneko.lua
            ];

            # Helpful activation message
            home.activation.luaInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "${startupMessage}"
            '';
          };
        };

      # Optionally define the defaultPackage - used for building
      defaultPackage = pkgs.mkShell {
        buildInputs = [
          luaPackages
          pkgs.lua-language-server
        ];
      };

      # Define the devShell for the current system - nix develop
      devShell = pkgs.mkShell {
        buildInputs = [
          luaPackages
          pkgs.lua-language-server
        ];
      };
    });
}
