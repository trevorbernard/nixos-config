# NixOS Configuration

Personal NixOS configuration files for system management.

## Structure

- `knowhere/` - Configuration for the "knowhere" system
  - `configuration.nix` - Main system configuration
  - `hardware-configuration.nix` - Hardware-specific configuration
  - `hardware/` - Additional hardware configurations
  - `nix/` - Custom Nix packages and modules

## Usage

Clone this repository and use with `nixos-rebuild`:

```bash
sudo nixos-rebuild switch --flake .#knowhere
```

## License

MIT