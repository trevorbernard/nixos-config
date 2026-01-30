# NixOS Configuration - knowhere

Flake-based NixOS configuration for the `knowhere` machine.

## Building

To build and activate the configuration:

```bash
sudo nixos-rebuild switch --flake .#knowhere
```

## Other Operations

Test the configuration without activating:
```bash
sudo nixos-rebuild test --flake .#knowhere
```

Build without activating:
```bash
sudo nixos-rebuild build --flake .#knowhere
```

Boot into the new configuration on next reboot:
```bash
sudo nixos-rebuild boot --flake .#knowhere
```

## Updating Dependencies

Update all flake inputs:
```bash
nix flake update
```

Update specific input:
```bash
nix flake update nixpkgs
nix flake update ghostty
```

### Updating Ghostty to a New Release

Ghostty is pinned to a specific version tag (currently `v1.2.3`) in `flake.nix`. To update to a new release:

1. Check available releases at https://github.com/ghostty-org/ghostty/releases

2. Update the version in `flake.nix`:
```nix
ghostty.url = "github:ghostty-org/ghostty/v1.3.0";  # Change to desired version
```

3. Update the lock file:
```bash
nix flake update ghostty
```

4. Verify the configuration:
```bash
nix flake check
```

5. Rebuild to use the new version:
```bash
sudo nixos-rebuild switch --flake .#knowhere
```

## Verifying Configuration

Check flake configuration validity:
```bash
nix flake check
```

Show flake metadata:
```bash
nix flake show
```

Show flake outputs:
```bash
nix flake metadata
```

## Structure

- `flake.nix` - Flake definition with inputs and outputs
- `flake.lock` - Locked dependency versions
- `configuration.nix` - Main system configuration
- `hardware-configuration.nix` - Hardware-specific settings
- `hardware/` - Additional hardware configurations
- `buildkite/` - Buildkite agent configuration
- `nix/` - Custom package definitions
  - `claude-code/` - Claude Code package

## Custom Packages

This configuration includes custom packages via overlays:
- **claude-code** - AI coding assistant (local package in `nix/`)
- **termcopy** - Terminal clipboard utility (external flake)
- **ghostty** - Terminal emulator (external flake)
