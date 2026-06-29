{ pkgs, ... }:
{
  imports = [
    ../shared/nix.nix
    ../shared/packages.nix
    ../shared/fonts.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    (aspellWithDicts (dicts: [ dicts.en dicts.en-computers ]))
  ];

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

  users.users.tbernard = {
    home = "/Users/tbernard";
    shell = pkgs.zsh;
  };
  system.primaryUser = "tbernard";

  system.stateVersion = 6;
}
