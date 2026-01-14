# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal NixOS/nix-darwin configuration managing two machines:
- **knowhere** - NixOS desktop (x86_64-linux) with NVIDIA GPU, GNOME/Wayland
- **aypa** - macOS (aarch64-darwin) using nix-darwin

## Build Commands

### NixOS (knowhere)
```bash
# From knowhere/nixos/
sudo nixos-rebuild switch --flake .#knowhere   # Build and activate
sudo nixos-rebuild test --flake .#knowhere     # Test without activating
sudo nixos-rebuild build --flake .#knowhere    # Build only
nix flake check                                 # Validate configuration
```

### macOS (aypa)
```bash
# From aypa/etc/nix-darwin/
darwin-rebuild switch --flake .#aypa
```

### Updating Dependencies
```bash
nix flake update              # Update all inputs
nix flake update nixpkgs      # Update specific input
nix flake update ghostty      # Update ghostty (pinned to version tag in flake.nix)
```

### Updating Claude Code Package
```bash
# From nix-common/claude-code/
./update.sh    # Fetches latest version, updates package-lock.json and hashes
```

## Architecture

```
├── aypa/etc/nix-darwin/      # macOS nix-darwin flake
│   └── flake.nix             # All config inline, uses Homebrew for GUI apps
├── knowhere/nixos/           # NixOS flake
│   ├── flake.nix             # Defines overlays for custom packages
│   ├── configuration.nix     # Main system config
│   ├── hardware/             # Hardware-specific (truerng, nvidia via configuration.nix)
│   └── buildkite/            # CI agent setup
└── nix-common/               # Shared packages across machines
    └── claude-code/          # Custom npm package derivation
```

## Custom Package Pattern

Packages not in nixpkgs are built locally via overlays. Example in `knowhere/nixos/flake.nix`:
```nix
nixpkgs.overlays = [
  (final: prev: {
    claude-code = prev.callPackage ./nix/claude-code/default.nix {};
  })
];
```

The `nix-common/claude-code/` flake is referenced as a path input by aypa and can be built standalone for both platforms.

## Key Configuration Patterns

- Flakes enabled everywhere (`nix.settings.experimental-features = "nix-command flakes"`)
- User packages in `users.users.tbernard.packages`, system packages in `environment.systemPackages`
- Wayland-first on NixOS with NVIDIA proprietary drivers
- Emacs keybindings enforced system-wide via dconf/GTK settings

## Nix Code Standards

### Formatting
- Use `nixfmt-rfc-style` for formatting (available in system packages)
- 2-space indentation
- Align attribute sets vertically when it improves readability
- Keep lines under 100 characters

### Code Style
- Prefer `let...in` over `with` for attribute access (explicit over implicit)
- Use `lib.mkIf`, `lib.mkMerge`, `lib.optionals` for conditional configuration
- Destructure function arguments: `{ pkgs, lib, config, ... }:` not `args:`
- Use `rec` sparingly—prefer `let` bindings or `self` references in overlays
- Prefer `callPackage` pattern over raw imports for packages

### Module Organization
- One concern per file—split large configurations into focused modules
- Hardware-specific config belongs in `hardware/` or `hardware-configuration.nix`
- Service configurations should be self-contained modules when complex
- Use `imports` to compose, not to share random variables

### Flake Hygiene
- Pin external flakes to tags/releases when stability matters (e.g., `ghostty.url = "github:ghostty-org/ghostty/v1.2.3"`)
- Use `follows` to deduplicate nixpkgs instances across inputs
- Keep `flake.lock` committed—it's the source of reproducibility
- Prefer path inputs for local shared code (`path:../../../nix-common/claude-code`)

### Package Derivations
- Include `meta` with at least `description`, `homepage`, `mainProgram`
- Use `passthru.updateScript` for packages that need regular updates
- Prefer `buildNpmPackage`, `buildPythonPackage`, etc. over raw `stdenv.mkDerivation`
- Use `fetchzip`/`fetchurl` with explicit hashes, never `fetchGit` without `rev`

### Anti-patterns to Avoid
- Multiple `environment.variables` blocks (merge them)
- Hardcoded paths—use `${pkgs.package}` interpolation
- Duplicating package lists between machines—extract to shared modules
- Using `builtins.fetchTarball` without a hash in flakes
- Overusing `lib.mkForce`—restructure modules instead
