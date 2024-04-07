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
#     ./openssh.nix
#     ./sops.nix
#     ./systemd-boot.nix
#     ./tailscale.nix
    ./users.nix
  ];
}
