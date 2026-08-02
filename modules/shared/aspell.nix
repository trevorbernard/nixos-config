{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.aspellDicts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "en-science" ];
    description = ''
      Attribute names (as found in pkgs.aspellDicts) to build the shared
      aspell wrapper from. Definitions merge across modules, so hosts append
      their own dictionaries to the shared base below. A single wrapper is
      built from the merged list, since aspellWithDicts cannot be extended
      after the fact.
    '';
  };

  config = {
    # Available on every host.
    my.aspellDicts = [
      "en"
      "en-computers"
    ];

    environment.systemPackages = [
      (pkgs.aspellWithDicts (dicts: map (name: dicts.${name}) (lib.unique config.my.aspellDicts)))
    ];
  };
}
