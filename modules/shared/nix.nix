{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Guarded on nix.enable: macbook hands the daemon to Determinate Nix, which
  # reads /etc/nix/nix.custom.conf and never sees anything written here. The
  # mkIf makes that inertness explicit rather than letting the settings below
  # look like they apply to every host. See README "Nix daemon ownership".
  nix.settings = lib.mkIf config.nix.enable {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [ "https://ryoppippi.cachix.org" ];
    extra-trusted-public-keys = [
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };

  # Weekly gc and store optimise on every host that owns its daemon, so not
  # macbook. The schedule is spelled per platform: systemd `dates` on NixOS,
  # while nix-darwin's launchd `interval` already defaults to weekly.
  nix.gc = lib.mkMerge [
    (lib.mkIf config.nix.enable {
      automatic = true;
      options = "--delete-older-than 30d";
    })
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      persistent = true;
      dates = "weekly";
    })
  ];

  nix.optimise = lib.mkMerge [
    (lib.mkIf config.nix.enable { automatic = true; })
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux { dates = [ "weekly" ]; })
  ];
}
