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
    mosh
    nil
    nix-direnv
    starship
    termcopy
    tig
    tmux
    tumbler
    zoxide
  ];
}
