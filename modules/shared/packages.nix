{ pkgs, ... }:
{
  imports = [ ./unfree.nix ];

  # Installs direnv + nix-direnv and wires up the shell hook; works on both
  # NixOS and nix-darwin, so it replaces the bare direnv/nix-direnv packages.
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    atuin
    clang
    claude-code
    cmake
    emacs-nox
    eza
    fzf
    gh
    git
    graphify
    htop
    hunk
    libtool
    magic-wormhole
    mcp-nixos
    mosh
    nil
    starship
    stow
    termcopy
    tig
    tmux
    tumbler
    zoxide
  ];
}
