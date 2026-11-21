{ pkgs, ... }:
{
  my.unfreePackages = [
    "amazon-q-cli"
    "aspell-dict-en-science"
    "brave"
    "nvidia-kernel-modules"
    "nvidia-persistenced"
    "nvidia-settings"
    "nvidia-x11"
    "terraform"
  ];

  my.aspellDicts = [ "en-science" ];

  # Sets NH_FLAKE, so `nh os switch` works from any directory. nh.clean stays
  # off: modules/shared/nix.nix already schedules nix.gc.
  programs.nh = {
    enable = true;
    flake = "/home/tbernard/code/nixos-config";
  };

  # `, cmd` runs a command from nixpkgs without installing it. The module (see
  # flake.nix) also turns on nix-index, whose shell hook names the package
  # that provides a missing command.
  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    bat
    ghostty
    gnome-tweaks
    gnumake
    jq
    nix-output-monitor
    nixfmt
    nvd
    terraform
    unzip
    vim
    wl-clipboard
    yq
    zip
  ];
}
