{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; # NixOS official package source, unstable branch
    nixpkgs-stable.url = "nixpkgs/nixos-23.11"; # Stable branch, version 23.11
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs: let
    forEachSystem = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"];
    forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
  mkNixos = host: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit (self) inputs outputs;};
        modules = [
          ./hosts/${host}
        ];
      };

    mkHome = host: system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {inherit (self) inputs outputs;};
        modules = [
          ./home/user/${host}.nix
        ];
      };

in
{

    # packages = forEachPkgs (pkgs: import ./pkgs {inherit pkgs;});

    nixosConfigurations = {
      cronos = mkNixos "cronos" "aarch64-linux";
 #    hestia = mkNixos "hestia" "x86_64-linux";
 #    deimos = mkNixos "deimos" "x86_64-linux";
    };

    homeConfigurations = {
     "dave@cronos" = mkHome "cronos" "aarch64-linux";
 #    "dave@hestia" = mkHome "hestia" "x86_64-linux";
 #    "dave@deimos" = mkHome "deimos" "x86_64-linux";
    };

#    nixosConfigurations = {
#	nixos = nixpkgs.lib.nixosSystem {
#	      system = "aarch64-linux";
#	      modules = [
#		./configuration.nix # Import the previous configuration.nix
#  home-manager.nixosModules.home-manager
#         {
#           home-manager.useGlobalPkgs = true;
#           home-manager.useUserPackages = true;

#           # TODO replace ryan with your own username
#           home-manager.users.user = import ./home.nix;

#           # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
#         }
#	      ];
#      };
#    };
  };
}
