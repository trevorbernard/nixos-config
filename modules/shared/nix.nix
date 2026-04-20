{ self, pkgs, lib, ... }:
{
  system.configurationRevision = self.rev or self.dirtyRev or null;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://ryoppippi.cachix.org" ];
    extra-trusted-public-keys = [
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    persistent = true;
    dates = "weekly";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    interval = { Weekday = 0; Hour = 3; Minute = 15; };
  };

  nix.optimise = {
    automatic = true;
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    dates = [ "weekly" ];
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    interval = { Weekday = 0; Hour = 4; Minute = 15; };
  };
}
