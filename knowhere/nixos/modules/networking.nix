{ config, pkgs, lib, ... }:

{
  # Network configuration
  networking.hostName = "knowhere";
  networking.networkmanager.enable = true;

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Mosh for better SSH over unreliable connections
  programs.mosh.enable = true;

  # Firewall configuration
  networking.firewall = {
    allowedTCPPorts = [ 22 5173 ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # Default mosh port range
    ];
  };

  # Enable CUPS for printing
  services.printing.enable = true;
}