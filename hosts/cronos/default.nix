# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      ../common/global
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "cronos";
  networking.networkmanager.enable = true;

  home-manager.users.user = import ../../home/user/cronos.nix;


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    vim
    lazygit
  ];

  # programs.git = {
  #   enable = true;
  #   config = {
	 #    user.name = "nanocortex";
	 #    user.email = "nb.dnio6@aleeas.com";
	 #    extraConfig = {
	 #      credential.helper = "store";
	 #    };
  #   };
  # };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ ];
  };

  # system.copySystemConfiguration = true;

  # Read the doc before updating
  system.stateVersion = "23.11";

}
