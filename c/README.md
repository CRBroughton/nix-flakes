# Modern C Development Environment

A comprehensive Nix flake for modern C development with industry-standard tools.

## Features

This environment includes:

### Compiler & Standard Library
- **GCC 14**: Latest GNU Compiler Collection
- **glibc**: GNU C Library

### Build Systems
- **GNU Make**: Traditional make-based builds
- **CMake**: Modern cross-platform build system
- **Meson + Ninja**: Fast, user-friendly build system

### Debugging & Profiling
- **GDB**: GNU Debugger
- **LLDB**: LLVM Debugger
- **Valgrind**: Memory debugging and leak detection

### Code Quality
- **clangd**: Language Server Protocol for intelligent code completion
- **clang-format**: Automatic code formatting
- **clang-tidy**: Static analysis and linting
- **cppcheck**: Additional static analysis
- **ccache**: Compiler cache for faster rebuilds

### Development Utilities
- **bear**: Generate `compile_commands.json` for LSP
- **ctags**: Code navigation and indexing
- **pkg-config**: Library configuration helper

## Usage

### As a Development Shell

Enter the development environment:

```bash
nix develop
```

This will drop you into a shell with all tools available.

### As a Home Manager Module

Add this flake to your Home Manager configuration:

1. Add to your flake inputs:
```nix
{
  inputs = {
    c-dev.url = "path:/home/craig/code/nix-flakes/c";
    # or from GitHub:
    # c-dev.url = "github:yourusername/nix-flakes?dir=c";
  };
}
```

2. Import the module:
```nix
{
  imports = [ c-dev.homeManagerModules.default ];

  programs.c-dev.enable = true;
}
```

### As a Direct Package Install

Install the environment to your profile:

```bash
nix profile install .#
```

## Quick Start Example

Create a simple C project:

```bash
# Enter the dev environment
nix develop

# Create a simple program
cat > hello.c << 'EOF'
#include <stdio.h>

int main(void) {
    printf("Hello, Nix!\n");
    return 0;
}
EOF

# Compile
gcc hello.c -o hello

# Run
./hello

# Debug with valgrind
valgrind ./hello

# Format code
clang-format -i hello.c
```

## CMake Example

```bash
# Create CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(MyProject C)

add_executable(myapp main.c)
EOF

# Build
mkdir build && cd build
cmake ..
make

# Generate compile_commands.json for LSP
bear -- make
```

## Meson Example

```bash
# Create meson.build
cat > meson.build << 'EOF'
project('myproject', 'c')
executable('myapp', 'main.c')
EOF

# Build
meson setup build
ninja -C build
```

## VS Code Integration

When using the Home Manager module, the following extensions are automatically configured:
- **clangd**: LSP support for C/C++
- **C/C++ Extension Pack**: IntelliSense and debugging
- **CMake Tools**: CMake project integration

Make sure to generate `compile_commands.json` for best LSP experience:
```bash
bear -- make
# or with CMake:
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
```

## License

This flake configuration is provided as-is for development purposes.
