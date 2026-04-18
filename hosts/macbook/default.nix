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
    ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    (aspellWithDicts (dicts: [ dicts.en dicts.en-computers ]))
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "1password"
      "brave-browser"
      "claude"
      "obsidian"
      "spotify"
    ];
    brews = [
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
