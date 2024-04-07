#!/usr/bin/env bash

set -e -u -o pipefail -x

setfont ter-v24n

DISK=/dev/vda

if mountpoint -q /mnt/boot && [ -d /mnt/boot ]; then umount -l /mnt/boot; fi
if mountpoint -q /mnt/var/log && [ -d /mnt/var/log ]; then umount -l /mnt/var/log; fi
if mountpoint -q /mnt/persist && [ -d /mnt/persist ]; then umount -l /mnt/persist; fi
if mountpoint -q /mnt/nix && [ -d /mnt/nix ]; then umount -l /mnt/nix; fi
if mountpoint -q /mnt/home && [ -d /mnt/home ]; then umount -l /mnt/home; fi
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
mkfs.btrfs -L Butter "$DISK"3 -f

mount "$DISK"3 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log

# We then take an empty *readonly* snapshot of the root subvolume,
# which we'll eventually rollback to on every boot.
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

umount /mnt

# Mount the directories

mount -o subvol=root,compress=zstd,noatime "$DISK"3 /mnt

mkdir /mnt/home
mount -o subvol=home,compress=zstd,noatime "$DISK"3 /mnt/home

mkdir /mnt/nix
mount -o subvol=nix,compress=zstd,noatime "$DISK"3 /mnt/nix

mkdir /mnt/persist
mount -o subvol=persist,compress=zstd,noatime "$DISK"3 /mnt/persist

mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime "$DISK"3 /mnt/var/log

# don't forget this!
mkdir /mnt/boot
mount "$DISK"1 /mnt/boot

# create configuration
nixos-generate-config --root /mnt


mkdir -p /mnt/persist/passwords
mkpasswd -m sha-512 "P@ssw0rd" > /mnt/persist/passwords/user

# now, edit nixos configuration and nixos-install
#
#
#
cp ../configuration.nix /mnt/etc/nixos/configuration.nix

nixos-install --root /mnt

nixos-rebuild boot

mkdir -p /mnt/persist/etc

cp -r /mnt/etc/nixos /mnt/persist/etc/
# cp {/mnt,/mnt/persist}/etc/machine-id

mkdir -p /mnt/persist/etc/ssh

cp {/mnt,/mnt/persist}/etc/ssh/ssh_host_ed25519_key
cp {/mnt,/mnt/persist}/etc/ssh/ssh_host_ed25519_key.pub
cp {/mnt,/mnt/persist}/etc/ssh/ssh_host_rsa_key
cp {/mnt,/mnt/persist}/etc/ssh/ssh_host_rsa_key.pub