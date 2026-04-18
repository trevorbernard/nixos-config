# NixOS Configuration

Personal NixOS/nix-darwin configuration managing multiple machines.

## Machines

- **knowhere** - NixOS desktop (x86_64-linux) with NVIDIA GPU, GNOME/Wayland
- **aypa** - macOS (aarch64-darwin) using nix-darwin
- **macbook** - macOS (aarch64-darwin) using nix-darwin

## Build Commands

All commands run from the repo root.

```bash
# build only
sudo nixos-rebuild build --flake '.#knowhere'
darwin-rebuild build --flake '.#aypa'

# build and activate
sudo nixos-rebuild switch --flake '.#knowhere'
darwin-rebuild switch --flake '.#aypa'
darwin-rebuild switch --flake '.#macbook'
```

## Structure

```
├── flake.nix              # single root flake for all hosts
├── hosts/
│   ├── knowhere/          # NixOS desktop
│   │   ├── default.nix
│   │   └── hardware/      # hardware-configuration.nix, truerng.nix
│   ├── aypa/              # macOS work machine
│   │   └── default.nix
│   └── macbook/           # macOS personal machine
│       └── default.nix
└── modules/
    └── shared/
        ├── nix.nix        # nix daemon settings, substituters
        └── packages.nix   # CLI packages present on every machine
```

## License

MIT
