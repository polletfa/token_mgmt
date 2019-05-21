#!/usr/bin/env bash
for i in "$(dirname "$(realpath "$0")")"/tokens/*; do
    if [ -d "$i" ]; then
        echo "$i"
        if [ -f "$i".tar.gz ]; then
            rm "$i".tar.gz
        fi
        (
            cd "$i" || exit 1
            tar zchf ../"$(basename "$i")".tar.gz .
        )
    fi
done
