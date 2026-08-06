{
  description = "System configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    termcopy = {
      url = "github:trevorbernard/termcopy/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tumbler = {
      url = "github:trevorbernard/tumbler/v0.1.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hunk's flake targets nixpkgs-unstable (bun2nix); don't pin it to ours.
    hunk.url = "github:modem-dev/hunk/v0.17.0";

    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr/v0.7.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuicr = {
      url = "github:agavra/tuicr/v0.20.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fork carrying faint (SGR 2) support, which upstream parses and then
    # discards. Both ends re-parse and re-emit the escape stream, so the client
    # and the server both have to carry the patch for faint to survive.
    mosh = {
      url = "github:trevorbernard/mosh";
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
      hunk,
      claude-code-overlay,
      herdr,
      tuicr,
      mosh,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      # Unfree packages reachable from the `packages` output. Kept as an
      # explicit allowlist rather than `allowUnfree = true` so this entry point
      # matches the host-side policy in modules/shared/unfree.nix.
      unfreePackages = [
        "pencil-cli"
        "sonarqube-cli"
      ];

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) unfreePackages;
        };

      forEachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f (pkgsFor system));
    in
    {
      # Single source of truth for every package this flake adds to nixpkgs, so
      # hosts and the `packages` output can never define one differently.
      overlays.default = nixpkgs.lib.composeManyExtensions [
        claude-code-overlay.overlays.default
        (final: _: {
          termcopy = termcopy.packages.${final.stdenv.hostPlatform.system}.default;
          tumbler = tumbler.packages.${final.stdenv.hostPlatform.system}.default;
          hunk = hunk.packages.${final.stdenv.hostPlatform.system}.default;
          herdr = herdr.packages.${final.stdenv.hostPlatform.system}.default;
          tuicr = tuicr.packages.${final.stdenv.hostPlatform.system}.default;
          mosh = mosh.packages.${final.stdenv.hostPlatform.system}.default;
        })
        (final: _: {
          graphify = final.callPackage ./pkgs/graphify { };
          openspec = final.callPackage ./pkgs/openspec { };
          pencil-cli = final.callPackage ./pkgs/pencil-cli { };
          sonarqube-cli = final.callPackage ./pkgs/sonarqube-cli { };
        })
      ];

      nixosConfigurations.knowhere = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.default ]; }
          ./hosts/knowhere/default.nix
        ];
      };

      darwinConfigurations.aypa = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.default ]; }
          ./hosts/aypa/default.nix
        ];
      };

      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; };
        modules = [
          { nixpkgs.overlays = [ self.overlays.default ]; }
          ./hosts/macbook/default.nix
        ];
      };

      # Both are macOS-only binaries, so they are absent on Linux rather than
      # present-and-unbuildable.
      packages = forEachSystem (
        pkgs:
        nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          inherit (pkgs) pencil-cli sonarqube-cli;
        }
      );

      # `nix flake check` builds every host toplevel and package belonging to
      # the system it runs on, plus a formatting gate.
      checks = forEachSystem (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          toplevels =
            nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
              knowhere = self.nixosConfigurations.knowhere.config.system.build.toplevel;
            }
            // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
              aypa = self.darwinConfigurations.aypa.config.system.build.toplevel;
              macbook = self.darwinConfigurations.macbook.config.system.build.toplevel;
            };
        in
        toplevels
        // self.packages.${system}
        // {
          # Files are passed individually because nixfmt has deprecated
          # directory arguments.
          formatting = pkgs.runCommandLocal "check-formatting" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
            find ${self} -name '*.nix' -exec nixfmt --check {} +
            touch $out
          '';
        }
      );

      # nixfmt-tree (treefmt) rather than bare nixfmt: it walks the tree, so
      # `nix fmt` with no arguments works instead of erroring on stdin.
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
