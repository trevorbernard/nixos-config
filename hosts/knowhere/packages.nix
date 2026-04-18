{ pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "amazon-q-cli"
      "aspell-dict-en-science"
      "brave"
      "claude-code"
      "nvidia-persistenced"
      "nvidia-settings"
      "nvidia-x11"
      "terraform"
    ];

  environment.systemPackages = with pkgs; [
    (aspellWithDicts (dicts: with dicts; [
      en
      en-computers
      en-science
    ]))
    bat
    ghostty
    gnome-tweaks
    gnumake
    jq
    libvterm
    magic-wormhole
    nh
    nix-output-monitor
    nixfmt-rfc-style
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
