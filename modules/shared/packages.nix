{ pkgs, ... }:
{
  imports = [ ./unfree.nix ];

  environment.systemPackages = with pkgs; [
    atuin
    clang
    claude-code
    cmake
    direnv
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
    mosh
    nil
    nix-direnv
    starship
    stow
    termcopy
    tig
    tmux
    tumbler
    zoxide
  ];
}
