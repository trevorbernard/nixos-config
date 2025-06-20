{ config, pkgs, lib, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    ./hardware/truerng.nix
    
    # Modular configuration
    ./modules/system.nix
    ./modules/hardware.nix
    ./modules/desktop.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/development.nix
  ];
}