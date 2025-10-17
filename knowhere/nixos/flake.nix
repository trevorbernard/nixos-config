{
  description = "NixOS configuration for knowhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.knowhere = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit nixpkgs-unstable;
        };

        modules = [
          ./configuration.nix

          # Overlay for custom packages
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              # Custom packages overlay
              (final: prev: {
                claude-code = prev.callPackage ./nix/claude-code/default.nix {};
                termcopy = prev.callPackage ./nix/termcopy/default.nix {};
              })

              # Ghostty from unstable
              (_: prev: {
                ghostty = (import nixpkgs-unstable {
                  system = prev.system;
                }).ghostty;
              })
            ];
          })
        ];
      };
    };
}
