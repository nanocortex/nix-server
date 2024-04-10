#!/usr/bin/env bash

set -e -u -o pipefail

# setfont ter-v24n
DISK="$1"
HOSTNAME="$2"
GITHUB_REPO="https://github.com/nanocortex/nix-server"
TEST=0

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

updateCryptSwap() {
  # Step 1: Get the UUID for the swap partition
  swap_uuid="$(lsblk -f | grep swap | sed -e 's/\s\+/ /g' | awk '{print $6}')"

  # Step 2a: Define the search pattern to match the beginning of the 'cryptroot' line
  search_pattern='^ *boot\.initrd\.luks\.devices\."cryptroot"'

  # Step 2b: Create the addition line for 'cryptswap' with the fetched UUID
  addition_line="  boot.initrd.luks.devices.\"cryptswap\".device = \"/dev/disk/by-uuid/$swap_uuid\";"

  # Step 2c: Insert the 'cryptswap' line after 'cryptroot' line in hardware-configuration.nix
  sed -i "/$search_pattern/a $addition_line" "/mnt/etc/nixos/hardware-configuration.nix"

  echo "Updated cryptswap configuration in hardware-configuration.nix"
}

# Pre-cleanup activities
closeLuks "/dev/mapper/cryptswap"
closeLuks "/dev/mapper/cryptroot"

check_and_unmount /mnt/boot
check_and_unmount /mnt

# Improve swap off handling
swapoff -a || true # Continue even if swapoff fails, adjust as needed for safety

# Wait and ensure devices are not in use before wiping
sleep 2
wipefs -a "$DISK"
sleep 2

# Partition and format disk
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on
mkfs.vfat "$DISK"1

# Check if TEST variable is set to 1
if [ "${TEST}" == "1" ]; then
    PASSWORD="password"
else
    # Ask for the password
    echo "ENTER Password for the LUKS partition: "
    read -s PASSWORD

    # Verify the password
    echo "Verify the password: "
    read -s PASSWORD_VERIFY

    # Check if passwords match
    if [ $PASSWORD != $PASSWORD_VERIFY ]; then
        echo "Passwords do not match."
        exit 1
    fi
fi

# Setting up encryption for swap
parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
echo -n $PASSWORD | cryptsetup luksFormat "$DISK"2 -
echo -n $PASSWORD | cryptsetup open "$DISK"2 cryptswap -
mkswap -L Swap /dev/mapper/cryptswap
swapon /dev/mapper/cryptswap

# Setting up root partition
parted "$DISK" -- mkpart primary 9GiB 100%
echo -n $PASSWORD | cryptsetup luksFormat "$DISK"3 -
echo -n $PASSWORD | cryptsetup open "$DISK"3 cryptroot -
mkfs.ext4 -L ext4 /dev/mapper/cryptroot -F

unset PASSWORD
unset PASSWORD_VERIFY

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot && mount "$DISK"1 /mnt/boot

# create configuration
nixos-generate-config --root /mnt

mkdir -p /mnt/etc/secrets/initrd
mkdir -p /etc/secrets/initrd
ssh-keygen -t rsa -N "" -f /mnt/etc/secrets/initrd/ssh_host_rsa_key
cp /mnt/etc/secrets/initrd/ssh_host_rsa_key /etc/secrets/initrd/ssh_host_rsa_key

rm -rf /tmp/nixconf
nix-shell -p git --run "git clone $GITHUB_REPO /tmp/nixconf"

updateCryptSwap

cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hw.conf
cp -r /tmp/nixconf/* /mnt/etc/nixos
cp /tmp/hw.conf /mnt/etc/nixos/hosts/$HOSTNAME/hardware-configuration.nix


# install nixos
nixos-install --flake /mnt/etc/nixos#$HOSTNAME --root /mnt

# cp -r /mnt/etc/nixos /mnt/home/user/dotfiles
nix-shell -p git --run "git clone $GITHUB_REPO /mnt/home/user/dotfiles"
# chown -R user /mnt/home/user/dotfiles
cp /tmp/hw.conf /mnt/home/user/dotfiles/hosts/$HOSTNAME/hardware-configuration.nix

rm -rf /mnt/etc/nixos/*

cp /tmp/ssh_host_ed25519_key /mnt/etc/ssh
cp /tmp/ssh_host_ed25519_key.pub /mnt/etc/ssh

# Final cleanup and reboot
rm -rf /tmp/*
echo "Installation complete. Rebooting"
sleep 2
# reboot
