{ pkgs, ... }:
{
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
    htop
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
