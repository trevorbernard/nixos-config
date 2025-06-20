# NixOS Configuration

Personal NixOS configuration files for system management.

## Structure

- `flake.nix` - Flake configuration for the entire system
- `knowhere/nixos/` - Configuration for the "knowhere" system
  - `configuration.nix` - Main system configuration (imports modules)
  - `hardware-configuration.nix` - Hardware-specific configuration
  - `hardware/` - Additional hardware configurations
  - `modules/` - Modular configuration files
    - `system.nix` - Boot, locale, timezone
    - `hardware.nix` - GPU, audio, hardware settings
    - `desktop.nix` - GNOME, display manager, fonts
    - `networking.nix` - Network, SSH, firewall
    - `users.nix` - User accounts and shell configuration
    - `development.nix` - Development tools and programming languages
  - `nix/` - Custom Nix packages and modules

## Usage

### Option 1: Flake-based (Recommended)

```bash
# Clone the repository
git clone <repo-url> ~/code/nixos-config
cd ~/code/nixos-config

# Build and switch to the configuration
sudo nixos-rebuild switch --flake .#knowhere
```

### Option 2: Traditional /etc/nixos integration

```bash
# Clone the repository
git clone <repo-url> ~/code/nixos-config

# Run the setup script to create symlinks
sudo ~/code/nixos-config/setup-nixos-integration.sh

# Build and switch using traditional method
sudo nixos-rebuild switch
```

## Benefits of the New Structure

- **Modular**: Each aspect of the system is in its own file
- **Maintainable**: Easy to find and modify specific configurations
- **Reusable**: Modules can be easily enabled/disabled or reused
- **Flake Support**: Better reproducibility and dependency management
- **Clean Separation**: System vs user configuration is clearly separated

## Customizing

To modify the configuration:

1. Edit the relevant module in `knowhere/nixos/modules/`
2. Run `sudo nixos-rebuild switch --flake .#knowhere` (flake method)
3. Or run `sudo nixos-rebuild switch` (traditional method)

## License

MIT
