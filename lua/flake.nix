{
  description = "Lua development environment with packages and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.lua;
        in
        {
          options.programs.lua = {
            enable = mkEnableOption "Lua development environment";
          };

          config = mkIf cfg.enable {
            home.packages = [
              (pkgs.lua.withPackages (ps: [
                ps.cjson
                ps.luafilesystem
                ps.luasocket
                ps.luasec
                ps.penlight
                ps.inspect
                ps.busted
              ]))
              pkgs.lua-language-server
            ];

            programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
              sumneko.lua
            ];

            # Helpful activation message
            home.activation.luaInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "Lua development environment installed with:"
              echo "  - Packages: cjson, luafilesystem, luasocket, luasec, penlight, inspect, busted"
              echo "  - lua-language-server (LSP)"
              echo "  - VSCode extension: Lua"
            '';
          };
        };
    };
}
