{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.knowhere = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./knowhere/nixos/configuration.nix
      ];
    };
  };
}
