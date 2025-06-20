#!/usr/bin/env nix-shell
#!nix-shell -i bash -p stow
# Script to integrate nixos-config with /etc/nixos

set -euo pipefail

REPO_DIR="${HOME}/code/nixos-config"
NIXOS_DIR="/etc/nixos"

echo "Setting up NixOS configuration integration..."

# Check if we're running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script needs to be run with sudo to modify /etc/nixos"
    echo "Usage: sudo ./setup-nixos-integration.sh"
    exit 1
fi

# Backup existing configuration if it exists
if [[ -f "$NIXOS_DIR/configuration.nix" ]]; then
    echo "Backing up existing configuration.nix to configuration.nix.backup"
    cp "$NIXOS_DIR/configuration.nix" "$NIXOS_DIR/configuration.nix.backup"
fi

# Remove existing configuration if it's not a symlink
if [[ -f "$NIXOS_DIR/configuration.nix" && ! -L "$NIXOS_DIR/configuration.nix" ]]; then
    rm "$NIXOS_DIR/configuration.nix"
fi

# Create symlink to our configuration
echo "Creating symlink from /etc/nixos/configuration.nix to repo configuration"
ln -sf "$REPO_DIR/knowhere/nixos/configuration.nix" "$NIXOS_DIR/configuration.nix"

# Verify the symlink was created correctly
if [[ -L "$NIXOS_DIR/configuration.nix" ]]; then
    echo "✅ Symlink created successfully"
    echo "   /etc/nixos/configuration.nix -> $(readlink "$NIXOS_DIR/configuration.nix")"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

echo ""
echo "Integration complete! You can now use:"
echo ""
echo "Traditional method:"
echo "  sudo nixos-rebuild switch"
echo ""
echo "Flake method (recommended):"
echo "  cd $REPO_DIR"
echo "  sudo nixos-rebuild switch --flake .#knowhere"
echo ""
echo "The flake method is recommended as it provides better reproducibility"
echo "and doesn't require symlinking to /etc/nixos"
