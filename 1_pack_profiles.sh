#!/usr/bin/env bash
for i in profiles/*; do
    if [ -d "$i" ]; then
        echo "$i"
        if [ -f "$i".tar ]; then
            rm "$i".tar
        fi
        (
            cd "$i" || exit 1
            tar chf ../"$(basename "$i")".tar .
        )
    fi
done
