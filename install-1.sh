#!/bin/bash

ROOT_DISK=$1

fdisk $ROOT_DISK << EOF
g
n
1

+512M
t
1
n
2


p
w
EOF

EFI_PARTITION="$ROOT_DISK"1
ROOTFS_PARTITION="$ROOT_DISK"2
MAPPED_PARTITION="/dev/mapper/archrootfs"

mkfs.fat -F32 "$EFI_PARTITION"

cryptsetup luksFormat --hash sha512 --pbkdf pbkdf2 "$ROOTFS_PARTITION"
cryptsetup luksOpen "$ROOTFS_PARTITION" archrootfs

mkfs.btrfs "$MAPPED_PARTITION"

mount "$MAPPED_PARTITION" /mnt
cd /mnt
    btrfs subvolume create @
    btrfs subvolume create @home
    btrfs subvolume create @swap
    btrfs subvolume create @tmp
    btrfs subvolume create @var_cache
    btrfs subvolume create @var_log
    btrfs subvolume create @var_tmp
cd
umount /mnt

mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@ "$MAPPED_PARTITION" /mnt
mount --mkdir -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@home "$MAPPED_PARTITION" /mnt/home
mount --mkdir -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@swap "$MAPPED_PARTITION" /mnt/swap
mount --mkdir -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@tmp "$MAPPED_PARTITION" /mnt/tmp
mount --mkdir -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var_cache "$MAPPED_PARTITION" /mnt/var/cache
mount --mkdir -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var_log "$MAPPED_PARTITION" /mnt/var/log
mount --mkdir -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=@var_tmp "$MAPPED_PARTITION" /mnt/var/tmp
mount --mkdir "$EFI_PARTITION" /mnt/boot/efi

reflector --latest 15 --country 'Brazil,Chile,Colombia,Ecuador,Paraguay,United States' --sort rate --save /etc/pacman.d/mirrorlist
sed -i '/#Color/c\Color' /etc/pacman.conf
sed -i '/#ParallelDownloads/c\ParallelDownloads = 5' /etc/pacman.conf

pacstrap -K /mnt base linux linux-firmware efibootmgr grub intel-ucode networkmanager neovim sudo git base-devel btrfs-progs mtools dosfstools ntfs-3g neofetch

genfstab -U /mnt >> /mnt/etc/fstab
