#!/usr/bin/env bash

source "$(dirname "$(realpath "$0")")"/../etc/token_mgmt/config

TOKEN_MANAGEMENT="$(dirname "$(realpath "$0")")"/../etc/token_mgmt/
TOKEN="$TOKEN_MANAGEMENT/.token"

function issue() {
    SIGN="$(cat "$TOKEN_MANAGEMENT"/picture)"

    HEIGHT="$(echo "$SIGN" | wc -l)"
    WIDTH="$(( 2 * ( $(echo "$SIGN" | head -n1 | wc -c ) - 1 ) ))"
    X="$(( ( COLUMNS - WIDTH ) / 2 ))"
    Y="$(( ( LINES - HEIGHT ) / 2 ))"

    echo -e -n "\033[2J\033[$Y;${X}H\033[40m"
    
    prev=
    for (( i=0; i<${#SIGN}; i++ )); do
	if [[ "${SIGN:$i:1}" == $'\n' ]]; then
            echo
            echo -e -n "\033[${X}G"
	else
            if [ "${SIGN:$i:1}" != "$prev" ]; then
		echo -n -e "\033[4${SIGN:$i:1}m"
		prev="${SIGN:$i:1}"
            fi
            echo -n "  "
	fi
    done
    echo -e "\033[H\033[40;37mUnauthorized access!"
}

function wipe() {
    if [ -d "$TOKEN" ]; then
        for i in "$TOKEN"/*.enc; do
	    if [ "$(basename "$i" .enc)" != "*" ]; then
                cp "$i" "$(basename "$i" .enc)"
                rm "$(basename "$i" .enc)"
            fi
        done
    fi
}

function unmount() {
    cd / || exit 1
    umount "$(mount|grep "$TOKEN"|cut -f3 -d\  )" 2>/dev/null
    rmdir "$TOKEN" 2> /dev/null
}

function die() {
    echo -e "\033[31mFailed!\033[0m" >&2

    if [ -f /etc/issue ]; then
	cp /etc/issue /etc/issue.token_mgmt.save
    else
	echo > /etc/issue.token_mgmt.save
    fi
    issue > /etc/issue

    if [ "$MAILTO" != "" ]; then
	journalctl -u token_mgmt --boot | mail -s "[token_mgmt] Unauthorized access!" "$MAILTO"
    fi
    
    wipe
    unmount
    exit 1
}

if [ -f /etc/issue.token_mgmt.save ]; then
    mv /etc/issue.token_mgmt.save /etc/issue
fi

echo -e "\033[32mCreate RAM disk\033[0m"
wipe
unmount
mkdir -p "$TOKEN" || die
mount -t tmpfs tmpfs "$TOKEN" || die
cd "$TOKEN" || die

echo -e "\033[32mExtract token\033[0m"
tar zxvf <(dd if="$DEVICE" of=/dev/stdout skip=512) || die
echo "ID: $(cat "ID")"
echo "PROFILE: $(cat "PROFILE")"

echo -e "\033[32mDecrypt key\033[0m"
openssl rsautl -decrypt -inkey "$TOKEN_MANAGEMENT/keys/$(cat ID).pem" -in key.enc -out key || die

echo -e "\033[32mDecrypt disk keys\033[0m"
for i in $DISKS; do
    if [ -f "$i.enc" ]; then
	openssl enc -d -aes-256-cbc -iter 10 -in "$i".enc -out "$i" -pass file:./key || die
    else
	echo "Warning: no key for $i"
    fi
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
    mount -t overlay overlay -o lowerdir="$lowr,upperdir=$TOKEN/$dirn/$basn,workdir=$TOKEN/$dirn/$basn-work" "$lowr" || die
done

echo -e "\033[32mDecrypt disks\033[0m"
for i in $DISKS; do
    echo "$i"
    cryptsetup open /dev/"$i" "$i"-encrypted --key-file "$TOKEN/$i"
done

#todo: put in a script on the token
systemctl daemon-reload

wipe
