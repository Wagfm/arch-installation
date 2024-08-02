#!/bin/bash


ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
echo 'KEYMAP=br-abnt' >> /etc/vconsole.conf
echo 'arch' >> /etc/hostname
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1       localhost' >> /etc/hosts
echo '127.0.1.1 localhost arch' >> /etc/hosts

mkinitcpio -p linux
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Grub --modules='part_gpt part_msdos gcry_sha512' --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service

passwd
useradd -mG wheel,power,storage wagner
passwd wagner
passwd -l root

rm -rf /install-2.sh
exit
