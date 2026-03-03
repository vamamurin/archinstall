#!/bin/bash

set -e

# ==========================================
# Environment Variables
# ==========================================
DISK="/dev/sdX" 
USER="admin" 
HOST="debian-wazuh" 
LOCALE="en_US.UTF-8" 
TIMEZONE="Asia/Ho_Chi_Minh"
DEBIAN_RELEASE="bookworm"
DEBIAN_MIRROR="http://deb.debian.org/debian"

echo "Start setting up Debian $DEBIAN_RELEASE (Headless) via Arch ISO..."
sleep 2

echo "Install debootstrap and arch-install-scripts into Arch environment..."
pacman -Sy --noconfirm debootstrap debian-archive-keyring arch-install-scripts wget

# 1. MBR partitioning
echo "Create an MBR partition table..."
parted -s "$DISK" mklabel msdos
parted -s "$DISK" mkpart primary ext4 1MiB 513MiB
parted -s "$DISK" set 1 boot on
parted -s "$DISK" mkpart primary ext4 513MiB 100%

BOOT="${DISK}1"
ROOT="${DISK}2"

echo "Format partitions..."
mkfs.ext4 -F "$BOOT"
mkfs.ext4 -F "$ROOT"

echo "Mount partitions..."
mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$BOOT" /mnt/boot

# 2. Install the basic system using debootstrap
echo "Currently installing the Debian base system..."
debootstrap --arch=amd64 $DEBIAN_RELEASE /mnt $DEBIAN_MIRROR

# 3. Gen fstab using arch's tool
echo "Creating file fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# 4. Chroot into debian to configure
echo "Chroot into new system..."

mount --types proc /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --rbind /dev /mnt/dev
mount --rbind /run /mnt/run

arch-chroot /mnt /bin/bash <<EOF

DISK="$DISK"

# Timezone configuration
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# Update repo and install the basic packages
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y locales sudo network-manager vim wget curl

# Locale configuration
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/default/locale

# Hostname configuration
echo "$HOST" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
EOL

# Install Kernel and Bootloader
apt-get install -y linux-image-amd64 grub-pc

# Turn on network service
systemctl enable NetworkManager

# Install GRUB
grub-install --target=i386-pc --recheck \$DISK
update-grub

# set a password
echo "==================================="
echo "Enter the password for ROOT:"
passwd < /dev/tty

# Create user admin
useradd -m -G sudo -s /bin/bash $USER
echo "Enter the password for $USER:"
passwd $USER < /dev/tty
echo "==================================="

EOF

# 5. finish
echo "Done! Debian $DEBIAN_RELEASE has been installed (Headless/CLI)."
umount -R /mnt
echo "use reboot"
