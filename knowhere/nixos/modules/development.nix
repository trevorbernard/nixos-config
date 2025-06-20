{ config, pkgs, lib, ... }:

let
  claude-code = pkgs.callPackage ../nix/claude-code/default.nix {};
in
{
  # Development tools and programming languages
  environment.systemPackages = with pkgs; [
    # Build tools
    clang
    cmake
    gnumake
    libtool
    ninja
    
    # Version control
    git
    jujutsu
    tig
    
    # Text editors and terminal tools
    emacs-nox
    vim
    
    # Command line utilities
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    atuin
    bat
    eza
    fzf
    htop
    jq
    libvterm
    magic-wormhole
    mosh
    nix-direnv
    oh-my-zsh
    ripgrep
    starship
    tmux
    wl-clipboard
    zoxide
    zsh
    
    # Nix tools
    nh
    nil
    nix-output-monitor
    nixfmt-rfc-style
    nvd
    
    # Terminal emulator
    ghostty
    
    # AI tools
    claude-code
  ];

  # Enable experimental Nix features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Environment variables for development
  environment.variables = {
    COLORTERM = "truecolor";
    TERM = "xterm-direct";
    EDITOR = "emacs";
  };

  environment.sessionVariables = {
    PATH = "$HOME/bin:$PATH";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}