#!/usr/bin/env bash
if [ "$1" = "" ]; then
    echo -e "\033[31mPlease specify a token.\033[0m" >&2
    exit 1
fi
if [ ! -f "$(dirname "$(realpath "$0")")"/tokens/"$1".tar.gz ]; then
    echo -e "\033[31mToken not found.\033[0m" >&2
    exit 1
fi

# shellcheck source=./config
source "$(dirname "$(realpath "$0")")"/config

echo -en "o\nn\np\n\n\n\nt\nb\nw\n" | sudo fdisk "$DEVICE"
mkfs.vfat "$DEVICE_PART1"

sudo dd if="$(dirname "$(realpath "$0")")"/tokens/"$1".tar.gz of="$DEVICE" seek=512

