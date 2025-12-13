# Podman Flake

A reusable Nix flake for installing and configuring Podman with Docker compatibility.

## Features

- Installs Podman and podman-compose
- Configures container registries for short names (e.g., `podman run hello-world`)
- Sets up Docker socket compatibility via systemd
- Configurable trust policies for container images

## Usage

### In your flake.nix

Add this flake as an input:

```nix
{
  inputs = {
    podman-flake.url = "path:/home/craig/nix-configuration/podman-flake";
    # Or if hosted on GitHub:
    # podman-flake.url = "github:yourusername/podman-flake";
  };

  outputs = { self, nixpkgs, home-manager, podman-flake, ... }: {
    homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
      # ... your config
      modules = [
        podman-flake.homeManagerModules.default
        {
          programs.podman-config = {
            enable = true;
          };
        }
      ];
    };
  };
}
```

### Configuration Options

```nix
programs.podman-config = {
  enable = true;  # Enable podman configuration

  package = pkgs.podman;  # Override podman package if needed

  enableDockerCompat = true;  # Enable Docker socket compatibility

  registries = [ "docker.io" ];  # Container registries for short names

  enableSystemdService = true;  # Enable Podman API systemd service
};
```

### With lazydocker

This flake works great with lazydocker. Just configure lazydocker to use podman-compose:

```yaml
# ~/.config/lazydocker/config.yml
commandTemplates:
  dockerCompose: podman-compose
```

## What it configures

1. **Container Registries** (`~/.config/containers/registries.conf`)
   - Allows using short names for containers
   - Default: searches docker.io

2. **Trust Policy** (`~/.config/containers/policy.json`)
   - Accepts container images without signature verification
   - Matches Fedora's default policy

3. **Docker Socket Compatibility**
   - Sets `DOCKER_HOST` environment variable
   - Creates systemd socket at `/run/user/$UID/podman/podman.sock`
   - Allows Docker-compatible tools to work with Podman

4. **Systemd Service**
   - Automatically starts Podman API service
   - Socket-activated for efficiency

## Testing

After installation, test with:

```bash
# Test podman
podman run hello-world

# Test Docker socket compatibility
docker ps  # Should work if Docker CLI uses DOCKER_HOST

# Check systemd service
systemctl --user status podman.socket
systemctl --user status podman.service
```
