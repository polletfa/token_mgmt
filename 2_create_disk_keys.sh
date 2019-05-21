#!/usr/bin/env bash
# shellcheck source=./config
source "$(dirname "$(realpath "$0")")"/config

if [ ! -d "$(dirname "$(realpath "$0")")"/disk.keys ]; then
    mkdir "$(dirname "$(realpath "$0")")"/disk.keys
fi

for d in $DISKS; do
    echo "$d"
    dd if=/dev/urandom of="$(dirname "$(realpath "$0")")"/disk.keys/"$d" bs=4096 count=1 iflag=fullblock
done
