# NixOS Configuration

Personal NixOS/nix-darwin configuration managing multiple machines from a single
flake.

## Machines

- **knowhere** — NixOS desktop (x86_64-linux) with NVIDIA GPU, GNOME/Wayland
- **aypa** — macOS (aarch64-darwin) work machine, using nix-darwin
- **macbook** — macOS (aarch64-darwin) personal machine, using nix-darwin

> **Note:** `macbook` runs [Determinate Nix](https://docs.determinate.systems/),
> which owns the Nix daemon. Its config sets `nix.enable = false` so nix-darwin
> doesn't manage Nix on that host.

## Build Commands

All commands run from the repo root.

```bash
# build only
sudo nixos-rebuild build --flake '.#knowhere'
darwin-rebuild build --flake '.#aypa'
darwin-rebuild build --flake '.#macbook'

# build and activate
sudo nixos-rebuild switch --flake '.#knowhere'
darwin-rebuild switch --flake '.#aypa'
darwin-rebuild switch --flake '.#macbook'

# build a custom package standalone (darwin only)
nix build '.#pencil-cli'
nix build '.#sonarqube-cli'

# format the tree
nix fmt
```

## Structure

```
├── flake.nix                  # single root flake; defines all hosts + packages
├── hosts/
│   ├── knowhere/              # NixOS desktop
│   │   ├── default.nix        # imports, bootloader, hostname, locale
│   │   ├── audio.nix          # PipeWire
│   │   ├── desktop.nix        # GNOME/Wayland, NVIDIA, fonts, dconf
│   │   ├── git-server.nix     # git-shell user, Tailscale-only SSH access
│   │   ├── networking.nix     # NetworkManager, Tailscale, Syncthing, firewall
│   │   ├── packages.nix       # host system packages + unfree allowlist
│   │   ├── services.nix       # ssh, docker, printing, gnupg, sleep targets
│   │   ├── users.nix          # tbernard user, shell, sudo rules
│   │   └── hardware/          # hardware-configuration.nix, truerng.nix
│   ├── aypa/                  # macOS work machine
│   │   └── default.nix
│   └── macbook/               # macOS personal machine (Determinate Nix)
│       └── default.nix
├── modules/
│   ├── darwin/
│   │   └── default.nix        # shared nix-darwin base (homebrew, user, fonts)
│   └── shared/
│       ├── nix.nix            # nix daemon settings, substituters, gc/optimise
│       ├── packages.nix       # CLI packages present on every machine
│       ├── unfree.nix         # my.unfreePackages option + allowUnfree predicate
│       └── fonts.nix          # fonts shared across hosts
└── pkgs/
    ├── pencil-cli/            # Pencil AI design-file CLI (npm, darwin)
    └── sonarqube-cli/         # SonarQube CLI (prebuilt binary, darwin)
```

## Unfree packages

Unfree packages are gated per-host rather than via a blanket `allowUnfree`.
`modules/shared/unfree.nix` exposes a `my.unfreePackages` list option (seeded with
a shared base) and builds the `allowUnfreePredicate` once; each host appends its
own package names, and the module system merges the lists.

## License

MIT
