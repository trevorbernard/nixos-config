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

  nix.gc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    automatic = true;
    dates = [ "weekly" ];
  };
}
