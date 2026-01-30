# NixOS Configuration

Personal NixOS/nix-darwin configuration managing multiple machines.

## Machines

- **knowhere** - NixOS desktop (x86_64-linux) with NVIDIA GPU, GNOME/Wayland
- **aypa** - macOS (aarch64-darwin) using nix-darwin

## Build Commands

### NixOS (knowhere)

```bash
cd knowhere/nixos
sudo nixos-rebuild switch --flake '.#knowhere'
```

### macOS (aypa)

```bash
cd aypa/etc/nix-darwin
darwin-rebuild switch --flake '.#aypa'
```

## Structure

```
├── aypa/etc/nix-darwin/   # macOS nix-darwin flake
├── knowhere/nixos/        # NixOS flake
│   ├── configuration.nix  # Main system configuration
│   ├── hardware/          # Hardware-specific configurations
│   ├── buildkite/         # CI agent setup
│   └── nix/               # Custom package definitions
└── nix-common/            # Shared packages across machines
```

## License

MIT
