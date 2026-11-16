# Placeholder hardware configuration.
# Generate a real one on the target machine with:
#   sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
# Then replace this import in hosts/desktop/default.nix.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Minimal stub to allow evaluation in some contexts; NOT bootable as-is.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
