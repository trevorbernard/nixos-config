# Configuration common to every host, NixOS and nix-darwin alike.
{
  imports = [
    ./fonts.nix
    ./nix.nix
    ./packages.nix
    ./unfree.nix
  ];
}
