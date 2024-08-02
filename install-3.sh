#!/bin/bash

timedatectl set-ntp true

sudo pacman -Syu

sudo pacman -S openssh --noconfirm

cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
        makepkg -si
    cd ..
cd

yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save

