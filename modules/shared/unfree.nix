{ lib, config, ... }:
{
  options.my.unfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "terraform" ];
    description = ''
      Names (as returned by lib.getName) of unfree packages permitted on this
      host. Definitions merge across modules, so hosts append their own names
      to the shared base below.
    '';
  };

  config = {
    # Allowed on every host (installed via modules/shared/packages.nix).
    my.unfreePackages = [ "claude-code" ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.my.unfreePackages;
  };
}
