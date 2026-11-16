{
  description = "Cohesive, declarative NixOS dotfiles: Iris-themed MangoWC + Quickshell shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Quickshell: verify ref/channel as needed for your target. HM integration available via nixpkgs/HM modules.
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, mango, quickshell, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
      lib = nixpkgs.lib;
    in
    {
      overlays.default = final: prev: {
        iris-colors = final.callPackage ./pkgs/iris-colors { };
      };

      packages.${system} = {
        inherit (pkgs) iris-colors;
        default = pkgs.iris-colors;
      };

      nixosModules.default = import ./modules/nixos;
      homeManagerModules.default = import ./modules/home;

      nixosConfigurations.desktop = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          ./hosts/desktop/default.nix
          home-manager.nixosModules.home-manager
          mango.nixosModules.mango
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs self; };
            home-manager.sharedModules = [ mango.hmModules.mango ];
            home-manager.users.user = import ./home.nix;
          }
        ];
      };

      # Convenience output for faster checks/eval in some workflows.
      homeConfigurations."user@desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs self; };
        modules = [
          mango.hmModules.mango
          ./home.nix
        ];
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      checks.${system} = {
        iris-colors = pkgs.iris-colors;
      };
    };
}
