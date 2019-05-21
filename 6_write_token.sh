#!/usr/bin/env bash
if [ "$1" = "" ]; then
    echo -e "\033[31mPlease specify a token.\033[0m" >&2
    exit 1
fi
if [ ! -f tokens/"$1".tar ]; then
    echo -e "\033[31mToken not found.\033[0m" >&2
    exit 1
fi

sudo dd if=tokens/"$1".tar of=/dev/mmcblk0

