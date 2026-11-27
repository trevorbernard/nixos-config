{ pkgs, ... }:
{
  imports = [ ../shared ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "brave-browser"
      "claude"
      "docker-desktop"
      "obsidian"
      "spotify"
      "supacode"
    ];
    brews = [
      "gnupg"
    ];
  };

  # Registers the Nix zsh in /etc/shells so it is a valid chsh target, matching
  # what knowhere does.
  environment.shells = [ pkgs.zsh ];

  # programs.zsh.enable already defaults to true here. These are the flat
  # spellings of the flags knowhere sets as autosuggestions.enable and
  # syntaxHighlighting.enable; nix-darwin has not adopted the nested form.
  programs.zsh = {
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
  };

  # Rex sets REX_BIN_DIR only inside its own terminals, so the guard keeps an
  # empty entry out of PATH everywhere else.
  environment.interactiveShellInit = ''
    if [ -n "$REX_BIN_DIR" ]; then
      export PATH="$REX_BIN_DIR:$PATH"
    fi
  '';

  users.users.tbernard = {
    home = "/Users/tbernard";
    shell = pkgs.zsh;
  };
  system.primaryUser = "tbernard";

  # reattach makes Touch ID reachable from inside tmux, whose sessions are
  # otherwise detached from the GUI login that owns the sensor.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  system.stateVersion = 6;
}
