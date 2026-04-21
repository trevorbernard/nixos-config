{ pkgs, lib, ... }:
{
  imports = [
    ../../modules/shared/nix.nix
    ../../modules/shared/packages.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
      "claude-code"
      "terraform"
    ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    (aspellWithDicts (dicts: [ dicts.en dicts.en-computers ]))
    neovim
    terraform
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
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

  users.users.tbernard = {
    home = "/Users/tbernard";
    shell = pkgs.zsh;
  };
  system.primaryUser = "tbernard";

  system.stateVersion = 6;
}
