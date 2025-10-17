{
  description = "NixOS configuration for knowhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = { self, nixpkgs, ghostty, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.knowhere = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix

          # Overlay for custom packages
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              # Custom packages overlay
              (final: prev: {
                claude-code = prev.callPackage ./nix/claude-code/default.nix {};
                termcopy = prev.callPackage ./nix/termcopy/default.nix {};
                ghostty = ghostty.packages.${system}.default;
              })
            ];
          })
        ];
      };
    };
}
