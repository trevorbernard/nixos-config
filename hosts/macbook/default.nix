{ lib, ... }:
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
    ];

  homebrew.casks = [
    "slack"
    "syncthing-app"
    "tailscale-app"
  ];
}
