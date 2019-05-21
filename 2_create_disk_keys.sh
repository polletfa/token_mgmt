#!/usr/bin/env bash
# shellcheck source=./config
source "$(dirname "$(realpath "$0")")"/config

if [ ! -d disk.keys ]; then
    mkdir disk.keys
fi

for d in $DISKS; do
    echo "$d"
    dd if=/dev/urandom of=disk.keys/"$d" bs=4096 count=1 iflag=fullblock
done
