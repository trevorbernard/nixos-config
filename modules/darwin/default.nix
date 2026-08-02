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
    # herdr now comes from the flake input via modules/shared/packages.nix,
    # which pins it; the brew tracked whatever was installed at the time.
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
