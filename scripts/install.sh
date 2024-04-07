#!/usr/bin/env bash

set -e -u -o pipefail -x

# setfont ter-v24n
DISK="/dev/vda"
GITHUB_REPO="https://github.com/nanocortex/nix-server"
FLAKE_PATH="/mnt/etc/nixos#cronos"

if mountpoint -q /mnt/boot && [ -d /mnt/boot ]; then umount -l /mnt/boot; fi
if mountpoint -q /mnt && [ -d /mnt ]; then umount -l /mnt; fi

swapoff -a
wipefs -a "$DISK"

# Clear existing partitions on the disk
# parted "$DISK" -- rm 1
# parted "$DISK" -- rm 2
# parted "$DISK" -- rm 3

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on
mkfs.vfat "$DISK"1

# As I intend to use this VM on Proxmox, I will not encrypt the disk

parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
mkswap -L Swap "$DISK"2
swapon "$DISK"2

parted "$DISK" -- mkpart primary 9GiB 100%
mkfs.ext4 -L ext4 "$DISK"3

mount "$DISK"3 /mnt

mkdir /mnt/boot
mount "$DISK"1 /mnt/boot

# create configuration
nixos-generate-config --root /mnt

nix-shell -p git --run "git clone $GITHUB_REPO /tmp/nixconf"

cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hw.conf
cp -r /tmp/nixconf/* /mnt/etc/nixos
cp /tmp/hw.conf /mnt/etc/nixos/hosts/cronos/hardware-configuration.nix

nixos-install --flake /mnt/etc/nixos#cronos --root /mnt

sudo cp /mnt/etc/nixos /mnt/home/user/dotfiles && sudo chown -R user /mnt/home/user/dotfiles

echo "Installation complete. Rebooting..."
