#!/usr/bin/env bash

set -e -u -o pipefail -x

# setfont ter-v24n
DISK="$1"
HOSTNAME="$2"

GITHUB_REPO="https://github.com/nanocortex/nix-server"

# Improved pre-conditions check and unmounting
check_and_unmount() {
    local target=$1
    if mountpoint -q "$target"; then
        sudo umount "$target" || sudo umount -lf "$target" # Lazily force unmount if needed
    fi
}

closeLuks() {
    local luks_volume_name=$1
    cryptsetup status "$luks_volume_name" &>/dev/null && sudo cryptsetup luksClose "$luks_volume_name" || echo "LUKS volume $luks_volume_name is not active or cannot be closed."
}

closeLuks "/dev/mapper/crytswap"
closeLuks "/dev/mapper/cryptroot"

check_and_unmount /mnt/boot
check_and_unmount /mnt

# Improve swap off handling
swapoff -a || true # Continue even if swapoff fails, adjust as needed for safety

# Wait and ensure devices are not in use before wiping
sleep 2
wipefs -a "$DISK"
sleep 2

# if mountpoint -q /mnt/boot && [ -d /mnt/boot ]; then umount -l /mnt/boot; fi
# if mountpoint -q /mnt && [ -d /mnt ]; then umount -l /mnt; fi

# swapoff -a
# wipefs -a "$DISK"

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on
mkfs.vfat "$DISK"1

# parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
# mkswap -L Swap "$DISK"2
# swapon "$DISK"2
#
# Ask for the password
read -r -s -p "Enter the password for the LUKS partition: " PASSWORD
echo # Move to a new line

# Verify the password
read -r -s -p "Verify the password: " PASSWORD_VERIFY
echo # Move to a new line

# Check if passwords match
if [ "$PASSWORD" != "$PASSWORD_VERIFY" ]; then
    echo "Passwords do not match."
    exit 1
fi


# Setting up encryption for swap
parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
echo "$PASSWORD" | cryptsetup luksFormat "$DISK"2 -
echo "$PASSWORD" | cryptsetup open "$DISK"2 cryptswap -
mkswap -L Swap /dev/mapper/cryptswap
swapon /dev/mapper/cryptswap


# parted "$DISK" -- mkpart primary 9GiB 100%
# mkfs.ext4 -L ext4 "$DISK"3 -F
#
parted "$DISK" -- mkpart primary 9GiB 100%
# Setting up encryption for the root partition
echo "$PASSWORD" | cryptsetup luksFormat "$DISK"3 -
echo "$PASSWORD" | cryptsetup open "$DISK"3 cryptroot -
mkfs.ext4 -L ext4 /dev/mapper/cryptroot -F

unset PASSWORD
unset PASSWORD_VERIFY

# mount "$DISK"3 /mnt
# mkdir /mnt/boot
# mount "$DISK"1 /mnt/boot

mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "$DISK"1 /mnt/boot


# create configuration
nixos-generate-config --root /mnt

mkdir -p /mnt/etc/secrets/initrd
mkdir -p /etc/secrets/initrd
ssh-keygen -t rsa -N "" -f /mnt/etc/secrets/initrd/ssh_host_rsa_key
cp /mnt/etc/secrets/initrd/ssh_host_rsa_key /etc/secrets/initrd/ssh_host_rsa_key

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

rm -rf /tmp/*

echo "Installation complete. Rebooting"

sleep 2

# reboot
#
