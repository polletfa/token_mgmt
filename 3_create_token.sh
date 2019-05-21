#!/usr/bin/env bash

cd "$(dirname "$(realpath "$0")")" || exit 1

UUID="$(uuidgen)"

if [ "$1" == "" ]; then
    echo  -e "\033[31mYou need to specify a profile!\033[0m" >&2
    exit 1
fi

if [ ! -f profiles/"$1".tar ]; then 
    echo -e "\033[31mProfile not found!\033[0m" >&2
    exit 1
fi

function die() {
    rm token.keys/"$UUID".*
    rm -fr tokens/"$UUID"
    echo -e "\033[31mFailed!\033[0m" >&2
    exit 1
}

mkdir -p tokens/"$UUID"
echo "$UUID" > tokens/"$UUID"/ID
echo "$1" > tokens/"$UUID"/PROFILE

# Create the token key pair
if [ ! -d token.keys ]; then
    mkdir token.keys
fi
echo -e "\033[32mGenerate private key...\033[0m"
openssl genrsa -out token.keys/"$UUID".private.pem 4096 || die
echo -e "\033[32mGenerate public key...\033[0m"
openssl rsa -pubout -in token.keys/"$UUID".private.pem -out token.keys/"$UUID".public.pem || die

# Generate an encryption key
echo -e "\033[32mGenerate encryption key...\033[0m"
openssl rand -base64 256 > token.keys/"$UUID".key || die

# Encrypt the key
echo -e "\033[32mEncrypt key...\033[0m"
openssl rsautl -encrypt -inkey token.keys/"$UUID".public.pem -pubin -in token.keys/"$UUID".key -out tokens/"$UUID"/key.enc || die

# Encrypt the disk keys
echo -e "\033[32mEncrypt disk keys...\033[0m"
for i in disk.keys/*; do
    echo "$i"
    openssl enc -aes-256-cbc -iter 10 -in "$i" -out tokens/"$UUID"/"$(basename "$i")".enc -pass file:./token.keys/"$UUID".key || die
done

# Encrypt the profile
if [ -f profiles/"$1".tar ]; then
    echo -e "\033[32mEncrypt profile...\033[0m"
    openssl enc -aes-256-cbc -iter 10 -in profiles/"$1".tar -out tokens/"$UUID"/profile.tar.enc -pass file:./token.keys/"$UUID".key || die
fi

echo -e "\033[32mToken $UUID created."

