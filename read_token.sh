#!/usr/bin/env bash

# shellcheck source=./config
source "$(dirname "$(realpath "$0")")"/config

TOKEN_MANAGEMENT="$(dirname "$(realpath "$0")")"
TOKEN="$TOKEN_MANAGEMENT/.token"

function wipe() {
    if [ -d "$TOKEN" ]; then
        for i in "$TOKEN"/*.enc; do
            cp "$i" "$(basename "$i" .enc)"
            rm "$(basename "$i" .enc)"
        done
    fi
}

function unmount() {
    cd /
    umount $(mount|grep "$TOKEN"|cut -f3 -d\  )
    rmdir "$TOKEN"
}

function die() {
    echo -e "\033[31mFailed!\033[0m" >&2
    wipe
    unmount
    exit 1
}

echo -e "\033[32mCreate RAM disk\033[0m"
wipe
unmount
mkdir -p "$TOKEN" || die
mount -t tmpfs tmpfs "$TOKEN" || die
cd "$TOKEN" || die

echo -e "\033[32mExtract token\033[0m"
tar xvf /dev/mmcblk0 || die

echo -e "\033[32mDecrypt key\033[0m"
openssl rsautl -decrypt -inkey "$TOKEN_MANAGEMENT/token.keys/$(cat ID).private.pem" -in key.enc -out key || die

echo -e "\033[32mDecrypt disk keys\033[0m"
for i in $DISKS; do
    openssl enc -d -aes-256-cbc -iter 10 -in "$i".enc -out "$i" -pass file:./key || die
done

echo -e "\033[32mDecrypt profile\033[0m"
openssl enc -d -aes-256-cbc -iter 10 -in profile.tar.enc -out profile.tar -pass file:./key || die

echo -e "\033[32mUnpack profile\033[0m"
tar xvf profile.tar

echo -e "\033[32mMount overlays\033[0m"
find overlays -name "*.tar" -print | while read -r i; do
    dirn="$(dirname "$i")"
    basn="$(basename "$i" .tar)"
    lowr="${dirn#overlays}/$basn"

    echo "$lowr"
    mkdir "$dirn/$basn" || die
    tar xvf "$i" -C "$dirn/$basn" || die

    mkdir "$dirn/$basn-work" || die
    mount -t overlay overlay -o lowerdir="$lowr",upperdir="$TOKEN/$dirn/$basn",workdir="$TOKEN/$dirn/$basn-work" "$lowr" || die
done

## todo: decrypt disks

wipe
