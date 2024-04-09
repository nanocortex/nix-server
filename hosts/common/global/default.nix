{pkgs, ...}: {
  imports = [
#    ./backup.nix
    ./home-manager.nix
#     ./mosh.nix
#     ./nfs.nix
#     ./nix.nix
#     ./nixpkgs.nix
#     ./ntfs.nix
#     ./oomd.nix
      ./openssh.nix
      ./sops.nix
#     ./systemd-boot.nix
      ./tailscale.nix
      ./users.nix
  ];


  time.timeZone = "Europe/Warsaw";

  # boot.kernelParams = [ "ip=dhcp" ];
  # boot.initrd = {
  #   verbose = true;
  #   availableKernelModules = [ "r8169" "virtio-pci" ];
  #   systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
  #   network = {
  #     enable = true;
  #     ssh = {
  #       enable = true;
  #       port = 22;
  #       authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIED8axnZzZk5P39CEbMeJZy42o/4T0iHgr1pefNDsnU5 ex0cortex@pm.me" ];
  #       hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
  #     };
  #   };
  # };
}
