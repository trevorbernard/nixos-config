# NixOS Configuration

Personal NixOS/nix-darwin configuration managing multiple machines from a single
flake.

## Machines

- **knowhere** — NixOS desktop (x86_64-linux) with NVIDIA GPU, GNOME/Wayland
- **aypa** — macOS (aarch64-darwin) work machine, using nix-darwin
- **macbook** — macOS (aarch64-darwin) personal machine, using nix-darwin

## Nix daemon ownership

`macbook` runs [Determinate Nix](https://docs.determinate.systems/), which owns
the Nix daemon. Its config sets `nix.enable = false` so nix-darwin doesn't
manage Nix on that host.

The consequence is that **nothing in `modules/shared/nix.nix`'s `nix.settings`
reaches `macbook`** — nix-darwin writes no Nix configuration at all when
`nix.enable` is off, and Determinate reads `/etc/nix/nix.custom.conf` instead.
The settings block is wrapped in `lib.mkIf config.nix.enable` to make that
explicit. In particular the `ryoppippi.cachix.org` substituter that serves
`claude-code` is *not* active on `macbook`; to enable it there, add it to
`/etc/nix/nix.custom.conf` out of band:

```
extra-substituters = https://ryoppippi.cachix.org
extra-trusted-public-keys = ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms=
```

## Build Commands

All commands run from the repo root.

```bash
# build only
sudo nixos-rebuild build --flake '.#knowhere'
darwin-rebuild build --flake '.#aypa'
darwin-rebuild build --flake '.#macbook'

# build and activate
sudo nixos-rebuild switch --flake '.#knowhere'
nh os switch                      # knowhere only; same thing from any directory
darwin-rebuild switch --flake '.#aypa'
darwin-rebuild switch --flake '.#macbook'

# build a custom package standalone (`nix flake show` lists them;
# pencil-cli and sonarqube-cli are darwin only)
nix build '.#knip'
nix build '.#pencil-cli'

# build this system's host toplevels and packages, plus a formatting gate
nix flake check

# format the tree
nix fmt
```

## Prerequisites

The `rex` input (used by `knowhere`) is fetched from `pkgs.superlogical.com`,
which requires a token in `/etc/nix/netrc`:

```
machine pkgs.superlogical.com login rex password TOKEN
```

## Layout

- `hosts/<name>/` — one directory per machine; `default.nix` is the entry point
  referenced from `flake.nix`.
- `modules/shared/` — imported by every host, NixOS and nix-darwin alike.
- `modules/darwin/` — base for both Macs; imports `modules/shared`.
- `pkgs/<name>/` — local derivations, all routed through `overlays.default` in
  `flake.nix`, which the hosts and the `packages` output both consume.
- `scripts/` — manual maintenance helpers.

## Per-host options

Shared modules define a base and expose `my.*` options that hosts extend; list
options merge across modules.

- `my.unfreePackages` — unfree packages are gated per-host rather than via a
  blanket `allowUnfree`. `modules/shared/unfree.nix` seeds a shared base and
  builds the `allowUnfreePredicate` once; each host appends its own names.
- `my.aspellDicts` — dictionaries for the single shared aspell wrapper, which
  can't be extended after it is built.
- `my.graphify.withOpenai` — enables graphify's OpenAI backend; off by default
  to keep the closure small.

## License

MIT
