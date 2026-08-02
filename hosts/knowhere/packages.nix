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

  environment.systemPackages = with pkgs; [
    bat
    ghostty
    gnome-tweaks
    gnumake
    jq
    libvterm
    nh
    nix-output-monitor
    nixfmt
    nvd
    ripgrep
    terraform
    unzip
    vim
    wl-clipboard
    yq
    zip
  ];
}
