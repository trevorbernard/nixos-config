{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: 
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
        f {
          inherit system;
          pkgs = import nixpkgs { inherit system; };
        });
    in
    {
      packages = forAllSystems ({ pkgs, system }: {
        default = import ./default.nix {
          inherit (pkgs) lib fetchzip buildNpmPackage;
        };
      });
    };
}
