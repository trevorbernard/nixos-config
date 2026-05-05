{ lib, ... }:
{
  imports = [
    ../../modules/darwin
  ];

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
