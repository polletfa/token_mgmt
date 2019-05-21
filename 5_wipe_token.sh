#!/usr/bin/env bash
sudo dd if=/dev/urandom of=/dev/mmcblk0 bs=1024 status=progress
