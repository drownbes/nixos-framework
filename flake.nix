{
  description = "Framework laptop os";

  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.home-manager.url = "github:nix-community/home-manager/release-23.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    home-manager,
    treefmt-nix,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
  in {
    inherit treefmtEval;
    shotcut = nixpkgs-unstable.legacyPackages.${system}.shotcut;
    formatter.${system} = treefmtEval.config.build.wrapper;
    checks.${system} = {
      formatting = treefmtEval.config.build.check self;
    };
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          unstablePkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };
        modules = [
          ./configuration.nix
          nixos-hardware.nixosModules.framework-11th-gen-intel
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.drownbes = import ./home.nix;
          }
        ];
      };
    };
  };
}
