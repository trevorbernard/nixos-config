{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.graphify;
in
{
  options.my.graphify.withOpenai = lib.mkEnableOption ''
    graphify's OpenAI backend. Pulls in openai and tiktoken, so leave it off
    on hosts with no OpenAI credentials to keep the closure small
  '';

  config = {
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
      (graphify.override { inherit (cfg) withOpenai; })
      herdr
      htop
      hunk
      libtool
      magic-wormhole
      mcp-nixos
      mosh
      nil
      openspec
      starship
      stow
      termcopy
      tig
      tmux
      tuicr
      tumbler
      zoxide
    ];
  };
}
