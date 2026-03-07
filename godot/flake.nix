{
  description = "godot game dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Define the packages for the Godot development environment
        devPackages = with pkgs; [
          godot_4
          blender
          krita
          git
          git-lfs
        ];

        # Create an installable environment package
        godotEnvPackage = pkgs.buildEnv {
          name = "godot-dev-env";
          paths = devPackages;
        };

      in {
        # OUTPUT 1: The Installable Package
        packages.default = godotEnvPackage;

        # OUTPUT 2: The Development Shell
        devShells.default = pkgs.mkShell {
          buildInputs = devPackages;

          shellHook = ''
            export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
            export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
            export GDK_BACKEND=wayland
            export QT_QPA_PLATFORM=wayland

            # Aliases for convenience - wrap with nixGL for OpenGL support
            alias godot='nixGL godot4'
            alias blender='nixGL blender'
            alias krita='nixGL krita'

            echo "dev shell ready"
            echo "Run 'godot .' to start Godot Engine with the current project"
            echo "Run 'blender' or 'krita' to start those apps"
          '';
        };
      });
}