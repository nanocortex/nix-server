{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; # NixOS official package source, unstable branch
    nixpkgs-stable.url = "nixpkgs/nixos-23.11"; # Stable branch, version 23.11
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs: 
let
    forEachSystem = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"];
    forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});

    mkNixos = host: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit (self) inputs outputs host;
        };
        modules = [
          ./hosts/${host}
        ];
      };

    mkHome = host: system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit (self) inputs outputs host;
        };
        modules = [
          ./home/user/${host}.nix
        ];
      };

in
{

    nixosModules = import ./modules/nixos;


    # packages = forEachPkgs (pkgs: import ./pkgs {inherit pkgs;});

    nixosConfigurations = {
      cronos = mkNixos "cronos" "aarch64-linux";
 #    hestia = mkNixos "hestia" "x86_64-linux";
    };

    homeConfigurations = {
     "user@cronos" = mkHome "cronos" "aarch64-linux";
 #    "dave@hestia" = mkHome "hestia" "x86_64-linux";
    };
  };
}
