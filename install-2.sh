#!/bin/bash

ROOT_DISK=$1

ROOT_PARTITION="$ROOT_DISK"2

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
echo 'KEYMAP=br-abnt' >> /etc/vconsole.conf
echo 'arch' >> /etc/hostname
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1       localhost' >> /etc/hosts
echo '127.0.1.1 localhost arch' >> /etc/hosts

sed -i '/MODULES=/c\MODULES=(btrfs)' /etc/mkinitcpio.conf
sed -i '/HOOKS=/c\HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)' /etc/mkinitcpio.conf
mkinitcpio -p linux

ROOT_PART_UUID=$(blkid -o value -s UUID "$ROOT_PARTITION")
sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$ROOT_PART_UUID:archrootfs root=/dev/mapper/archrootfs video=1920x1080\"" /etc/default/grub
sed -i "/#GRUB_ENABLE_CRYPTODISK/c\GRUB_ENABLE_CRYPTODISK=y" /etc/default/grub
sed -i "/#GRUB_DISABLE_OS_PROBER/c\GRUB_DISABLE_OS_PROBER=false" /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Grub --modules='part_gpt part_msdos gcry_sha512' --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service

passwd
useradd -mG wheel,power,storage wagner
passwd wagner
passwd -l root

exit 0
