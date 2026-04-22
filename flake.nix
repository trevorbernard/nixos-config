{
  description = "System configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    termcopy = {
      url = "github:trevorbernard/termcopy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tumbler = {
      url = "github:trevorbernard/tumbler/v0.1.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      termcopy,
      tumbler,
      claude-code-overlay,
      ...
    }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forEachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

      commonOverlays = [
        claude-code-overlay.overlays.default
        (final: _: {
          termcopy = termcopy.packages.${final.stdenv.hostPlatform.system}.default;
          tumbler = tumbler.packages.${final.stdenv.hostPlatform.system}.default;
        })
      ];
      darwinOverlays = commonOverlays ++ [
        (_: prev: {
          # direnv fish tests are killed by the macOS sandbox
          direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
        })
      ];
    in
    {
      nixosConfigurations.knowhere = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          { nixpkgs.overlays = commonOverlays; }
          ./hosts/knowhere/default.nix
        ];
      };

      darwinConfigurations.aypa = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; };
        modules = [
          { nixpkgs.overlays = darwinOverlays; }
          ./hosts/aypa/default.nix
        ];
      };

      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; };
        modules = [
          { nixpkgs.overlays = darwinOverlays; }
          ./hosts/macbook/default.nix
        ];
      };

      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };
}
