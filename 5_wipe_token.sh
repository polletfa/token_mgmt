#!/usr/bin/env bash
# shellcheck source=./config
source "$(dirname "$(realpath "$0")")"/config

sudo dd if=/dev/urandom of="$DEVICE" bs=1024 status=progress
