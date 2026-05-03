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

  services.tailscale.enable = true;

  homebrew.casks = [
    "syncthing-app"
  ];
}
