{
  description = "NixOS-WSL test branch: Iris-themed Quickshell dotfiles with opt-in nested MangoWC";

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

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, mango, quickshell, nixos-wsl, ... }:
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
        iris-colors = final.callPackage ./system/packages/iris-colors { };
      };

      packages.${system} = {
        inherit (pkgs) iris-colors;
        default = pkgs.iris-colors;
      };

      nixosModules.default = import ./system/modules;
      homeManagerModules.default = import ./home.nix;

      # WSL-specific system. NixOS-WSL owns the root filesystem; no bootloader,
      # disk mounts, or hardware configuration are declared here.
      nixosConfigurations.wsl = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          nixos-wsl.nixosModules.default
          ./system/hosts/wsl/default.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs self; };
            home-manager.sharedModules = [ mango.hmModules.mango ];
            home-manager.users.user = import ./system/hosts/wsl/home.nix;
          }
        ];
      };

      # Convenience output for faster checks/eval in some workflows.
      homeConfigurations."user@wsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs self; };
        modules = [
          mango.hmModules.mango
          (import ./system/hosts/wsl/home.nix)
        ];
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      checks.${system} = {
        iris-colors = pkgs.iris-colors;
      };
    };
}
