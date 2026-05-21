{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  # Determinate Nix manages the daemon on this host; let it own Nix.
  nix.enable = false;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "pencil-cli"
    ];

  environment.systemPackages = [
    (pkgs.callPackage ../../pkgs/pencil-cli { })
  ];

  homebrew.casks = [
    "pencil"
    "slack"
    "syncthing-app"
    "tailscale-app"
  ];
}
