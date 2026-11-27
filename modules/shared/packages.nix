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
    programs.direnv.enable = true;

    environment.variables.EDITOR = "emacs";

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
      leaf-markdown-viewer
      libtool
      magic-wormhole
      mcp-nixos
      nil
      openspec
      ripgrep
      secretspec
      starship
      stow
      termcopy
      tig
      tmux
      tuicr
      tumbler
      zoxide
      zsh-completions
    ];
  };
}
