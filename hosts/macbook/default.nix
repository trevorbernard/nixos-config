{ pkgs, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  # Determinate Nix manages the daemon on this host; let it own Nix.
  nix.enable = false;

  my.unfreePackages = [ "pencil-cli" ];

  environment.systemPackages = [
    (pkgs.callPackage ../../pkgs/pencil-cli { })
  ];

  homebrew.casks = [
    "slack"
    "syncthing-app"
    "tailscale-app"
  ];
}
