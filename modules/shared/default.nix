# Configuration common to every host, NixOS and nix-darwin alike.
{
  imports = [
    ./aspell.nix
    ./fonts.nix
    ./nix.nix
    ./packages.nix
    ./unfree.nix
  ];
}
