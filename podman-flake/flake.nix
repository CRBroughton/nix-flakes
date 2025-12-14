{
  description = "Podman container runtime with Docker compatibility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.podman;
          podman = pkgs.podman;
          podman-compose = pkgs.podman-compose;
        };
      }
    )
    // {
      # Export Home Manager module at the top level
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          options.programs.podman-config = {
            enable = lib.mkEnableOption "Podman with Docker compatibility setup";

            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.podman;
              description = "The podman package to use";
            };

            enableDockerCompat = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable Docker socket compatibility for tools like lazydocker";
            };

            registries = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ "docker.io" ];
              description = "Unqualified search registries for short container names";
            };

            enableSystemdService = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable Podman API systemd socket and service";
            };

            enableLazydocker = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable lazydocker with podman-compose configuration";
            };
          };

          config = lib.mkIf config.programs.podman-config.enable {
            # Install podman and related tools
            home.packages = [
              config.programs.podman-config.package
              pkgs.podman-compose
            ] ++ lib.optionals config.programs.podman-config.enableLazydocker [
              pkgs.lazydocker
            ];

            # Podman container registries configuration
            # This allows using short names like "hello-world" instead of "docker.io/library/hello-world"
            home.file.".config/containers/registries.conf".text = ''
              unqualified-search-registries = [${
                lib.concatMapStringsSep ", " (reg: ''"${reg}"'') config.programs.podman-config.registries
              }]
              short-name-mode = "enforcing"
            '';

            # Container image trust policy
            # Matches Fedora's default policy - accepts images without signature verification
            home.file.".config/containers/policy.json".text = builtins.toJSON {
              default = [
                {
                  type = "insecureAcceptAnything";
                }
              ];
              transports = {
                docker-daemon = {
                  "" = [
                    {
                      type = "insecureAcceptAnything";
                    }
                  ];
                };
              };
            };

            # Set up environment variable for Docker compatibility with Podman
            home.sessionVariables = lib.mkIf config.programs.podman-config.enableDockerCompat {
              DOCKER_HOST = "unix:///run/user/$UID/podman/podman.sock";
            };

            # Also set DOCKER_HOST in shell profiles for immediate availability
            programs.bash.sessionVariables = lib.mkIf config.programs.podman-config.enableDockerCompat {
              DOCKER_HOST = "unix:///run/user/$UID/podman/podman.sock";
            };

            programs.zsh.sessionVariables = lib.mkIf config.programs.podman-config.enableDockerCompat {
              DOCKER_HOST = "unix:///run/user/$UID/podman/podman.sock";
            };

            programs.fish.shellInit = lib.mkIf config.programs.podman-config.enableDockerCompat ''
              set -gx DOCKER_HOST "unix:///run/user/$UID/podman/podman.sock"
            '';

            # Configure lazydocker to use podman-compose
            home.file.".config/lazydocker/config.yml" = lib.mkIf config.programs.podman-config.enableLazydocker {
              text = ''
                gui:
                  theme:
                    activeBorderColor:
                      - yellow
                      - bold
                    optionsTextColor:
                      - yellow
                      - bold
                  sidePanelWidth: 0.33
                commandTemplates:
                  dockerCompose: podman-compose
              '';
            };

            # Create systemd socket and service for Podman API
            # This works on all systems, whether Podman is from Nix or system packages
            systemd.user.sockets.podman = lib.mkIf config.programs.podman-config.enableSystemdService {
              Unit = {
                Description = "Podman API Socket";
                Documentation = "man:podman-system-service(1)";
              };
              Socket = {
                ListenStream = "%t/podman/podman.sock";
                SocketMode = "0660";
              };
              Install = {
                WantedBy = [ "sockets.target" ];
              };
            };

            systemd.user.services.podman = lib.mkIf config.programs.podman-config.enableSystemdService {
              Unit = {
                Description = "Podman API Service";
                Documentation = "man:podman-system-service(1)";
                Requires = "podman.socket";
                After = "podman.socket";
              };
              Service = {
                Type = "exec";
                KillMode = "process";
                Environment = "LOGGING=--log-level=info";
                ExecStart = "${config.programs.podman-config.package}/bin/podman $LOGGING system service";
                Restart = "on-failure";
              };
              Install = {
                WantedBy = [ "default.target" ];
              };
            };
          };
        };
    };
}
