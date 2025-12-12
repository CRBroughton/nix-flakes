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

          # Default packages that are always included when Lua is enabled
          defaultPackages = ps: [
            ps.cjson
            ps.luafilesystem
            ps.luasocket
            ps.luasec
            ps.penlight
            ps.inspect
          ];

          # Additional packages based on enabled features
          lovePackages = ps: optionals cfg.enableLove [ ps.love ];
          testingPackages = ps: optionals cfg.enableTesting [
            ps.busted
            ps.luasec
          ];

          # Extra packages specified by the user
          extraPackages = ps: map (name: ps.${name}) cfg.extraPackages;

          # Combine all packages
          allLuaPackages = ps:
            defaultPackages ps
            ++ lovePackages ps
            ++ testingPackages ps
            ++ extraPackages ps;

        in
        {
          options.programs.lua = {
            enable = mkEnableOption "Lua development environment";

            enableLove = mkOption {
              type = types.bool;
              default = false;
              description = "Enable LÖVE 2D game engine";
            };

            enableTesting = mkOption {
              type = types.bool;
              default = false;
              description = "Enable testing tools (busted and luasec)";
            };

            extraPackages = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Additional Lua package names to include";
              example = [ "lgi" "lpeg" ];
            };

            enableLanguageServer = mkOption {
              type = types.bool;
              default = true;
              description = "Enable lua-language-server for LSP support";
            };
          };

          config = mkIf cfg.enable {
            home.packages = [
              (pkgs.lua.withPackages allLuaPackages)
            ] ++ optionals cfg.enableLanguageServer [
              pkgs.lua-language-server
            ];

            # Helpful activation message
            home.activation.luaInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
              echo "Lua development environment installed with:"
              echo "  - Default packages: cjson, luafilesystem, luasocket, luasec, penlight, inspect"
              ${optionalString cfg.enableLove ''echo "  - LÖVE 2D game engine"''}
              ${optionalString cfg.enableTesting ''echo "  - Testing tools: busted, luasec"''}
              ${optionalString (cfg.extraPackages != []) ''echo "  - Extra packages: ${concatStringsSep ", " cfg.extraPackages}"''}
              ${optionalString cfg.enableLanguageServer ''echo "  - lua-language-server (LSP)"''}
            '';
          };
        };
    };
}
