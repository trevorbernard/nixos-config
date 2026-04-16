{
  description = "nix-darwin configuration for aypa (macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    termcopy.url = "github:trevorbernard/termcopy";
    termcopy.inputs.nixpkgs.follows = "nixpkgs";
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    claude-code-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    termcopy,
    claude-code-overlay,
    ...
  }: let
    system = "aarch64-darwin";
  in {
    darwinConfigurations."aypa" = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit self;};
      modules = [
        {
          nixpkgs.overlays = [
            claude-code-overlay.overlays.default
            (final: prev: {
              # direnv 2.37.1 fish test gets killed by the macOS sandbox.
              direnv = prev.direnv.overrideAttrs (_: {
                doCheck = false;
              });
              termcopy = termcopy.packages.${final.stdenv.hostPlatform.system}.default;
            })
          ];
        }
        ./configuration.nix
      ];
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
