#!/usr/bin/env bash
if [ "$1" = "" ]; then
    echo -e "\033[31mPlease specify a token.\033[0m" >&2
    exit 1
fi
if [ ! -f "$(dirname "$(realpath "$0")")"/tokens/"$1".tar.gz ]; then
    echo -e "\033[31mToken not found.\033[0m" >&2
    exit 1
fi

echo -en "o\nn\np\n\n\n\nt\nb\nw\n" | sudo fdisk /dev/mmcblk0
sudo dd if="$(dirname "$(realpath "$0")")"/tokens/"$1".tar.gz of=/dev/mmcblk0 seek=512
mkfs.vfat /dev/mmcblk0p1

