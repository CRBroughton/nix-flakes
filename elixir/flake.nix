{
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

        packages = [
          pkgs.beam28Packages.elixir_1_19
          pkgs.beam28Packages.erlang
          pkgs.beam28Packages.erlfmt
        ];

        envPackage = pkgs.buildEnv {
          name = "elixir-dev";
          paths = packages;
        };

      in
      {
        packages.default = envPackage;
        devShell = pkgs.mkShell {
          buildInputs = packages;
        };
      }
    );
}
