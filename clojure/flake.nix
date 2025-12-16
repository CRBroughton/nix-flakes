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
          pkgs.clojure # The Clojure CLI tools (`clj`)
          pkgs.jdk25_headless # Java Development Kit 25 (headless)
        ];

        envPackage = pkgs.buildEnv {
          name = "clojure-dev";
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
