{
  description = "NixOS configuration for knowhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    ghostty.url = "github:ghostty-org/ghostty/v1.3.1";
    termcopy.url = "github:trevorbernard/termcopy";
    termcopy.inputs.nixpkgs.follows = "nixpkgs";
    tumbler.url = "github:trevorbernard/tumbler";
    tumbler.inputs.nixpkgs.follows = "nixpkgs";
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
  };

  outputs = { self, nixpkgs, ghostty, termcopy, tumbler, claude-code-overlay, ... }:
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
              claude-code-overlay.overlays.default
              # Custom packages overlay
              (final: prev: {
                termcopy = termcopy.packages.${system}.default;
                tumbler = tumbler.packages.${system}.default;
                ghostty = ghostty.packages.${system}.default;
              })
            ];
          })
        ];
      };
    };
}
