#! /bin/bash

CURDIR=`dirname $0`
GETENV_PATH="$CURDIR/getenv.c" 
DEST="/tmp"

function install {
    if [ -z ${OR_HOST+x} ]; then read -p "VM Host: " OR_HOST; fi
    if [ -z ${OR_PORT+x} ]; then read -p "VM Port: " OR_PORT; fi
    if [ -z ${OR_USER+x} ]; then read -p "VM User: " OR_USER; fi
    if [ -z ${OR_PASS+x} ]; then echo -n "VM Pass: "; read -s OR_PASS; fi

    export SSHPASS=$OR_PASS

    set -x

    sshpass -e \
    scp -q -P $OR_PORT -r $GETENV_PATH $OR_USER@$OR_HOST:$DEST

    sshpass -e \
    ssh -q -p $OR_PORT $OR_USER@$OR_HOST 'bash -x' << EOI
        gcc /tmp/getenv.c -o /tmp/getenv
        chmod 777 /tmp/getenv*
EOI
}

read -p "Do you want install getenv on remote machine $OR_HOST:$OR_PORT ? [yY] " -n 1 -r
if [[ $REPLY =~ ^[yY]$ ]]; then
    echo
    install
fi
