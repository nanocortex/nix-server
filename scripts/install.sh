#!/usr/bin/env bash

set -e -u -o pipefail -x

# setfont ter-v24n
DISK="$1"
HOSTNAME="$2"
PASSWORD_FILE="/tmp/secure.txt"

GITHUB_REPO="https://github.com/nanocortex/nix-server"

if mountpoint -q /mnt/boot && [ -d /mnt/boot ]; then umount -l /mnt/boot; fi
if mountpoint -q /mnt && [ -d /mnt ]; then umount -l /mnt; fi

swapoff -a
wipefs -a "$DISK"

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on
mkfs.vfat "$DISK"1

# parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
# mkswap -L Swap "$DISK"2
# swapon "$DISK"2

# Setting up encryption for swap
parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
cryptsetup luksFormat "$DISK"2 --key-file "$PASSWORD_FILE"
cryptsetup open "$DISK"2 cryptswap --key-file "$PASSWORD_FILE"
mkswap -L Swap /dev/mapper/cryptswap
swapon /dev/mapper/cryptswap


# parted "$DISK" -- mkpart primary 9GiB 100%
# mkfs.ext4 -L ext4 "$DISK"3 -F
#
parted "$DISK" -- mkpart primary 9GiB 100%
# Setting up encryption for the root partition
cryptsetup luksFormat "$DISK"3 --key-file "$PASSWORD_FILE"
cryptsetup open "$DISK"3 cryptroot --key-file "$PASSWORD_FILE"
mkfs.ext4 -L ext4 /dev/mapper/cryptroot -F

# mount "$DISK"3 /mnt
# mkdir /mnt/boot
# mount "$DISK"1 /mnt/boot

mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "$DISK"1 /mnt/boot


# create configuration
nixos-generate-config --root /mnt

rm -rf /tmp/nixconf
nix-shell -p git --run "git clone $GITHUB_REPO /tmp/nixconf"

cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hw.conf
cp -r /tmp/nixconf/* /mnt/etc/nixos
cp /tmp/hw.conf /mnt/etc/nixos/hosts/$HOSTNAME/hardware-configuration.nix

nixos-install --flake /mnt/etc/nixos#$HOSTNAME --root /mnt

# cp -r /mnt/etc/nixos /mnt/home/user/dotfiles
nix-shell -p git --run "git clone $GITHUB_REPO /mnt/home/user/dotfiles"
# chown -R user /mnt/home/user/dotfiles
cp /tmp/hw.conf /mnt/home/user/dotfiles/hosts/$HOSTNAME/hardware-configuration.nix

rm -rf /mnt/etc/nixos/*
# ln -s /mnt/etc/nixos /mnt/home/user/dotfiles

cp /tmp/ssh_host_ed25519_key /mnt/etc/ssh
cp /tmp/ssh_host_ed25519_key.pub /mnt/etc/ssh

mkdir -p /mnt/etc/secrets/initrd
ssh-keygen -t rsa -N "" -f /mnt/etc/secrets/initrd/ssh_host_rsa_key

rm -rf /tmp/*

echo "Installation complete. Rebooting"

sleep 2

# reboot
