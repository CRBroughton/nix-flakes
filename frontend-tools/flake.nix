{
  description = "Frontend development tools (ni, pnpm, bun)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        frontendTools = [
          pkgs.nodePackages.pnpm
          pkgs.bun
          pkgs.ni
        ];

        frontendEnvPackage = pkgs.buildEnv {
          name = "frontend-dev-env";
          paths = frontendTools;
        };

      in
      {
        packages.default = frontendEnvPackage;

        devShells.default = pkgs.mkShell {
          buildInputs = frontendTools;
        };

      }
    )

    // {
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
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
              self.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];

            home.activation.frontendInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "Frontend development environment enabled."
            '';
          };
        };
    };
}
