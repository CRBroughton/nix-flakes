# Podman Flake

A reusable Nix flake for installing and configuring Podman with Docker compatibility.

## Features

- Installs Podman and podman-compose
- Installs and configures lazydocker (enabled by default)
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

  enableDockerCompat = true;  # Enable Docker socket compatibility (default: true)

  registries = [ "docker.io" ];  # Container registries for short names

  enableSystemdService = true;  # Enable Podman API systemd service (default: true)

  enableLazydocker = true;  # Install and configure lazydocker (default: true)
};
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

5. **Lazydocker Configuration** (`~/.config/lazydocker/config.yml`)
   - Automatically configures lazydocker to use podman-compose
   - Works seamlessly with Podman containers

## Prerequisites

### On Non-NixOS Systems (Ubuntu, Debian, Raspberry Pi OS, etc.)

Podman requires `newuidmap` and `newgidmap` utilities with setuid permissions for rootless operation. These **must** be installed via your system package manager:

```bash
# Ubuntu/Debian/Raspberry Pi OS
sudo apt install uidmap

# Fedora
sudo dnf install shadow-utils

# Arch
sudo pacman -S shadow
```

**Why?** The Nix-provided versions cannot have the setuid bit set, which is required for user namespace mapping. The system-provided versions have the correct permissions.

### Verify Prerequisites

After installing `uidmap`, verify the setuid bit is set:

```bash
ls -l /usr/bin/newuidmap /usr/bin/newgidmap
```

You should see `-rwsr-xr-x` (note the `s` in the permissions).

## Post-Installation

After running `home-manager switch`, you need to:

1. **Restart your shell** to load the `DOCKER_HOST` environment variable:
   ```bash
   exec $SHELL
   ```
   Or log out and log back in.

2. **Start the podman socket** (if not already running):
   ```bash
   systemctl --user start podman.socket
   ```

## Testing

After installation and restarting your shell, test with:

```bash
# Test podman
podman run hello-world

# Test lazydocker
lazydocker

# Test Docker socket compatibility
docker ps  # Should work if Docker CLI uses DOCKER_HOST

# Check systemd service
systemctl --user status podman.socket
systemctl --user status podman.service
```

## Troubleshooting

### Error: "newuidmap: write to uid_map failed: Operation not permitted"

This means the system `uidmap` package is not installed. Install it:

```bash
sudo apt install uidmap
```

Then verify subuid/subgid mappings exist:

```bash
cat /etc/subuid
cat /etc/subgid
```

You should see entries like:
```
yourusername:100000:65536
```

If these files are empty or missing your user, add them:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
```

### Failed services: podman.socket, podman.service

The services may fail on first activation. Try manually starting them:

```bash
systemctl --user start podman.socket
systemctl --user start podman.service
```

Or restart them after `home-manager switch`:

```bash
systemctl --user daemon-reload
systemctl --user restart podman.socket podman.service
```

### Lazydocker error: "getting the docker.sock. is the docker daemon running?"

This means the Podman socket isn't available to lazydocker. Check these:

1. **Verify the `DOCKER_HOST` environment variable is set:**
   ```bash
   echo $DOCKER_HOST
   ```
   Should output: `unix:///run/user/1000/podman/podman.sock` (or your UID)

   If not set, you can run lazydocker with the environment variable set directly:
   ```bash
   DOCKER_HOST="unix:///run/user/$UID/podman/podman.sock" lazydocker
   ```

   Or restart your shell to load the variable:
   ```bash
   exec $SHELL
   ```

2. **Check if the podman socket exists:**
   ```bash
   ls -l /run/user/$UID/podman/podman.sock
   ```

3. **Verify the systemd socket is running:**
   ```bash
   systemctl --user status podman.socket
   ```

4. **If the socket isn't running, start it:**
   ```bash
   systemctl --user start podman.socket
   systemctl --user enable podman.socket
   ```

5. **Test the socket works:**
   ```bash
   curl --unix-socket /run/user/$UID/podman/podman.sock http://localhost/_ping
   ```
   Should respond with `OK`
