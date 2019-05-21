#!/usr/bin/env bash
openssl rsautl -decrypt -inkey "$1".pem -in key.enc -out key
openssl enc -d -aes-256-cbc -iter 10 -in "$2".enc -out "$2" -pass file:./key 
