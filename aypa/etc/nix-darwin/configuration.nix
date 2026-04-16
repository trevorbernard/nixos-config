{
  pkgs,
  lib,
  self,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude-code" "1password-cli"];

  environment.systemPackages = with pkgs; [
    _1password-cli
    (aspellWithDicts (dicts: [dicts.en dicts.en-computers]))
    atuin
    clang
    claude-code
    cmake
    direnv
    (emacs-nox.override {withNativeCompilation = true;})
    eza
    fzf
    gh
    git
    htop
    libtool
    mosh
    neovim
    nil
    nix-direnv
    starship
    termcopy
    tig
    tmux
    zoxide
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://ryoppippi.cachix.org"];
    extra-trusted-public-keys = ["ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="];
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    taps = [
      "snowflakedb/snowflake-cli"
      "atlassian-labs/acli"
    ];
    casks = [
      "1password"
      "brave-browser"
      "claude"
      "docker-desktop"
      "ghostty"
      "gitbutler"
      "obsidian"
      "session-manager-plugin"
      "snowflake-cli"
      "spotify"
    ];
    brews = [
      "atlassian-labs/acli/acli"
      "glow"
      "gnupg"
    ];
  };

  # https://github.com/LnL7/nix-darwin/issues/423
  users.users.tbernard = {
    home = "/Users/tbernard";
    shell = pkgs.zsh;
  };
  system.primaryUser = "tbernard";
}
